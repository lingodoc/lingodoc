import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../typst/services/typst_compiler.dart';
import '../../typst/services/typst_path_resolver.dart';
import '../../typst/models/compilation_result.dart';

/// State for PDF preview
class PdfPreviewState {
  final String? pdfPath;
  final String? languageCode;
  final bool isCompiling;
  final String? errorMessage;
  final DateTime? lastCompiled;

  const PdfPreviewState({
    this.pdfPath,
    this.languageCode,
    this.isCompiling = false,
    this.errorMessage,
    this.lastCompiled,
  });

  PdfPreviewState copyWith({
    String? pdfPath,
    String? languageCode,
    bool? isCompiling,
    String? errorMessage,
    DateTime? lastCompiled,
    bool clearError = false,
  }) {
    return PdfPreviewState(
      pdfPath: pdfPath ?? this.pdfPath,
      languageCode: languageCode ?? this.languageCode,
      isCompiling: isCompiling ?? this.isCompiling,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastCompiled: lastCompiled ?? this.lastCompiled,
    );
  }
}

/// Provider for the TypstCompiler service
final typstCompilerProvider = Provider<TypstCompiler>((ref) {
  final pathResolver = ref.watch(typstPathResolverProvider);
  return TypstCompiler(pathResolver);
});

/// Controller for managing PDF compilation and preview
class PdfPreviewController {
  final Ref ref;
  final String? languageCode;

  PdfPreviewController(this.ref, this.languageCode);

  Future<CompilationResult> compile({
    required String projectPath,
    String? outputDir,
  }) async {
    if (languageCode == null) {
      return CompilationResult.error(
        message: 'No language selected',
        languageCode: null,
      );
    }

    final compiler = ref.read(typstCompilerProvider);
    return await compiler.compileForLanguage(
      projectPath: projectPath,
      languageCode: languageCode!,
      outputDir: outputDir,
    );
  }

  Future<List<CompilationResult>> compileMultiple({
    required String projectPath,
    required List<String> languageCodes,
    String? outputDir,
  }) async {
    final compiler = ref.read(typstCompilerProvider);
    return await compiler.compileMultipleLanguages(
      projectPath: projectPath,
      languageCodes: languageCodes,
      outputDir: outputDir,
    );
  }
}

/// Provider for the PDF preview controller
final pdfPreviewControllerProvider =
    Provider.family<PdfPreviewController, String?>((ref, languageCode) {
  return PdfPreviewController(ref, languageCode);
});
