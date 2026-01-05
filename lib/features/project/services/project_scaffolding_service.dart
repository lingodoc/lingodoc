import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/models.dart';

/// Service for creating and scaffolding new LingoDoc projects
class ProjectScaffoldingService {
  /// Creates a new LingoDoc project with the specified configuration
  ///
  /// [projectPath] - Directory where the project will be created
  /// [projectName] - Name of the project (used in documentation)
  /// [languages] - List of languages to support
  /// [languageOrder] - Order in which languages should appear
  /// [defaultLanguage] - Primary/fallback language
  /// [createSampleChapter] - Whether to create an example chapter
  ///
  /// Throws [FileSystemException] if the directory already exists or cannot be created
  Future<void> createNewProject({
    required String projectPath,
    required String projectName,
    required List<LanguageConfig> languages,
    required List<String> languageOrder,
    required LanguageConfig defaultLanguage,
    bool createSampleChapter = true,
  }) async {
    final projectDir = Directory(projectPath);

    // Check if directory already exists
    if (await projectDir.exists()) {
      throw FileSystemException(
        'Project directory already exists',
        projectPath,
      );
    }

    try {
      // Create project directory structure
      await _createDirectoryStructure(projectPath);

      // Generate config.toml
      await _generateConfigFile(
        projectPath,
        languages,
        languageOrder,
        defaultLanguage,
      );

      // Generate main.typ
      await _generateMainTypFile(projectPath, projectName);

      // Generate lang.typ
      await _generateLangTypFile(projectPath, defaultLanguage.code);

      // Generate terms.typ.example and terms.typ
      await _generateTermsFiles(projectPath);

      // Generate .gitignore
      await _generateGitignore(projectPath);

      // Generate README.md
      await _generateReadme(projectPath, projectName, languages);

      // Optionally create sample chapter
      if (createSampleChapter) {
        await _generateSampleChapter(projectPath, languages);
      }
    } catch (e) {
      // Clean up on error
      if (await projectDir.exists()) {
        await projectDir.delete(recursive: true);
      }
      rethrow;
    }
  }

  /// Creates the directory structure for a new project
  Future<void> _createDirectoryStructure(String projectPath) async {
    final directories = [
      projectPath,
      path.join(projectPath, 'chapters'),
      path.join(projectPath, 'templates'),
      path.join(projectPath, 'output'),
    ];

    for (final dir in directories) {
      await Directory(dir).create(recursive: true);
    }
  }

  /// Generates the config.toml file
  Future<void> _generateConfigFile(
    String projectPath,
    List<LanguageConfig> languages,
    List<String> languageOrder,
    LanguageConfig defaultLanguage,
  ) async {
    final buffer = StringBuffer();
    buffer.writeln('# LingoDoc Project Configuration');
    buffer.writeln();

    // Write languages
    for (final lang in languages) {
      buffer.writeln('[[languages]]');
      buffer.writeln('code = "${lang.code}"');
      buffer.writeln('name = "${lang.name}"');
      buffer.writeln();
    }

    // Write language_order
    buffer.write('language_order = [');
    buffer.write(languageOrder.map((code) => '"$code"').join(', '));
    buffer.writeln(']');
    buffer.writeln();

    // Write view_mode
    buffer.writeln('# View mode: "SideBySide2", "SideBySide3", "Sequential", "PreviewOnly"');
    buffer.writeln('view_mode = "Sequential"');
    buffer.writeln();

    // Write editor_settings
    buffer.writeln('[editor_settings]');
    buffer.writeln('theme = "vs-dark"');
    buffer.writeln('font_size = 14');
    buffer.writeln('line_numbers = true');
    buffer.writeln('word_wrap = true');
    buffer.writeln('auto_save_interval = 1  # seconds');
    buffer.writeln();

    // Write project_settings
    buffer.writeln('[project_settings]');
    buffer.write('default_language = { code = "${defaultLanguage.code}", ');
    buffer.writeln('name = "${defaultLanguage.name}" }');
    buffer.writeln('output_directory = "output"');
    buffer.writeln('auto_compile = true');
    buffer.writeln('compile_debounce_ms = 500');

    final configFile = File(path.join(projectPath, 'config.toml'));
    await configFile.writeAsString(buffer.toString());
  }

