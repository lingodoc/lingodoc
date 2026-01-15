import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart' as pdfrx;
import '../../../core/services/timer_service.dart';

/// Widget for displaying a single PDF document using pdfrx
class PdfViewer extends StatefulWidget {
  final String? pdfPath;
  final String? languageCode;
  final VoidCallback? onError;
  final Function(Matrix4)? onMatrixChanged;
  final ValueNotifier<Matrix4?>? externalMatrixNotifier;

  const PdfViewer({
    super.key,
    this.pdfPath,
    this.languageCode,
    this.onError,
    this.onMatrixChanged,
    this.externalMatrixNotifier,
  });

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  final pdfrx.PdfViewerController _controller = pdfrx.PdfViewerController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isUpdatingFromExternal = false;
  String? _lastLoadedPath;
  DateTime? _lastFileModTime;
  int? _savedPageNumber; // Track page number for restoration
  Timer? _restorationRetryTimer; // Timer for retry logic (not managed by TimerService due to short lifecycle)
  int _restorationAttempts = 0;
  static const int _maxRestorationAttempts = 10;
  static const Duration _restorationRetryInterval = Duration(milliseconds: 100);

  // Timer service for centralized timer management
  final TimerService _timerService = TimerService();

  // Unique timer ID for this viewer instance
  late final String _fileWatchTimerId;

  // Use a UniqueKey that only changes when path changes, not on file modifications
  Key? _pdfViewerKey;

  @override
  void initState() {
    super.initState();

    // Generate unique timer ID for this viewer instance
    _fileWatchTimerId = 'pdf_viewer_${widget.languageCode ?? "default"}_${DateTime.now().millisecondsSinceEpoch}';

    // Initialize PDF viewer key based on path
    if (widget.pdfPath != null) {
      _pdfViewerKey = ValueKey(widget.pdfPath);
    }

    _checkPdf();

    // Listen to external matrix changes
    widget.externalMatrixNotifier?.addListener(_onExternalMatrixChanged);

    // Listen to controller changes and notify others
    _controller.addListener(_onControllerChanged);

    // Start periodic file check for automatic reloading (every 2000ms) using TimerService
    _timerService.register(
      _fileWatchTimerId,
      const Duration(milliseconds: 2000),
      _checkIfFileModified,
    );
  }
  
  void _onExternalMatrixChanged() {
    final newMatrix = widget.externalMatrixNotifier?.value;
    if (newMatrix != null && _controller.isReady && !_isUpdatingFromExternal) {
      _isUpdatingFromExternal = true;
      _controller.goTo(newMatrix, duration: Duration.zero);
      _isUpdatingFromExternal = false;
    }
  }
  
  void _onControllerChanged() {
    if (!_isUpdatingFromExternal && _controller.isReady) {
      widget.onMatrixChanged?.call(_controller.value);
    }
  }

  @override
  void didUpdateWidget(PdfViewer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reload PDF if path changed
    if (widget.pdfPath != oldWidget.pdfPath) {
      _cancelRestorationRetry(); // Cancel any pending retry

      // Check if this is a language change (same document, different language)
      // In this case, we want to preserve the current page position
      final isLanguageChange = widget.languageCode != oldWidget.languageCode &&
          oldWidget.pdfPath != null &&
          widget.pdfPath != null;

      // Save current page BEFORE clearing state (for language changes)
      // Always try to save page number if controller is ready
      if (_controller.isReady) {
        final currentPage = _controller.pageNumber;
        if (currentPage != null && (isLanguageChange || currentPage > 1)) {
          _savedPageNumber = currentPage;
        }
      }

      setState(() {
        _isLoading = false;
        _errorMessage = null;
        _lastLoadedPath = null;
        _lastFileModTime = null;

        // Only clear saved page if NOT a language change AND page was 1
        // Language changes should preserve page position
        if (!isLanguageChange && _savedPageNumber == 1) {
          _savedPageNumber = null;
        }

        // For language changes, keep the same key to avoid full widget rebuild
        // This preserves the controller state and makes page restoration more reliable
        // Only create new key for genuinely different documents
        if (widget.pdfPath != null && !isLanguageChange) {
          _pdfViewerKey = ValueKey(widget.pdfPath);
        }
        // For language changes, create a key based on document structure (without language path component)
        // This allows the PDF to reload but with better state preservation
        if (widget.pdfPath != null && isLanguageChange) {
          // Force a new key to load the new PDF, but restore page after
          _pdfViewerKey = ValueKey('${widget.pdfPath}_${DateTime.now().millisecondsSinceEpoch}');
        }
      });
      _checkPdf();
    } else if (widget.pdfPath != null) {
      // Same path - check if file was modified
      _checkIfFileModified();
    }

    // Update external matrix notifier listener
    if (widget.externalMatrixNotifier != oldWidget.externalMatrixNotifier) {
      oldWidget.externalMatrixNotifier?.removeListener(_onExternalMatrixChanged);
      widget.externalMatrixNotifier?.addListener(_onExternalMatrixChanged);
    }
  }
  
