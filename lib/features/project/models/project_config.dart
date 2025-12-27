import 'package:freezed_annotation/freezed_annotation.dart';
import 'language_config.dart';
import 'editor_settings.dart';
import 'project_settings.dart';

part 'project_config.freezed.dart';
part 'project_config.g.dart';

/// Root configuration model for a LingoDoc project.
@freezed
sealed class ProjectConfig with _$ProjectConfig {
  const ProjectConfig._();  // Private constructor for Freezed

  const factory ProjectConfig({
    required List<LanguageConfig> languages,
    required List<String> languageOrder,
    @Default('Sequential') String viewMode,
    @Default(EditorSettings()) EditorSettings editorSettings,
    required ProjectSettings projectSettings,
  }) = _ProjectConfig;

  factory ProjectConfig.fromJson(Map<String, dynamic> json) =>
      _$ProjectConfigFromJson(json);
}
