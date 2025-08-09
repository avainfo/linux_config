#!/usr/bin/env bash
set -euo pipefail

PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"

mkdir -p "$PLUGINS_DIR"

echo "Installing zsh-autosuggestions..."
if [ ! -d "$PLUGINS_DIR/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGINS_DIR/zsh-autosuggestions"
else
    echo "zsh-autosuggestions already installed, updating..."
    git -C "$PLUGINS_DIR/zsh-autosuggestions" pull --ff-only
fi

echo "Installing zsh-syntax-highlighting..."
if [ ! -d "$PLUGINS_DIR/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$PLUGINS_DIR/zsh-syntax-highlighting"
else
    echo "zsh-syntax-highlighting already installed, updating..."
    git -C "$PLUGINS_DIR/zsh-syntax-highlighting" pull --ff-only
fi

echo "Done!"
echo "➡️  Add the plugins to your ~/.zshrc:"
echo "plugins=(git zsh-autosuggestions zsh-syntax-highlighting)"
