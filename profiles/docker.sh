#!/usr/bin/env bash
set -euo pipefail

if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    echo " [DRY-RUN] Would install docker"
    exit 0
fi

if [[ ! -f /etc/os-release ]]; then
    echo " [ERROR] /etc/os-release not found. Cannot determine distribution."
    exit 1
fi

source /etc/os-release
CODENAME="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"

if [[ -z "$CODENAME" ]]; then
    echo " [ERROR] Could not determine Ubuntu/Pop codename. Skipping Docker install."
    exit 1
fi

echo "Installing Docker for codename: $CODENAME..."

sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
sudo rm -f /etc/apt/keyrings/docker.gpg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker "$USER" || true
echo " [INFO] You may need to logout and login again to use docker without sudo."
