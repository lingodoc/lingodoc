import 'dart:io';
import 'package:path/path.dart' as path;

/// The outcome of planning a chapter split at a caret position.
class SplitPlan {
  /// True when the split can be performed.
  final bool ok;

  /// Human-readable reason when [ok] is false (shown to the user).
  final String? reason;

  /// Text kept in the original file (everything above the cut).
  final String head;

  /// Text moved out (the cut section to end-of-file).
  final String tail;

  /// The original file's header (imports/comments above the first unit),
  /// prepended to the new file so it compiles standalone.
  final String header;

  /// Full content for the new file (`header + tail`).
  final String newFileContent;

  /// Heading text at the cut, used to suggest a filename.
  final String cutHeading;

  const SplitPlan._({
    required this.ok,
    this.reason,
    this.head = '',
    this.tail = '',
    this.header = '',
    this.newFileContent = '',
    this.cutHeading = '',
  });

  factory SplitPlan.invalid(String reason) =>
      SplitPlan._(ok: false, reason: reason);
}

/// A candidate split point: a unit that begins a heading of level ≤ 3.
class ChapterSection {
  /// 0-based line where the unit (`#let …`) starts.
  final int unitStartLine;

  /// Heading level (1 = `=`, 2 = `==`, 3 = `===`).
  final int level;

  /// Heading text (without the `=` markers).
  final String heading;

  const ChapterSection({
    required this.unitStartLine,
    required this.level,
    required this.heading,
  });
}

/// A planned multi-way split: what the original keeps plus the moved parts.
class MultiSplitPlan {
  final bool ok;
  final String? reason;

  /// Content the original file keeps (everything above the first cut).
  final String head;

  /// Moved segments in document order, each `(heading, fullFileContent)` where
  /// the content already includes the chapter header.
  final List<({String heading, String content})> parts;

  const MultiSplitPlan._({
    required this.ok,
    this.reason,
    this.head = '',
    this.parts = const [],
  });

  factory MultiSplitPlan.invalid(String reason) =>
      MultiSplitPlan._(ok: false, reason: reason);
}

/// Result of writing a split to disk.
class SplitResult {
  final String newFilePath;

  /// False when `main.typ` had no `#include` for the source file (the new file
  /// was still created, but the user must add the include manually).
  final bool includeUpdated;

  const SplitResult({required this.newFilePath, required this.includeUpdated});
}

/// Splits an oversized multilingual chapter into smaller chapter files.
///
/// Works on the *paragraph-level alternation* pattern, where a chapter is a
/// sequence of independent units, each `#let para-NNN = (…)` immediately
/// rendered by `#para-NNN.at(current-lang)`, all at column 0. Because the units
/// share no state, any unit boundary is a valid cut. Cuts snap to a unit that
/// begins a heading of level ≤ 3 so a new chapter always starts at a (sub)section.
class ChapterSplitService {
  static final RegExp _unitStart = RegExp(r'^#let\s');
  static final RegExp _heading = RegExp(r'^\s*(=+)\s+\S');

