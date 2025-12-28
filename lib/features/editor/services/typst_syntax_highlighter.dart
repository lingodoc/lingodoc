import 'package:flutter/material.dart';

/// Custom regex-based Typst syntax highlighter
/// Generates styled TextSpan from Typst code
class TypstSyntaxHighlighter {
  final Brightness brightness;

  TypstSyntaxHighlighter({required this.brightness});

  /// Typst syntax patterns with their corresponding style names
  static final List<_SyntaxPattern> _patterns = [
    // Comments (must come before other patterns to avoid conflicts)
    _SyntaxPattern(
      name: 'comment',
      pattern: RegExp(r'//.*$', multiLine: true),
    ),
    _SyntaxPattern(
      name: 'comment',
      pattern: RegExp(r'/\*[\s\S]*?\*/', multiLine: true),
    ),

    // Strings
    _SyntaxPattern(
      name: 'string',
      pattern: RegExp(r'"(?:[^"\\]|\\.)*"'),
    ),

    // Typst functions (# prefix) - includes method calls like #var.method
    _SyntaxPattern(
      name: 'function',
      pattern: RegExp(r'#[a-zA-Z_][a-zA-Z0-9_-]*(?:\.[a-zA-Z_][a-zA-Z0-9_-]*)*'),
    ),

    // Typst keywords (excluding common English words like 'and', 'or', 'not', 'in', 'as')
    _SyntaxPattern(
      name: 'keyword',
      pattern: RegExp(r'\b(let|set|show|import|include|if|else|for|while|return|break|continue)\b'),
    ),

    // Headings
    _SyntaxPattern(
      name: 'heading',
      pattern: RegExp(r'^={1,6}\s.*$', multiLine: true),
    ),

    // Math mode
    _SyntaxPattern(
      name: 'math',
      pattern: RegExp(r'\$[^$]+\$'),
    ),

    // Numbers with optional units
    _SyntaxPattern(
      name: 'number',
      pattern: RegExp(r'\b\d+(\.\d+)?(pt|mm|cm|in|em|%|deg|rad)?\b'),
    ),

    // Code blocks
    _SyntaxPattern(
      name: 'code',
      pattern: RegExp(r'```[\s\S]*?```', multiLine: true),
    ),

    // Inline code
    _SyntaxPattern(
      name: 'code',
      pattern: RegExp(r'`[^`]+`'),
    ),
  ];

  /// Get color for a syntax element type
  Color _getColor(String name) {
    final isDark = brightness == Brightness.dark;

    switch (name) {
      case 'keyword':
        return isDark ? const Color(0xFFFF79C6) : const Color(0xFFD73A49);
      case 'function':
        return isDark ? const Color(0xFF50FA7B) : const Color(0xFF005CC5);
      case 'string':
        return isDark ? const Color(0xFFF1FA8C) : const Color(0xFF032F62);
      case 'comment':
        return isDark ? const Color(0xFF6272A4) : const Color(0xFF6A737D);
      case 'number':
        return isDark ? const Color(0xFFBD93F9) : const Color(0xFF005CC5);
      case 'heading':
        return isDark ? const Color(0xFF8BE9FD) : const Color(0xFF22863A);
      case 'math':
        return isDark ? const Color(0xFFFFB86C) : const Color(0xFFE36209);
      case 'code':
        return isDark ? const Color(0xFF8BE9FD) : const Color(0xFF005CC5);
      default:
        return isDark ? const Color(0xFFF8F8F2) : const Color(0xFF24292E);
    }
  }

  /// Get TextStyle for a syntax element type
  TextStyle _getStyle(String name, TextStyle baseStyle) {
    TextStyle style = baseStyle.copyWith(color: _getColor(name));

    switch (name) {
      case 'keyword':
        return style.copyWith(fontWeight: FontWeight.bold);
      case 'heading':
        return style.copyWith(fontWeight: FontWeight.bold);
      case 'comment':
        return style.copyWith(fontStyle: FontStyle.italic);
      default:
        return style;
    }
  }

  /// Highlight Typst code and return a TextSpan
  TextSpan highlight(String code, {TextStyle? baseStyle}) {
    baseStyle ??= TextStyle(
      fontFamily: 'monospace',
      fontSize: 14,
      height: 1.5,
      color: _getColor('default'),
    );

    if (code.isEmpty) {
      return TextSpan(text: code, style: baseStyle);
    }

    // Track which characters have been styled
    final List<_StyledSegment> segments = [];

    // Find all pattern matches
    for (final pattern in _patterns) {
      for (final match in pattern.pattern.allMatches(code)) {
        segments.add(_StyledSegment(
          start: match.start,
          end: match.end,
          name: pattern.name,
        ));
      }
    }

    // Sort segments by start position
    segments.sort((a, b) => a.start.compareTo(b.start));

    // Merge overlapping segments (prefer first match)
    final List<_StyledSegment> merged = [];
    for (final segment in segments) {
      if (merged.isEmpty || segment.start >= merged.last.end) {
        merged.add(segment);
      }
    }

    // Build TextSpan children
    final List<TextSpan> children = [];
    int currentPos = 0;

    for (final segment in merged) {
      // Add unstyled text before this segment
      if (currentPos < segment.start) {
        children.add(TextSpan(
          text: code.substring(currentPos, segment.start),
          style: baseStyle,
        ));
      }

      // Add styled segment
      children.add(TextSpan(
        text: code.substring(segment.start, segment.end),
        style: _getStyle(segment.name, baseStyle),
      ));

      currentPos = segment.end;
    }

    // Add remaining unstyled text
    if (currentPos < code.length) {
      children.add(TextSpan(
        text: code.substring(currentPos),
        style: baseStyle,
      ));
    }

    return TextSpan(children: children, style: baseStyle);
  }
}

/// Internal class for syntax patterns
class _SyntaxPattern {
  final String name;
  final RegExp pattern;

  _SyntaxPattern({required this.name, required this.pattern});
}

/// Internal class for tracking styled segments
class _StyledSegment {
  final int start;
  final int end;
  final String name;

  _StyledSegment({
    required this.start,
    required this.end,
    required this.name,
  });
}