  /// Generates the main.typ file
  Future<void> _generateMainTypFile(String projectPath, String projectName) async {
    final buffer = StringBuffer();
    buffer.writeln('// main.typ');
    buffer.writeln('// Main document file that includes all chapters');
    buffer.writeln();
    buffer.writeln('// Import language configuration (modified by LingoDoc at compile time)');
    buffer.writeln('#import "lang.typ": current-lang');
    buffer.writeln();
    buffer.writeln('// Import project terms (if exists)');
    buffer.writeln('// Copy terms.typ.example to terms.typ and customize for your project');
    buffer.writeln('#import "terms.typ": term, terms, term-code, term-bold, term-italic');
    buffer.writeln();
    buffer.writeln('// Document metadata');
    buffer.writeln('#set document(');
    buffer.writeln('  title: "$projectName",');
    buffer.writeln('  author: "LingoDoc User"');
    buffer.writeln(')');
    buffer.writeln();
    buffer.writeln('// Page setup');
    buffer.writeln('#set page(');
    buffer.writeln('  paper: "a4",');
    buffer.writeln('  margin: (x: 2.5cm, y: 2cm),');
    buffer.writeln('  numbering: "1",');
    buffer.writeln(')');
    buffer.writeln();
    buffer.writeln('// Text settings');
    buffer.writeln('#set text(');
    buffer.writeln('  font: "Linux Libertine",');
    buffer.writeln('  size: 11pt,');
    buffer.writeln('  lang: current-lang,');
    buffer.writeln(')');
    buffer.writeln();
    buffer.writeln('// Heading settings');
    buffer.writeln('#set heading(numbering: "1.1")');
    buffer.writeln();
    buffer.writeln('// Title page');
    buffer.writeln('#align(center)[');
    buffer.writeln('  #v(1fr)');
    buffer.writeln('  #text(24pt, weight: "bold")[$projectName]');
    buffer.writeln('  #v(0.5cm)');
    buffer.writeln('  #text(14pt)[Multilingual Documentation]');
    buffer.writeln('  #v(1fr)');
    buffer.writeln(']');
    buffer.writeln();
    buffer.writeln('#pagebreak()');
    buffer.writeln();
    buffer.writeln('// Table of contents');
    buffer.writeln('#outline(');
    buffer.writeln('  title: [Table of Contents],');
    buffer.writeln('  indent: true,');
    buffer.writeln(')');
    buffer.writeln();
    buffer.writeln('#pagebreak()');
    buffer.writeln();
    buffer.writeln('// Include chapters');
    buffer.writeln('// #include "chapters/01-introduction.typ"');
    buffer.writeln('// #pagebreak()');
    buffer.writeln();
    buffer.writeln('// Add more chapters as needed');
    buffer.writeln();

    final mainFile = File(path.join(projectPath, 'main.typ'));
    await mainFile.writeAsString(buffer.toString());
  }

  /// Generates the lang.typ file
  Future<void> _generateLangTypFile(String projectPath, String defaultLangCode) async {
    final buffer = StringBuffer();
    buffer.writeln('// lang.typ - Language configuration');
    buffer.writeln('// This file is modified by LingoDoc at compile time');
    buffer.writeln('// Do not edit manually - changes will be overwritten during compilation');
    buffer.writeln('#let current-lang = "$defaultLangCode"');
    buffer.writeln();

    final langFile = File(path.join(projectPath, 'lang.typ'));
    await langFile.writeAsString(buffer.toString());
  }

  /// Generates terms.typ.example and terms.typ files
  Future<void> _generateTermsFiles(String projectPath) async {
    final termsTemplate = '''// terms.typ
// Project-specific terms - This file is not tracked in git
//
// Define your project-specific terms here. These terms will be used
// consistently throughout your document across all languages.
//
// NOTE: This file should be customized for your project and not shared in git.
// The terms.typ.example file provides a template.

#let terms = (
  // Add your project-specific terms below
  // example-term: "Example Value",
)

// Helper function to get a term
// Returns the term if it exists, otherwise returns a warning
#let term(key) = {
  if key in terms {
    terms.at(key)
  } else {
    text(fill: red)[⚠️ UNDEFINED: #key]
  }
}

// Optional: Helper function to get a term with custom formatting
#let term-code(key) = {
  raw(term(key))
}

#let term-bold(key) = {
  strong(term(key))
}

#let term-italic(key) = {
  emph(term(key))
}
''';

    // Write terms.typ.example
    final exampleFile = File(path.join(projectPath, 'terms.typ.example'));
    await exampleFile.writeAsString(termsTemplate);

    // Write terms.typ
    final termsFile = File(path.join(projectPath, 'terms.typ'));
    await termsFile.writeAsString(termsTemplate);
  }

