import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../models/screen_entry.dart';
import '../../settings/services/settings_service.dart';

/// Known language folder names inside the screen library directory.
const _knownLanguages = ['nl', 'en', 'fr', 'es', 'de', 'it'];

/// Provider that exposes the screen library path from user preferences.
final screenLibraryPathProvider = Provider<String?>((ref) {
  final path = ref.watch(userPreferencesProvider).asData?.value.screenLibraryPath;
  return (path != null && path.isNotEmpty) ? path : null;
});

/// Provider that loads all screen entries from the configured library.
/// Returns an empty list if no library path is configured.
final screenLibraryProvider = FutureProvider<List<ScreenEntry>>((ref) async {
  final basePath = ref.watch(screenLibraryPathProvider);
  if (basePath == null) return [];
  return ScreenLibraryService.loadScreens(basePath);
});

class ScreenLibraryService {
  /// Scans [basePath] for language sub-folders and HTML screen files.
  /// Returns a sorted list of [ScreenEntry] objects.
  static Future<List<ScreenEntry>> loadScreens(String basePath) async {
    // Discover which language folders are present
    final presentLanguages = <String>[];
    for (final lang in _knownLanguages) {
      if (await Directory(p.join(basePath, lang)).exists()) {
        presentLanguages.add(lang);
      }
    }
    if (presentLanguages.isEmpty) return [];

    // Use the first available language to enumerate screen numbers
    final primaryLang = presentLanguages.first;
    final primaryDir = Directory(p.join(basePath, primaryLang));
    final htmlFiles = await primaryDir
        .list()
        .where((e) => e is File && e.path.endsWith('.html'))
        .toList();

    // Parse each screen number and build entries
    final entries = <ScreenEntry>[];
    for (final file in htmlFiles) {
      final name = p.basenameWithoutExtension(file.path);
      final number = int.tryParse(name);
      if (number == null) continue; // skip index.html etc.

      // Determine which languages have this screen
      final langs = <String>[];
      for (final lang in presentLanguages) {
        if (await File(p.join(basePath, lang, '$number.html')).exists()) {
          langs.add(lang);
        }
      }

      // Parse title from the primary language file
      final title = await _parseTitle(file.path);

      entries.add(ScreenEntry(
        number: number,
        title: title,
        availableLanguages: langs,
      ));
    }

    entries.sort((a, b) => a.number.compareTo(b.number));
    return entries;
  }

  /// Extracts the <title> text from an HTML file.
  /// Reads only the first 1KB for speed.
  static Future<String> _parseTitle(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.openRead(0, 1024).toList();
      final content = bytes
          .expand((b) => b)
          .map((b) => String.fromCharCode(b))
          .join();
      final match = RegExp(
        r'<title[^>]*>(.*?)</title>',
        caseSensitive: false,
        dotAll: true,
      ).firstMatch(content);
      if (match != null) {
        return match.group(1)?.trim() ?? '';
      }
    } catch (_) {}
    return '';
  }

  /// Opens the HTML file for [entry] and [lang] in the system browser.
  static Future<void> openInBrowser(
    ScreenEntry entry,
    String libraryBasePath,
    String lang,
  ) async {
    final path = entry.htmlPath(libraryBasePath, lang);
    if (path == null) return;
    await Process.run('xdg-open', [path]);
  }
}
