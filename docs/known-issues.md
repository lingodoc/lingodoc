# Known Issues

## PDF Page Retention During Recompilation

**Status**: Open
**Priority**: Medium
**Affects**: v0.1.0

### Problem
PDF viewer doesn't remember the current page when recompiling. After auto-refresh or manual compilation, the PDF jumps back to page 1.

### Root Cause
The page restoration mechanism exists but has timing issues:
- Code attempts to save page number before reload
- Code attempts to restore using `controller.goToPage()`
- However, the restoration happens too early before controller is fully ready
- The widget key system conflicts with controller state management

### Solution Approach
Implement retry logic with:
1. Polling to check `controller.isReady` multiple times
2. Increased delay or callback-based restoration
3. Better logging to diagnose timing issues
4. Verify controller state before page navigation

### File Location
`lib/features/preview/widgets/pdf_viewer.dart`

### Workaround
None currently - users must manually navigate back to their page after recompilation.

---

_Last updated: 2024-12-27_
