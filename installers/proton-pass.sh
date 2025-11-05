#!/usr/bin/env bash

VERSION="1.1.4"

TEMP=/tmp/proton-authenticator.deb
curl -sSL "https://proton.me/download/authenticator/linux/ProtonAuthenticator_${VERSION}_amd64.deb" > "$TEMP"
sudo apt install "$TEMP"
rm $TEMP