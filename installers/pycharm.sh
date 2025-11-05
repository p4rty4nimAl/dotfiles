#!/usr/bin/env bash

VERSION="2025.2.4"

TEMP="/tmp/pycharm.tar.gz"
curl -sSL "https://download.jetbrains.com/python/pycharm-${VERSION}.tar.gz" > "$TEMP"
tar xzf "$TEMP" -C "$HOME/.local/bin/"
ln -s "$HOME/.local/bin/pycharm-${VERSION}/bin/pycharm" "$HOME/.local/bin/pycharm"
rm $TEMP
