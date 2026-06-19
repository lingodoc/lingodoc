// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TranslationLangState _$TranslationLangStateFromJson(
  Map<String, dynamic> json,
) => _TranslationLangState(
  hash: json['hash'] as String,
  token: json['token'] as String,
);

Map<String, dynamic> _$TranslationLangStateToJson(
  _TranslationLangState instance,
) => <String, dynamic>{'hash': instance.hash, 'token': instance.token};

_TranslationBlockState _$TranslationBlockStateFromJson(
  Map<String, dynamic> json,
) => _TranslationBlockState(
  latestToken: json['latestToken'] as String,
  langs:
      (json['langs'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          TranslationLangState.fromJson(e as Map<String, dynamic>),
        ),
      ) ??
      const <String, TranslationLangState>{},
);

Map<String, dynamic> _$TranslationBlockStateToJson(
  _TranslationBlockState instance,
) => <String, dynamic>{
  'latestToken': instance.latestToken,
  'langs': instance.langs,
};

_TranslationFileState _$TranslationFileStateFromJson(
  Map<String, dynamic> json,
) => _TranslationFileState(
  blocks:
      (json['blocks'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          TranslationBlockState.fromJson(e as Map<String, dynamic>),
        ),
      ) ??
      const <String, TranslationBlockState>{},
);

Map<String, dynamic> _$TranslationFileStateToJson(
  _TranslationFileState instance,
) => <String, dynamic>{'blocks': instance.blocks};

_TranslationProjectState _$TranslationProjectStateFromJson(
  Map<String, dynamic> json,
) => _TranslationProjectState(
  version: (json['version'] as num?)?.toInt() ?? 1,
  files:
      (json['files'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          TranslationFileState.fromJson(e as Map<String, dynamic>),
        ),
      ) ??
      const <String, TranslationFileState>{},
);

Map<String, dynamic> _$TranslationProjectStateToJson(
  _TranslationProjectState instance,
) => <String, dynamic>{'version': instance.version, 'files': instance.files};
