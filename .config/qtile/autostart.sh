#!/bin/sh

nitrogen --restore &
picom --backend glx & 
alacritty --command tmux &

#bars=(topleft topright)
#i=1
#for monitor in $(xrandr --query | grep " connected"| cut -d " " -f1); do
#    echo "starting polybar ${bars[i]} on monitor $monitor";
#    MONITOR="$monitor" polybar ${bars[i]}&
#    i=$((i + 1))
#done

nm-applet &
blueman-applet &
redshift &
pasystray -g --notify=sink --notify=systray_action --notify=source & #pasystray -g --notify=all&
gnome-keyring-daemon -r -d &
source home/aos/.zshrc & 
kdeconnect-indicator &
export QT_QPA_PLATFORMTHEME="qt5ct"
