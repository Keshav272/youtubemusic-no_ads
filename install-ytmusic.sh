#!/usr/bin/env bash
set -e

USER_HOME="$HOME"

echo "Starting YouTube Music setup..."

# Detect package manager and install Brave if missing
if ! command -v brave-browser >/dev/null 2>&1; then
    echo "Installing Brave Browser..."

    if command -v apt >/dev/null 2>&1; then
        sudo apt update
        sudo apt install -y curl gnupg
        sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list >/dev/null
        sudo apt update
        sudo apt install -y brave-browser

    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y dnf-plugins-core
        sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
        sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
        sudo dnf install -y brave-browser

    else
        echo "Unsupported Linux distribution."
        exit 1
    fi
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

chmod +x "$USER_HOME/.local/share/applications/youtube-music.desktop"

echo "Installation complete!"
echo "You can now launch YouTube Music from your applications menu."
