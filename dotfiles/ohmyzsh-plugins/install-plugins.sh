#!/usr/bin/env bash
set -euo pipefail

PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"
THEMES_DIR="$HOME/.oh-my-zsh/custom/themes"

mkdir -p "$PLUGINS_DIR"
mkdir -p "$THEMES_DIR"

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

echo "Installing Powerlevel10k..."
if [ ! -d "$THEMES_DIR/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$THEMES_DIR/powerlevel10k"
else
    echo "Powerlevel10k already installed, updating..."
    git -C "$THEMES_DIR/powerlevel10k" pull --ff-only
fi

echo "Done!"
echo "➡️  Add the plugins to your ~/.zshrc:"
echo "plugins=(git zsh-autosuggestions zsh-syntax-highlighting)"
echo "➡️  Set the theme in your ~/.zshrc:"
echo 'ZSH_THEME="powerlevel10k/powerlevel10k"'
