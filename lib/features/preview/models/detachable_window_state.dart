import 'package:freezed_annotation/freezed_annotation.dart';

part 'detachable_window_state.freezed.dart';
part 'detachable_window_state.g.dart';

/// State for detachable preview window
@freezed
sealed class DetachableWindowState with _$DetachableWindowState {
  const DetachableWindowState._(); // Private constructor for Freezed

  const factory DetachableWindowState({
    /// Whether the preview is currently detached
    @Default(false) bool isDetached,

    /// The selected language for the detached preview
    String? selectedLanguage,

    /// Current PDF path being displayed
    String? pdfPath,

    /// Whether compilation is in progress
    @Default(false) bool isCompiling,

    /// Whether grid mode is enabled
    @Default(false) bool isGridMode,
  }) = _DetachableWindowState;

  factory DetachableWindowState.fromJson(Map<String, dynamic> json) =>
      _$DetachableWindowStateFromJson(json);
}
