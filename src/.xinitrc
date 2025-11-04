#!/usr/bin/env bash
export XDG_CURRENT_DESKTOP=i3

xrdb ~/.Xresources

# test for an existing bus daemon
if test -z "$DBUS_SESSION_BUS_ADDRESS" ; then
	# if not found, launch a new one
	eval `dbus-launch --sh-syntax`
	echo "D-Bus per-session daemon address is: $DBUS_SESSION_BUS_ADDRESS"
fi

exec dbus-launch --exit-with-session i3
