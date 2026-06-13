# Fix Plan: Auto-Refresh and Page Retention Issues

**Created:** 2026-01-14
**Status:** In Progress

---

## Problem Summary

Two issues need to be fixed:

1. **Auto-refresh not working**: The 10-second periodic refresh is not triggering PDF recompilation/reload
2. **Page position lost on language change**: When switching languages, the PDF jumps back to page 1 instead of staying on the current page

---

## Issue 1: Auto-Refresh Not Firing

### Symptoms
- Auto-refresh toggle shows enabled (icon highlighted)
- No compilation happens every 10 seconds
- PDF only updates when manually compiling or changing language

### Files Involved
- `lib/features/preview/services/auto_refresh_service.dart` - Core timer logic
- `lib/features/preview/widgets/preview_panel.dart` - Main preview panel
- `lib/features/preview/widgets/detached_preview_window.dart` - Detached window
- `lib/features/settings/models/user_preferences.dart` - Has `autoRefreshIntervalSeconds` (unused!)

### What Was Tried (Session 2026-01-14)
- Fixed `_configureAutoRefresh()` to accept `ProjectConfig` parameter instead of re-reading FutureProvider
- This was supposed to ensure the timer gets configured with valid values

### Root Cause Theories to Investigate

1. **Timer not starting**: Check if `autoRefreshService.start()` is actually called
   - Add debug logging to `start()`, `_startPeriodicTimer()`, and timer callback

2. **Timer cancelled prematurely**: Check if something is calling `stop()` or `_cancelTimers()`
   - The `configure()` method calls `_startPeriodicTimer()` which first calls `_cancelTimers()`
   - If `configure()` is called after `start()`, timer gets cancelled and only restarts if `_isEnabled` is true

3. **Callback not updating UI**: Timer fires but callback doesn't trigger setState
   - Check `_handleAutoRefreshResult()` is being called
   - Verify `setState()` updates `_pdfPath`

4. **File change detection blocking**: `_checkForSourceChanges()` returns false
   - Check if `_lastSourceModTime` is being updated incorrectly
   - Source files might not be detected as changed

5. **User preferences not connected**: `autoRefreshIntervalSeconds` in UserPreferences is NOT used
   - `AutoRefreshService` hardcodes 10 seconds at line 59
   - Should read from user preferences

### Debugging Steps

```dart
// Add to auto_refresh_service.dart in _startPeriodicTimer():
void _startPeriodicTimer() {
  print('[AutoRefresh] _startPeriodicTimer called');
  print('[AutoRefresh] _isEnabled: $_isEnabled');
  print('[AutoRefresh] _projectPath: $_projectPath');
  print('[AutoRefresh] _languageCode: $_languageCode');
  print('[AutoRefresh] _periodicCallback: ${_periodicCallback != null}');

  _cancelTimers();

  if (!_isEnabled || _projectPath == null || _languageCode == null || _periodicCallback == null) {
    print('[AutoRefresh] Early return - conditions not met');
    return;
  }

  print('[AutoRefresh] Starting 10-second periodic timer');
  _periodicTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
    print('[AutoRefresh] Timer fired!');
    // ... rest of code
  });
}
```

### Fix Strategy

1. **Add comprehensive debug logging** to trace the exact flow
2. **Check call order**: Ensure `configure()` is called BEFORE `start()`
3. **Verify timer persistence**: Ensure nothing cancels the timer after it starts
4. **Connect user preferences**: Use `autoRefreshIntervalSeconds` from UserPreferences instead of hardcoded 10

---

## Issue 2: Page Position Lost on Language Change

### Symptoms
- On page 5 of English PDF
- Switch to Spanish
- PDF shows page 1 instead of page 5

### Files Involved
- `lib/features/preview/widgets/pdf_viewer.dart` - PDF viewer with page restoration logic

### What Was Tried (Session 2026-01-14)
- Modified `didUpdateWidget()` to detect language changes
- Save page number before path change for language switches
- Don't clear `_savedPageNumber` on language changes

### Root Cause Theories to Investigate

1. **Page save timing**: Controller might not be ready when saving page
   - `_controller.isReady` might be false at the moment of language change
   - Page number saved as null

2. **Page restoration timing**: `onViewerReady` callback might fire before PDF is actually loaded
   - `goToPage()` might fail silently
   - Need retry logic (exists but might not be working)

