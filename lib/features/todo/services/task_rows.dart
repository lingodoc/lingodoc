import '../../translation/models/translation_state.dart';
import '../../translation/services/translation_staleness.dart';
import '../models/todo_item.dart';
import 'todo_provider.dart';

/// The visible task rows for one file: TODO markers and out-of-date
/// translations, after filtering.
typedef FileTaskRows = ({
  List<TodoItem> todos,
  List<({String blockId, String lang})> trans,
});

/// Distinct assigned users across all TODOs (sorted).
List<String> taskUsers(TodoProjectState todosByFile) {
  final users = <String>{};
  for (final todos in todosByFile.values) {
    for (final t in todos) {
      if (t.user != null) users.add(t.user!);
    }
  }
  return users.toList()..sort();
}

/// Whether any TODO is general (unassigned).
bool hasUnassignedTodos(TodoProjectState todosByFile) {
  for (final todos in todosByFile.values) {
    for (final t in todos) {
      if (t.user == null) return true;
    }
  }
  return false;
}

/// Distinct languages that have a TODO or an out-of-date translation (sorted).
List<String> taskLangs(
  TodoProjectState todosByFile,
  Map<String, TranslationFileState> translationFiles,
) {
  final langs = <String>{};
  for (final todos in todosByFile.values) {
    for (final t in todos) {
      if (t.lang != null) langs.add(t.lang!);
    }
  }
  for (final file in translationFiles.values) {
    for (final s in staleBlocksForFile(file)) {
      langs.add(s.lang);
    }
  }
  return langs.toList()..sort();
}

/// Build the filtered, per-file rows for the Tasks panel.
///
/// - Type filter selects TODOs and/or translations.
/// - A user filter is about assignees, so it both narrows TODOs to that user
///   (or [kUnassignedFilter] for general ones) and hides translations entirely.
/// - A language filter narrows both TODOs and translations to that language;
///   document-level TODOs (no language) are excluded when a language is chosen.
Map<String, FileTaskRows> buildTaskRows({
  required TodoProjectState todosByFile,
  required Map<String, TranslationFileState> translationFiles,
  required TaskFilter filter,
}) {
  final showTodos = filter.type != TaskTypeFilter.translations;
  final showTrans =
      filter.type != TaskTypeFilter.todos && filter.user == null;

  bool todoVisible(TodoItem t) {
    if (filter.user != null) {
      if (filter.user == kUnassignedFilter) {
        if (t.user != null) return false;
      } else if (t.user != filter.user) {
        return false;
      }
    }
    if (filter.lang != null && t.lang != filter.lang) return false;
    return true;
  }

  final result = <String, FileTaskRows>{};

  if (showTodos) {
    for (final entry in todosByFile.entries) {
      final visible = entry.value.where(todoVisible).toList();
      if (visible.isEmpty) continue;
      result
          .putIfAbsent(entry.key, () => (todos: [], trans: []))
          .todos
          .addAll(visible);
    }
  }
  if (showTrans) {
    for (final relPath in translationFiles.keys) {
      final stale = staleBlocksForFile(translationFiles[relPath]).where((s) {
        return filter.lang == null || s.lang == filter.lang;
      }).toList();
      if (stale.isEmpty) continue;
      result
          .putIfAbsent(relPath, () => (todos: [], trans: []))
          .trans
          .addAll(stale);
    }
  }

  return result;
}
