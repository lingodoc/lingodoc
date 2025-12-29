import 'package:highlight/highlight.dart' show Mode;

/// Typst language mode for syntax highlighting
///
/// Defines highlighting rules for Typst markup language including:
/// - Keywords: let, if, else, for, import, include, show, set
/// - Built-in functions: strong, emph, text, image, table, etc.
/// - Comments: // and /* */
/// - Strings: "quoted" and `raw`
/// - Functions/commands: #function-name
/// - Content blocks: [content]
/// - Math mode: $equation$
final Mode typstMode = Mode(
  refs: {},
  case_insensitive: false,
  keywords: {
    'keyword': 'let if else for while import include show set',
    'built_in': 'strong emph text image table figure quote cite ref link heading list enum grid box rect circle ellipse line polygon path',
    'literal': 'true false none auto',
  },
  contains: [
    // Single-line comments: // comment
    Mode(
      className: 'comment',
      begin: r'//',
      end: r'$',
      relevance: 0,
    ),

    // Multi-line comments: /* comment */
    Mode(
      className: 'comment',
      begin: r'/\*',
      end: r'\*/',
      relevance: 0,
    ),

    // Double-quoted strings: "text"
    Mode(
      className: 'string',
      begin: '"',
      end: '"',
      contains: [
        Mode(begin: r'\\.') // Escape sequences
      ],
    ),

    // Raw strings (backticks): `raw text`
    Mode(
      className: 'string',
      begin: '`',
      end: '`',
    ),

    // Functions and commands: #function-name
    Mode(
      className: 'function',
      begin: r'#[a-zA-Z_][a-zA-Z0-9_-]*',
      relevance: 10,
    ),

    // Content blocks: [content]
    Mode(
      className: 'section',
      begin: r'\[',
      end: r'\]',
      relevance: 0,
    ),

    // Math mode: $x^2$
    Mode(
      className: 'formula',
      begin: r'\$',
      end: r'\$',
      relevance: 0,
    ),

    // Numbers
    Mode(
      className: 'number',
      begin: r'\b\d+\.?\d*',
      relevance: 0,
    ),
  ],
);
