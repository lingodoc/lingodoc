import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../models/file_tree_node.dart';
import '../services/project_state.dart';
import '../../editor/services/editor_service.dart';
import '../../editor/services/chapter_split_service.dart';
import 'chapter_split_dialog.dart';

/// Project tree widget for navigating files and folders
class ProjectTree extends ConsumerWidget {
  const ProjectTree({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectState = ref.watch(projectTreeProvider);

    if (projectState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (projectState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                projectState.error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    if (projectState.projectPath == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.folder_open, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No project open',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _openProject(ref, context),
                icon: const Icon(Icons.folder_open),
                label: const Text('Open Project'),
              ),
            ],
          ),
        ),
      );
    }

    if (projectState.nodes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.folder, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Empty project',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: _buildTreeNodes(
        context,
        ref,
        projectState.nodes,
        projectState.selectedFilePath,
      ),
    );
  }

  List<Widget> _buildTreeNodes(
    BuildContext context,
    WidgetRef ref,
    List<FileTreeNode> nodes,
    String? selectedPath,
  ) {
    final widgets = <Widget>[];

    for (final node in nodes) {
      widgets.add(
        _TreeNodeWidget(
          node: node,
          isSelected: node.path == selectedPath,
          onTap: () => _onNodeTap(ref, node),
          onToggle: () => _onNodeToggle(ref, node),
          onSecondaryTap: (pos) => _onNodeSecondaryTap(context, ref, node, pos),
        ),
      );

      // Add children if expanded
      if (node.isExpanded && node.children.isNotEmpty) {
        widgets.addAll(
          _buildTreeNodes(context, ref, node.children, selectedPath),
        );
      }
    }

    return widgets;
  }

  void _onNodeTap(WidgetRef ref, FileTreeNode node) {
    if (node.isDirectory) {
      _onNodeToggle(ref, node);
    } else {
      // Select the file
      ref.read(projectTreeProvider.notifier).selectFile(node.path);
      // Open file in editor
      ref.read(editorProvider.notifier).openFile(node.path);
    }
  }

  void _onNodeToggle(WidgetRef ref, FileTreeNode node) {
    if (!node.isDirectory) return;
    ref.read(projectTreeProvider.notifier).toggleNode(node);
  }

  bool _isChapterFile(FileTreeNode node) =>
      node.isTypstFile && p.split(p.dirname(node.path)).contains('chapters');

  /// Right-click a chapter file → offer "Split chapter…".
  Future<void> _onNodeSecondaryTap(
    BuildContext context,
    WidgetRef ref,
    FileTreeNode node,
    Offset pos,
  ) async {
    if (!_isChapterFile(node)) return;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        pos & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: const [
        PopupMenuItem<String>(
          value: 'split',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.call_split, size: 18),
            title: Text('Split chapter…'),
          ),
        ),
      ],
    );
    if (selected == 'split' && context.mounted) {
      await _showSplitDialog(context, ref, node);
    }
  }

  Future<void> _showSplitDialog(
    BuildContext context,
    WidgetRef ref,
    FileTreeNode node,
  ) async {
    final svc = ChapterSplitService();
    final content = await File(node.path).readAsString();
    final sections = svc.listSections(content);
    if (!context.mounted) return;
    if (sections.length < 2) {
      _snack(context, 'No subsections to split at in this chapter.');
      return;
    }

    final prefix =
        RegExp(
          r'^\d+[a-z]?',
        ).firstMatch(p.basenameWithoutExtension(node.path))?.group(0) ??
        '';
    final selection = await showDialog<Map<int, String>>(
      context: context,
      builder: (_) =>
          ChapterSplitDialog(sections: sections, filePrefix: prefix),
    );
    if (selection == null || selection.isEmpty) return;

    final projectPath = ref.read(projectTreeProvider).projectPath;
    if (projectPath == null) return;

    final plan = svc.computeMultiSplit(content, selection.keys.toSet());
    if (!plan.ok) {
      if (context.mounted) _snack(context, plan.reason ?? 'Cannot split.');
      return;
    }

    // Align filenames to plan.parts (both ordered by ascending boundary line).
    final sortedLines = selection.keys.toList()..sort();
    final files = <({String fileName, String content})>[
      for (var i = 0; i < sortedLines.length; i++)
        (fileName: selection[sortedLines[i]]!, content: plan.parts[i].content),
    ];

    try {
      final result = await svc.applyMultiSplit(
        projectPath: projectPath,
        currentFilePath: node.path,
        files: files,
        plan: plan,
      );
      // Keep an open tab for the original in sync with the shortened file.
      final tabs = ref.read(editorProvider).tabs;
      final idx = tabs.indexWhere((t) => t.filePath == node.path);
      if (idx != -1) {
        ref.read(editorProvider.notifier).updateTabContent(idx, plan.head);
      }
      await ref.read(projectTreeProvider.notifier).refresh();
      if (context.mounted) {
        _snack(
          context,
          result.includeUpdated
              ? 'Split into ${files.length} file'
                    '${files.length == 1 ? '' : 's'}.'
              : 'Created ${files.length} files — add their #include lines to '
                    'main.typ manually (the original include was not found).',
        );
      }
    } catch (e) {
      if (context.mounted) {
        _snack(
          context,
          e is ArgumentError ? '${e.message}' : 'Split failed: $e',
        );
      }
    }
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 5)),
    );
  }

  Future<void> _openProject(WidgetRef ref, BuildContext context) async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Open Project Folder'),
        content: const Text(
          'Select the folder that contains your LingoDoc project.\n\n'
          'The folder must contain a config.toml file that declares the '
          'languages and project settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Choose Folder…'),
          ),
        ],
      ),
    );

    if (proceed != true) return;

    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select LingoDoc Project Folder',
    );

    if (result != null) {
      await ref.read(projectTreeProvider.notifier).loadProject(result);
    }
  }
}

