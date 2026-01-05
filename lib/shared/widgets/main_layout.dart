import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split_view/split_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../../features/project/widgets/project_tree.dart';
import '../../features/project/widgets/new_project_wizard.dart';
import '../../features/project/services/project_state.dart';
import '../../features/editor/widgets/editor_tabs.dart';
import '../../features/editor/services/editor_service.dart';
import '../../features/preview/widgets/preview_panel.dart';
import '../../features/preview/services/detachable_window_service.dart';
import '../../features/editor/services/search_provider.dart';

/// Intent for save action
class SaveIntent extends Intent {
  const SaveIntent();
}

/// Main application layout with 3-panel split view:
/// - Left: Project tree navigation
/// - Center: Code editor
/// - Right: PDF preview panel
class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  late SplitViewController _splitController;
  bool _lastDetachedState = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controller with 3-panel layout (default)
    _splitController = SplitViewController(
      weights: [0.2, 0.4, 0.4],
      limits: [
        WeightLimit(min: 0.15, max: 0.30),
        WeightLimit(min: 0.30, max: 0.50),
        WeightLimit(min: 0.30, max: 0.50),
      ],
    );
    
    // Auto-load sample project and open chapter 04
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoLoadSampleProject();
    });
  }

  @override
  void dispose() {
    _splitController.dispose();
    super.dispose();
  }

  /// Auto-load the sample project and open chapter 04
  Future<void> _autoLoadSampleProject() async {
    try {
      // Get the current directory and look for sample-project
      final currentDir = Directory.current.path;
      final sampleProjectPath = p.join(currentDir, 'sample-project');

      // Check if sample project exists
      if (await Directory(sampleProjectPath).exists()) {
        // Load the project
        await ref.read(projectTreeProvider.notifier).loadProject(sampleProjectPath);

        // Wait a bit for the project to load
        await Future.delayed(const Duration(milliseconds: 500));

        // Open chapter 04
        final chapter04Path = p.join(sampleProjectPath, 'chapters', '04-master-clock-screens.typ');
        if (await File(chapter04Path).exists()) {
          await ref.read(editorProvider.notifier).openFile(chapter04Path);
        }
      }
    } catch (e) {
      debugPrint('Failed to auto-load sample project: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch detachable window state to hide preview when detached
    final isPreviewDetached = ref.watch(
      detachableWindowProvider.select((state) => state.isDetached),
    );

    // Update controller when detached state changes
    if (isPreviewDetached != _lastDetachedState) {
      _lastDetachedState = isPreviewDetached;
      
      // Dispose old controller and create new one with correct panel count
      _splitController.dispose();
      
      if (isPreviewDetached) {
        // 2-panel layout: recalculate weights to maintain proportions
        // When going from 3 panels to 2, redistribute the preview space to editor
        _splitController = SplitViewController(
          weights: [0.25, 0.75], // 25% tree, 75% editor
          limits: [
            WeightLimit(min: 0.15, max: 0.35), // Tree: 15-35%
            WeightLimit(min: 0.65, max: 0.85), // Editor: 65-85%
          ],
        );
      } else {
        // 3-panel layout: restore original distribution
        _splitController = SplitViewController(
          weights: [0.2, 0.4, 0.4], // 20% tree, 40% editor, 40% preview
          limits: [
            WeightLimit(min: 0.15, max: 0.30), // Tree: 15-30%
            WeightLimit(min: 0.30, max: 0.50), // Editor: 30-50%
            WeightLimit(min: 0.30, max: 0.50), // Preview: 30-50%
          ],
        );
      }
    }

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
            const SaveIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          SaveIntent: CallbackAction<SaveIntent>(
            onInvoke: (_) {
              _handleSave();
              return null;
            },
          ),
        },
        child: Scaffold(
          appBar: _buildMenuBar(context),
          body: SplitView(
        key: ValueKey('split-view-${isPreviewDetached ? "2-panel" : "3-panel"}'),
        viewMode: SplitViewMode.Horizontal,
        indicator: const SplitIndicator(
          viewMode: SplitViewMode.Horizontal,
          color: Colors.grey,
        ),
        activeIndicator: const SplitIndicator(
          viewMode: SplitViewMode.Horizontal,
          color: Colors.blueAccent,
          isActive: true,
        ),
        controller: _splitController,
        children: isPreviewDetached
            ? [
                // 2-panel layout: Tree + Editor only
                _buildProjectPanel(),
                _buildEditorPanel(),
              ]
            : [
                // 3-panel layout: Tree + Editor + Preview
                _buildProjectPanel(),
                _buildEditorPanel(),
                _buildPreviewPanel(),
              ],
          ),
        ),
      ),
    );
  }

  /// Menu bar with File, Edit, View, Help menus
  PreferredSizeWidget _buildMenuBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(40),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            _MenuBarItem(
              label: 'File',
              items: [
                _MenuItem(
                  label: 'New Project...',
                  icon: Icons.create_new_folder,
                  shortcut: 'Ctrl+Shift+N',
                  onTap: () => _handleNewProject(),
                ),
                _MenuItem(
                  label: 'Open Project...',
                  icon: Icons.folder_open,
                  shortcut: 'Ctrl+O',
                  onTap: () => _handleOpenProject(),
                ),
                const _MenuDivider(),
                _MenuItem(
                  label: 'New Chapter...',
                  icon: Icons.note_add,
                  shortcut: 'Ctrl+N',
                  onTap: () {}, // TODO: Step 5
                ),
                _MenuItem(
                  label: 'Save',
                  icon: Icons.save,
                  shortcut: 'Ctrl+S',
                  onTap: _handleSave,
                ),
                const _MenuDivider(),
                _MenuItem(
                  label: 'Exit',
                  icon: Icons.exit_to_app,
                  shortcut: 'Ctrl+Q',
                  onTap: () => _handleExit(),
                ),
              ],
            ),
            _MenuBarItem(
              label: 'Edit',
              items: [
                _MenuItem(
                  label: 'Undo',
                  icon: Icons.undo,
                  shortcut: 'Ctrl+Z',
                  onTap: () {}, // TODO: Step 6
                ),
                _MenuItem(
                  label: 'Redo',
                  icon: Icons.redo,
                  shortcut: 'Ctrl+Y',
                  onTap: () {}, // TODO: Step 6
                ),
                const _MenuDivider(),
                _MenuItem(
                  label: 'Find...',
                  icon: Icons.search,
                  shortcut: 'Ctrl+F',
                  onTap: () => ref.read(searchProvider.notifier).toggle(),
                ),
                _MenuItem(
                  label: 'Replace...',
                  icon: Icons.find_replace,
                  shortcut: 'Ctrl+H',
                  onTap: () {}, // TODO: Step 12
                ),
              ],
            ),
            _MenuBarItem(
              label: 'View',
              items: [
                _MenuItem(
                  label: 'Compile & Preview',
                  icon: Icons.play_arrow,
                  shortcut: 'F5',
                  onTap: () {}, // TODO: Step 8
                ),
                _MenuItem(
                  label: 'Refresh Preview',
                  icon: Icons.refresh,
                  shortcut: 'Ctrl+R',
                  onTap: () {}, // TODO: Step 9
                ),
                const _MenuDivider(),
                _MenuItem(
                  label: 'Detach Preview',
                  icon: Icons.open_in_new,
                  shortcut: 'Ctrl+D',
                  onTap: () {}, // TODO: Step 14
                ),
              ],
            ),
            _MenuBarItem(
              label: 'Help',
              items: [
                _MenuItem(
                  label: 'Documentation',
                  icon: Icons.help_outline,
                  onTap: () {}, // TODO: External link
                ),
                _MenuItem(
                  label: 'About LingoDoc',
                  icon: Icons.info_outline,
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectPanel() {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            title: 'Project',
            icon: Icons.folder,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                tooltip: 'Refresh',
                onPressed: () => _handleRefreshProject(),
              ),
            ],
          ),
          const Expanded(
            child: ProjectTree(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorPanel() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            title: 'Editor',
            icon: Icons.edit,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, size: 18),
                tooltip: 'Editor Settings',
                onPressed: () {}, // TODO: Step 15
              ),
            ],
          ),
          const Expanded(
            child: EditorTabs(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewPanel() {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            title: 'Preview',
            icon: Icons.preview,
            actions: [
              IconButton(
                icon: const Icon(Icons.grid_view, size: 18),
                tooltip: 'Language Grid',
                onPressed: () {}, // TODO: Step 10
              ),
              IconButton(
                icon: const Icon(Icons.open_in_new, size: 18),
                tooltip: 'Detach Window',
                onPressed: () {}, // TODO: Step 14
              ),
            ],
          ),
          const Expanded(
            child: PreviewPanel(),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNewProject() async {
    final projectPath = await showDialog<String>(
      context: context,
      builder: (context) => const NewProjectWizard(),
    );

    if (projectPath != null && mounted) {
      // Load the newly created project
      await ref.read(projectTreeProvider.notifier).loadProject(projectPath);
    }
  }

  Future<void> _handleOpenProject() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select LingoDoc Project Folder',
    );

    if (result != null && mounted) {
      await ref.read(projectTreeProvider.notifier).loadProject(result);
    }
  }

  void _handleRefreshProject() {
    ref.read(projectTreeProvider.notifier).refresh();
  }

  Future<void> _handleSave() async {
    final editorState = ref.read(editorProvider);
    final activeIndex = editorState.activeTabIndex;

    if (activeIndex != null) {
      await ref.read(editorProvider.notifier).saveTab(activeIndex);
      debugPrint('✅ Saved active tab');
    }
  }

  void _handleExit() {
    // TODO: Add unsaved changes check
    Navigator.of(context).pop();
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'LingoDoc',
      applicationVersion: '0.1.0',
      applicationIcon: const Icon(Icons.description, size: 48),
      children: [
        const Text(
          'A cross-platform desktop application for authoring '
          'multilingual technical documentation using Typst.',
        ),
      ],
    );
  }
}

