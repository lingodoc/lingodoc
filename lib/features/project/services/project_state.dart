import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'file_system_service.dart';
import '../models/file_tree_node.dart';

/// State class for project tree
@immutable
class ProjectTreeState {
  final String? projectPath;
  final List<FileTreeNode> nodes;
  final String? selectedFilePath;
  final bool isLoading;
  final String? error;

  const ProjectTreeState({
    this.projectPath,
    this.nodes = const [],
    this.selectedFilePath,
    this.isLoading = false,
    this.error,
  });

  ProjectTreeState copyWith({
    String? projectPath,
    List<FileTreeNode>? nodes,
    String? selectedFilePath,
    bool? isLoading,
    String? error,
  }) {
    return ProjectTreeState(
      projectPath: projectPath ?? this.projectPath,
      nodes: nodes ?? this.nodes,
      selectedFilePath: selectedFilePath ?? this.selectedFilePath,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing project tree state
class ProjectTreeNotifier extends Notifier<ProjectTreeState> {
  late final FileSystemService _fileSystemService;

  @override
  ProjectTreeState build() {
    _fileSystemService = ref.read(fileSystemServiceProvider);
    return const ProjectTreeState();
  }

  /// Load a project directory
  Future<void> loadProject(String projectPath) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final nodes = await _fileSystemService.loadProjectTree(projectPath);
      state = ProjectTreeState(
        projectPath: projectPath,
        nodes: nodes,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load project: $e',
      );
    }
  }

  /// Toggle expand/collapse of a directory node
  Future<void> toggleNode(FileTreeNode node) async {
    await _fileSystemService.toggleNode(node);
    // Trigger rebuild by updating state
    state = ProjectTreeState(
      projectPath: state.projectPath,
      nodes: List.from(state.nodes),
      selectedFilePath: state.selectedFilePath,
    );
  }

  /// Select a file in the tree
  void selectFile(String? filePath) {
    state = state.copyWith(selectedFilePath: filePath);
  }

  /// Refresh the project tree
  Future<void> refresh() async {
    if (state.projectPath == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final nodes = await _fileSystemService.refreshTree(state.projectPath!);
      state = ProjectTreeState(
        projectPath: state.projectPath,
        nodes: nodes,
        selectedFilePath: state.selectedFilePath,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to refresh: $e',
      );
    }
  }

  /// Close the current project
  void closeProject() {
    state = const ProjectTreeState();
  }
}

/// Provider for file system service
final fileSystemServiceProvider = Provider<FileSystemService>((ref) {
  return FileSystemService();
});

/// Provider for project tree state
final projectTreeProvider =
    NotifierProvider<ProjectTreeNotifier, ProjectTreeState>(ProjectTreeNotifier.new);
