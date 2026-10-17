import 'dart:developer' as developer;
import 'dart:io';
import '../../../core/utils/path_validator.dart';
import '../models/file_tree_node.dart';

/// Service for file system operations and directory traversal
class FileSystemService {
  /// Maximum depth for directory traversal to prevent infinite loops
  static const int _maxDepth = 20;

  /// Maximum entries to load to prevent memory exhaustion
  static const int _maxEntries = 5000;

  /// Track total entries loaded for limiting
  int _entriesLoaded = 0;

  /// Current project root for boundary checking
  String? _currentProjectRoot;

  /// Load the file tree for a project directory
  ///
  /// Returns an empty list if the path is invalid or inaccessible.
  /// Logs errors for debugging instead of silently swallowing them.
  Future<List<FileTreeNode>> loadProjectTree(String projectPath) async {
    _entriesLoaded = 0;

    try {
      // Validate and sanitize the project path
      final sanitizedPath = PathValidator.sanitizeProjectPath(projectPath);

      final projectDir = Directory(sanitizedPath);
      if (!await projectDir.exists()) {
        developer.log(
          'Project directory does not exist: $sanitizedPath',
          name: 'FileSystemService',
        );
        return [];
      }

      // Store project root for boundary checking in expandNode
      _currentProjectRoot = sanitizedPath;

      final rootNodes = await _loadDirectoryContents(
        projectDir,
        0,
        sanitizedPath,
      );
      return rootNodes;
    } catch (e, stackTrace) {
      developer.log(
        'Error loading project tree: $e',
        name: 'FileSystemService',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Load contents of a directory at given depth
  ///
  /// [projectRoot] is used for boundary checking to prevent traversal attacks.
  Future<List<FileTreeNode>> _loadDirectoryContents(
    Directory dir,
    int depth,
    String projectRoot,
  ) async {
    final nodes = <FileTreeNode>[];

    // Prevent infinite recursion
    if (depth > _maxDepth) {
      developer.log(
        'Maximum directory depth exceeded at: ${dir.path}',
        name: 'FileSystemService',
      );
      return nodes;
    }

    // Prevent memory exhaustion
    if (_entriesLoaded >= _maxEntries) {
      developer.log(
        'Maximum entry count reached ($_maxEntries)',
        name: 'FileSystemService',
      );
      return nodes;
    }

    try {
      // Validate directory is within project boundary
      if (!PathValidator.isWithinBoundary(dir.path, projectRoot)) {
        developer.log(
          'Directory outside project boundary: ${dir.path}',
          name: 'FileSystemService',
        );
        return nodes;
      }

      final entities = await dir.list().toList();

      // Sort: directories first, then files, alphabetically within each group
      entities.sort((a, b) {
        final aIsDir = a is Directory;
        final bIsDir = b is Directory;

        if (aIsDir != bIsDir) {
          return aIsDir ? -1 : 1;
        }

        final aName = a.uri.pathSegments.lastWhere((s) => s.isNotEmpty);
        final bName = b.uri.pathSegments.lastWhere((s) => s.isNotEmpty);
        return aName.toLowerCase().compareTo(bName.toLowerCase());
      });

      for (final entity in entities) {
        // Check entry limit
        if (_entriesLoaded >= _maxEntries) break;

        final node = FileTreeNode.fromEntity(entity, depth);

        // Skip invisible nodes
        if (!node.isVisible) continue;

        _entriesLoaded++;

        // Auto-expand first level directories (lazy load deeper levels)
        if (node.isDirectory && depth == 0) {
          node.isExpanded = true;
          node.children = await _loadDirectoryContents(
            entity as Directory,
            depth + 1,
            projectRoot,
          );
        }

        nodes.add(node);
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error loading directory ${dir.path}: $e',
        name: 'FileSystemService',
        error: e,
        stackTrace: stackTrace,
      );
    }

    return nodes;
  }

  /// Expand a directory node by loading its children
  ///
  /// Uses the project root from the last [loadProjectTree] call for boundary checking.
  Future<void> expandNode(FileTreeNode node) async {
    if (!node.isDirectory || node.isExpanded) return;

    final projectRoot = _currentProjectRoot;
    if (projectRoot == null) {
      developer.log(
        'Cannot expand node: no project root set',
        name: 'FileSystemService',
      );
      return;
    }

    try {
      // Validate node path is within project boundary
      if (!PathValidator.isWithinBoundary(node.path, projectRoot)) {
        developer.log(
          'Cannot expand node outside project boundary: ${node.path}',
          name: 'FileSystemService',
        );
        return;
      }

      final dir = Directory(node.path);
      node.children = await _loadDirectoryContents(
        dir,
        node.depth + 1,
        projectRoot,
      );
      node.isExpanded = true;
    } catch (e, stackTrace) {
      developer.log(
        'Error expanding node ${node.path}: $e',
        name: 'FileSystemService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Collapse a directory node
  void collapseNode(FileTreeNode node) {
    if (!node.isDirectory) return;
    node.isExpanded = false;
  }

  /// Toggle expand/collapse state of a directory node
  Future<void> toggleNode(FileTreeNode node) async {
    if (!node.isDirectory) return;

    if (node.isExpanded) {
      collapseNode(node);
    } else {
      await expandNode(node);
    }
  }

  /// Refresh the entire tree
  Future<List<FileTreeNode>> refreshTree(String projectPath) async {
    return loadProjectTree(projectPath);
  }
}
