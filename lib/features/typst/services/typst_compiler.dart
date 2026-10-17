import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../../../core/utils/path_validator.dart';
import '../../preview/services/sync_anchor_injector.dart';
import '../models/compilation_result.dart';
import '../models/sync_anchor.dart';
import 'typst_path_resolver.dart';

/// Result of an anchor probe: the queried [anchors] plus an optional diagnostic
/// [error] describing why the probe produced nothing.
class SyncAnchorResult {
  final List<SyncAnchor> anchors;
  final String? error;
  const SyncAnchorResult(this.anchors, {this.error});
}

/// Service for compiling Typst documents
class TypstCompiler {
  final TypstPathResolver _pathResolver;

  TypstCompiler(this._pathResolver);

  /// Get the path to the Typst executable
  ///
  /// Uses the shared TypstPathResolver to find the executable.
  /// Defaults to 'typst' if not found (will fail later with clear error).
  Future<String> _getTypstExecutable() async {
    final path = await _pathResolver.findExecutable();
    return path ?? 'typst';
  }

  /// Compile a Typst document for a specific language
  ///
  /// This function:
  /// 1. Validates inputs (language code, paths)
  /// 2. Injects the language code into lang.typ
  /// 3. Runs typst compile command
  /// 4. Returns the result with PDF path or error
  ///
  /// Throws [ArgumentError] if language code or paths are invalid.
  Future<CompilationResult> compileForLanguage({
    required String projectPath,
    required String languageCode,
    String? outputDir,
  }) async {
    try {
      // Step 0: Validate inputs for security
      PathValidator.validateLanguageCode(languageCode);
      final sanitizedProjectPath = PathValidator.sanitizeProjectPath(
        projectPath,
      );

      // Validate project directory exists
      if (!await Directory(sanitizedProjectPath).exists()) {
        return CompilationResult.error(
          message: 'Project directory does not exist: $sanitizedProjectPath',
          languageCode: languageCode,
        );
      }

      // Step 1: Inject language into lang.typ
      await _injectLanguage(sanitizedProjectPath, languageCode);

      // Step 1b: Refresh the image manifest so smart-image() can fall back and
      // render placeholders for not-yet-inserted images instead of failing.
      await _writeImageManifest(sanitizedProjectPath);

      // Step 2: Determine and validate output path (must be absolute for PdfViewer)
      final outputDirectory = PathValidator.validateOutputDirectory(
        outputDir ?? '',
        sanitizedProjectPath,
      );
      await Directory(outputDirectory).create(recursive: true);

      // Use absolute path for PDF viewer to locate the file correctly
      final outputPdfPath = path.absolute(
        path.join(outputDirectory, 'output_$languageCode.pdf'),
      );

      // Step 3: Run Typst compiler
      final mainTypPath = path.join(sanitizedProjectPath, 'main.typ');
      final typstExecutable = await _getTypstExecutable();

      final result = await Process.run(typstExecutable, [
        'compile',
        mainTypPath,
        outputPdfPath,
      ], workingDirectory: sanitizedProjectPath);

      if (result.exitCode != 0) {
        // Compilation failed - stderr is already captured in error result
      }

      // Step 4: Check result
      if (result.exitCode == 0) {
        return CompilationResult.success(
          pdfPath: outputPdfPath,
          languageCode: languageCode,
          compiledAt: DateTime.now(),
        );
      } else {
        return CompilationResult.error(
          message: 'Compilation failed',
          languageCode: languageCode,
          stderr: result.stderr.toString(),
          exitCode: result.exitCode,
        );
      }
    } catch (e) {
      return CompilationResult.error(
        message: 'Compilation error: $e',
        languageCode: languageCode,
      );
    }
  }

  /// Label emitted by every injected anchor marker.
  static const String _syncResultLabel = 'ld-result';

  /// Prefix for all temporary probe files (ignored by the auto-refresh watcher).
  static const String _syncTempPrefix = '.ldsync-';

  static final RegExp _includeRe = RegExp(r'#include\s+"([^"]+)"');

