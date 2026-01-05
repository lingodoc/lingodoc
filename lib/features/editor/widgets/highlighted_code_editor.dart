import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/vs.dart'; // Light theme
import 'package:flutter_highlight/themes/vs2015.dart'; // Dark theme
import '../models/typst_language_mode.dart';
import '../services/autocomplete_service.dart';
import '../services/editor_service.dart';
import '../services/search_provider.dart';
import '../models/suggestion.dart';
import 'search_bar_widget.dart';

/// Code editor with Typst syntax highlighting and autocomplete
class HighlightedCodeEditor extends ConsumerStatefulWidget {
  final String initialContent;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final String? filePath;
  final String? projectPath;

  const HighlightedCodeEditor({
    super.key,
    this.initialContent = '',
    this.onChanged,
    this.readOnly = false,
    this.filePath,
    this.projectPath,
  });

  @override
  ConsumerState<HighlightedCodeEditor> createState() => _HighlightedCodeEditorState();
}

class _HighlightedCodeEditorState extends ConsumerState<HighlightedCodeEditor> {
  late CodeController _controller;
  late FocusNode _focusNode;
  late AutocompleteService _autocompleteService;
  bool _isDirty = false;
  bool _showAutocomplete = false;
  List<Suggestion> _suggestions = [];
  Timer? _autoSaveTimer; // Auto-save timer
  Timer? _highlightDebounceTimer; // Debounce timer for autocomplete

  @override
  void initState() {
    super.initState();

    // Initialize autocomplete service
    _autocompleteService = AutocompleteService(projectPath: widget.projectPath);

    // Create controller with Typst language mode
    _controller = CodeController(
      text: widget.initialContent,
      language: typstMode,
    );

    _focusNode = FocusNode();
    _controller.addListener(_onTextChanged);

    // Start auto-save timer (10 seconds)
    _startAutoSaveTimer();
  }

