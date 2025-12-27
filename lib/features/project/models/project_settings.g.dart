// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProjectSettings _$ProjectSettingsFromJson(Map<String, dynamic> json) =>
    _ProjectSettings(
      defaultLanguage: LanguageConfig.fromJson(
        json['defaultLanguage'] as Map<String, dynamic>,
      ),
      outputDirectory: json['outputDirectory'] as String? ?? 'output',
      autoCompile: json['autoCompile'] as bool? ?? true,
      compileDebounceMs: (json['compileDebounceMs'] as num?)?.toInt() ?? 500,
    );

Map<String, dynamic> _$ProjectSettingsToJson(_ProjectSettings instance) =>
    <String, dynamic>{
      'defaultLanguage': instance.defaultLanguage,
      'outputDirectory': instance.outputDirectory,
      'autoCompile': instance.autoCompile,
      'compileDebounceMs': instance.compileDebounceMs,
    };
