# LingoDoc Performance Improvement Plan

## Overview

This plan addresses 8 performance issues identified in the codebase. Issues are organized into 3 phases based on impact and complexity.

---

## Phase 1: High-Impact Quick Wins (1-2 hours)

### Issue 1.1: Reduce PDF File Polling Frequency

**File**: `lib/features/preview/widgets/pdf_viewer.dart`
**Line**: 62
**Severity**: High
**Estimated Time**: 15 minutes

**Current Code**:
```dart
_fileWatchTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
  _checkIfFileModified();
});
```

**Change To**:
```dart
_fileWatchTimer = Timer.periodic(const Duration(milliseconds: 2000), (_) {
  _checkIfFileModified();
});
```

**Alternative (Better)**: Replace polling with file system watcher:
```dart
// In initState, replace timer with:
_fileWatcher = File(widget.pdfPath!).watch().listen((event) {
  if (event.type == FileSystemEvent.modify) {
    _checkIfFileModified();
  }
});

// In dispose:
_fileWatcher?.cancel();
```

**Validation**: Open a PDF, verify it still auto-reloads after compilation (within 2 seconds).

---

### Issue 1.2: Debounce Syntax Highlighting

**File**: `lib/features/editor/services/typst_syntax_highlighter.dart`
**Severity**: High
**Estimated Time**: 30 minutes

**Approach**: Create a debounced wrapper or integrate debouncing in the editor.

**Step 1**: Add debounce timer to `HighlightedCodeEditor`

**File**: `lib/features/editor/widgets/highlighted_code_editor.dart`

Add field:
```dart
Timer? _highlightDebounceTimer;
```

Modify `_onTextChanged()`:
```dart
void _onTextChanged() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      if (!_isDirty) {
        setState(() => _isDirty = true);
      }
      widget.onChanged?.call(_controller.text);

      // Debounce autocomplete updates
      _highlightDebounceTimer?.cancel();
      _highlightDebounceTimer = Timer(const Duration(milliseconds: 150), () {
        if (mounted) {
          _updateAutocomplete();
        }
      });
    }
  });
}
```

Add to `dispose()`:
```dart
_highlightDebounceTimer?.cancel();
```

**Validation**: Type rapidly in editor, verify no lag. Autocomplete should appear ~150ms after stopping.

---

### Issue 1.3: Guard AutoComplete setState

**File**: `lib/features/editor/widgets/highlighted_code_editor.dart`
**Line**: 107-141
**Severity**: Medium
**Estimated Time**: 15 minutes

**Current Code**:
```dart
void _updateAutocomplete() {
  // ... gets suggestions ...
  if (mounted) {
    setState(() {
      _showAutocomplete = suggestions.isNotEmpty;
      _suggestions = suggestions;
    });
  }
}
```

**Change To**:
```dart
void _updateAutocomplete() {
  if (!_isTypstFile()) {
    if (_showAutocomplete) {
      setState(() {
        _showAutocomplete = false;
        _suggestions = [];
      });
    }
    return;
  }

  final cursorPosition = _controller.selection.baseOffset;
  if (cursorPosition < 0 || cursorPosition > _controller.text.length) {
    if (_showAutocomplete) {
      setState(() {
        _showAutocomplete = false;
        _suggestions = [];
      });
    }
    return;
  }

  final suggestions = _autocompleteService.getContextSuggestions(
    _controller.text,
    cursorPosition,
  );

  // Only update state if something actually changed
  final shouldShow = suggestions.isNotEmpty;
  if (shouldShow != _showAutocomplete || !_listEquals(_suggestions, suggestions)) {
    setState(() {
      _showAutocomplete = shouldShow;
      _suggestions = suggestions;
    });
  }
}

// Add helper method
bool _listEquals(List<Suggestion> a, List<Suggestion> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i].label != b[i].label) return false;
  }
  return true;
}
```

**Validation**: Add debug print in setState, verify it's not called on every keystroke when suggestions unchanged.

---

## Phase 2: Medium-Impact Improvements (2-3 hours)

### Issue 2.1: Fix PreviewPanel AutoRefresh Reconfiguration

**File**: `lib/features/preview/widgets/preview_panel.dart`
**Line**: 117-139
**Severity**: Medium
**Estimated Time**: 30 minutes

