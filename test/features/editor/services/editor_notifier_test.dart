import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingodoc/features/editor/services/editor_service.dart';

void main() {
  late ProviderContainer container;
  late Directory tempDir;

  setUp(() {
    container = ProviderContainer();
    tempDir = Directory.systemTemp.createTempSync('editor_notifier_test_');
  });

  tearDown(() {
    container.dispose();
    tempDir.deleteSync(recursive: true);
  });

  EditorNotifier notifier() => container.read(editorProvider.notifier);
  EditorState state() => container.read(editorProvider);

  group('EditorNotifier - initial state', () {
    test('starts with no tabs and no active index', () {
      expect(state().tabs, isEmpty);
      expect(state().activeTabIndex, isNull);
      expect(state().activeTab, isNull);
    });
  });

  group('EditorNotifier - openFile', () {
    test('loads file content and activates tab', () async {
      final file = File('${tempDir.path}/hello.typ');
      await file.writeAsString('= Hello');

      await notifier().openFile(file.path);

      expect(state().tabs.length, 1);
      expect(state().tabs.first.content, '= Hello');
      expect(state().tabs.first.fileName, 'hello.typ');
      expect(state().activeTabIndex, 0);
    });

    test('sets error when file does not exist', () async {
      await notifier().openFile('${tempDir.path}/missing.typ');

      expect(state().tabs, isEmpty);
      expect(state().error, isNotNull);
    });

    test(
      'opening an already-open file switches to it without duplicating',
      () async {
        final file = File('${tempDir.path}/a.typ');
        await file.writeAsString('A');

        await notifier().openFile(file.path);
        await notifier().openFile(file.path);

        expect(state().tabs.length, 1);
        expect(state().activeTabIndex, 0);
      },
    );

    test('stores pendingLineJump when jumpToLine is provided', () async {
      final file = File('${tempDir.path}/b.typ');
      await file.writeAsString('B');

      await notifier().openFile(file.path, jumpToLine: 5);

      expect(state().pendingLineJump, 5);
    });

    test('clearLineJump removes pendingLineJump', () async {
      final file = File('${tempDir.path}/c.typ');
      await file.writeAsString('C');

      await notifier().openFile(file.path, jumpToLine: 3);
      notifier().clearLineJump();

      expect(state().pendingLineJump, isNull);
    });
  });

  group('EditorNotifier - closeTab', () {
    Future<void> openFile(String name, String content) async {
      final file = File('${tempDir.path}/$name');
      await file.writeAsString(content);
      await notifier().openFile(file.path);
    }

    test('closing the only tab leaves empty state', () async {
      await openFile('solo.typ', 'x');
      notifier().closeTab(0);

      expect(state().tabs, isEmpty);
      expect(state().activeTabIndex, isNull);
    });

    test('closing active tab activates the previous one', () async {
      await openFile('first.typ', '1');
      await openFile('second.typ', '2');
      // active is index 1 (second)
      notifier().closeTab(1);

      expect(state().tabs.length, 1);
      expect(state().activeTabIndex, 0);
      expect(state().tabs.first.fileName, 'first.typ');
    });

    test(
      'closing a tab before the active tab decrements active index',
      () async {
        await openFile('a.typ', 'a');
        await openFile('b.typ', 'b');
        await openFile('c.typ', 'c');
        // active is index 2 (c)
        notifier().closeTab(0);

        expect(state().tabs.length, 2);
        expect(state().activeTabIndex, 1);
        expect(state().activeTab?.fileName, 'c.typ');
      },
    );

    test('out-of-range index is a no-op', () async {
      await openFile('d.typ', 'd');
      notifier().closeTab(99);
      expect(state().tabs.length, 1);
    });
  });

  group('EditorNotifier - updateTabContent', () {
    test('marks tab dirty and updates content', () async {
      final file = File('${tempDir.path}/edit.typ');
      await file.writeAsString('original');
      await notifier().openFile(file.path);

      notifier().updateTabContent(0, 'modified');

      expect(state().tabs.first.content, 'modified');
      expect(state().tabs.first.isDirty, isTrue);
    });
  });

  group('EditorNotifier - requestInsertion / clearInsertion', () {
    test('pendingInsertion round-trip', () {
      notifier().requestInsertion('snippet text');
      expect(state().pendingInsertion, 'snippet text');

      notifier().clearInsertion();
      expect(state().pendingInsertion, isNull);
    });
  });

  group('EditorNotifier - closeAll', () {
    test('resets state to empty', () async {
      final file = File('${tempDir.path}/x.typ');
      await file.writeAsString('x');
      await notifier().openFile(file.path);

      notifier().closeAll();

      expect(state().tabs, isEmpty);
      expect(state().activeTabIndex, isNull);
    });
  });
}
