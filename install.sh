#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$HOME/.config/ava/backups/$TIMESTAMP"

DRY_RUN=0
FORCE_SYSTEM=0
MODE_FULL=0
MODE_USER=0
MODE_SYSTEM=0
MODE_DOCKER=0
MODE_NO_SYSTEM=0
MODE_ROOT_DOTFILES=0

SUM_DOT_INSTALLED=0
SUM_DOT_SKIPPED=0
SUM_DOT_CONFLICTS=0
SUM_BACKUPS=0
SUM_SYS_GROUPS=0
SUM_SYS_CONFIGS=0
SUM_DOCKER=0
SUM_ROOT_DOTFILES=0

show_help() {
    cat <<'EOF'
Usage: bash install.sh [OPTIONS]

Modes:
  --full            Install system packages/config and user environment
                    (default when no mode is provided)
  --user-only       Install user tools, shell, dotfiles and Neovim plugins
  --system-only     Install system packages and system configuration
  --root-dotfiles   Copy terminal/editor config to /root using sudo

Options:
  --docker          Install Docker Engine on supported apt-based Linux systems
  --no-system       Skip journald, coredump and sysctl drop-ins
  --force-system    Allow system/root changes on managed 42 workstations
  --dry-run         Preview changes without modifying the machine
  --help            Show this help

Examples:
  bash install.sh --full --dry-run
  bash install.sh --user-only
  bash install.sh --system-only --no-system
  bash install.sh --full --docker
  bash install.sh --root-dotfiles

On a 42 workstation, system/root changes are blocked by default. A plain
`bash install.sh` automatically degrades to the safe user-only path.
EOF
}

if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    cat >&2 <<'EOF'
Do not run install.sh with sudo.
Run it as your normal user. The installer calls sudo internally when required.

Examples:
  bash install.sh --full
  bash install.sh --system-only
  bash install.sh --root-dotfiles
EOF
    exit 1
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --full) MODE_FULL=1 ;;
        --user-only) MODE_USER=1 ;;
        --system-only) MODE_SYSTEM=1 ;;
        --root-dotfiles) MODE_ROOT_DOTFILES=1 ;;
        --docker) MODE_DOCKER=1 ;;
        --no-system) MODE_NO_SYSTEM=1 ;;
        --force-system) FORCE_SYSTEM=1 ;;
        --dry-run) DRY_RUN=1 ;;
        --help|-h) show_help; exit 0 ;;
        *) echo "Unknown option: $1" >&2; show_help >&2; exit 1 ;;
    esac
    shift
done

if [[ $MODE_FULL -eq 0 && $MODE_USER -eq 0 && $MODE_SYSTEM -eq 0 && $MODE_ROOT_DOTFILES -eq 0 ]]; then
    MODE_FULL=1
fi
if [[ $MODE_FULL -eq 1 ]]; then
    MODE_USER=1
    MODE_SYSTEM=1
fi
if [[ $MODE_USER -eq 1 && $MODE_SYSTEM -eq 0 ]]; then
    MODE_NO_SYSTEM=1
fi

log() { printf '%s\n' "$*"; }
info() { printf ' [INFO] %s\n' "$*"; }
warn() { printf ' [WARNING] %s\n' "$*" >&2; }
command_exists() { command -v "$1" >/dev/null 2>&1; }

run() {
    if [[ $DRY_RUN -eq 1 ]]; then
        printf ' [DRY-RUN]'
        printf ' %q' "$@"
        printf '\n'
    else
        "$@"
    fi
}

is_42_workstation() {
    [[ "$OS" == "Linux" ]] || return 1
    [[ -d /goinfre && -d "$HOME/goinfre" && -w "$HOME/goinfre" ]] || return 1
    command_exists mountpoint || return 1
    mountpoint -q /goinfre 2>/dev/null
}