**Problem**: `_buildPanel()` schedules callbacks on every build.

**Solution**: Track configuration state.

Add fields to `_PreviewPanelState`:
```dart
String? _lastConfiguredProjectPath;
String? _lastConfiguredLanguage;
String? _lastConfiguredOutputDir;
bool _autoRefreshInitialized = false;
```

Replace the autorefresh initialization block:
```dart
if (config != null && _selectedLanguage != null) {
  final projectPath = projectState.projectPath;
  final outputDir = config.projectSettings.outputDirectory;

  // Only reconfigure if settings actually changed
  final needsReconfigure =
      projectPath != _lastConfiguredProjectPath ||
      _selectedLanguage != _lastConfiguredLanguage ||
      outputDir != _lastConfiguredOutputDir ||
      !_autoRefreshInitialized;

  if (needsReconfigure) {
    _lastConfiguredProjectPath = projectPath;
    _lastConfiguredLanguage = _selectedLanguage;
    _lastConfiguredOutputDir = outputDir;
    _autoRefreshInitialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final autoRefreshState = ref.read(autoRefreshProvider);
      final shouldBeEnabled = config.projectSettings.autoCompile;
      final autoRefreshService = ref.read(autoRefreshServiceProvider);

      if (shouldBeEnabled) {
        ref.read(autoRefreshProvider.notifier).enable();
        _configureAutoRefresh();
        autoRefreshService.start();
      } else {
        ref.read(autoRefreshProvider.notifier).disable();
        autoRefreshService.stop();
      }
    });
  }
}
```

**Validation**: Add debug print, verify configuration only happens when language/project changes.

---

### Issue 2.2: Optimize EditorNotifier List Operations

**File**: `lib/features/editor/services/editor_service.dart`
**Severity**: Medium
**Estimated Time**: 20 minutes

**Current** (in `openFile`):
```dart
final updatedTabs = state.tabs
    .map((tab) => tab.copyWith(isActive: false))
    .toList();
updatedTabs.add(newTab);
```

**Optimized**:
```dart
final updatedTabs = List<EditorTab>.generate(
  state.tabs.length + 1,
  (i) => i < state.tabs.length
      ? state.tabs[i].copyWith(isActive: false)
      : newTab,
  growable: false,
);
```

**Current** (in `setActiveTab`):
```dart
final updatedTabs = state.tabs.asMap().entries.map((entry) {
  return entry.value.copyWith(isActive: entry.key == index);
}).toList();
```

**Optimized**:
```dart
// Only create new list if active status actually changes
if (state.activeTabIndex == index) return;

final updatedTabs = List<EditorTab>.generate(
  state.tabs.length,
  (i) => state.tabs[i].copyWith(isActive: i == index),
  growable: false,
);
```

**Validation**: Open/close many tabs rapidly, verify no noticeable lag.

---

### Issue 2.3: Reduce Timer Coordination Issues

**File**: `lib/features/preview/widgets/pdf_viewer.dart`
**Severity**: Medium
**Estimated Time**: 30 minutes

**Problem**: Restoration retry timer (100ms intervals, up to 10 attempts) can overlap with file watch timer.

**Solution**: Use a single coordinated approach.

**Option A** (Simple): Cancel file watch during restoration:
```dart
Future<void> _attemptPageRestoration() async {
  if (_savedPageNumber == null) return;

  // Pause file watching during restoration
  _fileWatchTimer?.cancel();

  _cancelRestorationRetry();
  _restorationAttempts = 0;
  _scheduleRestorationAttempt();
}

void _onRestorationComplete() {
  // Resume file watching after restoration
  if (mounted && widget.pdfPath != null) {
    _fileWatchTimer = Timer.periodic(const Duration(milliseconds: 2000), (_) {
      _checkIfFileModified();
    });
  }
}
```

**Option B** (Better long-term): Create a centralized timer service (see Phase 3).

---

## Phase 3: Architectural Improvements (4+ hours)

### Issue 3.1: Incremental Syntax Highlighting

**File**: `lib/features/editor/services/typst_syntax_highlighter.dart`
**Severity**: High (for large files)
**Estimated Time**: 2-3 hours

