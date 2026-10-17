import 'package:flutter_test/flutter_test.dart';
import 'package:lingodoc/features/preview/services/sync_anchor_injector.dart';

void main() {
  final injector = SyncAnchorInjector();

  /// Extract the `l:` line numbers of all injected markers, in order.
  List<int> markerLines(String text) {
    final re = RegExp(r'#metadata\(\(c: \d+, l: (\d+)\)\)<ld-sync>');
    return re.allMatches(text).map((m) => int.parse(m.group(1)!)).toList();
  }

  test(
    'marks heading and paragraph starts inside the active language block',
    () {
      final src = [
        '#let c = (', // 1
        '  en: [', // 2 (opener)
        '    = Intro', // 3 heading → marked
        '', // 4
        '    Hello world.', // 5 paragraph → marked
        '', // 6
        '    == Sub', // 7 heading → marked
        '    More text.', // 8 follows heading, no blank → NOT marked
        '  ],', // 9 close
        '  es: [', // 10 opener (other language)
        '    = Intro ES', // 11 → NOT marked for en
        '  ],', // 12
        ')', // 13
      ].join('\n');

      final out = injector.inject(
        sourceText: src,
        languageCode: 'en',
        chapterIndex: 0,
      );

      expect(markerLines(out), [3, 5, 7]);
      expect(out.contains('l: 11'), isFalse); // es block untouched
      // Original content is preserved (markers are inserted, nothing removed).
      expect(out.contains('= Intro ES'), isTrue);
    },
  );

  test('does not insert markers inside nested brackets', () {
    final src = [
      '#let c = (', // 1
      '  en: [', // 2
      '    #figure[', // 3 paragraph start (top level) → marked
      '      Caption text.', // 4 depth 2 → NOT marked
      '    ]', // 5
      '  ],', // 6
      ')', // 7
    ].join('\n');

    final out = injector.inject(
      sourceText: src,
      languageCode: 'en',
      chapterIndex: 1,
    );

    expect(markerLines(out), [3]); // only the top-level figure line
  });

  test('falls back to whole-file scan for plain .typ (no language blocks)', () {
    final src = [
      '= Title', // 1 → marked
      '', // 2
      'Body paragraph.', // 3 → marked
      '', // 4
      '== Section', // 5 → marked
    ].join('\n');

    final out = injector.inject(
      sourceText: src,
      languageCode: 'en',
      chapterIndex: 0,
    );

    expect(markerLines(out), [1, 3, 5]);
  });

  test('returns the source unchanged when the active block has no content', () {
    const src = '#let c = (\n  en: [\n  ],\n)\n';
    final out = injector.inject(
      sourceText: src,
      languageCode: 'en',
      chapterIndex: 0,
    );
    expect(out, src);
  });
}
