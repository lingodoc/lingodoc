import 'package:flutter/material.dart';
import '../models/suggestion.dart';
import '../services/autocomplete_service.dart';

/// Autocomplete widget for code editor
class CodeAutocomplete extends StatefulWidget {
  final String initialContent;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final AutocompleteService autocompleteService;
  final TextStyle? textStyle;

  const CodeAutocomplete({
    super.key,
    this.initialContent = '',
    this.onChanged,
    this.readOnly = false,
    required this.autocompleteService,
    this.textStyle,
  });

  @override
  State<CodeAutocomplete> createState() => _CodeAutocompleteState();
}

class _CodeAutocompleteState extends State<CodeAutocomplete> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(CodeAutocomplete oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialContent != oldWidget.initialContent) {
      _controller.text = widget.initialContent;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<Suggestion>(
      focusNode: _focusNode,
      textEditingController: _controller,
      optionsBuilder: (TextEditingValue textEditingValue) {
        final cursorPosition = textEditingValue.selection.base.offset;
        return widget.autocompleteService.getContextSuggestions(
          textEditingValue.text,
          cursorPosition,
        );
      },
      onSelected: (Suggestion suggestion) {
        _insertSuggestion(suggestion);
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<Suggestion> onSelected,
        Iterable<Suggestion> options,
      ) {
        return _buildSuggestionsOverlay(context, onSelected, options.toList());
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          readOnly: widget.readOnly,
          maxLines: null,
          expands: true,
          style: widget.textStyle ??
              const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                height: 1.5,
              ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(16),
            hintText: 'Start typing...',
          ),
          textAlignVertical: TextAlignVertical.top,
          onChanged: widget.onChanged,
        );
      },
    );
  }

  Widget _buildSuggestionsOverlay(
    BuildContext context,
    AutocompleteOnSelected<Suggestion> onSelected,
    List<Suggestion> suggestions,
  ) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 8.0,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(
            maxHeight: 300,
            maxWidth: 400,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.dividerColor,
              width: 1,
            ),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(4),
            shrinkWrap: true,
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return _buildSuggestionItem(
                context,
                suggestion,
                () => onSelected(suggestion),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(
    BuildContext context,
    Suggestion suggestion,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Icon based on type
            Text(
              suggestion.type.icon,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),

            // Suggestion label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (suggestion.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      suggestion.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Type label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getTypeColor(theme, suggestion.type).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                suggestion.type.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getTypeColor(theme, suggestion.type),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(ThemeData theme, SuggestionType type) {
    switch (type) {
      case SuggestionType.function:
        return theme.colorScheme.primary;
      case SuggestionType.keyword:
        return theme.colorScheme.secondary;
      case SuggestionType.markup:
        return theme.colorScheme.tertiary;
      case SuggestionType.term:
        return theme.colorScheme.primaryContainer;
      case SuggestionType.language:
        return theme.colorScheme.secondaryContainer;
    }
  }

  void _insertSuggestion(Suggestion suggestion) {
    final currentText = _controller.text;
    final cursorPosition = _controller.selection.base.offset;

    // Find the start of the word being completed
    final beforeCursor = currentText.substring(0, cursorPosition);
    final lastWordStart = _findLastWordStart(beforeCursor);

    // Replace the partial word with the suggestion
    final newText = currentText.substring(0, lastWordStart) +
        suggestion.insertText +
        currentText.substring(cursorPosition);

    // Update controller
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: lastWordStart + suggestion.insertText.length,
      ),
    );

    // Notify parent
    widget.onChanged?.call(newText);
  }

  int _findLastWordStart(String text) {
    if (text.isEmpty) return 0;

    // Find last word boundary (space, newline, or special character)
    for (int i = text.length - 1; i >= 0; i--) {
      final char = text[i];
      if (char == ' ' || char == '\n' || char == '\t') {
        return i + 1;
      }
      // Don't break on these characters as they're part of Typst syntax
      if (!(char == '#' ||
          char == '*' ||
          char == '_' ||
          char == '`' ||
          char == '=' ||
          char == '-' ||
          char == '+' ||
          char == '/' ||
          char.contains(RegExp(r'[a-zA-Z0-9_-]')))) {
        return i + 1;
      }
    }

    return 0;
  }
}
