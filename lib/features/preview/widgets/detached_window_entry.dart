import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import '../../../core/theme/app_theme.dart';
import '../services/detachable_window_service.dart';
import '../../project/services/project_state.dart';
import 'detached_preview_window.dart';

/// Entry point for detached preview window
/// This is called by desktop_multi_window when creating a new window
void detachedPreviewWindowMain(List<String> args) {
  // Parse window arguments
  final windowId = int.tryParse(args.first) ?? -1;

  // Parse window arguments from JSON
  String? projectPath;
  String? selectedLanguage;
  String? pdfPath;
  bool isGridMode = false;

  if (args.length > 1) {
    try {
      final params = jsonDecode(args[1]) as Map<String, dynamic>;
      projectPath = params['projectPath'] as String?;
      selectedLanguage = params['selectedLanguage'] as String?;
      pdfPath = params['pdfPath'] as String?;
      isGridMode = params['isGridMode'] as bool? ?? false;
    } catch (e) {
      debugPrint('Failed to parse window arguments: $e');
    }
  }

  runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'LingoDoc - Preview',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        home: DetachedPreviewWindowRoot(
          windowId: windowId,
          projectPath: projectPath,
          selectedLanguage: selectedLanguage,
          pdfPath: pdfPath,
          isGridMode: isGridMode,
        ),
      ),
    ),
  );
}

/// Root widget for detached window that handles window lifecycle
class DetachedPreviewWindowRoot extends ConsumerStatefulWidget {
  final int windowId;
  final String? projectPath;
  final String? selectedLanguage;
  final String? pdfPath;
  final bool isGridMode;

  const DetachedPreviewWindowRoot({
    super.key,
    required this.windowId,
    this.projectPath,
    this.selectedLanguage,
    this.pdfPath,
    this.isGridMode = false,
  });

  @override
  ConsumerState<DetachedPreviewWindowRoot> createState() =>
      _DetachedPreviewWindowRootState();
}

class _DetachedPreviewWindowRootState
    extends ConsumerState<DetachedPreviewWindowRoot> with WidgetsBindingObserver {

  Timer? _heartbeatTimer;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();

    // Add lifecycle observer to detect app state changes
    WidgetsBinding.instance.addObserver(this);

    // Load project and initialize state when window opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDetachedWindow();
      _startHeartbeat();
    });
  }

  /// Initialize the detached window with project and state
  Future<void> _initializeDetachedWindow() async {
    // Load project if path is provided
    if (widget.projectPath != null) {
      await ref.read(projectTreeProvider.notifier).loadProject(widget.projectPath!);
    }

    // Set initial state
    if (widget.selectedLanguage != null) {
      ref.read(detachableWindowProvider.notifier).setLanguage(widget.selectedLanguage!);
    }
    if (widget.pdfPath != null) {
      ref.read(detachableWindowProvider.notifier).setPdfPath(widget.pdfPath);
    }
    if (widget.isGridMode) {
      ref.read(detachableWindowProvider.notifier).toggleGridMode();
    }
  }

  /// Start heartbeat to keep main window informed
  void _startHeartbeat() {
    // Send periodic heartbeat to main window
    // This allows main window to detect if detached window is still alive
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isClosing) {
        try {
          DesktopMultiWindow.invokeMethod(0, 'window_alive', widget.windowId);
        } catch (e) {
          // Silently ignore - main window might be checking
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Detect when app/window is closing
    if (state == AppLifecycleState.detached || state == AppLifecycleState.paused) {
      _notifyMainWindowClosing();
    }
  }

  /// Notify the main window that this detached window is closing
  void _notifyMainWindowClosing() {
    if (_isClosing) return;
    _isClosing = true;

    try {
      // Send message to main window (ID: 0) to reattach preview
      DesktopMultiWindow.invokeMethod(
        0, // Main window ID
        'reattach_preview',
      );
      debugPrint('Sent reattach_preview message to main window');
    } catch (e) {
      debugPrint('Failed to notify main window: $e');
    }
  }

  @override
  void dispose() {
    // Clean up
    _heartbeatTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);

    // Final attempt to notify
    _notifyMainWindowClosing();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const DetachedPreviewWindow();
  }
}
