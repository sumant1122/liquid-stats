#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SDK_PATH="/Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk"
if [ ! -d "$SDK_PATH" ]; then
    SDK_PATH="$(xcrun --show-sdk-path 2>/dev/null || echo '')"
fi

CACHE_DIR="/tmp/clang-cache"
mkdir -p "$CACHE_DIR"

OUTPUT_DIR="$DIR/../build"
APP_DIR="$OUTPUT_DIR/GlassHUD.app"
MACOS_DIR="$APP_DIR/Contents/MacOS"
RESOURCES_DIR="$APP_DIR/Contents/Resources"

mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"
cp "$DIR/Info.plist" "$APP_DIR/Contents/Info.plist"

echo "==> Compiling GlassHUD..."
SOURCES=()
while IFS= read -r -d '' file; do
    SOURCES+=("$file")
done < <(find "$DIR/Sources" -name "*.swift" -print0)

swiftc \
    -sdk "$SDK_PATH" \
    -module-cache-path "$CACHE_DIR" \
    -framework Cocoa \
    -framework SwiftUI \
    -framework IOKit \
    -framework CoreWLAN \
    -O \
    -o "$MACOS_DIR/GlassHUD" \
    "${SOURCES[@]}"

echo "==> Ad-hoc signing GlassHUD.app..."
codesign --force --deep --sign - "$APP_DIR" 2>/dev/null || true

echo "==> Build complete: $APP_DIR"
