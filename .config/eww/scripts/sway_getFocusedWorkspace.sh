#!/bin/sh
source ~/.config/eww/scripts/sway-common.sh
swaymsg -t get_workspaces -r | jq -r '.[] | select(.focused==true) | .num'
listen_for_events get_focused_workspace