guard_42_system_changes() {
    if ! is_42_workstation || [[ $FORCE_SYSTEM -eq 1 ]]; then
        return 0
    fi

    if [[ $MODE_SYSTEM -eq 0 && $MODE_DOCKER -eq 0 && $MODE_ROOT_DOTFILES -eq 0 ]]; then
        return 0
    fi

    if [[ $MODE_FULL -eq 1 ]]; then
        warn "42 workstation detected: system, Docker and root changes are disabled by default."
        info "Continuing with the user-only setup. Use --force-system only if you intentionally want system changes."
        MODE_SYSTEM=0
        MODE_DOCKER=0
        MODE_ROOT_DOTFILES=0
        MODE_NO_SYSTEM=1
        return 0
    fi

    warn "42 workstation detected: refusing system/root changes on a managed workstation."
    warn "Use --force-system only if you intentionally want to override this safety guard."
    exit 2
}

guard_42_system_changes

apt_available() {
    [[ "$OS" == "Linux" ]] && command_exists apt-get && command_exists apt-cache
}

install_if_available() {
    local pkg
    for pkg in "$@"; do
        if apt-cache show "$pkg" >/dev/null 2>&1; then
            run sudo apt-get install -y "$pkg"
        else
            warn "Package $pkg is not available, skipping."
        fi
    done
}

install_system_packages() {
    if ! apt_available; then
        warn "apt is not available. Skipping Linux system packages."
        return 0
    fi

    local -a base_packages=(
        git curl wget unzip zip ca-certificates gnupg lsb-release
        software-properties-common build-essential pkg-config jq tree htop
        ripgrep fd-find fzf tmux zsh neovim python3 python3-pip python3-venv rsync
    )
    local -a dev_packages=(
        cmake ninja-build gcc g++ clang clangd clang-format clang-tidy
        lldb gdb make ccache bear cppcheck
    )
    local -a reliability_packages=(
        valgrind strace ltrace systemd-coredump elfutils binutils dwarves
        stress-ng fio sysstat iotop iftop tcpdump net-tools iproute2 socat netcat-openbsd
    )
    local -a desktop_packages=(kitty xclip xsel)
    local -a optional_packages=(
        btop figlet bpftrace trace-cmd linux-tools-common linux-tools-generic
        kernelshark fonts-powerline wl-clipboard gnome-tweaks
    )

    log ">> Updating apt..."
    run sudo apt-get update -y

    log ">> Installing base packages..."
    run sudo apt-get install -y "${base_packages[@]}"
    if [[ $DRY_RUN -eq 0 ]]; then
        SUM_SYS_GROUPS=$((SUM_SYS_GROUPS + 1))
    fi

    log ">> Installing development tools..."
    run sudo apt-get install -y "${dev_packages[@]}"
    if [[ $DRY_RUN -eq 0 ]]; then
        SUM_SYS_GROUPS=$((SUM_SYS_GROUPS + 1))
    fi

    log ">> Installing reliability and diagnostics tools..."
    run sudo apt-get install -y "${reliability_packages[@]}"
    if [[ $DRY_RUN -eq 0 ]]; then
        SUM_SYS_GROUPS=$((SUM_SYS_GROUPS + 1))
    fi

    if [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]] || [[ ! -e /proc/sys/fs/binfmt_misc/WSLInterop ]]; then
        log ">> Installing desktop tools..."
        run sudo apt-get install -y "${desktop_packages[@]}"
        if [[ $DRY_RUN -eq 0 ]]; then
            SUM_SYS_GROUPS=$((SUM_SYS_GROUPS + 1))
        fi
    else
        info "WSL detected without a Linux desktop session. Skipping desktop packages."
    fi

    log ">> Installing optional packages when available..."
    install_if_available "${optional_packages[@]}"
}

