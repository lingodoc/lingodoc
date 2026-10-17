import 'package:flutter_test/flutter_test.dart';
import 'package:lingodoc/core/utils/path_validator.dart';
import 'package:path/path.dart' as p;

void main() {
  group('PathValidator.validateLanguageCode', () {
    test('accepts two-letter codes', () {
      expect(() => PathValidator.validateLanguageCode('en'), returnsNormally);
      expect(() => PathValidator.validateLanguageCode('es'), returnsNormally);
      expect(() => PathValidator.validateLanguageCode('zh'), returnsNormally);
    });

    test('accepts three-letter codes', () {
      expect(() => PathValidator.validateLanguageCode('fra'), returnsNormally);
      expect(() => PathValidator.validateLanguageCode('eng'), returnsNormally);
    });

    test('accepts region-suffixed codes', () {
      expect(
        () => PathValidator.validateLanguageCode('en-US'),
        returnsNormally,
      );
      expect(
        () => PathValidator.validateLanguageCode('zh-CN'),
        returnsNormally,
      );
    });

    test('rejects empty string', () {
      expect(() => PathValidator.validateLanguageCode(''), throwsArgumentError);
    });

    test('rejects path traversal attempt', () {
      expect(
        () => PathValidator.validateLanguageCode('../en'),
        throwsArgumentError,
      );
    });

    test('rejects HTML injection', () {
      expect(
        () => PathValidator.validateLanguageCode('<script>'),
        throwsArgumentError,
      );
    });

    test('rejects code that is too long', () {
      expect(
        () => PathValidator.validateLanguageCode('english'),
        throwsArgumentError,
      );
    });
  });

  group('PathValidator.isWithinBoundary', () {
    test('file inside project returns true', () {
      expect(
        PathValidator.isWithinBoundary('/project/src/file.txt', '/project'),
        isTrue,
      );
    });

    test('exact match returns true', () {
      expect(PathValidator.isWithinBoundary('/project', '/project'), isTrue);
    });

    test('path that escapes via ../ returns false', () {
      expect(
        PathValidator.isWithinBoundary('/project/../etc/passwd', '/project'),
        isFalse,
      );
    });

    test('unrelated path returns false', () {
      expect(
        PathValidator.isWithinBoundary('/etc/passwd', '/project'),
        isFalse,
      );
    });
  });

  group('PathValidator.sanitizeWithBoundary', () {
    test('relative path resolves to absolute inside boundary', () {
      final result = PathValidator.sanitizeWithBoundary(
        'src/file.typ',
        '/project',
      );
      expect(result, equals(p.normalize('/project/src/file.typ')));
    });

    test('path traversal attempt throws ArgumentError', () {
      expect(
        () => PathValidator.sanitizeWithBoundary('../etc/passwd', '/project'),
        throwsArgumentError,
      );
    });

    test('absolute path inside boundary is returned normalized', () {
      final result = PathValidator.sanitizeWithBoundary(
        '/project/src/file.typ',
        '/project',
      );
      expect(result, equals(p.normalize('/project/src/file.typ')));
    });
  });

  group('PathValidator.validateFilename', () {
    test('plain filename passes', () {
      expect(
        () => PathValidator.validateFilename('chapter-01.typ'),
        returnsNormally,
      );
      expect(() => PathValidator.validateFilename('file.txt'), returnsNormally);
    });

    test('empty string throws', () {
      expect(() => PathValidator.validateFilename(''), throwsArgumentError);
    });

    test('forward slash throws', () {
      expect(
        () => PathValidator.validateFilename('a/b.txt'),
        throwsArgumentError,
      );
    });

    test('backslash throws', () {
      expect(
        () => PathValidator.validateFilename('a\\b.txt'),
        throwsArgumentError,
      );
    });

    test('double-dot throws', () {
      expect(() => PathValidator.validateFilename('..'), throwsArgumentError);
    });

    test('null byte throws', () {
      expect(
        () => PathValidator.validateFilename('file\x00.txt'),
        throwsArgumentError,
      );
    });
  });

  group('PathValidator.validateOutputDirectory', () {
    test('empty string defaults to <project>/output', () {
      final result = PathValidator.validateOutputDirectory('', '/project');
      expect(result, equals(p.normalize('/project/output')));
    });

    test('relative path resolves inside project', () {
      final result = PathValidator.validateOutputDirectory('dist', '/project');
      expect(result, equals(p.normalize('/project/dist')));
    });
  });
}
