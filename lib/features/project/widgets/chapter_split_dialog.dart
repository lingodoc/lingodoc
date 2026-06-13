import 'package:flutter/material.dart';
import '../../editor/services/chapter_split_service.dart';

/// Dialog that lists a chapter's sections and lets the user tick the ones that
/// should each start a new file (with an editable filename). Returns a map of
/// `unitStartLine → fileName` for the selected sections, or null if cancelled.
class ChapterSplitDialog extends StatefulWidget {
  final List<ChapterSection> sections;

  /// Filename prefix derived from the source chapter (e.g. `05`).
  final String filePrefix;

  const ChapterSplitDialog({
    super.key,
    required this.sections,
    required this.filePrefix,
  });

  @override
  State<ChapterSplitDialog> createState() => _ChapterSplitDialogState();
}

class _ChapterSplitDialogState extends State<ChapterSplitDialog> {
  final _selected = <int>{};
  final _names = <int, TextEditingController>{};

  String _defaultName(ChapterSection s) {
    final slug = chapterSlug(s.heading);
    return widget.filePrefix.isEmpty
        ? '$slug.typ'
        : '${widget.filePrefix}-$slug.typ';
  }

  @override
  void dispose() {
    for (final c in _names.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // The first section is the chapter's own start and always stays in the
    // original file; the rest are selectable boundaries.
    final selectable = widget.sections.skip(1).toList();

    return AlertDialog(
      title: const Text('Split chapter by section'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tick each section that should become its own file. Everything '
              'before the first ticked section stays in the original.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: selectable.length,
                itemBuilder: (context, i) {
                  final s = selectable[i];
                  final checked = _selected.contains(s.unitStartLine);
                  final controller = _names.putIfAbsent(
                    s.unitStartLine,
                    () => TextEditingController(text: _defaultName(s)),
                  );
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: checked,
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            _selected.add(s.unitStartLine);
                          } else {
                            _selected.remove(s.unitStartLine);
                          }
                        }),
                      ),
                      // Heading, indented by level.
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: (s.level - 1) * 12.0),
                          child: Text(
                            '${'=' * s.level} ${s.heading}',
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          controller: controller,
                          enabled: checked,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selected.isEmpty
              ? null
              : () {
                  final result = <int, String>{
                    for (final line in _selected)
                      line: _names[line]!.text.trim(),
                  };
                  Navigator.of(context).pop(result);
                },
          child: Text('Split into ${_selected.length} file'
              '${_selected.length == 1 ? '' : 's'}'),
        ),
      ],
    );
  }
}