install_docker() {
    if ! apt_available; then
        warn "Docker bootstrap currently supports apt-based Linux only."
        return 0
    fi
    if [[ ! -f /etc/os-release ]]; then
        warn "/etc/os-release not found. Cannot determine distribution for Docker."
        return 0
    fi

    # shellcheck disable=SC1091
    source /etc/os-release
    local codename="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"
    local docker_family="ubuntu"
    [[ "${ID:-}" == "debian" ]] && docker_family="debian"

    if [[ -z "$codename" ]]; then
        warn "Could not determine Ubuntu/Pop/Debian codename. Skipping Docker."
        return 0
    fi

    log ">> Installing Docker for $docker_family/$codename..."
    run sudo apt-get install -y ca-certificates curl gnupg
    run sudo install -m 0755 -d /etc/apt/keyrings

    if [[ $DRY_RUN -eq 1 ]]; then
        info "Would install Docker GPG key, repository and Engine packages."
        return 0
    fi

    sudo rm -f /etc/apt/keyrings/docker.gpg
    curl -fsSL "https://download.docker.com/linux/$docker_family/gpg" \
        | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$docker_family $codename stable" \
        | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker "$USER" || true
    SUM_DOCKER=1
    info "Log out and back in to use Docker without sudo."
}

backup_system_file() {
    local target="$1"
    [[ -f "$target" ]] || return 0
    local target_dir="$BACKUP_DIR/system$(dirname "$target")"

    if [[ $DRY_RUN -eq 1 ]]; then
        info "Would backup $target to $target_dir/"
    else
        mkdir -p "$target_dir"
        sudo cp -a "$target" "$target_dir/"
        SUM_BACKUPS=$((SUM_BACKUPS + 1))
        log "   [Backup] $target -> $target_dir/"
    fi
}

apply_system_config() {
    [[ "$OS" == "Linux" ]] || { info "System drop-ins are Linux-only. Skipping."; return 0; }

    backup_system_file /etc/systemd/coredump.conf.d/99-ava-workstation.conf
    backup_system_file /etc/systemd/journald.conf.d/99-ava-workstation.conf
    backup_system_file /etc/sysctl.d/99-ava-workstation.conf

    if [[ $DRY_RUN -eq 1 ]]; then
        info "Would apply coredump, journald and sysctl drop-ins."
        return 0
    fi

    sudo mkdir -p /etc/systemd/coredump.conf.d /etc/systemd/journald.conf.d /etc/sysctl.d
    sudo cp "$ROOT/system/coredump.conf.d/99-ava-workstation.conf" /etc/systemd/coredump.conf.d/99-ava-workstation.conf
    sudo cp "$ROOT/system/journald.conf.d/99-ava-workstation.conf" /etc/systemd/journald.conf.d/99-ava-workstation.conf
    sudo cp "$ROOT/system/sysctl.d/99-ava-workstation.conf" /etc/sysctl.d/99-ava-workstation.conf

    sudo systemctl daemon-reload || true
    sudo systemctl restart systemd-coredump || true
    sudo systemctl restart systemd-journald || true
    sudo sysctl --system || true
    SUM_SYS_CONFIGS=1
}

fetch_url() {
    local url="$1"
    local output="$2"

    if command_exists curl; then
        curl -fsSL "$url" -o "$output"
    elif command_exists wget; then
        wget -qO "$output" "$url"
    else
        warn "curl or wget is required to download $url"
        return 1
    fi
}

clone_or_update() {
    local repo_url="$1"
    local target_dir="$2"
    local name="$3"

    if [[ $DRY_RUN -eq 1 ]]; then
        info "Would clone or update $name in $target_dir"
        return 0
    fi

    if [[ -d "$target_dir/.git" ]]; then
        log "$name already exists. Updating..."
        git -C "$target_dir" pull --ff-only >/dev/null || warn "Could not update $name."
    elif [[ -d "$target_dir" ]]; then
        warn "$target_dir exists but is not a Git repository. Skipping $name."
    else
        git clone --depth=1 "$repo_url" "$target_dir"
    fi
}

