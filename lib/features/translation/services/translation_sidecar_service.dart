import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/translation_state.dart';

/// Loads and persists the translation-staleness sidecar
/// (`<project>/.lingodoc/translation-state.json`).
///
/// The file is committed to git so review status travels with the content, so
/// it is written sorted + pretty-printed to keep diffs small and conflicts
/// localized to the affected block.
class TranslationSidecarService {
  static const String dirName = '.lingodoc';
  static const String fileName = 'translation-state.json';

  String _filePath(String projectPath) =>
      path.join(projectPath, dirName, fileName);

  /// Load the sidecar, returning an empty state when it is missing or invalid.
  Future<TranslationProjectState> load(String projectPath) async {
    final file = File(_filePath(projectPath));
    if (!await file.exists()) return const TranslationProjectState();
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) {
        return const TranslationProjectState();
      }
      return TranslationProjectState.fromJson(decoded);
    } catch (_) {
      // Corrupt sidecar: start fresh rather than blocking the editor.
      return const TranslationProjectState();
    }
  }

  /// Persist [state], creating `.lingodoc/` if needed.
  Future<void> save(String projectPath, TranslationProjectState state) async {
    final file = File(_filePath(projectPath));
    await file.parent.create(recursive: true);
    await file.writeAsString(encode(state));
  }

  /// Sorted, pretty-printed JSON (stable, diff-friendly). Exposed for testing.
  String encode(TranslationProjectState state) {
    final ordered = _sortKeysDeep(state.toJson());
    return const JsonEncoder.withIndent('  ').convert(ordered);
  }

  dynamic _sortKeysDeep(dynamic node) {
    if (node is Map) {
      final keys = node.keys.map((k) => k.toString()).toList()..sort();
      return {for (final k in keys) k: _sortKeysDeep(node[k])};
    }
    if (node is List) return node.map(_sortKeysDeep).toList();
    return node;
  }
}
