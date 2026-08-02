#!/usr/bin/env bash
set -e

USER_HOME="$HOME"

echo "Removing YouTube Music..."

rm -f "$USER_HOME/.local/share/applications/youtube-music.desktop"
rm -f "$USER_HOME/.local/share/icons/youtube-music.png"

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$USER_HOME/.local/share/applications" >/dev/null 2>&1 || true
fi

echo "Uninstallation complete!"