  /// Plan a split of [text] at [caretOffset] (0-based char offset).
  SplitPlan computeSplit(String text, int caretOffset) {
    final lines = text.split('\n');

    // Offsets of each line start, for offset↔line mapping.
    final lineStart = List<int>.filled(lines.length, 0);
    var acc = 0;
    for (var i = 0; i < lines.length; i++) {
      lineStart[i] = acc;
      acc += lines[i].length + 1; // +1 for the '\n'
    }

    final caret = caretOffset.clamp(0, text.length);
    var caretLine = 0;
    for (var i = 0; i < lines.length; i++) {
      if (lineStart[i] <= caret) {
        caretLine = i;
      } else {
        break;
      }
    }

    // Unit starts (top-level `#let` at column 0).
    final units = <int>[];
    for (var i = 0; i < lines.length; i++) {
      if (_unitStart.hasMatch(lines[i])) units.add(i);
    }
    if (units.length < 2) {
      return SplitPlan.invalid(
        'This chapter has a single content block and cannot be split here.',
      );
    }
    final headerEndLine = units.first;

    // Section-boundary candidate units: those whose first heading is level ≤ 3.
    bool isSectionStart(int unitIndex) {
      final from = units[unitIndex];
      final to = unitIndex + 1 < units.length
          ? units[unitIndex + 1]
          : lines.length;
      for (var i = from; i < to; i++) {
        final m = _heading.firstMatch(lines[i]);
        if (m != null) return m.group(1)!.length <= 3;
      }
      return false;
    }

    // The unit the caret sits in (greatest unit start ≤ caretLine).
    var caretUnit = -1;
    for (var u = 0; u < units.length; u++) {
      if (units[u] <= caretLine) {
        caretUnit = u;
      } else {
        break;
      }
    }
    if (caretUnit < 0) {
      return SplitPlan.invalid(
        'Place the caret inside a section below the chapter header.',
      );
    }

    // Snap to the nearest section-start unit at or above the caret's unit.
    var cutUnit = -1;
    for (var u = caretUnit; u >= 0; u--) {
      if (isSectionStart(u)) {
        cutUnit = u;
        break;
      }
    }
    if (cutUnit < 0) {
      return SplitPlan.invalid(
        'No section heading (=, == or ===) found at or above the caret.',
      );
    }
    if (cutUnit == 0) {
      return SplitPlan.invalid(
        'The caret is in the first section — nothing would remain above it.',
      );
    }

    // Extend the cut upward over the unit's leading blank / comment lines so
    // they travel with the moved section.
    var cutLine = units[cutUnit];
    while (cutLine - 1 > headerEndLine) {
      final prev = lines[cutLine - 1];
      final t = prev.trim();
      if (t.isEmpty || t.startsWith('//')) {
        cutLine--;
      } else {
        break;
      }
    }

    final headerEndOffset = lineStart[headerEndLine];
    final cutOffset = lineStart[cutLine];
    final header = text.substring(0, headerEndOffset);
    final head = text.substring(0, cutOffset);
    final tail = text.substring(cutOffset);

    // Heading text at the cut, for a filename suggestion.
    var cutHeading = '';
    final from = units[cutUnit];
    final to = cutUnit + 1 < units.length ? units[cutUnit + 1] : lines.length;
    for (var i = from; i < to; i++) {
      final m = _heading.firstMatch(lines[i]);
      if (m != null) {
        cutHeading = lines[i].substring(m.end - 1).trim();
        break;
      }
    }

    return SplitPlan._(
      ok: true,
      head: head,
      tail: tail,
      header: header,
      newFileContent: header + tail,
      cutHeading: cutHeading,
    );
  }

