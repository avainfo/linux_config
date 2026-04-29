#!/usr/bin/env bash
set -euo pipefail

if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    echo " [DRY-RUN] Would install base packages"
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

echo "Updating apt..."
sudo apt-get update -y

echo "Installing base packages..."
sudo apt-get install -y git curl wget unzip zip ca-certificates gnupg lsb-release \
    software-properties-common build-essential pkg-config jq tree htop \
    ripgrep fd-find fzf tmux zsh neovim python3 python3-pip python3-venv rsync

install_if_available btop
