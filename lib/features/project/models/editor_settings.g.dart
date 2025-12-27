// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EditorSettings _$EditorSettingsFromJson(Map<String, dynamic> json) =>
    _EditorSettings(
      theme: json['theme'] as String? ?? 'vs-dark',
      fontSize: (json['fontSize'] as num?)?.toInt() ?? 14,
      lineNumbers: json['lineNumbers'] as bool? ?? true,
      wordWrap: json['wordWrap'] as bool? ?? true,
      autoSaveInterval: (json['autoSaveInterval'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$EditorSettingsToJson(_EditorSettings instance) =>
    <String, dynamic>{
      'theme': instance.theme,
      'fontSize': instance.fontSize,
      'lineNumbers': instance.lineNumbers,
      'wordWrap': instance.wordWrap,
      'autoSaveInterval': instance.autoSaveInterval,
    };
