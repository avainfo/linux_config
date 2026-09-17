# Linux Debugging Workstation Setup

A reproducible workstation bootstrap for Linux development, debugging, embedded systems, reliability work, and my portable terminal/editor environment.

The repository deliberately has **one installation entrypoint**:

```bash
bash install.sh [options]
```

`dotfiles/`, `system/`, and `scripts/` contain configuration and runtime helpers only. They do not have their own installers.

## Supported Environments

Primary targets:

- Pop!_OS 22.04+
- Ubuntu
- Debian-based Linux
- 42 Linux workstations for user-space configuration

User dotfiles also keep basic macOS compatibility where the underlying tools are available.

## Installation

> [!IMPORTANT]
> Do not run the installer itself with `sudo`.
> Run it as your normal user. It invokes `sudo` internally only for explicitly requested system changes.

### Clone

```bash
git clone https://github.com/avainfo/linux_config ~/.dotfiles
cd ~/.dotfiles
```

### Preview first

```bash
bash install.sh --user-only --dry-run
bash install.sh --full --dry-run
```

### User environment only

Links the tracked dotfiles, installs or updates the user shell dependencies, prepares Kitty/font support when needed, and bootstraps Neovim.

```bash
bash install.sh --user-only
```

### Full workstation

Installs apt packages, system drop-ins, and the user environment:

```bash
bash install.sh --full
```

### System only

```bash
bash install.sh --system-only
```

Skip the journald/coredump/sysctl drop-ins with:

```bash
bash install.sh --system-only --no-system
```

### Docker

```bash
bash install.sh --full --docker
```

### Root dotfiles

Root setup is still available, but through the same entrypoint:

```bash
bash install.sh --root-dotfiles
```

Optional root behavior:

```bash
INSTALL_GIT_CONFIG=1 bash install.sh --root-dotfiles
SET_ROOT_SHELL=1 bash install.sh --root-dotfiles
```

## 42 Workstations

The installer detects a 42 workstation by capability, not by username. It checks that `/goinfre` is a real mount and that `~/goinfre` is writable.

On a detected 42 workstation:

- a plain `bash install.sh` is safe and automatically uses the user-only path
- `--full` also degrades to user-only
- system package changes, Docker installation, and root configuration are blocked by default
- `--system-only`, `--docker`, or `--root-dotfiles` require the explicit `--force-system` override
- Neovim keeps its tracked configuration in `~/.config/nvim`
- Neovim cache, state, and plugin/runtime data are redirected to `~/goinfre/nvim`

The override exists for controlled environments where system modification is genuinely intended:

```bash
bash install.sh --system-only --force-system
```

Do not use `--force-system` casually on managed campus machines.

The 42 hook intentionally does **not** export project-specific variables such as `UV_PROJECT_ENVIRONMENT`, `UV_CACHE_DIR`, or `HF_HOME`. Those belong in individual projects so one project cannot contaminate another project's environment.

## Repository Structure

```text
.
├── install.sh                  # single bootstrap entrypoint
├── dotfiles/                   # tracked user configuration only
│   ├── ava/
│   │   └── 42-workstation.zsh # capability-based 42 runtime hook
│   ├── nvim/
│   ├── zsh/
│   ├── tmux/
│   ├── kitty/
│   ├── git/
│   └── ...
├── scripts/                    # runtime/debugging commands linked into ~/bin
├── system/                     # systemd/sysctl configuration data only
└── docs/
```

There are no nested installation scripts under `profiles/`, `dotfiles/`, or `system/`.

## What Gets Installed

Depending on the selected mode:

- Zsh, Oh My Zsh, Powerlevel10k, completions, autosuggestions, history search, and syntax highlighting
- C/C++ compilers, Clang, CMake, Ninja, GDB, LLDB, Bear, Cppcheck, ccache
- reliability and diagnostics tooling such as Valgrind, strace, ltrace, coredump tooling, stress-ng, fio, tcpdump, and optional tracing tools
- Kitty and clipboard/desktop utilities on applicable systems
- Vim, Neovim, clangd, Git, tmux, Kitty, GDB, and shell configuration
- custom scripts from `scripts/` and `dotfiles/bin/`
- optional Docker Engine installation
- optional journald, coredump, and sysctl drop-ins

## Safety Model

The bootstrap is designed to be rerunnable and conservative:

- `--dry-run` previews operations
- existing dotfiles are not silently overwritten
- identical files can be converted to repository symlinks
- conflicting files can be kept, diffed, backed up, or intentionally imported into the repository
- backups go under `~/.config/ava/backups/`
- system configuration uses drop-in files rather than replacing distribution defaults
- the main bootstrap refuses to run as root
- managed 42 workstations block system-level changes by default
- project-specific Python/AI cache settings are not exported globally

## Documentation

- [Workstation Philosophy](docs/workstation.md)
- [How to Restore Backups](docs/restore.md)
- [Crash Analysis Workflow](docs/crash-analysis-workflow.md)
