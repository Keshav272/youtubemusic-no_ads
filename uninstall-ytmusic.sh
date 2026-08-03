#!/usr/bin/env bash
set -euo pipefail

APP_NAME="YouTube Music"

USER_HOME="$HOME"
APP_DIR="$USER_HOME/.local/share/applications"
ICON_DIR="$USER_HOME/.local/share/icons"

DESKTOP_FILE="$APP_DIR/youtube-music.desktop"
ICON_FILE="$ICON_DIR/youtube-music.png"

banner() {
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "       🗑️ YouTube Music Uninstaller"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
}

step() {
    echo "➜ $1"
}

success() {
    echo "   ✓ $1"
}

error() {
    local code="$1"
    shift

    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "❌ ERROR $code"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$*"
    echo

    exit "$code"
}

banner

step "Checking installation..."

if [ ! -f "$DESKTOP_FILE" ] && [ ! -f "$ICON_FILE" ]; then
    error 20 "YouTube Music does not appear to be installed."
fi

success "Installation found."

step "Removing desktop launcher..."

if [ -f "$DESKTOP_FILE" ]; then
    rm -f "$DESKTOP_FILE" || \
        error 21 "Failed to remove desktop launcher."
fi

success "Desktop launcher removed."

step "Removing application icon..."

if [ -f "$ICON_FILE" ]; then
    rm -f "$ICON_FILE" || \
        error 22 "Failed to remove application icon."
fi

success "Application icon removed."

step "Refreshing desktop database..."

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true
fi

success "Desktop database refreshed."

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "         ✅ Uninstallation Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Application : $APP_NAME"
echo "Launcher    : Removed"
echo "Icon        : Removed"
echo
echo "Thank you for using YouTube Music (No Ads)!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
