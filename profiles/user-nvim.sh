#!/usr/bin/env bash
set -euo pipefail

export DRY_RUN="${DRY_RUN:-0}"

NVIM_CONFIG_DIR="$HOME/.config/nvim"

if [[ $DRY_RUN -eq 1 ]]; then
    echo " [DRY-RUN] Would bootstrap Neovim plugins with lazy.nvim"
    exit 0
fi

if ! command -v nvim >/dev/null 2>&1; then
    echo " [WARNING] nvim not found. Skipping Neovim plugin installation."
    exit 0
fi

if ! command -v git >/dev/null 2>&1; then
    echo " [WARNING] git not found. lazy.nvim cannot download plugins."
    exit 0
fi

if [[ ! -f "$NVIM_CONFIG_DIR/init.lua" ]]; then
    echo " [WARNING] Neovim config not found at $NVIM_CONFIG_DIR/init.lua. Skipping plugin installation."
    exit 0
fi

echo ">> Bootstrapping Neovim plugins..."

# Opening Neovim headlessly triggers lua/config/lazy.lua, which bootstraps lazy.nvim.
# Lazy sync then installs or updates all plugin specs declared under lua/plugins/.
if nvim --headless "+Lazy! sync" +qa; then
    echo "Neovim plugins installed."
else
    echo " [WARNING] Neovim plugin installation failed. Open nvim and run :Lazy sync manually."
    exit 0
fi

# Treesitter parsers are optional. Run this only if the command exists after plugin sync.
if nvim --headless "+silent! TSUpdateSync" +qa >/dev/null 2>&1; then
    echo "Treesitter parsers installed or updated."
else
    echo " [INFO] Treesitter parser update skipped or unavailable."
fi
