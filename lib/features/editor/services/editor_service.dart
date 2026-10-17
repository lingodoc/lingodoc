import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import '../models/editor_tab.dart';
import '../../translation/services/translation_state_provider.dart';
import '../../todo/services/todo_provider.dart';

/// State class for editor management
@immutable
class EditorState {
  final List<EditorTab> tabs;
  final int? activeTabIndex;
  final bool isLoading;
  final String? error;

  /// Text to insert at the current cursor position.
  /// The editor widget watches this and clears it after inserting.
  final String? pendingInsertion;

  /// 1-based line number to jump to after a cross-file PDF→editor navigation.
  /// Consumed and cleared by the newly-mounted HighlightedCodeEditor.
  final int? pendingLineJump;

  const EditorState({
    this.tabs = const [],
    this.activeTabIndex,
    this.isLoading = false,
    this.error,
    this.pendingInsertion,
    this.pendingLineJump,
  });

  EditorTab? get activeTab =>
      activeTabIndex != null && activeTabIndex! < tabs.length
      ? tabs[activeTabIndex!]
      : null;

  EditorState copyWith({
    List<EditorTab>? tabs,
    int? activeTabIndex,
    bool? isLoading,
    String? error,
    String? pendingInsertion,
    bool clearPendingInsertion = false,
    int? pendingLineJump,
    bool clearLineJump = false,
  }) {
    return EditorState(
      tabs: tabs ?? this.tabs,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pendingInsertion: clearPendingInsertion
          ? null
          : (pendingInsertion ?? this.pendingInsertion),
      pendingLineJump: clearLineJump
          ? null
          : (pendingLineJump ?? this.pendingLineJump),
    );
  }
}

/// Notifier for managing editor state
class EditorNotifier extends Notifier<EditorState> {
  @override
  EditorState build() => const EditorState();

  /// Open a file in a new tab or switch to existing tab.
  ///
  /// [jumpToLine] is a 1-based line number to scroll to after the file opens;
  /// used by PDF→editor cross-file navigation.
  Future<void> openFile(String filePath, {int? jumpToLine}) async {
    // Check if file is already open
    final existingIndex = state.tabs.indexWhere(
      (tab) => tab.filePath == filePath,
    );
    if (existingIndex != -1) {
      // File already open, just switch to it
      setActiveTab(existingIndex);
      if (jumpToLine != null) {
        state = state.copyWith(pendingLineJump: jumpToLine);
      }
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        state = state.copyWith(
          isLoading: false,
          error: 'File not found: $filePath',
        );
        return;
      }

      final content = await file.readAsString();
      final fileName = path.basename(filePath);

      final newTab = EditorTab(
        filePath: filePath,
        fileName: fileName,
        content: content,
        isActive: true,
      );

      // Deactivate all existing tabs - optimized list generation
      final updatedTabs = List<EditorTab>.generate(
        state.tabs.length + 1,
        (i) => i < state.tabs.length
            ? state.tabs[i].copyWith(isActive: false)
            : newTab,
        growable: false,
      );

      state = EditorState(
        tabs: updatedTabs,
        activeTabIndex: updatedTabs.length - 1,
        isLoading: false,
        pendingLineJump: jumpToLine,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to open file: $e',
      );
    }
  }

  /// Clear the pending line jump (called by the editor after consuming it).
  void clearLineJump() {
    state = state.copyWith(clearLineJump: true);
  }

  /// Close a tab
  void closeTab(int index) {
    if (index < 0 || index >= state.tabs.length) return;

    final updatedTabs = List<EditorTab>.from(state.tabs);
    updatedTabs.removeAt(index);

    int? newActiveIndex;
    if (updatedTabs.isNotEmpty) {
      if (state.activeTabIndex == index) {
        // Closing active tab, activate the previous one or the first one
        newActiveIndex = index > 0 ? index - 1 : 0;
        updatedTabs[newActiveIndex] = updatedTabs[newActiveIndex].copyWith(
          isActive: true,
        );
      } else if (state.activeTabIndex != null &&
          state.activeTabIndex! > index) {
        // Active tab is after the closed one, adjust index
        newActiveIndex = state.activeTabIndex! - 1;
      } else {
        newActiveIndex = state.activeTabIndex;
      }
    }

    state = EditorState(tabs: updatedTabs, activeTabIndex: newActiveIndex);
  }

  /// Set active tab
  void setActiveTab(int index) {
    if (index < 0 || index >= state.tabs.length) return;

    // Only create new list if active status actually changes
    if (state.activeTabIndex == index) return;

    final updatedTabs = List<EditorTab>.generate(
      state.tabs.length,
      (i) => state.tabs[i].copyWith(isActive: i == index),
      growable: false,
    );

    state = EditorState(tabs: updatedTabs, activeTabIndex: index);
  }

  /// Update tab content
  void updateTabContent(int index, String content) {
    if (index < 0 || index >= state.tabs.length) return;

    final updatedTabs = List<EditorTab>.from(state.tabs);
    updatedTabs[index] = updatedTabs[index].copyWith(
      content: content,
      isDirty: true,
    );

    state = EditorState(
      tabs: updatedTabs,
      activeTabIndex: state.activeTabIndex,
    );
  }

  /// Save tab content to file
  Future<void> saveTab(int index) async {
    if (index < 0 || index >= state.tabs.length) return;

    final tab = state.tabs[index];

    try {
      final file = File(tab.filePath);
      await file.writeAsString(tab.content);

      final updatedTabs = List<EditorTab>.from(state.tabs);
      updatedTabs[index] = tab.copyWith(isDirty: false);

      // Trigger state change to notify listeners (for auto-refresh)
      state = EditorState(
        tabs: updatedTabs,
        activeTabIndex: state.activeTabIndex,
      );

      // Recompute translation staleness for the saved file (fire-and-forget,
      // off the save critical path; a no-op for non-translation files).
      ref
          .read(translationStateProvider.notifier)
          .onFileSaved(tab.filePath, tab.content);

      // Rescan the saved file for TODO markers.
      ref.read(todoProvider.notifier).onFileSaved(tab.filePath, tab.content);
    } catch (e) {
      state = state.copyWith(error: 'Failed to save file: $e');
    }
  }

  /// Save all modified tabs
  Future<void> saveAll() async {
    for (int i = 0; i < state.tabs.length; i++) {
      if (state.tabs[i].isDirty) {
        await saveTab(i);
      }
    }
  }

  /// Close all tabs
  void closeAll() {
    state = const EditorState();
  }

  /// Request insertion of [text] at the active editor's cursor position.
  /// The editor widget picks this up and clears it after inserting.
  void requestInsertion(String text) {
    state = state.copyWith(pendingInsertion: text);
  }

  /// Called by the editor widget after it has consumed the pending insertion.
  void clearInsertion() {
    state = state.copyWith(clearPendingInsertion: true);
  }
}

/// Provider for editor state
final editorProvider = NotifierProvider<EditorNotifier, EditorState>(() {
  return EditorNotifier();
});
