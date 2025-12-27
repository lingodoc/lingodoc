import 'package:flutter/foundation.dart';

/// Represents an autocomplete suggestion
@immutable
class Suggestion {
  final String label;
  final String insertText;
  final SuggestionType type;
  final String? description;
  final String? detail;

  const Suggestion({
    required this.label,
    required this.insertText,
    required this.type,
    this.description,
    this.detail,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Suggestion &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          type == other.type;

  @override
  int get hashCode => Object.hash(label, type);
}

/// Type of autocomplete suggestion
enum SuggestionType {
  /// Typst function (e.g., #import, #let, #show)
  function,

  /// Typst keyword (e.g., if, for, while)
  keyword,

  /// Typst markup command (e.g., *bold*, _italic_)
  markup,

  /// Project-specific term from terms.typ
  term,

  /// Language code or content
  language,
}

/// Extension for SuggestionType display
extension SuggestionTypeExt on SuggestionType {
  String get icon {
    switch (this) {
      case SuggestionType.function:
        return '⚡';
      case SuggestionType.keyword:
        return '🔑';
      case SuggestionType.markup:
        return '✨';
      case SuggestionType.term:
        return '📚';
      case SuggestionType.language:
        return '🌐';
    }
  }

  String get label {
    switch (this) {
      case SuggestionType.function:
        return 'Function';
      case SuggestionType.keyword:
        return 'Keyword';
      case SuggestionType.markup:
        return 'Markup';
      case SuggestionType.term:
        return 'Term';
      case SuggestionType.language:
        return 'Language';
    }
  }
}
