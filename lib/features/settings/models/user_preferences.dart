import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_preferences.freezed.dart';
part 'user_preferences.g.dart';

/// JSON converter for ThemeMode
class ThemeModeConverter implements JsonConverter<ThemeMode, String> {
  const ThemeModeConverter();

  @override
  ThemeMode fromJson(String json) {
    switch (json) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  @override
  String toJson(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

/// User preferences model for LingoDoc application settings.
///
/// Persisted to SharedPreferences on save.
@freezed
sealed class UserPreferences with _$UserPreferences {
  const UserPreferences._(); // Private constructor for Freezed

  const factory UserPreferences({
    // Application settings
    @ThemeModeConverter() @Default(ThemeMode.dark) ThemeMode themeMode,
    @Default(10) int autoRefreshIntervalSeconds,
    @Default(true) bool enableAutoRefresh,
    @Default(true) bool rememberWindowState,

    // Editor preferences (override project config)
    @Default(14) int editorFontSize,
    @Default(true) bool editorLineNumbers,
    @Default(true) bool editorWordWrap,

    // Preview preferences
    @Default(true) bool retainPdfPage,

    // Screen library
    @Default(null) String? screenLibraryPath,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}
