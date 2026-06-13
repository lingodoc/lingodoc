import 'package:flutter_test/flutter_test.dart';
import 'package:lingodoc/features/preview/services/sync_mapping_service.dart';
import 'package:lingodoc/features/typst/models/sync_anchor.dart';

void main() {
  const a = '/proj/chapters/a.typ';
  const b = '/proj/chapters/b.typ';

  // Two chapters. A spans pages 1–2, B spans pages 2–3, in document order.
  final anchors = <SyncAnchor>[
    const SyncAnchor(filePath: a, line: 1, page: 1, y: 100),
    const SyncAnchor(filePath: a, line: 5, page: 1, y: 300),
    const SyncAnchor(filePath: a, line: 9, page: 2, y: 100),
    const SyncAnchor(filePath: b, line: 1, page: 2, y: 400),
    const SyncAnchor(filePath: b, line: 4, page: 3, y: 100),
  ];

  group('forward (editor → PDF)', () {
    final map = SyncMap(anchors);

    test('floors to the anchor of the paragraph containing the caret', () {
      expect(map.forward(a, 1)!.page, 1);
      expect(map.forward(a, 1)!.y, 100);
      expect(map.forward(a, 3)!.y, 100); // between l1 and l5 → l1
      expect(map.forward(a, 7)!.y, 300); // between l5 and l9 → l5
      expect(map.forward(a, 100)!.page, 2); // past last → l9
    });

    test('caret before the first anchor falls back to it', () {
      expect(map.forward(a, 0)!.y, 100);
    });

    test('returns null for a file with no anchors', () {
      expect(map.forward('/proj/chapters/missing.typ', 3), isNull);
    });
  });

  group('inverse (PDF → editor)', () {
    final map = SyncMap(anchors);

    test('resolves the source line at or just above the page top', () {
      expect(map.inverse(1, 350)!.line, 5); // p1, below y=300
      expect(map.inverse(1, 350)!.filePath, a);
    });

    test('a late page resolves to the correct (later) chapter file', () {
      // The original fast-path bug returned a line in the open file (A) for any
      // late page. The global map must pick chapter B.
      final loc = map.inverse(3, 50);
      expect(loc!.filePath, b);
      expect(loc.line, 1); // nearest anchor at/above page-3 top
      expect(map.inverse(3, 200)!.line, 4); // within page 3
    });

    test('a location before the first anchor falls back to it', () {
      expect(map.inverse(1, 0)!.line, 1);
      expect(map.inverse(1, 0)!.filePath, a);
    });
  });

  group('empty map', () {
    test('returns null for both directions', () {
      final map = SyncMap.empty();
      expect(map.isEmpty, isTrue);
      expect(map.forward(a, 1), isNull);
      expect(map.inverse(1, 0), isNull);
    });

    test('SyncMap([]) is empty', () {
      expect(SyncMap(const []).isEmpty, isTrue);
    });
  });
}
