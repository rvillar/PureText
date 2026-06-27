#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ARCHIVES_DIR="$ROOT_DIR/.artifacts/ios/archives"
EXPORT_DIR="$ROOT_DIR/.artifacts/ios/export"
LOCAL_EXPORT_OPTIONS="$ROOT_DIR/Apps/PureTextiOS/Config/ExportOptions.local.plist"

ARCHIVE_PATH="${1:-}"

if [[ -z "$ARCHIVE_PATH" ]]; then
  if [[ ! -d "$ARCHIVES_DIR" ]]; then
    echo "No archive directory found at: $ARCHIVES_DIR"
    echo "Create an archive first with ./scripts/archive_ios_app.sh"
    exit 1
  fi

  ARCHIVE_PATH="$(find "$ARCHIVES_DIR" -maxdepth 1 -name '*.xcarchive' -print | sort | tail -n 1)"
fi

if [[ -z "$ARCHIVE_PATH" || ! -d "$ARCHIVE_PATH" ]]; then
  echo "Archive not found."
  echo "Pass the .xcarchive path explicitly or create one first with ./scripts/archive_ios_app.sh"
  exit 1
fi

if [[ ! -f "$LOCAL_EXPORT_OPTIONS" ]]; then
  echo "Missing local export options: $LOCAL_EXPORT_OPTIONS"
  echo "Copy Apps/PureTextiOS/Config/ExportOptions.example.plist to ExportOptions.local.plist and fill your local values before exporting."
  exit 1
fi

ARCHIVE_NAME="$(basename "$ARCHIVE_PATH" .xcarchive)"
EXPORT_PATH="$EXPORT_DIR/$ARCHIVE_NAME"

mkdir -p "$EXPORT_PATH"

echo "Exporting archive:"
echo "  $ARCHIVE_PATH"
echo "Using export options:"
echo "  $LOCAL_EXPORT_OPTIONS"
echo "Export destination:"
echo "  $EXPORT_PATH"
echo "This flow uses the method configured in ExportOptions.local.plist."
echo "If that file is set for App Store Connect upload, Xcode may contact Apple services during export."

xcodebuild \
  -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportOptionsPlist "$LOCAL_EXPORT_OPTIONS" \
  -exportPath "$EXPORT_PATH"

echo
echo "Export finished."
echo "Contents:"
find "$EXPORT_PATH" -maxdepth 1 -type f | sort
