# LingoDoc - Project Guide

## Overview
LingoDoc is a desktop application for authoring multilingual technical documentation using Typst markup language. Built with Flutter for cross-platform desktop support (Linux, macOS, Windows).

## Architecture

### Technology Stack
- **Frontend**: Flutter 3.10+ (Material 3 UI)
- **State Management**: Riverpod 2.5+
- **Models**: Freezed for immutable data classes
- **Configuration**: TOML parsing for `config.toml`
- **Typst Integration**: CLI wrapper for document compilation
- **PDF Rendering**: Native PDF viewer widgets

### Key Design Patterns
1. **Feature-based architecture**: Code organized by feature, not layer
2. **Immutable state**: All models use Freezed for immutability
3. **Provider pattern**: Riverpod for dependency injection and state
4. **Service layer**: Business logic separated from UI widgets

## Domain Model

### Core Concepts
- **Project**: A LingoDoc project directory containing config.toml, chapters, templates
- **Language**: A configured language (code + name) from config.toml
- **Chapter**: A .typ file containing multilingual content blocks
- **Compilation**: Process of injecting language into lang.typ and generating PDF

### Configuration Schema (config.toml)
\`\`\`toml
[[languages]]
code = "en"
name = "English"

language_order = ["en", "es", "fr"]

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
\`\`\`

### Multilingual Content Pattern
All language versions in a single .typ file:
\`\`\`typst
#import "../lang.typ": current-lang

#let lang-content = (
  en: [English content],
  es: [Spanish content],
  fr: [French content],
)

#lang-content.at(current-lang, default: lang-content.en)
\`\`\`

### Language Injection Mechanism
1. User selects language in UI
2. App modifies \`lang.typ\`: \`#let current-lang = "en"\`
3. Typst compiler runs with updated language
4. PDF generated with selected language content

## Development Workflow

### Initial Setup
\`\`\`bash
# Install Flutter (https://flutter.dev/docs/get-started/install)
flutter doctor

# Clone repository
git clone <repo-url>
cd lingodoc

# Get dependencies
flutter pub get

# Generate Freezed models
flutter pub run build_runner build --delete-conflicting-outputs

# Run app
flutter run -d linux  # or macos, windows
\`\`\`

### Code Generation
\`\`\`bash
# Watch mode (auto-regenerate on changes)
flutter pub run build_runner watch

# One-time build
flutter pub run build_runner build --delete-conflicting-outputs
\`\`\`

### Project Structure
See \`lib/\` directory - feature-based organization with models, services, widgets per feature.

## Implementation Steps (16-Step Roadmap)

1. ✅ **Project setup** - Flutter create, dependencies, folder structure, CLAUDE.md
2. ✅ **Core models** - ProjectConfig, LanguageConfig, etc. with Freezed
3. ✅ **Config service** - TOML parsing for config.toml
4. ✅ **Main layout** - Window setup, 3-panel split view, menu bar
5. ✅ **Project tree** - File tree with expand/collapse
6. ✅ **Basic editor** - Plain text editing, file tabs
7. ✅ **Typst installer** - Download typst on first run
8. ✅ **Compilation** - Invoke typst CLI, generate PDFs
9. ✅ **PDF preview** - Single PDF display with pdfx package
10. **Multi-language preview** - Grid with column selector
11. ✅ **Syntax highlighting** - Typst syntax mode
12. **Code suggestions** - Autocomplete for terms/typst
13. ✅ **Auto-refresh** - Timer-based preview updates
14. **Detachable window** - Multi-window for preview
15. **Settings dialog** - User preferences
16. **Polish** - Error handling, loading states, keyboard shortcuts

## Reference Files (Sample Project)

Located in \`sample-project/\`:
- \`config.toml\` - Configuration schema reference
- \`chapters/01-introduction.typ\` - Multilingual pattern example
- \`terms.typ\` - Project-specific terminology dictionary
- \`lang.typ\` - Language injection file (auto-modified)
- \`main.typ\` - Document entry point

## Contributing

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use \`flutter_lints\` (already configured)
- Run \`flutter analyze\` before committing

### Testing
\`\`\`bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
\`\`\`

### Git Workflow
- Feature branches: \`feature/step-N-description\`
- Commit format: \`Step N: Description of changes\`
- PR titles: \`[Step N] Feature name\`

## Resources

- [Flutter Desktop Documentation](https://docs.flutter.dev/desktop)
- [Riverpod Documentation](https://riverpod.dev/)
- [Freezed Documentation](https://pub.dev/packages/freezed)
- [Typst Documentation](https://typst.app/docs)
