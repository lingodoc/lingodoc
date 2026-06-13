# PROJECT_INDEX.md — LingoDoc Flutter

> **Token Savings**: ~94% reduction — read this (~3K tokens) instead of scanning all source files (~58K tokens).
> **Generated**: 2026-04-05 | **Version**: 0.1.0+1

---

## 📁 Project Structure

```
lingodoc-flutter/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── app.dart                           # Root MaterialApp widget
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart         # App-wide constants
│   │   │   └── file_extensions.dart       # Supported file extensions
│   │   ├── services/
│   │   │   └── timer_service.dart         # Singleton timer coordinator (prevents conflicts)
│   │   ├── theme/
│   │   │   └── app_theme.dart             # Material 3 theme definition
│   │   └── utils/
│   │       └── path_validator.dart        # Security: path traversal prevention, ISO 639-1/2 validation
│   ├── features/
│   │   ├── editor/
│   │   │   ├── models/
│   │   │   │   ├── editor_tab.dart        # Tab state: filePath, content, isDirty, scrollOffset
│   │   │   │   ├── suggestion.dart        # Autocomplete suggestion model
│   │   │   │   └── typst_language_mode.dart # CodeEditor language mode definition
│   │   │   ├── services/
│   │   │   │   ├── autocomplete_service.dart  # Typst function + project terms autocomplete
│   │   │   │   ├── editor_service.dart        # EditorNotifier (Riverpod), tab CRUD, file I/O
│   │   │   │   └── search_provider.dart       # SearchNotifier + SearchState (Freezed)
│   │   │   └── widgets/
│   │   │       ├── code_editor.dart           # Main editor widget (flutter_code_editor)
│   │   │       ├── editor_tabs.dart           # Tab bar widget
│   │   │       ├── highlighted_code_editor.dart # Syntax-highlighted editor wrapper
│   │   │       └── search_bar_widget.dart     # Find/replace bar widget
│   │   ├── preview/
│   │   │   ├── models/
│   │   │   │   ├── detachable_window_state.dart  # Freezed: isDetached, pdfPath, language, isCompiling
│   │   │   │   └── preview_state.dart            # Freezed: PdfPreviewState (pdfPath, isCompiling, error)
│   │   │   ├── services/
│   │   │   │   ├── auto_refresh_service.dart     # Debounce + 10s periodic compile timer
│   │   │   │   ├── detachable_window_service.dart # DetachableWindowNotifier (multi-window)
│   │   │   │   └── preview_provider.dart          # PdfPreviewNotifier, typstCompilerProvider
│   │   │   └── widgets/
│   │   │       ├── detached_preview_window.dart   # Standalone preview window widget
│   │   │       ├── detached_window_entry.dart     # Entry point for detached window process
│   │   │       ├── language_grid.dart             # Multi-language PDF grid view
│   │   │       ├── pdf_viewer.dart                # pdfrx PDF viewer widget
│   │   │       └── preview_panel.dart             # Right-panel preview with language selector
│   │   ├── project/
│   │   │   ├── models/
│   │   │   │   ├── editor_settings.dart    # Freezed: theme, fontSize, lineNumbers, wordWrap
│   │   │   │   ├── file_tree_node.dart     # Tree node: name, path, isDirectory, children
│   │   │   │   ├── language_config.dart    # Freezed: code (String), name (String)
│   │   │   │   ├── models.dart             # Barrel export for project models
│   │   │   │   ├── project_config.dart     # Freezed: languages, languageOrder, editorSettings, projectSettings
│   │   │   │   └── project_settings.dart   # Freezed: defaultLanguage, outputDirectory, autoCompile, debounceMs
│   │   │   ├── services/
│   │   │   │   ├── config_provider.dart    # projectConfigProvider (reads config.toml)
│   │   │   │   ├── config_service.dart     # TOML parser -> ProjectConfig
│   │   │   │   ├── file_system_service.dart # File tree traversal, file CRUD
│   │   │   │   ├── project_scaffolding_service.dart # Creates new project with template files
│   │   │   │   └── project_state.dart      # ProjectTreeNotifier: load, select file, refresh
│   │   │   └── widgets/
│   │   │       ├── new_project_wizard.dart # Multi-step new project creation dialog
│   │   │       └── project_tree.dart       # File tree panel widget (flutter_treeview)
│   │   ├── settings/
│   │   │   ├── models/
│   │   │   │   └── user_preferences.dart   # Freezed: themeMode, autoRefreshIntervalSeconds,
│   │   │   │                               #          enableAutoRefresh, retainPdfPage,
│   │   │   │                               #          editorFontSize, editorLineNumbers, editorWordWrap
│   │   │   ├── services/
│   │   │   │   └── settings_service.dart   # SharedPreferences persistence for UserPreferences
│   │   │   └── widgets/
│   │   │       └── settings_dialog.dart    # Settings UI dialog
│   │   └── typst/
│   │       ├── models/
│   │       │   └── compilation_result.dart # Freezed: success, pdfPath, errorMessage, languageCode
│   │       ├── services/
│   │       │   ├── typst_compiler.dart     # Runs `typst compile`, injects lang.typ, returns PDF path
│   │       │   ├── typst_installer.dart    # Downloads & installs Typst binary (with SHA256 verify)
│   │       │   ├── typst_path_resolver.dart # Finds typst executable (PATH -> app support dir)
│   │       │   └── typst_startup_check.dart # Checks Typst installation at startup
│   │       └── widgets/
│   │           └── typst_install_dialog.dart # Install-prompt dialog
│   └── shared/
│       ├── providers/
│       │   └── app_providers.dart          # Barrel export: all Riverpod providers
│       └── widgets/
│           ├── app_startup.dart            # Initialization wrapper (Typst check, prefs load)
│           ├── error_message.dart          # Shared error display widget
│           ├── loading_indicator.dart      # Shared loading spinner widget
│           └── main_layout.dart            # 3-panel split: ProjectTree | Editor | Preview
├── sample-project/                         # Reference project for testing
│   ├── config.toml                         # Config schema reference
│   ├── chapters/01-introduction.typ        # Multilingual chapter example
│   ├── lang.typ                            # Language injection file (auto-modified at runtime)
│   ├── main.typ                            # Document entry point
│   └── terms.typ                           # Terminology dictionary
├── docs/
│   ├── STEP_13_AUTO_REFRESH.md
│   ├── FIX_PLAN_AUTO_REFRESH_AND_PAGE_RETENTION.md
│   ├── TECHNICAL_DEBT_PLAN.md
│   └── known-issues.md
├── CLAUDE.md                               # AI agent guidance (read first)
├── PROJECT_INDEX.md                        # This file
├── pubspec.yaml                            # Flutter dependencies
└── analysis_options.yaml                   # Dart linting rules
```

