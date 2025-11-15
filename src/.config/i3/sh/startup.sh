#!/usr/bin/env bash

MODEL=$(hostnamectl | grep "Hardware Model:" | cut -d ":" -f 2)
LAPTOP=$(echo "$MODEL" | cut -d " " -f 2)

# [ "$MODEL" = " ThinkPad E14 Gen 3" ]

# [ "$MODEL" = " ThinkPad X390" ]


# set trackpad string
CONNECTED_DEVICES=$(xinput list --name-only)
TRACKPAD_STRING="$(echo "$CONNECTED_DEVICES" | grep -i "touchpad")"
echo $TRACKPAD_STRING
if [ -n "$TRACKPAD_STRING" ]; then
	# configure trackpad
	xinput --set-prop "$TRACKPAD_STRING" "libinput Disable While Typing Enabled" 0
	xinput --set-prop "$TRACKPAD_STRING" "libinput Tapping Enabled" 1
	xinput --set-prop "$TRACKPAD_STRING" "libinput Click Method Enabled" 0 1
	xinput --set-prop "$TRACKPAD_STRING" "libinput Middle Emulation Enabled" 1
fi
# set up wireless mouse, disable acceleration
xinput --set-prop "MM731 Hybrid Mouse" "libinput Accel Profile Enabled" 0 0


NUM_MONITORS=$(xrandr --current --listmonitors | awk '(NR==1) {print $2}')

if [ "$NUM_MONITORS" = "1" ]; then
	# do not know how xrandr organises outputs, assume first is best?
	# works for me...
	PRIMARY=$(xrandr --current | awk '(NR==2) {print $1}')
	# set primary output
	xrandr --auto --output $PRIMARY --primary
else
	# desktop
	XRANDR_OUTPUT=$(xrandr --current --listmonitors)
	PRIMARY="DP-$(echo "$XRANDR_OUTPUT" | grep DP | rev | cut -c 1)"
	SECONDARY="HDMI-$(echo "$XRANDR_OUTPUT" | grep HDMI | rev | cut -c 1)"
	if command -v "nvidia-settings"; then
		nvidia-settings --assign "CurrentMetaMode=nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
	fi
	xrandr --output "$PRIMARY" --mode 1920x1080 --rate 240 --primary \
		--output "$SECONDARY" --mode 1920x1080 --rate 120 --left-of "$PRIMARY"
	xinput --set-prop "pointer:USB Laser Game Mouse" "libinput Accel Profile Enabled" 0, 1
fi

# set background display
# shellcheck disable=SC2046,SC2086
hsetroot $($HOME/.config/i3/sh/background.sh) #-cover "/home/astraea/.config/i3/background.png"
# Set keyboard repeat rate delay: 250ms, repeat 20 hz
xset r rate 250 20
# start picom
"$HOME/.config/i3/sh/toggle-compositor.sh" 1
