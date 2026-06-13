import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;

import 'package:lingodoc/features/editor/services/editor_service.dart';
import 'package:lingodoc/features/project/services/project_state.dart';
import 'package:lingodoc/main.dart' as app;

/// Tests the fix for preview not updating when opening a new project.
///
/// The bug: _pdfPath and _selectedLanguage in PreviewPanel were never cleared
/// on project change, so the old PDF stayed visible and no immediate compile
/// was triggered.  The fix resets both and fires _compileForLanguage() via
/// addPostFrameCallback when projectPath changes.
///
/// NOTE: ~/handleiding has no config.toml (its project root is
/// ~/handleiding/output/).  This test uses a self-contained fixture so it
/// works anywhere typst is installed.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory fixture;

  setUp(() async {
    fixture = await Directory.systemTemp.createTemp('lingodoc_inttest_');
    await _createMinimalProject(fixture.path);
  });

  tearDown(() async {
    try {
      await fixture.delete(recursive: true);
    } catch (_) {}
  });

  testWidgets(
    'preview shows compiled PDF after loading project folder and opening .typ file',
    (tester) async {
      // Start the full desktop app.  main() is declared 'void' so we cannot
      // await it; the real async work (windowManager, runApp) runs as the
      // test framework pumps frames.
      // ignore: unawaited_futures
      app.main([]);

      // Let startup finish: window_manager handshake, sample-project auto-load,
      // initial FutureProvider resolution.  Use pump(duration) instead of
      // pumpAndSettle because the 10-second auto-refresh timer prevents settling.
      await tester.pump(const Duration(seconds: 5));

      // ------------------------------------------------------------------ //
      // Grab the root Riverpod container so we can drive providers directly  //
      // (bypasses the FilePicker directory dialog the user would normally see) //
      // ------------------------------------------------------------------ //
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ProviderScope).first),
      );

      // Load the fixture as the active project.
      await tester.runAsync(
        () => container.read(projectTreeProvider.notifier).loadProject(fixture.path),
      );

      // Two pumps: first lets the FutureProvider rebuild the preview panel
      // (_buildPanel detects the new projectPath and schedules the callback),
      // second runs the addPostFrameCallback that calls _compileForLanguage().
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Open main.typ in the editor — the file the user would click in the
      // project tree after navigating to ~/handleiding.
      await tester.runAsync(
        () => container
            .read(editorProvider.notifier)
            .openFile(p.join(fixture.path, 'main.typ')),
      );
      await tester.pump();

      // ------------------------------------------------------------------ //
      // Wait for Typst compilation.  The fix fires an immediate compile so   //
      // the PDF should appear well within 30 seconds on any reasonable machine//
      // ------------------------------------------------------------------ //
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.text('No PDF loaded').evaluate().isEmpty) break;
      }

      // The placeholder must be gone — PdfViewer is rendering a real PDF.
      expect(
        find.text('No PDF loaded'),
        findsNothing,
        reason:
            'Preview must show the compiled PDF; '
            'if this fails the immediate-compile on project-load fix is broken',
      );
      expect(
        find.text('Compile a document to view the preview'),
        findsNothing,
      );
    },
  );
}

// ---------------------------------------------------------------------------

/// Creates a minimal LingoDoc project that Typst compiles in under a second.
///
/// Structure:
///   config.toml  – declares "en" language, enables auto-compile
///   lang.typ     – language injection file (required by the compiler)
///   main.typ     – trivial document that imports lang.typ
Future<void> _createMinimalProject(String dir) async {
  await File(p.join(dir, 'config.toml')).writeAsString('''
[[languages]]
code = "en"
name = "English"

[project_settings]
default_language = { code = "en", name = "English" }
auto_compile = true
compile_debounce_ms = 500
''');

  // lang.typ is modified by the compiler to inject the selected language.
  await File(p.join(dir, 'lang.typ')).writeAsString(
    '#let current-lang = "en"\n',
  );

  // Trivial document – no fonts, images, or includes that could fail.
  await File(p.join(dir, 'main.typ')).writeAsString(
    '#import "lang.typ": current-lang\n'
    '= Fixture Document\n'
    'Language: #current-lang\n',
  );
}
