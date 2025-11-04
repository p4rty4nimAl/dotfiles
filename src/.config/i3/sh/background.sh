#!/usr/bin/env bash

# expected behaviour:
# 	if $BASE_DIR/background.d exists, use random image from folder
#	else, if $BASE_DIR/background{.png,.jpg,.jpeg,...} exists, use that
#	else, use default hex code

BASE_DIR=$HOME/.config/i3
FALLBACK_COLOUR="#313131"

if [[ "$1" = "i3" ]]; then
	IMG_STR="-i"
	CLR_STR="-c"
else
	IMG_STR="-cover"
	CLR_STR="-solid"
fi
if [[ -d "$BASE_DIR/background.d" && -n $(ls -A "$BASE_DIR/background.d") ]]; then
	readarray IMG_ARR < <(ls "$BASE_DIR/background.d/")
	LENGTH=${#IMG_ARR[@]}
	# get random index
	IDX=$(( RANDOM * LENGTH / 32768))
	if [ "$LENGTH" != "0" ]; then
		OPTIONS="$IMG_STR $BASE_DIR/background.d/${IMG_ARR[$IDX]}"
	else
		OPTIONS="$CLR_STR $FALLBACK_COLOUR"
	fi
else
	if [[ -f "$BASE_DIR/background.png" ]]; then
		OPTIONS="$IMG_STR $BASE_DIR/background.png"
	else
		OPTIONS="$CLR_STR $FALLBACK_COLOUR"
	fi
fi
if [ -n "$OPTIONS" ]; then
	echo -e "$OPTIONS"
fi
