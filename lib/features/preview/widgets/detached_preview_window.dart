import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/detachable_window_state.dart';
import '../services/detachable_window_service.dart';
import '../services/preview_provider.dart';
import '../services/auto_refresh_service.dart';
import '../../project/services/project_state.dart';
import '../../project/models/project_config.dart';
import '../../typst/models/compilation_result.dart';
import 'pdf_viewer.dart';
import 'language_grid.dart';
import 'preview_panel.dart';

/// Detached preview window that can be shown in a separate window
class DetachedPreviewWindow extends ConsumerStatefulWidget {
  const DetachedPreviewWindow({super.key});

  @override
  ConsumerState<DetachedPreviewWindow> createState() =>
      _DetachedPreviewWindowState();
}

class _DetachedPreviewWindowState extends ConsumerState<DetachedPreviewWindow> {
  @override
  void initState() {
    super.initState();
    // No longer listening to editor changes - using 10-second periodic timer
  }

  /// Configure auto-refresh with 10-second periodic timer
  void _configureAutoRefresh() {
    final projectConfigAsync = ref.read(projectConfigProvider);
    final projectState = ref.read(projectTreeProvider);
    final projectPath = projectState.projectPath;
    final windowState = ref.read(detachableWindowProvider);
    final selectedLanguage = windowState.selectedLanguage;

    if (projectPath == null || selectedLanguage == null) return;

    final config = projectConfigAsync.value;
    if (config == null) return;

    final autoRefreshService = ref.read(autoRefreshServiceProvider);

    // Configure the periodic timer
    autoRefreshService.configure(
      projectPath: projectPath,
      languageCode: selectedLanguage,
      outputDir: config.projectSettings.outputDirectory,
      onComplete: (result) {
        _handleAutoRefreshResult(result);
      },
    );
  }