  @override
  void dispose() {
    // Cancel file watch timer using TimerService
    _timerService.cancel(_fileWatchTimerId);

    // Cancel restoration retry timer (not managed by TimerService)
    _restorationRetryTimer?.cancel();

    widget.externalMatrixNotifier?.removeListener(_onExternalMatrixChanged);
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  /// Cancel any pending restoration retry timer
  void _cancelRestorationRetry() {
    _restorationRetryTimer?.cancel();
    _restorationRetryTimer = null;
    _restorationAttempts = 0;
  }

  /// Resume file watching after restoration completes
  void _resumeFileWatching() {
    if (mounted && widget.pdfPath != null) {
      _timerService.register(
        _fileWatchTimerId,
        const Duration(milliseconds: 2000),
        _checkIfFileModified,
      );
    }
  }

  /// Attempt to restore the saved page number with retry logic
  Future<void> _attemptPageRestoration() async {
    if (_savedPageNumber == null) {
      return;
    }

    // Pause file watching during restoration to prevent timer conflicts
    _timerService.cancel(_fileWatchTimerId);

    // Cancel any existing retry timer
    _cancelRestorationRetry();

    _restorationAttempts = 0;
    _scheduleRestorationAttempt();
  }

  /// Schedule a single restoration attempt
  void _scheduleRestorationAttempt() {
    if (_restorationAttempts >= _maxRestorationAttempts) {
      _cancelRestorationRetry();
      _resumeFileWatching(); // Resume file watching when giving up
      return;
    }

    _restorationAttempts++;
    
    _restorationRetryTimer = Timer(_restorationRetryInterval, () {
      _tryRestorePage();
    });
  }

  /// Try to restore the page, with retry if not ready
  void _tryRestorePage() {
    if (!mounted) {
      _cancelRestorationRetry();
      return;
    }

    if (_savedPageNumber == null) {
      _cancelRestorationRetry();
      return;
    }

    // Check if controller is ready and has a document
    if (!_controller.isReady) {
      _scheduleRestorationAttempt();
      return;
    }

    // Use saved page number as-is (controller will handle bounds)
    final targetPage = _savedPageNumber!;

    try {
      _controller.goToPage(pageNumber: targetPage);

      // Success - cancel retry timer and resume file watching
      _cancelRestorationRetry();
      _resumeFileWatching();
    } catch (e) {
      _scheduleRestorationAttempt();
    }
  }

  Future<void> _checkPdf() async {
    if (widget.pdfPath == null) {
      setState(() {
        _errorMessage = null;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if file exists
      final file = File(widget.pdfPath!);
      if (!await file.exists()) {
        throw Exception('PDF file not found: ${widget.pdfPath}');
      }

      // Track file modification time
      final stat = await file.stat();
      _lastFileModTime = stat.modified;
      _lastLoadedPath = widget.pdfPath;

      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
      
      // Trigger page restoration after PDF loads
      if (_savedPageNumber != null) {
        // Use a small initial delay to let the PDF viewer initialize
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            _attemptPageRestoration();
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load PDF: $e';
        _isLoading = false;
      });

      widget.onError?.call();
    }
  }

  Future<void> _checkIfFileModified() async {
    if (widget.pdfPath == null || _lastLoadedPath != widget.pdfPath) {
      return;
    }

    try {
      final file = File(widget.pdfPath!);
      if (!await file.exists()) {
        return;
      }

      final stat = await file.stat();

      // If file was modified after last load, reload it
      if (_lastFileModTime == null || stat.modified.isAfter(_lastFileModTime!)) {
        // Save current page number before reloading
        if (_controller.isReady) {
          final currentPage = _controller.pageNumber;
          _savedPageNumber = currentPage;
        }

        // Update modification time FIRST before reloading
        _lastFileModTime = stat.modified;
        
        // Reload the PDF by calling _checkPdf which will handle the reload properly
        await _checkPdf();
      }
    } catch (e) {
      // Error checking file modification - ignore silently
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            border: Border(
              bottom: BorderSide(color: theme.dividerColor),
            ),
          ),
          child: Row(
            children: [
              // Language indicator
              if (widget.languageCode != null) ...[
                Chip(
                  label: Text(widget.languageCode!.toUpperCase()),
                  backgroundColor: theme.colorScheme.primaryContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                const SizedBox(width: 16),
              ],

              const Spacer(),

              // Page navigation controls
              Text(
                'Use mouse wheel or gestures to navigate',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(width: 16),

              // Refresh button
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  // Save page before manual refresh
                  if (_controller.isReady) {
                    _savedPageNumber = _controller.pageNumber;
                  }
                  setState(() {
                    _isLoading = false;
                    _errorMessage = null;
                  });
                  _checkPdf();
                },
                tooltip: 'Reload PDF',
              ),
            ],
          ),
        ),

        // PDF content
        Expanded(
          child: _buildContent(theme),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme) {
    // Loading state
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading PDF...',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
                _checkPdf();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Empty state (no PDF loaded)
    if (widget.pdfPath == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No PDF loaded',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Compile a document to view the preview',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // PDF viewer with pdfrx and scrollbar
    return Container(
      color: theme.colorScheme.surfaceContainerLow,
      child: pdfrx.PdfViewer(
        key: _pdfViewerKey,
        pdfrx.PdfDocumentRefFile(widget.pdfPath!),
        controller: _controller,
        params: pdfrx.PdfViewerParams(
          minScale: 0.5,
          maxScale: 5.0,
          viewerOverlayBuilder: (context, size, handleLinkTap) => [
            pdfrx.PdfViewerScrollThumb(
              controller: _controller,
              orientation: ScrollbarOrientation.right,
            ),
            pdfrx.PdfViewerScrollThumb(
              controller: _controller,
              orientation: ScrollbarOrientation.bottom,
            ),
          ],
          onViewerReady: (document, controller) {
            if (_savedPageNumber != null && _savedPageNumber! > 1) {
              // Use the retry-based restoration which is more robust
              _attemptPageRestoration();
            }
          },
        ),
      ),
    );
  }
}
