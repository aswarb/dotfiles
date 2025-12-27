#!/bin/sh
pos=$(hyprctl cursorpos -j)

echo pos
x=$(echo "$pos" | jq -r '.x')
y=$(echo "$pos" | jq -r '.y')

if [[ -z "$x" || -z "$y" ]]; then
  echo "Failed to get cursor position"
  exit 1
fi

hyprctl dispatch movecursor $((x + 10)) $y

hyprctl dispatch movecursor $x $y

