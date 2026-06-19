import 'package:flutter_test/flutter_test.dart';
import 'package:lingodoc/features/todo/models/todo_item.dart';
import 'package:lingodoc/features/todo/services/task_rows.dart';
import 'package:lingodoc/features/todo/services/todo_provider.dart';
import 'package:lingodoc/features/translation/models/translation_state.dart';

void main() {
  // Two files of TODOs across two users and two languages.
  final todos = <String, List<TodoItem>>{
    'chapters/01.typ': [
      const TodoItem(line: 3, message: 'intro', user: 'jo', blockId: 'p1', lang: 'es'),
      const TodoItem(line: 9, message: 'general note'), // unassigned, doc-level
    ],
    'chapters/02.typ': [
      const TodoItem(line: 5, message: 'check term', user: 'maria', blockId: 'p2', lang: 'fr'),
    ],
  };

  // One file with a stale `es` translation: editing en made es stale.
  final translationFiles = <String, TranslationFileState>{
    'chapters/01.typ': const TranslationFileState(blocks: {
      'p1': TranslationBlockState(
        latestToken: 't2',
        langs: {
          'en': TranslationLangState(hash: 'a', token: 't2'),
          'es': TranslationLangState(hash: 'b', token: 't1'), // stale
        },
      ),
    }),
  };

  group('option sources', () {
    test('taskUsers, hasUnassignedTodos, taskLangs', () {
      expect(taskUsers(todos), ['jo', 'maria']);
      expect(hasUnassignedTodos(todos), isTrue);
      // langs from todos (es, fr) ∪ stale translation langs (es).
      expect(taskLangs(todos, translationFiles), ['es', 'fr']);
    });
  });

  group('buildTaskRows filtering', () {
    test('no filter shows all todos and the stale translation', () {
      final rows = buildTaskRows(
        todosByFile: todos,
        translationFiles: translationFiles,
        filter: const TaskFilter(),
      );
      expect(rows['chapters/01.typ']!.todos.length, 2);
      expect(rows['chapters/01.typ']!.trans.length, 1);
      expect(rows['chapters/02.typ']!.todos.length, 1);
    });

    test('type=todos hides translations', () {
      final rows = buildTaskRows(
        todosByFile: todos,
        translationFiles: translationFiles,
        filter: const TaskFilter(type: TaskTypeFilter.todos),
      );
      expect(rows['chapters/01.typ']!.trans, isEmpty);
      expect(rows['chapters/01.typ']!.todos.length, 2);
    });

    test('type=translations hides todos', () {
      final rows = buildTaskRows(
        todosByFile: todos,
        translationFiles: translationFiles,
        filter: const TaskFilter(type: TaskTypeFilter.translations),
      );
      expect(rows.containsKey('chapters/02.typ'), isFalse);
      expect(rows['chapters/01.typ']!.todos, isEmpty);
      expect(rows['chapters/01.typ']!.trans.length, 1);
    });

    test('user=jo shows only jo todos and hides translations', () {
      final rows = buildTaskRows(
        todosByFile: todos,
        translationFiles: translationFiles,
        filter: const TaskFilter(user: 'jo'),
      );
      expect(rows.keys, ['chapters/01.typ']);
      expect(rows['chapters/01.typ']!.todos.single.user, 'jo');
      expect(rows['chapters/01.typ']!.trans, isEmpty);
    });

    test('user=unassigned shows only general todos', () {
      final rows = buildTaskRows(
        todosByFile: todos,
        translationFiles: translationFiles,
        filter: const TaskFilter(user: kUnassignedFilter),
      );
      expect(rows.keys, ['chapters/01.typ']);
      expect(rows['chapters/01.typ']!.todos.single.user, isNull);
    });

    test('lang=es narrows todos and translations to es', () {
      final rows = buildTaskRows(
        todosByFile: todos,
        translationFiles: translationFiles,
        filter: const TaskFilter(lang: 'es'),
      );
      // 02 (fr todo) excluded; doc-level todo (no lang) excluded.
      expect(rows.keys, ['chapters/01.typ']);
      expect(rows['chapters/01.typ']!.todos.single.lang, 'es');
      expect(rows['chapters/01.typ']!.trans.single.lang, 'es');
    });

    test('combined user=maria + lang=fr', () {
      final rows = buildTaskRows(
        todosByFile: todos,
        translationFiles: translationFiles,
        filter: const TaskFilter(user: 'maria', lang: 'fr'),
      );
      expect(rows.keys, ['chapters/02.typ']);
      expect(rows['chapters/02.typ']!.todos.single.user, 'maria');
    });
  });
}
