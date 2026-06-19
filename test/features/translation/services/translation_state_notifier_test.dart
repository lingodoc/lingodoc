import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingodoc/features/translation/services/translation_staleness.dart';
import 'package:lingodoc/features/translation/services/translation_state_provider.dart';

const _configToml = '''
[[languages]]
code = "en"
name = "English"

[[languages]]
code = "fr"
name = "French"

language_order = ["en", "fr"]

[project_settings]
default_language = { code = "en", name = "English" }
''';

void main() {
  late ProviderContainer container;
  late Directory tempDir;

  setUp(() async {
    container = ProviderContainer();
    tempDir = Directory.systemTemp.createTempSync('translation_notifier_test_');
    await File('${tempDir.path}/config.toml').writeAsString(_configToml);
    await Directory('${tempDir.path}/chapters').create(recursive: true);
  });

  tearDown(() {
    container.dispose();
    tempDir.deleteSync(recursive: true);
  });

  TranslationStateNotifier notifier() =>
      container.read(translationStateProvider.notifier);

  String chapterPath() => '${tempDir.path}/chapters/01.typ';
  String relPath() => translationRelPath(tempDir.path, chapterPath());

  test('onFileSaved baselines a new file as in-sync', () async {
    await notifier().loadForProject(tempDir.path);

    notifier().onFileSaved(
      chapterPath(),
      '#let para-001 = (\n  en: [a],\n  fr: [b],\n)\n',
    );

    final file = container.read(translationStateProvider).files[relPath()];
    expect(file, isNotNull);
    expect(totalStaleForFile(file), 0);
  });

  test('editing one language marks the sibling stale after save', () async {
    await notifier().loadForProject(tempDir.path);

    notifier().onFileSaved(
      chapterPath(),
      '#let para-001 = (\n  en: [a],\n  fr: [b],\n)\n',
    );
    // Edit en only.
    notifier().onFileSaved(
      chapterPath(),
      '#let para-001 = (\n  en: [a-edited],\n  fr: [b],\n)\n',
    );

    final file = container.read(translationStateProvider).files[relPath()];
    expect(staleBlocksForFile(file), [(blockId: 'para-001', lang: 'fr')]);
  });

  test('debounced persist writes the sidecar file', () async {
    await notifier().loadForProject(tempDir.path);
    notifier().onFileSaved(
      chapterPath(),
      '#let para-001 = (\n  en: [a],\n  fr: [b],\n)\n',
    );

    final sidecar = File('${tempDir.path}/.lingodoc/translation-state.json');
    expect(await sidecar.exists(), isFalse); // debounced, not yet written

    await Future<void>.delayed(const Duration(milliseconds: 850));
    expect(await sidecar.exists(), isTrue);

    // Reload into a fresh notifier and confirm state survives.
    final reloaded = await container
        .read(translationSidecarServiceProvider)
        .load(tempDir.path);
    expect(reloaded.files.containsKey(relPath()), isTrue);
  });

  test('markReviewedAction clears a stale flag', () async {
    await notifier().loadForProject(tempDir.path);
    notifier().onFileSaved(
        chapterPath(), '#let para-001 = (\n  en: [a],\n  fr: [b],\n)\n');
    notifier().onFileSaved(
        chapterPath(), '#let para-001 = (\n  en: [a2],\n  fr: [b],\n)\n');
    expect(totalStaleForFile(
        container.read(translationStateProvider).files[relPath()]), 1);

    notifier().markReviewedAction(relPath(), 'para-001', 'fr');
    expect(totalStaleForFile(
        container.read(translationStateProvider).files[relPath()]), 0);
  });
}
