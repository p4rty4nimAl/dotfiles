#!/usr/bin/env bash

# VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -o -P '\d+%' | head -n 1)

# MUTED=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -c yes) # == 1 when true

# MUTE_STRING="Volume changed"
# if [[ $MUTED -eq 1 ]]; then
# 	MUTE_STRING="(Muted) $MUTE_STRING"
# fi

# dunstify -h "int:value:$VOLUME" "$MUTE_STRING" "Volume now set to $VOLUME"