/// Panel header with title and action buttons
class _PanelHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> actions;

  const _PanelHeader({
    required this.title,
    required this.icon,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          ...actions,
        ],
      ),
    );
  }
}

/// Menu bar item with dropdown menu
class _MenuBarItem extends StatefulWidget {
  final String label;
  final List<Widget> items;

  const _MenuBarItem({
    required this.label,
    required this.items,
  });

  @override
  State<_MenuBarItem> createState() => _MenuBarItemState();
}

class _MenuBarItemState extends State<_MenuBarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      offset: const Offset(0, 40),
      itemBuilder: (context) => widget.items
          .map((item) => PopupMenuItem<void>(
                height: item is _MenuDivider ? 8 : 40,
                padding: EdgeInsets.zero,
                child: item,
              ))
          .toList(),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: _isHovered
              ? Theme.of(context).colorScheme.surfaceContainerHigh
              : Colors.transparent,
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}

/// Menu item with icon, label, and keyboard shortcut
class _MenuItem extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? shortcut;
  final VoidCallback onTap;

  const _MenuItem({
    required this.label,
    this.icon,
    this.shortcut,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 12),
            ],
            Text(label),
            const Spacer(),
            if (shortcut != null)
              Text(
                shortcut!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Menu divider
class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1);
  }
}
