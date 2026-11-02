# Campus Session

Apply your personal GNOME desktop preferences automatically at login, without
opening a terminal. Includes an optional minimal Oh My Zsh configuration.

Designed for Ubuntu GNOME campus workstations. No sudo is needed; settings apply
only to your user account and administrator-locked preferences are skipped.

## Requirements

- A GNOME desktop session on Linux (such as Ubuntu's default desktop).
- Bash, `gsettings`, `gdbus`, `gnome-extensions`, and the usual GNU utilities,
  including `timeout` and `install`. These are normally present on Ubuntu GNOME.
- Git to clone the repository, or download and extract its ZIP from GitHub.
- Optional: Zsh and an existing Oh My Zsh installation for the included shell config.

Brightness support depends on the hardware and GNOME version. External monitors
often do not support GNOME's brightness API.

## Install

```bash
git clone https://github.com/MliliGenes/campus-session.git
cd campus-session
bash install.sh
```

This installs the login script and a GNOME autostart entry, while preserving your
current `~/.zshrc`. Existing installed files are backed up; the installer prints
the backup location.

Apply the settings immediately:

```bash
~/.local/bin/campus-session
```

Future GNOME logins run the script automatically. The files in this repository
are copied during installation: after editing them or pulling updates, run
`bash install.sh` again to update the installed copy.

### Optional: replace your Zsh configuration

Review `zshrc.cleaned` first, then run:

```bash
bash install.sh --replace-zshrc
```

This backs up and replaces your entire `~/.zshrc`. The included config uses
Oh My Zsh's `robbyrussell` theme and `git` plugin, deduplicates PATH, and adds
`~/.local/bin` and `~/.opencode/bin` to PATH. It also provides:

- `zshconfig`: edit `~/.zshrc` using `$EDITOR` or Nano.
- `session-apply`: manually reapply the desktop preferences.

Open a new terminal to load it. Oh My Zsh itself is not installed by this bundle.
If you keep your existing `.zshrc`, remove any duplicate desktop-setting commands,
brightness loops, or Flatpak helper calls yourself.

## Settings applied at login

| Setting | Value |
| --- | --- |
| Cursor size | 28 |
| Screen brightness | 90% |
| Automatic brightness | Disabled |
| Idle dimming | Disabled |
| Mouse acceleration | Flat |
| Mouse speed | 0.0 (neutral) |
| Natural mouse scrolling | Disabled |
| Desktop animations | Disabled |
| Clock format | 24-hour, with seconds |
| Desktop Icons NG (`ding@rastersoft.com`) | Disabled |

Screen locking is not changed. Dark mode and custom keyboard repeat settings are
included as commented-out examples, so they are not applied by default.

If `~/.local/bin/flatpak-link.sh` exists, the script runs it with `sh` after applying
the settings, with a 30-second timeout. That helper is not included or modified.
It runs on each script invocation, including manual runs.

## Customize

Edit `apply_preferences()` in `campus-session` to change desktop settings or
comment out lines you do not want applied. Change `brightness=90` to choose a
different brightness percentage. Then reinstall and apply:

```bash
bash install.sh
~/.local/bin/campus-session
```

You can also edit `~/.local/bin/campus-session` directly, but reinstalling will
replace that copy (and back it up first).

The script retries brightness and extension operations up to 15 times while GNOME
starts. It then exits; it does not keep running to override your manual changes.

## Troubleshooting

Read the latest run's log:

```bash
cat "${XDG_STATE_HOME:-$HOME/.local/state}/campus-session/last-run.log"
```

- **No login run:** confirm you are using GNOME and that the autostart entry exists
  at `${XDG_CONFIG_HOME:-$HOME/.config}/autostart/campus-session.desktop`.
- **Unavailable or locked settings:** unsupported keys and administrator-locked
  preferences are logged and skipped.
- **Brightness does not change:** check `Brightness applied` in the log. Your
  hardware may not expose brightness through GNOME's Power D-Bus API.
- **Desktop icons remain:** check `DING disabled` in the log. Other desktop icon
  extensions are not handled by this script.
- **Settings change back later:** another login script or desktop service may
  override them after this script finishes.
- **Flatpak helper fails:** inspect the log and your existing `flatpak-link.sh`.

The log is replaced on every run. Actual brightness and campus login ordering
need checking on your own workstation.

## Disable or uninstall

Stop applying preferences at future logins:

```bash
rm -f -- "${XDG_CONFIG_HOME:-$HOME/.config}/autostart/campus-session.desktop"
```

Optionally remove the installed script and reference shell config:

```bash
rm -f -- "$HOME/.local/bin/campus-session"
rm -f -- "${XDG_CONFIG_HOME:-$HOME/.config}/campus-session/zshrc.cleaned"
```

Backups are kept under
`${XDG_CONFIG_HOME:-$HOME/.config}/campus-session/backups/`. If you replaced your
`.zshrc`, restore the `zshrc` file from the appropriate backup directory to
`~/.zshrc`.

Uninstalling does not revert settings already applied. Change them in GNOME
Settings, re-enable Desktop Icons NG in Extensions, or use
`gsettings reset SCHEMA KEY` to restore a setting's system default (which may
differ from your previous value).

## Files

- `campus-session`: applies desktop settings and runs the optional Flatpak helper.
- `install.sh`: installs files, creates backups, and registers GNOME autostart.
- `zshrc.cleaned`: optional minimal interactive Zsh configuration.
