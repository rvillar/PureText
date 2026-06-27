#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_PATH="$ROOT_DIR/Apps/PureTextiOS/PureTextiOS.xcodeproj"
LOCAL_CONFIG_PATH="$ROOT_DIR/Apps/PureTextiOS/Config/Local.xcconfig"
ARCHIVE_DIR="$ROOT_DIR/.artifacts/ios/archives"
TIMESTAMP="$(date +"%Y%m%d-%H%M%S")"
ARCHIVE_PATH="$ARCHIVE_DIR/PureText-$TIMESTAMP.xcarchive"

if [[ ! -f "$LOCAL_CONFIG_PATH" ]]; then
  echo "Missing local signing config: $LOCAL_CONFIG_PATH"
  echo "Copy Apps/PureTextiOS/Config/Local.example.xcconfig to Local.xcconfig and fill your local values before archiving."
  exit 1
fi

mkdir -p "$ARCHIVE_DIR"

echo "Creating iOS archive at:"
echo "  $ARCHIVE_PATH"

xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme PureTextiOS \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  archive

echo
echo "Archive created successfully."
echo "Next steps:"
echo "1. Open Xcode Organizer and validate/upload the archive, or"
echo "2. Use the .xcarchive at the path above for your local distribution workflow."
