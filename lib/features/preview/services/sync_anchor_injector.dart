/// Injects line-tagged `#metadata` markers into chapter source so the compiled
/// PDF can be queried for the exact render position of each paragraph/heading.
///
/// For each block-level paragraph start and heading **inside the active
/// language's content blocks**, a marker line
/// `#metadata((c: <chapterIndex>, l: <line>))<ld-sync>` is inserted just before
/// it. `typst query(<ld-sync>)` then returns every marker's `(page, y)` plus the
/// encoded `(chapterIndex, line)`, giving dense source↔PDF anchors.
///
/// Fail-safe by design: when in doubt it inserts *fewer* markers. It never
/// inserts inside nested constructs (`#figure[...]`, arrays) or raw code
/// fences, so it cannot turn valid markup into a broken compile.
class SyncAnchorInjector {
  /// Label attached to every injected marker.
  static const String label = 'ld-sync';

  static final RegExp _headingRe = RegExp(r'^\s*=+\s+\S');

  /// Transform [sourceText] by inserting markers. [chapterIndex] identifies the
  /// originating file so probe results can be mapped back to it. Returns the
  /// original text unchanged when no safe insertion points are found.
  String inject({
    required String sourceText,
    required String languageCode,
    required int chapterIndex,
  }) {
    final lines = sourceText.split('\n');
    final markerBefore = <int>{};

    final openers = _languageBlockOpeners(lines, languageCode);
    if (openers.isEmpty) {
      // Plain .typ file (no language blocks): scan the whole file at top level.
      _scanRange(lines, 0, 0, lines.length, markerBefore, topLevel: true);
    } else {
      for (final (openerIdx, colonIdx) in openers) {
        _scanBlock(lines, openerIdx, colonIdx, markerBefore);
      }
    }

    if (markerBefore.isEmpty) return sourceText;

    final out = StringBuffer();
    for (var i = 0; i < lines.length; i++) {
      if (markerBefore.contains(i)) {
        out.write('#metadata((c: $chapterIndex, l: ${i + 1}))<$label>\n');
      }
      out.write(lines[i]);
      if (i < lines.length - 1) out.write('\n');
    }
    return out.toString();
  }

  /// Find the `(lineIndex, colonIndex)` of every `<code>: [` opener, skipping
  /// over the body of each block so nested openers aren't matched twice.
  List<(int, int)> _languageBlockOpeners(List<String> lines, String code) {
    if (code.isEmpty) return const [];
    final opener = RegExp('(^|[\\s(,])${RegExp.escape(code)}\\s*:\\s*\\[');
    final result = <(int, int)>[];
    var i = 0;
    while (i < lines.length) {
      if (!opener.hasMatch(lines[i])) {
        i++;
        continue;
      }
      final colonIdx = lines[i].indexOf(':');
      result.add((i, colonIdx));
      // Skip to the end of this block so we don't match openers inside it.
      i = _blockEndExclusive(lines, i, colonIdx);
    }
    return result;
  }

  /// Index just past the line where the block opened at [openerIdx] closes.
  int _blockEndExclusive(List<String> lines, int openerIdx, int colonIdx) {
    var depth = 0;
    var started = false;
    for (var j = openerIdx; j < lines.length; j++) {
      final from = (j == openerIdx && colonIdx >= 0) ? colonIdx : 0;
      final line = lines[j];
      for (var k = from; k < line.length; k++) {
        final ch = line[k];
        if (ch == '[') {
          depth++;
          started = true;
        } else if (ch == ']') {
          depth--;
          if (started && depth == 0) return j + 1;
        }
      }
    }
    return lines.length;
  }

  /// Mark paragraph/heading starts inside the content block opened at
  /// [openerIdx]. Only lines at the block's top content depth (1) qualify.
  void _scanBlock(
    List<String> lines,
    int openerIdx,
    int colonIdx,
    Set<int> markerBefore,
  ) {
    final end = _blockEndExclusive(lines, openerIdx, colonIdx);
    _scanRange(lines, openerIdx, colonIdx, end, markerBefore, topLevel: false);
  }

  /// Walk [start, end) tracking bracket depth and raw-fence state, recording the
  /// line indices that should receive a marker.
  ///
  /// [topLevel] true means a plain file: prose sits at depth 0. Otherwise the
  /// content is inside a `[ ... ]` block, so prose sits at depth 1.
  void _scanRange(
    List<String> lines,
    int openerIdx,
    int colonIdx,
    int end,
    Set<int> markerBefore, {
    required bool topLevel,
  }) {
    final contentDepth = topLevel ? 0 : 1;
    var depth = 0;
    var started = topLevel; // plain files start "open"
    var inRaw = false;
    var prevBlank = true; // first content line qualifies as a paragraph start

    for (var j = openerIdx; j < end; j++) {
      final line = lines[j];
      final startDepth = depth;
      final trimmed = line.trim();
      final isFence = line.trimLeft().startsWith('```');
      // In block mode the opener line (`<lang>: [`) is structural: never mark it
      // and don't let it reset paragraph state, so the block's first content
      // line still counts as a paragraph start. In a plain file the first line
      // is real content.
      final isStructuralOpener = !topLevel && j == openerIdx;
      // A line that opens with a closing bracket/paren closes a construct (e.g.
      // the block's own `],`); it is structure, not a paragraph.
      final isCloser =
          trimmed.startsWith(']') ||
          trimmed.startsWith(')') ||
          trimmed.startsWith('}');
      final canMarkHere =
          !isStructuralOpener &&
          !isCloser &&
          started &&
          !inRaw &&
          !isFence &&
          startDepth == contentDepth;

      if (!isStructuralOpener) {
        if (trimmed.isEmpty && !inRaw && startDepth <= contentDepth) {
          prevBlank = true;
        } else if (canMarkHere) {
          if (_headingRe.hasMatch(line) || prevBlank) markerBefore.add(j);
          prevBlank = false;
        } else if (!inRaw) {
          prevBlank = false;
        }
      }

      if (isFence) inRaw = !inRaw;

      // Update bracket depth (raw-block interiors don't count).
      if (!inRaw || isFence) {
        final from = (j == openerIdx && colonIdx >= 0) ? colonIdx : 0;
        for (var k = from; k < line.length; k++) {
          final ch = line[k];
          if (ch == '[') {
            depth++;
            started = true;
          } else if (ch == ']') {
            depth--;
            if (!topLevel && started && depth == 0) return;
          }
        }
      }
    }
  }
}
