import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'typst_installer.dart';
import 'typst_path_resolver.dart';

/// State for Typst installation status
class TypstStatus {
  final bool isInstalled;
  final String? version;
  final bool isChecking;

  const TypstStatus({
    required this.isInstalled,
    this.version,
    this.isChecking = false,
  });

  TypstStatus copyWith({
    bool? isInstalled,
    String? version,
    bool? isChecking,
  }) {
    return TypstStatus(
      isInstalled: isInstalled ?? this.isInstalled,
      version: version ?? this.version,
      isChecking: isChecking ?? this.isChecking,
    );
  }
}

/// Provider for TypstInstaller service
final typstInstallerProvider = Provider<TypstInstaller>((ref) {
  final pathResolver = ref.watch(typstPathResolverProvider);
  return TypstInstaller(pathResolver);
});

/// Provider for Typst installation status (Riverpod 3.x)
final typstStatusProvider = NotifierProvider<TypstStatusNotifier, TypstStatus>(
  TypstStatusNotifier.new,
);

/// Notifier for managing Typst installation status (Riverpod 3.x)
class TypstStatusNotifier extends Notifier<TypstStatus> {
  @override
  TypstStatus build() {
    // Initialize with checking state and start the check asynchronously
    // Don't await - let it run in the background
    Future.microtask(() => _checkInstallation());
    return const TypstStatus(isInstalled: false, isChecking: true);
  }

  /// Check if Typst is installed on startup
  Future<void> _checkInstallation() async {
    final installer = ref.read(typstInstallerProvider);

    final isInstalled = await installer.isInstalled();
    final version = isInstalled ? await installer.getInstalledVersion() : null;

    state = TypstStatus(
      isInstalled: isInstalled,
      version: version,
      isChecking: false,
    );
  }

  /// Refresh installation status (call after installation)
  Future<void> refreshStatus() async {
    await _checkInstallation();
  }
}
