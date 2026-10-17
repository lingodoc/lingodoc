import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_preferences.dart';
import '../services/settings_service.dart';

/// Settings dialog with tabbed interface for user preferences.
///
/// Tabs:
/// - Appearance: Theme mode selection
/// - Editor: Font size, line numbers, word wrap
/// - Preview: Auto-refresh settings, PDF page retention
/// - Advanced: Reset to defaults
class SettingsDialog extends ConsumerStatefulWidget {
  const SettingsDialog({super.key});

  @override
  ConsumerState<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<SettingsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late UserPreferences _currentPreferences;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize with current preferences or defaults
    final prefsAsync = ref.read(userPreferencesProvider);
    _currentPreferences = prefsAsync.when(
      data: (prefs) => prefs,
      loading: () => const UserPreferences(),
      error: (e, stack) => const UserPreferences(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updatePreference(UserPreferences Function(UserPreferences) updater) {
    setState(() {
      _currentPreferences = updater(_currentPreferences);
      _hasChanges = true;
    });
  }

  Future<void> _saveAndClose() async {
    if (_hasChanges) {
      await ref
          .read(userPreferencesProvider.notifier)
          .updatePreferences(_currentPreferences);
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text(
          'Are you sure you want to reset all settings to their default values?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(userPreferencesProvider.notifier).resetToDefaults();
      setState(() {
        _currentPreferences = const UserPreferences();
        _hasChanges = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 500,
        height: 400,
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAppearanceTab(),
                  _buildEditorTab(),
                  _buildPreviewTab(),
                  _buildAdvancedTab(),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.settings, size: 24),
          const SizedBox(width: 12),
          Text('Settings', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(icon: Icon(Icons.palette), text: 'Appearance'),
        Tab(icon: Icon(Icons.edit), text: 'Editor'),
        Tab(icon: Icon(Icons.preview), text: 'Preview'),
        Tab(icon: Icon(Icons.settings_suggest), text: 'Advanced'),
      ],
    );
  }

  Widget _buildAppearanceTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SettingSection(
          title: 'Theme',
          child: SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('System'),
                icon: Icon(Icons.settings_brightness),
              ),
            ],
            selected: {_currentPreferences.themeMode},
            onSelectionChanged: (Set<ThemeMode> newSelection) {
              _updatePreference(
                (prefs) => prefs.copyWith(themeMode: newSelection.first),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _SettingSection(
          title: 'Window State',
          child: SwitchListTile(
            title: const Text('Remember window size and position'),
            value: _currentPreferences.rememberWindowState,
            onChanged: (value) {
              _updatePreference(
                (prefs) => prefs.copyWith(rememberWindowState: value),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEditorTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SettingSection(
          title: 'Font Size',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _currentPreferences.editorFontSize.toDouble(),
                      min: 10,
                      max: 24,
                      divisions: 14,
                      label: _currentPreferences.editorFontSize.toString(),
                      onChanged: (value) {
                        _updatePreference(
                          (prefs) =>
                              prefs.copyWith(editorFontSize: value.toInt()),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${_currentPreferences.editorFontSize}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              Text(
                'Font size for code editor',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SettingSection(
          title: 'Display Options',
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Show line numbers'),
                value: _currentPreferences.editorLineNumbers,
                onChanged: (value) {
                  _updatePreference(
                    (prefs) => prefs.copyWith(editorLineNumbers: value),
                  );
                },
              ),
              SwitchListTile(
                title: const Text('Enable word wrap'),
                value: _currentPreferences.editorWordWrap,
                onChanged: (value) {
                  _updatePreference(
                    (prefs) => prefs.copyWith(editorWordWrap: value),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SettingSection(
          title: 'Auto-Refresh',
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Enable auto-refresh'),
                subtitle: const Text(
                  'Automatically refresh preview on changes',
                ),
                value: _currentPreferences.enableAutoRefresh,
                onChanged: (value) {
                  _updatePreference(
                    (prefs) => prefs.copyWith(enableAutoRefresh: value),
                  );
                },
              ),
              if (_currentPreferences.enableAutoRefresh) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _currentPreferences
                                  .autoRefreshIntervalSeconds
                                  .toDouble(),
                              min: 5,
                              max: 60,
                              divisions: 11,
                              label:
                                  '${_currentPreferences.autoRefreshIntervalSeconds}s',
                              onChanged: (value) {
                                _updatePreference(
                                  (prefs) => prefs.copyWith(
                                    autoRefreshIntervalSeconds: value.toInt(),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            child: Text(
                              '${_currentPreferences.autoRefreshIntervalSeconds}s',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Refresh interval (seconds)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SettingSection(
          title: 'PDF Viewer',
          child: SwitchListTile(
            title: const Text('Retain page position'),
            subtitle: const Text('Remember page position when refreshing'),
            value: _currentPreferences.retainPdfPage,
            onChanged: (value) {
              _updatePreference(
                (prefs) => prefs.copyWith(retainPdfPage: value),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SettingSection(
          title: 'Reset Settings',
          child: ListTile(
            leading: const Icon(Icons.restore, color: Colors.orange),
            title: const Text('Reset to Defaults'),
            subtitle: const Text(
              'Restore all settings to their original values',
            ),
            onTap: _resetToDefaults,
            trailing: FilledButton.tonal(
              onPressed: _resetToDefaults,
              child: const Text('Reset'),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'About Settings',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Settings are automatically saved and will persist across sessions. '
                  'Editor preferences here override project-specific settings in config.toml.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(onPressed: _cancel, child: const Text('Cancel')),
          const SizedBox(width: 8),
          FilledButton(onPressed: _saveAndClose, child: const Text('Save')),
        ],
      ),
    );
  }
}

/// Section widget for settings groups.
class _SettingSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(margin: EdgeInsets.zero, child: child),
      ],
    );
  }
}
