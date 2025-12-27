import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Service for resolving the path to the Typst executable.
///
/// Checks locations in order:
/// 1. System PATH (typst command)
/// 2. ~/.local/bin/typst (Linux/macOS)
/// 3. Application support bin directory (Windows)
class TypstPathResolver {
  String? _cachedPath;

  /// Find the Typst executable path.
  ///
  /// Returns the path to typst, or null if not found.
  /// Results are cached for performance.
  Future<String?> findExecutable() async {
    if (_cachedPath != null) return _cachedPath;

    // Try system PATH first
    try {
      final result = await Process.run(
        Platform.isWindows ? 'where' : 'which',
        ['typst'],
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => ProcessResult(0, 1, '', 'timeout'),
      );
      if (result.exitCode == 0) {
        _cachedPath = 'typst';
        return _cachedPath;
      }
    } catch (e) {
      // which/where command not available or failed
    }

    // Try installation directories
    if (Platform.isLinux || Platform.isMacOS) {
      final homeDir = Platform.environment['HOME'];
      if (homeDir != null) {
        final localBinPath = path.join(homeDir, '.local', 'bin', 'typst');
        if (await File(localBinPath).exists()) {
          _cachedPath = localBinPath;
          return _cachedPath;
        }
      }
    } else if (Platform.isWindows) {
      try {
        final appSupportDir = await getApplicationSupportDirectory();
        final binPath = path.join(appSupportDir.path, 'bin', 'typst.exe');
        if (await File(binPath).exists()) {
          _cachedPath = binPath;
          return _cachedPath;
        }
      } catch (e) {
        // getApplicationSupportDirectory failed
      }
    }

    return null;
  }

  /// Clear the cached path.
  ///
  /// Call this after installing or uninstalling Typst.
  void clearCache() {
    _cachedPath = null;
  }
}

/// Provider for the Typst path resolver.
final typstPathResolverProvider = Provider<TypstPathResolver>((ref) {
  return TypstPathResolver();
});
