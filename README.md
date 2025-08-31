# 🛠️ Dotfiles – Ava Setup

Personal configuration for a productive, portable, and visually appealing development environment.  
Works on any machine with user-space installation (no root required).  

Currently using:
- **Powerlevel10k** for the prompt (with plans to switch to a fully custom Zsh theme)
- **Afterglow** theme for Kitty
- **JetBrainsMono Nerd Font** for better glyph support and programming ligatures

---

## 📂 Contents

- **Zsh + Oh My Zsh** → Powerlevel10k prompt + plugins (`autosuggestions`, `syntax-highlighting`)
- **Tmux** → pane splits, status bar, and Truecolor support with Kitty
- **Vim** → minimal setup for C and Python development
- **Git** → aliases and colorized configuration
- **Kitty** → Afterglow theme + JetBrainsMono Nerd Font
- **EditorConfig** → consistent indentation and style
- **Clang-format** → C/C++ code formatting rules
- **GDB** → clean and readable debugging output
- **Custom scripts in `bin/`** → helpers for building, running, valgrind, etc.
- **Custom Zsh Theme (planned)** → multi-line prompt with full Git status (↑ ahead, ↓ behind, ✚ modified, ✔ staged, ⚠ conflicts)
- **Kitty Themes (planned)** → multiple variants (`ava-dark`, `ava-blue`, `ava-graphite`)

---

## 🚀 Installation

### 1. Clone the repository
```bash
git clone https://github.com/avainfo/linux_config/ ~/.dotfiles
```

### 2. Run the installation script

```bash
~/.dotfiles/install.sh
```

The script will:

* Create required directories (`~/.config/kitty`, `~/bin`, etc.)
* Symlink configuration files into `$HOME`
* Copy scripts into `~/bin`

---

## 🎨 Kitty Themes

Default setup uses the **Afterglow** theme with **JetBrainsMono Nerd Font**.
Additional themes are stored in `kitty/themes/`.
To change the theme, edit the `include` line at the top of `kitty.conf`:

```conf
include ~/.config/kitty/themes/ava-dark.conf
```

Available options:

* `ava-dark` → balanced dark theme
* `ava-blue` → deep night background with blue accents
* `ava-graphite` → high-contrast, highly readable theme

---

## 📦 Repository Structure

```
dotfiles/
  install.sh
  zsh/.zshrc
  zsh/.p10k.zsh
  tmux/.tmux.conf
  vim/.vimrc
  git/.gitconfig
  kitty/kitty.conf
  kitty/themes/*.conf
  editor/.editorconfig
  clang/.clang-format
  debug/.gdbinit
  bin/...
```

---

## ✨ Preview

Example Powerlevel10k prompt (current setup):

```
╭─ ~/Documents/config/dotfiles master ?1 ─── 00:32:41 ─╮
╰─❯                                                   ─╯
```

Kitty running the **Afterglow** theme with **JetBrainsMono Nerd Font**,
Tmux with a clean bottom bar, and accurate colors in Vim and Zsh.

---

## 📜 License

Free to use and modify.
