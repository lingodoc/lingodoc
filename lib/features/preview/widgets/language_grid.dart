import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pdf_viewer.dart';
import '../../project/models/project_config.dart';
import '../services/preview_provider.dart';
import '../../project/services/project_state.dart';
import '../../typst/models/compilation_result.dart';

/// Multi-language preview grid with column selector
class LanguageGrid extends ConsumerStatefulWidget {
  final ProjectConfig config;

  const LanguageGrid({
    super.key,
    required this.config,
  });

  @override
  ConsumerState<LanguageGrid> createState() => _LanguageGridState();
}

class _LanguageGridState extends ConsumerState<LanguageGrid> {
  // Track which languages are selected for display
  final Map<String, bool> _selectedLanguages = {};

  // Track PDF paths for each language
  final Map<String, String?> _pdfPaths = {};

  // Track compilation state
  bool _isCompiling = false;
  int _compilingCount = 0;
  
  // Synchronized scrolling state
  final ValueNotifier<Matrix4?> _sharedMatrixNotifier = ValueNotifier(null);
  String? _currentScrollingLanguage;

  @override
  void initState() {
    super.initState();

    // Initialize all languages as selected by default
    for (final lang in widget.config.languages) {
      _selectedLanguages[lang.code] = true;
    }
  }
  
  @override
  void dispose() {
    _sharedMatrixNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedLangs = _selectedLanguages.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    return Column(
      children: [
        // Toolbar with language column selector
        _buildToolbar(theme, selectedLangs),

        // Grid of PDF viewers
        Expanded(
          child: selectedLangs.isEmpty
              ? _buildEmptyState(theme)
              : _buildGrid(theme, selectedLangs),
        ),
      ],
    );
  }

  Widget _buildToolbar(ThemeData theme, List<String> selectedLangs) {
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
          // Language column selector
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: widget.config.languages.map((lang) {
                return FilterChip(
                  label: Text('${lang.name} (${lang.code})'),
                  selected: _selectedLanguages[lang.code] ?? false,
                  onSelected: (selected) {
                    setState(() {
                      _selectedLanguages[lang.code] = selected;
                    });
                  },
                  showCheckmark: true,
                );
              }).toList(),
            ),
          ),

          const SizedBox(width: 16),

          // Compile all button
          FilledButton.icon(
            onPressed: _isCompiling ? null : _compileAll,
            icon: _isCompiling
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.play_arrow, size: 18),
            label: Text(_isCompiling
                ? 'Compiling ($_compilingCount/${selectedLangs.length})...'
                : 'Compile All'),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(ThemeData theme, List<String> selectedLangs) {
    // Determine grid columns based on selected language count
    final columnCount = selectedLangs.length <= 1 ? 1
        : selectedLangs.length == 2 ? 2
        : selectedLangs.length == 3 ? 3
        : 2; // For 4+ languages, use 2 columns

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
        childAspectRatio: 0.7, // Aspect ratio for A4-ish PDFs
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: selectedLangs.length,
      itemBuilder: (context, index) {
        final langCode = selectedLangs[index];
        final lang = widget.config.languages.firstWhere(
          (l) => l.code == langCode,
        );

        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Language label
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                color: theme.colorScheme.primaryContainer,
                child: Text(
                  '${lang.name} (${lang.code})',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // PDF viewer with synchronized scrolling
              Expanded(
                child: PdfViewer(
                  pdfPath: _pdfPaths[langCode],
                  languageCode: langCode,
                  externalMatrixNotifier: _sharedMatrixNotifier,
                  onMatrixChanged: (matrix) {
                    // Only update if this viewer is the one being scrolled
                    if (_currentScrollingLanguage == null || _currentScrollingLanguage == langCode) {
                      _currentScrollingLanguage = langCode;
                      _sharedMatrixNotifier.value = matrix;
                      // Reset after a short delay to allow other viewers to catch up
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (_currentScrollingLanguage == langCode) {
                          _currentScrollingLanguage = null;
                        }
                      });
                    }
                  },
                  onError: () {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to load PDF for ${lang.name}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.grid_view_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No languages selected',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select at least one language to view',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _compileAll() async {
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

    final selectedLangs = _selectedLanguages.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedLangs.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No languages selected'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _isCompiling = true;
      _compilingCount = 0;
    });

    try {
      // Compile all selected languages sequentially
      for (final langCode in selectedLangs) {
        final controller = ref.read(pdfPreviewControllerProvider(langCode));
        final result = await controller.compile(projectPath: projectPath);

        result.when(
          success: (pdfPath, languageCode, compiledAt) {
            setState(() {
              if (languageCode != null) {
                _pdfPaths[languageCode] = pdfPath;
              }
              _compilingCount++;
            });
          },
          error: (message, languageCode, stderr, exitCode) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to compile $languageCode: $message'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
            setState(() {
              _compilingCount++;
            });
          },
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Compiled ${selectedLangs.length} language(s)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Compilation error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isCompiling = false;
        _compilingCount = 0;
      });
    }
  }
}
