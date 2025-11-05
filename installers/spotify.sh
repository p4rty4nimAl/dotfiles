#!/usr/bin/env bash

curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo tee /etc/apt/keyrings/spotify.asc
sudo tee /etc/apt/sources.list.d/spotify.sources <<EOF
Types: deb
URIs: http://repository.spotify.com/
Suites: stable
Components: non-free
Signed-By: /etc/apt/keyrings/spotify.asc
EOF >/dev/null

sudo apt update && sudo apt install spotify-client