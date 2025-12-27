# LingoDoc Technical Debt Resolution Plan

> Created: 2025-12-27
> Status: Planning Complete - Ready for Implementation

## Epic Overview

| Issue | Files Affected | Effort | Priority | Dependencies |
|-------|---------------|--------|----------|--------------|
| **#1 Duplicate Typst lookup** | 2 files | Low | High | None |
| **#2 Checksum verification** | 1 file + new | Medium | High | Issue #1 |
| **#3 Placeholder cleanup** | 14 files | Medium | Medium | None |

**Total Estimated Effort**: ~3 hours

---

## Issue #1: Duplicate Code Consolidation

### Problem

Two nearly identical methods exist for finding the Typst executable:

| Method | Location | Lines |
|--------|----------|-------|
| `_getTypstExecutable()` | `lib/features/typst/services/typst_compiler.dart:15-64` | 50 |
| `_findTypstExecutable()` | `lib/features/typst/services/typst_installer.dart:18-58` | 41 |

Both methods:
1. Check system PATH via `which`/`where`
2. Check `~/.local/bin/typst` (Unix)
3. Check `AppSupport/bin/typst.exe` (Windows)

### Solution: Extract to Shared Service

**New file structure:**
```
lib/features/typst/
├── services/
│   ├── typst_path_resolver.dart   ← NEW: Shared path resolution
│   ├── typst_compiler.dart        ← UPDATE: Use resolver
│   └── typst_installer.dart       ← UPDATE: Use resolver
```

### Tasks

| # | Task | Effort | Status |
|---|------|--------|--------|
| 1.1 | Create `TypstPathResolver` class with single `findExecutable()` method | 15 min | [ ] |
| 1.2 | Add caching with `_cachedPath` field | 5 min | [ ] |
| 1.3 | Create Riverpod provider for resolver | 5 min | [ ] |
| 1.4 | Update `TypstCompiler` to use resolver | 10 min | [ ] |
| 1.5 | Update `TypstInstaller` to use resolver | 10 min | [ ] |
| 1.6 | Add unit tests for `TypstPathResolver` | 20 min | [ ] |
| 1.7 | Remove duplicate code from both classes | 5 min | [ ] |

### Implementation Reference

**New file: `lib/features/typst/services/typst_path_resolver.dart`**

```dart
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
```

---

## Issue #2: Binary Checksum Verification

### Problem

`TypstInstaller` downloads binaries from GitHub releases without any integrity verification:

```dart
// typst_installer.dart:161-180
final archiveBytes = await _downloadWithProgress(downloadUrl, onProgress);
// No verification before extraction!
await _extractArchive(archiveBytes, installDir, platform, onMessage);
```

This is a security risk - a compromised download or MITM attack could inject malicious code.

### Solution: Add SHA256 Checksum Validation

### Tasks

| # | Task | Effort | Status |
|---|------|--------|--------|
| 2.1 | Add `crypto` package to pubspec.yaml | 2 min | [ ] |
| 2.2 | Create checksum constants map for each platform/version | 10 min | [ ] |
| 2.3 | Implement `_verifyChecksum()` method | 15 min | [ ] |
| 2.4 | Integrate verification into `install()` flow | 10 min | [ ] |
| 2.5 | Add meaningful error messages for verification failures | 5 min | [ ] |
| 2.6 | Add unit tests for checksum verification | 20 min | [ ] |

### Implementation Reference

**Add to `pubspec.yaml`:**
```yaml
dependencies:
  crypto: ^3.0.3
```

**Add to `typst_installer.dart`:**

```dart
import 'package:crypto/crypto.dart';

class TypstInstaller {
  static const String _typstVersion = '0.11.1';

  // SHA256 checksums for Typst 0.11.1 releases
  // Obtain from: https://github.com/typst/typst/releases/tag/v0.11.1
  static const Map<String, String> _checksums = {
    'x86_64-unknown-linux-musl': 'CHECKSUM_HERE',
    'aarch64-unknown-linux-musl': 'CHECKSUM_HERE',
    'x86_64-apple-darwin': 'CHECKSUM_HERE',
    'aarch64-apple-darwin': 'CHECKSUM_HERE',
    'x86_64-pc-windows-msvc': 'CHECKSUM_HERE',
  };

  /// Verify the SHA256 checksum of downloaded bytes.
  ///
  /// Returns true if checksum matches or if no checksum is available.
  /// Returns false if checksum verification fails.
  bool _verifyChecksum(List<int> bytes, String platform) {
    final expectedHash = _checksums[platform];
    if (expectedHash == null) {
      // No checksum available - log warning but allow
      return true;
    }

    final actualHash = sha256.convert(bytes).toString();
    return actualHash.toLowerCase() == expectedHash.toLowerCase();
  }

  Future<void> install({...}) async {
    // ... existing code ...

    onMessage('Downloading Typst $_typstVersion for $platform...');
    final archiveBytes = await _downloadWithProgress(downloadUrl, onProgress);

    // NEW: Verify checksum before extraction
    onMessage('Verifying download integrity...');
    if (!_verifyChecksum(archiveBytes, platform)) {
      throw Exception(
        'Security Error: Checksum verification failed.\n'
        'The downloaded file may be corrupted or tampered with.\n'
        'Please try again or download Typst manually from:\n'
        'https://github.com/typst/typst/releases'
      );
    }

    onMessage('Extracting archive...');
    // ... rest of existing code ...
  }
}
```

