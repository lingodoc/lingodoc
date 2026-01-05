import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_provider.freezed.dart';
part 'search_provider.g.dart';

/// Search state for editor
@freezed
sealed class SearchState with _$SearchState {
  const SearchState._(); // Private constructor for Freezed

  const factory SearchState({
    @Default(false) bool isVisible,
    @Default('') String searchQuery,
    @Default(0) int currentMatchIndex,
    @Default(0) int totalMatches,
    @Default(false) bool caseSensitive,
    @Default(false) bool wholeWord,
    @Default(false) bool useRegex,
  }) = _SearchState;

  factory SearchState.fromJson(Map<String, dynamic> json) =>
      _$SearchStateFromJson(json);
}

/// Search provider for managing search state
class SearchNotifier extends Notifier<SearchState> {
  @override
  SearchState build() => const SearchState();

  /// Show the search bar and optionally set initial query
  void show({String? initialQuery}) {
    state = state.copyWith(
      isVisible: true,
      searchQuery: initialQuery ?? state.searchQuery,
    );
  }

  /// Hide the search bar
  void hide() {
    state = state.copyWith(isVisible: false);
  }

  /// Toggle search bar visibility
  void toggle({String? initialQuery}) {
    if (state.isVisible) {
      hide();
    } else {
      show(initialQuery: initialQuery);
    }
  }

  /// Update search query
  void setQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Update match counts
  void setMatches(int current, int total) {
    state = state.copyWith(
      currentMatchIndex: current,
      totalMatches: total,
    );
  }

  /// Toggle case sensitivity
  void toggleCaseSensitive() {
    state = state.copyWith(caseSensitive: !state.caseSensitive);
  }

  /// Toggle whole word matching
  void toggleWholeWord() {
    state = state.copyWith(wholeWord: !state.wholeWord);
  }

  /// Toggle regex mode
  void toggleRegex() {
    state = state.copyWith(useRegex: !state.useRegex);
  }

  /// Navigate to next match
  void nextMatch() {
    if (state.totalMatches > 0) {
      final next = (state.currentMatchIndex + 1) % state.totalMatches;
      state = state.copyWith(currentMatchIndex: next);
    }
  }

  /// Navigate to previous match
  void previousMatch() {
    if (state.totalMatches > 0) {
      final prev = state.currentMatchIndex > 0
          ? state.currentMatchIndex - 1
          : state.totalMatches - 1;
      state = state.copyWith(currentMatchIndex: prev);
    }
  }

  /// Clear search
  void clear() {
    state = const SearchState();
  }
}

/// Global search provider
final searchProvider = NotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);
