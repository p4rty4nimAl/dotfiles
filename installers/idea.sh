#!/usr/bin/env bash

VERSION="2025.2.4"

TEMP="/tmp/idea.tar.gz"
curl -sSL "https://download.jetbrains.com/idea/ideaIC-${VERSION}.tar.gz" > "$TEMP"
tar xzf "$TEMP" -C "$HOME/.local/bin/"
ln -s "$HOME/.local/bin/idea-${VERSION}/bin/idea" "$HOME/.local/bin/ideas.sh"
rm $TEMP
