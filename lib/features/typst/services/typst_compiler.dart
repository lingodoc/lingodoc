import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../models/compilation_result.dart';

/// Service for compiling Typst documents
class TypstCompiler {
  String? _cachedTypstPath;

  /// Get the path to the Typst executable
  ///
  /// Checks in order:
  /// 1. System PATH (typst command)
  /// 2. ~/.local/bin/typst (Linux/macOS installation directory)
  /// 3. Application support bin directory (Windows)
  Future<String> _getTypstExecutable() async {
    // Return cached path if available
    if (_cachedTypstPath != null) {
      return _cachedTypstPath!;
    }

    // Try system PATH first
    try {
      final result = await Process.run(
        Platform.isWindows ? 'where' : 'which',
        ['typst'],
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => ProcessResult(0, 1, '', 'timeout'),
      );
      if (result.exitCode == 0) {
        _cachedTypstPath = 'typst';
        return _cachedTypstPath!;
      }
    } catch (e) {
      // which/where command not available or failed
    }

    // Try installation directories
    if (Platform.isLinux || Platform.isMacOS) {
      final homeDir = Platform.environment['HOME'];
      if (homeDir != null) {
        final localBinPath = path.join(homeDir, '.local', 'bin', 'typst');
        if (await File(localBinPath).exists()) {
          _cachedTypstPath = localBinPath;
          return _cachedTypstPath!;
        }
      }
    } else if (Platform.isWindows) {
      try {
        final appSupportDir = await getApplicationSupportDirectory();
        final binPath = path.join(appSupportDir.path, 'bin', 'typst.exe');
        if (await File(binPath).exists()) {
          _cachedTypstPath = binPath;
          return _cachedTypstPath!;
        }
      } catch (e) {
        // getApplicationSupportDirectory failed
      }
    }

    // Default to 'typst' and let it fail if not found
    return 'typst';
  }
  /// Compile a Typst document for a specific language
  ///
  /// This function:
  /// 1. Injects the language code into lang.typ
  /// 2. Runs typst compile command
  /// 3. Returns the result with PDF path or error
  Future<CompilationResult> compileForLanguage({
    required String projectPath,
    required String languageCode,
    String? outputDir,
  }) async {
    try {
      // Step 1: Inject language into lang.typ
      await _injectLanguage(projectPath, languageCode);

      // Step 2: Determine output path (must be absolute for PdfViewer)
      final outputDirectory = outputDir ?? path.join(projectPath, 'output');
      await Directory(outputDirectory).create(recursive: true);

      // Use absolute path for PDF viewer to locate the file correctly
      final outputPdfPath = path.absolute(path.join(
        outputDirectory,
        'output_$languageCode.pdf',
      ));

      // Step 3: Run Typst compiler
      final mainTypPath = path.join(projectPath, 'main.typ');
      final typstExecutable = await _getTypstExecutable();

      final result = await Process.run(
        typstExecutable,
        [
          'compile',
          mainTypPath,
          outputPdfPath,
        ],
        workingDirectory: projectPath,
      );

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

  /// Compile PDFs for multiple languages in parallel
  Future<List<CompilationResult>> compileMultipleLanguages({
    required String projectPath,
    required List<String> languageCodes,
    String? outputDir,
  }) async {
    final futures = languageCodes.map((lang) {
      return compileForLanguage(
        projectPath: projectPath,
        languageCode: lang,
        outputDir: outputDir,
      );
    });

    return Future.wait(futures);
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

    // Write back to file
    await langFile.writeAsString(newContent);
  }

  /// Watch a Typst file for changes and recompile automatically
  ///
  /// Returns a Stream that emits compilation results when the file changes
  Stream<CompilationResult> watchAndCompile({
    required String projectPath,
    required String languageCode,
    String? outputDir,
    Duration debounce = const Duration(milliseconds: 500),
  }) async* {
    final mainTypPath = path.join(projectPath, 'main.typ');
    final watcher = File(mainTypPath).watch(events: FileSystemEvent.modify);

    DateTime? lastCompileTime;

    await for (final _ in watcher) {
      final now = DateTime.now();

      // Debounce: Only compile if enough time has passed since last compile
      if (lastCompileTime == null ||
          now.difference(lastCompileTime) > debounce) {
        lastCompileTime = now;

        final result = await compileForLanguage(
          projectPath: projectPath,
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
