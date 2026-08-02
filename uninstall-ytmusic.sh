cat << 'EOF' > uninstall-ytmusic.sh
#!/bin/bash

# Exit on error
set -e

USER_HOME="$HOME"

echo "Removing YouTube Music desktop app shortcut and icon..."

rm -f "$USER_HOME/.local/share/applications/youtube-music-brave.desktop"
rm -f "$USER_HOME/.local/share/icons/youtube-music.png"

echo "Updating desktop database..."
update-desktop-database "$USER_HOME/.local/share/applications"

echo "Uninstallation complete!"
EOF

chmod +x uninstall-ytmusic.sh
