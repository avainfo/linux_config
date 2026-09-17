# Linux Debugging Workstation Setup

A reproducible workstation configuration for Linux development, embedded systems, debugging and failure analysis.

The repository is intentionally built around **one entrypoint**:

```bash
bash install.sh ...
```

There are no per-component installers to remember. `dotfiles/`, `system/` and `scripts/` contain configuration and runtime files only; orchestration lives in the root `install.sh`.

## Supported environments

Primary targets:

- Pop!_OS
- Ubuntu
- Debian-based Linux
- WSL with an apt-based distribution

The user-only path also keeps the dotfiles usable on macOS. Linux-only package and system configuration steps are skipped when they do not apply.

## Install

Clone the repository:

```bash
git clone https://github.com/avainfo/linux_config ~/.dotfiles
cd ~/.dotfiles
```

Preview first on an existing machine:

```bash
bash install.sh --full --dry-run
```

Then choose one mode:

```bash
# Complete workstation
bash install.sh --full

# Dotfiles, shell, user tools and Neovim only
bash install.sh --user-only

# Packages and Linux system configuration only
bash install.sh --system-only

# Full install without journald/coredump/sysctl changes
bash install.sh --full --no-system

# Full install plus Docker
bash install.sh --full --docker

# Copy the terminal/editor environment to /root
bash install.sh --root-dotfiles
```

Do **not** run `install.sh` itself with `sudo`. The bootstrap requests `sudo` internally only for operations that need it.

## What the bootstrap does

### User environment

- links Zsh, Powerlevel10k, tmux, Vim, Neovim, Git, Kitty, GDB and clangd configuration
- links scripts from `scripts/` and `dotfiles/bin/` into `~/bin`
- installs or updates Oh My Zsh, Powerlevel10k and the configured Zsh plugins
- installs JetBrainsMono Nerd Font when needed
- installs Kitty in user space when it is not already available
- bootstraps Lazy.nvim plugins and Treesitter parsers

### Linux workstation

The system path installs grouped packages for:

- base CLI tooling
- C/C++ build and debugging
- embedded/reliability diagnostics
- desktop helpers when appropriate
- optional tracing and observability packages when available

System configuration uses drop-ins under:

- `/etc/systemd/coredump.conf.d/`
- `/etc/systemd/journald.conf.d/`
- `/etc/sysctl.d/`

### 42 workstations

42-specific behavior is detected from the real `/goinfre` mount, not from a username.

On a 42 workstation, Neovim redirects disposable storage to local `goinfre`:

```text
~/goinfre/nvim/cache
~/goinfre/nvim/state
~/goinfre/nvim/data
```

The actual config stays portable at `~/.config/nvim`.

The 42 hook deliberately does **not** export global `UV_PROJECT_ENVIRONMENT`, `UV_CACHE_DIR` or similar project-specific variables. Each project should control its own large development storage, typically from its Makefile or local script, so unrelated projects do not accidentally share one environment.

## Safety model

- `--dry-run` previews actions without changing the machine
- existing dotfile conflicts are not overwritten silently
- identical files are replaced with repository symlinks automatically
- interactive conflicts can be kept, backed up/replaced, copied into the repo, diffed or aborted
- backups live under `~/.config/ava/backups/`
- root dotfiles are copied rather than symlinked to a user-owned checkout
- Linux system configuration uses drop-in files instead of replacing distribution defaults

## Repository layout

```text
.
├── install.sh          # only installation entrypoint
├── dotfiles/           # tracked user configuration
│   ├── ava/            # environment-specific shell hooks
│   ├── nvim/
│   ├── zsh/
│   ├── kitty/
│   └── ...
├── scripts/            # daily engineering helpers
├── system/             # Linux drop-in configuration files
└── docs/
```

## Documentation

- [Workstation philosophy](docs/workstation.md)
- [Restore backups](docs/restore.md)
- [Crash analysis workflow](docs/crash-analysis-workflow.md)

See [COMMERCIAL.md](COMMERCIAL.md) for the professional context around the debugging and reliability tooling.
