import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../editor/services/editor_service.dart';
import '../../project/services/project_state.dart';
import '../../translation/services/translation_state_provider.dart';
import '../models/todo_item.dart';
import '../services/task_rows.dart';
import '../services/todo_provider.dart';

/// Unified work panel: TODO markers found in source plus translations that are
/// out of date relative to their freshest sibling. Filterable by assigned user,
/// language, and type. Replaces the translation-only status panel.
class TasksPanel extends ConsumerWidget {
  final VoidCallback? onClose;

  const TasksPanel({super.key, this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final projectPath = ref.watch(projectTreeProvider).projectPath;
    final todosByFile = ref.watch(todoProvider);
    final translation = ref.watch(translationStateProvider);
    final filter = ref.watch(taskFilterProvider);

    // Filter option sources (computed from the full, unfiltered data set).
    final users = taskUsers(todosByFile);
    final hasUnassigned = hasUnassignedTodos(todosByFile);
    final langs = taskLangs(todosByFile, translation.files);

    // Build per-file, filtered rows.
    final fileRows = buildTaskRows(
      todosByFile: todosByFile,
      translationFiles: translation.files,
      filter: filter,
    );

    final relPaths = fileRows.keys.toList()..sort();
    final totalVisible = fileRows.values.fold<int>(
      0,
      (sum, r) => sum + r.todos.length + r.trans.length,
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(
            context,
            ref,
            theme,
            totalVisible,
            filter,
            users: users,
            hasUnassigned: hasUnassigned,
            langs: langs,
          ),
          if (relPaths.isEmpty)
            _buildEmpty(theme)
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: relPaths.length,
                itemBuilder: (context, index) {
                  final relPath = relPaths[index];
                  final rows = fileRows[relPath]!;
                  return _FileGroup(
                    relPath: relPath,
                    projectPath: projectPath,
                    todos: rows.todos,
                    trans: rows.trans,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    int total,
    TaskFilter filter, {
    required List<String> users,
    required bool hasUnassigned,
    required List<String> langs,
  }) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.checklist,
            size: 16,
            color: total > 0
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            'Tasks ($total)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // Type filter
          _FilterMenu<TaskTypeFilter>(
            label: switch (filter.type) {
              TaskTypeFilter.all => 'All',
              TaskTypeFilter.todos => 'TODOs',
              TaskTypeFilter.translations => 'Translations',
            },
            active: filter.type != TaskTypeFilter.all,
            items: const [
              (value: TaskTypeFilter.all, label: 'All'),
              (value: TaskTypeFilter.todos, label: 'TODOs'),
              (value: TaskTypeFilter.translations, label: 'Translations'),
            ],
            onSelected: (v) => ref.read(taskFilterProvider.notifier).setType(v),
          ),
          const SizedBox(width: 4),
          // User filter
          _FilterMenu<String?>(
            label: filter.user == null
                ? 'User'
                : (filter.user == kUnassignedFilter
                      ? 'Unassigned'
                      : '@${filter.user}'),
            active: filter.user != null,
            items: [
              const (value: null, label: 'Any user'),
              if (hasUnassigned)
                (value: kUnassignedFilter, label: 'Unassigned'),
              for (final u in users) (value: u, label: '@$u'),
            ],
            onSelected: (v) => ref.read(taskFilterProvider.notifier).setUser(v),
          ),
          const SizedBox(width: 4),
          // Language filter
          _FilterMenu<String?>(
            label: filter.lang ?? 'Lang',
            active: filter.lang != null,
            items: [
              const (value: null, label: 'Any language'),
              for (final l in langs) (value: l, label: l),
            ],
            onSelected: (v) => ref.read(taskFilterProvider.notifier).setLang(v),
          ),
          if (onClose != null)
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              tooltip: 'Hide panel',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: onClose,
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No open tasks. TODO markers and out-of-date translations '
              'will appear here.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact dropdown used for the three header filters.
class _FilterMenu<T> extends StatelessWidget {
  final String label;
  final bool active;
  final List<({T value, String label})> items;
  final ValueChanged<T> onSelected;

  const _FilterMenu({
    required this.label,
    required this.active,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<T>(
      tooltip: 'Filter',
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final item in items)
          PopupMenuItem<T>(value: item.value, child: Text(item.label)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? theme.colorScheme.secondaryContainer
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: active
                    ? theme.colorScheme.onSecondaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 16),
          ],
        ),
      ),
    );
  }
}

/// One file's group of task rows (TODOs first, then stale translations).
class _FileGroup extends ConsumerWidget {
  final String relPath;
  final String? projectPath;
  final List<TodoItem> todos;
  final List<({String blockId, String lang})> trans;

  const _FileGroup({
    required this.relPath,
    required this.projectPath,
    required this.todos,
    required this.trans,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
          color: theme.colorScheme.surfaceContainer,
          child: Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  p.basename(relPath),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trans.isNotEmpty)
                TextButton(
                  onPressed: () => ref
                      .read(translationStateProvider.notifier)
                      .markAllReviewedAction(relPath),
                  child: const Text('Mark all up to date'),
                ),
            ],
          ),
        ),
        for (final todo in todos)
          _TodoRow(relPath: relPath, projectPath: projectPath, todo: todo),
        for (final entry in trans)
          _TransRow(relPath: relPath, projectPath: projectPath, entry: entry),
      ],
    );
  }
}

