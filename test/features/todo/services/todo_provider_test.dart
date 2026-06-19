import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingodoc/features/todo/services/todo_provider.dart';
import 'package:lingodoc/features/translation/services/translation_state_provider.dart'
    show translationRelPath;

const _configToml = '''
[[languages]]
code = "en"
name = "English"

[[languages]]
code = "es"
name = "Spanish"

language_order = ["en", "es"]

[project_settings]
default_language = { code = "en", name = "English" }
''';

void main() {
  late ProviderContainer container;
  late Directory tempDir;

  setUp(() async {
    container = ProviderContainer();
    tempDir = Directory.systemTemp.createTempSync('todo_provider_test_');
    await File('${tempDir.path}/config.toml').writeAsString(_configToml);
    await Directory('${tempDir.path}/chapters').create(recursive: true);
  });

  tearDown(() {
    container.dispose();
    tempDir.deleteSync(recursive: true);
  });

  TodoNotifier notifier() => container.read(todoProvider.notifier);

  test('loadForProject aggregates todos across files and skips clean ones',
      () async {
    await File('${tempDir.path}/main.typ').writeAsString(
      '// todo: top level\n#let x = 1\n',
    );
    await File('${tempDir.path}/chapters/01.typ').writeAsString(
      '#let p1 = (\n  en: [Hi],\n  es: [\n    Hola\n    // todo(jo): revisar\n  ],\n)\n',
    );
    await File('${tempDir.path}/chapters/02.typ').writeAsString(
      '#let p2 = (\n  en: [Clean],\n)\n', // no markers
    );

    await notifier().loadForProject(tempDir.path);
    final state = container.read(todoProvider);

    expect(state.keys.toSet(), {'main.typ', 'chapters/01.typ'});
    expect(state['main.typ']!.single.message, 'top level');
    final esTodo = state['chapters/01.typ']!.single;
    expect(esTodo.user, 'jo');
    expect(esTodo.lang, 'es');
    expect(esTodo.blockId, 'p1');
  });

  test('loadForProject skips the output directory', () async {
    await Directory('${tempDir.path}/output').create(recursive: true);
    await File('${tempDir.path}/output/build.typ')
        .writeAsString('// todo: generated, ignore me\n');

    await notifier().loadForProject(tempDir.path);
    expect(container.read(todoProvider), isEmpty);
  });

  test('onFileSaved updates only the saved file', () async {
    final chapter = '${tempDir.path}/chapters/01.typ';
    await File(chapter).writeAsString('// todo: one\n');
    await notifier().loadForProject(tempDir.path);

    final rel = translationRelPath(tempDir.path, chapter);
    expect(container.read(todoProvider)[rel]!.length, 1);

    // Saving new content with two markers replaces just this file's entry.
    notifier().onFileSaved(chapter, '// todo: a\n// todo(maria): b\n');
    expect(container.read(todoProvider)[rel]!.length, 2);

    // Saving content with no markers removes the file from state.
    notifier().onFileSaved(chapter, '#let x = 1\n');
    expect(container.read(todoProvider).containsKey(rel), isFalse);
  });
}
