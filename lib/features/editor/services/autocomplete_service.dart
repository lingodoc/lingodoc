import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/suggestion.dart';

/// Service for providing autocomplete suggestions
class AutocompleteService {
  final String? projectPath;
  List<Suggestion> _projectTerms = [];

  AutocompleteService({this.projectPath}) {
    if (projectPath != null) {
      _loadProjectTerms();
    }
  }

  /// Typst function suggestions
  static final List<Suggestion> _typstFunctions = [
    Suggestion(
      label: '#import',
      insertText: '#import ',
      type: SuggestionType.function,
      description: 'Import external file or module',
      detail: '#import "path.typ": symbol',
    ),
    Suggestion(
      label: '#let',
      insertText: '#let ',
      type: SuggestionType.function,
      description: 'Define variable or function',
      detail: '#let name = value',
    ),
    Suggestion(
      label: '#show',
      insertText: '#show ',
      type: SuggestionType.function,
      description: 'Apply styling to elements',
      detail: '#show selector: function',
    ),
    Suggestion(
      label: '#set',
      insertText: '#set ',
      type: SuggestionType.function,
      description: 'Set document parameters',
      detail: '#set element(param: value)',
    ),
    Suggestion(
      label: '#include',
      insertText: '#include ',
      type: SuggestionType.function,
      description: 'Include content from file',
      detail: '#include "path.typ"',
    ),
    Suggestion(
      label: '#text',
      insertText: '#text(',
      type: SuggestionType.function,
      description: 'Format text',
      detail: '#text(fill: color)[content]',
    ),
    Suggestion(
      label: '#strong',
      insertText: '#strong[',
      type: SuggestionType.function,
      description: 'Make text bold',
      detail: '#strong[text]',
    ),
    Suggestion(
      label: '#emph',
      insertText: '#emph[',
      type: SuggestionType.function,
      description: 'Make text italic',
      detail: '#emph[text]',
    ),
    Suggestion(
      label: '#raw',
      insertText: '#raw(',
      type: SuggestionType.function,
      description: 'Display raw/code text',
      detail: '#raw("text")',
    ),
    Suggestion(
      label: '#heading',
      insertText: '#heading(',
      type: SuggestionType.function,
      description: 'Create heading',
      detail: '#heading(level: 1)[Title]',
    ),
    Suggestion(
      label: '#list',
      insertText: '#list(',
      type: SuggestionType.function,
      description: 'Create list',
      detail: '#list[item1][item2]',
    ),
    Suggestion(
      label: '#table',
      insertText: '#table(',
      type: SuggestionType.function,
      description: 'Create table',
      detail: '#table(columns: 2)[A][B][C][D]',
    ),
    Suggestion(
      label: '#image',
      insertText: '#image(',
      type: SuggestionType.function,
      description: 'Insert image',
      detail: '#image("path.png")',
    ),
    Suggestion(
      label: '#figure',
      insertText: '#figure(',
      type: SuggestionType.function,
      description: 'Create figure with caption',
      detail: '#figure(image("path.png"), caption: [...])',
    ),
    Suggestion(
      label: '#link',
      insertText: '#link(',
      type: SuggestionType.function,
      description: 'Create hyperlink',
      detail: '#link("url")[text]',
    ),
    Suggestion(
      label: '#box',
      insertText: '#box(',
      type: SuggestionType.function,
      description: 'Create inline box',
      detail: '#box[content]',
    ),
    Suggestion(
      label: '#block',
      insertText: '#block(',
      type: SuggestionType.function,
      description: 'Create block container',
      detail: '#block[content]',
    ),
    Suggestion(
      label: '#page',
      insertText: '#page(',
      type: SuggestionType.function,
      description: 'Configure page settings',
      detail: '#page(width: 210mm, height: 297mm)',
    ),
    Suggestion(
      label: '#align',
      insertText: '#align(',
      type: SuggestionType.function,
      description: 'Align content',
      detail: '#align(center)[content]',
    ),
    Suggestion(
      label: '#grid',
      insertText: '#grid(',
      type: SuggestionType.function,
      description: 'Create grid layout',
      detail: '#grid(columns: 2)[A][B]',
    ),
  ];

