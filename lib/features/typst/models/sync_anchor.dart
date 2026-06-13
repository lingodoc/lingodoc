/// A single editor↔PDF synchronization anchor: a known source position
/// (`filePath` + 1-based `line`) and the exact place it renders to in the
/// compiled PDF (`page` + vertical `y` offset in points from the page top).
///
/// Produced by [TypstCompiler.queryAnchorPositions]: at compile time a
/// line-tagged `#metadata` marker is injected before each paragraph/heading,
/// and `typst query` reads back its resolved layout position. This is far more
/// robust than correlating heading *text* and is dense enough for
/// paragraph-level precision.
class SyncAnchor {
  /// Absolute path of the source chapter file this anchor came from.
  final String filePath;

  /// 1-based source line of the tagged content.
  final int line;

  /// 1-based PDF page the content renders on.
  final int page;

  /// Vertical offset on the page, in points, measured from the page top.
  final double y;

  const SyncAnchor({
    required this.filePath,
    required this.line,
    required this.page,
    required this.y,
  });

  @override
  String toString() =>
      'SyncAnchor(${filePath.split('/').last}:$line → p$page y${y.toStringAsFixed(1)})';
}
