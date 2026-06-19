import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_item.freezed.dart';
part 'todo_item.g.dart';

/// A single TODO note found in `.typ` source.
///
/// Markers are Typst line comments: `// todo: message` (general) or
/// `// todo(user): message` (assigned). [user] is the assignee (null when
/// general), [line] is 1-based for editor navigation, and [blockId]/[lang]
/// locate the marker inside a multilingual `#let` block — both null when the
/// marker sits outside any language block (document-level).
@freezed
sealed class TodoItem with _$TodoItem {
  const factory TodoItem({
    required int line,
    @Default('') String message,
    String? user,
    String? blockId,
    String? lang,
  }) = _TodoItem;

  factory TodoItem.fromJson(Map<String, dynamic> json) =>
      _$TodoItemFromJson(json);
}
