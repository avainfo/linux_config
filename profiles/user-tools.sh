#!/usr/bin/env bash
set -euo pipefail

export DRY_RUN="${DRY_RUN:-0}"

LOCAL_BIN="$HOME/.local/bin"
LOCAL_OPT="$HOME/.local/opt"
FONT_DIR="$HOME/.local/share/fonts"
KITTY_DIR="$HOME/.local/kitty.app"
KITTY_BIN="$KITTY_DIR/bin/kitty"
JETBRAINS_FONT_ZIP_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
KITTY_INSTALLER_URL="https://sw.kovidgoyal.net/kitty/installer.sh"

run_mkdir() {
    if [[ $DRY_RUN -eq 1 ]]; then
        echo " [DRY-RUN] Would create directory $1"
    else
        mkdir -p "$1"
    fi
}

fetch_url() {
    local url="$1"
    local output="$2"

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$output"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$output" "$url"
    else
        echo " [WARNING] curl or wget is required to download $url"
        return 1
    fi
}

install_jetbrains_nerd_font() {
    echo ">> Preparing JetBrainsMono Nerd Font..."

    if fc-match "JetBrainsMono Nerd Font" >/dev/null 2>&1 && fc-match "JetBrainsMono Nerd Font" | grep -qi "JetBrains"; then
        echo "JetBrainsMono Nerd Font already available."
        return
    fi

    if [[ $DRY_RUN -eq 1 ]]; then
        echo " [DRY-RUN] Would download and install JetBrainsMono Nerd Font into $FONT_DIR"
        return
    fi

    if ! command -v unzip >/dev/null 2>&1; then
        echo " [WARNING] unzip is required to install JetBrainsMono Nerd Font."
        return
    fi

    local tmp_dir
    tmp_dir="$(mktemp -d)"
    trap 'rm -rf "$tmp_dir"' RETURN

    fetch_url "$JETBRAINS_FONT_ZIP_URL" "$tmp_dir/JetBrainsMono.zip" || return 0
    mkdir -p "$FONT_DIR/JetBrainsMonoNerdFont"
    unzip -oq "$tmp_dir/JetBrainsMono.zip" -d "$FONT_DIR/JetBrainsMonoNerdFont"

    if command -v fc-cache >/dev/null 2>&1; then
        fc-cache -f "$FONT_DIR" >/dev/null || true
    fi

    echo "JetBrainsMono Nerd Font installed in $FONT_DIR/JetBrainsMonoNerdFont"
}

install_kitty_user() {
    echo ">> Preparing Kitty terminal..."

    if command -v kitty >/dev/null 2>&1; then
        echo "Kitty already available in PATH."
        return
    fi

    if [[ -x "$KITTY_BIN" ]]; then
        echo "Kitty already installed at $KITTY_BIN"
        return
    fi

    if [[ $DRY_RUN -eq 1 ]]; then
        echo " [DRY-RUN] Would install Kitty into $KITTY_DIR without sudo"
        return
    fi

    run_mkdir "$LOCAL_OPT"
    fetch_url "$KITTY_INSTALLER_URL" "$LOCAL_OPT/kitty-installer.sh" || return 0
    sh "$LOCAL_OPT/kitty-installer.sh" launch=n dest="$HOME/.local"

    if [[ -x "$KITTY_BIN" ]]; then
        mkdir -p "$LOCAL_BIN"
        ln -snf "$KITTY_BIN" "$LOCAL_BIN/kitty"
        echo "Kitty installed and linked to $LOCAL_BIN/kitty"
    else
        echo " [WARNING] Kitty installer completed but $KITTY_BIN was not found."
    fi
}

run_mkdir "$LOCAL_BIN"
run_mkdir "$LOCAL_OPT"
run_mkdir "$FONT_DIR"

install_jetbrains_nerd_font
install_kitty_user

echo "User tools prepared."
