import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/typst_startup_check.dart';

/// Dialog for installing Typst compiler
class TypstInstallDialog extends ConsumerStatefulWidget {
  const TypstInstallDialog({super.key});

  @override
  ConsumerState<TypstInstallDialog> createState() => _TypstInstallDialogState();
}

class _TypstInstallDialogState extends ConsumerState<TypstInstallDialog> {
  bool _isInstalling = false;
  double _progress = 0.0;
  String _statusMessage = '';
  String? _errorMessage;
  bool _installationComplete = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.download, color: Colors.blue),
          SizedBox(width: 12),
          Text('Typst Compiler Required'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isInstalling && !_installationComplete) ...[
              const Text(
                'LingoDoc requires the Typst compiler to generate PDF previews.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'The installer will:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildBulletPoint('Download Typst 0.11.1 from GitHub'),
              _buildBulletPoint('Install to ~/.local/bin (Linux/macOS)'),
              _buildBulletPoint('Make the binary executable'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Note: You may need to restart your terminal or IDE after installation to use Typst from the command line.',
                        style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_isInstalling) ...[
              Text(
                _statusMessage,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _progress > 0 ? _progress : null,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                '${(_progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
            if (_installationComplete && _errorMessage == null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Installation Complete!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Typst compiler is now ready to use.',
                            style: TextStyle(fontSize: 14, color: Colors.green.shade900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Installation Failed',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _errorMessage!,
                            style: TextStyle(fontSize: 12, color: Colors.red.shade900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (!_isInstalling && !_installationComplete)
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
        if (!_isInstalling && !_installationComplete)
          FilledButton.icon(
            onPressed: _startInstallation,
            icon: const Icon(Icons.download),
            label: const Text('Install Typst'),
          ),
        if (_installationComplete || _errorMessage != null)
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_installationComplete),
            child: Text(_installationComplete ? 'Close' : 'OK'),
          ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Future<void> _startInstallation() async {
    setState(() {
      _isInstalling = true;
      _progress = 0.0;
      _statusMessage = 'Preparing installation...';
      _errorMessage = null;
    });

    try {
      final installer = ref.read(typstInstallerProvider);

      await installer.install(
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _progress = progress;
            });
          }
        },
        onMessage: (message) {
          if (mounted) {
            setState(() {
              _statusMessage = message;
            });
          }
        },
      );

      // Refresh status after installation
      await ref.read(typstStatusProvider.notifier).refreshStatus();

      if (mounted) {
        setState(() {
          _installationComplete = true;
          _isInstalling = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isInstalling = false;
        });
      }
    }
  }
}

/// Show the Typst installation dialog
Future<bool?> showTypstInstallDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const TypstInstallDialog(),
  );
}
