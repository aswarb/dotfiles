#!/bin/bash

listen_for_events() {
    local handler_func="$1"
    swaymsg -t subscribe -m '["workspace", "window"]' -r | while IFS= read -r line; do
        "$handler_func" "$line"
    done
}

get_workspaces() {
    local thisLine="$1"
    local change=$(echo "$thisLine" | jq -r '.change // empty')
    case "$change" in
        init|empty|focus|move|rename)
            swaymsg -t get_workspaces -r | jq -rc '[.[].num] | sort'
            ;;
    esac
}

get_focused_program() {
    local thisLine="$1"
    local change=$(echo "$thisLine" | jq -r '.change // empty')
    if [ "$change" = "focus" ] || [ "$change" = "title" ] || [ "$change" = "new" ]; then
        local name=$(echo "$thisLine" | jq -r '.container.name // empty')
        if [ -n "$name" ]; then
            echo "$name"
        fi
    fi
}

get_focused_workspace() {
    local thisLine="$1"
    local change=$(echo "$thisLine" | jq -r '.change // empty')
    # Workspace focus events have .current.num
    local num=$(echo "$thisLine" | jq -r '.current.num // empty')
    if [ -n "$num" ]; then
        echo "$num"
    fi
}

get_active_workspaces() {
    local thisLine="$1"
    local change=$(echo "$thisLine" | jq -r '.change // empty')
    case "$change" in
        init|empty|focus|move|rename)
            swaymsg -t get_outputs -r | jq -rc '[.[].current_workspace | tonumber] | sort'
            ;;
    esac
}