  /// Generates .gitignore file
  Future<void> _generateGitignore(String projectPath) async {
    final gitignore = '''# LingoDoc Project .gitignore

# Output directory (generated PDFs)
output/

# Auto-modified language file
lang.typ

# Project-specific terms (not for version control)
terms.typ

# OS-specific files
.DS_Store
Thumbs.db

# Editor/IDE files
.vscode/
.idea/
*.swp
*.swo
*~
''';

    final gitignoreFile = File(path.join(projectPath, '.gitignore'));
    await gitignoreFile.writeAsString(gitignore);
  }

  /// Generates README.md file
  Future<void> _generateReadme(
    String projectPath,
    String projectName,
    List<LanguageConfig> languages,
  ) async {
    final languageList = languages.map((l) => '- ${l.name} (${l.code})').join('\n');

    final readme = '''# $projectName

A multilingual documentation project created with LingoDoc.

## Languages

This project supports the following languages:
$languageList

## Project Structure

- `config.toml` - Project configuration and language settings
- `main.typ` - Main document entry point
- `lang.typ` - Current language (auto-modified by LingoDoc)
- `terms.typ` - Project-specific terminology dictionary
- `chapters/` - Document chapters with multilingual content
- `templates/` - Reusable Typst templates
- `output/` - Compiled PDF files

## Getting Started

1. Open this project in LingoDoc
2. Edit chapters in the `chapters/` directory
3. Select a language from the toolbar
4. The PDF preview will update automatically

## Adding Chapters

Create a new `.typ` file in the `chapters/` directory using this template:

```typst
// Import language configuration
#import "../lang.typ": current-lang

#let lang-content = (
  en: [
    = Chapter Title in English
    Content in English...
  ],
  // Add other languages here
)

#lang-content.at(current-lang, default: lang-content.en)
```

Then include it in `main.typ`:

```typst
#include "chapters/your-chapter.typ"
#pagebreak()
```

## Customizing Terms

1. Copy `terms.typ.example` to `terms.typ`
2. Add your project-specific terms
3. Use them in chapters with `#term("your-term")`

## Building PDFs

PDFs are automatically compiled when you make changes. Find them in the `output/` directory.

## Learn More

- [Typst Documentation](https://typst.app/docs)
- [LingoDoc Documentation](https://github.com/your-repo/lingodoc)
''';

    final readmeFile = File(path.join(projectPath, 'README.md'));
    await readmeFile.writeAsString(readme);
  }

  /// Generates a sample introduction chapter
  Future<void> _generateSampleChapter(
    String projectPath,
    List<LanguageConfig> languages,
  ) async {
    final buffer = StringBuffer();
    buffer.writeln('// 01-introduction.typ');
    buffer.writeln('// Multilingual chapter: All languages in one file');
    buffer.writeln();
    buffer.writeln('// Import language configuration');
    buffer.writeln('#import "../lang.typ": current-lang');
    buffer.writeln();
    buffer.writeln('#let lang-content = (');

    // Generate content for each language
    for (var i = 0; i < languages.length; i++) {
      final lang = languages[i];
      buffer.writeln('  ${lang.code}: [');
      buffer.writeln('    = Introduction');
      buffer.writeln();
      buffer.writeln('    Welcome to this documentation project.');
      buffer.writeln();
      buffer.writeln('    == Getting Started');
      buffer.writeln();
      buffer.writeln('    This is a sample chapter in ${lang.name}.');
      buffer.write('  ]');
      if (i < languages.length - 1) {
        buffer.writeln(',');
      } else {
        buffer.writeln();
      }
      buffer.writeln();
    }

    buffer.writeln(')');
    buffer.writeln();
    buffer.writeln('#lang-content.at(current-lang, default: lang-content.${languages.first.code})');
    buffer.writeln();

    final chapterFile = File(path.join(projectPath, 'chapters', '01-introduction.typ'));
    await chapterFile.writeAsString(buffer.toString());

    // Update main.typ to include the chapter
    final mainFile = File(path.join(projectPath, 'main.typ'));
    final mainContent = await mainFile.readAsString();
    final updatedContent = mainContent.replaceAll(
      '// Include chapters\n// #include "chapters/01-introduction.typ"\n// #pagebreak()',
      '// Include chapters\n#include "chapters/01-introduction.typ"\n#pagebreak()',
    );
    await mainFile.writeAsString(updatedContent);
  }
}