---

## 🚀 Entry Points

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry: initialises window_manager, runs `App` widget |
| `lib/app.dart` | `MaterialApp` with Riverpod, theme, routing |
| `lib/shared/widgets/app_startup.dart` | Startup check (Typst binary, preferences) |
| `lib/features/preview/widgets/detached_window_entry.dart` | Entry for detached PDF window process |

---

## 📦 Core Riverpod Providers

All re-exported from `lib/shared/providers/app_providers.dart`.

| Provider | Type | Location | Purpose |
|----------|------|----------|---------|
| `editorProvider` | `NotifierProvider<EditorNotifier, EditorState>` | `editor_service.dart` | Tab CRUD, file open/save/close |
| `searchProvider` | `NotifierProvider<SearchNotifier, SearchState>` | `search_provider.dart` | Find/replace UI state |
| `autoRefreshServiceProvider` | `Provider<AutoRefreshService>` | `auto_refresh_service.dart` | Debounce + periodic compile triggers |
| `detachableWindowProvider` | `NotifierProvider<DetachableWindowNotifier, DetachableWindowState>` | `detachable_window_service.dart` | Multi-window preview state |
| `pdfPreviewProvider` | `NotifierProvider<PdfPreviewNotifier, PdfPreviewState>` | `preview_provider.dart` | PDF path + compile state |
| `typstCompilerProvider` | `Provider<TypstCompiler>` | `preview_provider.dart` | TypstCompiler singleton |
| `projectConfigProvider` | `FutureProvider<ProjectConfig?>` | `config_provider.dart` | Reads & parses config.toml |
| `projectTreeProvider` | `NotifierProvider<ProjectTreeNotifier, ProjectTreeState>` | `project_state.dart` | File tree load/select/refresh |
| `settingsServiceProvider` | `Provider<SettingsService>` | `settings_service.dart` | SharedPreferences adapter |
| `userPreferencesProvider` | `NotifierProvider<…, UserPreferences>` | `settings_service.dart` | Live user preferences state |
| `typstPathResolverProvider` | `Provider<TypstPathResolver>` | `typst_path_resolver.dart` | Executable lookup |
| `typstStartupCheckProvider` | `FutureProvider<bool>` | `typst_startup_check.dart` | Is Typst installed? |

