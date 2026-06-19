import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingodoc/features/translation/models/translation_state.dart';
import 'package:lingodoc/features/translation/services/translation_sidecar_service.dart';

void main() {
  late Directory tempDir;
  final service = TranslationSidecarService();

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('translation_sidecar_test_');
  });
  tearDown(() => tempDir.deleteSync(recursive: true));

  const sample = TranslationProjectState(
    version: 1,
    files: {
      'chapters/01.typ': TranslationFileState(
        blocks: {
          'para-001': TranslationBlockState(
            latestToken: 't1',
            langs: {
              'en': TranslationLangState(hash: 'h-en', token: 't1'),
              'fr': TranslationLangState(hash: 'h-fr', token: 't0'),
            },
          ),
        },
      ),
    },
  );

  test('missing sidecar loads as empty state', () async {
    final loaded = await service.load(tempDir.path);
    expect(loaded.version, 1);
    expect(loaded.files, isEmpty);
  });

  test('save then load round-trips and creates .lingodoc/', () async {
    await service.save(tempDir.path, sample);

    final file = File('${tempDir.path}/.lingodoc/translation-state.json');
    expect(await file.exists(), isTrue);

    final loaded = await service.load(tempDir.path);
    expect(loaded, sample);

    final block = loaded.files['chapters/01.typ']!.blocks['para-001']!;
    expect(block.latestToken, 't1');
    expect(block.langs['fr']!.token, 't0'); // stale relative to latestToken
  });

  test('encode is sorted and pretty-printed', () {
    final json = service.encode(sample);
    expect(json.contains('\n  '), isTrue); // indented
    // Keys sorted: "files" before "version".
    expect(json.indexOf('"files"'), lessThan(json.indexOf('"version"')));
  });

  test('corrupt sidecar falls back to empty state', () async {
    final file = File('${tempDir.path}/.lingodoc/translation-state.json');
    await file.parent.create(recursive: true);
    await file.writeAsString('{ not valid json');
    final loaded = await service.load(tempDir.path);
    expect(loaded.files, isEmpty);
  });
}
