# Workstation Philosophy

This repository is designed to turn a fresh Pop!_OS, Ubuntu, or Debian-based installation into a capable Linux development and debugging environment while keeping the same user configuration portable to more restricted machines.

## One Bootstrap

The repository has a single installation entrypoint:

```bash
bash install.sh [options]
```

The rest of the repository is data and runtime configuration:

- `dotfiles/` contains tracked user configuration
- `scripts/` contains runtime/debugging commands
- `system/` contains systemd and sysctl drop-ins
- `docs/` contains documentation

This avoids installer logic drifting between multiple nested scripts.

## Capability-Based Behavior

The bootstrap adapts to the environment rather than hardcoding a specific username or hostname.

For example, a 42 workstation is detected from the real `/goinfre` mount plus a writable `~/goinfre` directory.

When that environment is detected:

- user configuration remains available
- Neovim runtime/cache data is moved out of the small home quota into `~/goinfre/nvim`
- system package installation, Docker setup, and root configuration are blocked by default
- `--full` safely degrades to the user-only path
- an explicit `--force-system` is required to override the guard

Project-specific environment variables such as `UV_PROJECT_ENVIRONMENT`, `UV_CACHE_DIR`, and `HF_HOME` are intentionally not exported from the global shell configuration. They belong to the relevant project or project Makefile.

## Base OS

The full system setup is primarily designed for:

- Pop!_OS 22.04+
- Ubuntu
- Debian-based Linux systems

The user-level dotfiles are more portable and can also be used on restricted/shared systems.

## Components

The single bootstrap internally groups the setup into logical components:

- **Base**: standard CLI tools such as git, curl, fzf, tmux, zsh, and Neovim
- **Dev Tools**: C/C++ build systems, compilers, Clang tooling, GDB, LLDB, Bear, and Cppcheck
- **Embedded Reliability**: diagnostics and analysis tooling such as Valgrind, strace, coredump tooling, stress-ng, and tracing utilities
- **Desktop**: Kitty, fonts, and clipboard utilities when applicable
- **Docker**: optional Docker Engine installation from the official repository
- **User Environment**: shell dependencies, dotfile links, and Neovim bootstrap

## Safety and Idempotence

The installer is intended to be run repeatedly without blindly replacing local state.

- `--dry-run` previews changes
- conflicting user configuration is surfaced interactively
- identical local files can be replaced with repository symlinks
- backups are stored under `~/.config/ava/backups/`
- system configuration uses drop-in directories instead of replacing distribution defaults
- the main script refuses to run directly as root
- managed 42 workstations block system-level changes unless explicitly overridden