/// A TODO marker row. Tapping opens the file at the marker's line.
class _TodoRow extends ConsumerWidget {
  final String relPath;
  final String? projectPath;
  final TodoItem todo;

  const _TodoRow({
    required this.relPath,
    required this.projectPath,
    required this.todo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: projectPath == null
          ? null
          : () => ref
                .read(editorProvider.notifier)
                .openFile(
                  p.join(projectPath!, p.normalize(relPath)),
                  jumpToLine: todo.line,
                ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 4, 8, 4),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            _Chip(
              text: 'todo',
              fg: theme.colorScheme.onPrimaryContainer,
              bg: theme.colorScheme.primaryContainer,
              theme: theme,
            ),
            if (todo.user != null) ...[
              const SizedBox(width: 4),
              _Chip(
                text: '@${todo.user}',
                fg: theme.colorScheme.onSecondaryContainer,
                bg: theme.colorScheme.secondaryContainer,
                theme: theme,
              ),
            ],
            const SizedBox(width: 4),
            _Chip(
              text: todo.lang ?? 'doc',
              fg: theme.colorScheme.onSurfaceVariant,
              bg: theme.colorScheme.surfaceContainerHighest,
              theme: theme,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                todo.message.isEmpty ? '(no description)' : todo.message,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: todo.message.isEmpty
                      ? FontStyle.italic
                      : FontStyle.normal,
                  color: todo.message.isEmpty
                      ? theme.colorScheme.onSurfaceVariant
                      : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'L${todo.line}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// An out-of-date translation row (carried over from the old status panel).
class _TransRow extends ConsumerWidget {
  final String relPath;
  final String? projectPath;
  final ({String blockId, String lang}) entry;

  const _TransRow({
    required this.relPath,
    required this.projectPath,
    required this.entry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: projectPath == null
          ? null
          : () => ref
                .read(editorProvider.notifier)
                .openFile(p.join(projectPath!, p.normalize(relPath))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 4, 4, 4),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(entry.blockId, style: theme.textTheme.bodySmall),
            const SizedBox(width: 8),
            _Chip(
              text: entry.lang,
              fg: theme.colorScheme.onTertiaryContainer,
              bg: theme.colorScheme.tertiaryContainer,
              theme: theme,
            ),
            const Spacer(),
            TextButton(
              onPressed: () => ref
                  .read(translationStateProvider.notifier)
                  .markReviewedAction(relPath, entry.blockId, entry.lang),
              child: const Text('Mark up to date'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color fg;
  final Color bg;
  final ThemeData theme;

  const _Chip({
    required this.text,
    required this.fg,
    required this.bg,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: theme.textTheme.labelSmall?.copyWith(color: fg)),
    );
  }
}