  /// Query the exact PDF position (page + y) of every paragraph/heading anchor.
  ///
  /// Typst 0.11 has no SyncTeX, so this injects line-tagged `#metadata` markers
  /// (see [SyncAnchorInjector]) into temporary copies of each chapter, builds a
  /// probe `main` that includes those copies, and reads the markers' resolved
  /// layout positions back via `typst query`. lang.typ is expected to already
  /// be injected for [languageCode] by a preceding compile.
  ///
  /// Best-effort: on any failure it returns an empty anchor list plus a
  /// diagnostic in [SyncAnchorResult.error]. All temporary files are removed.
  Future<SyncAnchorResult> queryAnchorPositions({
    required String projectPath,
    required String languageCode,
  }) async {
    final tempFiles = <File>[];
    try {
      PathValidator.validateLanguageCode(languageCode);
      final root = PathValidator.sanitizeProjectPath(projectPath);
      if (!await Directory(root).exists()) {
        return const SyncAnchorResult([], error: 'project directory missing');
      }

      // Ensure the image manifest exists so the probe (which includes the real
      // document) can resolve pandoc-compat's smart-image().
      await _writeImageManifest(root);

      final mainPath = path.join(root, 'main.typ');
      final mainFile = File(mainPath);
      if (!await mainFile.exists()) {
        return const SyncAnchorResult([], error: 'main.typ missing');
      }
      final mainSrc = await mainFile.readAsString();

      final injector = SyncAnchorInjector();
      final indexToPath = <int, String>{};
      var chapterIndex = 0;

      // Rewrite each chapter #include to a marker-injected temp copy.
      var probeMain = mainSrc;
      final matches = _includeRe.allMatches(mainSrc).toList();
      for (final m in matches) {
        final incRel = m.group(1)!;
        if (!incRel.endsWith('.typ')) continue;
        final incAbs = path.normalize(path.join(root, incRel));
        final incFile = File(incAbs);
        if (!await incFile.exists()) continue;

        final idx = chapterIndex++;
        indexToPath[idx] = incAbs;

        final transformed = injector.inject(
          sourceText: await incFile.readAsString(),
          languageCode: languageCode,
          chapterIndex: idx,
        );
        final tempRel = _tempSibling(incRel);
        final tempAbs = path.normalize(path.join(root, tempRel));
        final tempFile = File(tempAbs);
        await tempFile.writeAsString(transformed);
        tempFiles.add(tempFile);

        probeMain = probeMain.replaceAll('"$incRel"', '"$tempRel"');
      }

      // If there were no chapter includes, anchor main.typ itself.
      if (indexToPath.isEmpty) {
        indexToPath[0] = mainPath;
        probeMain = injector.inject(
          sourceText: mainSrc,
          languageCode: languageCode,
          chapterIndex: 0,
        );
      }

      // Append the result collector and write the probe main.
      probeMain =
          '$probeMain\n'
          '#context [\n'
          '  #metadata(query(<${SyncAnchorInjector.label}>).map(m => (\n'
          '    c: m.value.c,\n'
          '    l: m.value.l,\n'
          '    page: m.location().page(),\n'
          '    y: m.location().position().y.pt(),\n'
          '  ))) <$_syncResultLabel>\n'
          ']\n';
      final probeMainRel = '${_syncTempPrefix}main.typ';
      final probeMainFile = File(path.join(root, probeMainRel));
      await probeMainFile.writeAsString(probeMain);
      tempFiles.add(probeMainFile);

      final typstExecutable = await _getTypstExecutable();
      final result = await Process.run(typstExecutable, [
        'query',
        probeMainRel,
        '<$_syncResultLabel>',
        '--field',
        'value',
        '--one',
        '--format',
        'json',
      ], workingDirectory: root);

      if (result.exitCode != 0) {
        return SyncAnchorResult(
          const [],
          error: 'query failed: ${_firstLine(result.stderr.toString())}',
        );
      }

      final decoded = jsonDecode(result.stdout.toString());
      if (decoded is! List) {
        return const SyncAnchorResult([], error: 'unexpected query output');
      }

      final anchors = <SyncAnchor>[];
      for (final entry in decoded) {
        if (entry is! Map) continue;
        final c = entry['c'];
        final l = entry['l'];
        final page = entry['page'];
        final y = entry['y'];
        if (c is! num || l is! num || page is! num || y is! num) continue;
        final filePath = indexToPath[c.toInt()];
        if (filePath == null) continue;
        anchors.add(
          SyncAnchor(
            filePath: filePath,
            line: l.toInt(),
            page: page.toInt(),
            y: y.toDouble(),
          ),
        );
      }
      return SyncAnchorResult(anchors);
    } catch (e) {
      return SyncAnchorResult(const [], error: '$e');
    } finally {
      for (final f in tempFiles) {
        try {
          if (await f.exists()) await f.delete();
        } catch (_) {}
      }
    }
  }

