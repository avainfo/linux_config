#!/usr/bin/env bash
set -euo pipefail

if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    echo " [DRY-RUN] Would install desktop tools"
    exit 0
fi

install_if_available() {
    for pkg in "$@"; do
        if apt-cache show "$pkg" >/dev/null 2>&1; then
            sudo apt-get install -y "$pkg"
        else
            echo " [WARNING] Package $pkg is not available, skipping."
        fi
    done
}

echo "Installing desktop tools..."
sudo apt-get install -y kitty xclip xsel

install_if_available fonts-powerline wl-clipboard gnome-tweaks
