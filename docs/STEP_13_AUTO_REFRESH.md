# Step 13: Auto-Refresh Implementation

## Overview
Implemented timer-based auto-refresh system for LingoDoc that automatically recompiles and updates PDF previews when editor content changes.

## Implementation Summary

### 1. Auto-Refresh Service (`lib/features/preview/services/auto_refresh_service.dart`)
**New file** - Core service managing auto-refresh functionality

#### Key Components:
- **AutoRefreshService**: Main service class with debounced compilation
  - `refresh()`: Triggers debounced compilation on editor changes
  - `refreshImmediate()`: Bypasses debouncing for manual refresh
  - Timer management with automatic cleanup

- **AutoRefreshState**: State model tracking refresh status
  - `isEnabled`: Auto-refresh toggle state
  - `isRefreshing`: Current compilation status
  - `lastRefreshTime`: Timestamp of last successful refresh
  - `errorMessage`: Error details if compilation fails

- **AutoRefreshNotifier**: State management provider
  - `toggle()`: Enable/disable auto-refresh
  - `setRefreshing()`: Update compilation status
  - `updateLastRefresh()`: Record successful refresh
  - `setError()`: Handle compilation errors

#### Debouncing Mechanism:
```dart
Timer? _debounceTimer;

_debounceTimer?.cancel();
_debounceTimer = Timer(Duration(milliseconds: debounceMs), () {
  // Perform compilation after debounce period
});
```

### 2. Preview Panel Integration (`lib/features/preview/widgets/preview_panel.dart`)
**Modified** - Added auto-refresh UI controls and editor change listeners

#### Key Changes:

1. **Editor Change Listener**:
   - Added in `initState()` to watch editor state changes
   - Triggers auto-refresh only when content actually changes
   - Respects auto-refresh enabled state

```dart
ref.listenManual(editorProvider, (previous, next) {
  _onEditorChanged(previous, next);
});
```

2. **Auto-Refresh UI Toggle**:
   - Icon button with visual state indicator
   - Shows enabled/disabled state with different icons
   - Displays spinner when compilation in progress
   - Shows error tooltip if compilation fails

3. **Automatic Initialization**:
   - Reads `autoCompile` from project settings
   - Initializes auto-refresh state on project load
   - Syncs UI state with project configuration

### 3. Configuration Integration
Uses existing `ProjectSettings` fields:
- `autoCompile` (bool): Master toggle for auto-refresh feature
- `compileDebounceMs` (int): Debounce delay in milliseconds (default: 500ms)

## User Experience

### Visual Feedback
1. **Auto-Refresh Toggle**:
   - Outlined icon (⟳) when disabled
   - Filled icon (⟳) in primary color when enabled
   - Tooltip: "Auto-refresh enabled/disabled"

2. **Compilation Status**:
   - Small spinner (12x12) shown during auto-refresh compilation
   - Doesn't block manual compilation button
   - Error icon with tooltip on failure

3. **Non-Intrusive**:
   - Auto-refresh errors logged to console, not snackbars
   - Preserves user workflow without interruptions
   - Manual compile button remains available

### Workflow
1. User opens project → Auto-refresh initializes based on config
2. User edits `.typ` file → Content change detected
3. After debounce period → Compilation triggered automatically
4. PDF viewer updates → New preview displayed
5. Status indicators → Visual feedback throughout

## Technical Details

### Debouncing Strategy
- **Default**: 500ms (configurable via `config.toml`)
- **Purpose**: Prevents excessive compilation during rapid typing
- **Implementation**: Timer-based with cancellation on new changes

### State Management
- **Riverpod providers**: Clean separation of concerns
- **State notifications**: Reactive UI updates
- **Lifecycle management**: Proper disposal on widget unmount

### Performance Considerations
1. **Debouncing**: Reduces CPU usage during active editing
2. **Conditional triggering**: Only compiles on actual content changes
3. **Background compilation**: Non-blocking UI operations
4. **Error handling**: Graceful degradation on failures

## Testing Checklist

### Manual Testing Steps:
1. ✅ **Enable auto-refresh**:
   - Click auto-refresh toggle
   - Icon should change to filled state
   - Primary color should apply

2. ✅ **Edit content**:
   - Open a `.typ` file
   - Make changes
   - Wait for debounce period (500ms)
   - PDF should update automatically

3. ✅ **Disable auto-refresh**:
   - Click toggle again
   - Icon returns to outlined state
   - Edits should NOT trigger compilation

4. ✅ **Project settings**:
   - Set `auto_compile = false` in config.toml
   - Reload project
   - Auto-refresh should be disabled by default

5. ✅ **Error handling**:
   - Introduce syntax error in .typ file
   - Error icon should appear
   - Tooltip shows error message

6. ✅ **Manual override**:
   - With auto-refresh enabled
   - Manual compile button should still work
   - Both can coexist without conflicts

## Configuration Example

```toml
# config.toml
[project_settings]
default_language = { code = "en", name = "English" }
output_directory = "output"
auto_compile = true          # Enable auto-refresh by default
compile_debounce_ms = 500    # Wait 500ms before compiling
```

## Future Enhancements

### Potential Improvements:
1. **Periodic refresh**: Optional timer-based refresh (e.g., every 30s)
2. **Smart compilation**: Only compile affected languages
3. **File watching**: System-level file watchers for external changes
4. **Settings UI**: In-app configuration panel for debounce timing
5. **Compilation queue**: Handle multiple pending compilations

### Settings Dialog Integration (Step 15):
When settings dialog is implemented, add controls for:
- Auto-refresh toggle
- Debounce timing slider (100ms - 2000ms)
- Periodic refresh interval
- Compilation notifications preferences

## Files Modified

### New Files:
- `lib/features/preview/services/auto_refresh_service.dart` (169 lines)

### Modified Files:
- `lib/features/preview/widgets/preview_panel.dart`:
  - Added auto-refresh imports
  - Added `initState()` with editor listener
  - Added `_onEditorChanged()` handler
  - Added `_triggerAutoRefresh()` method
  - Added `_handleAutoRefreshResult()` handler
  - Added auto-refresh UI toggle with status indicators
  - Added project settings initialization

## Related Documentation

- **Step 8**: Typst compiler integration (compilation foundation)
- **Step 9**: PDF preview (viewer that auto-refresh updates)
- **Step 11**: Syntax highlighting (editor integration point)
- **Step 15**: Settings dialog (future UI for configuration)

## Code Quality

### Analysis:
```bash
flutter analyze lib/features/preview/
# Result: No issues found! ✅
```

### Code Generation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
# Result: Built successfully with 0 outputs ✅
```

## Conclusion

Step 13 successfully implements auto-refresh with:
- ✅ Timer-based debouncing (500ms default)
- ✅ Editor change detection
- ✅ Visual status indicators
- ✅ Project settings integration
- ✅ Error handling
- ✅ Non-intrusive UX
- ✅ Zero analysis warnings

The feature provides a smooth, live-preview experience while maintaining system performance through intelligent debouncing and conditional triggering.
