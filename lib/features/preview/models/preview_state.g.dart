// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preview_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PreviewState _$PreviewStateFromJson(Map<String, dynamic> json) =>
    _PreviewState(
      pdfPath: json['pdfPath'] as String?,
      isLoading: json['isLoading'] as bool? ?? false,
      error: json['error'] as String?,
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      zoom: (json['zoom'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$PreviewStateToJson(_PreviewState instance) =>
    <String, dynamic>{
      'pdfPath': instance.pdfPath,
      'isLoading': instance.isLoading,
      'error': instance.error,
      'currentPage': instance.currentPage,
      'totalPages': instance.totalPages,
      'zoom': instance.zoom,
    };