**Approach**: Only re-highlight visible lines + changed region.

**Step 1**: Modify `highlight()` to accept line range:
```dart
TextSpan highlightRange(
  String code, {
  required int startLine,
  required int endLine,
  TextStyle? baseStyle,
}) {
  // Only process lines in range
  final lines = code.split('\n');
  final rangeStart = lines.take(startLine).join('\n').length;
  final rangeEnd = lines.take(endLine + 1).join('\n').length;

  // Apply patterns only to visible range
  // Cache results for unchanged lines
}
```

**Step 2**: Track changed line numbers in editor.

**Step 3**: Only re-highlight changed lines + buffer.

---

### Issue 3.2: Preserve PDF Viewer State in Grid

**File**: `lib/features/preview/widgets/language_grid.dart`
**Severity**: Low-Medium
**Estimated Time**: 1-2 hours

**Approach**: Use `AutomaticKeepAliveClientMixin` or custom state management.

**Option A**: Wrap PdfViewer in keep-alive:
```dart
class _KeepAlivePdfViewer extends StatefulWidget {
  final String? pdfPath;
  final String? languageCode;
  // ... other props

  @override
  State<_KeepAlivePdfViewer> createState() => _KeepAlivePdfViewerState();
}

class _KeepAlivePdfViewerState extends State<_KeepAlivePdfViewer>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PdfViewer(
      pdfPath: widget.pdfPath,
      languageCode: widget.languageCode,
      // ...
    );
  }
}
```

**Option B**: Store viewer controllers in parent state and reuse them.

---

### Issue 3.3: Centralized Timer Service (Future Enhancement)

**New File**: `lib/core/services/timer_service.dart`

```dart
/// Coordinates all periodic operations to prevent timer conflicts
class TimerService {
  static final TimerService _instance = TimerService._();
  factory TimerService() => _instance;
  TimerService._();

  final Map<String, Timer> _timers = {};
  final Map<String, DateTime> _lastExecution = {};

  void register(String id, Duration interval, VoidCallback callback) {
    cancel(id);
    _timers[id] = Timer.periodic(interval, (_) {
      _lastExecution[id] = DateTime.now();
      callback();
    });
  }

  void cancel(String id) {
    _timers[id]?.cancel();
    _timers.remove(id);
  }

  void cancelAll() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }
}
```

---

## Implementation Checklist

### Phase 1 (Do First)
- [ ] 1.1 Increase PDF polling interval (500ms → 2000ms)
- [ ] 1.2 Add debounce to syntax highlighting/autocomplete
- [ ] 1.3 Guard setState in _updateAutocomplete

### Phase 2 (Do Second)
- [ ] 2.1 Fix PreviewPanel autorefresh reconfiguration
- [ ] 2.2 Optimize EditorNotifier list operations
- [ ] 2.3 Coordinate PDF viewer timers

### Phase 3 (Future Sessions)
- [ ] 3.1 Implement incremental syntax highlighting
- [ ] 3.2 Preserve PDF viewer state in grid
- [ ] 3.3 Create centralized timer service

---

## Testing Strategy

After each change:

1. **Manual Testing**:
   - Open large .typ file (500+ lines)
   - Type rapidly, verify no lag
   - Switch languages, verify preview updates
   - Toggle grid mode, verify smooth transitions

2. **Performance Metrics**:
   - Add `debugPrint` with timestamps to measure:
     - Time between keystroke and autocomplete display
     - Time between save and PDF refresh
     - setState call frequency

3. **Memory Profiling**:
   - Use Flutter DevTools Memory tab
   - Watch for GC pressure during rapid typing
   - Monitor object allocations during tab switching

---

## Rollback Strategy

If any change causes issues:

1. Each issue is independent - can be reverted individually
2. Keep original code commented (temporarily) during testing
3. Use git commits per-issue for easy cherry-pick/revert

---

## Expected Outcomes

| Metric | Before | After Phase 1 | After Phase 2 |
|--------|--------|---------------|---------------|
| File stat() calls/sec | 2-8 | 0.5-2 | 0.5-2 |
| setState calls on typing | Every key | ~7/sec | ~7/sec |
| Typing input lag | Noticeable | Minimal | Minimal |
| Memory churn | Moderate | Moderate | Low |
