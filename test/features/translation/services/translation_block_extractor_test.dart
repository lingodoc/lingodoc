import 'package:flutter_test/flutter_test.dart';
import 'package:lingodoc/features/translation/services/translation_block_extractor.dart';

void main() {
  const extractor = TranslationBlockExtractor();
  const codes = ['en', 'es', 'fr', 'nl', 'de'];

  group('TranslationBlockExtractor', () {
    test(
      'extracts multi-language paragraph blocks with ids and start lines',
      () {
        const src = '''
#import "../lang.typ": current-lang

// ===== Paragraph 1 =====
#let para-001 = (
  en: [Hello world],
  es: [Hola mundo],
  fr: [Bonjour le monde],
)
#para-001.at(current-lang)

// ===== Paragraph 2 =====
#let para-002 = (
  en: [Second],
  nl: [Tweede],
)
#para-002.at(current-lang)
''';
        final blocks = extractor.extract(src, codes);

        expect(blocks.length, 2);
        expect(blocks[0].blockId, 'para-001');
        expect(blocks[0].values.keys.toSet(), {'en', 'es', 'fr'});
        expect(blocks[0].values['en'], 'Hello world');
        expect(blocks[0].values['fr'], 'Bonjour le monde');
        // startLine is the 0-based `#let` line.
        expect(blocks[0].startLine, 3);

        expect(blocks[1].blockId, 'para-002');
        expect(blocks[1].values.keys.toSet(), {'en', 'nl'});
      },
    );

    test('handles nested brackets and multiline values', () {
      const src = '''
#let para-001 = (
  en: [
    = Title
    A #figure[image][caption] and a #link("x")[label].
    More body.
  ],
  es: [
    = Titulo
    Cuerpo.
  ],
)
#para-001.at(current-lang)
''';
      final blocks = extractor.extract(src, codes);
      expect(blocks.length, 1);
      final en = blocks.single.values['en']!;
      // Nested [..] content is preserved, outer brackets stripped.
      expect(en.contains('#figure[image][caption]'), isTrue);
      expect(en.contains('= Title'), isTrue);
      expect(en.startsWith('['), isFalse);
      expect(en.trimRight().endsWith(']'), isFalse);
    });

    test(
      'does not mistake text inside a value for another language opener',
      () {
        // The English body literally contains "es: [" — must not be parsed as a
        // Spanish opener.
        const src = '''
#let para-001 = (
  en: [Use the syntax es: [something] in code.],
  es: [Spanish text],
)
#para-001.at(current-lang)
''';
        final blocks = extractor.extract(src, codes);
        expect(blocks.single.values['es'], 'Spanish text');
        expect(blocks.single.values['en']!.contains('es: [something]'), isTrue);
      },
    );

    test(
      'ignores non-dict #let units and units with no configured languages',
      () {
        const src = '''
#let title = [Just content]
#let helper(x) = x + 1
#let other = (
  foo: [not a language],
  bar: [neither],
)
#let para-001 = (
  en: [real],
)
''';
        final blocks = extractor.extract(src, codes);
        expect(blocks.length, 1);
        expect(blocks.single.blockId, 'para-001');
      },
    );

    test('normalizes trailing whitespace and outer blank lines', () {
      const src = '''
#let para-001 = (
  en: [
    Line one
    Line two
  ],
)
''';
      final blocks = extractor.extract(src, codes);
      expect(blocks.single.values['en'], 'Line one\n    Line two');
    });

    test('returns empty for empty language list or non-translation files', () {
      const src = '#let para-001 = (\n  en: [x],\n)\n';
      expect(extractor.extract(src, const []), isEmpty);
      expect(extractor.extract('= Just a heading\nbody', codes), isEmpty);
    });
  });

  group('TranslationBlockExtractor.extractSpans', () {
    test('reports the 0-based line span enclosing each language value', () {
      const src = '''
#let para-001 = (
  en: [Hello],
  es: [
    Hola
    mundo
  ],
)
''';
      final spans = extractor.extractSpans(src, codes);
      expect(spans.length, 2);

      final en = spans.firstWhere((s) => s.lang == 'en');
      expect(en.blockId, 'para-001');
      expect(en.startLine, 1); // `  en: [Hello],`
      // A line index L is inside when startLine <= L < endLine.
      expect(2 >= en.startLine && 2 < en.endLine, isFalse); // line 2 is es

      final es = spans.firstWhere((s) => s.lang == 'es');
      expect(es.startLine, 2); // `  es: [`
      // Lines 3 (Hola) and 4 (mundo) fall within the es span.
      expect(3 >= es.startLine && 3 < es.endLine, isTrue);
      expect(4 >= es.startLine && 4 < es.endLine, isTrue);
    });
  });
}