  /// Handle auto-refresh compilation result
  void _handleAutoRefreshResult(CompilationResult result) {
    if (!mounted) return;

    result.when(
      success: (pdfPath, languageCode, compiledAt) {
        ref.read(detachableWindowProvider.notifier).setPdfPath(pdfPath);
        ref.read(autoRefreshProvider.notifier).updateLastRefresh();
      },
      error: (message, languageCode, stderr, exitCode) {
        ref.read(autoRefreshProvider.notifier).setError(message);
        // Show subtle error indicator without intrusive snackbar
        debugPrint('Auto-refresh compilation failed: $message');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final windowState = ref.watch(detachableWindowProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('LingoDoc - Preview'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
          tooltip: 'Close detached window',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_in_picture_alt),
            onPressed: () {
              Navigator.of(context).pop();
            },
            tooltip: 'Reattach to main window',
          ),
        ],
      ),
      body: _buildDetachedPreview(context, windowState),
    );
  }

  Widget _buildDetachedPreview(
      BuildContext context, DetachableWindowState windowState) {
    final projectConfigAsync = ref.watch(projectConfigProvider);

    return projectConfigAsync.when(
      data: (config) => _buildPreviewContent(context, config, windowState),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Failed to load config: $error'),
      ),
    );
  }

  Widget _buildPreviewContent(BuildContext context, ProjectConfig? config,
      DetachableWindowState windowState) {
    if (config == null) {
      return const Center(
        child: Text('No project loaded'),
      );
    }

    final theme = Theme.of(context);
    final languages = config.languages;

    // Get current language from window state or default to first language
    final selectedLanguage = windowState.selectedLanguage ??
        (languages.isNotEmpty ? languages.first.code : null);

    // Initialize auto-refresh based on project settings
    final autoRefreshState = ref.read(autoRefreshProvider);
    final shouldBeEnabled = config.projectSettings.autoCompile;
    final autoRefreshService = ref.read(autoRefreshServiceProvider);

    // Only update if state differs from project setting
    if (autoRefreshState.isEnabled != shouldBeEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (shouldBeEnabled) {
          ref.read(autoRefreshProvider.notifier).enable();
          _configureAutoRefresh();
          autoRefreshService.start();
        } else {
          ref.read(autoRefreshProvider.notifier).disable();
          autoRefreshService.stop();
        }
      });
    } else if (shouldBeEnabled) {
      // Auto-refresh is already enabled, just reconfigure if settings changed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _configureAutoRefresh();
      });
    }

    // Show grid mode if enabled
    if (windowState.isGridMode) {
      return Column(
        children: [
          _buildToolbar(context, theme, config, selectedLanguage),
          Expanded(child: LanguageGrid(config: config)),
        ],
      );
    }

    // Single-language mode
    return Column(
      children: [
        _buildToolbar(context, theme, config, selectedLanguage),
        Expanded(
          child: PdfViewer(
            pdfPath: windowState.pdfPath,
            languageCode: selectedLanguage,
            onError: () {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to load PDF'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context, ThemeData theme,
      ProjectConfig config, String? selectedLanguage) {
    final windowState = ref.watch(detachableWindowProvider);
    final languages = config.languages;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Language:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          // Language dropdown
          DropdownButton<String>(
            value: selectedLanguage,
            items: languages.map<DropdownMenuItem<String>>((lang) {
              return DropdownMenuItem<String>(
                value: lang.code,
                child: Text('${lang.name} (${lang.code})'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                ref.read(detachableWindowProvider.notifier).setLanguage(value);
                _compileForLanguage(value);
                // Reconfigure auto-refresh for new language
                _configureAutoRefresh();
              }
            },
          ),
          const Spacer(),

          // Auto-refresh toggle with status
          Consumer(
            builder: (context, ref, child) {
              final autoRefreshState = ref.watch(autoRefreshProvider);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      autoRefreshState.isEnabled
                          ? Icons.autorenew
                          : Icons.autorenew_outlined,
                      color: autoRefreshState.isEnabled
                          ? theme.colorScheme.primary
                          : null,
                    ),
                    onPressed: () {
                      final service = ref.read(autoRefreshServiceProvider);
                      if (autoRefreshState.isEnabled) {
                        // Disable auto-refresh
                        ref.read(autoRefreshProvider.notifier).disable();
                        service.stop();
                      } else {
                        // Enable auto-refresh
                        ref.read(autoRefreshProvider.notifier).enable();
                        _configureAutoRefresh();
                        service.start();
                      }
                    },
                    tooltip: autoRefreshState.isEnabled
                        ? 'Auto-refresh enabled (every 10s)'
                        : 'Auto-refresh disabled',
                  ),
                  // Show status indicator when auto-refresh is active
                  if (autoRefreshState.isEnabled && autoRefreshState.isRefreshing)
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  // Show error indicator if there's an error
                  if (autoRefreshState.errorMessage != null)
                    Tooltip(
                      message: autoRefreshState.errorMessage!,
                      child: Icon(
                        Icons.error_outline,
                        size: 16,
                        color: theme.colorScheme.error,
                      ),
                    ),
                ],
              );
            },
          ),

          const SizedBox(width: 8),

          // Grid mode toggle
          IconButton(
            icon: Icon(
                windowState.isGridMode ? Icons.view_agenda : Icons.grid_view),
            onPressed: () {
              ref.read(detachableWindowProvider.notifier).toggleGridMode();
            },
            tooltip: windowState.isGridMode
                ? 'Single language view'
                : 'Multi-language grid view',
          ),

          const SizedBox(width: 8),

          // Compile button
          FilledButton.icon(
            onPressed: windowState.isCompiling
                ? null
                : () => _compileForLanguage(selectedLanguage),
            icon: windowState.isCompiling
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.play_arrow, size: 18),
            label: Text(windowState.isCompiling ? 'Compiling...' : 'Compile'),
          ),
        ],
      ),
    );
  }

  Future<void> _compileForLanguage(String? languageCode) async {
    if (languageCode == null) return;

    final projectState = ref.read(projectTreeProvider);
    final projectPath = projectState.projectPath;

    if (projectPath == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No project loaded'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    ref.read(detachableWindowProvider.notifier).setCompiling(true);

    try {
      final controller = ref.read(pdfPreviewControllerProvider(languageCode));
      final result = await controller.compile(projectPath: projectPath);

      result.when(
        success: (pdfPath, languageCode, compiledAt) {
          ref.read(detachableWindowProvider.notifier).setCompiling(false);
          ref.read(detachableWindowProvider.notifier).setPdfPath(pdfPath);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Compiled successfully for $languageCode'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        error: (message, languageCode, stderr, exitCode) {
          ref.read(detachableWindowProvider.notifier).setCompiling(false);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Compilation failed: $message'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
      );
    } catch (e) {
      ref.read(detachableWindowProvider.notifier).setCompiling(false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
