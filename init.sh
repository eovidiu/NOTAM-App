#!/bin/bash
# NOTAM iOS App - Session Initialization
set -e

echo "=== Session Initialization ==="

echo "[1/4] Checking Xcode availability..."
if ! command -v xcodebuild &> /dev/null; then
    echo "ERROR: Xcode command line tools not found"
    exit 1
fi
xcodebuild -version

echo "[2/4] Checking Swift version..."
swift --version

echo "[3/4] Building project..."
if [ -d "NOTAMApp.xcodeproj" ]; then
    xcodebuild -project NOTAMApp.xcodeproj -scheme NOTAMApp -destination 'platform=iOS Simulator,name=iPhone 15' build 2>/dev/null || {
        echo "WARNING: Build failed or project not yet created"
    }
else
    echo "INFO: Xcode project not yet created"
fi

echo "[4/4] Running tests..."
if [ -d "NOTAMApp.xcodeproj" ]; then
    xcodebuild -project NOTAMApp.xcodeproj -scheme NOTAMApp -destination 'platform=iOS Simulator,name=iPhone 15' test 2>/dev/null || {
        echo "WARNING: Tests failed or not yet implemented"
    }
else
    echo "INFO: Tests will run after project creation"
fi

echo "=== Initialization Complete ==="
echo ""
echo "Next steps:"
echo "  1. Read claude-progress.txt for current status"
echo "  2. Check features.json for feature list"
echo "  3. Review context_summary.md for decisions"
