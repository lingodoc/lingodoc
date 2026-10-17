import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/translation_state.dart';
import 'translation_block_extractor.dart';

/// SHA-256 of a normalized language value, hex-encoded.
String hashValue(String normalized) =>
    sha256.convert(utf8.encode(normalized)).toString();

/// Reconcile a file's freshly-extracted [blocks] against its [prior] state,
/// returning the new file state. Pure and deterministic given [nowIso]
/// (injected so tests can control the token).
///
/// Symmetric "last edited wins" model: editing any existing language mints a
/// new block token and makes that language fresh; unedited siblings keep their
/// old token and so become stale. Adding/removing a translation (with no edit
/// to an existing one) does not restale siblings.
TranslationFileState reconcileFile({
  required TranslationFileState? prior,
  required List<TranslationBlock> blocks,
  required String nowIso,
}) {
  final priorBlocks = prior?.blocks ?? const <String, TranslationBlockState>{};
  final newBlocks = <String, TranslationBlockState>{};

  for (final block in blocks) {
    final hashes = <String, String>{
      for (final e in block.values.entries) e.key: hashValue(e.value),
    };
    final prev = priorBlocks[block.blockId];

    if (prev == null) {
      // New block: baseline everything in-sync under one shared token.
      newBlocks[block.blockId] = TranslationBlockState(
        latestToken: nowIso,
        langs: {
          for (final e in hashes.entries)
            e.key: TranslationLangState(hash: e.value, token: nowIso),
        },
      );
      continue;
    }

    // Classify languages relative to the stored state.
    final edited = <String>{}; // existed before AND content changed
    final added = <String>{}; // not present before
    for (final code in hashes.keys) {
      final pl = prev.langs[code];
      if (pl == null) {
        added.add(code);
      } else if (pl.hash != hashes[code]) {
        edited.add(code);
      }
    }

    if (edited.isEmpty) {
      // Only additions/removals (or no change at all): keep the reference
      // token; siblings stay as-is. Added langs adopt the current reference so
      // they read as in-sync rather than instantly stale.
      newBlocks[block.blockId] = TranslationBlockState(
        latestToken: prev.latestToken,
        langs: {
          for (final code in hashes.keys)
            code: TranslationLangState(
              hash: hashes[code]!,
              token: prev.langs[code]?.token ?? prev.latestToken,
            ),
        },
      );
    } else {
      // A real edit happened: mint a new token. Edited (and newly-added) langs
      // are fresh; untouched siblings keep their old token → become stale.
      newBlocks[block.blockId] = TranslationBlockState(
        latestToken: nowIso,
        langs: {
          for (final code in hashes.keys)
            code: TranslationLangState(
              hash: hashes[code]!,
              token: (edited.contains(code) || added.contains(code))
                  ? nowIso
                  : prev.langs[code]!.token,
            ),
        },
      );
    }
  }

  // Blocks absent from the new scan are dropped (deleted from the file).
  return TranslationFileState(blocks: newBlocks);
}

/// True when [lang] in [block] is out of date with its freshest sibling.
bool isLangStale(TranslationBlockState block, String lang) {
  final l = block.langs[lang];
  if (l == null) return false;
  return l.token != block.latestToken;
}

/// langCode → number of stale blocks in [file].
Map<String, int> staleCountsByLang(TranslationFileState? file) {
  final counts = <String, int>{};
  if (file == null) return counts;
  for (final block in file.blocks.values) {
    for (final entry in block.langs.entries) {
      if (entry.value.token != block.latestToken) {
        counts[entry.key] = (counts[entry.key] ?? 0) + 1;
      }
    }
  }
  return counts;
}

/// All stale `(blockId, lang)` pairs in [file], in a stable sorted order.
List<({String blockId, String lang})> staleBlocksForFile(
  TranslationFileState? file,
) {
  final out = <({String blockId, String lang})>[];
  if (file == null) return out;
  final ids = file.blocks.keys.toList()..sort();
  for (final id in ids) {
    final block = file.blocks[id]!;
    final langs =
        block.langs.keys
            .where((l) => block.langs[l]!.token != block.latestToken)
            .toList()
          ..sort();
    for (final l in langs) {
      out.add((blockId: id, lang: l));
    }
  }
  return out;
}

/// Total count of stale `(block, lang)` pairs in [file].
int totalStaleForFile(TranslationFileState? file) =>
    staleBlocksForFile(file).length;

/// Reconcile a single translation: reset its token to the block's reference so
/// it is no longer stale, without changing content.
TranslationFileState markReviewed(
  TranslationFileState file,
  String blockId,
  String lang,
) {
  final block = file.blocks[blockId];
  if (block == null) return file;
  final l = block.langs[lang];
  if (l == null) return file;
  final newLangs = Map<String, TranslationLangState>.from(block.langs)
    ..[lang] = l.copyWith(token: block.latestToken);
  final newBlocks = Map<String, TranslationBlockState>.from(file.blocks)
    ..[blockId] = block.copyWith(langs: newLangs);
  return file.copyWith(blocks: newBlocks);
}

/// Reconcile every translation in [file] (used after a bulk human review pass).
TranslationFileState markAllReviewed(TranslationFileState file) {
  final newBlocks = <String, TranslationBlockState>{};
  for (final entry in file.blocks.entries) {
    final block = entry.value;
    newBlocks[entry.key] = block.copyWith(
      langs: {
        for (final l in block.langs.entries)
          l.key: l.value.copyWith(token: block.latestToken),
      },
    );
  }
  return file.copyWith(blocks: newBlocks);
}
