#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DRY_RUN="${DRY_RUN:-0}"

if [[ $DRY_RUN -eq 1 ]]; then
    echo " [DRY-RUN] Would apply system configurations"
    exit 0
fi

echo "Applying system configurations (requires sudo)..."

sudo mkdir -p /etc/systemd/coredump.conf.d
sudo cp "$ROOT/system/coredump.conf.d/99-ava-workstation.conf" "/etc/systemd/coredump.conf.d/99-ava-workstation.conf"

sudo mkdir -p /etc/systemd/journald.conf.d
sudo cp "$ROOT/system/journald.conf.d/99-ava-workstation.conf" "/etc/systemd/journald.conf.d/99-ava-workstation.conf"

sudo mkdir -p /etc/sysctl.d
sudo cp "$ROOT/system/sysctl.d/99-ava-workstation.conf" "/etc/sysctl.d/99-ava-workstation.conf"

echo "Reloading systemd services..."
sudo systemctl daemon-reload || true
sudo systemctl restart systemd-coredump || true
sudo systemctl restart systemd-journald || true

echo "Applying sysctl..."
sudo sysctl --system || true

echo "System configuration applied."
