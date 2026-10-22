# Generic tmux layouts (Zsh)

The aliases `vim=nvim`, `dvim`, and `tvim` remain available. The new `dv`, `dh`, and `ts` functions live in `dotfiles/zsh/.zshrc`.

| Command | Layout |
| --- | --- |
| `dv vim .` | Two equal top/bottom panes, both running `vim .` |
| `dh vim .` | Two equal left/right panes, both running `vim .` |
| `dv 'ssh causaltrace'` | Two top/bottom SSH panes |
| `ts 'vim .' 'ssh causaltrace'` | Vim on the left; two SSH panes stacked on the right |
| `ts 'vim .' 'ssh causaltrace' 'ssh other-host'` | Vim on the left; different commands in the top-right and bottom-right panes |

For `dv` and `dh`, pass a single quoted **shell command** if it contains spaces, pipes or shell operators. Unquoted arguments such as `dv vim .` are escaped and joined for you.

For `ts`, supply **two or three quoted shell commands**. When the third is omitted, the second is duplicated in both right-hand panes.

## Behavior

- Inside tmux, these functions create and select a **new tmux window**. Existing panes in the current window are not disturbed.
- Outside tmux, they create a dedicated session and attach to it.
- All panes start in the directory from which you invoked the command.
- `dv`/`dh` allocate 50/50. `ts` allocates 55% to the editor on the left and 45% to the right; the two right panes share the height equally.
- The first pane is focused at the end of setup.
- Commands are typed into the pane's shell, so interactive commands like `nvim` and `ssh` work. When a command exits, that pane returns to its shell instead of disappearing.

Your existing tmux shortcuts still work: `Ctrl+b` plus arrow keys to move between panes; `Alt` plus arrow keys to resize them. Close the whole created window with `Ctrl+b` then `&` (tmux asks for confirmation).

## Updating an existing workstation

After pulling changes to `linux_config`, reload the symlinked `~/.zshrc` with:

```zsh
source ~/.zshrc
```

If `~/.zshrc` is not linked to this repository, copy or symlink the update with your usual dotfiles installer.

## Tests

```sh
zsh -n dotfiles/zsh/.zshrc
zsh -f tests/zsh/tmux_layouts.zsh
```

The automated tests simulate tmux to verify the pane geometry, argument handling, interactive command startup, and session/window selection logic. They do not launch real SSH connections or actual Neovim instances.
