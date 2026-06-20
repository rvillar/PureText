#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="PureText"
BUILD_ROOT="$ROOT_DIR/.artifacts"
APP_BUNDLE="$BUILD_ROOT/$APP_NAME.app"
ASSET_CATALOG="$BUILD_ROOT/Assets.xcassets"
APPICON_SET="$ASSET_CATALOG/AppIcon.appiconset"
ICON_SOURCE="$ROOT_DIR/Assets/PureTextIcon.png"
BIN_PATH="$BUILD_ROOT/$APP_NAME"

rm -rf \
	"$APP_BUNDLE" \
	"$ASSET_CATALOG"
mkdir -p "$BUILD_ROOT" "$ROOT_DIR/.cache/clang" "$APP_BUNDLE/Contents/MacOS" "$APP_BUNDLE/Contents/Resources" "$APPICON_SET"

CLANG_MODULE_CACHE_PATH="$ROOT_DIR/.cache/clang" \
swiftc "$ROOT_DIR"/Sources/PureText/*.swift \
	-framework AppKit \
	-framework UniformTypeIdentifiers \
	-o "$BIN_PATH"

create_icon() {
	local size="$1"
	local filename="$2"
	sips -z "$size" "$size" "$ICON_SOURCE" --out "$APPICON_SET/$filename" >/dev/null
}

create_icon 16 icon_16x16.png
create_icon 32 icon_16x16@2x.png
create_icon 32 icon_32x32.png
create_icon 64 icon_32x32@2x.png
create_icon 128 icon_128x128.png
create_icon 256 icon_128x128@2x.png
create_icon 256 icon_256x256.png
create_icon 512 icon_256x256@2x.png
create_icon 512 icon_512x512.png
create_icon 1024 icon_512x512@2x.png

cat > "$APPICON_SET/Contents.json" <<'JSON'
{
  "images" : [
    { "filename" : "icon_16x16.png", "idiom" : "mac", "scale" : "1x", "size" : "16x16" },
    { "filename" : "icon_16x16@2x.png", "idiom" : "mac", "scale" : "2x", "size" : "16x16" },
    { "filename" : "icon_32x32.png", "idiom" : "mac", "scale" : "1x", "size" : "32x32" },
    { "filename" : "icon_32x32@2x.png", "idiom" : "mac", "scale" : "2x", "size" : "32x32" },
    { "filename" : "icon_128x128.png", "idiom" : "mac", "scale" : "1x", "size" : "128x128" },
    { "filename" : "icon_128x128@2x.png", "idiom" : "mac", "scale" : "2x", "size" : "128x128" },
    { "filename" : "icon_256x256.png", "idiom" : "mac", "scale" : "1x", "size" : "256x256" },
    { "filename" : "icon_256x256@2x.png", "idiom" : "mac", "scale" : "2x", "size" : "256x256" },
    { "filename" : "icon_512x512.png", "idiom" : "mac", "scale" : "1x", "size" : "512x512" },
    { "filename" : "icon_512x512@2x.png", "idiom" : "mac", "scale" : "2x", "size" : "512x512" }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
JSON

cp "$BIN_PATH" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
chmod +x "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
cp "$ROOT_DIR/App/Info.plist" "$APP_BUNDLE/Contents/Info.plist"

xcrun actool \
	--compile "$APP_BUNDLE/Contents/Resources" \
	--platform macosx \
	--minimum-deployment-target 13.0 \
	--app-icon AppIcon \
	--output-partial-info-plist "$BUILD_ROOT/actool-info.plist" \
	"$ASSET_CATALOG" >/dev/null

echo "App bundle created at: $APP_BUNDLE"
