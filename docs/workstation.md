# Workstation Philosophy

This repository keeps one portable development environment for Pop!_OS, Ubuntu, Debian-based systems, WSL, and user-level dotfiles on macOS.

## One bootstrap, passive configuration

The root `install.sh` is the only installation entrypoint.

Everything else has a narrower responsibility:

- `dotfiles/` contains configuration that is linked into the user environment
- `system/` contains Linux drop-in files that the bootstrap copies into `/etc`
- `scripts/` contains daily engineering helpers linked into `~/bin`
- `docs/` documents workflows and recovery

This avoids having multiple partially overlapping installers whose behavior drifts over time.

## Installation layers

The bootstrap still keeps logical layers internally:

- **Base**: standard CLI tools such as Git, curl, fzf, tmux, Zsh and Neovim
- **Development**: C/C++ compilers, CMake, Ninja, clangd, GDB, LLDB, Bear and Cppcheck
- **Reliability**: Valgrind, strace, coredumps, tracing, stress and network diagnostics
- **Desktop**: Kitty and clipboard helpers when a desktop environment is relevant
- **Docker**: optional installation from Docker's official package repository
- **User**: shell plugins, fonts, dotfile links and Neovim plugin bootstrap

The implementation is centralized, but the responsibilities remain explicit.

## Environment-specific behavior

Machine-specific policy should be detected from machine capabilities, not usernames or hardcoded hostnames.

For example, a 42 workstation is identified by the mounted `/goinfre` filesystem and a writable `$HOME/goinfre`. In that environment, Neovim's disposable cache, data and state are redirected to `goinfre`, while the tracked config stays in the normal XDG config path.

Project-specific environments are intentionally excluded from global shell policy. A Python project that wants its uv cache or virtualenv in `goinfre` should configure that locally instead of exporting a global `UV_PROJECT_ENVIRONMENT`.

## Safety and idempotence

The installer is designed to be rerun safely:

- `--dry-run` previews operations
- existing personal config is not overwritten silently
- identical files can become symlinks automatically
- conflicts can be inspected with `diff`
- replacements are backed up under `~/.config/ava/backups/`
- root config is copied rather than linked to a user checkout
- Linux system settings use drop-in files rather than replacing distribution defaults
