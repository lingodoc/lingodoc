import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/screen_entry.dart';
import '../services/screen_library_service.dart';
import '../../editor/services/editor_service.dart';
import '../../settings/models/user_preferences.dart';
import '../../settings/services/settings_service.dart';

/// Dialog for browsing the HTML screen library and inserting
/// a #screen(N) reference at the current editor cursor position.
class ScreenPickerDialog extends ConsumerStatefulWidget {
  const ScreenPickerDialog({super.key});

  @override
  ConsumerState<ScreenPickerDialog> createState() => _ScreenPickerDialogState();
}

class _ScreenPickerDialogState extends ConsumerState<ScreenPickerDialog> {
  final _searchController = TextEditingController();
  String _query = '';
  ScreenEntry? _selected;
  String _previewLang = 'nl';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ScreenEntry> _filtered(List<ScreenEntry> all) {
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return all.where((e) {
      return e.number.toString().contains(q) ||
          e.title.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final libraryPath = ref.watch(screenLibraryPathProvider);
    final screensAsync = ref.watch(screenLibraryProvider);
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 900,
        height: 620,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, theme, libraryPath),
            if (libraryPath == null)
              _buildNoLibrary(context, theme)
            else
              Expanded(
                child: screensAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      Center(child: Text('Error loading screens: $e')),
                  data: (screens) =>
                      _buildContent(context, theme, screens, libraryPath),
                ),
              ),
            _buildFooter(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    String? libraryPath,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          const Icon(Icons.screenshot_monitor, size: 20),
          const SizedBox(width: 10),
          Text(
            'Insert Screen',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 20),
          if (libraryPath != null)
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by number or title…',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            )
          else
            const Spacer(),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildNoLibrary(BuildContext context, ThemeData theme) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_off_outlined,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No screen library configured',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Set the path to your HTML screenshots folder in Settings.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Icons.folder_open, size: 18),
              label: const Text('Choose folder…'),
              onPressed: () => _pickLibraryFolder(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    List<ScreenEntry> allScreens,
    String libraryPath,
  ) {
    final filtered = _filtered(allScreens);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left: screen grid
        Expanded(
          flex: 3,
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'No screens match "$_query"',
                    style: TextStyle(color: theme.colorScheme.outline),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.6,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) => _ScreenCard(
                    entry: filtered[i],
                    isSelected: _selected?.number == filtered[i].number,
                    onTap: () => setState(() {
                      _selected = filtered[i];
                      // default to first available language
                      if (!filtered[i].availableLanguages.contains(
                        _previewLang,
                      )) {
                        _previewLang =
                            filtered[i].availableLanguages.firstOrNull ?? 'nl';
                      }
                    }),
                  ),
                ),
        ),

        // Divider
        VerticalDivider(width: 1, color: theme.dividerColor),

        // Right: details pane
        SizedBox(
          width: 260,
          child: _selected == null
              ? Center(
                  child: Text(
                    'Select a screen',
                    style: TextStyle(color: theme.colorScheme.outline),
                  ),
                )
              : _buildDetailPane(context, theme, _selected!, libraryPath),
        ),
      ],
    );
  }

  Widget _buildDetailPane(
    BuildContext context,
    ThemeData theme,
    ScreenEntry entry,
    String libraryPath,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Screen ${entry.number}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (entry.title.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(entry.title, style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: 16),

          // Language selector
          Text(
            'Preview language',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: entry.availableLanguages.map((lang) {
              final active = lang == _previewLang;
              return ChoiceChip(
                label: Text(lang.toUpperCase()),
                selected: active,
                onSelected: (_) => setState(() => _previewLang = lang),
                labelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Open in browser
          OutlinedButton.icon(
            icon: const Icon(Icons.open_in_browser, size: 16),
            label: const Text('Preview in browser'),
            onPressed: () => ScreenLibraryService.openInBrowser(
              entry,
              libraryPath,
              _previewLang,
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 36),
            ),
          ),
          const SizedBox(height: 8),

          // Insertion preview
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    entry.insertionText,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Available languages info
          Text(
            'Available: ${entry.availableLanguages.join(', ')}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          TextButton.icon(
            icon: const Icon(Icons.folder_open, size: 16),
            label: const Text('Change library folder…'),
            onPressed: () => _pickLibraryFolder(context),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Insert'),
            onPressed: _selected == null
                ? null
                : () {
                    ref
                        .read(editorProvider.notifier)
                        .requestInsertion(_selected!.insertionText);
                    Navigator.of(context).pop();
                  },
          ),
        ],
      ),
    );
  }

  Future<void> _pickLibraryFolder(BuildContext context) async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select HTML Screen Library Folder',
    );
    if (result != null) {
      final current =
          ref.read(userPreferencesProvider).asData?.value ??
          const UserPreferences();
      await ref
          .read(userPreferencesProvider.notifier)
          .updatePreferences(current.copyWith(screenLibraryPath: result));
    }
  }
}

/// A compact card showing a screen number and title in the grid.
class _ScreenCard extends StatelessWidget {
  final ScreenEntry entry;
  final bool isSelected;
  final VoidCallback onTap;

  const _ScreenCard({
    required this.entry,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerLow,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${entry.number}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
              ),
            ),
            if (entry.title.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                entry.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.outline,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
