#!/usr/bin/env bash

VERSION="2025.2.4"

TEMP="/tmp/idea.tar.gz"
curl -sSL "https://download.jetbrains.com/idea/ideaIC-${VERSION}.tar.gz" > "$TEMP"
tar xzf "$TEMP" -C "$HOME/.local/bin/"
# This installer is only called if `idea` is not already installed
# Therefore, we can use shell expansion to find the installation directory
# as it does not match $VERSION
ln -s "$HOME"/.local/bin/idea-*/bin/idea "$HOME/.local/bin/idea"
rm $TEMP
