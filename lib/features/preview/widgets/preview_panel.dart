import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pdf_viewer.dart';
import 'language_grid.dart';
import '../services/preview_provider.dart';
import '../services/auto_refresh_service.dart';
import '../services/detachable_window_service.dart';
import '../../project/services/project_state.dart';
import '../../project/services/config_provider.dart';
import '../../project/models/project_config.dart';
import '../../typst/models/compilation_result.dart';

/// Provider for project configuration based on current project path
final projectConfigProvider = FutureProvider<ProjectConfig?>((ref) async {
  final projectState = ref.watch(projectTreeProvider);
  if (projectState.projectPath == null) {
    return null;
  }

  try {
    final configService = ref.read(configServiceProvider);
    return await configService.loadConfig(projectState.projectPath!);
  } catch (e) {
    return null;
  }
});

/// Preview panel that displays PDF preview with language selection
class PreviewPanel extends ConsumerStatefulWidget {
  const PreviewPanel({super.key});

  @override
  ConsumerState<PreviewPanel> createState() => _PreviewPanelState();
}

class _PreviewPanelState extends ConsumerState<PreviewPanel> {
  String? _selectedLanguage;
  String? _pdfPath;
  bool _isCompiling = false;
  bool _isGridMode = false; // Toggle between single and multi-language view

  @override
  void initState() {
    super.initState();
    // No longer listening to editor changes - using 10-second periodic timer instead
  }

  /// Configure auto-refresh with 10-second periodic timer
  void _configureAutoRefresh() {
    final projectConfigAsync = ref.read(projectConfigProvider);
    final projectState = ref.read(projectTreeProvider);
    final projectPath = projectState.projectPath;

    if (projectPath == null || _selectedLanguage == null) return;

    final config = projectConfigAsync.value;
    if (config == null) return;

    final autoRefreshService = ref.read(autoRefreshServiceProvider);

    // Configure the periodic timer
    autoRefreshService.configure(
      projectPath: projectPath,
      languageCode: _selectedLanguage!,
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
        setState(() {
          _pdfPath = pdfPath;
        });
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
    final theme = Theme.of(context);
    final projectConfigAsync = ref.watch(projectConfigProvider);

    return projectConfigAsync.when(
      data: (config) => _buildPanel(context, theme, config),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Failed to load config: $error'),
      ),
    );
  }

  Widget _buildPanel(BuildContext context, ThemeData theme, ProjectConfig? config) {
    final languages = config?.languages ?? [];

    // Default to first language if none selected
    if (_selectedLanguage == null && languages.isNotEmpty) {
      _selectedLanguage = languages.first.code;
    }

    // Initialize auto-refresh based on project settings
    if (config != null) {
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
    }

    // Show grid mode if enabled and config available
    if (_isGridMode && config != null) {
      return LanguageGrid(config: config);
    }

    // Single-language mode (original view)
    return Column(
      children: [
        // Language selector toolbar
        if (languages.isNotEmpty)
          Container(
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
                  value: _selectedLanguage,
                  items: languages.map<DropdownMenuItem<String>>((lang) {
                    return DropdownMenuItem<String>(
                      value: lang.code,
                      child: Text('${lang.name} (${lang.code})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedLanguage = value;
                      });
                      // Trigger recompilation with new language
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
                  icon: Icon(_isGridMode ? Icons.view_agenda : Icons.grid_view),
                  onPressed: () {
                    setState(() {
                      _isGridMode = !_isGridMode;
                    });
                  },
                  tooltip: _isGridMode ? 'Single language view' : 'Multi-language grid view',
                ),

                const SizedBox(width: 8),

                // Detach window button
                IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () {
                    _detachPreview();
                  },
                  tooltip: 'Open preview in new window',
                ),

                const SizedBox(width: 8),

                // Compile button
                FilledButton.icon(
                  onPressed: _isCompiling ? null : () => _compileForLanguage(_selectedLanguage),
                  icon: _isCompiling
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.play_arrow, size: 18),
                  label: Text(_isCompiling ? 'Compiling...' : 'Compile'),
                ),
              ],
            ),
          ),
        // PDF viewer
        Expanded(
          child: PdfViewer(
            pdfPath: _pdfPath,
            languageCode: _selectedLanguage,
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

    setState(() {
      _isCompiling = true;
    });

    try {
      final controller = ref.read(pdfPreviewControllerProvider(languageCode));
      final result = await controller.compile(projectPath: projectPath);

      // Handle CompilationResult using Freezed's when method
      result.when(
        success: (pdfPath, languageCode, compiledAt) {
          setState(() {
            _pdfPath = pdfPath;
            _isCompiling = false;
          });

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
          setState(() {
            _isCompiling = false;
          });

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
      setState(() {
        _isCompiling = false;
      });

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

  /// Detach the preview to a separate window
  void _detachPreview() {
    // Sync state to detachable window
    final notifier = ref.read(detachableWindowProvider.notifier);
    if (_selectedLanguage != null) {
      notifier.setLanguage(_selectedLanguage!);
    }
    if (_pdfPath != null) {
      notifier.setPdfPath(_pdfPath);
    }
    notifier.setCompiling(_isCompiling);
    if (_isGridMode) {
      notifier.toggleGridMode();
    }

    // Open detached window
    detachableWindowService.openDetachedWindow(
      context: context,
      ref: ref,
    );
  }
}
