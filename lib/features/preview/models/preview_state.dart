import 'package:freezed_annotation/freezed_annotation.dart';

part 'preview_state.freezed.dart';
part 'preview_state.g.dart';

/// State model for PDF preview panel
@freezed
sealed class PreviewState with _$PreviewState {
  const PreviewState._();  // Private constructor for Freezed

  const factory PreviewState({
    /// Currently displayed PDF file path
    String? pdfPath,

    /// Whether preview is currently loading
    @Default(false) bool isLoading,

    /// Error message if preview failed
    String? error,

    /// Current page number (1-indexed)
    @Default(1) int currentPage,

    /// Total number of pages
    @Default(0) int totalPages,

    /// Current zoom level (1.0 = 100%)
    @Default(1.0) double zoom,
  }) = _PreviewState;

  /// Create PreviewState from JSON
  factory PreviewState.fromJson(Map<String, dynamic> json) =>
      _$PreviewStateFromJson(json);
}