  /// Insert the temp prefix into a relative include path's basename, keeping it
  /// in the same directory so relative includes/images still resolve.
  String _tempSibling(String relPath) {
    final dir = path.dirname(relPath);
    final base = path.basename(relPath);
    final prefixed = '$_syncTempPrefix$base';
    return dir == '.' ? prefixed : path.join(dir, prefixed);
  }

  static String _firstLine(String s) {
    final t = s.trim();
    if (t.isEmpty) return 'no output';
    final nl = t.indexOf('\n');
    return nl == -1 ? t : t.substring(0, nl);
  }

  /// Maximum number of concurrent compilations to prevent resource exhaustion
  static const int _maxConcurrentCompilations = 4;

  /// Compile PDFs for multiple languages with concurrency limit
  ///
  /// Limits parallel compilations to prevent CPU thrashing and memory spikes.
  /// All language codes are validated before compilation begins.
  Future<List<CompilationResult>> compileMultipleLanguages({
    required String projectPath,
    required List<String> languageCodes,
    String? outputDir,
  }) async {
    if (languageCodes.isEmpty) {
      return [];
    }

    // Validate all language codes upfront
    for (final lang in languageCodes) {
      PathValidator.validateLanguageCode(lang);
    }

    // Process in batches to limit concurrency
    final results = <CompilationResult>[];
    for (var i = 0; i < languageCodes.length; i += _maxConcurrentCompilations) {
      final batch = languageCodes.skip(i).take(_maxConcurrentCompilations);
      final batchFutures = batch.map((lang) {
        return compileForLanguage(
          projectPath: projectPath,
          languageCode: lang,
          outputDir: outputDir,
        );
      });
      results.addAll(await Future.wait(batchFutures));
    }

    return results;
  }

  /// Inject language code into lang.typ file
  ///
  /// Modifies the lang.typ file to set:
  /// ```typst
  /// #let current-lang = "en"
  /// ```
  Future<void> _injectLanguage(String projectPath, String languageCode) async {
    final langTypPath = path.join(projectPath, 'lang.typ');
    final langFile = File(langTypPath);

    if (!await langFile.exists()) {
      // Create lang.typ if it doesn't exist
      await langFile.writeAsString('#let current-lang = "$languageCode"\n');
      return;
    }

    // Read existing content
    final content = await langFile.readAsString();

    // Replace or add current-lang definition
    final langPattern = RegExp(r'#let\s+current-lang\s*=\s*"[^"]*"');

    String newContent;
    if (langPattern.hasMatch(content)) {
      // Replace existing definition
      newContent = content.replaceAll(
        langPattern,
        '#let current-lang = "$languageCode"',
      );
    } else {
      // Add definition at the beginning
      newContent = '#let current-lang = "$languageCode"\n$content';
    }

    // Only write when something actually changed, to avoid bumping the file's
    // modification time and triggering a redundant auto-refresh recompile.
    if (newContent != content) {
      await langFile.writeAsString(newContent);
    }
  }

  /// Name of the generated image manifest consumed by pandoc-compat.typ.
  static const String _imageManifestFile = 'lingodoc-images.typ';

