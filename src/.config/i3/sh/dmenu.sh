#!/usr/bin/env bash

GREY=$1
WHITE=$2
FONT=$3
MODE=$4

CMD_FLAGS="-nb \"$GREY\" -sf \"$GREY\" -sb \"$WHITE\" -nf \"$WHITE\" -fn \"$FONT\""

if [ "$MODE" = "run" ]; then
	exec bash -c "dmenu_run $CMD_FLAGS"
elif [ "$MODE" = "display" ]; then
	echo -e "primary\nsecondary\nmirror\nextend" | bash -c "dmenu $CMD_FLAGS"
fi
