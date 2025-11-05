#!/usr/bin/env bash

VERSION="1.32.11"

TEMP=/tmp/proton-pass.deb
curl -sSL "https://proton.me/download/pass/linux/proton-pass_${VERSION}_amd64.deb" > "$TEMP"
sudo apt install "$TEMP"
rm $TEMP