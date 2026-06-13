import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pdf_viewer.dart';
import 'language_grid.dart';
import '../services/preview_provider.dart';
import '../services/auto_refresh_service.dart';
import '../services/detachable_window_service.dart';
import '../services/sync_controller.dart';
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

  // Track configuration state to prevent unnecessary reconfiguration
  String? _lastConfiguredProjectPath;
  String? _lastConfiguredLanguage;
  String? _lastConfiguredOutputDir;
  bool _autoRefreshInitialized = false;

  // Cached so dispose() can stop the loop without touching `ref` (unsafe during
  // unmount in Riverpod 3).
  AutoRefreshService? _autoRefreshService;

  // Last compile error surfaced to the user, to avoid re-notifying every
  // 10-second auto-refresh tick for the same failure.
  String? _lastNotifiedCompileError;

  /// Extract a concise, human-useful reason from a compilation failure.
  String _compileErrorSummary(String? stderr, String fallback) {
    final text = stderr?.trim() ?? '';
    if (text.isEmpty) return fallback;
    // Prefer the first Typst "error: …" line; otherwise the first non-empty line.
    for (final line in text.split('\n')) {
      final t = line.trim();
      if (t.startsWith('error:')) return t.substring('error:'.length).trim();
    }
    return text.split('\n').first.trim();
  }

  @override
  void initState() {
    super.initState();
    // Cache the service now so dispose() can stop it without using `ref`.
    _autoRefreshService = ref.read(autoRefreshServiceProvider);
    // No longer listening to editor changes - using 10-second periodic timer instead
  }

  @override
  void dispose() {
    // Stop the auto-refresh compile loop when the panel is removed (preview
    // switched off or detached) so it never keeps recompiling in the background.
    _autoRefreshService?.stop();
    super.dispose();
  }

  /// Configure auto-refresh with 10-second periodic timer
  ///
  /// [config] - The already-loaded project configuration (required to avoid
  /// re-reading the FutureProvider which may not have resolved yet)
  void _configureAutoRefresh(ProjectConfig config) {
    final projectState = ref.read(projectTreeProvider);
    final projectPath = projectState.projectPath;

    if (projectPath == null || _selectedLanguage == null) return;

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
        _lastNotifiedCompileError = null; // allow re-notifying on next failure
        if (languageCode != null) _refreshSyncAnchors(languageCode);
      },
      error: (message, languageCode, stderr, exitCode) {
        ref.read(autoRefreshProvider.notifier).setError(message);
        // Surface the failure to the user once per distinct error (auto-refresh
        // retries every 10s, so we must not spam the same message).
        final summary = _compileErrorSummary(stderr, message);
        if (summary != _lastNotifiedCompileError) {
          _lastNotifiedCompileError = summary;
          _notifyCompileFailed(summary);
        }
      },
    );
  }

  /// Show a compilation-failure notification with the underlying reason.
  void _notifyCompileFailed(String summary) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Compilation failed — $summary'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 6),
        ),
      );
  }

  /// Guard so anchor probes never overlap. The probe runs a full document
  /// query; without this, the 10-second auto-refresh could stack concurrent
  /// probes and exhaust system resources on large projects.
  bool _syncProbeRunning = false;

  /// Rebuild the editor↔PDF anchor map after a successful compile.
  ///
  /// Best-effort and non-blocking: injects line-tagged markers and runs
  /// `typst query` to locate every paragraph/heading in the freshly compiled
  /// PDF, then feeds the anchors to the shared [SyncController].
  Future<void> _refreshSyncAnchors(String languageCode) async {
    if (_syncProbeRunning) return; // single-flight
    final projectPath = ref.read(projectTreeProvider).projectPath;
    if (projectPath == null) return;
    _syncProbeRunning = true;
    try {
      final compiler = ref.read(typstCompilerProvider);
      final result = await compiler.queryAnchorPositions(
        projectPath: projectPath,
        languageCode: languageCode,
      );
      if (!mounted) return;
      ref
          .read(syncControllerProvider)
          .setAnchors(result.anchors, error: result.error);
    } finally {
      _syncProbeRunning = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectConfigAsync = ref.watch(projectConfigProvider);

    // Notify the user when a folder that lacks config.toml is opened.
    ref.listen<AsyncValue<ProjectConfig?>>(projectConfigProvider, (_, next) {
      next.whenData((config) {
        final projectPath = ref.read(projectTreeProvider).projectPath;
        if (config == null && projectPath != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No config.toml found in "$projectPath". '
                'LingoDoc cannot compile without a project configuration.',
              ),
              backgroundColor: Colors.orange.shade700,
              duration: const Duration(seconds: 6),
            ),
          );
        }
      });
    });

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

    // Detect project change and clear stale PDF regardless of config availability.
    // This must run before the config == null guard so switching to a folder
    // without config.toml immediately removes the previous project's PDF.
    final currentProjectPath = ref.read(projectTreeProvider).projectPath;
    if (currentProjectPath != _lastConfiguredProjectPath &&
        _lastConfiguredProjectPath != null) {
      _selectedLanguage = null;
      _pdfPath = null;
      _autoRefreshInitialized = false;
      _lastConfiguredLanguage = null;
      _lastConfiguredOutputDir = null;
    }

    // No config.toml: stop here and show a helpful error state.
    if (config == null) {
      _lastConfiguredProjectPath = currentProjectPath;
      return _buildNoConfigState(context, theme, currentProjectPath);
    }

    // config is non-null from here (null case returned early above).
    final projectPath = currentProjectPath;
    final outputDir = config.projectSettings.outputDirectory;

    // Default to first language if none selected
    if (_selectedLanguage == null && languages.isNotEmpty) {
      _selectedLanguage = languages.first.code;
    }

    // Only reconfigure if settings actually changed
    final needsReconfigure =
        projectPath != _lastConfiguredProjectPath ||
        _selectedLanguage != _lastConfiguredLanguage ||
        outputDir != _lastConfiguredOutputDir ||
        !_autoRefreshInitialized;

    if (needsReconfigure && _selectedLanguage != null) {
      // wasInitialized is false both on first load and after a project switch
      // (because _autoRefreshInitialized was reset above when projectPath changed).
      final wasInitialized = _autoRefreshInitialized;
      _lastConfiguredProjectPath = projectPath;
      _lastConfiguredLanguage = _selectedLanguage;
      _lastConfiguredOutputDir = outputDir;
      _autoRefreshInitialized = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final shouldBeEnabled = config.projectSettings.autoCompile;
        final autoRefreshService = ref.read(autoRefreshServiceProvider);

        if (shouldBeEnabled) {
          ref.read(autoRefreshProvider.notifier).enable();
          _configureAutoRefresh(config);
          autoRefreshService.start();
        } else {
          ref.read(autoRefreshProvider.notifier).disable();
          autoRefreshService.stop();
        }

        // Trigger immediate compilation on first load and on every project switch.
        if (!wasInitialized) {
          _compileForLanguage(_selectedLanguage!);
        }
      });
    }

    // Show grid mode if enabled and config available
    if (_isGridMode) {
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
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
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
                        _compileForLanguage(value);
                        _configureAutoRefresh(config);
                      }
                    },
                  ),
                ),

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
                              _configureAutoRefresh(config);
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

                // Continuous editor→PDF sync toggle
                ValueListenableBuilder<bool>(
                  valueListenable:
                      ref.read(syncControllerProvider).continuousEnabled,
                  builder: (context, enabled, _) {
                    return IconButton(
                      icon: Icon(enabled ? Icons.link : Icons.link_off),
                      color: enabled ? theme.colorScheme.primary : null,
                      onPressed: () =>
                          ref.read(syncControllerProvider).toggleContinuous(),
                      tooltip: enabled
                          ? 'PDF follows editor caret (Ctrl+Alt+J) — on'
                          : 'PDF follows editor caret (Ctrl+Alt+J) — off',
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
            syncController: ref.read(syncControllerProvider),
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

  /// Shown when the current project folder has no config.toml.
  Widget _buildNoConfigState(
      BuildContext context, ThemeData theme, String? projectPath) {
    // No project open at all — show the normal empty-preview placeholder.
    if (projectPath == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.picture_as_pdf_outlined,
                size: 64, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No PDF loaded',
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Compile a document to view the preview',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    // Project is open but config.toml is missing.
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_off_outlined,
                size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'No config.toml found',
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.error),
            ),
            const SizedBox(height: 8),
            Text(
              projectPath,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'LingoDoc needs a config.toml to know which languages are '
              'configured and where to write the compiled PDF.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Open a folder that contains a config.toml, or create one '
              'with the "New Project" wizard.',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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

    setState(() {
      _isCompiling = true;
    });

    try {
      final controller = ref.read(pdfPreviewControllerProvider(languageCode));
      final result = await controller.compile(projectPath: projectPath);

      if (!mounted) return;
      // Handle CompilationResult using Freezed's when method
      result.when(
        success: (pdfPath, languageCode, compiledAt) {
          setState(() {
            _pdfPath = pdfPath;
            _isCompiling = false;
          });

          _lastNotifiedCompileError = null;
          if (languageCode != null) _refreshSyncAnchors(languageCode);

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
          final summary = _compileErrorSummary(stderr, message);
          _lastNotifiedCompileError = summary;
          _notifyCompileFailed(summary);
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
