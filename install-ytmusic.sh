cat << 'EOF' > install-ytmusic.sh
#!/bin/bash

# Exit on error
set -e

# Detect current user home directory dynamically
USER_HOME="$HOME"

echo "Starting YouTube Music setup..."

# Check if Brave Browser is installed
if ! command -v brave-browser &> /dev/null; then
    echo "Brave Browser not found. Installing..."
    sudo dnf install -y dnf-plugins-core
    sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
    sudo dnf install -y brave-browser
else
    echo "Brave Browser is already installed, skipping..."
fi

echo "Creating application directories..."
mkdir -p "$USER_HOME/.local/share/applications" "$USER_HOME/.local/share/icons"

echo "Downloading YouTube Music icon..."
curl -sL https://raw.githubusercontent.com/th-ch/youtube-music/master/assets/generated/icons/png/512x512.png -o "$USER_HOME/.local/share/icons/youtube-music.png"

echo "Creating desktop entry..."
cat << DESKTOPEOF > "$USER_HOME/.local/share/applications/youtube-music-brave.desktop"
[Desktop Entry]
Version=1.0
Name=YouTube Music
Comment=Launch YouTube Music in Brave Web App mode
Exec=brave-browser --app=https://music.youtube.com
Icon=$USER_HOME/.local/share/icons/youtube-music.png
Terminal=false
Type=Application
Categories=Audio;Music;Player;AudioVideo;
DESKTOPEOF

echo "Updating desktop database..."
update-desktop-database "$USER_HOME/.local/share/applications"

echo "Setup complete!"
EOF

chmod +x install-ytmusic.sh
