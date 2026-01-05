import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/models.dart';
import '../services/project_scaffolding_service.dart';

/// Wizard dialog for creating a new LingoDoc project
class NewProjectWizard extends StatefulWidget {
  const NewProjectWizard({super.key});

  @override
  State<NewProjectWizard> createState() => _NewProjectWizardState();
}

class _NewProjectWizardState extends State<NewProjectWizard> {
  final _scaffoldingService = ProjectScaffoldingService();
  final _formKey = GlobalKey<FormState>();
  final _projectPathController = TextEditingController();

  // Wizard state
  int _currentStep = 0;

  // Project details
  String _projectName = '';
  String _projectPath = '';

  // Language configuration
  final List<LanguageConfig> _selectedLanguages = [];
  LanguageConfig? _defaultLanguage;
  bool _createSampleChapter = true;

  // Common languages for quick selection
  static const _commonLanguages = [
    LanguageConfig(code: 'en', name: 'English'),
    LanguageConfig(code: 'es', name: 'Spanish'),
    LanguageConfig(code: 'fr', name: 'French'),
    LanguageConfig(code: 'de', name: 'German'),
    LanguageConfig(code: 'it', name: 'Italian'),
    LanguageConfig(code: 'pt', name: 'Portuguese'),
    LanguageConfig(code: 'zh', name: 'Chinese'),
    LanguageConfig(code: 'ja', name: 'Japanese'),
    LanguageConfig(code: 'ko', name: 'Korean'),
    LanguageConfig(code: 'ar', name: 'Arabic'),
    LanguageConfig(code: 'ru', name: 'Russian'),
    LanguageConfig(code: 'hi', name: 'Hindi'),
  ];

