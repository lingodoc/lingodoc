import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/typst/services/typst_startup_check.dart';
import '../../features/typst/widgets/typst_install_dialog.dart';
import 'main_layout.dart';

/// Startup wrapper that checks Typst installation before showing main UI
class AppStartup extends ConsumerStatefulWidget {
  const AppStartup({super.key});

  @override
  ConsumerState<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends ConsumerState<AppStartup> {
  bool _hasShownDialog = false;

  @override
  Widget build(BuildContext context) {
    final typstStatus = ref.watch(typstStatusProvider);

    // Show loading screen while checking
    if (typstStatus.isChecking) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Checking Typst installation...'),
            ],
          ),
        ),
      );
    }

    // Show installation dialog if Typst is not installed
    if (!typstStatus.isInstalled && !_hasShownDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        setState(() {
          _hasShownDialog = true;
        });

        final result = await showTypstInstallDialog(context);

        if (result != true && mounted) {
          // User cancelled or installation failed
          _showInstallationRequiredMessage();
        }
      });

      // Show placeholder while dialog is being shown
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show main layout if Typst is installed
    if (typstStatus.isInstalled) {
      return const MainLayout();
    }

    // Show installation required message if user cancelled
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: Colors.orange.shade700,
              ),
              const SizedBox(height: 24),
              const Text(
                'Typst Compiler Required',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'LingoDoc requires the Typst compiler to generate PDF previews.\n'
                'Please install Typst to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () async {
                  final result = await showTypstInstallDialog(context);
                  if (result == true && mounted) {
                    setState(() {
                      _hasShownDialog = false;
                    });
                  }
                },
                icon: const Icon(Icons.download),
                label: const Text('Install Typst'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInstallationRequiredMessage() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Typst installation is required for PDF preview functionality',
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Install',
          textColor: Colors.white,
          onPressed: () async {
            final result = await showTypstInstallDialog(context);
            if (result == true && mounted) {
              setState(() {
                _hasShownDialog = false;
              });
            }
          },
        ),
      ),
    );
  }
}