  @override
  void didUpdateWidget(HighlightedCodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update content if file path changed (new file opened)
    if (widget.filePath != oldWidget.filePath) {
      _controller.text = widget.initialContent;
      _isDirty = false;
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _highlightDebounceTimer?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startAutoSaveTimer() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_isDirty && widget.filePath != null) {
        _handleSave();
      }
    });
  }

  void _onTextChanged() {
    // Defer all state changes to avoid calling them during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (!_isDirty) {
          setState(() => _isDirty = true);
        }
        widget.onChanged?.call(_controller.text);

        // Debounce autocomplete updates
        _highlightDebounceTimer?.cancel();
        _highlightDebounceTimer = Timer(const Duration(milliseconds: 150), () {
          if (mounted) {
            _updateAutocomplete();
          }
        });
      }
    });
  }

  void _updateAutocomplete() {
    if (!_isTypstFile()) {
      if (_showAutocomplete) {
        setState(() {
          _showAutocomplete = false;
          _suggestions = [];
        });
      }
      return;
    }

    final cursorPosition = _controller.selection.baseOffset;

    // Guard against invalid cursor position (can be -1 when no selection)
    if (cursorPosition < 0 || cursorPosition > _controller.text.length) {
      if (_showAutocomplete) {
        setState(() {
          _showAutocomplete = false;
          _suggestions = [];
        });
      }
      return;
    }

    final suggestions = _autocompleteService.getContextSuggestions(
      _controller.text,
      cursorPosition,
    );

    // Only update state if something actually changed
    final shouldShow = suggestions.isNotEmpty;
    if (shouldShow != _showAutocomplete || !_listEquals(_suggestions, suggestions)) {
      setState(() {
        _showAutocomplete = shouldShow;
        _suggestions = suggestions;
      });
    }
  }

  // Helper method to compare suggestion lists
  bool _listEquals(List<Suggestion> a, List<Suggestion> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].label != b[i].label) return false;
    }
    return true;
  }

  bool _isTypstFile() {
    return widget.filePath?.endsWith('.typ') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final searchState = ref.watch(searchProvider);

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          _buildToolbar(theme),
          // Search bar at top of editor
          if (searchState.isVisible)
            SearchBarWidget(
              onQueryChanged: (_) => _performSearch(),
              onNext: _navigateToNextMatch,
              onPrevious: _navigateToPreviousMatch,
            ),
          Expanded(
            child: Shortcuts(
              shortcuts: {
                LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS): const _SaveIntent(),
                LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF): const _FindIntent(),
              },
              child: Actions(
                actions: {
                  _SaveIntent: CallbackAction<_SaveIntent>(
                    onInvoke: (_) => _handleSave(),
                  ),
                  _FindIntent: CallbackAction<_FindIntent>(
                    onInvoke: (_) => _handleFind(),
                  ),
                },
                child: _buildEditorWithSearch(theme, isDarkMode),
              ),
            ),
          ),
          _buildStatusBar(theme),
        ],
      ),
    );
  }

  Widget _buildToolbar(ThemeData theme) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.save, size: 18),
            tooltip: 'Save (Ctrl+S)',
            onPressed: _isDirty ? _handleSave : null,
            padding: EdgeInsets.zero,
          ),
          const Spacer(),
          if (_isTypstFile())
            Chip(
              label: const Text('Typst'),
              avatar: const Icon(Icons.code, size: 16),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          const SizedBox(width: 8),
          if (_isDirty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Modified',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditorWithSearch(ThemeData theme, bool isDarkMode) {
    return _buildEditor(theme, isDarkMode);
  }

  Widget _buildEditor(ThemeData theme, bool isDarkMode) {
    // Use flutter_code_editor with syntax highlighting
    return Stack(
      children: [
        CodeTheme(
          data: CodeThemeData(styles: isDarkMode ? vs2015Theme : vsTheme),
          child: CodeField(
            controller: _controller,
            focusNode: _focusNode,
            readOnly: widget.readOnly,
            textStyle: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
            ),
            gutterStyle: GutterStyle(
              showLineNumbers: true,
              textStyle: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              margin: 10,
              width: 40,
            ),
            expands: true,
          ),
        ),
        // Autocomplete overlay
        if (_showAutocomplete && _suggestions.isNotEmpty)
          Positioned(
            left: 80, // Account for line numbers
            top: _calculateAutocompletePosition(),
            child: _buildAutocompleteOverlay(theme),
          ),
      ],
    );
  }

  Widget _buildStatusBar(ThemeData theme) {
    final text = _controller.text;
    final lineCount = text.split('\n').length;
    final charCount = text.length;

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Text('Lines: $lineCount', style: theme.textTheme.bodySmall),
          const SizedBox(width: 16),
          Text('Characters: $charCount', style: theme.textTheme.bodySmall),
          const SizedBox(width: 16),
          if (widget.filePath != null)
            Expanded(
              child: Text(
                widget.filePath!,
                style: theme.textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }

  void _handleSave() async {
    debugPrint('🔧 HighlightedCodeEditor: Save triggered for ${widget.filePath}');

    // Find the tab index for this file
    final editorState = ref.read(editorProvider);
    final tabIndex = editorState.tabs.indexWhere((tab) => tab.filePath == widget.filePath);

    if (tabIndex == -1) {
      debugPrint('❌ HighlightedCodeEditor: Tab not found for ${widget.filePath}');
      return;
    }

    debugPrint('🔧 HighlightedCodeEditor: Calling EditorService.saveTab($tabIndex)');

    // Call the EditorService to save the file
    await ref.read(editorProvider.notifier).saveTab(tabIndex);

    // Mark as not dirty after successful save
    setState(() => _isDirty = false);
  }

  void _handleFind() {
    // Get selected text
    final selection = _controller.selection;
    String? selectedText;

    if (selection.start != selection.end) {
      selectedText = _controller.text.substring(
        selection.start,
        selection.end,
      );
    }

    // Show search bar with selected text (if any)
    ref.read(searchProvider.notifier).show(initialQuery: selectedText);

    // Perform search if we have a query
    if (selectedText != null && selectedText.isNotEmpty) {
      _performSearch();
    }
  }

  void _performSearch() {
    final searchState = ref.read(searchProvider);
    final query = searchState.searchQuery;

    if (query.isEmpty) {
      ref.read(searchProvider.notifier).setMatches(0, 0);
      return;
    }

    final text = _controller.text;
    final matches = <int>[];

    // Simple case-sensitive/insensitive search
    final searchText = searchState.caseSensitive ? text : text.toLowerCase();
    final searchQuery = searchState.caseSensitive ? query : query.toLowerCase();

    int index = 0;
    while (index < searchText.length) {
      final foundIndex = searchText.indexOf(searchQuery, index);
      if (foundIndex == -1) break;

      index = foundIndex;

      // Check whole word if enabled
      if (searchState.wholeWord) {
        final isStartWord = index == 0 || !_isWordChar(text[index - 1]);
        final endIndex = index + query.length;
        final isEndWord = endIndex >= text.length || !_isWordChar(text[endIndex]);

        if (isStartWord && isEndWord) {
          matches.add(index);
        }
      } else {
        matches.add(index);
      }

      index = index + query.length;
    }

    // Update match count
    ref.read(searchProvider.notifier).setMatches(
      matches.isNotEmpty ? 0 : 0,
      matches.length,
    );

    // Navigate to first match if available
    if (matches.isNotEmpty) {
      _navigateToMatch(matches[0]);
    }
  }

  bool _isWordChar(String char) {
    return RegExp(r'[a-zA-Z0-9_]').hasMatch(char);
  }

  void _navigateToNextMatch() {
    final searchState = ref.read(searchProvider);
    if (searchState.totalMatches == 0) return;

    _performSearch();
  }

  void _navigateToPreviousMatch() {
    final searchState = ref.read(searchProvider);
    if (searchState.totalMatches == 0) return;

    _performSearch();
  }

  void _navigateToMatch(int position) {
    final query = ref.read(searchProvider).searchQuery;

    // Set selection to the match
    _controller.selection = TextSelection(
      baseOffset: position,
      extentOffset: position + query.length,
    );

    // Request focus so selection is visible
    _focusNode.requestFocus();
  }

  double _calculateAutocompletePosition() {
    // Simple calculation - in a real implementation, you'd want to calculate
    // based on cursor position and text layout
    return 100.0;
  }

  Widget _buildAutocompleteOverlay(ThemeData theme) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300, maxHeight: 200),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = _suggestions[index];
            return ListTile(
              dense: true,
              leading: Icon(
                _getIconForSuggestionType(suggestion.type.name),
                size: 16,
              ),
              title: Text(
                suggestion.label,
                style: theme.textTheme.bodySmall,
              ),
              subtitle: suggestion.detail != null
                  ? Text(
                      suggestion.detail!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  : null,
              onTap: () {
                _applySuggestion(suggestion);
              },
            );
          },
        ),
      ),
    );
  }

  IconData _getIconForSuggestionType(String type) {
    switch (type) {
      case 'function':
        return Icons.functions;
      case 'variable':
        return Icons.code;
      case 'term':
        return Icons.translate;
      default:
        return Icons.lightbulb_outline;
    }
  }

  void _applySuggestion(Suggestion suggestion) {
    final cursorPos = _controller.selection.baseOffset;
    final currentText = _controller.text;

    // Create new text with suggestion inserted
    final newText = currentText.substring(0, cursorPos) +
        suggestion.insertText +
        currentText.substring(cursorPos);

    // Update controller text
    _controller.text = newText;

    // Move cursor to end of inserted text
    final newCursorPos = cursorPos + suggestion.insertText.length;
    _controller.selection = TextSelection.collapsed(offset: newCursorPos);

    setState(() {
      _showAutocomplete = false;
      _suggestions = [];
    });
  }
}

class _SaveIntent extends Intent {
  const _SaveIntent();
}

class _FindIntent extends Intent {
  const _FindIntent();
}
