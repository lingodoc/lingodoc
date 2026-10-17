import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/vs.dart'; // Light theme
import 'package:flutter_highlight/themes/vs2015.dart'; // Dark theme
import 'package:path/path.dart' as p;
import '../models/typst_language_mode.dart';
import '../services/autocomplete_service.dart';
import '../services/chapter_split_service.dart';
import '../services/editor_service.dart';
import '../services/search_provider.dart';
import '../models/suggestion.dart';
import '../../preview/services/sync_controller.dart';
import '../../project/services/project_state.dart';
import 'search_bar_widget.dart';

/// Code editor with Typst syntax highlighting and autocomplete
class HighlightedCodeEditor extends ConsumerStatefulWidget {
  final String initialContent;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final String? filePath;
  final String? projectPath;

  const HighlightedCodeEditor({
    super.key,
    this.initialContent = '',
    this.onChanged,
    this.readOnly = false,
    this.filePath,
    this.projectPath,
  });

  @override
  ConsumerState<HighlightedCodeEditor> createState() =>
      _HighlightedCodeEditorState();
}

class _HighlightedCodeEditorState extends ConsumerState<HighlightedCodeEditor> {
  late CodeController _controller;
  late FocusNode _focusNode;
  late AutocompleteService _autocompleteService;
  bool _isDirty = false;
  bool _showAutocomplete = false;
  List<Suggestion> _suggestions = [];
  Timer? _autoSaveTimer; // Auto-save timer
  Timer? _highlightDebounceTimer; // Debounce timer for autocomplete
  Timer? _syncDebounceTimer; // Debounce timer for continuous editor→PDF sync
  bool _applyingInverse = false; // Guard: caret moved by a PDF→editor jump
  late SyncController _sync;
  late ScrollController _scrollController;

  /// Files above this size skip live syntax highlighting and autocomplete:
  /// flutter_code_editor's highlighter and our autocomplete both scan the whole
  /// document synchronously, which freezes the UI (and can exhaust memory) on
  /// very large chapters. Editing/saving/sync still work.
  static const int _largeFileThreshold = 256 * 1024; // 256 KB
  late final bool _isLargeFile;

  final ChapterSplitService _splitService = ChapterSplitService();

  /// A `.typ` file living under a `chapters/` directory (eligible for splitting).
  bool get _isChapterFile {
    final fp = widget.filePath;
    if (fp == null || !fp.endsWith('.typ')) return false;
    return p.split(p.dirname(fp)).contains('chapters');
  }

