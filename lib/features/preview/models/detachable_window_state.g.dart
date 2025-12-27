// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detachable_window_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DetachableWindowState _$DetachableWindowStateFromJson(
  Map<String, dynamic> json,
) => _DetachableWindowState(
  isDetached: json['isDetached'] as bool? ?? false,
  selectedLanguage: json['selectedLanguage'] as String?,
  pdfPath: json['pdfPath'] as String?,
  isCompiling: json['isCompiling'] as bool? ?? false,
  isGridMode: json['isGridMode'] as bool? ?? false,
);

Map<String, dynamic> _$DetachableWindowStateToJson(
  _DetachableWindowState instance,
) => <String, dynamic>{
  'isDetached': instance.isDetached,
  'selectedLanguage': instance.selectedLanguage,
  'pdfPath': instance.pdfPath,
  'isCompiling': instance.isCompiling,
  'isGridMode': instance.isGridMode,
};
