import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingodoc/features/project/models/models.dart';
import 'package:lingodoc/features/project/services/config_service.dart';

void main() {
  late ConfigService configService;
  late Directory tempDir;

  setUp(() {
    configService = ConfigService();
    tempDir = Directory.systemTemp.createTempSync('lingodoc_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('ConfigService', () {
    test('loadConfig - successfully loads valid config.toml', () async {
      // Arrange
      final configFile = File('${tempDir.path}/config.toml');
      await configFile.writeAsString('''
[[languages]]
code = "en"
name = "English"

[[languages]]
code = "es"
name = "Spanish"

language_order = ["en", "es"]
view_mode = "Sequential"

[editor_settings]
theme = "vs-dark"
font_size = 14
line_numbers = true
word_wrap = true
auto_save_interval = 1

[project_settings]
default_language = { code = "en", name = "English" }
output_directory = "output"
auto_compile = true
compile_debounce_ms = 500
''');

      // Act
      final config = await configService.loadConfig(tempDir.path);

      // Assert
      expect(config.languages.length, 2);
      expect(config.languages[0].code, 'en');
      expect(config.languages[0].name, 'English');
      expect(config.languages[1].code, 'es');
      expect(config.languages[1].name, 'Spanish');
      expect(config.languageOrder, ['en', 'es']);
      expect(config.viewMode, 'Sequential');
      expect(config.editorSettings.theme, 'vs-dark');
      expect(config.editorSettings.fontSize, 14);
      expect(config.projectSettings.defaultLanguage.code, 'en');
      expect(config.projectSettings.outputDirectory, 'output');
      expect(config.projectSettings.autoCompile, true);
      expect(config.projectSettings.compileDebounceMs, 500);
    });

    test('loadConfig - throws FileSystemException when file does not exist', () async {
      // Act & Assert
      expect(
        () => configService.loadConfig(tempDir.path),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('loadConfig - throws FormatException when languages array is missing', () async {
      // Arrange
      final configFile = File('${tempDir.path}/config.toml');
      await configFile.writeAsString('''
[editor_settings]
theme = "vs-dark"

[project_settings]
default_language = { code = "en", name = "English" }
''');

      // Act & Assert
      expect(
        () => configService.loadConfig(tempDir.path),
        throwsA(isA<FormatException>()),
      );
    });

    test('loadConfig - throws FormatException when project_settings is missing', () async {
      // Arrange
      final configFile = File('${tempDir.path}/config.toml');
      await configFile.writeAsString('''
[[languages]]
code = "en"
name = "English"
''');

      // Act & Assert
      expect(
        () => configService.loadConfig(tempDir.path),
        throwsA(isA<FormatException>()),
      );
    });

    test('loadConfig - uses defaults when optional fields are missing', () async {
      // Arrange
      final configFile = File('${tempDir.path}/config.toml');
      await configFile.writeAsString('''
[[languages]]
code = "en"
name = "English"

[project_settings]
default_language = { code = "en", name = "English" }
''');

      // Act
      final config = await configService.loadConfig(tempDir.path);

      // Assert
      expect(config.languageOrder, ['en']); // Derived from languages
      expect(config.viewMode, 'Sequential'); // Default
      expect(config.editorSettings.theme, 'vs-dark'); // Default
      expect(config.projectSettings.outputDirectory, 'output'); // Default
      expect(config.projectSettings.autoCompile, true); // Default
      expect(config.projectSettings.compileDebounceMs, 500); // Default
    });

    test('saveConfig - successfully writes config to file', () async {
      // Arrange
      final config = ProjectConfig(
        languages: [
          const LanguageConfig(code: 'en', name: 'English'),
          const LanguageConfig(code: 'fr', name: 'French'),
        ],
        languageOrder: ['en', 'fr'],
        viewMode: 'SideBySide2',
        editorSettings: const EditorSettings(
          theme: 'vs-light',
          fontSize: 16,
          lineNumbers: false,
          wordWrap: false,
          autoSaveInterval: 2,
        ),
        projectSettings: const ProjectSettings(
          defaultLanguage: LanguageConfig(code: 'en', name: 'English'),
          outputDirectory: 'dist',
          autoCompile: false,
          compileDebounceMs: 1000,
        ),
      );

      // Act
      await configService.saveConfig(tempDir.path, config);

      // Assert
      final savedConfig = await configService.loadConfig(tempDir.path);
      expect(savedConfig.languages.length, 2);
      expect(savedConfig.languages[0].code, 'en');
      expect(savedConfig.languages[1].code, 'fr');
      expect(savedConfig.viewMode, 'SideBySide2');
      expect(savedConfig.editorSettings.theme, 'vs-light');
      expect(savedConfig.editorSettings.fontSize, 16);
      expect(savedConfig.projectSettings.outputDirectory, 'dist');
      expect(savedConfig.projectSettings.autoCompile, false);
    });
  });
}
