#!/usr/bin/env bash

COMPOSITOR="picom"

COMPOSITOR_ARGS="-b -f --glx-no-stencil --glx-no-rebind-pixmap -i 0.85 -O 0.015 -I 0.015 -D 2"
#COMPOSITOR_ARGS="-b -f --glx-no-stencil -i 0.85 -O 0.015 -I 0.015 -D 2"
#COMPOSITOR_ARGS="-b --backend xrender -i 0.8 -D 2"

# Exit codes:
#	0: $COMPOSITOR was not running
#	1: $COMPOSITOR was running
#	2: error

COMPOSITOR_PID=$(pidof $COMPOSITOR)
DESIRED_STATE=$1

if [ -z "$DESIRED_STATE" ]; then
	# No desired state; toggle
	if [ -z "$COMPOSITOR_PID" ]; then
		$COMPOSITOR $COMPOSITOR_ARGS
	else
		kill "$COMPOSITOR_PID"
	fi
elif [ "$DESIRED_STATE" = "0" ]; then
	kill "$COMPOSITOR_PID"
elif [ -z "$COMPOSITOR_PID" ]; then
	$COMPOSITOR $COMPOSITOR_ARGS
fi

# exec test for exit code
exec test -z "$COMPOSITOR_PID"
