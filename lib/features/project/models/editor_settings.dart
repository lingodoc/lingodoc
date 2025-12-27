import 'package:freezed_annotation/freezed_annotation.dart';

part 'editor_settings.freezed.dart';
part 'editor_settings.g.dart';

/// Editor preferences for the application.
@freezed
sealed class EditorSettings with _$EditorSettings {
  const EditorSettings._();  // Private constructor for Freezed

  const factory EditorSettings({
    @Default('vs-dark') String theme,
    @Default(14) int fontSize,
    @Default(true) bool lineNumbers,
    @Default(true) bool wordWrap,
    @Default(1) int autoSaveInterval,
  }) = _EditorSettings;

  factory EditorSettings.fromJson(Map<String, dynamic> json) =>
      _$EditorSettingsFromJson(json);
}
