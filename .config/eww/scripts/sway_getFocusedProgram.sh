#!/bin/sh
source ~/.config/eww/scripts/sway-common.sh
swaymsg -t get_tree -r | jq -r 'recurse(.nodes[]?, .floating_nodes[]?) | select(.focused==true) | .name'
listen_for_events get_focused_program