  @override
  void dispose() {
    _projectPathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New LingoDoc Project',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Stepper(
                  currentStep: _currentStep,
                  onStepContinue: _onStepContinue,
                  onStepCancel: _onStepCancel,
                  controlsBuilder: _buildControls,
                  steps: [
                    _buildProjectDetailsStep(),
                    _buildLanguageSelectionStep(),
                    _buildLanguageOrderStep(),
                    _buildDefaultLanguageStep(),
                    _buildOptionsStep(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Step _buildProjectDetailsStep() {
    return Step(
      title: const Text('Project Details'),
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Project Name',
                hintText: 'My Documentation Project',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a project name';
                }
                return null;
              },
              onSaved: (value) => _projectName = value ?? '',
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Project Path',
                hintText: '/path/to/project',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.folder_open),
                  onPressed: _selectProjectPath,
                ),
              ),
              readOnly: true,
              controller: _projectPathController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a project path';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildLanguageSelectionStep() {
    return Step(
      title: const Text('Select Languages'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choose the languages you want to support:'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _commonLanguages.map((lang) {
              final isSelected = _selectedLanguages.contains(lang);
              return FilterChip(
                label: Text(lang.name),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedLanguages.add(lang);
                    } else {
                      _selectedLanguages.remove(lang);
                      // Clear default language if it was removed
                      if (_defaultLanguage == lang) {
                        _defaultLanguage = null;
                      }
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _addCustomLanguage,
                icon: const Icon(Icons.add),
                label: const Text('Add Custom Language'),
              ),
            ],
          ),
          if (_selectedLanguages.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Selected languages:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedLanguages.map((lang) {
                return Chip(
                  label: Text('${lang.name} (${lang.code})'),
                  onDeleted: () {
                    setState(() {
                      _selectedLanguages.remove(lang);
                      if (_defaultLanguage == lang) {
                        _defaultLanguage = null;
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildLanguageOrderStep() {
    return Step(
      title: const Text('Language Order'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Drag to reorder languages (top to bottom):'),
          const SizedBox(height: 16),
          if (_selectedLanguages.isEmpty)
            const Text(
              'No languages selected yet',
              style: TextStyle(fontStyle: FontStyle.italic),
            )
          else
            ReorderableListView(
              shrinkWrap: true,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = _selectedLanguages.removeAt(oldIndex);
                  _selectedLanguages.insert(newIndex, item);
                });
              },
              children: _selectedLanguages.map((lang) {
                return ListTile(
                  key: ValueKey(lang),
                  leading: const Icon(Icons.drag_handle),
                  title: Text('${lang.name} (${lang.code})'),
                );
              }).toList(),
            ),
        ],
      ),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildDefaultLanguageStep() {
    return Step(
      title: const Text('Default Language'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select the primary/fallback language:'),
          const SizedBox(height: 16),
          if (_selectedLanguages.isEmpty)
            const Text(
              'No languages selected yet',
              style: TextStyle(fontStyle: FontStyle.italic),
            )
          else
            DropdownButtonFormField<LanguageConfig>(
              initialValue: _defaultLanguage,
              decoration: const InputDecoration(
                labelText: 'Default Language',
                border: OutlineInputBorder(),
              ),
              items: _selectedLanguages.map((lang) {
                return DropdownMenuItem(
                  value: lang,
                  child: Text('${lang.name} (${lang.code})'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _defaultLanguage = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a default language';
                }
                return null;
              },
            ),
        ],
      ),
      isActive: _currentStep >= 3,
      state: _currentStep > 3 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildOptionsStep() {
    return Step(
      title: const Text('Options'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            title: const Text('Create sample chapter'),
            subtitle: const Text('Generate an example introduction chapter'),
            value: _createSampleChapter,
            onChanged: (value) {
              setState(() {
                _createSampleChapter = value ?? true;
              });
            },
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Project Summary',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Name:', _projectName.isEmpty ? '-' : _projectName),
                  _buildSummaryRow('Path:', _projectPath.isEmpty ? '-' : _projectPath),
                  _buildSummaryRow(
                    'Languages:',
                    _selectedLanguages.isEmpty
                        ? '-'
                        : _selectedLanguages.map((l) => l.name).join(', '),
                  ),
                  _buildSummaryRow(
                    'Default:',
                    _defaultLanguage?.name ?? '-',
                  ),
                  _buildSummaryRow(
                    'Sample chapter:',
                    _createSampleChapter ? 'Yes' : 'No',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      isActive: _currentStep >= 4,
      state: StepState.indexed,
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, ControlsDetails details) {
    final isLastStep = _currentStep == 4;

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: [
          if (_currentStep > 0)
            TextButton(
              onPressed: details.onStepCancel,
              child: const Text('Back'),
            ),
          const Spacer(),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: isLastStep ? _createProject : details.onStepContinue,
            child: Text(isLastStep ? 'Create Project' : 'Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectProjectPath() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Project Directory',
    );

    if (result != null) {
      setState(() {
        _projectPath = result;
        _projectPathController.text = result;
      });
    }
  }

  Future<void> _addCustomLanguage() async {
    final codeController = TextEditingController();
    final nameController = TextEditingController();

    final result = await showDialog<LanguageConfig>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Language Code',
                hintText: 'e.g., en, es, fr',
              ),
              maxLength: 5,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Language Name',
                hintText: 'e.g., English, Spanish',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (codeController.text.isNotEmpty &&
                  nameController.text.isNotEmpty) {
                final lang = LanguageConfig(
                  code: codeController.text.trim(),
                  name: nameController.text.trim(),
                );
                Navigator.of(context).pop(lang);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLanguages.add(result);
      });
    }
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
      } else {
        return;
      }
    }

    if (_currentStep == 1 && _selectedLanguages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one language')),
      );
      return;
    }

    if (_currentStep == 3 && _defaultLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a default language')),
      );
      return;
    }

    setState(() {
      _currentStep += 1;
    });
  }

  void _onStepCancel() {
    setState(() {
      _currentStep -= 1;
    });
  }

  Future<void> _createProject() async {
    try {
      // Show loading dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Creating project...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Create the project
      await _scaffoldingService.createNewProject(
        projectPath: _projectPath,
        projectName: _projectName,
        languages: _selectedLanguages,
        languageOrder: _selectedLanguages.map((l) => l.code).toList(),
        defaultLanguage: _defaultLanguage!,
        createSampleChapter: _createSampleChapter,
      );

      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Close wizard and return project path
      Navigator.of(context).pop(_projectPath);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Project "$_projectName" created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Show error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error Creating Project'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
