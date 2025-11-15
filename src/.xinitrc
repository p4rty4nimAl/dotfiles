#!/usr/bin/env bash
export XDG_CURRENT_DESKTOP=i3

xrdb ~/.Xresources

# test for an existing bus daemon
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
	# if not found, launch a new one
	eval `dbus-launch --sh-syntax`
fi

exec dbus-launch --exit-with-session i3
