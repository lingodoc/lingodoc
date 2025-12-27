import 'package:freezed_annotation/freezed_annotation.dart';

part 'language_config.freezed.dart';
part 'language_config.g.dart';

/// Represents a language configuration with code and name.
@freezed
sealed class LanguageConfig with _$LanguageConfig {
  const LanguageConfig._();  // Private constructor for Freezed

  const factory LanguageConfig({
    required String code,
    required String name,
  }) = _LanguageConfig;

  factory LanguageConfig.fromJson(Map<String, dynamic> json) =>
      _$LanguageConfigFromJson(json);
}
