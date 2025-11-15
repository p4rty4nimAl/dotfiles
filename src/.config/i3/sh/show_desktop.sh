#!/usr/bin/env bash

NEW_WORKSPACES=$(i3-msg -t get_workspaces | jq -r "map(select(.visible)).[].num")

for container in $(echo $NEW_WORKSPACES); do
    i3-msg "workspace number $container"
    i3-msg "workspace number $(( (container + 10) % 20))"
done
