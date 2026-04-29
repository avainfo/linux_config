#!/usr/bin/env bash
set -euo pipefail

if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    echo " [DRY-RUN] Would install embedded reliability tools"
    exit 0
fi

install_if_available() {
    for pkg in "$@"; do
        if apt-cache show "$pkg" >/dev/null 2>&1; then
            sudo apt-get install -y "$pkg"
        else
            echo " [WARNING] Package $pkg is not available, skipping."
        fi
    done
}

echo "Installing reliability tools..."
sudo apt-get install -y valgrind strace ltrace systemd-coredump elfutils binutils \
    dwarves stress-ng fio sysstat iotop iftop tcpdump net-tools iproute2 socat netcat-openbsd

install_if_available bpftrace trace-cmd linux-tools-common linux-tools-generic kernelshark
