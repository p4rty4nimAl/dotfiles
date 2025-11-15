#!/usr/bin/env bash

# apt list --installed ... # requirements, test for necessary ones for a specific file before installing it
# [ -e /sys/class/power_supply/BAT0/uevent ] # battery detection [i3status.conf]

# # cpu temperature? [i3status.conf]

# items in () after a package are the necessary tools provided by that package, if different
# ? means package not available in default apt repos

# list of packages that are difficult to automatically resolve

# systemd(systemctl, loginctl), i3-wm(i3, i3-sensible-terminal, i3bar), kwalletmanager(kwalletd6), pulseaudio-utils(pactl)
# code?, github-desktop?, node?, proton-authenticator?, proton-pass?, pycharm?, spotify-client(spotify)?, steam-installer(steam)?
# coreutils(head, cut, tr, printf), suckless-tools(dmenu, dmenu_run), x11-xserver-utils(xrandr, xset), mawk(awk), ?(nvidia-settings)

MIN_PKGS=(bash coreutils dbus-x11 firefox grep i3-wm i3status mawk python3 sed suckless-tools systemd x11-xserver-utils xinit xserver-xorg)
# minimal packages for graphical environment
# nice-to-haves
PKGS=(brightness-udev dex dunst flameshot hsetroot htop i3lock kwalletmanager picom pulseaudio-utils thunar xfce4-terminal xinput xss-lock)
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
    if [ -n "$notice_displayed" ]; then
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
    for dep in ${NON_APT_PKGS[@]}; do
        if [ -z "$(command -v $dep)" ]; then
            notice
            # not installed, prompt user
            read -rep "Would you like to install '$dep'? (y/n): " CONSENT
            if [ "$CONSENT" = "Y" ] || [ "$CONSENT" = "y" ]; then
                # shellcheck source=installers/*.sh
                . "$(pwd)/installers/$dep.sh"
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
                echo "File already exists, ignoring: $file" >&2
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
        missing=$(which_missing $dependencies)
        echo "Missing: $missing" >&2
    fi
done <<< "$DEPS"

echo "Installation complete."
if [ -e "./post-install.sh" ]; then
    echo "Running post-install script."
    . ./post-install.sh
fi
