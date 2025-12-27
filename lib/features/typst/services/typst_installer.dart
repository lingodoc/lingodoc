import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Service for installing and managing Typst binaries
class TypstInstaller {
  static const String _typstVersion = '0.11.1';
  static const String _githubReleaseBase =
      'https://github.com/typst/typst/releases/download';

  /// Get the path to the Typst executable
  ///
  /// Checks in order:
  /// 1. System PATH (typst command)
  /// 2. ~/.local/bin/typst (Linux/macOS installation directory)
  /// 3. Application support bin directory (Windows)
  Future<String?> _findTypstExecutable() async {
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
        return 'typst';
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
          return localBinPath;
        }
      }
    } else if (Platform.isWindows) {
      try {
        final appSupportDir = await getApplicationSupportDirectory();
        final binPath = path.join(appSupportDir.path, 'bin', 'typst.exe');
        if (await File(binPath).exists()) {
          return binPath;
        }
      } catch (e) {
        // getApplicationSupportDirectory failed
      }
    }

    return null;
  }

  /// Check if Typst is installed and accessible
  Future<bool> isInstalled() async {
    final executable = await _findTypstExecutable();
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
    final executable = await _findTypstExecutable();
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

  /// Download and install Typst binary to application directory
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

      onMessage('Extracting archive...');
      final installDir = await _getInstallDirectory();
      await _extractArchive(archiveBytes, installDir, platform, onMessage);

      onMessage('Verifying installation...');
      final typstPath = await _findTypstExecutable();
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
  }
}
