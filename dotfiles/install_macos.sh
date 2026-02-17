#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "🍎 Setting up dotfiles for macOS..."

link() {
    local source="$1"
    local target="$2"
    
    mkdir -p "$(dirname "$target")"
    ln -snf "$source" "$target"
    echo "🔗 Linked $target -> $source"
}

# Zsh & p10k
link "$ROOT/zsh/.zshrc"              "$HOME/.zshrc"
echo "ℹ️  Remember to install fonts for p10k if needed."
[ -f "$ROOT/zsh/.p10k.zsh" ] && link "$ROOT/zsh/.p10k.zsh" "$HOME/.p10k.zsh"

# Tmux
link "$ROOT/tmux/.tmux.conf"         "$HOME/.tmux.conf"

# Vim
link "$ROOT/vim/.vimrc"              "$HOME/.vimrc"

# Git
link "$ROOT/git/.gitconfig"          "$HOME/.gitconfig"

# Kitty
# macOS config is usually at ~/.config/kitty/kitty.conf too (cross-platform)
link "$ROOT/kitty/kitty.conf"        "$HOME/.config/kitty/kitty.conf"

# GDB (if installed via brew, usually needs configuration)
link "$ROOT/debug/.gdbinit"          "$HOME/.gdbinit"

# Neovim
# Using symlink for the whole directory is cleaner if you want direct reflection
# Alternatively, we could rsync if you prefer copies
if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
    echo "⚠️  Backing up existing ~/.config/nvim to ~/.config/nvim.bak"
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
fi
link "$ROOT/nvim"                    "$HOME/.config/nvim"

# bin/
# Using rsync to merge scripts into ~/bin
echo "📂 Installing scripts to ~/bin..."
mkdir -p "$HOME/bin"
rsync -av --delete "$ROOT/bin/" "$HOME/bin/" 2>/dev/null || true

echo "✅ macOS setup complete! Restart your shell."
