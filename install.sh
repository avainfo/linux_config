#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ROOT

show_help() {
    cat <<EOF
Usage: bash install.sh [OPTIONS]

Options:
  --full          Install everything (default if no flags are provided)
  --user-only     Only install dotfiles and user scripts (no sudo required)
  --system-only   Only install packages and system configs
  --docker        Install Docker (requires apt)
  --no-system     Skip system configurations (journald, coredump, sysctl)
  --dry-run       Print what would happen without making any changes
  --help          Show this help message
EOF
    exit 0
}

MODE_FULL=0
MODE_USER_ONLY=0
MODE_SYSTEM_ONLY=0
MODE_DOCKER=0
MODE_NO_SYSTEM=0
export DRY_RUN=0

# Summary tracking
export SUM_DOT_INSTALLED=0
export SUM_DOT_SKIPPED=0
export SUM_DOT_CONFLICTS=0
export SUM_BACKUPS=0
export SUM_SYS_PROFILES=0
export SUM_SYS_CONFIGS=0
export SUM_DOCKER=0

# Parse arguments
if [[ $# -eq 0 ]]; then
    MODE_FULL=1
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --full) MODE_FULL=1 ;;
        --user-only) MODE_USER_ONLY=1 ;;
        --system-only) MODE_SYSTEM_ONLY=1 ;;
        --docker) MODE_DOCKER=1 ;;
        --no-system) MODE_NO_SYSTEM=1 ;;
        --dry-run) export DRY_RUN=1 ;;
        --help) show_help ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
    shift
done

# Resolve effective modes
if [[ $MODE_FULL -eq 1 ]]; then
    MODE_USER_ONLY=1
    MODE_SYSTEM_ONLY=1
fi

if [[ $MODE_USER_ONLY -eq 1 && $MODE_FULL -eq 0 ]]; then
    MODE_NO_SYSTEM=1
    MODE_SYSTEM_ONLY=0
fi

echo "======================================"
echo " Starting Workstation Installation"
echo "======================================"
if [[ $DRY_RUN -eq 1 ]]; then
    echo " *** DRY-RUN MODE: NO CHANGES WILL BE MADE ***"
fi

export HAS_APT=0
if command -v apt-get >/dev/null 2>&1; then
    HAS_APT=1
fi

# 1. System packages
if [[ $MODE_SYSTEM_ONLY -eq 1 ]]; then
    if [[ $HAS_APT -eq 1 ]]; then
        echo ">> Installing base profiles..."
        bash "$ROOT/profiles/base.sh"
        bash "$ROOT/profiles/dev-tools.sh"
        bash "$ROOT/profiles/embedded-reliability.sh"
        bash "$ROOT/profiles/desktop.sh"
        SUM_SYS_PROFILES=4
    else
        echo ">> Warning: apt-get not found. Skipping system packages."
    fi
fi

# 2. Docker
if [[ $MODE_DOCKER -eq 1 ]]; then
    if [[ $HAS_APT -eq 1 ]]; then
        echo ">> Installing Docker..."
        bash "$ROOT/profiles/docker.sh"
        SUM_DOCKER=1
    else
        echo ">> Warning: apt-get not found. Skipping Docker install."
    fi
fi

# 3. System Config
if [[ $MODE_SYSTEM_ONLY -eq 1 && $MODE_NO_SYSTEM -eq 0 ]]; then
    echo ">> Applying system configuration..."
    bash "$ROOT/system/apply.sh"
    SUM_SYS_CONFIGS=1
fi

# 4. Dotfiles & User Config
if [[ $MODE_USER_ONLY -eq 1 ]]; then
    echo ">> Preparing user shell..."
    bash "$ROOT/profiles/user-shell.sh"
    echo ">> Installing dotfiles..."
    bash "$ROOT/dotfiles/install.sh"
fi

echo ""
echo "======================================"
echo " Installation Summary"
echo "======================================"
if [[ -f "/tmp/ava_install_summary.env" ]]; then
    source "/tmp/ava_install_summary.env"
    rm -f "/tmp/ava_install_summary.env"
fi

echo " Dotfiles Linked     : $SUM_DOT_INSTALLED"
echo " Dotfiles Skipped    : $SUM_DOT_SKIPPED"
echo " Manual Conflicts    : $SUM_DOT_CONFLICTS"
echo " Backups Created     : $SUM_BACKUPS"
echo " Profiles Installed  : $SUM_SYS_PROFILES"
echo " Sys Config Applied  : $SUM_SYS_CONFIGS"
echo " Docker Installed    : $SUM_DOCKER"
echo "======================================"
echo " Next Steps:"
if [[ $MODE_USER_ONLY -eq 1 ]]; then
    echo " - Reload your shell: exec zsh"
    echo " - Start a tmux session: tmux new -s work"
fi
if [[ $SUM_SYS_CONFIGS -gt 0 ]]; then
    echo " - Check crash dumps: coredumpctl list"
    echo " - Debug a service: debug-service <service-name>"
fi
echo "======================================"
