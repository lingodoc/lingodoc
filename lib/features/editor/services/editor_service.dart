import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import '../models/editor_tab.dart';

/// State class for editor management
@immutable
class EditorState {
  final List<EditorTab> tabs;
  final int? activeTabIndex;
  final bool isLoading;
  final String? error;

  const EditorState({
    this.tabs = const [],
    this.activeTabIndex,
    this.isLoading = false,
    this.error,
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
  }) {
    return EditorState(
      tabs: tabs ?? this.tabs,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing editor state
class EditorNotifier extends Notifier<EditorState> {
  @override
  EditorState build() => const EditorState();

  /// Open a file in a new tab or switch to existing tab
  Future<void> openFile(String filePath) async {
    // Check if file is already open
    final existingIndex = state.tabs.indexWhere((tab) => tab.filePath == filePath);
    if (existingIndex != -1) {
      // File already open, just switch to it
      setActiveTab(existingIndex);
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

      // Deactivate all existing tabs
      final updatedTabs = state.tabs
          .map((tab) => tab.copyWith(isActive: false))
          .toList();

      updatedTabs.add(newTab);

      state = EditorState(
        tabs: updatedTabs,
        activeTabIndex: updatedTabs.length - 1,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to open file: $e',
      );
    }
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
        updatedTabs[newActiveIndex] = updatedTabs[newActiveIndex].copyWith(isActive: true);
      } else if (state.activeTabIndex != null && state.activeTabIndex! > index) {
        // Active tab is after the closed one, adjust index
        newActiveIndex = state.activeTabIndex! - 1;
      } else {
        newActiveIndex = state.activeTabIndex;
      }
    }

    state = EditorState(
      tabs: updatedTabs,
      activeTabIndex: newActiveIndex,
    );
  }

  /// Set active tab
  void setActiveTab(int index) {
    if (index < 0 || index >= state.tabs.length) return;

    final updatedTabs = state.tabs.asMap().entries.map((entry) {
      return entry.value.copyWith(isActive: entry.key == index);
    }).toList();

    state = EditorState(
      tabs: updatedTabs,
      activeTabIndex: index,
    );
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
      debugPrint('💾 EditorService: Saving file to: ${tab.filePath}');
      debugPrint('💾 EditorService: File exists: ${await file.exists()}');
      await file.writeAsString(tab.content);
      debugPrint('💾 EditorService: Save completed successfully');

      final updatedTabs = List<EditorTab>.from(state.tabs);
      updatedTabs[index] = tab.copyWith(isDirty: false);

      // Trigger state change to notify listeners (for auto-refresh)
      state = EditorState(
        tabs: updatedTabs,
        activeTabIndex: state.activeTabIndex,
      );
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
}

/// Provider for editor state
final editorProvider = NotifierProvider<EditorNotifier, EditorState>(() {
  return EditorNotifier();
});
