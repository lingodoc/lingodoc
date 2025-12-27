class AppConstants {
  static const String appName = 'LingoDoc';
  static const String appVersion = '0.1.0';

  // File extensions
  static const String typstExtension = '.typ';
  static const String tomlExtension = '.toml';
  static const String pdfExtension = '.pdf';

  // Config file names
  static const String configFileName = 'config.toml';
  static const String langFileName = 'lang.typ';
  static const String termsFileName = 'terms.typ';
  static const String mainFileName = 'main.typ';

  // Default directories
  static const String chaptersDir = 'chapters';
  static const String templatesDir = 'templates';
  static const String outputDir = 'output';

  // Editor defaults
  static const int defaultFontSize = 14;
  static const int defaultAutoSaveInterval = 1; // seconds
  static const int defaultCompileDebounce = 500; // milliseconds
}
