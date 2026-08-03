#!/usr/bin/env bash
set -euo pipefail

APP_NAME="YouTube Music"
APP_URL="https://music.youtube.com"
ICON_URL="https://raw.githubusercontent.com/th-ch/youtube-music/master/assets/generated/icons/png/512x512.png"

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

echo "==> Installing $APP_NAME..."

mkdir -p "$APP_DIR" "$ICON_DIR" || error 10 "Failed to create application directories."

OS=""
PKG=""

if command -v apt >/dev/null 2>&1; then
    OS="Debian/Ubuntu"
    PKG="apt"
elif command -v dnf >/dev/null 2>&1; then
    OS="Fedora"
    PKG="dnf"
elif command -v pacman >/dev/null 2>&1; then
    OS="Arch"
    PKG="pacman"
elif command -v zypper >/dev/null 2>&1; then
    OS="openSUSE"
    PKG="zypper"
else
    error 30 "Unsupported Linux distribution."
fi

echo "Detected: $OS"

if ! command -v brave-browser >/dev/null 2>&1; then
    echo "Installing Brave Browser..."

    case "$PKG" in
        apt)
            sudo apt update
            sudo apt install -y curl gnupg
            sudo mkdir -p /usr/share/keyrings
            curl -fsSLo /tmp/brave-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg || error 12 "Failed to download Brave signing key."
            sudo mv /tmp/brave-keyring.gpg /usr/share/keyrings/brave-browser-archive-keyring.gpg

            echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | \
            sudo tee /etc/apt/sources.list.d/brave-browser-release.list >/dev/null

            sudo apt update
            sudo apt install -y brave-browser || error 12 "Failed to install Brave Browser."
            ;;
        dnf)
            sudo dnf install -y dnf-plugins-core
            sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
            sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
            sudo dnf install -y brave-browser || error 12 "Failed to install Brave Browser."
            ;;
        pacman)
            if command -v yay >/dev/null 2>&1; then
                yay -S --noconfirm brave-bin || error 12 "Failed to install Brave Browser."
            elif command -v paru >/dev/null 2>&1; then
                paru -S --noconfirm brave-bin || error 12 "Failed to install Brave Browser."
            else
                sudo pacman -Sy --noconfirm brave || error 12 "Failed to install Brave Browser."
            fi
            ;;
        zypper)
            sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
            sudo zypper addrepo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
            sudo zypper --gpg-auto-import-keys refresh
            sudo zypper install -y brave-browser || error 12 "Failed to install Brave Browser."
            ;;
    esac
fi

echo "Downloading icon..."
curl -fsSL "$ICON_URL" -o "$ICON_FILE" || error 11 "Failed to download the YouTube Music icon."

echo "Creating launcher..."

cat > "$DESKTOP_FILE" <<EOF || error 13 "Failed to create desktop launcher."
[Desktop Entry]
Version=1.0
Type=Application
Name=YouTube Music
Comment=Listen to YouTube Music
Exec=brave-browser --app=https://music.youtube.com
Icon=$ICON_FILE
Terminal=false
StartupNotify=true
StartupWMClass=music.youtube.com
Categories=Audio;Music;AudioVideo;
Keywords=Music;YouTube;Audio;
EOF

chmod +x "$DESKTOP_FILE" || error 14 "Failed to set launcher permissions."

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true
fi

echo
echo "=================================="
echo "Installation Complete!"
echo "Detected OS : $OS"
echo "Browser     : Brave"
echo "Launcher    : $DESKTOP_FILE"
echo "=================================="
