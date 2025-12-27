// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compilation_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CompilationSuccess _$CompilationSuccessFromJson(Map<String, dynamic> json) =>
    _CompilationSuccess(
      pdfPath: json['pdfPath'] as String,
      languageCode: json['languageCode'] as String?,
      compiledAt: DateTime.parse(json['compiledAt'] as String),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$CompilationSuccessToJson(_CompilationSuccess instance) =>
    <String, dynamic>{
      'pdfPath': instance.pdfPath,
      'languageCode': instance.languageCode,
      'compiledAt': instance.compiledAt.toIso8601String(),
      'runtimeType': instance.$type,
    };

_CompilationError _$CompilationErrorFromJson(Map<String, dynamic> json) =>
    _CompilationError(
      message: json['message'] as String,
      languageCode: json['languageCode'] as String?,
      stderr: json['stderr'] as String?,
      exitCode: (json['exitCode'] as num?)?.toInt(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$CompilationErrorToJson(_CompilationError instance) =>
    <String, dynamic>{
      'message': instance.message,
      'languageCode': instance.languageCode,
      'stderr': instance.stderr,
      'exitCode': instance.exitCode,
      'runtimeType': instance.$type,
    };
