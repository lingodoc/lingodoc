// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProjectConfig _$ProjectConfigFromJson(Map<String, dynamic> json) =>
    _ProjectConfig(
      languages: (json['languages'] as List<dynamic>)
          .map((e) => LanguageConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
      languageOrder: (json['languageOrder'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      viewMode: json['viewMode'] as String? ?? 'Sequential',
      editorSettings: json['editorSettings'] == null
          ? const EditorSettings()
          : EditorSettings.fromJson(
              json['editorSettings'] as Map<String, dynamic>,
            ),
      projectSettings: ProjectSettings.fromJson(
        json['projectSettings'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$ProjectConfigToJson(_ProjectConfig instance) =>
    <String, dynamic>{
      'languages': instance.languages,
      'languageOrder': instance.languageOrder,
      'viewMode': instance.viewMode,
      'editorSettings': instance.editorSettings,
      'projectSettings': instance.projectSettings,
    };