  /// Insert a `#include "<newIncludeRel>"` line immediately after the line that
  /// includes [currentIncludeRel]. Returns the rewritten source and whether the
  /// current include was found.
  (String, bool) insertInclude(
    String mainSrc,
    String currentIncludeRel,
    String newIncludeRel,
  ) {
    final lines = mainSrc.split('\n');
    final target = '#include "$currentIncludeRel"';
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].trim() == target) {
        final indent = lines[i].substring(0, lines[i].indexOf('#'));
        lines.insert(i + 1, '$indent#include "$newIncludeRel"');
        return (lines.join('\n'), true);
      }
    }
    return (mainSrc, false);
  }

  /// Write the planned split to disk: create the new chapter file, overwrite the
  /// original with [plan].head, and add the new `#include` to `main.typ`.
  ///
  /// Throws [ArgumentError] for an invalid [newFileName] or an existing target.
  Future<SplitResult> applySplit({
    required String projectPath,
    required String currentFilePath,
    required String newFileName,
    required SplitPlan plan,
  }) async {
    if (!plan.ok) {
      throw ArgumentError(plan.reason ?? 'Cannot split here.');
    }
    final name = newFileName.trim();
    if (name.isEmpty || !name.endsWith('.typ')) {
      throw ArgumentError('Filename must end with ".typ".');
    }
    if (name.contains('/') || name.contains('\\') || name.contains('..')) {
      throw ArgumentError('Filename must not contain path separators.');
    }

    final dir = path.dirname(currentFilePath);
    final newPath = path.join(dir, name);
    if (await File(newPath).exists()) {
      throw ArgumentError('A file named "$name" already exists.');
    }

    await File(newPath).writeAsString(plan.newFileContent);
    await File(currentFilePath).writeAsString(plan.head);

    var includeUpdated = false;
    final mainPath = path.join(projectPath, 'main.typ');
    final mainFile = File(mainPath);
    if (await mainFile.exists()) {
      final currentRel = _posix(
        path.relative(currentFilePath, from: projectPath),
      );
      final newRel = _posix(path.relative(newPath, from: projectPath));
      final (rewritten, found) = insertInclude(
        await mainFile.readAsString(),
        currentRel,
        newRel,
      );
      if (found) {
        await mainFile.writeAsString(rewritten);
        includeUpdated = true;
      }
    }

    return SplitResult(newFilePath: newPath, includeUpdated: includeUpdated);
  }

  static String _posix(String p) => p.replaceAll('\\', '/');

  // ---- Multi-way split (used by the project-tree "Split by section" tool) ----

  /// List the section-start units (heading level ≤ 3) in [text]. The first one
  /// is the chapter's own start (it stays in the original); the rest are
  /// selectable boundaries where a new file can begin. Returns an empty list
  /// when the chapter is a single content block (not splittable).
  List<ChapterSection> listSections(String text) {
    final lines = text.split('\n');
    final units = <int>[];
    for (var i = 0; i < lines.length; i++) {
      if (_unitStart.hasMatch(lines[i])) units.add(i);
    }
    if (units.length < 2) return const [];

    final sections = <ChapterSection>[];
    for (var u = 0; u < units.length; u++) {
      final from = units[u];
      final to = u + 1 < units.length ? units[u + 1] : lines.length;
      for (var i = from; i < to; i++) {
        final m = _heading.firstMatch(lines[i]);
        if (m != null) {
          final level = m.group(1)!.length;
          if (level <= 3) {
            sections.add(
              ChapterSection(
                unitStartLine: from,
                level: level,
                heading: lines[i].substring(m.end - 1).trim(),
              ),
            );
          }
          break; // only the unit's first heading matters
        }
      }
    }
    return sections;
  }

  /// Plan a multi-way split: [selectedUnitStartLines] are the unit-start lines
  /// (from [listSections]) that should each begin a new file. The content before
  /// the first selected boundary stays in the original.
  MultiSplitPlan computeMultiSplit(
    String text,
    Set<int> selectedUnitStartLines,
  ) {
    if (selectedUnitStartLines.isEmpty) {
      return MultiSplitPlan.invalid(
        'Select at least one section to split off.',
      );
    }
    final lines = text.split('\n');
    final lineStart = List<int>.filled(lines.length, 0);
    var acc = 0;
    for (var i = 0; i < lines.length; i++) {
      lineStart[i] = acc;
      acc += lines[i].length + 1;
    }

    final units = <int>[];
    for (var i = 0; i < lines.length; i++) {
      if (_unitStart.hasMatch(lines[i])) units.add(i);
    }
    if (units.length < 2) {
      return MultiSplitPlan.invalid('This chapter cannot be split.');
    }
    final headerEndLine = units.first;
    final header = text.substring(0, lineStart[headerEndLine]);

    final selected = selectedUnitStartLines.toList()..sort();
    if (selected.first <= headerEndLine) {
      return MultiSplitPlan.invalid(
        'The first section must stay in the original file.',
      );
    }

    // Back each boundary up over its leading blank / comment lines.
    int cutLineFor(int unitLine) {
      var c = unitLine;
      while (c - 1 > headerEndLine) {
        final t = lines[c - 1].trim();
        if (t.isEmpty || t.startsWith('//')) {
          c--;
        } else {
          break;
        }
      }
      return c;
    }

    final cuts = selected.map(cutLineFor).toList();
    final head = text.substring(0, lineStart[cuts.first]);

    String headingAt(int unitLine) {
      final idx = units.indexOf(unitLine);
      final to = idx + 1 < units.length ? units[idx + 1] : lines.length;
      for (var i = unitLine; i < to; i++) {
        final m = _heading.firstMatch(lines[i]);
        if (m != null) return lines[i].substring(m.end - 1).trim();
      }
      return '';
    }

    final parts = <({String heading, String content})>[];
    for (var k = 0; k < selected.length; k++) {
      final startOffset = lineStart[cuts[k]];
      final endOffset = k + 1 < selected.length
          ? lineStart[cuts[k + 1]]
          : text.length;
      final segment = text.substring(startOffset, endOffset);
      parts.add((heading: headingAt(selected[k]), content: header + segment));
    }

    return MultiSplitPlan._(ok: true, head: head, parts: parts);
  }

  /// Insert `#include`s for [newRels] (in order) right after the line including
  /// [currentIncludeRel]. Returns the rewritten source and whether it was found.
  (String, bool) insertIncludes(
    String mainSrc,
    String currentIncludeRel,
    List<String> newRels,
  ) {
    final lines = mainSrc.split('\n');
    final target = '#include "$currentIncludeRel"';
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].trim() == target) {
        final indent = lines[i].substring(0, lines[i].indexOf('#'));
        lines.insertAll(i + 1, [
          for (final r in newRels) '$indent#include "$r"',
        ]);
        return (lines.join('\n'), true);
      }
    }
    return (mainSrc, false);
  }

  /// Write a multi-way split to disk: overwrite the original with [plan].head,
  /// create each `(fileName, content)` in [files], and add their includes to
  /// `main.typ`. [files] must align 1:1 with `plan.parts`.
  ///
  /// Throws [ArgumentError] on invalid/duplicate/existing filenames.
  Future<SplitResult> applyMultiSplit({
    required String projectPath,
    required String currentFilePath,
    required List<({String fileName, String content})> files,
    required MultiSplitPlan plan,
  }) async {
    if (!plan.ok) throw ArgumentError(plan.reason ?? 'Cannot split.');
    final dir = path.dirname(currentFilePath);
    final seen = <String>{};
    for (final f in files) {
      final name = f.fileName.trim();
      if (name.isEmpty || !name.endsWith('.typ')) {
        throw ArgumentError('Filename "$name" must end with ".typ".');
      }
      if (name.contains('/') || name.contains('\\') || name.contains('..')) {
        throw ArgumentError(
          'Filename "$name" must not contain path separators.',
        );
      }
      if (!seen.add(name)) {
        throw ArgumentError('Duplicate filename "$name".');
      }
      if (await File(path.join(dir, name)).exists()) {
        throw ArgumentError('A file named "$name" already exists.');
      }
    }

    for (final f in files) {
      await File(path.join(dir, f.fileName)).writeAsString(f.content);
    }
    await File(currentFilePath).writeAsString(plan.head);

    var includeUpdated = false;
    final mainFile = File(path.join(projectPath, 'main.typ'));
    if (await mainFile.exists()) {
      final currentRel = _posix(
        path.relative(currentFilePath, from: projectPath),
      );
      final newRels = [
        for (final f in files)
          _posix(path.relative(path.join(dir, f.fileName), from: projectPath)),
      ];
      final (rewritten, found) = insertIncludes(
        await mainFile.readAsString(),
        currentRel,
        newRels,
      );
      if (found) {
        await mainFile.writeAsString(rewritten);
        includeUpdated = true;
      }
    }

    return SplitResult(
      newFilePath: path.join(dir, files.first.fileName),
      includeUpdated: includeUpdated,
    );
  }
}

/// Build a filesystem-friendly slug for a suggested filename, e.g.
/// `APOLLO III bus ("COM")` → `apollo-iii-bus-com`.
String chapterSlug(String heading) {
  final slug = heading
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return slug.isEmpty ? 'part' : slug;
}
