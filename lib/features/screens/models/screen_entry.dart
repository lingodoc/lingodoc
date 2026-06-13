import 'package:path/path.dart' as p;

/// A single Apollo III screen available in the screen library.
class ScreenEntry {
  final int number;
  final String title;
  final List<String> availableLanguages;

  const ScreenEntry({
    required this.number,
    required this.title,
    required this.availableLanguages,
  });

  /// Absolute path to the HTML file for [lang], or null if not available.
  String? htmlPath(String libraryBasePath, String lang) {
    if (!availableLanguages.contains(lang)) return null;
    return p.join(libraryBasePath, lang, '$number.html');
  }

  /// Typst insertion text for this screen.
  String get insertionText => '#screen($number)';
}
