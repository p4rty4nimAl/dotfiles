#!/usr/bin/env bash

VERSION="2025.2.4"

TEMP="/tmp/datagrip.tar.gz"
curl -sSL "https://download-cdn.jetbrains.com/datagrip/datagrip-${VERSION}.tar.gz" > "$TEMP"
tar xzf "$TEMP" -C "$HOME/.local/bin/"
# This installer is only called if `idea` is not already installed
# Therefore, we can use shell expansion to find the installation directory
# as it does not match $VERSION
ln -s "$HOME"/.local/bin/DataGrip-*/bin/datagrip "$HOME/.local/bin/datagrip"
rm $TEMP
