import 'package:flutter_test/flutter_test.dart';
import 'package:lingodoc/features/editor/services/chapter_split_service.dart';

void main() {
  final svc = ChapterSplitService();

  // Paragraph-level chapter: three independent units. First headings are
  // level 1 (unit0), level 3 (unit1), level 4 (unit2).
  const src = '''
// Chapter 5
#import "../lang.typ": current-lang

// ===== Paragraph 1 =====
#let para-001 = (
  en: [
  = Title
  == Section A
  body a
  ],
)
#para-001.at(current-lang)

// ===== Paragraph 2 =====
#let para-002 = (
  en: [
  === Sub B
  body b
  ],
)
#para-002.at(current-lang)

// ===== Paragraph 3 =====
#let para-003 = (
  en: [
  ==== Deep C
  body c
  ],
)
#para-003.at(current-lang)
''';

  group('computeSplit', () {
    test('snaps to the section unit the caret is in (=== boundary)', () {
      final plan = svc.computeSplit(src, src.indexOf('body b'));
      expect(plan.ok, isTrue);
      expect(plan.cutHeading, 'Sub B');
      // Head keeps para-001, drops para-002/003.
      expect(plan.head.contains('para-001'), isTrue);
      expect(plan.head.contains('para-002'), isFalse);
      // The moved section's leading comment travels with it.
      expect(plan.tail.trimLeft().startsWith('// ===== Paragraph 2'), isTrue);
      // New file is standalone: header import + the moved units.
      expect(plan.newFileContent.contains('#import "../lang.typ"'), isTrue);
      expect(plan.newFileContent.contains('para-002'), isTrue);
      expect(plan.newFileContent.contains('para-003'), isTrue);
    });

    test('a level-4 (====) caret snaps up to the nearest <=3 section', () {
      final plan = svc.computeSplit(src, src.indexOf('body c'));
      expect(plan.ok, isTrue);
      expect(
        plan.cutHeading,
        'Sub B',
      ); // snapped up to unit1, not the ==== unit
      expect(plan.tail.contains('para-002'), isTrue);
      expect(plan.tail.contains('para-003'), isTrue);
      expect(plan.head.contains('para-002'), isFalse);
    });

    test('rejects splitting at the first section', () {
      final plan = svc.computeSplit(src, src.indexOf('body a'));
      expect(plan.ok, isFalse);
      expect(plan.reason, contains('first section'));
    });

    test('rejects a caret in the header', () {
      final plan = svc.computeSplit(src, src.indexOf('#import'));
      expect(plan.ok, isFalse);
      expect(plan.reason, contains('caret'));
    });

    test('rejects a single-unit chapter', () {
      const single =
          '#import "../lang.typ": current-lang\n'
          '#let lang-content = (en: [= Title\nbody])\n'
          '#lang-content.at(current-lang)\n';
      final plan = svc.computeSplit(single, single.indexOf('body'));
      expect(plan.ok, isFalse);
      expect(plan.reason, contains('single content block'));
    });

    test('head + tail reconstruct the original exactly', () {
      final plan = svc.computeSplit(src, src.indexOf('body b'));
      expect(plan.head + plan.tail, src);
    });
  });

  group('insertInclude', () {
    const main =
        '#include "chapters/04-software-1.typ"\n'
        '#include "chapters/05-apollo-iii-in-detail.typ"\n';

    test('inserts the new include right after the source include', () {
      final (out, found) = svc.insertInclude(
        main,
        'chapters/05-apollo-iii-in-detail.typ',
        'chapters/05-network.typ',
      );
      expect(found, isTrue);
      expect(
        out,
        '#include "chapters/04-software-1.typ"\n'
        '#include "chapters/05-apollo-iii-in-detail.typ"\n'
        '#include "chapters/05-network.typ"\n',
      );
    });

    test('reports not-found when the source include is absent', () {
      final (out, found) = svc.insertInclude(
        main,
        'chapters/99-missing.typ',
        'chapters/x.typ',
      );
      expect(found, isFalse);
      expect(out, main);
    });
  });

  group('listSections', () {
    test('returns section-start units of level <= 3, skipping ====', () {
      final sections = svc.listSections(src);
      expect(sections.map((s) => s.heading), ['Title', 'Sub B']);
      expect(sections.map((s) => s.level), [1, 3]);
    });

    test('empty for a single-unit chapter', () {
      const single =
          '#let lang-content = (en: [= T\nx])\n'
          '#lang-content.at(current-lang)\n';
      expect(svc.listSections(single), isEmpty);
    });
  });

  group('computeMultiSplit', () {
    const srcMulti = '''
#import "../lang.typ": current-lang

// ===== Paragraph 1 =====
#let para-001 = (
  en: [
  = T
  a ],
)
#para-001.at(current-lang)

// ===== Paragraph 2 =====
#let para-002 = (
  en: [
  === A
  b ],
)
#para-002.at(current-lang)

// ===== Paragraph 3 =====
#let para-003 = (
  en: [
  === B
  c ],
)
#para-003.at(current-lang)

// ===== Paragraph 4 =====
#let para-004 = (
  en: [
  === C
  d ],
)
#para-004.at(current-lang)
''';

    test('splits into multiple parts at the selected boundaries', () {
      final sections = svc.listSections(srcMulti);
      expect(sections.map((s) => s.heading), ['T', 'A', 'B', 'C']);
      // Select A and C → original keeps T; part1 = A+B; part2 = C.
      final plan = svc.computeMultiSplit(srcMulti, {
        sections[1].unitStartLine,
        sections[3].unitStartLine,
      });
      expect(plan.ok, isTrue);
      expect(plan.parts.length, 2);
      expect(plan.parts[0].heading, 'A');
      expect(plan.parts[1].heading, 'C');
      expect(plan.head.contains('para-001'), isTrue);
      expect(plan.head.contains('para-002'), isFalse);
      // part1 spans A and B; part2 only C.
      expect(plan.parts[0].content.contains('para-002'), isTrue);
      expect(plan.parts[0].content.contains('para-003'), isTrue);
      expect(plan.parts[0].content.contains('para-004'), isFalse);
      expect(plan.parts[1].content.contains('para-004'), isTrue);
      // Each part is standalone (carries the header import).
      expect(plan.parts[0].content.contains('#import "../lang.typ"'), isTrue);
      // head + all parts' segments reconstruct the body.
      expect(plan.head + plan.parts.map((p) => p.content).join(), isNotEmpty);
    });

    test('rejects selecting the first section', () {
      final sections = svc.listSections(srcMulti);
      final plan = svc.computeMultiSplit(srcMulti, {sections[0].unitStartLine});
      expect(plan.ok, isFalse);
    });

    test('rejects an empty selection', () {
      expect(svc.computeMultiSplit(srcMulti, {}).ok, isFalse);
    });
  });

  group('insertIncludes', () {
    test('inserts multiple includes in order after the source', () {
      const main = '#include "chapters/05-detail.typ"\n';
      final (out, found) = svc.insertIncludes(main, 'chapters/05-detail.typ', [
        'chapters/05-a.typ',
        'chapters/05-b.typ',
      ]);
      expect(found, isTrue);
      expect(
        out,
        '#include "chapters/05-detail.typ"\n'
        '#include "chapters/05-a.typ"\n'
        '#include "chapters/05-b.typ"\n',
      );
    });
  });

  group('chapterSlug', () {
    test('produces a filesystem-friendly slug', () {
      expect(
        chapterSlug('APOLLO III bus ("COM" connection)'),
        'apollo-iii-bus-com-connection',
      );
      expect(chapterSlug('  '), 'part');
    });
  });
}
