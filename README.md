# Linux Debugging Workstation Setup

A reproducible Linux workstation bootstrap for Pop!_OS, Ubuntu, and Debian-based systems.

It turns a fresh Linux machine into a C/C++ and embedded Linux development environment with debugging, crash analysis and system diagnostics tools.

## Commercial Relevance

This repository is primarily a personal engineering environment, but it documents the tools and workflows I use for Linux development, crash investigation and diagnostics.

It supports my work in:

- Linux developer training
- C/C++ debugging training
- embedded Linux support
- reproducible development environments
- diagnostics workflow setup

See [COMMERCIAL.md](COMMERCIAL.md) for more details.

## Supported Systems
- **Pop!_OS 22.04+**
- **Ubuntu & Debian-based Linux systems**

## Installation

### 1. Clone the repository
```bash
git clone https://github.com/avainfo/linux_config ~/.dotfiles
cd ~/.dotfiles
```

### 2. Choose your installation mode

> [!TIP]
> If you are installing on an existing machine, it is highly recommended to run a dry-run first to preview changes without modifying anything.

**Dry-Runs (Safe Previews)**
```bash
bash install.sh --full --dry-run
bash install.sh --user-only --dry-run
```

**Full Workstation Install (Requires sudo)**
Installs packages, system configurations, and user dotfiles.
```bash
bash install.sh --full
```

**System-Only Install (Requires sudo)**
Only installs apt packages and system configurations.
```bash
bash install.sh --system-only
```

**Full Install without System Configs**
Installs packages and dotfiles, but leaves system files (like journald and sysctl) alone.
```bash
bash install.sh --full --no-system
```

**Full Install + Docker (Requires sudo)**
```bash
bash install.sh --full --docker
```

**User-Only Install (No sudo required)**
Only links dotfiles and user scripts to your home directory. Safe for shared servers.
```bash
bash install.sh --user-only
```

## What Gets Installed

- **Zsh & Oh My Zsh**: The user shell profile automatically downloads Oh My Zsh, Powerlevel10k prompt, and plugins (`autosuggestions`, `syntax-highlighting`) if they are missing. Note: `chsh` is **not** run automatically.
- **Development Tools**: C/C++ compilers, CMake, Ninja, GDB, LLDB, Bear, Cppcheck.
- **Diagnostics Tools**: Valgrind, strace, ltrace, systemd-coredump, stress-ng, perf.
- **Desktop Utilities**: Kitty terminal, fonts, clipboard tools.
- **Custom Scripts**: Found in `scripts/`, including `analyze-core`, `debug-service`, and `collect-diagnostics`.

## Safety Model

- **Safe Upgrades**: The dotfiles installer will interactively prompt you if a local config file conflicts with the repository. It uses `cmp` and `diff` to show you exactly what changed.
- **Drop-in Configs**: System configurations (like `coredump.conf` and `journald.conf`) are safely placed in drop-in directories (`*.conf.d/`) rather than overwriting main OS files.
- **Backups**: If you choose to replace an existing config, a backup is safely stored in `~/.config/ava/backups/`.

## Documentation

Check the `docs/` folder for more details:
- [Workstation Philosophy](docs/workstation.md)
- [How to Restore Backups](docs/restore.md)
- [Crash Analysis Workflow](docs/crash-analysis-workflow.md)
