#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="PureText"
BUILD_ROOT="$ROOT_DIR/.artifacts"
RELEASE_ROOT="$BUILD_ROOT/release"
APP_BUNDLE="$BUILD_ROOT/$APP_NAME.app"
VERSION_LABEL="${1:-$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$ROOT_DIR/App/Info.plist")}"
ARCHIVE_NAME="$APP_NAME-$VERSION_LABEL-macOS.zip"
ARCHIVE_PATH="$RELEASE_ROOT/$ARCHIVE_NAME"

"$ROOT_DIR/scripts/build_app.sh"

rm -rf "$RELEASE_ROOT"
mkdir -p "$RELEASE_ROOT"

ditto -c -k --keepParent "$APP_BUNDLE" "$ARCHIVE_PATH"

echo "Release archive created at: $ARCHIVE_PATH"
