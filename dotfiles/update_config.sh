#!/usr/bin/env bash
set -euo pipefail

# Define the root of the dotfiles repo
ROOT="$(cd "$(dirname "$0")" && pwd)"
echo "📂 Top Update Script: Backing up system config to $ROOT"

# Function to update single files
# Usage: update_file <SystemPath> <RepoPath>
update_file() {
    local system_path="$1"
    local repo_path="$2"

    if [ ! -e "$system_path" ]; then
        echo "⚠️  Skipping $system_path (not found)"
        return
    fi
    
    # Check if it's a symlink pointing to the repo
    if [ -L "$system_path" ]; then
        local target
        target=$(readlink -f "$system_path")
        local repo_abs
        repo_abs=$(readlink -f "$repo_path")
        
        if [ "$target" == "$repo_abs" ]; then
            echo "✅ $system_path is already linked to repo (No action needed)"
            return
        fi
    fi

    # If it's a regular file or not linked to repo, update repo file
    echo "🔄 Updating $repo_path from $system_path..."
    mkdir -p "$(dirname "$repo_path")"
    cp "$system_path" "$repo_path"
}

# Function to update directories using rsync
# Usage: update_dir <SystemPath> <RepoPath> [Delete=true]
update_dir() {
    local system_path="$1"
    local repo_path="$2"
    local delete="${3:-true}" # Default to true (mirror)

    if [ ! -d "$system_path" ]; then
        echo "⚠️  Skipping directory $system_path (not found)"
        return
    fi
    
    local rsync_opts="-av"
    if [ "$delete" == "true" ]; then
        rsync_opts="$rsync_opts --delete"
        echo "📂 Syncing (Mirror) $system_path -> $repo_path"
    else
        echo "📂 Syncing (Copy) $system_path -> $repo_path"
    fi

    mkdir -p "$repo_path"
    # Sync contents
    rsync $rsync_opts --exclude '.git' --exclude '__pycache__' "$system_path/" "$repo_path/"
}

# --- Files ---

# Zsh
update_file "$HOME/.zshrc" "$ROOT/zsh/.zshrc"
update_file "$HOME/.p10k.zsh" "$ROOT/zsh/.p10k.zsh"

# Tmux
update_file "$HOME/.tmux.conf" "$ROOT/tmux/.tmux.conf"

# Vim
update_file "$HOME/.vimrc" "$ROOT/vim/.vimrc"

# Git
update_file "$HOME/.gitconfig" "$ROOT/git/.gitconfig"

# GDB
update_file "$HOME/.gdbinit" "$ROOT/debug/.gdbinit"

# Kitty
update_file "$HOME/.config/kitty/kitty.conf" "$ROOT/kitty/kitty.conf"

# --- Directories ---

# Neovim (Mirror)
# Exclude lazy-lock or cache if necessary, but usually config includes init.lua and lua/
update_dir "$HOME/.config/nvim" "$ROOT/nvim" "true"

# Bin scripts (Copy only, preserve repo-only scripts)
update_dir "$HOME/bin" "$ROOT/bin" "false"

# Plymouth (System Theme)

# This might require sudo to read if permissions are strict, but usually readable.
PLYMOUTH_THEME="/usr/share/plymouth/themes/ava-info"
if [ -d "$PLYMOUTH_THEME" ]; then
    echo "🎨 Backing up Plymouth theme..."
    mkdir -p "$ROOT/plymouth"
    # We don't verify checksums, just copy. 
    # Use -r for cp or rsync. Rsync is better.
    rsync -av --delete "$PLYMOUTH_THEME/" "$ROOT/plymouth/"
else
    echo "⚠️  Plymouth theme not found at $PLYMOUTH_THEME"
fi

echo "🎉 Update Complete! Check 'git status' to see changes."