/// Individual tree node widget
class _TreeNodeWidget extends StatefulWidget {
  final FileTreeNode node;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final void Function(Offset globalPosition)? onSecondaryTap;

  const _TreeNodeWidget({
    required this.node,
    required this.isSelected,
    required this.onTap,
    required this.onToggle,
    this.onSecondaryTap,
  });

  @override
  State<_TreeNodeWidget> createState() => _TreeNodeWidgetState();
}

class _TreeNodeWidgetState extends State<_TreeNodeWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final indent = widget.node.depth * 16.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onSecondaryTapDown: widget.onSecondaryTap == null
            ? null
            : (d) => widget.onSecondaryTap!(d.globalPosition),
        child: InkWell(
          onTap: widget.onTap,
          child: Container(
            height: 32,
            padding: EdgeInsets.only(left: indent + 8, right: 8),
            color: widget.isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : _isHovered
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Colors.transparent,
            child: Row(
              children: [
                // Expand/collapse icon for directories
                if (widget.node.isDirectory)
                  GestureDetector(
                    onTap: widget.onToggle,
                    child: Icon(
                      widget.node.isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      size: 18,
                    ),
                  )
                else
                  const SizedBox(width: 18),
                const SizedBox(width: 4),
                // File/folder icon
                Icon(
                  _getIcon(),
                  size: 18,
                  color: widget.isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : null,
                ),
                const SizedBox(width: 8),
                // File/folder name
                Expanded(
                  child: Text(
                    widget.node.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: widget.isSelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : null,
                      fontWeight: widget.node.isConfigFile
                          ? FontWeight.w600
                          : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    if (widget.node.isDirectory) {
      return widget.node.isExpanded ? Icons.folder_open : Icons.folder;
    }
    if (widget.node.isTypstFile) return Icons.description;
    if (widget.node.isConfigFile) return Icons.settings;
    return Icons.insert_drive_file;
  }
}