  /// Typst keyword suggestions
  static final List<Suggestion> _typstKeywords = [
    Suggestion(
      label: 'if',
      insertText: 'if ',
      type: SuggestionType.keyword,
      description: 'Conditional statement',
      detail: 'if condition { ... }',
    ),
    Suggestion(
      label: 'else',
      insertText: 'else ',
      type: SuggestionType.keyword,
      description: 'Else clause',
      detail: 'else { ... }',
    ),
    Suggestion(
      label: 'for',
      insertText: 'for ',
      type: SuggestionType.keyword,
      description: 'For loop',
      detail: 'for item in collection { ... }',
    ),
    Suggestion(
      label: 'while',
      insertText: 'while ',
      type: SuggestionType.keyword,
      description: 'While loop',
      detail: 'while condition { ... }',
    ),
    Suggestion(
      label: 'in',
      insertText: 'in ',
      type: SuggestionType.keyword,
      description: 'In operator',
      detail: 'key in dict',
    ),
    Suggestion(
      label: 'not',
      insertText: 'not ',
      type: SuggestionType.keyword,
      description: 'Logical not',
      detail: 'not condition',
    ),
    Suggestion(
      label: 'and',
      insertText: 'and ',
      type: SuggestionType.keyword,
      description: 'Logical and',
      detail: 'condition1 and condition2',
    ),
    Suggestion(
      label: 'or',
      insertText: 'or ',
      type: SuggestionType.keyword,
      description: 'Logical or',
      detail: 'condition1 or condition2',
    ),
    Suggestion(
      label: 'return',
      insertText: 'return ',
      type: SuggestionType.keyword,
      description: 'Return value',
      detail: 'return value',
    ),
    Suggestion(
      label: 'break',
      insertText: 'break',
      type: SuggestionType.keyword,
      description: 'Break loop',
      detail: 'break',
    ),
    Suggestion(
      label: 'continue',
      insertText: 'continue',
      type: SuggestionType.keyword,
      description: 'Continue to next iteration',
      detail: 'continue',
    ),
    Suggestion(
      label: 'true',
      insertText: 'true',
      type: SuggestionType.keyword,
      description: 'Boolean true',
      detail: 'true',
    ),
    Suggestion(
      label: 'false',
      insertText: 'false',
      type: SuggestionType.keyword,
      description: 'Boolean false',
      detail: 'false',
    ),
    Suggestion(
      label: 'none',
      insertText: 'none',
      type: SuggestionType.keyword,
      description: 'None/null value',
      detail: 'none',
    ),
    Suggestion(
      label: 'auto',
      insertText: 'auto',
      type: SuggestionType.keyword,
      description: 'Automatic value',
      detail: 'auto',
    ),
  ];

  /// Typst markup suggestions
  static final List<Suggestion> _typstMarkup = [
    Suggestion(
      label: '*bold*',
      insertText: '*',
      type: SuggestionType.markup,
      description: 'Bold text',
      detail: '*text*',
    ),
    Suggestion(
      label: '_italic_',
      insertText: '_',
      type: SuggestionType.markup,
      description: 'Italic text',
      detail: '_text_',
    ),
    Suggestion(
      label: '`code`',
      insertText: '`',
      type: SuggestionType.markup,
      description: 'Inline code',
      detail: '`code`',
    ),
    Suggestion(
      label: '= Heading',
      insertText: '= ',
      type: SuggestionType.markup,
      description: 'Level 1 heading',
      detail: '= Title',
    ),
    Suggestion(
      label: '== Heading',
      insertText: '== ',
      type: SuggestionType.markup,
      description: 'Level 2 heading',
      detail: '== Subtitle',
    ),
    Suggestion(
      label: '- List',
      insertText: '- ',
      type: SuggestionType.markup,
      description: 'Bullet list',
      detail: '- Item',
    ),
    Suggestion(
      label: '+ List',
      insertText: '+ ',
      type: SuggestionType.markup,
      description: 'Numbered list',
      detail: '+ Item',
    ),
    Suggestion(
      label: '/ Term:',
      insertText: '/ ',
      type: SuggestionType.markup,
      description: 'Definition list',
      detail: '/ Term: Definition',
    ),
    Suggestion(
      label: '---',
      insertText: '---',
      type: SuggestionType.markup,
      description: 'Horizontal rule',
      detail: '---',
    ),
    Suggestion(
      label: '```code```',
      insertText: '```\n',
      type: SuggestionType.markup,
      description: 'Code block',
      detail: '```lang\ncode\n```',
    ),
  ];

