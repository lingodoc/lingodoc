import 'package:freezed_annotation/freezed_annotation.dart';

part 'compilation_result.freezed.dart';
part 'compilation_result.g.dart';

/// Result of a Typst compilation operation
@freezed
sealed class CompilationResult with _$CompilationResult {
  const CompilationResult._();  // Private constructor for custom methods

  const factory CompilationResult.success({
    required String pdfPath,
    String? languageCode,
    required DateTime compiledAt,
  }) = _CompilationSuccess;

  const factory CompilationResult.error({
    required String message,
    String? languageCode,
    String? stderr,
    int? exitCode,
  }) = _CompilationError;

  factory CompilationResult.fromJson(Map<String, dynamic> json) =>
      _$CompilationResultFromJson(json);
}