  @override
  void initState() {
    super.initState();

    _sync = ref.read(syncControllerProvider);
    _isLargeFile = widget.initialContent.length > _largeFileThreshold;

    // Initialize autocomplete service
    _autocompleteService = AutocompleteService(projectPath: widget.projectPath);

    // Create controller. Syntax highlighting is disabled for very large files
    // to keep the editor responsive (see [_isLargeFile]).
    _controller = CodeController(
      text: widget.initialContent,
      language: _isLargeFile ? null : typstMode,
    );

    _focusNode = FocusNode();
    _scrollController = ScrollController();
    _controller.addListener(_onTextChanged);

    // Listen for PDF→editor jump requests targeting this file.
    _sync.inverseTarget.addListener(_onInverseTarget);

    // Start auto-save timer (10 seconds)
    _startAutoSaveTimer();

    // Consume a pending line jump set by cross-file PDF→editor navigation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final pendingLine = ref.read(editorProvider).pendingLineJump;
      if (pendingLine != null) {
        ref.read(editorProvider.notifier).clearLineJump();
        _jumpToLine(pendingLine);
      }
    });
  }

  @override
  void didUpdateWidget(HighlightedCodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update content if file path changed (new file opened)
    if (widget.filePath != oldWidget.filePath) {
      _controller.text = widget.initialContent;
      _isDirty = false;
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _highlightDebounceTimer?.cancel();
    _syncDebounceTimer?.cancel();
    _sync.inverseTarget.removeListener(_onInverseTarget);
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 1-based line number of the current caret position.
  int _currentLine() {
    final offset = _controller.selection.baseOffset;
    final text = _controller.text;
    if (offset < 0 || offset > text.length) return 1;
    return '\n'.allMatches(text.substring(0, offset)).length + 1;
  }

  /// Character offset of the start of 1-based [line].
  int _offsetForLine(int line) {
    final lines = _controller.text.split('\n');
    final clamped = line.clamp(1, lines.length);
    var offset = 0;
    for (var i = 0; i < clamped - 1; i++) {
      offset += lines[i].length + 1; // +1 for the newline
    }
    return offset.clamp(0, _controller.text.length);
  }

  /// Editor → PDF: ask the preview to reveal the current caret line.
  ///
  /// [announce] shows a hint when the position can't be located (used for
  /// explicit Ctrl+J / right-click actions, but not for continuous following,
  /// which must stay silent).
  void _syncToPdf({bool announce = false}) {
    final filePath = widget.filePath;
    final resolved =
        filePath != null && _sync.requestForward(filePath, _currentLine());
    if (!resolved && announce && mounted) {
      final hasAnchors = _sync.anchorCount.value > 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hasAnchors
                ? "Couldn't locate this line in the PDF — place the caret "
                      'inside a section.'
                : 'Sync data unavailable — compile the document first.',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// PDF → editor: move the caret to the requested source line and reveal it.
  void _onInverseTarget() {
    final target = _sync.inverseTarget.value;
    if (target == null) return;

    final targetFile = target.filePath;
    if (targetFile != widget.filePath) {
      // The jump targets a different file — open it and carry the line over.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(editorProvider.notifier)
            .openFile(targetFile, jumpToLine: target.line);
      });
      return;
    }

    if (!mounted) return;
    _jumpToLine(target.line);
    _applyingInverse = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyingInverse = false;
    });
  }

  void _jumpToLine(int line) {
    final offset = _offsetForLine(line);
    _controller.selection = TextSelection.collapsed(offset: offset);
    _focusNode.requestFocus();
  }

  void _startAutoSaveTimer() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_isDirty && widget.filePath != null) {
        _handleSave();
      }
    });
  }

  void _onTextChanged() {
    // Defer all state changes to avoid calling them during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (!_isDirty) {
          setState(() => _isDirty = true);
        }
        widget.onChanged?.call(_controller.text);

        // Debounce autocomplete updates (skipped for large files — scanning the
        // whole document per keystroke would freeze the UI).
        if (!_isLargeFile) {
          _highlightDebounceTimer?.cancel();
          _highlightDebounceTimer = Timer(
            const Duration(milliseconds: 150),
            () {
              if (mounted) {
                _updateAutocomplete();
              }
            },
          );
        }

        // Continuous editor→PDF sync: follow the caret while enabled. Skipped
        // when the caret was moved programmatically by a PDF→editor jump.
        if (_sync.continuousEnabled.value && !_applyingInverse) {
          _syncDebounceTimer?.cancel();
          _syncDebounceTimer = Timer(const Duration(milliseconds: 150), () {
            if (mounted) _syncToPdf();
          });
        }
      }
    });
  }

  void _updateAutocomplete() {
    if (!_isTypstFile()) {
      if (_showAutocomplete) {
        setState(() {
          _showAutocomplete = false;
          _suggestions = [];
        });
      }
      return;
    }

    final cursorPosition = _controller.selection.baseOffset;

    // Guard against invalid cursor position (can be -1 when no selection)
    if (cursorPosition < 0 || cursorPosition > _controller.text.length) {
      if (_showAutocomplete) {
        setState(() {
          _showAutocomplete = false;
          _suggestions = [];
        });
      }
      return;
    }

    final suggestions = _autocompleteService.getContextSuggestions(
      _controller.text,
      cursorPosition,
    );

    // Only update state if something actually changed
    final shouldShow = suggestions.isNotEmpty;
    if (shouldShow != _showAutocomplete ||
        !_listEquals(_suggestions, suggestions)) {
      setState(() {
        _showAutocomplete = shouldShow;
        _suggestions = suggestions;
      });
    }
  }

  // Helper method to compare suggestion lists
  bool _listEquals(List<Suggestion> a, List<Suggestion> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].label != b[i].label) return false;
    }
    return true;
  }

  bool _isTypstFile() {
    return widget.filePath?.endsWith('.typ') ?? false;
  }

  /// Insert [text] at the current cursor position in the CodeController.
  void _insertAtCursor(String text) {
    final sel = _controller.selection;
    final current = _controller.text;
    final start = sel.isValid ? sel.start : current.length;
    final end = sel.isValid ? sel.end : current.length;
    final updated = current.replaceRange(start, end, text);
    _controller.value = _controller.value.copyWith(
      text: updated,
      selection: TextSelection.collapsed(offset: start + text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final searchState = ref.watch(searchProvider);

    // Listen for insertion requests from the screen picker
    ref.listen<String?>(editorProvider.select((s) => s.pendingInsertion), (
      _,
      next,
    ) {
      if (next != null) {
        _insertAtCursor(next);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(editorProvider.notifier).clearInsertion();
        });
      }
    });

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          _buildToolbar(theme),
          // Search bar at top of editor
          if (searchState.isVisible)
            SearchBarWidget(
              onQueryChanged: (_) => _performSearch(),
              onNext: _navigateToNextMatch,
              onPrevious: _navigateToPreviousMatch,
            ),
          Expanded(
            child: Shortcuts(
              shortcuts: {
                LogicalKeySet(
                  LogicalKeyboardKey.control,
                  LogicalKeyboardKey.keyS,
                ): const _SaveIntent(),
                LogicalKeySet(
                  LogicalKeyboardKey.control,
                  LogicalKeyboardKey.keyF,
                ): const _FindIntent(),
                LogicalKeySet(
                  LogicalKeyboardKey.control,
                  LogicalKeyboardKey.keyJ,
                ): const _SyncForwardIntent(),
                LogicalKeySet(
                  LogicalKeyboardKey.control,
                  LogicalKeyboardKey.alt,
                  LogicalKeyboardKey.keyJ,
                ): const _SyncToggleIntent(),
              },
              child: Actions(
                actions: {
                  _SaveIntent: CallbackAction<_SaveIntent>(
                    onInvoke: (_) => _handleSave(),
                  ),
                  _FindIntent: CallbackAction<_FindIntent>(
                    onInvoke: (_) => _handleFind(),
                  ),
                  _SyncForwardIntent: CallbackAction<_SyncForwardIntent>(
                    onInvoke: (_) {
                      _syncToPdf(announce: true);
                      return null;
                    },
                  ),
                  _SyncToggleIntent: CallbackAction<_SyncToggleIntent>(
                    onInvoke: (_) {
                      _sync.toggleContinuous();
                      return null;
                    },
                  ),
                },
                child: _buildEditorWithSearch(theme, isDarkMode),
              ),
            ),
          ),
          _buildStatusBar(theme),
        ],
      ),
    );
  }

  Widget _buildToolbar(ThemeData theme) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.save, size: 18),
            tooltip: 'Save (Ctrl+S)',
            onPressed: _isDirty ? _handleSave : null,
            padding: EdgeInsets.zero,
          ),
          if (_isTypstFile()) ...[
            const SizedBox(width: 4),
            // Show in PDF (editor → PDF), enabled only when sync anchors exist.
            ValueListenableBuilder<int>(
              valueListenable: _sync.anchorCount,
              builder: (context, count, _) => IconButton(
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                tooltip: count > 0
                    ? 'Show in PDF (Ctrl+J)'
                    : 'Show in PDF — compile first',
                onPressed: count > 0 ? () => _syncToPdf(announce: true) : null,
                padding: EdgeInsets.zero,
              ),
            ),
            // Continuously follow the caret toggle.
            ValueListenableBuilder<bool>(
              valueListenable: _sync.continuousEnabled,
              builder: (context, on, _) => IconButton(
                icon: Icon(on ? Icons.link : Icons.link_off, size: 18),
                tooltip: on
                    ? 'Following caret — click to stop (Ctrl+Alt+J)'
                    : 'Continuously follow caret (Ctrl+Alt+J)',
                color: on ? theme.colorScheme.primary : null,
                onPressed: _sync.toggleContinuous,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
          if (_isChapterFile) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.call_split, size: 18),
              tooltip: 'Split chapter at cursor',
              onPressed: _splitChapterHere,
              padding: EdgeInsets.zero,
            ),
          ],
          const Spacer(),
          if (_isLargeFile) ...[
            Tooltip(
              message:
                  'Large file — syntax highlighting and autocomplete '
                  'disabled to keep the editor responsive.',
              child: Chip(
                label: const Text('Plain (large file)'),
                avatar: const Icon(Icons.bolt_outlined, size: 16),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 8),
          ] else if (_isTypstFile())
            Chip(
              label: const Text('Typst'),
              avatar: const Icon(Icons.code, size: 16),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          const SizedBox(width: 8),
          if (_isDirty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Modified',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditorWithSearch(ThemeData theme, bool isDarkMode) {
    // Secondary (right) tap opens a sync context menu without stealing the
    // editor's normal interactions.
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onSecondaryTapDown: (details) =>
          _showSyncContextMenu(details.globalPosition),
      child: _buildEditor(theme, isDarkMode),
    );
  }

  Future<void> _showSyncContextMenu(Offset globalPosition) async {
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;
    final continuous = _sync.continuousEnabled.value;
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        globalPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        const PopupMenuItem<String>(
          value: 'forward',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.picture_as_pdf_outlined, size: 18),
            title: Text('Show in PDF'),
            subtitle: Text('Ctrl+J'),
          ),
        ),
        PopupMenuItem<String>(
          value: 'toggle',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(continuous ? Icons.link_off : Icons.link, size: 18),
            title: Text(
              continuous ? 'Stop following caret' : 'Continuously follow caret',
            ),
            subtitle: const Text('Ctrl+Alt+J'),
          ),
        ),
        if (_isChapterFile)
          const PopupMenuItem<String>(
            value: 'split',
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.call_split, size: 18),
              title: Text('Split chapter here'),
            ),
          ),
      ],
    );
    if (selected == 'forward') {
      _syncToPdf(announce: true);
    } else if (selected == 'toggle') {
      _sync.toggleContinuous();
    } else if (selected == 'split') {
      _splitChapterHere();
    }
  }

  /// Split the current chapter at the caret: everything from the caret's section
  /// to end-of-file moves into a new chapter file (named by the user), and
  /// `main.typ` gains an `#include` for it.
  Future<void> _splitChapterHere() async {
    final filePath = widget.filePath;
    final projectPath = ref.read(projectTreeProvider).projectPath;
    if (filePath == null || projectPath == null) return;

    final plan = _splitService.computeSplit(
      _controller.text,
      _controller.selection.baseOffset,
    );
    if (!plan.ok) {
      if (mounted) _showSnack(plan.reason ?? 'Cannot split here.');
      return;
    }

    final suggestion = _suggestedFileName(filePath, plan.cutHeading);
    final name = await _promptFileName(suggestion);
    if (name == null) return; // cancelled

    try {
      final result = await _splitService.applySplit(
        projectPath: projectPath,
        currentFilePath: filePath,
        newFileName: name,
        plan: plan,
      );
      if (!mounted) return;

      // Update the (now shorter) original tab to match what was written to disk.
      final tabs = ref.read(editorProvider).tabs;
      final idx = tabs.indexWhere((t) => t.filePath == filePath);
      if (idx != -1) {
        ref.read(editorProvider.notifier).updateTabContent(idx, plan.head);
      }
      // Open the split-off part and refresh the tree.
      await ref.read(editorProvider.notifier).openFile(result.newFilePath);
      await ref.read(projectTreeProvider.notifier).refresh();

      if (!mounted) return;
      _showSnack(
        result.includeUpdated
            ? 'Split into "${p.basename(result.newFilePath)}".'
            : 'Created "${p.basename(result.newFilePath)}" — add its #include to '
                  'main.typ manually (the original include was not found).',
      );
    } catch (e) {
      if (mounted) {
        _showSnack(e is ArgumentError ? '${e.message}' : 'Split failed: $e');
      }
    }
  }

  /// Suggest `<numeric-prefix>-<heading-slug>.typ` from the source filename.
  String _suggestedFileName(String filePath, String heading) {
    final base = p.basenameWithoutExtension(filePath);
    final prefix = RegExp(r'^\d+[a-z]?').firstMatch(base)?.group(0);
    final slug = chapterSlug(heading);
    return prefix != null ? '$prefix-$slug.typ' : '$base-$slug.typ';
  }

  Future<String?> _promptFileName(String suggestion) async {
    final controller = TextEditingController(text: suggestion);
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: suggestion.length - '.typ'.length,
    );
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Split chapter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filename for the section being split off:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'chapter-name.typ',
              ),
              onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Split'),
          ),
        ],
      ),
    );
    controller.dispose();
    return (result == null || result.isEmpty) ? null : result;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
    );
  }

  Widget _buildEditor(ThemeData theme, bool isDarkMode) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Stack(
          children: [
            CodeTheme(
              data: CodeThemeData(styles: isDarkMode ? vs2015Theme : vsTheme),
              child: CodeField(
                controller: _controller,
                focusNode: _focusNode,
                readOnly: widget.readOnly,
                maxLines: null,
                textStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
                gutterStyle: GutterStyle(
                  showLineNumbers: true,
                  textStyle: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  margin: 10,
                  width: 40,
                ),
              ),
            ),
            if (_showAutocomplete && _suggestions.isNotEmpty)
              Positioned(
                left: 80,
                top: _calculateAutocompletePosition(),
                child: _buildAutocompleteOverlay(theme),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(ThemeData theme) {
    final text = _controller.text;
    final lineCount = text.split('\n').length;
    final charCount = text.length;

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Text('Lines: $lineCount', style: theme.textTheme.bodySmall),
          const SizedBox(width: 16),
          Text('Characters: $charCount', style: theme.textTheme.bodySmall),
          const SizedBox(width: 16),
          if (widget.filePath != null)
            Expanded(
              child: Text(
                widget.filePath!,
                style: theme.textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }

  void _handleSave() async {
    // Find the tab index for this file
    final editorState = ref.read(editorProvider);
    final tabIndex = editorState.tabs.indexWhere(
      (tab) => tab.filePath == widget.filePath,
    );

    if (tabIndex == -1) {
      return;
    }

    // Call the EditorService to save the file
    await ref.read(editorProvider.notifier).saveTab(tabIndex);

    // Mark as not dirty after successful save
    setState(() => _isDirty = false);
  }

  void _handleFind() {
    // Get selected text
    final selection = _controller.selection;
    String? selectedText;

    if (selection.start != selection.end) {
      selectedText = _controller.text.substring(selection.start, selection.end);
    }

    // Show search bar with selected text (if any)
    ref.read(searchProvider.notifier).show(initialQuery: selectedText);

    // Perform search if we have a query
    if (selectedText != null && selectedText.isNotEmpty) {
      _performSearch();
    }
  }

  void _performSearch() {
    final searchState = ref.read(searchProvider);
    final query = searchState.searchQuery;

    if (query.isEmpty) {
      ref.read(searchProvider.notifier).setMatches(0, 0);
      return;
    }

    final text = _controller.text;
    final matches = <int>[];

    // Simple case-sensitive/insensitive search
    final searchText = searchState.caseSensitive ? text : text.toLowerCase();
    final searchQuery = searchState.caseSensitive ? query : query.toLowerCase();

    int index = 0;
    while (index < searchText.length) {
      final foundIndex = searchText.indexOf(searchQuery, index);
      if (foundIndex == -1) break;

      index = foundIndex;

      // Check whole word if enabled
      if (searchState.wholeWord) {
        final isStartWord = index == 0 || !_isWordChar(text[index - 1]);
        final endIndex = index + query.length;
        final isEndWord =
            endIndex >= text.length || !_isWordChar(text[endIndex]);

        if (isStartWord && isEndWord) {
          matches.add(index);
        }
      } else {
        matches.add(index);
      }

      index = index + query.length;
    }

    // Update match count
    ref
        .read(searchProvider.notifier)
        .setMatches(matches.isNotEmpty ? 0 : 0, matches.length);

    // Navigate to first match if available
    if (matches.isNotEmpty) {
      _navigateToMatch(matches[0]);
    }
  }

  bool _isWordChar(String char) {
    return RegExp(r'[a-zA-Z0-9_]').hasMatch(char);
  }

  void _navigateToNextMatch() {
    final searchState = ref.read(searchProvider);
    if (searchState.totalMatches == 0) return;

    _performSearch();
  }

  void _navigateToPreviousMatch() {
    final searchState = ref.read(searchProvider);
    if (searchState.totalMatches == 0) return;

    _performSearch();
  }

  void _navigateToMatch(int position) {
    final query = ref.read(searchProvider).searchQuery;

    // Set selection to the match
    _controller.selection = TextSelection(
      baseOffset: position,
      extentOffset: position + query.length,
    );

    // Request focus so selection is visible
    _focusNode.requestFocus();
  }

  double _calculateAutocompletePosition() {
    // Simple calculation - in a real implementation, you'd want to calculate
    // based on cursor position and text layout
    return 100.0;
  }

  Widget _buildAutocompleteOverlay(ThemeData theme) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300, maxHeight: 200),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = _suggestions[index];
            return ListTile(
              dense: true,
              leading: Icon(
                _getIconForSuggestionType(suggestion.type.name),
                size: 16,
              ),
              title: Text(suggestion.label, style: theme.textTheme.bodySmall),
              subtitle: suggestion.detail != null
                  ? Text(
                      suggestion.detail!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  : null,
              onTap: () {
                _applySuggestion(suggestion);
              },
            );
          },
        ),
      ),
    );
  }

  IconData _getIconForSuggestionType(String type) {
    switch (type) {
      case 'function':
        return Icons.functions;
      case 'variable':
        return Icons.code;
      case 'term':
        return Icons.translate;
      default:
        return Icons.lightbulb_outline;
    }
  }

  void _applySuggestion(Suggestion suggestion) {
    final cursorPos = _controller.selection.baseOffset;
    final currentText = _controller.text;

    // Create new text with suggestion inserted
    final newText =
        currentText.substring(0, cursorPos) +
        suggestion.insertText +
        currentText.substring(cursorPos);

    // Update controller text
    _controller.text = newText;

    // Move cursor to end of inserted text
    final newCursorPos = cursorPos + suggestion.insertText.length;
    _controller.selection = TextSelection.collapsed(offset: newCursorPos);

    setState(() {
      _showAutocomplete = false;
      _suggestions = [];
    });
  }
}

class _SaveIntent extends Intent {
  const _SaveIntent();
}

class _FindIntent extends Intent {
  const _FindIntent();
}

class _SyncForwardIntent extends Intent {
  const _SyncForwardIntent();
}

class _SyncToggleIntent extends Intent {
  const _SyncToggleIntent();
}
