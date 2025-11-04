#!/usr/bin/env bash


# ln -s [1] [2]
# 2 becomes a link to 1

# apt list --installed ... # requirements, test for necessary ones for a specific file before installing it
# [ -e /sys/class/power_supply/BAT0/uevent ] # battery detection [i3status.conf]

# # cpu temperature? [i3status.conf]

# hierarchial structure
## items in [] are package dependencies for that file
### items in () after a package are the necessary tools provided by that package, if different
## items in [[]] are relative path dependencies
## ? means package not available in default apt repos

# ~/
#
## .config/
### i3 [i3-wm(i3, i3-sensible-terminal, i3bar)]
#### background.d/*
#### background.png
#### close.i3 [systemd(systemctl, loginctl)]
#### config [[sh/lock.sh], [sh/dmenu.sh], [sh/background.sh], [sh/toggle-compositor.sh] dex, xss-lock, systemd(systemctl, loginctl), flameshot, dunst, kwalletmanager(kwalletd6), hsetroot]
#### fn.i3 [[sh/change_brightness.sh], pulseaudio-utils(pactl)]
#### i3status.conf [i3status]
#### i3status.i3 [i3status]
#### open.i3 [bash]
#### open.d/
##### code.i3 [code?]
##### firefox.i3 [firefox]
##### github-desktop.i3 [github-desktop?]
##### htop.i3 [htop]
##### node.i3 [node?]
##### proton-authenticator.i3 [proton-authenticator?]
##### proton-pass.i3 [proton-pass?]
##### pycharm.i3 [pycharm?]
##### python3.i3 [python3]
##### show-configs.i3 [nano]
##### spotify.i3 [spotify-client(spotify)?]
##### steam.i3 [steam-installer(steam)?]
##### thunar.i3 [thunar]
#### picom.conf [picom]
#### resize.i3
#### sh/ [bash]
##### audio_notify.sh [pulseaudio-utils(pactl), grep, coreutils(head), dunst]
##### background.sh [[../background.d]]
##### battery_health.sh
##### change_brightess.sh [brightnessctl, coreutils(cut, tr), dunst]
##### dmenu.sh [suckless-tools(dmenu, dmenu_run)]
##### lock.sh [hsetroot, [background.sh], i3lock]
##### monitors.sh [x11-xserver-utils(xrandr), grep, mawk(awk), coreutils(cut, printf, head), hsetroot, [background.sh]]
##### startup.sh [grep, coreutils(cut), xinput, x11-xserver-utils(xrandr, xset), ?(nvidia-settings), hsetroot, [toggle-compositor.sh]]
##### toggle-compositor.sh [picom]

# minimal packages for graphical envrionment
MIN_PKGS=(bash coreutils firefox grep i3-wm i3status python3 sed suckless-tools systemd x11-xserver-utils xinit xserver-xorg)
# nice-to-haves
PKGS=(brightnessctl dex dunst flameshot github-desktop hsetroot htop i3lock kwalletmanager picom proton-authenticator proton-pass pulseaudio-utils thunar xfce4-terminal xinput xss-lock)


# assuming 64bit system
INSTALL_DATA="$(apt list "${MIN_PKGS[@]}" "${PKGS[@]}" 2>/dev/null | grep -v "i386" | tail -n +2)"
# dependencies file
DEPS=$(tail -n +2 < "dependencies.csv") # $1?

is_installed() {
    # returns 0 if all installed (or none specified), 1 if not
    # if <package> is wrapped in "[]", interpret as file in $DEPS, resolve recursively
    # usage: if is_installed <package1|file1> <package2|file2> <...>; then ...
    while (( $# )); do
        if [ "${1::1}" = "[" ] && [ "${1:(-1)}" = "]" ]; then
            # interpreting as file in $DEPS
            # adding comma to ensure grep gets the file, not another dep
            local key="${1:1:(-1)},"
            # if not is_installed (dependencies of file), return 1 (fail)
            # shellcheck disable=SC2046
            is_installed $( (grep "$key" | cut -d "," -f 2) <<< "$DEPS") || return 1;
        elif [ "$(echo "$INSTALL_DATA" | grep -F "$1" | grep -cE "(installed|upgradable)")" = "0" ]; then
            return 1;
        fi
        shift
    done
}


while IFS=, read -r file dependencies; do
    if is_installed $dependencies; then
        /bin/true
    else
        echo "MISSING: $dependencies"
    fi
done <<< "$DEPS"
