import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/editor_tab.dart';
import '../services/editor_service.dart';
import 'highlighted_code_editor.dart';

/// Tab bar widget for managing multiple open files
class EditorTabs extends ConsumerWidget {
  const EditorTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProvider);

    if (editorState.tabs.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        _buildTabBar(context, ref, editorState.tabs, editorState.activeTabIndex),
        Expanded(
          child: _buildActiveEditor(context, ref, editorState.activeTab),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No file open',
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            'Open a .typ file from the project tree',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(
    BuildContext context,
    WidgetRef ref,
    List<EditorTab> tabs,
    int? activeIndex,
  ) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          return _TabItem(
            tab: tabs[index],
            isActive: index == activeIndex,
            onTap: () => ref.read(editorProvider.notifier).setActiveTab(index),
            onClose: () => _handleCloseTab(context, ref, index, tabs[index]),
          );
        },
      ),
    );
  }

  Widget _buildActiveEditor(BuildContext context, WidgetRef ref, EditorTab? activeTab) {
    if (activeTab == null) {
      return _buildEmptyState(context);
    }

    return HighlightedCodeEditor(
      key: ValueKey(activeTab.filePath),
      initialContent: activeTab.content,
      filePath: activeTab.filePath,
      onChanged: (content) {
        final state = ref.read(editorProvider);
        final tabIndex = state.tabs.indexWhere((tab) => tab.filePath == activeTab.filePath);
        if (tabIndex != -1) {
          ref.read(editorProvider.notifier).updateTabContent(tabIndex, content);
        }
      },
    );
  }

  Future<void> _handleCloseTab(
    BuildContext context,
    WidgetRef ref,
    int index,
    EditorTab tab,
  ) async {
    if (tab.isDirty) {
      final confirmed = await _showUnsavedChangesDialog(context, tab.fileName);
      if (confirmed == null || !confirmed) {
        return;
      }
    }

    ref.read(editorProvider.notifier).closeTab(index);
  }

  Future<bool?> _showUnsavedChangesDialog(BuildContext context, String fileName) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: Text('Do you want to close "$fileName" without saving changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Close Without Saving'),
          ),
        ],
      ),
    );
  }
}

/// Individual tab item in the tab bar
class _TabItem extends StatefulWidget {
  final EditorTab tab;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _TabItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  @override
  State<_TabItem> createState() => _TabItemState();
}

class _TabItemState extends State<_TabItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 120, maxWidth: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: widget.isActive
                ? Theme.of(context).colorScheme.surface
                : _isHovered
                    ? Theme.of(context).colorScheme.surfaceContainerHigh
                    : Colors.transparent,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // File icon
              Icon(
                Icons.description,
                size: 16,
                color: widget.isActive
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
              const SizedBox(width: 8),
              // File name
              Expanded(
                child: Text(
                  widget.tab.fileName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: widget.isActive ? FontWeight.w600 : null,
                        color: widget.isActive
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.grey[700],
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Dirty indicator / Close button
              if (widget.tab.isDirty && !_isHovered)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                )
              else if (_isHovered)
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  onPressed: widget.onClose,
                  tooltip: 'Close',
                )
              else
                const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}
