#!/usr/bin/env bash
# Captures the README screenshots into docs/screenshots/ (dark mode, clean status bar).
#
# The UI test target is disabled in BudgetTracker.xctestplan so it stays out of regular test
# runs; this script enables it for the duration of the capture and restores the plan afterwards.
set -euo pipefail

cd "$(dirname "$0")/.."

DEVICE="${DEVICE:-iPhone 17}"
OUTPUT_DIR="$PWD/docs/screenshots"
TEST_PLAN="BudgetTracker.xctestplan"

mkdir -p "$OUTPUT_DIR"
cp "$TEST_PLAN" "$TEST_PLAN.bak"
trap 'mv "$TEST_PLAN.bak" "$TEST_PLAN"' EXIT
sed -i '' 's/"enabled" : false,/"enabled" : true,/' "$TEST_PLAN"

xcrun simctl boot "$DEVICE" 2>/dev/null || true
xcrun simctl ui "$DEVICE" appearance dark
xcrun simctl status_bar "$DEVICE" override \
  --time 9:41 --batteryState charged --batteryLevel 100 --cellularBars 4 --wifiBars 3

TEST_RUNNER_SCREENSHOT_DIR="$OUTPUT_DIR" xcodebuild test \
  -project BudgetTracker.xcodeproj \
  -scheme BudgetTracker \
  -destination "platform=iOS Simulator,name=$DEVICE" \
  -only-testing BudgetTrackerUITests/ReadmeScreenshotTests \
  -parallel-testing-enabled NO \
  -resultBundlePath "${RESULT_BUNDLE:-$(mktemp -d)/screenshots.xcresult}" \
  -quiet

xcrun simctl status_bar "$DEVICE" clear
echo "Screenshots written to $OUTPUT_DIR"
