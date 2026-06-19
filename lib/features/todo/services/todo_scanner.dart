import '../../translation/services/translation_block_extractor.dart';
import '../models/todo_item.dart';

/// Scans `.typ` source for TODO comment markers and locates each within its
/// enclosing multilingual block/language (when any).
///
/// Marker grammar (case-insensitive, may appear inline as a trailing comment):
///   `// todo`                         → general
///   `// todo: rewrite this`           → general + message
///   `// todo(jo): translate to es`    → assigned to `jo`
///   `// todo(@maria) check term`      → assigned to `maria` (@ optional, : optional)
///
/// Language scoping reuses [TranslationBlockExtractor.extractSpans] so a marker
/// inside an `es: [ … ]` value is tagged `lang: es`, while one outside every
/// language value is document-level (`blockId`/`lang` null).
class TodoScanner {
  const TodoScanner();

  static final RegExp _marker = RegExp(
    r'//\s*todo\b(?:\s*\(\s*@?([A-Za-z0-9_.\-]+)\s*\))?\s*:?\s*(.*)$',
    caseSensitive: false,
  );

  /// Returns every TODO in [fileText], in source order. [languageCodes] is the
  /// project's configured languages, used to attribute markers to a language.
  List<TodoItem> scan(String fileText, List<String> languageCodes) {
    final lines = fileText.split('\n');
    final spans =
        const TranslationBlockExtractor().extractSpans(fileText, languageCodes);

    final todos = <TodoItem>[];
    for (var i = 0; i < lines.length; i++) {
      final m = _marker.firstMatch(lines[i]);
      if (m == null) continue;

      // Find the (single) language span that encloses this line, if any.
      TranslationLangSpan? enclosing;
      for (final s in spans) {
        if (i >= s.startLine && i < s.endLine) {
          enclosing = s;
          break;
        }
      }

      todos.add(TodoItem(
        line: i + 1, // 1-based for editor navigation
        message: (m.group(2) ?? '').trim(),
        user: m.group(1),
        blockId: enclosing?.blockId,
        lang: enclosing?.lang,
      ));
    }
    return todos;
  }
}
