import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import '../models/translation_state.dart';
import '../../project/services/config_provider.dart';
import 'translation_block_extractor.dart';
import 'translation_sidecar_service.dart';
import 'translation_staleness.dart';

/// Sidecar I/O service.
final translationSidecarServiceProvider = Provider<TranslationSidecarService>(
  (ref) => TranslationSidecarService(),
);

/// Pure block extractor.
final translationBlockExtractorProvider = Provider<TranslationBlockExtractor>(
  (ref) => const TranslationBlockExtractor(),
);

/// Project-relative POSIX path for a file (the sidecar's file-map key).
String translationRelPath(String projectPath, String filePath) =>
    path.relative(filePath, from: projectPath).replaceAll('\\', '/');

/// Tracks translation staleness across the open project. Recomputed on save and
/// persisted (debounced) to the committed `.lingodoc` sidecar.
class TranslationStateNotifier extends Notifier<TranslationProjectState> {
  String? _projectPath;
  List<String> _languageCodes = const [];
  Timer? _persistTimer;

  @override
  TranslationProjectState build() {
    ref.onDispose(() => _persistTimer?.cancel());
    return const TranslationProjectState();
  }

  /// Load the sidecar and the project's configured language codes. Called when
  /// a project is opened.
  Future<void> loadForProject(String projectPath) async {
    _projectPath = projectPath;
    try {
      final config = await ref
          .read(configServiceProvider)
          .loadConfig(projectPath);
      _languageCodes = config.languages.map((l) => l.code).toList();
    } catch (_) {
      _languageCodes = const [];
    }
    state = await ref.read(translationSidecarServiceProvider).load(projectPath);
  }

  /// Recompute staleness for [filePath] after it was saved. Fire-and-forget,
  /// off the UI critical path; a no-op for files with no translation blocks.
  void onFileSaved(String filePath, String content) {
    final projectPath = _projectPath;
    if (projectPath == null || _languageCodes.isEmpty) return;

    final relPath = translationRelPath(projectPath, filePath);
    if (relPath.startsWith('..')) return; // outside the project

    final blocks = ref
        .read(translationBlockExtractorProvider)
        .extract(content, _languageCodes);
    if (blocks.isEmpty) return; // not a translation file

    final newFileState = reconcileFile(
      prior: state.files[relPath],
      blocks: blocks,
      nowIso: DateTime.now().toUtc().toIso8601String(),
    );
    _updateFile(relPath, newFileState);
    _schedulePersist();
  }

  /// Clear the stale flag on one translation (without editing content).
  void markReviewedAction(String relPath, String blockId, String lang) {
    final file = state.files[relPath];
    if (file == null) return;
    _updateFile(relPath, markReviewed(file, blockId, lang));
    _schedulePersist();
  }

  /// Clear the stale flag on every translation in a file.
  void markAllReviewedAction(String relPath) {
    final file = state.files[relPath];
    if (file == null) return;
    _updateFile(relPath, markAllReviewed(file));
    _schedulePersist();
  }

  void _updateFile(String relPath, TranslationFileState fileState) {
    final files = Map<String, TranslationFileState>.from(state.files)
      ..[relPath] = fileState;
    state = state.copyWith(files: files);
  }

  void _schedulePersist() {
    _persistTimer?.cancel();
    _persistTimer = Timer(const Duration(milliseconds: 750), _persist);
  }

  Future<void> _persist() async {
    final projectPath = _projectPath;
    if (projectPath == null) return;
    await ref.read(translationSidecarServiceProvider).save(projectPath, state);
  }
}

final translationStateProvider =
    NotifierProvider<TranslationStateNotifier, TranslationProjectState>(
      TranslationStateNotifier.new,
    );
