#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DRY_RUN="${DRY_RUN:-0}"

SUM_DOT_INSTALLED="${SUM_DOT_INSTALLED:-0}"
SUM_DOT_SKIPPED="${SUM_DOT_SKIPPED:-0}"
SUM_DOT_CONFLICTS="${SUM_DOT_CONFLICTS:-0}"
SUM_BACKUPS="${SUM_BACKUPS:-0}"

BACKUP_DIR="$HOME/.config/ava/backups/$(date +%Y%m%d-%H%M%S)"

# Ensure required directories exist
if [[ $DRY_RUN -eq 0 ]]; then
    mkdir -p "$HOME/bin"
    mkdir -p "$HOME/.config/kitty"
else
    echo " [DRY-RUN] Would create directory $HOME/bin and $HOME/.config/kitty"
fi

create_backup() {
    local target="$1"
    if [[ $DRY_RUN -eq 0 ]]; then
        mkdir -p "$BACKUP_DIR"
        cp -a "$target" "$BACKUP_DIR/"
        SUM_BACKUPS=$((SUM_BACKUPS + 1))
        echo "   [Backup] Saved to $BACKUP_DIR/$(basename "$target")"
    else
        echo "   [DRY-RUN] Would backup $target to $BACKUP_DIR/"
    fi
}

install_link() {
    local source_path="$1"
    local target_path="$2"

    if [[ ! -e "$source_path" ]]; then
        echo " [Skip] Source missing: $source_path"
        SUM_DOT_SKIPPED=$((SUM_DOT_SKIPPED + 1))
        return
    fi

    if [[ -L "$target_path" && "$(readlink "$target_path")" == "$source_path" ]]; then
        echo " [OK]   Already linked: $target_path"
        return
    fi

    if [[ -e "$target_path" || -L "$target_path" ]]; then
        if cmp -s "$target_path" "$source_path"; then
            echo " [OK]   Content identical, replacing with symlink: $target_path"
            if [[ $DRY_RUN -eq 0 ]]; then
                rm -f "$target_path"
                ln -snf "$source_path" "$target_path"
                SUM_DOT_INSTALLED=$((SUM_DOT_INSTALLED + 1))
            fi
            return
        fi

        echo " [!] Conflict found: $target_path"
        if [[ ! -t 0 ]]; then
            echo "   -> Non-interactive mode. Skipping file."
            SUM_DOT_CONFLICTS=$((SUM_DOT_CONFLICTS + 1))
            return
        fi

        while true; do
            echo "   [1] Keep existing file and skip"
            echo "   [2] Backup existing file and replace with repo symlink"
            echo "   [3] Copy existing file into repo, then symlink it"
            echo "   [4] Show diff"
            echo "   [5] Abort installation"
            read -r -p "   Choose action [1-5]: " choice
            case "$choice" in
                1)
                    echo "   -> Kept existing file."
                    SUM_DOT_SKIPPED=$((SUM_DOT_SKIPPED + 1))
                    return
                    ;;
                2)
                    create_backup "$target_path"
                    if [[ $DRY_RUN -eq 0 ]]; then
                        rm -rf "$target_path"
                        ln -snf "$source_path" "$target_path"
                        SUM_DOT_INSTALLED=$((SUM_DOT_INSTALLED + 1))
                    fi
                    echo "   -> Replaced with symlink."
                    return
                    ;;
                3)
                    create_backup "$source_path" # Backup the repo version just in case
                    if [[ $DRY_RUN -eq 0 ]]; then
                        cp -a "$target_path" "$source_path"
                        rm -rf "$target_path"
                        ln -snf "$source_path" "$target_path"
                        SUM_DOT_INSTALLED=$((SUM_DOT_INSTALLED + 1))
                    fi
                    echo "   -> Copied local config to repo and symlinked."
                    return
                    ;;
                4)
                    diff -u "$target_path" "$source_path" || true
                    ;;
                5)
                    echo "Aborting."
                    exit 1
                    ;;
                *)
                    echo "Invalid choice."
                    ;;
            esac
        done
    else
        if [[ $DRY_RUN -eq 0 ]]; then
            mkdir -p "$(dirname "$target_path")"
            ln -snf "$source_path" "$target_path"
            SUM_DOT_INSTALLED=$((SUM_DOT_INSTALLED + 1))
            echo " [LINK] Created $target_path"
        else
            echo " [DRY-RUN] Would link $source_path -> $target_path"
        fi
    fi
}

echo "Linking dotfiles..."

install_link "$ROOT/zsh/.zshrc"              "$HOME/.zshrc"
install_link "$ROOT/zsh/.p10k.zsh"           "$HOME/.p10k.zsh"
install_link "$ROOT/tmux/.tmux.conf"         "$HOME/.tmux.conf"
install_link "$ROOT/vim/.vimrc"              "$HOME/.vimrc"
install_link "$ROOT/git/.gitconfig"          "$HOME/.gitconfig"
install_link "$ROOT/kitty/kitty.conf"        "$HOME/.config/kitty/kitty.conf"
install_link "$ROOT/debug/.gdbinit"          "$HOME/.gdbinit"

# Sync bin scripts individually
if [[ -d "$ROOT/bin" ]]; then
    for script in "$ROOT/bin/"*; do
        if [[ -f "$script" ]]; then
            install_link "$script" "$HOME/bin/$(basename "$script")"
        fi
    done
fi
if [[ -d "$ROOT/../scripts" ]]; then
    for script in "$ROOT/../scripts/"*; do
        if [[ -f "$script" ]]; then
            install_link "$script" "$HOME/bin/$(basename "$script")"
        fi
    done
fi

cat <<EOF > /tmp/ava_install_summary.env
export SUM_DOT_INSTALLED=$SUM_DOT_INSTALLED
export SUM_DOT_SKIPPED=$SUM_DOT_SKIPPED
export SUM_DOT_CONFLICTS=$SUM_DOT_CONFLICTS
export SUM_BACKUPS=$SUM_BACKUPS
EOF

echo "Dotfiles installed."
