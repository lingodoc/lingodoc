import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../editor/services/editor_service.dart';
import '../../project/services/project_state.dart';
import '../services/translation_staleness.dart';
import '../services/translation_state_provider.dart';

/// Collapsible panel listing translations that are out of date relative to
/// their freshest sibling, grouped by file. Each row clears its own stale flag;
/// each file header can clear all of its own.
class TranslationStatusPanel extends ConsumerWidget {
  final VoidCallback? onClose;

  const TranslationStatusPanel({super.key, this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final projectState = ref.watch(projectTreeProvider);
    final projectPath = projectState.projectPath;
    final translation = ref.watch(translationStateProvider);

    // Files with at least one stale translation, sorted by path.
    final staleFiles = <String, List<({String blockId, String lang})>>{};
    for (final relPath in translation.files.keys) {
      final stale = staleBlocksForFile(translation.files[relPath]);
      if (stale.isNotEmpty) staleFiles[relPath] = stale;
    }
    final relPaths = staleFiles.keys.toList()..sort();
    final totalStale =
        staleFiles.values.fold<int>(0, (sum, list) => sum + list.length);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, theme, totalStale),
          if (relPaths.isEmpty)
            _buildEmpty(theme)
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: relPaths.length,
                itemBuilder: (context, index) {
                  final relPath = relPaths[index];
                  return _FileGroup(
                    relPath: relPath,
                    projectPath: projectPath,
                    stale: staleFiles[relPath]!,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, int totalStale) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Icon(Icons.translate,
              size: 16,
              color: totalStale > 0
                  ? theme.colorScheme.tertiary
                  : theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            totalStale > 0
                ? 'Translations out of date ($totalStale)'
                : 'Translations up to date',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
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
          Icon(Icons.check_circle_outline,
              size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Every translation is in sync with its freshest sibling.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

/// One file's group of stale translations with a "mark all" header action.
class _FileGroup extends ConsumerWidget {
  final String relPath;
  final String? projectPath;
  final List<({String blockId, String lang})> stale;

  const _FileGroup({
    required this.relPath,
    required this.projectPath,
    required this.stale,
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
              Icon(Icons.description_outlined,
                  size: 14, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  p.basename(relPath),
                  style: theme.textTheme.labelMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () => ref
                    .read(translationStateProvider.notifier)
                    .markAllReviewedAction(relPath),
                child: const Text('Mark all up to date'),
              ),
            ],
          ),
        ),
        for (final entry in stale)
          _StaleRow(relPath: relPath, projectPath: projectPath, entry: entry),
      ],
    );
  }
}

class _StaleRow extends ConsumerWidget {
  final String relPath;
  final String? projectPath;
  final ({String blockId, String lang}) entry;

  const _StaleRow({
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                entry.lang,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onTertiaryContainer),
              ),
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
