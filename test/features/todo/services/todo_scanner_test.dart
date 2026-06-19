import 'package:flutter_test/flutter_test.dart';
import 'package:lingodoc/features/todo/services/todo_scanner.dart';

void main() {
  const scanner = TodoScanner();
  const codes = ['en', 'es', 'fr', 'nl', 'de'];

  group('TodoScanner', () {
    test('finds a general todo with message, no user, document-level', () {
      const src = '''
#import "../lang.typ": current-lang

// todo: rewrite this intro
Some content.
''';
      final todos = scanner.scan(src, codes);
      expect(todos.length, 1);
      expect(todos.first.line, 3); // 1-based
      expect(todos.first.user, isNull);
      expect(todos.first.message, 'rewrite this intro');
      expect(todos.first.blockId, isNull);
      expect(todos.first.lang, isNull);
    });

    test('parses assigned todo with and without @ and colon', () {
      const src = '''
// todo(jo): translate to es
// todo(@maria) check term usage
''';
      final todos = scanner.scan(src, codes);
      expect(todos.length, 2);
      expect(todos[0].user, 'jo');
      expect(todos[0].message, 'translate to es');
      expect(todos[1].user, 'maria'); // @ stripped
      expect(todos[1].message, 'check term usage');
    });

    test('is case-insensitive and tolerates an empty message', () {
      const src = '// TODO';
      final todos = scanner.scan(src, codes);
      expect(todos.length, 1);
      expect(todos.first.user, isNull);
      expect(todos.first.message, '');
    });

    test('attributes a todo inside a language block to that language', () {
      const src = '''
#let para-001 = (
  en: [Hello],
  es: [
    Hola
    // todo(jo): revisar
  ],
)
''';
      final todos = scanner.scan(src, codes);
      expect(todos.length, 1);
      expect(todos.first.user, 'jo');
      expect(todos.first.lang, 'es');
      expect(todos.first.blockId, 'para-001');
    });

    test('handles an inline trailing todo on an empty value line', () {
      const src = '''
#let para-001 = (
  en: [Hello],
  es: [], // todo(jo)
)
''';
      final todos = scanner.scan(src, codes);
      expect(todos.length, 1);
      expect(todos.first.user, 'jo');
      expect(todos.first.lang, 'es');
      expect(todos.first.blockId, 'para-001');
    });

    test('attributes correctly with nested brackets in a value', () {
      const src = '''
#let para-001 = (
  en: [A #strong[bold] word],
  fr: [
    Un mot #strong[gras]
    // todo: relire
  ],
)
''';
      final todos = scanner.scan(src, codes);
      expect(todos.length, 1);
      expect(todos.first.lang, 'fr');
      expect(todos.first.blockId, 'para-001');
    });

    test('does NOT match the word todo in prose (only // comments)', () {
      const src = '''
#let para-001 = (
  en: [This is a todo list for the reader],
)
This paragraph mentions a todo but is not a marker.
''';
      final todos = scanner.scan(src, codes);
      expect(todos, isEmpty);
    });

    test('does NOT match when comment leads with other text', () {
      // Contract: marker must lead the comment (`// todo …`).
      const src = '// fix the broken todo handling later';
      final todos = scanner.scan(src, codes);
      expect(todos, isEmpty);
    });

    test('captures multiple users across one file in source order', () {
      const src = '''
// todo(jo): first
// todo: second
// todo(maria): third
''';
      final todos = scanner.scan(src, codes);
      expect(todos.map((t) => t.user).toList(), ['jo', null, 'maria']);
      expect(todos.map((t) => t.line).toList(), [1, 2, 3]);
    });

    test('returns empty for files without markers', () {
      const src = '#let x = 1\njust content';
      expect(scanner.scan(src, codes), isEmpty);
    });
  });
}
