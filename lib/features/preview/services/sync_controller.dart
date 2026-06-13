import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../typst/models/sync_anchor.dart';
import 'sync_mapping_service.dart';

/// A request to scroll the PDF to a given location (editor → PDF).
class SyncForwardTarget {
  final SyncTarget target;

  /// Monotonic id so the listener fires even when the same target is requested
  /// twice in a row (a ValueNotifier ignores equal values otherwise).
  final int requestId;

  const SyncForwardTarget(this.target, this.requestId);
}

/// A request to move the editor caret to a source line (PDF → editor).
class SyncInverseTarget {
  final int line;
  final int requestId;

  /// File the jump targets. The consumer opens [filePath] (if not already
  /// active) then moves the caret to [line].
  final String filePath;

  const SyncInverseTarget(this.line, this.requestId, {required this.filePath});
}

/// Shared, same-window channel that connects the editor and the PDF preview.
///
/// Holds the global [SyncMap] (rebuilt whenever the compiled-PDF anchors change
/// via [setAnchors]) and exposes [forwardTarget]/[inverseTarget] notifiers that
/// the two panes listen to. Exposed as a plain singleton via
/// [syncControllerProvider] so it does not trigger Riverpod rebuilds.
class SyncController {
  /// On when the PDF should continuously follow the editor caret.
  final ValueNotifier<bool> continuousEnabled = ValueNotifier(false);

  /// Editor → PDF scroll requests.
  final ValueNotifier<SyncForwardTarget?> forwardTarget = ValueNotifier(null);

  /// PDF → editor caret requests.
  final ValueNotifier<SyncInverseTarget?> inverseTarget = ValueNotifier(null);

  /// Number of anchors currently available (0 ⇒ sync unavailable). UI controls
  /// listen to this to enable/disable themselves.
  final ValueNotifier<int> anchorCount = ValueNotifier(0);

  /// Last diagnostic message from the anchor probe (null on success).
  String? lastError;

  SyncMap _map = SyncMap.empty();
  int _requestCounter = 0;

  // ---- Inputs (called by the preview after each compile) ------------------

  /// Replace the anchor set with the freshly-queried [anchors]. [error] carries
  /// a diagnostic when the probe failed (anchors will be empty).
  void setAnchors(List<SyncAnchor> anchors, {String? error}) {
    _map = SyncMap(anchors);
    lastError = error;
    anchorCount.value = _map.anchorCount;
    if (kDebugMode) {
      debugPrint('[sync] anchors=${_map.anchorCount}'
          '${error != null ? ' error=$error' : ''}');
    }
  }

  // ---- Requests (called by editor / preview) ------------------------------

  /// Editor asks the PDF to reveal [caretLine] (1-based) of [filePath].
  /// Returns true if a target was resolved.
  bool requestForward(String filePath, int caretLine) {
    final target = _map.forward(filePath, caretLine);
    if (target == null) return false;
    forwardTarget.value = SyncForwardTarget(target, ++_requestCounter);
    return true;
  }

  /// PDF asks the editor to jump to the source for PDF ([page], [y]). [y] is in
  /// points from the page top (0 ⇒ top of page). Returns true if resolved.
  bool requestInverse(int page, double y) {
    final loc = _map.inverse(page, y);
    if (loc == null) return false;
    inverseTarget.value =
        SyncInverseTarget(loc.line, ++_requestCounter, filePath: loc.filePath);
    return true;
  }

  void toggleContinuous() {
    continuousEnabled.value = !continuousEnabled.value;
  }

  void dispose() {
    continuousEnabled.dispose();
    forwardTarget.dispose();
    inverseTarget.dispose();
    anchorCount.dispose();
  }
}

/// Singleton [SyncController] shared by the editor and preview panes.
final syncControllerProvider = Provider<SyncController>((ref) {
  final controller = SyncController();
  ref.onDispose(controller.dispose);
  return controller;
});
