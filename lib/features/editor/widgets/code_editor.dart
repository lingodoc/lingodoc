import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/editor_service.dart';

/// Basic code editor widget with plain text editing
class CodeEditor extends ConsumerStatefulWidget {
  final String initialContent;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final String? filePath;

  const CodeEditor({
    super.key,
    this.initialContent = '',
    this.onChanged,
    this.readOnly = false,
    this.filePath,
  });

  @override
  ConsumerState<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends ConsumerState<CodeEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
    _focusNode = FocusNode();

    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(CodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update content if file path changed (new file opened)
    if (widget.filePath != oldWidget.filePath) {
      _controller.text = widget.initialContent;
      _isDirty = false;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (!_isDirty) {
      setState(() => _isDirty = true);
    }
    widget.onChanged?.call(_controller.text);
  }

  void _insertAtCursor(String text) {
    final sel = _controller.selection;
    final current = _controller.text;
    final start = sel.isValid ? sel.start : current.length;
    final end = sel.isValid ? sel.end : current.length;
    _controller.value = _controller.value.copyWith(
      text: current.replaceRange(start, end, text),
      selection: TextSelection.collapsed(offset: start + text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(
      editorProvider.select((s) => s.pendingInsertion),
      (_, next) {
        if (next != null) {
          _insertAtCursor(next);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(editorProvider.notifier).clearInsertion();
          });
        }
      },
    );

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Editor toolbar
          _buildToolbar(context),

          // Editor content
          Expanded(
            child: Shortcuts(
              shortcuts: {
                // Save shortcut
                LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS): const _SaveIntent(),
                // Undo shortcut
                LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyZ): const _UndoIntent(),
                // Redo shortcut
                LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyY): const _RedoIntent(),
              },
              child: Actions(
                actions: {
                  _SaveIntent: CallbackAction<_SaveIntent>(
                    onInvoke: (_) => _handleSave(),
                  ),
                  _UndoIntent: CallbackAction<_UndoIntent>(
                    onInvoke: (_) => _handleUndo(),
                  ),
                  _RedoIntent: CallbackAction<_RedoIntent>(
                    onInvoke: (_) => _handleRedo(),
                  ),
                },
                child: _buildEditor(context),
              ),
            ),
          ),

          // Status bar
          _buildStatusBar(context),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.undo, size: 18),
            tooltip: 'Undo (Ctrl+Z)',
            onPressed: _handleUndo,
            padding: EdgeInsets.zero,
          ),
          IconButton(
            icon: const Icon(Icons.redo, size: 18),
            tooltip: 'Redo (Ctrl+Y)',
            onPressed: _handleRedo,
            padding: EdgeInsets.zero,
          ),
          const VerticalDivider(),
          IconButton(
            icon: const Icon(Icons.save, size: 18),
            tooltip: 'Save (Ctrl+S)',
            onPressed: _isDirty ? _handleSave : null,
            padding: EdgeInsets.zero,
          ),
          const Spacer(),
          if (_isDirty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Modified',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditor(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      readOnly: widget.readOnly,
      maxLines: null,
      expands: true,
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 14,
        height: 1.5,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(16),
        hintText: 'Start typing...',
      ),
      textAlignVertical: TextAlignVertical.top,
    );
  }

  Widget _buildStatusBar(BuildContext context) {
    final lineCount = _controller.text.split('\n').length;
    final charCount = _controller.text.length;
    final cursorPosition = _controller.selection.base.offset;

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Lines: $lineCount',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 16),
          Text(
            'Characters: $charCount',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 16),
          Text(
            'Cursor: $cursorPosition',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          if (widget.filePath != null)
            Text(
              widget.filePath!,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  void _handleSave() {
    // TODO: Implement actual save functionality
    setState(() => _isDirty = false);
  }

  void _handleUndo() {
    // Note: TextField has built-in undo/redo on some platforms
  }

  void _handleRedo() {
    // TODO: Implement redo functionality
  }
}

// Intent classes for keyboard shortcuts
class _SaveIntent extends Intent {
  const _SaveIntent();
}

class _UndoIntent extends Intent {
  const _UndoIntent();
}

class _RedoIntent extends Intent {
  const _RedoIntent();
}