  /// Scan the project's `images/` directory and (re)write `lingodoc-images.typ`
  /// listing every image file that exists on disk (relative paths). This lets
  /// `smart-image()` fall back across languages and render a placeholder for
  /// not-yet-inserted images instead of aborting the whole compile.
  ///
  /// Only runs for projects that use this convention (an `images/` directory or
  /// a `pandoc-compat.typ`); otherwise it does nothing. Best-effort: failures
  /// are swallowed so a manifest problem never blocks compilation.
  Future<void> _writeImageManifest(String projectPath) async {
    try {
      final imagesDir = Directory(path.join(projectPath, 'images'));
      final hasImages = await imagesDir.exists();
      final usesCompat = await File(
        path.join(projectPath, 'pandoc-compat.typ'),
      ).exists();
      if (!hasImages && !usesCompat) return;

      final relPaths = <String>[];
      if (hasImages) {
        await for (final entity in imagesDir.list(recursive: true)) {
          if (entity is File) {
            final ext = path.extension(entity.path).toLowerCase();
            if (ext == '.png' ||
                ext == '.jpg' ||
                ext == '.jpeg' ||
                ext == '.gif' ||
                ext == '.svg' ||
                ext == '.webp') {
              // Relative to the project root, with forward slashes for Typst.
              final rel = path
                  .relative(entity.path, from: projectPath)
                  .replaceAll(r'\', '/');
              relPaths.add(rel);
            }
          }
        }
      }
      relPaths.sort();

      final buffer = StringBuffer()
        ..writeln('// Auto-generated by LingoDoc on each compile. Do not edit.')
        ..writeln('// Lists image files present under images/ so smart-image()')
        ..writeln('// can fall back and show placeholders for missing images.')
        ..write('#let available-images = (');
      if (relPaths.isEmpty) {
        buffer.write(')\n');
      } else {
        buffer.writeln();
        for (final p in relPaths) {
          buffer.writeln('  "$p",');
        }
        buffer.writeln(')');
      }
      final content = buffer.toString();

      final manifest = File(path.join(projectPath, _imageManifestFile));
      // Write only when changed, to avoid needless disk churn.
      if (!await manifest.exists() ||
          await manifest.readAsString() != content) {
        await manifest.writeAsString(content);
      }
    } catch (_) {
      // Best-effort: never let manifest generation break compilation.
    }
  }

  /// Watch a Typst file for changes and recompile automatically
  ///
  /// Returns a Stream that emits compilation results when the file changes.
  /// Validates inputs before starting the watcher.
  Stream<CompilationResult> watchAndCompile({
    required String projectPath,
    required String languageCode,
    String? outputDir,
    Duration debounce = const Duration(milliseconds: 500),
  }) async* {
    // Validate inputs upfront
    PathValidator.validateLanguageCode(languageCode);
    final sanitizedProjectPath = PathValidator.sanitizeProjectPath(projectPath);

    final mainTypPath = path.join(sanitizedProjectPath, 'main.typ');
    final watcher = File(mainTypPath).watch(events: FileSystemEvent.modify);

    DateTime? lastCompileTime;

    await for (final _ in watcher) {
      final now = DateTime.now();

      // Debounce: Only compile if enough time has passed since last compile
      if (lastCompileTime == null ||
          now.difference(lastCompileTime) > debounce) {
        lastCompileTime = now;

        final result = await compileForLanguage(
          projectPath: sanitizedProjectPath,
          languageCode: languageCode,
          outputDir: outputDir,
        );

        yield result;
      }
    }
  }

  /// Check if Typst is available
  Future<bool> isTypstAvailable() async {
    try {
      final typstExecutable = await _getTypstExecutable();
      final result = await Process.run(typstExecutable, ['--version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Get Typst version
  Future<String?> getTypstVersion() async {
    try {
      final typstExecutable = await _getTypstExecutable();
      final result = await Process.run(typstExecutable, ['--version']);
      if (result.exitCode == 0) {
        // Output format: "typst 0.11.1"
        return result.stdout.toString().trim();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
