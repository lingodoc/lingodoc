import 'package:freezed_annotation/freezed_annotation.dart';

part 'translation_state.freezed.dart';
part 'translation_state.g.dart';

/// Per-language reconciliation record for one translation block.
///
/// [hash] is the SHA-256 of the language value's normalized text as of the last
/// scan. [token] is the block-level token this language was last reconciled to;
/// a language is *stale* when its [token] differs from its block's
/// [TranslationBlockState.latestToken].
@freezed
sealed class TranslationLangState with _$TranslationLangState {
  const factory TranslationLangState({
    required String hash,
    required String token,
  }) = _TranslationLangState;

  factory TranslationLangState.fromJson(Map<String, dynamic> json) =>
      _$TranslationLangStateFromJson(json);
}

/// State for one translation block (`#let <id> = (en: […], …)`).
///
/// [latestToken] is the token minted at the most recent content edit to *any*
/// language of this block. The freshest language(s) carry the same token;
/// every other language is stale until reconciled (edited or marked reviewed).
@freezed
sealed class TranslationBlockState with _$TranslationBlockState {
  const factory TranslationBlockState({
    required String latestToken,
    @Default(<String, TranslationLangState>{})
    Map<String, TranslationLangState> langs,
  }) = _TranslationBlockState;

  factory TranslationBlockState.fromJson(Map<String, dynamic> json) =>
      _$TranslationBlockStateFromJson(json);
}

/// All tracked blocks for a single source file, keyed by block id.
@freezed
sealed class TranslationFileState with _$TranslationFileState {
  const factory TranslationFileState({
    @Default(<String, TranslationBlockState>{})
    Map<String, TranslationBlockState> blocks,
  }) = _TranslationFileState;

  factory TranslationFileState.fromJson(Map<String, dynamic> json) =>
      _$TranslationFileStateFromJson(json);
}

/// Root project translation state, persisted to
/// `.lingodoc/translation-state.json`. Files are keyed by project-relative
/// POSIX paths.
@freezed
sealed class TranslationProjectState with _$TranslationProjectState {
  const factory TranslationProjectState({
    @Default(1) int version,
    @Default(<String, TranslationFileState>{})
    Map<String, TranslationFileState> files,
  }) = _TranslationProjectState;

  factory TranslationProjectState.fromJson(Map<String, dynamic> json) =>
      _$TranslationProjectStateFromJson(json);
}