---

## 🧊 Freezed Models

| Model | Key Fields | File |
|-------|-----------|------|
| `LanguageConfig` | `code`, `name` | `project/models/language_config.dart` |
| `EditorSettings` | `theme`, `fontSize`, `lineNumbers`, `wordWrap`, `autoSaveInterval` | `project/models/editor_settings.dart` |
| `ProjectSettings` | `defaultLanguage`, `outputDirectory`, `autoCompile`, `compileDebouncMs` | `project/models/project_settings.dart` |
| `ProjectConfig` | `languages`, `languageOrder`, `editorSettings`, `projectSettings` | `project/models/project_config.dart` |
| `CompilationResult` | `success`, `pdfPath`, `errorMessage`, `languageCode` | `typst/models/compilation_result.dart` |
| `PdfPreviewState` | `pdfPath`, `languageCode`, `isCompiling`, `errorMessage`, `lastCompiled` | `preview/models/preview_state.dart` |
| `DetachableWindowState` | `isDetached`, `pdfPath`, `selectedLanguage`, `isCompiling` | `preview/models/detachable_window_state.dart` |
| `SearchState` | `isVisible`, `searchQuery`, `currentMatchIndex`, `totalMatches`, `caseSensitive`, `wholeWord`, `useRegex` | `editor/services/search_provider.dart` |
| `UserPreferences` | `themeMode`, `autoRefreshIntervalSeconds`, `enableAutoRefresh`, `retainPdfPage`, `editorFontSize`, `editorLineNumbers`, `editorWordWrap` | `settings/models/user_preferences.dart` |

---

## 🔧 Key Services

| Service | Singleton? | Purpose |
|---------|-----------|---------|
| `TimerService` | Yes (Dart singleton) | Central timer registry — prevents conflicts between debounce/periodic timers |
| `TypstCompiler` | Via provider | `typst compile` subprocess; injects `lang.typ`; SHA256-verified install |
| `TypstInstaller` | Stateless | Downloads platform-specific Typst release, SHA256 verify, installs to app support dir |
| `TypstPathResolver` | Via provider | PATH -> app support dir lookup for typst executable |
| `AutoRefreshService` | Via provider | Debounce (file change) + 10s periodic timer -> triggers compile |
| `ConfigService` | Stateless | TOML parsing -> `ProjectConfig` |
| `FileSystemService` | Via provider | Directory traversal -> `FileTreeNode` list; file CRUD |
| `ProjectScaffoldingService` | Stateless | Generates `config.toml`, `lang.typ`, `main.typ`, `terms.typ`, optional sample chapter |
| `SettingsService` | Via provider | JSON <-> `SharedPreferences` for `UserPreferences` |
| `PathValidator` | Static util | ISO 639-1/2 language code validation; path traversal prevention |
| `AutocompleteService` | Per-editor | Typst built-ins + project `terms.typ` suggestions with 150ms debounce |

---

## 🗺️ Implementation Status (16-Step Roadmap)

