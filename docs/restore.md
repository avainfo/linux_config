# Restore from Backups

During installation, if the installer finds an existing configuration file that conflicts with the dotfiles repository, it gives you the option to back it up.

## Where are backups stored?

All backups are centralized in:

```bash
~/.config/ava/backups/
```

Each backup is placed inside a timestamped folder, for example:
`~/.config/ava/backups/20260429-123045/`

## How to restore a backup

1. Locate the backup folder in `~/.config/ava/backups/`.
2. Find the file you want to restore (e.g. `.zshrc`).
3. Overwrite the symlink created by the installer with your backup:

```bash
cp -a ~/.config/ava/backups/20260429-123045/.zshrc ~/.zshrc
```

## How to uninstall system drop-ins

If you used `--system-only` or `--full` and want to remove the workstation tweaks from your system:

```bash
sudo rm -f /etc/systemd/coredump.conf.d/99-ava-workstation.conf
sudo rm -f /etc/systemd/journald.conf.d/99-ava-workstation.conf
sudo rm -f /etc/sysctl.d/99-ava-workstation.conf

# Reload services
sudo systemctl daemon-reload
sudo systemctl restart systemd-coredump
sudo systemctl restart systemd-journald
sudo sysctl --system
```
