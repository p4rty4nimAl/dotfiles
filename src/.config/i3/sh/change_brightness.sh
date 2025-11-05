#!/usr/bin/env bash

if [ "$#" -lt "2" ] || ([ "$1" != "-" ] && [ "$1" != "+" ]); then
    exit 1
fi

get_percentage() {
    local max=$(( $2 * 2 ))
    echo $(( ($1 * 200 + 100) / max ))
}
get_raw() {
    echo $(( ($1 * $2 * 2 + 100) / 200 ))
}

BASE_DIR=(/sys/class/backlight/*)

if [ "${#BASE_DIR}" = "0" ]; then
    exit 0
fi

MAX_BRIGHTNESS=$(cat "${BASE_DIR[0]}/max_brightness")
ACTUAL_BRIGHTNESS=$(cat "${BASE_DIR[0]}/actual_brightness")
CURRENT_BRIGHTNESS=$(get_percentage $ACTUAL_BRIGHTNESS $MAX_BRIGHTNESS)

# $1 = +n or -n
# shellcheck disable=SC1102
NEW_BRIGHTNESS=$(( $CURRENT_BRIGHTNESS "$1" "$2" ))
if [ "$NEW_BRIGHTNESS" -lt 0 ]; then
    NEW_BRIGHTNESS=0
elif [ "$NEW_BRIGHTNESS" -gt 100 ]; then
    NEW_BRIGHTNESS=100
fi

get_raw "$NEW_BRIGHTNESS" "$MAX_BRIGHTNESS" > "${BASE_DIR[0]}/brightness"

dunstify -h "int:value:$NEW_BRIGHTNESS" "Brightness changed" "Brightness set to $NEW_BRIGHTNESS%"