install_user_shell() {
    command_exists git || { warn "git not found. Skipping Oh My Zsh setup."; return 0; }

    local zsh_dir="$HOME/.oh-my-zsh"
    local custom="$zsh_dir/custom"

    log ">> Preparing Oh My Zsh, Powerlevel10k and plugins..."
    clone_or_update https://github.com/ohmyzsh/ohmyzsh.git "$zsh_dir" "Oh My Zsh"
    run mkdir -p "$custom/plugins" "$custom/themes"
    clone_or_update https://github.com/romkatv/powerlevel10k.git "$custom/themes/powerlevel10k" "Powerlevel10k"
    clone_or_update https://github.com/zsh-users/zsh-autosuggestions.git "$custom/plugins/zsh-autosuggestions" "zsh-autosuggestions"
    clone_or_update https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom/plugins/zsh-syntax-highlighting" "zsh-syntax-highlighting"
    clone_or_update https://github.com/zsh-users/zsh-completions.git "$custom/plugins/zsh-completions" "zsh-completions"
    clone_or_update https://github.com/zsh-users/zsh-history-substring-search.git "$custom/plugins/zsh-history-substring-search" "zsh-history-substring-search"
}

install_jetbrains_nerd_font() {
    local font_dir="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"

    if command_exists fc-match && fc-match "JetBrainsMono Nerd Font" 2>/dev/null | grep -qi JetBrains; then
        info "JetBrainsMono Nerd Font already available."
        return 0
    fi

    if [[ "$OS" == "Darwin" ]] && command_exists brew; then
        run brew install --cask font-jetbrains-mono-nerd-font
        return 0
    fi

    command_exists unzip || { warn "unzip not found. Skipping Nerd Font install."; return 0; }

    if [[ $DRY_RUN -eq 1 ]]; then
        info "Would install JetBrainsMono Nerd Font into $font_dir"
        return 0
    fi

    local tmp_dir
    tmp_dir="$(mktemp -d)"
    if fetch_url https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip "$tmp_dir/JetBrainsMono.zip"; then
        mkdir -p "$font_dir"
        unzip -oq "$tmp_dir/JetBrainsMono.zip" -d "$font_dir"
        command_exists fc-cache && fc-cache -f "$font_dir" >/dev/null || true
    fi
    rm -rf "$tmp_dir"
}

install_kitty_user() {
    command_exists kitty && { info "Kitty already available in PATH."; return 0; }

    if [[ "$OS" == "Darwin" ]] && command_exists brew; then
        run brew install --cask kitty
        return 0
    fi

    local local_bin="$HOME/.local/bin"
    local kitty_dir="$HOME/.local/kitty.app"
    local kitty_bin="$kitty_dir/bin/kitty"

    [[ -x "$kitty_bin" ]] && { info "Kitty already installed at $kitty_bin"; return 0; }

    if [[ $DRY_RUN -eq 1 ]]; then
        info "Would install Kitty into $kitty_dir"
        return 0
    fi

    local tmp_dir
    tmp_dir="$(mktemp -d)"
    if fetch_url https://sw.kovidgoyal.net/kitty/installer.sh "$tmp_dir/kitty-installer.sh"; then
        sh "$tmp_dir/kitty-installer.sh" launch=n dest="$HOME/.local"
        if [[ -x "$kitty_bin" ]]; then
            mkdir -p "$local_bin"
            ln -snf "$kitty_bin" "$local_bin/kitty"
        fi
    fi
    rm -rf "$tmp_dir"
}

install_user_tools() {
    run mkdir -p "$HOME/.local/bin" "$HOME/.local/share/fonts"
    install_jetbrains_nerd_font
    install_kitty_user
}

create_backup() {
    local target="$1"

    if [[ $DRY_RUN -eq 1 ]]; then
        info "Would backup $target to $BACKUP_DIR/"
        return 0
    fi

    mkdir -p "$BACKUP_DIR"
    cp -a "$target" "$BACKUP_DIR/"
    SUM_BACKUPS=$((SUM_BACKUPS + 1))
    log "   [Backup] Saved $target to $BACKUP_DIR/"
}

