#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PACKAGE_DIR="$ROOT_DIR/Packages/PureTextCore"
STRICT_IOS_VALIDATION="${STRICT_IOS_VALIDATION:-0}"

echo "Validating PureTextCore on macOS..."
swift build --package-path "$PACKAGE_DIR"

echo "Checking iOS Simulator availability for PureTextCore..."
DESTINATIONS_OUTPUT="$(cd "$PACKAGE_DIR" && xcodebuild -scheme PureTextCore -showdestinations 2>&1)"

if [[ "$DESTINATIONS_OUTPUT" == *"platform:iOS Simulator"* ]]; then
	echo "Validating PureTextCore on iOS Simulator..."
	(
		cd "$PACKAGE_DIR"
		xcodebuild -scheme PureTextCore -destination 'generic/platform=iOS Simulator' build
	)
else
	echo "iOS Simulator destination is not currently available for PureTextCore."
	echo "Install the iOS Simulator platform/runtime in Xcode to enable local iOS validation."

	if [[ "$STRICT_IOS_VALIDATION" == "1" ]]; then
		exit 1
	fi
fi

echo "PureTextCore compatibility validation finished."
