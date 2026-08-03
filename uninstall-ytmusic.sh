#!/usr/bin/env bash
set -euo pipefail

USER_HOME="$HOME"

APP_DIR="$USER_HOME/.local/share/applications"
ICON_DIR="$USER_HOME/.local/share/icons"

DESKTOP_FILE="$APP_DIR/youtube-music.desktop"
ICON_FILE="$ICON_DIR/youtube-music.png"

error() {
    code="$1"
    shift
    echo
    echo "[ERROR $code] $*"
    exit "$code"
}

echo "Removing YouTube Music..."

rm -f "$DESKTOP_FILE" || error 20 "Failed to remove launcher."
rm -f "$ICON_FILE" || error 21 "Failed to remove icon."

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true
fi

echo
echo "=================================="
echo "Uninstallation Complete!"
echo "Launcher removed successfully."
echo "=================================="