  /// Load project-specific terms from terms.typ
  Future<void> _loadProjectTerms() async {
    if (projectPath == null) return;

    try {
      final termsFile = File(path.join(projectPath!, 'terms.typ'));
      if (!await termsFile.exists()) return;

      final content = await termsFile.readAsString();
      final terms = _parseTermsFile(content);

      _projectTerms = terms
          .map((term) => Suggestion(
                label: '#term($term)',
                insertText: '#term($term)',
                type: SuggestionType.term,
                description: 'Project term: $term',
                detail: 'From terms.typ',
              ))
          .toList();
    } catch (e) {
      // Silently fail if terms.typ cannot be parsed
      _projectTerms = [];
    }
  }

  /// Parse terms.typ file to extract term keys
  List<String> _parseTermsFile(String content) {
    final terms = <String>[];
    final lines = content.split('\n');

    bool inTermsBlock = false;
    for (final line in lines) {
      final trimmed = line.trim();

      // Detect start of terms dictionary
      if (trimmed.startsWith('#let terms = (')) {
        inTermsBlock = true;
        continue;
      }

      // Detect end of terms dictionary
      if (inTermsBlock && trimmed == ')') {
        break;
      }

      // Parse term definitions
      if (inTermsBlock && trimmed.isNotEmpty && !trimmed.startsWith('//')) {
        // Match pattern: key: "value",
        final match = RegExp(r'^([a-zA-Z0-9_-]+)\s*:').firstMatch(trimmed);
        if (match != null) {
          terms.add(match.group(1)!);
        }
      }
    }

    return terms;
  }



  /// Get all suggestions matching the prefix
  List<Suggestion> getSuggestions(String prefix) {
    if (prefix.isEmpty) return [];

    final lowerPrefix = prefix.toLowerCase();
    final allSuggestions = [
      ..._typstFunctions,
      ..._typstKeywords,
      ..._typstMarkup,
      ..._projectTerms,
    ];

    return allSuggestions
        .where((s) => s.label.toLowerCase().startsWith(lowerPrefix))
        .toList();
  }

  /// Get context-aware suggestions based on cursor position
  List<Suggestion> getContextSuggestions(String text, int cursorPosition) {
    // Get text before cursor
    final beforeCursor = text.substring(0, cursorPosition);
    final lastWord = _getLastWord(beforeCursor);

    if (lastWord.isEmpty) return [];

    // Context-aware filtering
    if (lastWord.startsWith('#')) {
      // Function context
      return getSuggestions(lastWord)
          .where((s) =>
              s.type == SuggestionType.function || s.type == SuggestionType.term)
          .toList();
    } else if (lastWord.startsWith('*') ||
        lastWord.startsWith('_') ||
        lastWord.startsWith('`')) {
      // Markup context
      return getSuggestions(lastWord)
          .where((s) => s.type == SuggestionType.markup)
          .toList();
    } else {
      // General context - all suggestions
      return getSuggestions(lastWord);
    }
  }

  /// Extract the last word before cursor
  String _getLastWord(String text) {
    if (text.isEmpty) return '';

    // Find last word boundary (space, newline, or start)
    final match = RegExp(r'([#*_`=\-+/a-zA-Z0-9_-]*)$').firstMatch(text);
    return match?.group(1) ?? '';
  }

  /// Reload project terms (call when terms.typ changes)
  Future<void> reloadProjectTerms() async {
    await _loadProjectTerms();
  }
}
