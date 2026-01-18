#!/bin/sh

source ~/.config/eww/scripts/hypr-common.sh

echo $(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .activeWorkspace.id')
# Listen for changes
listen_for_events get_focused_workspace