install_link() {
    local source_path="$1"
    local target_path="$2"

    if [[ ! -e "$source_path" ]]; then
        warn "Source missing: $source_path"
        SUM_DOT_SKIPPED=$((SUM_DOT_SKIPPED + 1))
        return 0
    fi

    if [[ -L "$target_path" && "$(readlink "$target_path")" == "$source_path" ]]; then
        log " [OK]   Already linked: $target_path"
        return 0
    fi

    if [[ -e "$target_path" || -L "$target_path" ]]; then
        if [[ -f "$target_path" && -f "$source_path" ]] && cmp -s "$target_path" "$source_path"; then
            log " [OK]   Content identical, replacing with symlink: $target_path"
            if [[ $DRY_RUN -eq 0 ]]; then
                rm -f "$target_path"
                ln -snf "$source_path" "$target_path"
                SUM_DOT_INSTALLED=$((SUM_DOT_INSTALLED + 1))
            fi
            return 0
        fi

        log " [!] Conflict found: $target_path"
        if [[ ! -t 0 ]]; then
            log "   -> Non-interactive mode. Keeping existing file."
            [[ -f "$target_path" && -f "$source_path" ]] && log "   diff -u '$target_path' '$source_path'"
            SUM_DOT_CONFLICTS=$((SUM_DOT_CONFLICTS + 1))
            return 0
        fi

        local choice
        while true; do
            cat <<'EOF'
   [1] Keep existing file and skip
   [2] Backup existing file and replace with repo symlink
   [3] Copy existing regular file into repo, then symlink it
   [4] Show diff
   [5] Abort installation
EOF
            read -r -p "   Choose action [1-5]: " choice
            case "$choice" in
                1)
                    SUM_DOT_SKIPPED=$((SUM_DOT_SKIPPED + 1))
                    return 0
                    ;;
                2)
                    create_backup "$target_path"
                    if [[ $DRY_RUN -eq 0 ]]; then
                        rm -rf "$target_path"
                        ln -snf "$source_path" "$target_path"
                        SUM_DOT_INSTALLED=$((SUM_DOT_INSTALLED + 1))
                    fi
                    return 0
                    ;;
                3)
                    if [[ ! -f "$target_path" || ! -f "$source_path" ]]; then
                        warn "Copying local config into the repo is supported only for regular files."
                        continue
                    fi
                    create_backup "$source_path"
                    if [[ $DRY_RUN -eq 0 ]]; then
                        cp -a "$target_path" "$source_path"
                        rm -f "$target_path"
                        ln -snf "$source_path" "$target_path"
                        SUM_DOT_INSTALLED=$((SUM_DOT_INSTALLED + 1))
                    fi
                    return 0
                    ;;
                4)
                    if [[ -f "$target_path" && -f "$source_path" ]]; then
                        diff -u "$target_path" "$source_path" || true
                    else
                        info "Diff is available only for regular files."
                    fi
                    ;;
                5)
                    log "Aborting."
                    exit 1
                    ;;
                *) warn "Invalid choice." ;;
            esac
        done
    fi

    if [[ $DRY_RUN -eq 1 ]]; then
        info "Would link $source_path -> $target_path"
    else
        mkdir -p "$(dirname "$target_path")"
        ln -snf "$source_path" "$target_path"
        SUM_DOT_INSTALLED=$((SUM_DOT_INSTALLED + 1))
        log " [LINK] $target_path -> $source_path"
    fi
}

install_tree_links() {
    local source_dir="$1"
    local target_dir="$2"

    [[ -d "$source_dir" ]] || return 0
    while IFS= read -r -d '' item; do
        local relative_path="${item#"$source_dir/"}"
        install_link "$item" "$target_dir/$relative_path"
    done < <(find "$source_dir" \( -type f -o -type l \) -print0)
}

