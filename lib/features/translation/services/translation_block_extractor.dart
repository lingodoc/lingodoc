/// A single multilingual block extracted from a `.typ` source file.
///
/// Mirrors the on-disk pattern
/// `#let <blockId> = (en: [...], es: [...], …)` — [values] holds the
/// normalized raw text of each configured language present in the block.
class TranslationBlock {
  /// The `#let` variable name (e.g. `para-007`, `lang-content`). Used as the
  /// stable per-block identity key across saves.
  final String blockId;

  /// 0-based line index of the `#let …` opener (for gutter mapping).
  final int startLine;

  /// langCode → normalized value text. Only languages actually present in the
  /// block appear here.
  final Map<String, String> values;

  const TranslationBlock({
    required this.blockId,
    required this.startLine,
    required this.values,
  });
}

/// The line span of one language value within a block. [startLine] is the
/// 0-based index of the `<code>: [` opener line; [endLine] is exclusive (the
/// index just past the value's closing `]` line). A source line `L` belongs to
/// this language when `startLine <= L < endLine`.
class TranslationLangSpan {
  final String blockId;
  final String lang;
  final int startLine;
  final int endLine;

  const TranslationLangSpan({
    required this.blockId,
    required this.lang,
    required this.startLine,
    required this.endLine,
  });
}

/// Parses LingoDoc multilingual `.typ` source into per-block, per-language
/// values for translation-staleness tracking.
///
/// Reuses the same scanning approach proven in `ChapterSplitService`
/// (`#let` unit starts) and `SyncAnchorInjector` (bracket-depth walk over
/// `[ … ]` content and `<code>: [` language openers), so nested brackets and
/// multiline values are handled and inner text is never mistaken for an opener.
class TranslationBlockExtractor {
  const TranslationBlockExtractor();

  static final RegExp _unitStart = RegExp(r'^#let\s');

  /// `#let <name> = (` — a dict-literal block. Plain `#let x = [...]` or
  /// function definitions do not match and are skipped.
  static final RegExp _dictUnit =
      RegExp(r'^#let\s+([A-Za-z0-9_\-]+)\s*=\s*\(');

  /// Extract every translation block from [fileText]. Only languages in
  /// [languageCodes] are considered; a block with none of them is skipped.
  List<TranslationBlock> extract(String fileText, List<String> languageCodes) {
    final scanned = _scan(fileText, languageCodes);
    if (scanned.isEmpty) return const [];

    // Group hits by block, preserving first-occurrence-wins per language.
    final byBlock = <String, ({int startLine, Map<String, String> values})>{};
    for (final hit in scanned) {
      final entry = byBlock.putIfAbsent(
        hit.blockId,
        () => (startLine: hit.blockStart, values: <String, String>{}),
      );
      entry.values.putIfAbsent(hit.lang, () => _normalize(hit.value));
    }

    final blocks = <TranslationBlock>[];
    for (final e in byBlock.entries) {
      if (e.value.values.isNotEmpty) {
        blocks.add(TranslationBlock(
          blockId: e.key,
          startLine: e.value.startLine,
          values: e.value.values,
        ));
      }
    }
    return blocks;
  }

  /// Extract the per-language line span of every language value, so callers
  /// (e.g. the TODO scanner) can map an arbitrary source line back to the
  /// `(blockId, lang)` it sits inside. Shares the same bracket-depth scan as
  /// [extract].
  List<TranslationLangSpan> extractSpans(
      String fileText, List<String> languageCodes) {
    return _scan(fileText, languageCodes)
        .map((h) => TranslationLangSpan(
              blockId: h.blockId,
              lang: h.lang,
              startLine: h.startLine,
              endLine: h.endLine,
            ))
        .toList();
  }

  /// Single source of truth for the `#let name = (… <code>: [ … ] …)` scan.
  /// Returns one record per language value found, with its raw text and line
  /// span. Inner value text can never be mistaken for another opener because
  /// each value body is skipped after extraction.
  List<
      ({
        String blockId,
        int blockStart,
        String lang,
        String value,
        int startLine,
        int endLine,
      })> _scan(String fileText, List<String> languageCodes) {
    if (languageCodes.isEmpty) return const [];
    final lines = fileText.split('\n');

    // All top-level `#let` unit starts, like ChapterSplitService.
    final unitLines = <int>[];
    for (var i = 0; i < lines.length; i++) {
      if (_unitStart.hasMatch(lines[i])) unitLines.add(i);
    }
    if (unitLines.isEmpty) return const [];

    final codeAlt = languageCodes.map(RegExp.escape).join('|');
    final anyOpener = RegExp('(^|[\\s(,])($codeAlt)\\s*:\\s*\\[');

    final hits = <({
      String blockId,
      int blockStart,
      String lang,
      String value,
      int startLine,
      int endLine,
    })>[];
    for (var u = 0; u < unitLines.length; u++) {
      final start = unitLines[u];
      final end = u + 1 < unitLines.length ? unitLines[u + 1] : lines.length;

      final m = _dictUnit.firstMatch(lines[start]);
      if (m == null) continue; // not a `#let name = (` dict block
      final blockId = m.group(1)!;

      var j = start;
      while (j < end) {
        final mm = anyOpener.firstMatch(lines[j]);
        if (mm == null) {
          j++;
          continue;
        }
        final code = mm.group(2)!;
        final colonIdx = lines[j].indexOf(':', mm.start);
        final extracted = _extractValue(lines, j, colonIdx, end);
        if (extracted == null) {
          j++;
          continue;
        }
        hits.add((
          blockId: blockId,
          blockStart: start,
          lang: code,
          value: extracted.text,
          startLine: j,
          endLine: extracted.endLine,
        ));
        j = extracted.endLine > j ? extracted.endLine : j + 1;
      }
    }
    return hits;
  }

  /// Walk the `[ … ]` value beginning at/after [colonIdx] on line [openerLine],
  /// tracking bracket depth so nested brackets and multiline values are
  /// captured. Returns the inner text (between the outer brackets, exclusive)
  /// and the index just past the closing line, or null if unbalanced.
  ({String text, int endLine})? _extractValue(
    List<String> lines,
    int openerLine,
    int colonIdx,
    int limit,
  ) {
    var depth = 0;
    var started = false;
    final buf = StringBuffer();
    for (var j = openerLine; j < limit && j < lines.length; j++) {
      final line = lines[j];
      final from = (j == openerLine && colonIdx >= 0) ? colonIdx : 0;
      for (var k = from; k < line.length; k++) {
        final ch = line[k];
        if (ch == '[') {
          if (started) buf.write(ch);
          depth++;
          started = true;
        } else if (ch == ']') {
          depth--;
          if (started && depth == 0) {
            return (text: buf.toString(), endLine: j + 1);
          }
          if (started) buf.write(ch);
        } else if (started) {
          buf.write(ch);
        }
      }
      if (started) buf.write('\n');
    }
    return null;
  }

  /// Conservative normalization: normalize line endings, strip trailing
  /// whitespace per line, and trim the ends. Intentionally does not collapse
  /// internal spaces (Typst is whitespace-sensitive), so cosmetic reflow
  /// without semantic change still avoids false "stale" flags while real edits
  /// are detected.
  String _normalize(String raw) {
    final lines = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');
    final trimmed = lines.map((l) => l.replaceAll(RegExp(r'\s+$'), '')).join('\n');
    return trimmed.trim();
  }
}
