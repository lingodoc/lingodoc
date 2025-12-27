import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../models/file_tree_node.dart';
import '../services/project_state.dart';
import '../../editor/services/editor_service.dart';

/// Project tree widget for navigating files and folders
class ProjectTree extends ConsumerWidget {
  const ProjectTree({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectState = ref.watch(projectTreeProvider);

    if (projectState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
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
              Text(
                'Error',
                style: Theme.of(context).textTheme.titleMedium,
              ),
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _openProject(ref),
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: _buildTreeNodes(context, ref, projectState.nodes, projectState.selectedFilePath),
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
      widgets.add(_TreeNodeWidget(
        node: node,
        isSelected: node.path == selectedPath,
        onTap: () => _onNodeTap(ref, node),
        onToggle: () => _onNodeToggle(ref, node),
      ));

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

  Future<void> _openProject(WidgetRef ref) async {
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

  const _TreeNodeWidget({
    required this.node,
    required this.isSelected,
    required this.onTap,
    required this.onToggle,
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
                        fontWeight:
                            widget.node.isConfigFile ? FontWeight.w600 : null,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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
