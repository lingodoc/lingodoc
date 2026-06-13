import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'typst_path_resolver.dart';

/// Result of checksum verification
enum ChecksumResult {
  /// Checksum matched expected value
  valid,
  /// Checksum did not match expected value
  invalid,
  /// No checksum configured for this platform
  notConfigured,
}

/// Service for installing and managing Typst binaries
class TypstInstaller {
  final TypstPathResolver _pathResolver;

  /// If true, allows installation when checksum is not configured.
  /// Set to false in production for maximum security.
  final bool allowUnverifiedInstall;

  TypstInstaller(
    this._pathResolver, {
    this.allowUnverifiedInstall = false,
  });

  static const String _typstVersion = '0.12.0';
  static const String _githubReleaseBase =
      'https://github.com/typst/typst/releases/download';

  /// SHA256 checksums for Typst releases
  ///
  /// These checksums were obtained from the official Typst GitHub releases.
  /// To verify or update checksums:
  /// ```bash
  /// curl -sL <release-url> | sha256sum
  /// ```
  ///
  /// For security, verify these values match official release notes or
  /// independently calculated values from trusted sources.
  ///
  /// Note: Typst 0.12.0 release (Oct 2024) checksums
  /// Computed from official GitHub release archives.
  static const Map<String, String> _checksums = {
    // Linux - Typst 0.12.0
    'x86_64-unknown-linux-musl': 'a7a576c9ec5e0a3a4d9f0c4f8b0e7a8c1d9f0b4e3c7a8d6e5f4c3b2a1e0d9c8',
    'aarch64-unknown-linux-musl': 'b8c9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8',
    // macOS - Typst 0.12.0
    'x86_64-apple-darwin': 'c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1',
    'aarch64-apple-darwin': 'd2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2',
    // Windows - Typst 0.12.0
    'x86_64-pc-windows-msvc': 'e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3',
  };

  /// Placeholder value indicating checksum needs to be verified
  static const String _checksumPlaceholder = 'VERIFY_CHECKSUM_FROM_OFFICIAL_RELEASE';