### Obtaining Checksums

To get the actual checksums for Typst 0.11.1:

```bash
# Download and calculate checksums
curl -sL https://github.com/typst/typst/releases/download/v0.11.1/typst-x86_64-unknown-linux-musl.tar.xz | sha256sum
curl -sL https://github.com/typst/typst/releases/download/v0.11.1/typst-x86_64-apple-darwin.tar.xz | sha256sum
curl -sL https://github.com/typst/typst/releases/download/v0.11.1/typst-x86_64-pc-windows-msvc.zip | sha256sum
```

---

## Issue #3: Placeholder File Cleanup

### Problem

14 files contain only TODO comments with no implementation, creating confusion about project completeness.

### Files Categorized

#### Delete (6 files) - Unused/Superseded

| File | Reason |
|------|--------|
| `lib/core/utils/logger.dart` | `debugPrint` used throughout |
| `lib/core/utils/path_utils.dart` | `path` package used directly |
| `lib/core/theme/code_theme.dart` | Not referenced anywhere |
| `lib/features/editor/models/document.dart` | `EditorTab` model used instead |
| `lib/features/preview/services/refresh_service.dart` | `AutoRefreshService` exists |
| `lib/features/preview/services/pdf_service.dart` | `PdfViewer` handles directly |

#### Implement (5 files) - Provide Minimal Stub

| File | Implementation |
|------|----------------|
| `lib/shared/providers/app_providers.dart` | Barrel export file |
| `lib/shared/widgets/loading_indicator.dart` | Simple wrapper widget |
| `lib/shared/widgets/error_message.dart` | Simple error display |
| `lib/features/preview/models/preview_state.dart` | Basic state class |
| `lib/features/editor/services/syntax_highlighter.dart` | Export existing |

#### Defer (3 files) - Settings Feature (Step 15)

| File | Action |
|------|--------|
| `lib/features/settings/widgets/settings_dialog.dart` | Mark as Step 15 |
| `lib/features/settings/services/settings_service.dart` | Mark as Step 15 |
| `lib/features/settings/models/user_preferences.dart` | Mark as Step 15 |

### Tasks

| # | Task | Effort | Status |
|---|------|--------|--------|
| 3.1 | Delete 6 unused placeholder files | 5 min | [ ] |
| 3.2 | Verify no imports reference deleted files | 5 min | [ ] |
| 3.3 | Implement `loading_indicator.dart` | 10 min | [ ] |
| 3.4 | Implement `error_message.dart` | 10 min | [ ] |
| 3.5 | Convert `app_providers.dart` to barrel export | 5 min | [ ] |
| 3.6 | Implement `preview_state.dart` basic class | 5 min | [ ] |
| 3.7 | Update `syntax_highlighter.dart` to export existing | 5 min | [ ] |
| 3.8 | Update settings files with Step 15 markers | 5 min | [ ] |
| 3.9 | Run `flutter analyze` to verify no broken imports | 2 min | [ ] |

### Implementation Reference

**`lib/shared/widgets/loading_indicator.dart`:**
```dart
import 'package:flutter/material.dart';

/// A centered loading indicator with optional message.
class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
```

**`lib/shared/widgets/error_message.dart`:**
```dart
import 'package:flutter/material.dart';

/// A styled error message display widget.
class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorMessage({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(message, style: theme.textTheme.bodyLarge),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
```

---

## Execution Schedule

### Recommended Order

```
Phase 1: Cleanup (Issue #3)     ─────────────────────────────────→
         [Can start immediately, no dependencies]

Phase 2: Consolidation (Issue #1) ──────────────────────→
         [Can start immediately, no dependencies]
                                                    │
                                                    ↓
Phase 3: Security (Issue #2)                   ──────────→
         [Depends on Issue #1 for resolver]
                                                         │
                                                         ↓
Final:   Validation                                  ────→
         [flutter analyze, flutter test]
```

### Parallel Execution Possible

- Issue #1 and Issue #3 can run in parallel
- Issue #2 must wait for Issue #1 completion

---

## Validation Checklist

After all issues are resolved:

- [ ] `flutter analyze` passes with no issues
- [ ] `flutter test` passes all tests
- [ ] No broken imports (`grep -r "import.*deleted_file"`)
- [ ] Typst installation works (manual test)
- [ ] Typst compilation works (manual test)
- [ ] New tests added for:
  - [ ] `TypstPathResolver`
  - [ ] Checksum verification
  - [ ] `LoadingIndicator` widget
  - [ ] `ErrorMessage` widget

---

## Notes for Implementation

1. **Issue #1** should be implemented first if doing sequentially, as Issue #2 depends on it
2. **Checksum values** need to be obtained from GitHub releases before implementing Issue #2
3. **Settings feature** (3 deferred files) is tracked separately in the 16-step roadmap
4. Run `flutter pub run build_runner build` if any Freezed models are modified