3. **Key change forcing rebuild**: `_pdfViewerKey = ValueKey(widget.pdfPath)` forces complete rebuild
   - New key = new widget = controller reset
   - Page restoration happens after controller is recreated

4. **Compilation delay**: New PDF might not exist yet when viewer tries to load
   - Language change triggers compile
   - Viewer tries to load before compile finishes

### Debugging Steps

```dart
// Add to pdf_viewer.dart in didUpdateWidget():
@override
void didUpdateWidget(PdfViewer oldWidget) {
  super.didUpdateWidget(oldWidget);

  print('[PdfViewer] didUpdateWidget');
  print('[PdfViewer] oldPath: ${oldWidget.pdfPath}');
  print('[PdfViewer] newPath: ${widget.pdfPath}');
  print('[PdfViewer] oldLang: ${oldWidget.languageCode}');
  print('[PdfViewer] newLang: ${widget.languageCode}');
  print('[PdfViewer] controller.isReady: ${_controller.isReady}');
  print('[PdfViewer] current page: ${_controller.isReady ? _controller.pageNumber : "N/A"}');
  print('[PdfViewer] _savedPageNumber: $_savedPageNumber');

  // ... rest of code with more logging
}
```

### Fix Strategy

1. **Add debug logging** to trace page save/restore flow
2. **Ensure page is saved before any state changes**
3. **Consider NOT changing the key** for language changes (same viewer, different source)
4. **Add explicit page restoration** after compilation completes (not just in viewer)
5. **Store page number at preview_panel level** and pass to viewer

### Alternative Approach: Store Page at Panel Level

Instead of relying on PdfViewer to preserve its own state across rebuilds, store the page number in the parent widget:

```dart
// In preview_panel.dart
class _PreviewPanelState extends ConsumerState<PreviewPanel> {
  int _currentPage = 1;  // Add this

  // When language changes:
  onChanged: (value) {
    if (value != null && config != null) {
      // Save current page before changing
      // Need a way to get current page from PdfViewer

      setState(() {
        _selectedLanguage = value;
      });
      _compileForLanguage(value);
      _configureAutoRefresh(config);
    }
  },

  // Pass to PdfViewer:
  PdfViewer(
    pdfPath: _pdfPath,
    languageCode: _selectedLanguage,
    initialPage: _currentPage,  // Add this prop
    onPageChanged: (page) => _currentPage = page,  // Add callback
  ),
}
```

---

## Implementation Checklist

### Phase 1: Debug and Diagnose
- [ ] Add debug logging to AutoRefreshService
- [ ] Add debug logging to PdfViewer
- [ ] Run app and observe console output
- [ ] Identify exact failure points

### Phase 2: Fix Auto-Refresh
- [ ] Verify timer starts and fires
- [ ] Verify file change detection works
- [ ] Verify callback updates UI
- [ ] Connect to user preferences for interval
- [ ] Test with manual file modifications

### Phase 3: Fix Page Retention
- [ ] Verify page number is saved before language change
- [ ] Verify page restoration is attempted
- [ ] Consider storing page at parent level
- [ ] Test with multi-page documents

### Phase 4: Validation
- [ ] Test auto-refresh with 10-second interval
- [ ] Test language switching preserves page
- [ ] Test in detached window
- [ ] Test edge cases (page > total pages in new language)

---

## Key Code Locations

| Feature | File | Key Methods |
|---------|------|-------------|
| Timer management | `auto_refresh_service.dart:52` | `_startPeriodicTimer()` |
| Timer callback | `auto_refresh_service.dart:59` | Timer.periodic callback |
| File change check | `auto_refresh_service.dart:83` | `_checkForSourceChanges()` |
| Configure timer | `auto_refresh_service.dart:141` | `configure()` |
| Start/stop | `auto_refresh_service.dart:40,46` | `start()`, `stop()` |
| Panel init | `preview_panel.dart:136` | addPostFrameCallback |
| Page save | `pdf_viewer.dart:108` | in `didUpdateWidget()` |
| Page restore | `pdf_viewer.dart:477` | `onViewerReady` callback |
| Retry logic | `pdf_viewer.dart:156` | `_attemptPageRestoration()` |

---

## Commands to Run

```bash
# Run app with debug output
flutter run -d linux 2>&1 | tee debug.log

# Filter for auto-refresh logs
flutter run -d linux 2>&1 | grep -E '\[AutoRefresh\]|\[PdfViewer\]'

# Analyze after changes
flutter analyze

# Run tests
flutter test
```
