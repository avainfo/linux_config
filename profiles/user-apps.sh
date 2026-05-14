#!/usr/bin/env bash
set -euo pipefail

export DRY_RUN="${DRY_RUN:-0}"

LOCAL_BIN="$HOME/.local/bin"
KITTY_APP_DIR="$HOME/.local/kitty.app"
FONT_DIR="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
NERD_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"

log_skip() {
    echo " [SKIP] $1"
}

log_warn() {
    echo " [WARNING] $1"
}

run_or_preview() {
    if [[ $DRY_RUN -eq 1 ]]; then
        echo " [DRY-RUN] $*"
    else
        "$@"
    fi
}

install_kitty_user() {
    echo ">> Preparing Kitty terminal for user install..."

    if command -v kitty >/dev/null 2>&1; then
        log_skip "kitty is already available in PATH: $(command -v kitty)"
        return
    fi

    if [[ -x "$KITTY_APP_DIR/bin/kitty" ]]; then
        echo "Kitty already installed at $KITTY_APP_DIR"
    else
        if ! command -v curl >/dev/null 2>&1; then
            log_warn "curl not found. Cannot install Kitty without sudo."
            return
        fi

        if [[ $DRY_RUN -eq 1 ]]; then
            echo " [DRY-RUN] Would install Kitty into $KITTY_APP_DIR"
        else
            curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n
        fi
    fi

    if [[ $DRY_RUN -eq 0 && -x "$KITTY_APP_DIR/bin/kitty" ]]; then
        mkdir -p "$LOCAL_BIN"
        ln -snf "$KITTY_APP_DIR/bin/kitty" "$LOCAL_BIN/kitty"
        echo "Linked $LOCAL_BIN/kitty -> $KITTY_APP_DIR/bin/kitty"
    elif [[ $DRY_RUN -eq 1 ]]; then
        echo " [DRY-RUN] Would link $LOCAL_BIN/kitty -> $KITTY_APP_DIR/bin/kitty"
    fi
}

install_jetbrains_mono_nerd_font() {
    echo ">> Preparing JetBrains Mono Nerd Font..."

    if [[ -d "$FONT_DIR" ]] && find "$FONT_DIR" -type f \( -name '*.ttf' -o -name '*.otf' \) | grep -q .; then
        log_skip "JetBrains Mono Nerd Font already installed in $FONT_DIR"
        return
    fi

    if ! command -v curl >/dev/null 2>&1; then
        log_warn "curl not found. Cannot download JetBrains Mono Nerd Font without sudo."
        return
    fi

    if ! command -v tar >/dev/null 2>&1; then
        log_warn "tar not found. Cannot extract JetBrains Mono Nerd Font."
        return
    fi

    if [[ $DRY_RUN -eq 1 ]]; then
        echo " [DRY-RUN] Would download JetBrains Mono Nerd Font from $NERD_FONT_URL"
        echo " [DRY-RUN] Would install fonts into $FONT_DIR"
        return
    fi

    local tmp_dir
    tmp_dir="$(mktemp -d)"
    trap 'rm -rf "$tmp_dir"' RETURN

    mkdir -p "$FONT_DIR"
    curl -fL "$NERD_FONT_URL" -o "$tmp_dir/JetBrainsMono.tar.xz"
    tar -xJf "$tmp_dir/JetBrainsMono.tar.xz" -C "$FONT_DIR"

    if command -v fc-cache >/dev/null 2>&1; then
        fc-cache -f "$FONT_DIR" >/dev/null || true
        echo "Font cache refreshed."
    else
        log_warn "fc-cache not found. You may need to refresh the font cache manually."
    fi

    echo "JetBrains Mono Nerd Font installed in $FONT_DIR"
}

mkdir -p "$LOCAL_BIN"

install_kitty_user
install_jetbrains_mono_nerd_font

echo "User apps prepared."
