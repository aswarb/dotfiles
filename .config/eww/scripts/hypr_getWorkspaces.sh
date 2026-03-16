#!/bin/sh

source ~/.config/eww/scripts/hypr-common.sh
echo $(hyprctl workspaces -j | jq -rc '[.[].id] | sort')
listen_for_events get_workspaces
