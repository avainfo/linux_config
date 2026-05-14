#!/usr/bin/env bash
set -euo pipefail

export DRY_RUN="${DRY_RUN:-0}"

ZSH="$HOME/.oh-my-zsh"
ZSH_CUSTOM="$ZSH/custom"

clone_or_update() {
    local repo_url="$1"
    local target_dir="$2"
    local name="$3"

    if [[ $DRY_RUN -eq 1 ]]; then
        echo " [DRY-RUN] Would clone or update $name in $target_dir"
        return
    fi

    if [[ -d "$target_dir/.git" ]]; then
        echo "$name already exists. Updating..."
        git -C "$target_dir" pull --ff-only >/dev/null || {
            echo " [WARNING] Could not update $name. Keeping existing copy."
            return 0
        }
    elif [[ -d "$target_dir" ]]; then
        echo " [WARNING] $target_dir exists but is not a Git repository. Skipping $name."
    else
        echo "Cloning $name..."
        git clone --depth=1 "$repo_url" "$target_dir"
    fi
}

if [[ $DRY_RUN -eq 1 ]]; then
    echo " [DRY-RUN] Would prepare Oh My Zsh and plugins in $HOME"
fi

if ! command -v git >/dev/null 2>&1; then
    echo " [WARNING] git not found. Skipping Oh My Zsh and plugin setup."
    exit 0
fi

echo ">> Preparing User Shell (Oh My Zsh & Plugins)..."

# Oh My Zsh
clone_or_update \
    "https://github.com/ohmyzsh/ohmyzsh.git" \
    "$ZSH" \
    "Oh My Zsh"

run_mkdir() {
    if [[ $DRY_RUN -eq 1 ]]; then
        echo " [DRY-RUN] Would create directory $1"
    else
        mkdir -p "$1"
    fi
}

run_mkdir "$ZSH_CUSTOM/plugins"
run_mkdir "$ZSH_CUSTOM/themes"

# Powerlevel10k
clone_or_update \
    "https://github.com/romkatv/powerlevel10k.git" \
    "$ZSH_CUSTOM/themes/powerlevel10k" \
    "Powerlevel10k"

# zsh-autosuggestions
clone_or_update \
    "https://github.com/zsh-users/zsh-autosuggestions.git" \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions" \
    "zsh-autosuggestions"

# zsh-syntax-highlighting
clone_or_update \
    "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" \
    "zsh-syntax-highlighting"

# zsh-completions
clone_or_update \
    "https://github.com/zsh-users/zsh-completions.git" \
    "$ZSH_CUSTOM/plugins/zsh-completions" \
    "zsh-completions"

# zsh-history-substring-search
clone_or_update \
    "https://github.com/zsh-users/zsh-history-substring-search.git" \
    "$ZSH_CUSTOM/plugins/zsh-history-substring-search" \
    "zsh-history-substring-search"

echo "User shell prepared."
