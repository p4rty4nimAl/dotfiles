#!/usr/bin/env bash

BATTERY_ID=0
if [ -n "$1" ]; then
	BATTERY_ID=$1
fi
BASE_DIR="/sys/class/power_supply/BAT$BATTERY_ID"
ENERGY_FULL_DESIGN=$(cat "$BASE_DIR/energy_full_design")
ENERGY_FULL=$(cat "$BASE_DIR/energy_full")
OUTPUT=$(( ENERGY_FULL * 10000 / ENERGY_FULL_DESIGN ))

echo -e "${OUTPUT:0:2}.${OUTPUT:2:4}%"
