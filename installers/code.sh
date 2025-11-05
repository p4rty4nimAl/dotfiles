#!/usr/bin/env bash

TEMP=/tmp/vscode.deb
curl -sSL "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" > "$TEMP"
sudo apt install "$TEMP"
rm $TEMP