| Step | Status | Description |
|------|--------|-------------|
| 1 | done | Project setup, dependencies, folder structure |
| 2 | done | Core Freezed models (ProjectConfig, LanguageConfig, etc.) |
| 3 | done | TOML config service |
| 4 | done | Main layout: 3-panel split (ProjectTree | Editor | Preview) |
| 5 | done | Project file tree with expand/collapse |
| 6 | done | Plain text editor, file tabs |
| 7 | done | Typst binary installer (download + SHA256 verify) |
| 8 | done | Typst compilation -> PDF |
| 9 | done | PDF preview (pdfrx) |
| 10 | partial | Multi-language preview grid (language_grid.dart exists, integration pending) |
| 11 | done | Syntax highlighting (custom regex Typst mode via flutter_code_editor) |
| 12 | partial | Autocomplete (service implemented, UI integration in progress) |
| 13 | done | Auto-refresh: debounce + 10s periodic timer; page retention on language change |
| 14 | done | Detachable preview window (desktop_multi_window) |
| 15 | done | Settings dialog (UserPreferences + SharedPreferences) |
| 16 | partial | Polish: error handling, loading states, keyboard shortcuts |

---

## Language Injection Mechanism

1. User selects language in UI
2. App writes `#let current-lang = "en"` into `lang.typ`
3. `typst compile` runs against `main.typ`
4. PDF generated with selected language content
5. `pdfrx` viewer loads the resulting PDF

---

## ⚙️ Configuration Schema (`config.toml`)

```toml
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
```

---

## 📚 Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | ^3.1.0 | State management / DI |
| `freezed_annotation` | ^3.1.0 | Immutable model codegen |
| `toml` | ^0.17.0 | config.toml parsing |
| `pdfrx` | ^1.0.82 | PDF viewer widget |
| `flutter_code_editor` | ^0.3.0 | Syntax-highlighted editor |
| `flutter_highlight` / `highlight` | ^0.7.0 | Code highlighting engine |
| `desktop_multi_window` | ^0.2.0 | Detachable preview window |
| `window_manager` | ^0.5.1 | Desktop window control |
| `path_provider` | ^2.1.2 | App support directory (Typst install) |
| `file_picker` | ^10.3.8 | Open project dialog |
| `http` + `archive` | ^1.2.0 / ^4.0.7 | Typst binary download |
| `crypto` | ^3.0.3 | SHA256 checksum verification |
| `shared_preferences` | ^2.2.0 | UserPreferences persistence |
| `split_view` | ^3.2.1 | Resizable 3-panel layout |

---

## 🐛 Known Issues & Locations

| Issue | Location |
|-------|---------|
| Multi-language grid not fully wired to preview panel | `preview/widgets/language_grid.dart`, `preview/widgets/preview_panel.dart` |
| Autocomplete UI not integrated into code_editor | `editor/widgets/code_editor.dart`, `editor/services/autocomplete_service.dart` |
| Page retention PDF scroll restore is partial | `preview/widgets/pdf_viewer.dart`, `settings/models/user_preferences.dart` |
| Detached window state sync can desync on rapid attach/detach | `preview/services/detachable_window_service.dart` |

See also: `docs/known-issues.md`, `docs/TECHNICAL_DEBT_PLAN.md`

---

## 🛠️ Common Operations

```bash
# Run on Linux
flutter run -d linux

# Regenerate Freezed/JSON models (required after editing @freezed classes)
flutter pub run build_runner build --delete-conflicting-outputs

# Analyze code
flutter analyze

# Run tests
flutter test
```

---

## 📝 Files to Read for Common Tasks

| Task | Primary Files |
|------|--------------|
| Add new setting | `settings/models/user_preferences.dart` -> `settings/services/settings_service.dart` -> `settings/widgets/settings_dialog.dart` |
| Modify compilation | `typst/services/typst_compiler.dart` |
| Change auto-refresh behavior | `preview/services/auto_refresh_service.dart`, `core/services/timer_service.dart` |
| Add editor feature | `editor/services/editor_service.dart`, `editor/widgets/code_editor.dart` |
| Add Typst autocomplete snippets | `editor/services/autocomplete_service.dart` |
| Modify project tree | `project/services/project_state.dart`, `project/widgets/project_tree.dart` |
| Change layout | `shared/widgets/main_layout.dart` |
| Add Riverpod provider | `shared/providers/app_providers.dart` (barrel export) |
| New project wizard | `project/services/project_scaffolding_service.dart`, `project/widgets/new_project_wizard.dart` |
| PDF viewer behavior | `preview/widgets/pdf_viewer.dart`, `preview/widgets/preview_panel.dart` |
| Config parsing | `project/services/config_service.dart`, `project/services/config_provider.dart` |
