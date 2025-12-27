import 'dart:io';
import 'package:toml/toml.dart';
import '../models/models.dart';

/// Service for loading and parsing LingoDoc project configuration from TOML files.
class ConfigService {
  /// Loads and parses the config.toml file from the given project path.
  ///
  /// Throws [FileSystemException] if the file doesn't exist.
  /// Throws [FormatException] if the TOML is invalid or required fields are missing.
  Future<ProjectConfig> loadConfig(String projectPath) async {
    final configFile = File('$projectPath/config.toml');
    
    if (!await configFile.exists()) {
      throw FileSystemException(
        'Configuration file not found',
        configFile.path,
      );
    }

    final content = await configFile.readAsString();
    final document = TomlDocument.parse(content);

    return _parseConfig(document.toMap());
  }

  /// Parses the TOML document map into a ProjectConfig model.
  ProjectConfig _parseConfig(Map<String, dynamic> toml) {
    // Parse languages array
    final languagesRaw = toml['languages'] as List<dynamic>?;
    if (languagesRaw == null || languagesRaw.isEmpty) {
      throw const FormatException('Missing or empty "languages" array in config.toml');
    }

    final languages = languagesRaw.map((lang) {
      final langMap = lang as Map<String, dynamic>;
      return LanguageConfig(
        code: langMap['code'] as String? ?? '',
        name: langMap['name'] as String? ?? '',
      );
    }).toList();

    // TOML parser bug workaround: top-level values after arrays get nested in the last array element
    // Check the last language element for language_order and view_mode
    final lastLangMap = languagesRaw.last as Map<String, dynamic>;

    // Parse language_order array (might be in last language element due to TOML bug)
    final languageOrderRaw = (toml['language_order'] ?? lastLangMap['language_order']) as List<dynamic>?;
    final languageOrder = languageOrderRaw?.cast<String>() ??
        languages.map((l) => l.code).toList();

    // Parse view_mode (might be in last language element due to TOML bug)
    final viewMode = (toml['view_mode'] ?? lastLangMap['view_mode']) as String? ?? 'Sequential';

    // Parse editor_settings
    final editorSettingsMap = toml['editor_settings'] as Map<String, dynamic>?;
    final editorSettings = editorSettingsMap != null
        ? EditorSettings(
            theme: editorSettingsMap['theme'] as String? ?? 'vs-dark',
            fontSize: editorSettingsMap['font_size'] as int? ?? 14,
            lineNumbers: editorSettingsMap['line_numbers'] as bool? ?? true,
            wordWrap: editorSettingsMap['word_wrap'] as bool? ?? true,
            autoSaveInterval: editorSettingsMap['auto_save_interval'] as int? ?? 1,
          )
        : const EditorSettings();

    // Parse project_settings
    final projectSettingsMap = toml['project_settings'] as Map<String, dynamic>?;
    if (projectSettingsMap == null) {
      throw const FormatException('Missing "project_settings" section in config.toml');
    }

    // Parse default_language
    final defaultLangMap = projectSettingsMap['default_language'] as Map<String, dynamic>?;
    if (defaultLangMap == null) {
      throw const FormatException('Missing "default_language" in project_settings');
    }

    final defaultLanguage = LanguageConfig(
      code: defaultLangMap['code'] as String? ?? '',
      name: defaultLangMap['name'] as String? ?? '',
    );

    final projectSettings = ProjectSettings(
      defaultLanguage: defaultLanguage,
      outputDirectory: projectSettingsMap['output_directory'] as String? ?? 'output',
      autoCompile: projectSettingsMap['auto_compile'] as bool? ?? true,
      compileDebounceMs: projectSettingsMap['compile_debounce_ms'] as int? ?? 500,
    );

    return ProjectConfig(
      languages: languages,
      languageOrder: languageOrder,
      viewMode: viewMode,
      editorSettings: editorSettings,
      projectSettings: projectSettings,
    );
  }

  /// Saves a ProjectConfig back to the config.toml file.
  Future<void> saveConfig(String projectPath, ProjectConfig config) async {
    final configFile = File('$projectPath/config.toml');
    
    // Build TOML content
    final buffer = StringBuffer();
    buffer.writeln('# LingoDoc Project Configuration');
    buffer.writeln();

    // Write languages
    for (final lang in config.languages) {
      buffer.writeln('[[languages]]');
      buffer.writeln('code = "${lang.code}"');
      buffer.writeln('name = "${lang.name}"');
      buffer.writeln();
    }

    // Write language_order
    buffer.write('language_order = [');
    buffer.write(config.languageOrder.map((code) => '"$code"').join(', '));
    buffer.writeln(']');
    buffer.writeln();

    // Write view_mode
    buffer.writeln('view_mode = "${config.viewMode}"');
    buffer.writeln();

    // Write editor_settings
    buffer.writeln('[editor_settings]');
    buffer.writeln('theme = "${config.editorSettings.theme}"');
    buffer.writeln('font_size = ${config.editorSettings.fontSize}');
    buffer.writeln('line_numbers = ${config.editorSettings.lineNumbers}');
    buffer.writeln('word_wrap = ${config.editorSettings.wordWrap}');
    buffer.writeln('auto_save_interval = ${config.editorSettings.autoSaveInterval}');
    buffer.writeln();

    // Write project_settings
    buffer.writeln('[project_settings]');
    buffer.write('default_language = { code = "${config.projectSettings.defaultLanguage.code}", ');
    buffer.writeln('name = "${config.projectSettings.defaultLanguage.name}" }');
    buffer.writeln('output_directory = "${config.projectSettings.outputDirectory}"');
    buffer.writeln('auto_compile = ${config.projectSettings.autoCompile}');
    buffer.writeln('compile_debounce_ms = ${config.projectSettings.compileDebounceMs}');

    await configFile.writeAsString(buffer.toString());
  }
}
