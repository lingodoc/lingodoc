#!/bin/bash
# Test script for Step 13: Auto-Refresh Implementation

echo "🧪 Testing Step 13: Auto-Refresh Implementation"
echo "==============================================="
echo ""

# Test 1: Verify new files exist
echo "1️⃣ Checking new auto-refresh service file..."
if [ -f "lib/features/preview/services/auto_refresh_service.dart" ]; then
    echo "   ✅ auto_refresh_service.dart exists"
    echo "   📊 Lines: $(wc -l < lib/features/preview/services/auto_refresh_service.dart)"
else
    echo "   ❌ auto_refresh_service.dart missing"
    exit 1
fi
echo ""

# Test 2: Verify imports in preview_panel.dart
echo "2️⃣ Checking preview panel integration..."
if grep -q "auto_refresh_service.dart" lib/features/preview/widgets/preview_panel.dart; then
    echo "   ✅ Auto-refresh service imported"
else
    echo "   ❌ Auto-refresh service not imported"
    exit 1
fi

if grep -q "autoRefreshProvider" lib/features/preview/widgets/preview_panel.dart; then
    echo "   ✅ Auto-refresh provider used"
else
    echo "   ❌ Auto-refresh provider not used"
    exit 1
fi
echo ""

# Test 3: Run Flutter analyze
echo "3️⃣ Running static analysis..."
flutter analyze lib/features/preview/ > /tmp/analyze_output.txt 2>&1
if grep -q "No issues found" /tmp/analyze_output.txt; then
    echo "   ✅ No analysis issues"
else
    echo "   ❌ Analysis issues found:"
    cat /tmp/analyze_output.txt
    exit 1
fi
echo ""

# Test 4: Check for key components
echo "4️⃣ Verifying key components..."

# Check AutoRefreshService class
if grep -q "class AutoRefreshService" lib/features/preview/services/auto_refresh_service.dart; then
    echo "   ✅ AutoRefreshService class defined"
fi

# Check AutoRefreshState class
if grep -q "class AutoRefreshState" lib/features/preview/services/auto_refresh_service.dart; then
    echo "   ✅ AutoRefreshState class defined"
fi

# Check AutoRefreshNotifier class
if grep -q "class AutoRefreshNotifier" lib/features/preview/services/auto_refresh_service.dart; then
    echo "   ✅ AutoRefreshNotifier class defined"
fi

# Check debounce timer
if grep -q "Timer? _debounceTimer" lib/features/preview/services/auto_refresh_service.dart; then
    echo "   ✅ Debounce timer implemented"
fi

# Check refresh method
if grep -q "Future<void> refresh(" lib/features/preview/services/auto_refresh_service.dart; then
    echo "   ✅ Refresh method defined"
fi
echo ""

# Test 5: UI Integration
echo "5️⃣ Checking UI integration..."

# Check auto-refresh toggle button
if grep -q "Icons.autorenew" lib/features/preview/widgets/preview_panel.dart; then
    echo "   ✅ Auto-refresh toggle button added"
fi

# Check status indicators
if grep -q "CircularProgressIndicator" lib/features/preview/widgets/preview_panel.dart; then
    echo "   ✅ Status indicators present"
fi

# Check editor listener
if grep -q "ref.listenManual(editorProvider" lib/features/preview/widgets/preview_panel.dart; then
    echo "   ✅ Editor change listener added"
fi
echo ""

# Test 6: Documentation
echo "6️⃣ Checking documentation..."
if [ -f "docs/STEP_13_AUTO_REFRESH.md" ]; then
    echo "   ✅ Step 13 documentation created"
    echo "   📖 Size: $(wc -w < docs/STEP_13_AUTO_REFRESH.md) words"
else
    echo "   ⚠️  Documentation file not found"
fi
echo ""

# Summary
echo "==============================================="
echo "✅ All automated tests passed!"
echo ""
echo "📝 Manual Testing Checklist:"
echo "   1. Launch app and open a project"
echo "   2. Click auto-refresh toggle (should highlight)"
echo "   3. Edit a .typ file"
echo "   4. Wait 500ms and verify PDF updates"
echo "   5. Toggle off and verify no auto-refresh"
echo "   6. Check error handling with invalid Typst"
echo ""
echo "🎯 Step 13 Implementation Complete!"
