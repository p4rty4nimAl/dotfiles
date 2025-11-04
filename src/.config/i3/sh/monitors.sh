#!/usr/bin/env bash

GPU_ID=0
INTERNAL_DISPLAY=eDP
MODE=$1

declare -a OUTPUTS
declare MODE

get_active_outputs () {
	# Function to map display ports (as in xRandR) to their sysfs path.
	# Populates the $OUTPUTS variable, with an array of colon separated values - xRandR:sysfs, or xRandR:disconnected
	# Parameters: GPU_ID, typically 0.
	# Returns: number of active displays - 0 for headless, 1 for a single display, etc.
	readarray POSSIBLE_OUTPUTS < <(xrandr --verbose | grep -i "[^b]connect" | awk '/^[^[:space:]]/ {conn=$1} /CONNECTOR_ID/ && conn {print conn ":" $2}')
	local GPU_ID=$1

	for f in "/sys/class/drm/card${GPU_ID}"-*/; do
		# if device connected, add it to the total + ...
		if [ "$(cat "$f/status")" = "connected" ]; then
			# check $OUTPUTS for matching 'connector_id's
			for id in $(seq 0 $(( ${#POSSIBLE_OUTPUTS[@]} - 1 )) ); do
				# match comparison
				if [ "$(cut -d ":" -f 2 <<< "${POSSIBLE_OUTPUTS[id]}")" = "$(cat "$f/connector_id")" ]; then
					# join when matched
					POSSIBLE_OUTPUTS[id]="$(cut -d ":" -f 1 <<< "${POSSIBLE_OUTPUTS[id]}"):$f"
				fi
			done
		fi
	done
	# validate output, remove remaining entries with ids
	OUTPUTS=()
	for id in $(seq 0 $(( ${#POSSIBLE_OUTPUTS[@]} - 1 )) ); do
		# may falsely fail check if the 'connector_id' is present as a file in CWD
		if [ -e "$(cut -d ":" -f 2 <<< "${POSSIBLE_OUTPUTS[id]}")" ]; then
			OUTPUTS[id]="${POSSIBLE_OUTPUTS[id]}"
		fi
	done
	return ${#OUTPUTS[@]}
}
get_mode () {
	XRANDR_OUTPUT=$1
	MODE=$(head -n 1 < "$(printf "%s\n" "${OUTPUTS[@]}" | grep -F "$XRANDR_OUTPUT" | cut -d ":" -f 2)/modes)")
}


get_active_outputs $GPU_ID
CONNECTED=$?

if [ $CONNECTED -lt 2 ]; then
	# Machine is either headless, or single output
	if [ $CONNECTED -eq 1 ]; then
		# machine has single display - assume internal, force its use
		xrandr --auto --output $INTERNAL_DISPLAY
	fi
	exit 0
fi
# At least two displays connected - handle according to $MODE

CMD_ARGS=""

case "$MODE" in
	primary)
		for i in $(seq 0 $(( ${#OUTPUTS[@]} - 1)) ); do
			OUTPUT="$(cut -d ":" -f 1 <<< "${OUTPUTS[i]}")"
			CMD_ARGS="$CMD_ARGS --output $OUTPUT --auto"
			if [ "$OUTPUT" != "$INTERNAL_DISPLAY" ]; then
				CMD_ARGS="$CMD_ARGS --off"
			else
				get_mode "$OUTPUT"
				CMD_ARGS="$CMD_ARGS --mode $MODE --primary"
			fi
		done
		;;
	secondary)
		for i in $(seq 0 $(( ${#OUTPUTS[@]} - 1)) ); do
			OUTPUT="$(cut -d ":" -f 1 <<< "${OUTPUTS[i]}")"
			CMD_ARGS="$CMD_ARGS --output $OUTPUT --auto"
			if [ "$OUTPUT" = "$INTERNAL_DISPLAY" ]; then
				CMD_ARGS="$CMD_ARGS --off"
			else
				get_mode "$OUTPUT"
				CMD_ARGS="$CMD_ARGS --mode $MODE --primary"
			fi
		done
		;;
	mirror)
		for i in $(seq 0 $(( ${#OUTPUTS[@]} - 1)) ); do
			OUTPUT="$(cut -d ":" -f 1 <<< "${OUTPUTS[i]}")"
			get_mode "$OUTPUT"
			CMD_ARGS="$CMD_ARGS --output $OUTPUT --auto --mode $MODE"
			if [ "$OUTPUT" = "$INTERNAL_DISPLAY" ]; then
				CMD_ARGS="$CMD_ARGS --primary"
			else
				CMD_ARGS="$CMD_ARGS --same-as $INTERNAL_DISPLAY"
			fi
		done
		;;
	extend)
		for i in $(seq 0 $(( ${#OUTPUTS[@]} - 1)) ); do
			OUTPUT="$(cut -d ":" -f 1 <<< "${OUTPUTS[i]}")"
			get_mode "$OUTPUT"
			CMD_ARGS="$CMD_ARGS --output $OUTPUT --auto --mode $MODE"
			if [ "$OUTPUT" = "$INTERNAL_DISPLAY" ]; then
				CMD_ARGS="$CMD_ARGS --primary"
			else
				if [ -n "$LAST_OUTPUT" ]; then
					CMD_ARGS="$CMD_ARGS --above $LAST_OUTPUT"
				else
					CMD_ARGS="$CMD_ARGS --above $INTERNAL_DISPLAY"
				fi
			fi
			LAST_OUTPUT=$OUTPUT
		done
		;;
esac

# shellcheck disable=SC2086
xrandr $CMD_ARGS
# shellcheck disable=SC2046,SC2086
hsetroot $(~/.config/i3/sh/background.sh)
