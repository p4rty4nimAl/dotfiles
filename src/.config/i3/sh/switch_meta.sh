#!/usr/bin/env bash

MOD4_STRING="set \$mod Mod4"
MOD1_STRING="set \$mod Mod1"
CONFIG_LOC="$HOME/.config/i3/config"

if [ $(grep -c "${MOD4_STRING}" "${CONFIG_LOC}") = 1 ]; then
	# currently 4, replace with 1
	NEW_CONFIG=$(sed "s/${MOD4_STRING}/${MOD1_STRING}/" "${CONFIG_LOC}")
else
	# currently 1, replace with 4
	NEW_CONFIG=$(sed "s/${MOD1_STRING}/${MOD4_STRING}/" "${CONFIG_LOC}")
fi

echo "${NEW_CONFIG}" > "${CONFIG_LOC}"
