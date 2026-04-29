# Workstation Philosophy

This repository is designed to turn a fresh installation of Pop!_OS, Ubuntu, or Debian into a fully capable development environment quickly and reproducibly.

## Base OS

The setup is heavily tested on **Pop!_OS 22.04+** and **Ubuntu**, taking advantage of the `apt` ecosystem.

## Modularity

The configuration is split into distinct components:
- **Base**: Standard CLI tools (git, curl, fzf, tmux, zsh, neovim).
- **Dev Tools**: C/C++ build systems and compilers (cmake, gcc, clang, gdb).
- **Embedded Reliability**: Diagnostics and analysis tools (valgrind, strace, coredumpctl).
- **Desktop**: Terminal emulator (kitty) and clipboard utilities.
- **Docker**: Containerization using the official Docker APT repository.

## Safety and Idempotence

The installer script (`install.sh`) is built to be run multiple times safely.
- It will not overwrite your existing personal configuration blindly.
- It uses systemd drop-in configuration (`/etc/systemd/*.conf.d/`) to avoid clashing with distribution defaults.
- It provides a `--dry-run` flag so you can preview changes.
