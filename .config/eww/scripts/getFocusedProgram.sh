#!/bin/sh

source ~/.config/eww/scripts/hypr-common.sh

lastWorkspace=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .activeWorkspace.id')

echo $(hyprctl workspaces -j | jq -r '.[] | select(.id == '$lastWorkspace') | .lastwindowtitle')

listen_for_events get_focused_program
