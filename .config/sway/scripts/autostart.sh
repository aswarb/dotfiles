#!/bin/bash
# Sway autostart — called from sway config via exec

# Kill existing instances cleanly
pkill -x waybar 2>/dev/null
pkill -x gammastep 2>/dev/null
pkill -x blueman-applet 2>/dev/null
pkill -x nm-applet 2>/dev/null
pkill -f gammastep-indicator 2>/dev/null
pkill -x pasystray 2>/dev/null
pkill -x gnome-keyring-daemon 2>/dev/null
pkill -x kdeconnect-indicator 2>/dev/null
pkill -f polkit-kde-authentication-agent-1 2>/dev/null
eww kill 2>/dev/null

sleep 0.5

# Source your shell env if needed
[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"

# Night light — gammastep replaces hyprsunset
# Adjust lat:long for your location, or use geoclue
gammastep-indicator -m wayland -l 51.5:-0.1 -t 6500:5000 &

# Tray applets
pasystray -g --notify=sink --notify=systray_action --notify=source &
blueman-applet &
nm-applet &
gnome-keyring-daemon -r -d &
kdeconnect-indicator &

# Polkit agent
/usr/lib/polkit-kde-authentication-agent-1 &

# Terminal with tmux
alacritty --command tmux attach &

# EWW bars — adjust widget names if needed
eww daemon &
sleep 0.3
eww open-many top1 top0 buttom0 bottom1 &

# NOTE: swaybg / wallpaper is handled natively via `output ... bg` in the sway config.
# NOTE: hyprsunset → gammastep. Install gammastep if not already present.
# NOTE: If you used quickshell, you'll need to find a Wayland-generic alternative or keep it if it supports wlroots.
