// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TodoItem _$TodoItemFromJson(Map<String, dynamic> json) => _TodoItem(
  line: (json['line'] as num).toInt(),
  message: json['message'] as String? ?? '',
  user: json['user'] as String?,
  blockId: json['blockId'] as String?,
  lang: json['lang'] as String?,
);

Map<String, dynamic> _$TodoItemToJson(_TodoItem instance) => <String, dynamic>{
  'line': instance.line,
  'message': instance.message,
  'user': instance.user,
  'blockId': instance.blockId,
  'lang': instance.lang,
};
