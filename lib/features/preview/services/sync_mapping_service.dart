import '../../typst/models/sync_anchor.dart';

/// Where in the PDF a source position maps to (1-based [page] + vertical [y]
/// offset in points from the page top).
class SyncTarget {
  final int page;
  final double y;
  const SyncTarget({required this.page, required this.y});
}

/// A resolved source position (file + 1-based line) for a PDF location.
class SyncSourceLocation {
  final String filePath;
  final int line;
  const SyncSourceLocation({required this.filePath, required this.line});
}

/// Immutable global anchor map over every chapter's injected anchors.
///
/// Built from [SyncAnchor]s queried from the compiled PDF (see
/// [SyncAnchorInjector] / [TypstCompiler.queryAnchorPositions]). Lookups use a
/// floor strategy — "the paragraph the caret is in" for forward, "the source
/// position at or just above the viewport" for inverse — which is robust and
/// naturally resolves the correct file across chapter boundaries.
class SyncMap {
  /// All anchors, ordered by document position (page then y).
  final List<SyncAnchor> _byDoc;

  const SyncMap._(this._byDoc);

  factory SyncMap.empty() => const SyncMap._([]);

  /// Build from [anchors] (any order). Filters out malformed entries.
  factory SyncMap(List<SyncAnchor> anchors) {
    final list = anchors
        .where((a) => a.line > 0 && a.page > 0)
        .toList()
      ..sort((a, b) => a.page != b.page ? a.page - b.page : a.y.compareTo(b.y));
    return SyncMap._(list);
  }

  bool get isEmpty => _byDoc.isEmpty;
  int get anchorCount => _byDoc.length;

  /// Forward (editor → PDF): the render target for the paragraph containing
  /// 1-based [line] in [filePath]. Returns null if the file has no anchors.
  SyncTarget? forward(String filePath, int line) {
    SyncAnchor? best;
    for (final a in _byDoc) {
      if (a.filePath != filePath) continue;
      if (a.line <= line) {
        if (best == null || a.line > best.line) best = a;
      }
      best ??= a; // fall back to the file's first anchor if line precedes it
    }
    if (best == null) return null;
    return SyncTarget(page: best.page, y: best.y);
  }

  /// Inverse (PDF → editor): the source location at or just above PDF
  /// ([page], [y]). [y] is in points from the page top; pass 0 for "top of
  /// page". Returns null when there are no anchors.
  SyncSourceLocation? inverse(int page, double y) {
    if (_byDoc.isEmpty) return null;
    SyncAnchor? best;
    for (final a in _byDoc) {
      final atOrAbove = a.page < page || (a.page == page && a.y <= y);
      if (atOrAbove) {
        best = a; // _byDoc is sorted, so the last match is the closest above
      } else {
        break;
      }
    }
    best ??= _byDoc.first; // location precedes the first anchor
    return SyncSourceLocation(filePath: best.filePath, line: best.line);
  }
}
