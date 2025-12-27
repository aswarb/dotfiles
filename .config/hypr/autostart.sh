#!/bin/bash


pkill -x waybar>/dev/null
pkill -x hyprpaper>dev/null
pkill -x hyprsunset>dev/null
pkill -x quickshell>/dev/null
pkill -x blueman-applet>/dev/null 
pkill -x nm-applet>/dev/null 
pkill -x gammastep>/dev/null 
pkill -f gammastep-indicator>/dev/null 
pkill -x pasystray>/dev/null 
pkill -x gnome-keyring-daemon>/dev/null 
pkill -x kdeconnect-indicator>/dev/null 
eww kill
source /home/aos/.zshrc

#waybar &
hyprpaper &
hyprsunset &
#quickshell &
pasystray -g --notify=sink --notify=systray_action --notify=source &
blueman-applet &
nm-applet & 
gnome-keyring-daemon -r -d &
kdeconnect-indicator &
alacritty --command tmux attach &
eww daemon &
eww open-many RBar LBar &