install_dotfiles() {
    log ">> Linking dotfiles..."
    run mkdir -p "$HOME/bin" "$HOME/.config" "$HOME/.config/kitty"

    install_link "$ROOT/dotfiles/zsh/.zshrc" "$HOME/.zshrc"
    install_link "$ROOT/dotfiles/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
    install_link "$ROOT/dotfiles/tmux/.tmux.conf" "$HOME/.tmux.conf"
    install_link "$ROOT/dotfiles/vim/.vimrc" "$HOME/.vimrc"
    install_link "$ROOT/dotfiles/git/.gitconfig" "$HOME/.gitconfig"
    install_link "$ROOT/dotfiles/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
    install_link "$ROOT/dotfiles/debug/.gdbinit" "$HOME/.gdbinit"
    install_link "$ROOT/dotfiles/nvim" "$HOME/.config/nvim"
    install_link "$ROOT/dotfiles/clangd/config.yaml" "$HOME/.config/clangd/config.yaml"
    install_link "$ROOT/dotfiles/ava/42-workstation.zsh" "$HOME/.config/ava/42-workstation.zsh"

    install_tree_links "$ROOT/dotfiles/bin" "$HOME/bin"
    install_tree_links "$ROOT/scripts" "$HOME/bin"
}

run_nvim_headless() {
    if is_42_workstation; then
        local base="$HOME/goinfre/nvim"
        mkdir -p "$base/cache" "$base/state" "$base/data"
        env \
            XDG_CACHE_HOME="$base/cache" \
            XDG_STATE_HOME="$base/state" \
            XDG_DATA_HOME="$base/data" \
            nvim --headless "$@"
    else
        nvim --headless "$@"
    fi
}

bootstrap_nvim() {
    [[ "${SKIP_NVIM_BOOTSTRAP:-0}" -eq 1 ]] && { info "Skipping Neovim bootstrap."; return 0; }
    command_exists nvim || { warn "nvim not found. Skipping plugin bootstrap."; return 0; }
    command_exists git || { warn "git not found. Skipping plugin bootstrap."; return 0; }
    [[ -f "$HOME/.config/nvim/init.lua" ]] || { warn "Neovim config not found. Skipping plugin bootstrap."; return 0; }

    if [[ $DRY_RUN -eq 1 ]]; then
        info "Would run Neovim Lazy sync and Treesitter update."
        return 0
    fi

    log ">> Bootstrapping Neovim plugins..."
    run_nvim_headless "+Lazy! sync" +qa || warn "Lazy sync failed. Run :Lazy sync manually."
    run_nvim_headless "+silent! TSUpdateSync" +qa >/dev/null 2>&1 || info "Treesitter parser update skipped or unavailable."
}

sudo_clone_or_update() {
    local repo_url="$1"
    local target_dir="$2"
    local name="$3"

    if [[ $DRY_RUN -eq 1 ]]; then
        info "Would clone or update $name in $target_dir as root"
        return 0
    fi

    if sudo test -d "$target_dir/.git"; then
        sudo git -C "$target_dir" pull --ff-only >/dev/null || warn "Could not update root $name."
    elif sudo test -d "$target_dir"; then
        warn "$target_dir exists but is not a Git repository. Skipping root $name."
    else
        sudo git clone --depth=1 "$repo_url" "$target_dir"
    fi
}

copy_root_item() {
    local source_path="$1"
    local target_path="$2"
    local root_backup="/root/.dotfiles-backup/$TIMESTAMP"

    [[ -e "$source_path" ]] || return 0

    if [[ $DRY_RUN -eq 1 ]]; then
        info "Would backup $target_path when needed and copy $source_path as root."
        return 0
    fi

    if sudo test -e "$target_path" || sudo test -L "$target_path"; then
        sudo mkdir -p "$root_backup"
        sudo cp -a "$target_path" "$root_backup/"
    fi

    sudo rm -rf "$target_path"
    sudo mkdir -p "$(dirname "$target_path")"
    sudo cp -a "$source_path" "$target_path"
}

