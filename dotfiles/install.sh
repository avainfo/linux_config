#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"

link() { mkdir -p "$(dirname "$2")"; ln -snf "$1" "$2"; echo "→ $2"; }

# Zsh & p10k
link "$ROOT/zsh/.zshrc"              "$HOME/.zshrc"
[ -f "$ROOT/zsh/.p10k.zsh" ] && link "$ROOT/zsh/.p10k.zsh" "$HOME/.p10k.zsh"

# Tmux
link "$ROOT/tmux/.tmux.conf"         "$HOME/.tmux.conf"

# Vim
link "$ROOT/vim/.vimrc"              "$HOME/.vimrc"

# Git
link "$ROOT/git/.gitconfig"          "$HOME/.gitconfig"

# Kitty
link "$ROOT/kitty/kitty.conf"        "$HOME/.config/kitty/kitty.conf"

# Editor & Clang & GDB
link "$ROOT/debug/.gdbinit"          "$HOME/.gdbinit"

# bin/
mkdir -p "$HOME/bin"
rsync -a --delete "$ROOT/bin/" "$HOME/bin/" 2>/dev/null || true

echo "Done. Reload your shell: exec zsh"

