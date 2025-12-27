import 'dart:io';

/// Represents a node in the file tree (file or directory)
class FileTreeNode {
  final String name;
  final String path;
  final bool isDirectory;
  final int depth;
  bool isExpanded;
  List<FileTreeNode> children;

  FileTreeNode({
    required this.name,
    required this.path,
    required this.isDirectory,
    required this.depth,
    this.isExpanded = false,
    List<FileTreeNode>? children,
  }) : children = children ?? [];

  /// Create a node from a FileSystemEntity
  static FileTreeNode fromEntity(
    FileSystemEntity entity,
    int depth, {
    bool autoExpand = false,
  }) {
    final isDir = entity is Directory;
    return FileTreeNode(
      name: entity.uri.pathSegments.lastWhere((s) => s.isNotEmpty),
      path: entity.path,
      isDirectory: isDir,
      depth: depth,
      isExpanded: autoExpand && isDir,
    );
  }

  /// Check if this is a Typst file
  bool get isTypstFile => !isDirectory && name.endsWith('.typ');

  /// Check if this is a TOML config file
  bool get isConfigFile => !isDirectory && name.endsWith('.toml');

  /// Check if this node should be visible in the tree
  bool get isVisible {
    // Hide hidden files/folders (starting with .)
    if (name.startsWith('.')) return false;

    // Hide build output directories
    if (isDirectory && (name == 'output' || name == 'build')) return false;

    return true;
  }

  /// Get an icon name for this node type
  String get iconName {
    if (isDirectory) {
      return isExpanded ? 'folder_open' : 'folder';
    }
    if (isTypstFile) return 'description';
    if (isConfigFile) return 'settings';
    return 'insert_drive_file';
  }

  @override
  String toString() => 'FileTreeNode($name, depth=$depth, isDir=$isDirectory)';
}
