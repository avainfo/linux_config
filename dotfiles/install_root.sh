#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
ROOT_HOME="/root"
BACKUP_DIR="$ROOT_HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

OH_MY_ZSH_DIR="$ROOT_HOME/.oh-my-zsh"
ZSH_CUSTOM_DIR="$OH_MY_ZSH_DIR/custom"

INSTALL_GIT_CONFIG="${INSTALL_GIT_CONFIG:-0}"
SET_ROOT_SHELL="${SET_ROOT_SHELL:-0}"

if [ "$EUID" -ne 0 ]; then
	echo "Please run this script with sudo:"
	echo "  sudo ./install_root.sh"
	exit 1
fi

command_exists() {
	command -v "$1" >/dev/null 2>&1
}

backup_existing() {
	local target="$1"

	if [ -e "$target" ] && [ ! -L "$target" ]; then
		mkdir -p "$BACKUP_DIR"
		mv "$target" "$BACKUP_DIR/"
		echo "Backed up $target -> $BACKUP_DIR/"
	fi
}

link() {
	local source="$1"
	local target="$2"

	if [ ! -e "$source" ]; then
		echo "Skipping missing source: $source"
		return 0
	fi

	mkdir -p "$(dirname "$target")"
	backup_existing "$target"

	cp -a "$source" "$target"
	echo "Copied $source -> $target"
}

clone_or_update() {
	local repo_url="$1"
	local target_dir="$2"

	if [ -d "$target_dir/.git" ]; then
		echo "Updating $target_dir"
		git -C "$target_dir" pull --ff-only >/dev/null || {
			echo "Warning: could not update $target_dir"
			return 0
		}
	else
		echo "Cloning $repo_url -> $target_dir"
		git clone --depth=1 "$repo_url" "$target_dir"
	fi
}

install_root_oh_my_zsh() {
	if ! command_exists git; then
		echo "git is required to install Oh My Zsh plugins."
		echo "Install it first, then re-run this script."
		return 1
	fi

	clone_or_update \
		"https://github.com/ohmyzsh/ohmyzsh.git" \
		"$OH_MY_ZSH_DIR"

	mkdir -p "$ZSH_CUSTOM_DIR/plugins" "$ZSH_CUSTOM_DIR/themes"

	clone_or_update \
		"https://github.com/zsh-users/zsh-autosuggestions.git" \
		"$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"

	clone_or_update \
		"https://github.com/zsh-users/zsh-syntax-highlighting.git" \
		"$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"

	clone_or_update \
		"https://github.com/romkatv/powerlevel10k.git" \
		"$ZSH_CUSTOM_DIR/themes/powerlevel10k"
}

maybe_set_root_shell() {
	if [ "$SET_ROOT_SHELL" != "1" ]; then
		return 0
	fi

	if ! command_exists zsh; then
		echo "zsh is not installed. Skipping root shell change."
		return 0
	fi

	local zsh_path
	zsh_path="$(command -v zsh)"
	chsh -s "$zsh_path" root
	echo "Root shell set to $zsh_path"
}

echo "Installing root dotfiles..."

install_root_oh_my_zsh

# Shell
link "$ROOT/zsh/.zshrc" "$ROOT_HOME/.zshrc"
link "$ROOT/zsh/.p10k.zsh" "$ROOT_HOME/.p10k.zsh"

# Tmux
link "$ROOT/tmux/.tmux.conf" "$ROOT_HOME/.tmux.conf"

# Vim
link "$ROOT/vim/.vimrc" "$ROOT_HOME/.vimrc"

# GDB
link "$ROOT/debug/.gdbinit" "$ROOT_HOME/.gdbinit"

# Neovim
link "$ROOT/nvim" "$ROOT_HOME/.config/nvim"

# Git config is optional for root to avoid accidental commits as root
if [ "$INSTALL_GIT_CONFIG" = "1" ]; then
	link "$ROOT/git/.gitconfig" "$ROOT_HOME/.gitconfig"
else
	echo "Skipping root .gitconfig. Use INSTALL_GIT_CONFIG=1 to enable it."
fi

maybe_set_root_shell

echo "Root dotfiles installed."

if [ -d "$BACKUP_DIR" ]; then
	echo "Backups were stored in: $BACKUP_DIR"
fi
