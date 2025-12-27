#!/bin/sh

source ~/.config/eww/scripts/hypr-common.sh

echo $(hyprctl monitors -j | jq -rc '[.[].activeWorkspace.id] | sort')
# Listen for changes
listen_for_events get_active_workspaces
