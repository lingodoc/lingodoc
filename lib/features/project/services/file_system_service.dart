import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/file_tree_node.dart';

/// Service for file system operations and directory traversal
class FileSystemService {
  /// Load the file tree for a project directory
  Future<List<FileTreeNode>> loadProjectTree(String projectPath) async {
    try {
      final projectDir = Directory(projectPath);
      if (!await projectDir.exists()) {
        debugPrint('Project directory does not exist: $projectPath');
        return [];
      }

      final rootNodes = await _loadDirectoryContents(projectDir, 0);
      return rootNodes;
    } catch (e) {
      debugPrint('Error loading project tree: $e');
      return [];
    }
  }

  /// Load contents of a directory at given depth
  Future<List<FileTreeNode>> _loadDirectoryContents(
    Directory dir,
    int depth,
  ) async {
    final nodes = <FileTreeNode>[];

    try {
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
        final node = FileTreeNode.fromEntity(entity, depth);

        // Skip invisible nodes
        if (!node.isVisible) continue;

        // Auto-expand first level directories
        if (node.isDirectory && depth == 0) {
          node.isExpanded = true;
          node.children = await _loadDirectoryContents(
            entity as Directory,
            depth + 1,
          );
        }

        nodes.add(node);
      }
    } catch (e) {
      debugPrint('Error loading directory ${dir.path}: $e');
    }

    return nodes;
  }

  /// Expand a directory node by loading its children
  Future<void> expandNode(FileTreeNode node) async {
    if (!node.isDirectory || node.isExpanded) return;

    try {
      final dir = Directory(node.path);
      node.children = await _loadDirectoryContents(dir, node.depth + 1);
      node.isExpanded = true;
    } catch (e) {
      debugPrint('Error expanding node ${node.path}: $e');
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
