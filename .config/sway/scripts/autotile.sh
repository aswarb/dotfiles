#!/bin/bash
# autotile.sh — alternates split direction based on focused container dimensions
# Listens for window and workspace focus events, sets splith/splitv
# based on whether the focused container is wider or taller.

swaymsg -t subscribe -m '["window", "workspace"]' -r | while read -r event; do
    change=$(echo "$event" | jq -r '.change // empty')
    
    # Only act on focus and new window events
    case "$change" in
        focus|new|move) ;;
        *) continue ;;
    esac

    # Get focused container dimensions
    read w h floating fullscreen < <(swaymsg -t get_tree -r | jq -r '
        recurse(.nodes[]?, .floating_nodes[]?) |
        select(.focused == true) |
        "\(.rect.width) \(.rect.height) \(.type) \(.fullscreen_mode)"
    ' | head -1)

    # Skip floating, fullscreen, or missing
    [ -z "$w" ] && continue
    [ "$floating" = "floating_con" ] && continue
    [ "$fullscreen" = "1" ] && continue

    # Split along the longest axis
    if [ "$w" -gt "$h" ]; then
        swaymsg -q splith
    else
        swaymsg -q splitv
    fi
done
