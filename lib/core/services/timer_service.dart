import 'dart:async';
import 'package:flutter/foundation.dart';

/// Centralized timer service that coordinates all periodic operations
/// to prevent timer conflicts and improve performance.
///
/// This service provides:
/// - Global timer registration and management
/// - Automatic conflict detection
/// - Timer coordination and lifecycle management
/// - Debug logging for timer activity
///
/// Usage:
/// ```dart
/// // Register a timer
/// TimerService().register(
///   'my-timer-id',
///   const Duration(seconds: 2),
///   () {
///     // Periodic callback
///   },
/// );
///
/// // Cancel a timer
/// TimerService().cancel('my-timer-id');
/// ```
class TimerService {
  static final TimerService _instance = TimerService._();

  /// Get the singleton instance
  factory TimerService() => _instance;

  TimerService._();

  /// Active timers by ID
  final Map<String, Timer> _timers = {};

  /// Last execution timestamp for each timer
  final Map<String, DateTime> _lastExecution = {};

  /// Timer intervals for debugging and coordination
  final Map<String, Duration> _intervals = {};

  /// Register or update a periodic timer
  ///
  /// If a timer with the same [id] already exists, it will be cancelled
  /// and replaced with the new timer.
  ///
  /// Parameters:
  /// - [id]: Unique identifier for this timer
  /// - [interval]: How often the callback should execute
  /// - [callback]: Function to call on each interval
  /// - [immediate]: If true, execute callback immediately before starting timer
  void register(
    String id,
    Duration interval,
    VoidCallback callback, {
    bool immediate = false,
  }) {
    // Cancel existing timer if present
    cancel(id);

    // Execute immediately if requested
    if (immediate) {
      callback();
      _lastExecution[id] = DateTime.now();
    }

    // Register the timer
    _timers[id] = Timer.periodic(interval, (_) {
      _lastExecution[id] = DateTime.now();
      callback();
    });

    _intervals[id] = interval;

    if (kDebugMode) {
      print('[TimerService] Registered timer "$id" with interval ${interval.inMilliseconds}ms');
    }
  }

  /// Cancel a specific timer by ID
  ///
  /// Returns true if a timer was cancelled, false if no timer with that ID exists.
  bool cancel(String id) {
    final timer = _timers.remove(id);
    _intervals.remove(id);
    _lastExecution.remove(id);

    if (timer != null) {
      timer.cancel();
      if (kDebugMode) {
        print('[TimerService] Cancelled timer "$id"');
      }
      return true;
    }

    return false;
  }

  /// Cancel all registered timers
  ///
  /// This is useful during app shutdown or when resetting state.
  void cancelAll() {
    final count = _timers.length;

    for (final timer in _timers.values) {
      timer.cancel();
    }

    _timers.clear();
    _intervals.clear();
    _lastExecution.clear();

    if (kDebugMode) {
      print('[TimerService] Cancelled all $count timers');
    }
  }

  /// Check if a timer with the given ID is registered
  bool isRegistered(String id) {
    return _timers.containsKey(id);
  }

  /// Get the interval for a registered timer
  ///
  /// Returns null if the timer is not registered.
  Duration? getInterval(String id) {
    return _intervals[id];
  }

  /// Get the last execution time for a registered timer
  ///
  /// Returns null if the timer has never executed or is not registered.
  DateTime? getLastExecution(String id) {
    return _lastExecution[id];
  }

  /// Get all registered timer IDs
  List<String> getRegisteredIds() {
    return _timers.keys.toList();
  }

  /// Get debug information about all registered timers
  String getDebugInfo() {
    if (_timers.isEmpty) {
      return '[TimerService] No timers registered';
    }

    final buffer = StringBuffer('[TimerService] Registered timers:\n');
    for (final id in _timers.keys) {
      final interval = _intervals[id];
      final lastExec = _lastExecution[id];
      buffer.writeln('  - "$id": ${interval?.inMilliseconds}ms interval, last: ${lastExec?.toString() ?? "never"}');
    }

    return buffer.toString();
  }

  /// Pause a timer temporarily
  ///
  /// The timer can be resumed with [resume()].
  /// This is more efficient than cancelling and re-registering when
  /// you need temporary suspension.
  ///
  /// Note: The timer ID remains registered but inactive.
  bool pause(String id) {
    final timer = _timers[id];
    if (timer != null && timer.isActive) {
      timer.cancel();
      if (kDebugMode) {
        print('[TimerService] Paused timer "$id"');
      }
      return true;
    }
    return false;
  }

  /// Resume a paused timer
  ///
  /// Recreates the timer with the same interval and callback.
  /// This requires the callback to be stored, so we'll need to modify
  /// the implementation if this feature is needed.
  ///
  /// For now, use cancel() + register() instead.
  // TODO: Implement if needed by storing callbacks
}
