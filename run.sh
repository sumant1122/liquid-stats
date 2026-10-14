#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_PATH="$DIR/build/GlassHUD.app"

if [ ! -d "$APP_PATH" ]; then
    echo "==> Building GlassHUD first..."
    "$DIR/GlassHUD/build.sh"
fi

# If already running, stop old instance
pkill -x GlassHUD 2>/dev/null || true
sleep 0.2

echo "==> Launching GlassHUD floating window..."
open "$APP_PATH"
echo "==> GlassHUD is now floating on your screen! (Menu bar icon added for toggling)"
