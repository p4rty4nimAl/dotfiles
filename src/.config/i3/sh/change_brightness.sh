#!/usr/bin/env bash

if [ "$1" != "-" ] && [ "$1" != "+" ]; then
    exit 1
fi

# get current brightness as a percentage
CURRENT_BRIGHTNESS=$(brightnessctl -m | cut -d , -f 4 | tr -d %)

# $1 = +n or -n
# shellcheck disable=SC1102
NEW_BRIGHTNESS=$(( $CURRENT_BRIGHTNESS "$1" ))
if [ "$NEW_BRIGHTNESS" -lt 0 ]; then
    NEW_BRIGHTNESS=0
elif [ "$NEW_BRIGHTNESS" -gt 100 ]; then
    NEW_BRIGHTNESS=100
fi

brightnessctl set "$NEW_BRIGHTNESS%"

dunstify -h "int:value:$NEW_BRIGHTNESS" "Brightness changed" "Brightness set to $NEW_BRIGHTNESS%"
