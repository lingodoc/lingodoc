import 'package:freezed_annotation/freezed_annotation.dart';
import 'language_config.dart';

part 'project_settings.freezed.dart';
part 'project_settings.g.dart';

/// Project-specific settings.
@freezed
sealed class ProjectSettings with _$ProjectSettings {
  const ProjectSettings._();  // Private constructor for Freezed

  const factory ProjectSettings({
    required LanguageConfig defaultLanguage,
    @Default('output') String outputDirectory,
    @Default(true) bool autoCompile,
    @Default(500) int compileDebounceMs,
  }) = _ProjectSettings;

  factory ProjectSettings.fromJson(Map<String, dynamic> json) =>
      _$ProjectSettingsFromJson(json);
}
