import 'package:flutter_test/flutter_test.dart';
import 'package:lingodoc/features/translation/models/translation_state.dart';
import 'package:lingodoc/features/translation/services/translation_block_extractor.dart';
import 'package:lingodoc/features/translation/services/translation_staleness.dart';

void main() {
  // Build one block with given language → text values.
  TranslationBlock block(String id, Map<String, String> values) =>
      TranslationBlock(blockId: id, startLine: 0, values: values);

  Set<String> staleLangs(TranslationFileState file, String blockId) {
    final b = file.blocks[blockId]!;
    return b.langs.keys.where((l) => isLangStale(b, l)).toSet();
  }

  group('reconcileFile - symmetric staleness', () {
    test('new file baselines everything in-sync', () {
      final file = reconcileFile(
        prior: null,
        blocks: [
          block('p1', {'en': 'a', 'fr': 'b', 'de': 'c'}),
        ],
        nowIso: 't0',
      );
      expect(staleLangs(file, 'p1'), isEmpty);
    });

    test('editing one language marks the others stale, that one fresh', () {
      final t0 = reconcileFile(
        prior: null,
        blocks: [
          block('p1', {'en': 'a', 'fr': 'b', 'de': 'c'}),
        ],
        nowIso: 't0',
      );

      // Edit fr only.
      final t1 = reconcileFile(
        prior: t0,
        blocks: [
          block('p1', {'en': 'a', 'fr': 'b-edited', 'de': 'c'}),
        ],
        nowIso: 't1',
      );
      expect(staleLangs(t1, 'p1'), {'en', 'de'});
      expect(isLangStale(t1.blocks['p1']!, 'fr'), isFalse);
    });

    test('editing a different language re-stales the previously fresh one', () {
      var file = reconcileFile(
        prior: null,
        blocks: [
          block('p1', {'en': 'a', 'fr': 'b', 'de': 'c'}),
        ],
        nowIso: 't0',
      );
      file = reconcileFile(
        prior: file,
        blocks: [
          block('p1', {'en': 'a', 'fr': 'b2', 'de': 'c'}),
        ],
        nowIso: 't1',
      );
      expect(staleLangs(file, 'p1'), {'en', 'de'});

      // Now edit de.
      file = reconcileFile(
        prior: file,
        blocks: [
          block('p1', {'en': 'a', 'fr': 'b2', 'de': 'c2'}),
        ],
        nowIso: 't2',
      );
      expect(staleLangs(file, 'p1'), {'en', 'fr'});
      expect(isLangStale(file.blocks['p1']!, 'de'), isFalse);
    });

    test('editing a stale translation clears its own flag', () {
      var file = reconcileFile(
        prior: null,
        blocks: [
          block('p1', {'en': 'a', 'fr': 'b'}),
        ],
        nowIso: 't0',
      );
      file = reconcileFile(
        prior: file,
        blocks: [
          block('p1', {'en': 'a2', 'fr': 'b'}),
        ],
        nowIso: 't1',
      ); // fr now stale
      expect(staleLangs(file, 'p1'), {'fr'});

      file = reconcileFile(
        prior: file,
        blocks: [
          block('p1', {'en': 'a2', 'fr': 'b2'}),
        ],
        nowIso: 't2',
      ); // fr edited → clears
      expect(isLangStale(file.blocks['p1']!, 'fr'), isFalse);
    });

    test(
      'new block among existing baselines in-sync; deleted block is pruned',
      () {
        var file = reconcileFile(
          prior: null,
          blocks: [
            block('p1', {'en': 'a', 'fr': 'b'}),
          ],
          nowIso: 't0',
        );
        // Add p2, keep p1 unchanged.
        file = reconcileFile(
          prior: file,
          blocks: [
            block('p1', {'en': 'a', 'fr': 'b'}),
            block('p2', {'en': 'x', 'fr': 'y'}),
          ],
          nowIso: 't1',
        );
        expect(staleLangs(file, 'p2'), isEmpty);

        // Remove p1.
        file = reconcileFile(
          prior: file,
          blocks: [
            block('p2', {'en': 'x', 'fr': 'y'}),
          ],
          nowIso: 't2',
        );
        expect(file.blocks.containsKey('p1'), isFalse);
      },
    );

    test('adding/removing a language does not restale siblings', () {
      var file = reconcileFile(
        prior: null,
        blocks: [
          block('p1', {'en': 'a', 'fr': 'b'}),
        ],
        nowIso: 't0',
      );
      // Add a brand-new translation; existing en/fr untouched.
      file = reconcileFile(
        prior: file,
        blocks: [
          block('p1', {'en': 'a', 'fr': 'b', 'de': 'c'}),
        ],
        nowIso: 't1',
      );
      expect(staleLangs(file, 'p1'), isEmpty);

      // Remove de again; still nothing stale.
      file = reconcileFile(
        prior: file,
        blocks: [
          block('p1', {'en': 'a', 'fr': 'b'}),
        ],
        nowIso: 't2',
      );
      expect(staleLangs(file, 'p1'), isEmpty);
    });
  });

  group('reconciliation actions', () {
    TranslationFileState staleFile() {
      final t0 = reconcileFile(
        prior: null,
        blocks: [
          block('p1', {'en': 'a', 'fr': 'b', 'de': 'c'}),
        ],
        nowIso: 't0',
      );
      return reconcileFile(
        prior: t0,
        blocks: [
          block('p1', {'en': 'a2', 'fr': 'b', 'de': 'c'}),
        ],
        nowIso: 't1',
      ); // fr + de stale
    }

    test('markReviewed clears a single translation', () {
      final file = markReviewed(staleFile(), 'p1', 'fr');
      expect(isLangStale(file.blocks['p1']!, 'fr'), isFalse);
      expect(isLangStale(file.blocks['p1']!, 'de'), isTrue);
    });

    test('markAllReviewed clears every translation', () {
      final file = markAllReviewed(staleFile());
      expect(staleLangs(file, 'p1'), isEmpty);
    });
  });

  group('selectors', () {
    test('staleBlocksForFile / staleCountsByLang / totalStaleForFile', () {
      final t0 = reconcileFile(
        prior: null,
        blocks: [
          block('p1', {'en': 'a', 'fr': 'b'}),
          block('p2', {'en': 'x', 'fr': 'y'}),
        ],
        nowIso: 't0',
      );
      // Edit en in both blocks → fr stale in both.
      final file = reconcileFile(
        prior: t0,
        blocks: [
          block('p1', {'en': 'a2', 'fr': 'b'}),
          block('p2', {'en': 'x2', 'fr': 'y'}),
        ],
        nowIso: 't1',
      );

      expect(totalStaleForFile(file), 2);
      expect(staleCountsByLang(file)['fr'], 2);
      expect(staleBlocksForFile(file), [
        (blockId: 'p1', lang: 'fr'),
        (blockId: 'p2', lang: 'fr'),
      ]);
    });
  });
}