install_root_dotfiles() {
    command_exists sudo || { warn "sudo is required for --root-dotfiles."; return 1; }
    command_exists git || { warn "git is required for root shell plugins."; return 1; }

    log ">> Installing root dotfiles..."
    sudo_clone_or_update https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh "Oh My Zsh"
    run sudo mkdir -p /root/.oh-my-zsh/custom/plugins /root/.oh-my-zsh/custom/themes
    sudo_clone_or_update https://github.com/romkatv/powerlevel10k.git /root/.oh-my-zsh/custom/themes/powerlevel10k "Powerlevel10k"
    sudo_clone_or_update https://github.com/zsh-users/zsh-autosuggestions.git /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions "zsh-autosuggestions"
    sudo_clone_or_update https://github.com/zsh-users/zsh-syntax-highlighting.git /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting "zsh-syntax-highlighting"

    copy_root_item "$ROOT/dotfiles/zsh/.zshrc" /root/.zshrc
    copy_root_item "$ROOT/dotfiles/zsh/.p10k.zsh" /root/.p10k.zsh
    copy_root_item "$ROOT/dotfiles/tmux/.tmux.conf" /root/.tmux.conf
    copy_root_item "$ROOT/dotfiles/vim/.vimrc" /root/.vimrc
    copy_root_item "$ROOT/dotfiles/debug/.gdbinit" /root/.gdbinit
    copy_root_item "$ROOT/dotfiles/nvim" /root/.config/nvim

    if [[ "${INSTALL_GIT_CONFIG:-0}" == "1" ]]; then
        copy_root_item "$ROOT/dotfiles/git/.gitconfig" /root/.gitconfig
    else
        info "Skipping root .gitconfig. Set INSTALL_GIT_CONFIG=1 to include it."
    fi

    if [[ "${SET_ROOT_SHELL:-0}" == "1" ]] && command_exists zsh; then
        run sudo chsh -s "$(command -v zsh)" root
    fi

    if [[ $DRY_RUN -eq 0 ]]; then
        SUM_ROOT_DOTFILES=1
    fi
}

print_summary() {
    cat <<EOF

======================================
 Installation Summary
======================================
 Dotfiles Linked     : $SUM_DOT_INSTALLED
 Dotfiles Skipped    : $SUM_DOT_SKIPPED
 Manual Conflicts    : $SUM_DOT_CONFLICTS
 Backups Created     : $SUM_BACKUPS
 System Groups       : $SUM_SYS_GROUPS
 Sys Config Applied  : $SUM_SYS_CONFIGS
 Docker Installed    : $SUM_DOCKER
 Root Dotfiles       : $SUM_ROOT_DOTFILES
======================================
EOF

    if [[ $DRY_RUN -eq 1 ]]; then
        info "Dry-run counters show applied changes only; planned actions are listed above."
    fi
    if is_42_workstation; then
        info "42 workstation detected: Neovim cache/state/data use ~/goinfre/nvim."
    fi
    [[ $MODE_USER -eq 1 ]] && info "Reload your shell with: exec zsh"
    [[ $SUM_DOCKER -eq 1 ]] && info "A new login may be required for Docker group membership."
}

log "======================================"
log " Starting Workstation Installation"
log "======================================"
[[ $DRY_RUN -eq 1 ]] && log " *** DRY-RUN MODE: NO CHANGES WILL BE MADE ***"

if [[ $MODE_SYSTEM -eq 1 ]]; then
    install_system_packages
    [[ $MODE_NO_SYSTEM -eq 0 ]] && apply_system_config
fi

[[ $MODE_DOCKER -eq 1 ]] && install_docker

if [[ $MODE_USER -eq 1 ]]; then
    install_user_tools
    install_user_shell
    install_dotfiles
    bootstrap_nvim
fi

[[ $MODE_ROOT_DOTFILES -eq 1 ]] && install_root_dotfiles

print_summary
