import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/typst_syntax_highlighter.dart';
import '../services/autocomplete_service.dart';
import '../services/editor_service.dart';
import '../models/suggestion.dart';

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
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late AutocompleteService _autocompleteService;
  bool _isDirty = false;
  bool _showAutocomplete = false;
  List<Suggestion> _suggestions = [];
  Timer? _autoSaveTimer; // Auto-save timer

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
    _focusNode = FocusNode();
    _autocompleteService = AutocompleteService(projectPath: widget.projectPath);
    _controller.addListener(_onTextChanged);

    // Start auto-save timer (10 seconds)
    _startAutoSaveTimer();
  }

  @override
  void didUpdateWidget(HighlightedCodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filePath != oldWidget.filePath) {
      _controller.text = widget.initialContent;
      _isDirty = false;
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
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
    if (!_isDirty) {
      setState(() => _isDirty = true);
    }
    widget.onChanged?.call(_controller.text);
    _updateAutocomplete();
  }

  void _updateAutocomplete() {
    if (!_isTypstFile()) {
      setState(() {
        _showAutocomplete = false;
        _suggestions = [];
      });
      return;
    }

    final cursorPosition = _controller.selection.base.offset;
    final suggestions = _autocompleteService.getContextSuggestions(
      _controller.text,
      cursorPosition,
    );

    setState(() {
      _showAutocomplete = suggestions.isNotEmpty;
      _suggestions = suggestions;
    });
  }

  bool _isTypstFile() {
    return widget.filePath?.endsWith('.typ') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          _buildToolbar(theme),
          Expanded(
            child: Shortcuts(
              shortcuts: {
                LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS): const _SaveIntent(),
              },
              child: Actions(
                actions: {
                  _SaveIntent: CallbackAction<_SaveIntent>(
                    onInvoke: (_) => _handleSave(),
                  ),
                },
                child: _buildEditor(theme),
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

  Widget _buildEditor(ThemeData theme) {
    // Use syntax-highlighted view for .typ files
    if (_isTypstFile()) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Editor with syntax highlighting
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth - 32, // Account for padding
                    minHeight: constraints.maxHeight - 32,
                  ),
                  child: Stack(
                    children: [
                      // Highlighted code display (read-only visual)
                      SizedBox(
                        width: double.infinity,
                        child: RichText(
                          text: TypstSyntaxHighlighter(
                            brightness: theme.brightness,
                          ).highlight(
                            _controller.text,
                            baseStyle: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                      // Transparent editable TextField overlay
                      SizedBox(
                        width: double.infinity,
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          readOnly: widget.readOnly,
                          maxLines: null,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.transparent, // Make text transparent to show highlighted version
                          ),
                          cursorColor: theme.colorScheme.primary,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Autocomplete overlay
              if (_showAutocomplete && _suggestions.isNotEmpty)
                Positioned(
                  left: 16,
                  top: _calculateAutocompletePosition(),
                  child: _buildAutocompleteOverlay(theme),
                ),
            ],
          );
        },
      );
    }

    // Plain text editor for non-.typ files
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      readOnly: widget.readOnly,
      maxLines: null,
      expands: true,
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 14,
        height: 1.5,
        color: theme.colorScheme.onSurface,
      ),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(16),
        hintText: 'Start typing...',
      ),
      textAlignVertical: TextAlignVertical.top,
    );
  }

  Widget _buildStatusBar(ThemeData theme) {
    final lineCount = _controller.text.split('\n').length;
    final charCount = _controller.text.length;

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
    final text = _controller.text;
    final cursorPos = _controller.selection.base.offset;
    
    // Simple insertion - in real implementation, you'd handle replacement
    final newText = text.substring(0, cursorPos) + 
                   suggestion.insertText + 
                   text.substring(cursorPos);
    
    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(
      offset: cursorPos + suggestion.insertText.length,
    );
    
    setState(() {
      _showAutocomplete = false;
      _suggestions = [];
    });
  }
}

class _SaveIntent extends Intent {
  const _SaveIntent();
}
