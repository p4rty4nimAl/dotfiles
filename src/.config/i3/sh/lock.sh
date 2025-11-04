#!/usr/bin/env bash

dunstctl set-paused true

# shellcheck disable=SC2046
hsetroot $("$HOME/.config/i3/sh/background.sh") &
# shellcheck disable=SC2046,SC2086
i3lock --nofork -t $($HOME/.config/i3/sh/background.sh i3)

dunstctl set-paused false
