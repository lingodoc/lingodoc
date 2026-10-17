import 'package:path/path.dart' as p;

/// Utility class for validating and sanitizing file paths
///
/// Provides security-focused path operations to prevent:
/// - Path traversal attacks (../ sequences)
/// - Access to files outside project boundaries
/// - Invalid or malformed paths
class PathValidator {
  /// Language code pattern for ISO 639-1/2 codes
  /// Examples: en, es, zh, eng, fra, en-US, zh-CN
  static final RegExp _languageCodePattern = RegExp(
    r'^[a-z]{2,3}(-[A-Z]{2})?$',
  );

  /// Validates a language code against ISO 639-1/2 format
  ///
  /// Valid examples: en, es, zh, eng, fra, en-US, zh-CN
  /// Invalid examples: ../en, en"; malicious, <script>
  ///
  /// Throws [ArgumentError] if the language code is invalid.
  static void validateLanguageCode(String languageCode) {
    if (languageCode.isEmpty) {
      throw ArgumentError.value(
        languageCode,
        'languageCode',
        'Language code cannot be empty',
      );
    }

    if (!_languageCodePattern.hasMatch(languageCode)) {
      throw ArgumentError.value(
        languageCode,
        'languageCode',
        'Invalid language code format. Expected ISO 639-1/2 format '
            '(e.g., "en", "en-US", "fra")',
      );
    }
  }

  /// Normalizes and sanitizes a path
  ///
  /// Returns the normalized absolute path, resolving any .. or . sequences.
  /// Does NOT validate the path exists - only normalizes it.
  static String normalize(String inputPath) {
    // First normalize to resolve .. and . sequences
    final normalized = p.normalize(inputPath);

    // Convert to absolute if relative
    if (!p.isAbsolute(normalized)) {
      return p.absolute(normalized);
    }

    return normalized;
  }

  /// Validates that a path is within a specified boundary directory
  ///
  /// Returns true if [targetPath] is within or equal to [boundaryPath].
  /// Both paths are normalized before comparison.
  ///
  /// Example:
  /// ```dart
  /// isWithinBoundary('/project/src/file.txt', '/project') // true
  /// isWithinBoundary('/project/../etc/passwd', '/project') // false
  /// ```
  static bool isWithinBoundary(String targetPath, String boundaryPath) {
    final normalizedTarget = normalize(targetPath);
    final normalizedBoundary = normalize(boundaryPath);

    // Check if target starts with boundary path
    // Add separator to ensure we're checking full path segments
    final boundaryWithSep = normalizedBoundary.endsWith(p.separator)
        ? normalizedBoundary
        : '$normalizedBoundary${p.separator}';

    return normalizedTarget == normalizedBoundary ||
        normalizedTarget.startsWith(boundaryWithSep);
  }

  /// Sanitizes and validates a project path
  ///
  /// Normalizes the path and validates it's a valid directory path.
  /// Throws [ArgumentError] if the path is invalid or potentially dangerous.
  ///
  /// Note: Does NOT check if the directory exists.
  static String sanitizeProjectPath(String projectPath) {
    if (projectPath.isEmpty) {
      throw ArgumentError.value(
        projectPath,
        'projectPath',
        'Project path cannot be empty',
      );
    }

    // Normalize the path
    final normalized = normalize(projectPath);

    // Check for null bytes (security concern)
    if (projectPath.contains('\x00')) {
      throw ArgumentError.value(
        projectPath,
        'projectPath',
        'Project path contains invalid characters',
      );
    }

    return normalized;
  }

  /// Validates and sanitizes a path ensuring it's within a boundary
  ///
  /// Combines normalization and boundary checking.
  /// Throws [ArgumentError] if the path escapes the boundary.
  ///
  /// Example:
  /// ```dart
  /// sanitizeWithBoundary('../etc/passwd', '/project')  // throws
  /// sanitizeWithBoundary('src/file.txt', '/project')   // returns '/project/src/file.txt'
  /// ```
  static String sanitizeWithBoundary(String targetPath, String boundaryPath) {
    final sanitizedBoundary = sanitizeProjectPath(boundaryPath);

    // Resolve target path relative to boundary
    String resolvedTarget;
    if (p.isAbsolute(targetPath)) {
      resolvedTarget = normalize(targetPath);
    } else {
      resolvedTarget = normalize(p.join(boundaryPath, targetPath));
    }

    // Validate the resolved path is within boundary
    if (!isWithinBoundary(resolvedTarget, sanitizedBoundary)) {
      throw ArgumentError.value(
        targetPath,
        'targetPath',
        'Path escapes project boundary',
      );
    }

    return resolvedTarget;
  }

  /// Validates a filename (not a path) for safety
  ///
  /// Rejects filenames containing path separators or dangerous characters.
  static void validateFilename(String filename) {
    if (filename.isEmpty) {
      throw ArgumentError.value(
        filename,
        'filename',
        'Filename cannot be empty',
      );
    }

    // Check for path separators
    if (filename.contains('/') || filename.contains('\\')) {
      throw ArgumentError.value(
        filename,
        'filename',
        'Filename cannot contain path separators',
      );
    }

    // Check for parent directory references
    if (filename == '..' || filename == '.') {
      throw ArgumentError.value(filename, 'filename', 'Invalid filename');
    }

    // Check for null bytes
    if (filename.contains('\x00')) {
      throw ArgumentError.value(
        filename,
        'filename',
        'Filename contains invalid characters',
      );
    }
  }

  /// Validates an output directory path
  ///
  /// Similar to sanitizeWithBoundary but specifically for output directories.
  /// Ensures the output directory is within the project boundary.
  static String validateOutputDirectory(String outputDir, String projectPath) {
    if (outputDir.isEmpty) {
      // Default to 'output' within project
      return p.join(normalize(projectPath), 'output');
    }

    return sanitizeWithBoundary(outputDir, projectPath);
  }
}
