import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/search_provider.dart';

/// Search bar widget displayed above the editor
class SearchBarWidget extends ConsumerStatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final ValueChanged<String>? onQueryChanged;

  const SearchBarWidget({
    super.key,
    this.onNext,
    this.onPrevious,
    this.onQueryChanged,
  });

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

    // Auto-focus when search bar appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(SearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update search field with initial query from state
    final searchState = ref.read(searchProvider);
    if (_searchController.text != searchState.searchQuery) {
      _searchController.text = searchState.searchQuery;
      _searchController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: searchState.searchQuery.length,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchState = ref.watch(searchProvider);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Row(
        children: [
          // Search input field
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Find',
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchProvider.notifier).setQuery('');
                          widget.onQueryChanged?.call('');
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 13),
              onChanged: (value) {
                ref.read(searchProvider.notifier).setQuery(value);
                widget.onQueryChanged?.call(value);
              },
              onSubmitted: (_) {
                widget.onNext?.call();
              },
            ),
          ),

          const SizedBox(width: 8),

          // Match counter
          if (searchState.totalMatches > 0)
            Text(
              '${searchState.currentMatchIndex + 1}/${searchState.totalMatches}',
              style: theme.textTheme.bodySmall,
            ),

          const SizedBox(width: 8),

          // Previous match button
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up, size: 18),
            tooltip: 'Previous match (Shift+Enter)',
            onPressed: searchState.totalMatches > 0
                ? () {
                    ref.read(searchProvider.notifier).previousMatch();
                    widget.onPrevious?.call();
                  }
                : null,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),

          const SizedBox(width: 4),

          // Next match button
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, size: 18),
            tooltip: 'Next match (Enter)',
            onPressed: searchState.totalMatches > 0
                ? () {
                    ref.read(searchProvider.notifier).nextMatch();
                    widget.onNext?.call();
                  }
                : null,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),

          const SizedBox(width: 8),

          // Case sensitive toggle
          IconButton(
            icon: Icon(
              Icons.text_format,
              size: 18,
              color: searchState.caseSensitive
                  ? theme.colorScheme.primary
                  : theme.iconTheme.color,
            ),
            tooltip: 'Match case (Aa)',
            onPressed: () {
              ref.read(searchProvider.notifier).toggleCaseSensitive();
              widget.onQueryChanged?.call(searchState.searchQuery);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),

          const SizedBox(width: 4),

          // Whole word toggle
          IconButton(
            icon: Icon(
              Icons.text_fields,
              size: 18,
              color: searchState.wholeWord
                  ? theme.colorScheme.primary
                  : theme.iconTheme.color,
            ),
            tooltip: 'Match whole word',
            onPressed: () {
              ref.read(searchProvider.notifier).toggleWholeWord();
              widget.onQueryChanged?.call(searchState.searchQuery);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),

          const SizedBox(width: 8),

          // Close button
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            tooltip: 'Close (Escape)',
            onPressed: () {
              ref.read(searchProvider.notifier).hide();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
