import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import '../../typst/services/typst_compiler.dart';
import '../../typst/models/compilation_result.dart';
import 'preview_provider.dart' show typstCompilerProvider;

class AutoRefreshService {
  final Ref ref;
  final TypstCompiler compiler;

  // Debounce timer for editor changes
  Timer? _debounceTimer;

  // Periodic timer for auto-refresh (every 10 seconds)
  Timer? _periodicTimer;

  // Current auto-refresh state
  bool _isEnabled = false;

  // Periodic refresh callback
  Function(CompilationResult)? _periodicCallback;
  String? _projectPath;
  String? _languageCode;
  String? _outputDir;
  
  // Track last modification time of source files to avoid unnecessary compilation
  DateTime? _lastSourceModTime;

  AutoRefreshService(this.ref, this.compiler);

  /// Check if auto-refresh is currently enabled
  bool get isEnabled => _isEnabled;

  /// Start auto-refresh with 10-second periodic timer
  ///
  /// This enables auto-refresh and starts a periodic timer that compiles
  /// every 10 seconds automatically.
  void start() {
    _isEnabled = true;
    _startPeriodicTimer();
  }

  /// Stop auto-refresh and clean up timers
  void stop() {
    _isEnabled = false;
    _cancelTimers();
  }

  /// Start the periodic 10-second timer for auto-refresh
  void _startPeriodicTimer() {
    _cancelTimers();

    if (!_isEnabled || _projectPath == null || _languageCode == null || _periodicCallback == null) {
      return;
    }

    _periodicTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (!_isEnabled || _projectPath == null || _languageCode == null || _periodicCallback == null) {
        return;
      }

      // Check if source files have actually changed before compiling
      // Returns the latest modification time if changes detected, null otherwise
      final latestModTime = await _checkForSourceChanges();
      if (latestModTime == null) {
        return;
      }

      // Perform compilation
      final result = await compiler.compileForLanguage(
        projectPath: _projectPath!,
        languageCode: _languageCode!,
        outputDir: _outputDir,
      );

      // Update last source modification time AFTER successful compilation
      // This ensures future changes will be detected
      _lastSourceModTime = latestModTime;

      // Notify callback
      _periodicCallback!(result);
    });
  }

  /// Check if any source files have been modified since last compilation
  /// Returns the latest modification time if changes detected, null otherwise
  Future<DateTime?> _checkForSourceChanges() async {
    if (_projectPath == null) return null;

    try {
      // Check main.typ and all .typ files in chapters directory
      final mainTypPath = path.join(_projectPath!, 'main.typ');
      final chaptersDir = path.join(_projectPath!, 'chapters');

      DateTime? latestModTime;

      // Check main.typ
      final mainTypFile = File(mainTypPath);
      if (await mainTypFile.exists()) {
        final stat = await mainTypFile.stat();
        latestModTime = stat.modified;
      }

      // Check all .typ files in chapters directory
      final chaptersDirectory = Directory(chaptersDir);
      if (await chaptersDirectory.exists()) {
        await for (final entity in chaptersDirectory.list(recursive: false)) {
          if (entity is File && entity.path.endsWith('.typ')) {
            final stat = await entity.stat();
            if (latestModTime == null || stat.modified.isAfter(latestModTime)) {
              latestModTime = stat.modified;
            }
          }
        }
      }

      // Check terms.typ if it exists
      final termsTypPath = path.join(_projectPath!, 'terms.typ');
      final termsTypFile = File(termsTypPath);
      if (await termsTypFile.exists()) {
        final stat = await termsTypFile.stat();
        if (latestModTime == null || stat.modified.isAfter(latestModTime)) {
          latestModTime = stat.modified;
        }
      }

      // Check lang.typ if it exists (language injection file)
      final langTypPath = path.join(_projectPath!, 'lang.typ');
      final langTypFile = File(langTypPath);
      if (await langTypFile.exists()) {
        final stat = await langTypFile.stat();
        if (latestModTime == null || stat.modified.isAfter(latestModTime)) {
          latestModTime = stat.modified;
        }
      }

      // If no previous check or files were modified, return the latest mod time
      if (_lastSourceModTime == null ||
          (latestModTime != null && latestModTime.isAfter(_lastSourceModTime!))) {
        return latestModTime;
      }

      return null;
    } catch (e) {
      // On error, return current time to force compilation
      return DateTime.now();
    }
  }

  /// Configure periodic refresh settings
  ///
  /// This sets up the parameters for the 10-second periodic refresh.
  /// Call this to initialize or update the auto-refresh configuration.
  void configure({
    required String projectPath,
    required String languageCode,
    String? outputDir,
    required Function(CompilationResult) onComplete,
  }) {
    _projectPath = projectPath;
    _languageCode = languageCode;
    _outputDir = outputDir;
    _periodicCallback = onComplete;
    
    // Reset last source mod time when configuration changes
    _lastSourceModTime = null;

    // Restart timer with new configuration if enabled
    if (_isEnabled) {
      _startPeriodicTimer();
    }
  }

  /// Trigger immediate refresh without debouncing
  ///
  /// Useful for manual refresh requests or language changes
  Future<CompilationResult> refreshImmediate({
    required String projectPath,
    required String languageCode,
    String? outputDir,
  }) async {
    _cancelTimers();
    
    // Reset last source mod time to force next periodic check
    _lastSourceModTime = null;

    return await compiler.compileForLanguage(
      projectPath: projectPath,
      languageCode: languageCode,
      outputDir: outputDir,
    );
  }

  /// Cancel all active timers
  void _cancelTimers() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  /// Clean up resources
  void dispose() {
    stop();
  }
}

/// Provider for AutoRefreshService
final autoRefreshServiceProvider = Provider<AutoRefreshService>((ref) {
  final compiler = ref.read(typstCompilerProvider);
  final service = AutoRefreshService(ref, compiler);

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// State notifier for managing auto-refresh state across the app
class AutoRefreshState {
  final bool isEnabled;
  final bool isRefreshing;
  final DateTime? lastRefreshTime;
  final String? errorMessage;

  const AutoRefreshState({
    this.isEnabled = false,
    this.isRefreshing = false,
    this.lastRefreshTime,
    this.errorMessage,
  });

  AutoRefreshState copyWith({
    bool? isEnabled,
    bool? isRefreshing,
    DateTime? lastRefreshTime,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AutoRefreshState(
      isEnabled: isEnabled ?? this.isEnabled,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      lastRefreshTime: lastRefreshTime ?? this.lastRefreshTime,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Notifier for auto-refresh state
class AutoRefreshNotifier extends Notifier<AutoRefreshState> {
  @override
  AutoRefreshState build() => const AutoRefreshState();

  /// Toggle auto-refresh on/off
  void toggle() {
    state = state.copyWith(isEnabled: !state.isEnabled);
  }

  /// Enable auto-refresh
  void enable() {
    state = state.copyWith(isEnabled: true);
  }

  /// Disable auto-refresh
  void disable() {
    state = state.copyWith(isEnabled: false);
  }

  /// Set refreshing state
  void setRefreshing(bool isRefreshing) {
    state = state.copyWith(isRefreshing: isRefreshing);
  }

  /// Update last refresh time
  void updateLastRefresh() {
    state = state.copyWith(
      lastRefreshTime: DateTime.now(),
      isRefreshing: false,
      clearError: true,
    );
  }

  /// Set error message
  void setError(String message) {
    state = state.copyWith(
      errorMessage: message,
      isRefreshing: false,
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for auto-refresh state
final autoRefreshProvider = NotifierProvider<AutoRefreshNotifier, AutoRefreshState>(() {
  return AutoRefreshNotifier();
});
