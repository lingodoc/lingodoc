import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

import 'app.dart';
import 'features/preview/widgets/detached_window_entry.dart';
import 'features/preview/services/detachable_window_service.dart';

void main(List<String> args) async {
  // Check if this is a sub-window
  if (args.isNotEmpty && args.first == 'multi_window') {
    final windowId = int.tryParse(args[1]);
    if (windowId != null) {
      // This is a detached preview window
      WidgetsFlutterBinding.ensureInitialized();
      detachedPreviewWindowMain(args.sublist(1));
      return;
    }
  }

  // Main window initialization
  WidgetsFlutterBinding.ensureInitialized();

  // Set up message handler for detached window communication
  DesktopMultiWindow.setMethodHandler(_handleMethodCall);

  // Configure desktop window
  await windowManager.ensureInitialized();

  const WindowOptions windowOptions = WindowOptions(
    size: Size(1400, 900),
    minimumSize: Size(1200, 700),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'LingoDoc',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Create provider container for message handling
  final container = ProviderContainer();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: LingoDocApp(),
    ),
  );

  // Store container reference for message handling
  _globalContainer = container;
}

// Global container reference for window message handling
ProviderContainer? _globalContainer;

// Track last heartbeat from detached window
DateTime? _lastHeartbeat;
Timer? _heartbeatMonitor;

/// Handle method calls from detached windows
Future<dynamic> _handleMethodCall(MethodCall call, int fromWindowId) async {
  if (call.method == 'reattach_preview') {
    // Handle reattach request from detached window
    debugPrint('Received reattach_preview message from window $fromWindowId');

    // Reattach preview in main window
    if (_globalContainer != null) {
      _globalContainer!.read(detachableWindowProvider.notifier).attach();
    }

    // Reset window ID in service
    detachableWindowService.resetWindowId();

    // Stop heartbeat monitoring
    _heartbeatMonitor?.cancel();
    _lastHeartbeat = null;

    return true;
  }

  if (call.method == 'window_alive') {
    // Heartbeat from detached window
    _lastHeartbeat = DateTime.now();

    // Start monitoring if not already started
    if (_heartbeatMonitor == null) {
      _startHeartbeatMonitoring();
    }

    return true;
  }

  return null;
}

/// Monitor heartbeat from detached window
void _startHeartbeatMonitoring() {
  _heartbeatMonitor = Timer.periodic(const Duration(seconds: 3), (timer) {
    if (_lastHeartbeat != null) {
      final elapsed = DateTime.now().difference(_lastHeartbeat!);

      // If no heartbeat for 5 seconds, assume window closed
      if (elapsed.inSeconds > 5) {
        debugPrint('Detached window heartbeat timeout - reattaching preview');

        // Reattach preview
        if (_globalContainer != null) {
          _globalContainer!.read(detachableWindowProvider.notifier).attach();
        }

        // Reset window ID
        detachableWindowService.resetWindowId();

        // Stop monitoring
        _heartbeatMonitor?.cancel();
        _heartbeatMonitor = null;
        _lastHeartbeat = null;
      }
    }
  });
}
