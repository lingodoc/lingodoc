// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    _UserPreferences(
      themeMode: json['themeMode'] == null
          ? ThemeMode.dark
          : const ThemeModeConverter().fromJson(json['themeMode'] as String),
      autoRefreshIntervalSeconds:
          (json['autoRefreshIntervalSeconds'] as num?)?.toInt() ?? 10,
      enableAutoRefresh: json['enableAutoRefresh'] as bool? ?? true,
      rememberWindowState: json['rememberWindowState'] as bool? ?? true,
      editorFontSize: (json['editorFontSize'] as num?)?.toInt() ?? 14,
      editorLineNumbers: json['editorLineNumbers'] as bool? ?? true,
      editorWordWrap: json['editorWordWrap'] as bool? ?? true,
      retainPdfPage: json['retainPdfPage'] as bool? ?? true,
      screenLibraryPath: json['screenLibraryPath'] as String? ?? null,
    );

Map<String, dynamic> _$UserPreferencesToJson(_UserPreferences instance) =>
    <String, dynamic>{
      'themeMode': const ThemeModeConverter().toJson(instance.themeMode),
      'autoRefreshIntervalSeconds': instance.autoRefreshIntervalSeconds,
      'enableAutoRefresh': instance.enableAutoRefresh,
      'rememberWindowState': instance.rememberWindowState,
      'editorFontSize': instance.editorFontSize,
      'editorLineNumbers': instance.editorLineNumbers,
      'editorWordWrap': instance.editorWordWrap,
      'retainPdfPage': instance.retainPdfPage,
      'screenLibraryPath': instance.screenLibraryPath,
    };
