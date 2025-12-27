import 'package:flutter/foundation.dart';

/// Represents an open file tab in the editor
@immutable
class EditorTab {
  final String filePath;
  final String fileName;
  final String content;
  final bool isDirty;
  final bool isActive;

  const EditorTab({
    required this.filePath,
    required this.fileName,
    required this.content,
    this.isDirty = false,
    this.isActive = false,
  });

  EditorTab copyWith({
    String? filePath,
    String? fileName,
    String? content,
    bool? isDirty,
    bool? isActive,
  }) {
    return EditorTab(
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      content: content ?? this.content,
      isDirty: isDirty ?? this.isDirty,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EditorTab &&
          runtimeType == other.runtimeType &&
          filePath == other.filePath;

  @override
  int get hashCode => filePath.hashCode;
}
