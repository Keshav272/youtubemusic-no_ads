#!/usr/bin/env bash
set -e

USER_HOME="$HOME"

echo "Starting YouTube Music setup..."

if ! command -v brave-browser >/dev/null; then
    echo "Installing Brave Browser..."
    sudo dnf install -y dnf-plugins-core
    sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
    sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
    sudo dnf install -y brave-browser
fi

mkdir -p "$USER_HOME/.local/share/applications"
mkdir -p "$USER_HOME/.local/share/icons"

curl -fLo "$USER_HOME/.local/share/icons/youtube-music.png" \
https://raw.githubusercontent.com/th-ch/youtube-music/master/assets/generated/icons/png/512x512.png

cat > "$USER_HOME/.local/share/applications/youtube-music.desktop" <<EOF
[Desktop Entry]
Version=1.0
Name=YouTube Music
Comment=Launch YouTube Music
Exec=brave-browser --app=https://music.youtube.com
Icon=$USER_HOME/.local/share/icons/youtube-music.png
Terminal=false
Type=Application
Categories=Audio;Music;AudioVideo;
EOF

echo "Done!"
