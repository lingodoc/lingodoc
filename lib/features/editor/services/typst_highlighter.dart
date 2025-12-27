import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';

/// Custom Typst syntax highlighting configuration
class TypstHighlighter {
  /// Get theme based on brightness
  static Map<String, TextStyle> getTheme(Brightness brightness) {
    return brightness == Brightness.dark ? monokaiSublimeTheme : githubTheme;
  }

  /// Typst language definition for syntax highlighting
  static const Map<String, dynamic> typstLanguage = {
    'case_insensitive': false,
    'keywords': {
      '\$keyword': [
        'let',
        'set',
        'show',
        'import',
        'include',
        'if',
        'else',
        'for',
        'while',
        'return',
        'break',
        'continue',
        'and',
        'or',
        'not',
        'in',
        'as',
      ],
    },
    'contains': [
      // Headings
      {
        'className': 'section',
        'begin': r'^(={1,6})\s',
        'end': r'$',
      },
      // Code blocks
      {
        'className': 'code',
        'begin': r'```',
        'end': r'```',
      },
      // Inline code
      {
        'className': 'code',
        'begin': r'`',
        'end': r'`',
      },
      // Comments
      {
        'className': 'comment',
        'begin': r'//',
        'end': r'$',
      },
      {
        'className': 'comment',
        'begin': r'/\*',
        'end': r'\*/',
      },
      // Strings
      {
        'className': 'string',
        'begin': r'"',
        'end': r'"',
        'contains': [
          {
            'className': 'subst',
            'begin': r'\\.',
          }
        ],
      },
      // Functions
      {
        'className': 'function',
        'begin': r'#[a-zA-Z_][a-zA-Z0-9_-]*',
      },
      // Variables/fields
      {
        'className': 'attr',
        'begin': r'[a-zA-Z_][a-zA-Z0-9_-]*\s*:',
      },
      // Numbers
      {
        'className': 'number',
        'begin': r'\b\d+(\.\d+)?(pt|mm|cm|in|em|%)?',
      },
      // Content blocks []
      {
        'className': 'params',
        'begin': r'\[',
        'end': r'\]',
      },
      // Math mode
      {
        'className': 'formula',
        'begin': r'\$',
        'end': r'\$',
      },
    ],
  };

  /// Apply Typst-specific styling to code
  static TextStyle getStyleForToken(String className, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    switch (className) {
      case 'keyword':
        return TextStyle(
          color: isDark ? const Color(0xFFFF79C6) : const Color(0xFFD73A49),
          fontWeight: FontWeight.bold,
        );
      case 'function':
        return TextStyle(
          color: isDark ? const Color(0xFF50FA7B) : const Color(0xFF005CC5),
        );
      case 'string':
        return TextStyle(
          color: isDark ? const Color(0xFFF1FA8C) : const Color(0xFF032F62),
        );
      case 'comment':
        return TextStyle(
          color: isDark ? const Color(0xFF6272A4) : const Color(0xFF6A737D),
          fontStyle: FontStyle.italic,
        );
      case 'number':
        return TextStyle(
          color: isDark ? const Color(0xFFBD93F9) : const Color(0xFF005CC5),
        );
      case 'section':
        return TextStyle(
          color: isDark ? const Color(0xFF8BE9FD) : const Color(0xFF22863A),
          fontWeight: FontWeight.bold,
        );
      case 'formula':
        return TextStyle(
          color: isDark ? const Color(0xFFFFB86C) : const Color(0xFFE36209),
        );
      default:
        return TextStyle(
          color: isDark ? const Color(0xFFF8F8F2) : const Color(0xFF24292E),
        );
    }
  }
}
