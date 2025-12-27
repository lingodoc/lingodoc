import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import '../models/detachable_window_state.dart';
import '../../project/services/project_state.dart';

/// Provider for detachable window state
final detachableWindowProvider =
    NotifierProvider<DetachableWindowNotifier, DetachableWindowState>(() {
  return DetachableWindowNotifier();
});

/// Notifier for managing detachable window state and lifecycle
class DetachableWindowNotifier extends Notifier<DetachableWindowState> {
  @override
  DetachableWindowState build() => const DetachableWindowState();

  /// Open the preview in a detached window
  Future<void> detach() async {
    if (state.isDetached) return;

    state = state.copyWith(isDetached: true);

    // Create a new window for the detached preview
    _createDetachedWindow();
  }

  /// Close the detached window and reattach to main window
  Future<void> attach() async {
    if (!state.isDetached) return;

    state = state.copyWith(isDetached: false);
  }

  /// Update the selected language
  void setLanguage(String language) {
    state = state.copyWith(selectedLanguage: language);
  }

  /// Update the PDF path
  void setPdfPath(String? path) {
    state = state.copyWith(pdfPath: path);
  }

  /// Set compilation status
  void setCompiling(bool isCompiling) {
    state = state.copyWith(isCompiling: isCompiling);
  }

  /// Toggle grid mode
  void toggleGridMode() {
    state = state.copyWith(isGridMode: !state.isGridMode);
  }

  /// Create a new detached window
  void _createDetachedWindow() {
    // Use platform channels to create a new window
    // This will be handled by the DetachedPreviewWindow widget
    // which uses a new isolate/window context
  }
}

/// Service for managing multi-window functionality
class DetachableWindowService {
  static final DetachableWindowService _instance =
      DetachableWindowService._internal();

  factory DetachableWindowService() => _instance;

  DetachableWindowService._internal();

  /// Track active detached window ID
  int? _detachedWindowId;

  /// Open a detached preview window
  Future<void> openDetachedWindow({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    // Check if window already exists
    if (_detachedWindowId != null) {
      // Focus existing window
      try {
        await DesktopMultiWindow.invokeMethod(_detachedWindowId!, 'focus');
      } catch (e) {
        // Window might have been closed, reset state
        _detachedWindowId = null;
      }
      return;
    }

    try {
      // Get current project path to pass to detached window
      final projectState = ref.read(projectTreeProvider);
      final projectPath = projectState.projectPath;

      if (projectPath == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No project loaded'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Get current state to pass to detached window
      final windowState = ref.read(detachableWindowProvider);

      // Create new window using desktop_multi_window with project path
      final window = await DesktopMultiWindow.createWindow(jsonEncode({
        'args1': 'DetachedPreview',
        'projectPath': projectPath,
        'selectedLanguage': windowState.selectedLanguage,
        'pdfPath': windowState.pdfPath,
        'isGridMode': windowState.isGridMode,
      }));

      _detachedWindowId = window.windowId;

      // Configure window
      await window.setFrame(const Offset(100, 100) & const Size(1200, 800));
      await window.center();
      await window.setTitle('LingoDoc - Preview');
      await window.show();

      // Update state to indicate preview is detached
      ref.read(detachableWindowProvider.notifier).detach();

      // Note: Window close events will be handled by the window itself
      // through the DetachedPreviewWindow widget
    } catch (e) {
      debugPrint('Failed to create detached window: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to detach preview: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Close the detached window
  Future<void> closeDetachedWindow() async {
    if (_detachedWindowId != null) {
      try {
        await DesktopMultiWindow.invokeMethod(_detachedWindowId!, 'close');
        _detachedWindowId = null;
      } catch (e) {
        debugPrint('Failed to close detached window: $e');
      }
    }
  }

  /// Get the current detached window ID
  int? get detachedWindowId => _detachedWindowId;

  /// Reset the detached window ID (called when window closes)
  void resetWindowId() {
    _detachedWindowId = null;
  }
}

/// Global instance of the detachable window service
final detachableWindowService = DetachableWindowService();
