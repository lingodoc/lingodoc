# LingoDoc Flutter

A cross-platform desktop application for authoring multilingual technical documentation using Typst.

## Features

- 📝 **Typst Editor**: Syntax-highlighted editor with autocomplete
- 🌍 **Multilingual Support**: Manage multiple language versions in one project
- 📄 **Live Preview**: Real-time PDF generation and preview
- 🎨 **Customizable**: Configurable editor themes, fonts, and layouts
- 🪟 **Multi-Window**: Detachable preview windows for multi-monitor setups
- ⚙️ **Project Configuration**: TOML-based configuration for languages and settings

## Quick Start

### Prerequisites
- Flutter SDK 3.10 or higher
- Desktop development enabled (Linux/macOS/Windows)

### Installation

```bash
# Clone repository
git clone <repo-url>
cd lingodoc_flutter

# Install dependencies
flutter pub get

# Generate models
flutter pub run build_runner build --delete-conflicting-outputs

# Run application
flutter run -d linux  # or macos, windows
```

### Project Structure

```
your-project/
├── config.toml              # Project configuration
├── main.typ                 # Document entry point
├── lang.typ                 # Language selector (auto-modified)
├── terms.typ                # Project terminology
├── chapters/                # Document chapters
│   ├── 01-introduction.typ
│   └── ...
├── templates/               # Reusable templates
└── output/                  # Generated PDFs
```

## Configuration

Edit `config.toml` to configure languages, editor settings, and project defaults.

See [CLAUDE.md](CLAUDE.md) for detailed documentation.

## Development

See [CLAUDE.md](CLAUDE.md) for development setup, architecture, and contribution guidelines.

## License

MIT License
