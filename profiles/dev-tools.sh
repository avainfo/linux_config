#!/usr/bin/env bash
set -euo pipefail

if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    echo " [DRY-RUN] Would install dev tools"
    exit 0
fi

echo "Installing dev tools..."
sudo apt-get install -y cmake ninja-build gcc g++ clang clangd clang-format \
    clang-tidy lldb gdb make ccache bear cppcheck
