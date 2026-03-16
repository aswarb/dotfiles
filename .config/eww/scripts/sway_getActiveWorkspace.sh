#!/bin/sh
source ~/.config/eww/scripts/sway-common.sh
swaymsg -t get_outputs -r | jq -rc '[.[].current_workspace | tonumber] | sort'
listen_for_events get_active_workspaces