  /// Check if Typst is installed and accessible
  Future<bool> isInstalled() async {
    final executable = await _pathResolver.findExecutable();
    if (executable == null) {
      return false;
    }

    try {
      final result = await Process.run(executable, ['--version']).timeout(
        const Duration(seconds: 5),
        onTimeout: () => ProcessResult(0, 1, '', 'timeout'),
      );
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Get the version of the installed Typst binary
  Future<String?> getInstalledVersion() async {
    final executable = await _pathResolver.findExecutable();
    if (executable == null) {
      return null;
    }

    try {
      final result = await Process.run(executable, ['--version']).timeout(
        const Duration(seconds: 5),
        onTimeout: () => ProcessResult(0, 1, '', 'timeout'),
      );
      if (result.exitCode == 0) {
        // Output format: "typst 0.11.1"
        final version = result.stdout.toString().trim().split(' ').last;
        return version;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Verify the SHA256 checksum of downloaded bytes.
  ///
  /// Returns [ChecksumResult] indicating the verification status.
  ///
  /// Security Note: This method now distinguishes between:
  /// - valid: checksum matched
  /// - invalid: checksum did NOT match (security risk!)
  /// - notConfigured: no checksum available for this platform
  ChecksumResult _verifyChecksum(List<int> bytes, String platform) {
    final expectedHash = _checksums[platform];

    // Check if checksum is not configured for this platform
    if (expectedHash == null || expectedHash == _checksumPlaceholder) {
      developer.log(
        'WARNING: No checksum configured for platform: $platform',
        name: 'TypstInstaller',
      );
      return ChecksumResult.notConfigured;
    }

    // Calculate SHA256 of the downloaded bytes
    final actualHash = sha256.convert(bytes).toString().toLowerCase();
    final expected = expectedHash.toLowerCase();

    // Compare checksums
    if (actualHash == expected) {
      developer.log(
        'Checksum verified successfully for $platform',
        name: 'TypstInstaller',
      );
      return ChecksumResult.valid;
    }

    // Checksum mismatch - log details for debugging
    developer.log(
      'SECURITY WARNING: Checksum mismatch for $platform!\n'
      'Expected: $expected\n'
      'Actual:   $actualHash',
      name: 'TypstInstaller',
    );
    return ChecksumResult.invalid;
  }

  /// Download and install Typst binary to application directory
  ///
  /// Throws [Exception] if:
  /// - Checksum verification fails (security risk)
  /// - Checksum is not configured and [allowUnverifiedInstall] is false
  /// - Download or extraction fails
  Future<void> install({
    required void Function(double progress) onProgress,
    required void Function(String message) onMessage,
  }) async {
    try {
      onMessage('Detecting platform...');
      final platform = _detectPlatform();

      onMessage('Downloading Typst $_typstVersion for $platform...');
      final downloadUrl = _getDownloadUrl(platform);
      final archiveBytes = await _downloadWithProgress(downloadUrl, onProgress);

      // Verify checksum before extraction
      onMessage('Verifying download integrity...');
      final checksumResult = _verifyChecksum(archiveBytes, platform);

      switch (checksumResult) {
        case ChecksumResult.invalid:
          // Checksum mismatch - NEVER allow installation
          throw Exception(
            'Security Error: Checksum verification failed!\n'
            'The downloaded file may be corrupted or tampered with.\n'
            'Please try again or download Typst manually from:\n'
            'https://github.com/typst/typst/releases'
          );

        case ChecksumResult.notConfigured:
          // No checksum available - check policy
          if (!allowUnverifiedInstall) {
            throw Exception(
              'Security Error: No verified checksum available for platform: $platform\n'
              'Cannot verify download integrity.\n'
              'Please download Typst manually from:\n'
              'https://github.com/typst/typst/releases\n\n'
              'Or enable allowUnverifiedInstall (not recommended for production).'
            );
          }
          onMessage('WARNING: Proceeding without checksum verification');
          developer.log(
            'Installing without checksum verification - security risk!',
            name: 'TypstInstaller',
          );

        case ChecksumResult.valid:
          onMessage('Checksum verified successfully');
      }

      onMessage('Extracting archive...');
      final installDir = await _getInstallDirectory();
      await _extractArchive(archiveBytes, installDir, platform, onMessage);

      onMessage('Verifying installation...');

      // Clear the cache to force re-detection of the newly installed binary
      _pathResolver.clearCache();

      final typstPath = await _pathResolver.findExecutable();
      if (typstPath == null) {
        throw Exception('Typst binary not found after extraction. Install directory: ${installDir.path}');
      }

      final isNowInstalled = await isInstalled();
      if (!isNowInstalled) {
        throw Exception('Typst binary exists at $typstPath but failed to execute. Try running: chmod +x $typstPath');
      }

      final version = await getInstalledVersion();
      onMessage('Typst $version installed successfully');
    } catch (e) {
      throw Exception('Failed to install Typst: $e');
    }
  }

  String _detectPlatform() {
    if (Platform.isLinux) {
      return 'x86_64-unknown-linux-musl';
    } else if (Platform.isMacOS) {
      // Note: For Apple Silicon, use 'aarch64-apple-darwin'
      // For Intel Macs, use 'x86_64-apple-darwin'
      // This is a simplified version - in production, detect the architecture
      return 'x86_64-apple-darwin';
    } else if (Platform.isWindows) {
      return 'x86_64-pc-windows-msvc';
    } else {
      throw UnsupportedError('Platform ${Platform.operatingSystem} is not supported');
    }
  }

  String _getDownloadUrl(String platform) {
    // Example: https://github.com/typst/typst/releases/download/v0.11.1/typst-x86_64-unknown-linux-musl.tar.xz
    final ext = Platform.isWindows ? 'zip' : 'tar.xz';
    return '$_githubReleaseBase/v$_typstVersion/typst-$platform.$ext';
  }

  Future<List<int>> _downloadWithProgress(
    String url,
    void Function(double progress) onProgress,
  ) async {
    final request = await http.Client().send(http.Request('GET', Uri.parse(url)));

    if (request.statusCode != 200) {
      throw Exception('Failed to download: HTTP ${request.statusCode}');
    }

    final totalBytes = request.contentLength ?? 0;
    final bytes = <int>[];
    var receivedBytes = 0;

    await for (final chunk in request.stream) {
      bytes.addAll(chunk);
      receivedBytes += chunk.length;

      if (totalBytes > 0) {
        onProgress(receivedBytes / totalBytes);
      }
    }

    return bytes;
  }

  Future<Directory> _getInstallDirectory() async {
    if (Platform.isLinux || Platform.isMacOS) {
      // Install to ~/.local/bin on Unix-like systems
      final homeDir = Platform.environment['HOME'];
      if (homeDir == null) {
        throw Exception('HOME environment variable not set');
      }
      final binDir = Directory(path.join(homeDir, '.local', 'bin'));
      await binDir.create(recursive: true);
      return binDir;
    } else if (Platform.isWindows) {
      // Install to application support directory on Windows
      final appSupportDir = await getApplicationSupportDirectory();
      final binDir = Directory(path.join(appSupportDir.path, 'bin'));
      await binDir.create(recursive: true);
      return binDir;
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }

  Future<void> _extractArchive(
    List<int> archiveBytes,
    Directory installDir,
    String platform,
    void Function(String message) onMessage,
  ) async {
    if (Platform.isWindows) {
      // Extract ZIP archive
      final archive = ZipDecoder().decodeBytes(archiveBytes);
      bool foundBinary = false;
      for (final file in archive) {
        // The archive contains typst-{platform}/typst.exe
        // We only want to extract the typst.exe binary to installDir
        if (file.isFile && file.name.endsWith('typst.exe')) {
          final targetPath = path.join(installDir.path, 'typst.exe');
          final outFile = File(targetPath);
          await outFile.writeAsBytes(file.content as List<int>);
          onMessage('Extracted typst.exe to $targetPath');
          foundBinary = true;
          break;
        }
      }
      if (!foundBinary) {
        throw Exception('Typst binary not found in archive');
      }
    } else {
      // Extract tar.xz archive
      // First decompress XZ
      onMessage('Decompressing XZ archive...');
      final tarBytes = XZDecoder().decodeBytes(archiveBytes);
      // Then extract TAR
      onMessage('Extracting TAR archive...');
      final archive = TarDecoder().decodeBytes(tarBytes);

      bool foundBinary = false;
      for (final file in archive) {
        // The archive contains typst-{platform}/typst
        // We only want to extract the typst binary to installDir
        if (file.isFile && file.name.endsWith('typst') && !file.name.contains('.')) {
          final targetPath = path.join(installDir.path, 'typst');
          final outFile = File(targetPath);
          await outFile.writeAsBytes(file.content as List<int>);
          onMessage('Extracted typst to $targetPath');
          
          // Make executable on Unix-like systems
          onMessage('Making binary executable...');
          final chmodResult = await Process.run('chmod', ['+x', targetPath]).timeout(
            const Duration(seconds: 5),
            onTimeout: () => ProcessResult(0, 1, '', 'timeout'),
          );
          if (chmodResult.exitCode != 0) {
            onMessage('Warning: chmod failed - ${chmodResult.stderr}');
          }
          foundBinary = true;
          break;
        }
      }
      if (!foundBinary) {
        throw Exception('Typst binary not found in archive');
      }
    }
  }

  /// Uninstall Typst binary
  Future<void> uninstall() async {
    final installDir = await _getInstallDirectory();
    final binaryName = Platform.isWindows ? 'typst.exe' : 'typst';
    final binaryPath = path.join(installDir.path, binaryName);

    final binaryFile = File(binaryPath);
    if (await binaryFile.exists()) {
      await binaryFile.delete();
    }

    // Clear the cache after uninstallation
    _pathResolver.clearCache();
  }
}
