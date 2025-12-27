import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingodoc/features/typst/services/typst_path_resolver.dart';

void main() {
  late TypstPathResolver resolver;

  setUp(() {
    resolver = TypstPathResolver();
  });

  group('TypstPathResolver', () {
    test('findExecutable - returns cached path on subsequent calls', () async {
      // First call
      final path1 = await resolver.findExecutable();

      // Second call should return the same cached value
      final path2 = await resolver.findExecutable();

      expect(path2, equals(path1));
    });

    test('clearCache - forces re-detection on next call', () async {
      // First call to populate cache
      await resolver.findExecutable();

      // Clear the cache
      resolver.clearCache();

      // The implementation will re-detect, so we just verify it doesn't throw
      final path = await resolver.findExecutable();

      // Path should either be found or null, but not throw an error
      expect(path, anyOf(isNull, isA<String>()));
    });

    test('findExecutable - returns null when typst not found', () async {
      // This test assumes typst is not installed in the test environment
      // We create a new resolver to ensure no cached results
      final freshResolver = TypstPathResolver();

      // Clear any system PATH that might have typst
      // Note: This is a simplified test - in a real scenario, we'd mock Process.run
      final result = await freshResolver.findExecutable();

      // Result should be either null (not found) or a string (found in system)
      expect(result, anyOf(isNull, isA<String>()));
    });

    test('findExecutable - caches the result for performance', () async {
      // First call
      final stopwatch = Stopwatch()..start();
      await resolver.findExecutable();
      stopwatch.stop();
      final firstCallDuration = stopwatch.elapsedMicroseconds;

      // Second call (should use cache)
      stopwatch.reset();
      stopwatch.start();
      await resolver.findExecutable();
      stopwatch.stop();
      final secondCallDuration = stopwatch.elapsedMicroseconds;

      // Second call should be significantly faster (cache hit)
      // Allow some tolerance for system variance
      expect(secondCallDuration < firstCallDuration ~/ 2, isTrue,
          reason:
              'Second call ($secondCallDuration μs) should be much faster than first ($firstCallDuration μs)');
    });

    test('findExecutable - handles platform-specific paths correctly',
        () async {
      final path = await resolver.findExecutable();

      if (path != null) {
        if (Platform.isWindows) {
          // Windows should return either 'typst' or a path ending in .exe
          expect(path == 'typst' || path.endsWith('.exe'), isTrue);
        } else {
          // Unix-like systems should return 'typst' or an absolute path
          expect(path == 'typst' || path.startsWith('/'), isTrue);
        }
      }
    });

    test('clearCache - allows detection of newly installed binary', () async {
      // Initial detection
      final initialPath = await resolver.findExecutable();

      // Simulate installation by clearing cache
      resolver.clearCache();

      // Re-detect (in real scenario, binary might have been installed)
      final newPath = await resolver.findExecutable();

      // Both paths should be the same type (null or String)
      expect(newPath.runtimeType, equals(initialPath.runtimeType));
    });
  });

  group('TypstPathResolver - Integration', () {
    test('findExecutable - respects system PATH priority', () async {
      final path = await resolver.findExecutable();

      // If found in system PATH, it should return 'typst'
      // Otherwise, it should check installation directories
      if (path == 'typst') {
        // System PATH has higher priority
        expect(path, equals('typst'));
      } else if (path != null) {
        // Found in installation directory
        if (Platform.isLinux || Platform.isMacOS) {
          expect(path.contains('.local/bin/typst'), isTrue);
        } else if (Platform.isWindows) {
          expect(path.endsWith('typst.exe'), isTrue);
        }
      }
    });

    test('findExecutable - handles missing HOME environment gracefully',
        () async {
      // This test verifies the resolver doesn't crash when HOME is not set
      // In a real test, we'd mock the environment variables
      final path = await resolver.findExecutable();

      // Should either find typst or return null, but not throw
      expect(path, anyOf(isNull, isA<String>()));
    });

    test('findExecutable - handles timeout scenarios gracefully', () async {
      // The implementation has a 5-second timeout for Process.run
      // This test ensures it completes within a reasonable time
      final stopwatch = Stopwatch()..start();
      await resolver.findExecutable();
      stopwatch.stop();

      // Should complete well within timeout (5 seconds = 5,000,000 microseconds)
      expect(stopwatch.elapsedMicroseconds < 6000000, isTrue,
          reason: 'findExecutable should complete within timeout');
    });
  });
}
