#!/usr/bin/env bash
set -euo pipefail

export DRY_RUN="${DRY_RUN:-0}"

ZSH="$HOME/.oh-my-zsh"
ZSH_CUSTOM="$ZSH/custom"

if [[ $DRY_RUN -eq 1 ]]; then
    echo " [DRY-RUN] Would prepare Oh My Zsh and plugins in $HOME"
    exit 0
fi

if ! command -v git >/dev/null 2>&1; then
    echo " [WARNING] git not found. Skipping Oh My Zsh and plugin setup."
    exit 0
fi

echo ">> Preparing User Shell (Oh My Zsh & Plugins)..."

# Oh My Zsh
if [[ ! -d "$ZSH" ]]; then
    echo "Cloning Oh My Zsh..."
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$ZSH"
else
    echo "Oh My Zsh already exists at $ZSH"
fi

mkdir -p "$ZSH_CUSTOM/plugins"
mkdir -p "$ZSH_CUSTOM/themes"

# Powerlevel10k
if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
    echo "Cloning Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
else
    echo "Powerlevel10k already exists."
fi

# zsh-autosuggestions
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    echo "Cloning zsh-autosuggestions..."
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo "zsh-autosuggestions already exists."
fi

# zsh-syntax-highlighting
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    echo "Cloning zsh-syntax-highlighting..."
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    echo "zsh-syntax-highlighting already exists."
fi

echo "User shell prepared."
