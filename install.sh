#!/bin/bash
set -eu
umask 077
case "${1:-}" in
    ''|--replace-zshrc) ;;
    *) printf 'Usage: bash install.sh [--replace-zshrc]\n' >&2; exit 1 ;;
esac
bundle_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
backup_dir="$config_dir/campus-session/backups/$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "$HOME/.local/bin" "$config_dir/autostart" "$config_dir/campus-session" "$backup_dir"
backup() {
    if [[ -e $1 || -L $1 ]]; then cp -a -- "$1" "$backup_dir/$2"; fi
}
backup "$HOME/.local/bin/campus-session" campus-session
backup "$config_dir/autostart/campus-session.desktop" campus-session.desktop
backup "$config_dir/campus-session/zshrc.cleaned" zshrc.cleaned
install -m 700 "$bundle_dir/campus-session" "$HOME/.local/bin/campus-session"
install -m 600 "$bundle_dir/zshrc.cleaned" "$config_dir/campus-session/zshrc.cleaned"
cat > "$config_dir/autostart/campus-session.desktop" <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Campus Session Preferences
Comment=Apply personal GNOME settings at login
Exec=/bin/sh -c "exec ~/.local/bin/campus-session"
OnlyShowIn=GNOME;
Terminal=false
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=5
DESKTOP
if [[ ${1:-} == --replace-zshrc ]]; then
    backup "$HOME/.zshrc" zshrc
    install -m 600 "$bundle_dir/zshrc.cleaned" "$HOME/.zshrc"
    printf 'Installed the cleaned ~/.zshrc.\n'
else
    printf 'Your ~/.zshrc was preserved. Cleaned copy: %s/campus-session/zshrc.cleaned\n' "$config_dir"
    printf 'Remove the old desktop commands and Flatpak helper call from ~/.zshrc,\nor rerun with --replace-zshrc to install the cleaned version.\n'
fi
printf 'Backups: %s\n' "$backup_dir"
printf 'Applies at your next GNOME login. Apply now: ~/.local/bin/campus-session\n'
