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
MIN_PKGS=(bash coreutils dbus-x11 firefox grep i3-wm i3status mawk python3 sed suckless-tools systemd x11-xserver-utils xinit xserver-xorg)
# nice-to-haves
PKGS=(brightness-udev dex dunst flameshot github-desktop hsetroot htop i3lock kwalletmanager picom pulseaudio-utils thunar xfce4-terminal xinput xss-lock)
# packages that arent available by default (on debian at least)
NON_APT_PKGS=(code github-desktop node proton-authenticator proton-pass pycharm idea spotify steam)

# assuming x86_64 system, filtering in case of multiarch
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
            # check if fake, command -> return 1 if fail
            if [ "${1:(-1):1}" != "?" ] || [ -z "$(command -v ${1:0:-1})" ]; then
                return 1
            fi
        fi
        shift
    done
}

which_missing() {
    local CONFIRMED_MISSING=()
    while (( $# )); do
        is_installed "$1" || CONFIRMED_MISSING+=("$1")
        shift
    done
    echo "${CONFIRMED_MISSING[@]}"
}

notice_displayed="false"
notice() {
    if [ -n $notice_displayed ]; then
        echo "You can suppress install requests with 'noinstall'."
        notice_displayed=
    fi
}

if [ "$1" != "noinstall" ]; then
    if [ "$(is_installed ${MIN_PKGS[@]})" = "1" ]; then
        notice
        read -rep "Would you like to install the minimal graphical packages? (y/n): " CONSENT
        if [ "$CONSENT" = "Y"] || [ "$CONSENT" = "y" ]; then
            sudo apt install $(which_missing ${MIN_PKGS[@]})
        fi
    fi
    if [ "$(is_installed ${PKGS[@]})" = "1" ]; then
        notice
        read -rep "Would you like to install the additional graphical packages? (y/n): " CONSENT
        if [ "$CONSENT" = "Y"] || [ "$CONSENT" = "y" ]; then
            sudo apt install $(which_missing ${PKGS[@]})
        fi
    fi
    for dep in $NON_APT_PKGS; do
        if [ -z "$(command -v $dep)" ]; then
            notice
            # not installed, prompt user
            read -rep "Would you like to install '$dep'? (y/n): " CONSENT
            if [ "$CONSENT" = "Y" ] || [ "$CONSENT" = "y" ]; then
                . $(pwd)/installers/$dep.sh
            fi
        fi
    done
fi

while IFS=, read -r file dependencies; do
    # shellcheck disable=SC2086
    if is_installed $dependencies; then
        if [ -e "$HOME/$file" ]; then
            # file already exists
            # if symlink/dir, leave it alone (probably from previous ./install.sh)
            # else warn
            if [ ! -h "$HOME/$file" ] && [ ! -d "$HOME/$file" ]; then
                # file is not from previous ./install.
                # TODO: prompt to overwrite
                echo "File already exists, ignoring: $file"
            fi
        else
            # file does not exist, create/symlink it
            if [ -d "$(pwd)/src/$file" ]; then
                echo "Creating directory: $file"
                mkdir "$HOME/$file"
            else 
                echo "Linking: $file"
                ln -s "$(pwd)/src/$file" "$HOME/$file"
            fi
        fi
    else
        # TODO: better error handling/raising here
        # shellcheck disable=SC2086
        missing=$(which_missing $dependencies)
        echo "Missing: $missing"
    fi
done <<< "$DEPS"

echo "Installation successful! (*kind of)"
echo "Running post-install script."
. ./post-install.sh