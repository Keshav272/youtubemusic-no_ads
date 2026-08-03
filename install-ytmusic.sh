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

banner() {
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "        🎵 YouTube Music Installer"
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

mkdir -p "$APP_DIR" "$ICON_DIR" || error 10 "Failed to create application directories."

step "Detecting operating system..."

if [ ! -f /etc/os-release ]; then
    error 30 "Unable to detect Linux distribution."
fi

. /etc/os-release

case "$ID" in
    ubuntu|debian|linuxmint|pop)
        OS="Debian/Ubuntu"
        PKG="apt"
        ;;
    fedora)
        OS="Fedora"
        PKG="dnf"
        ;;
    arch|manjaro|endeavouros)
        OS="Arch Linux"
        PKG="pacman"
        ;;
    opensuse*|sles)
        OS="openSUSE"
        PKG="zypper"
        ;;
    *)
        error 30 "Unsupported Linux distribution: $ID"
        ;;
esac

success "$OS detected."

step "Checking Brave Browser..."
if command -v brave-browser >/dev/null 2>&1; then
    success "Brave Browser is already installed."
else
    step "Installing Brave Browser..."

    case "$PKG" in
        apt)
            sudo apt update || error 12 "Failed to update package lists."

            sudo apt install -y curl gnupg || \
                error 12 "Failed to install required dependencies."

            sudo mkdir -p /usr/share/keyrings

            curl -fsSL \
                https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg \
                | sudo gpg --dearmor -o /usr/share/keyrings/brave-browser-archive-keyring.gpg \
                || error 12 "Failed to download Brave signing key."

            echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
                | sudo tee /etc/apt/sources.list.d/brave-browser-release.list >/dev/null

            sudo apt update || error 12 "Failed to refresh repositories."

            sudo apt install -y brave-browser || \
                error 12 "Failed to install Brave Browser."
            ;;

        dnf)
            sudo dnf install -y dnf-plugins-core || \
                error 12 "Failed to install dnf plugins."

            sudo dnf config-manager --add-repo \
                https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo || \
                error 12 "Failed to add Brave repository."

            sudo rpm --import \
                https://brave-browser-rpm-release.s3.brave.com/brave-core.asc || \
                error 12 "Failed to import Brave signing key."

            sudo dnf install -y brave-browser || \
                error 12 "Failed to install Brave Browser."
            ;;

pacman)
    if command -v yay >/dev/null 2>&1; then
        yay -S --noconfirm brave-bin || \
            error 12 "Failed to install Brave Browser."
    elif command -v paru >/dev/null 2>&1; then
        paru -S --noconfirm brave-bin || \
            error 12 "Failed to install Brave Browser."
    else
        sudo pacman -Sy --noconfirm brave || \
            error 12 "Failed to install Brave Browser."
    fi
    ;;
        zypper)
            sudo rpm --import \
                https://brave-browser-rpm-release.s3.brave.com/brave-core.asc || \
                error 12 "Failed to import Brave signing key."

            sudo zypper addrepo \
                https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo || \
                error 12 "Failed to add Brave repository."

            sudo zypper --gpg-auto-import-keys refresh || \
                error 12 "Failed to refresh repositories."

            sudo zypper install -y brave-browser || \
                error 12 "Failed to install Brave Browser."
            ;;
    esac

    success "Brave Browser installed."
fi

step "Downloading YouTube Music icon..."

curl -fsSL "$ICON_URL" -o "$ICON_FILE" || \
    error 11 "Failed to download the YouTube Music icon."

success "Icon downloaded."

step "Creating desktop launcher..."

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=YouTube Music
GenericName=Music Player
Comment=Listen to YouTube Music without ads using Brave Browser
Exec=brave-browser --new-window --app=https://music.youtube.com
Icon=$ICON_FILE
Terminal=false
StartupNotify=true
StartupWMClass=Brave-browser
Categories=Audio;Music;AudioVideo;
Keywords=YouTube;Music;Audio;Streaming;
EOF

chmod +x "$DESKTOP_FILE" || \
    error 14 "Failed to make launcher executable."

success "Desktop launcher created."

step "Refreshing desktop database..."

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true
fi

success "Desktop database refreshed."
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "           ✅ Installation Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Application : $APP_NAME"
echo "Detected OS : $OS"
echo "Browser     : Brave Browser"
echo "Launcher    : $DESKTOP_FILE"
echo "Version     : 1.0"

echo
echo "You can now launch YouTube Music from your Applications Menu."
echo
echo "Enjoy your ad-free music! 🎵"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
