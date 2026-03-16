#!/bin/sh
source ~/.config/eww/scripts/sway-common.sh
swaymsg -t get_workspaces -r | jq -rc '[.[].num] | sort'
listen_for_events get_workspaces
