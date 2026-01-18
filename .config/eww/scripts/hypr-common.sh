#!/bin/bash

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

export PYTHONUNBUFFERED=1  # not needed unless using Python
export stdbuf=-o0           # for utilities

listen_for_events() {
	local handler_func="$1" 
	socat -u "UNIX-CONNECT:$SOCKET" - | while IFS= read -r line; do
		"$handler_func" "$line"
	done
}

get_workspaces() {
    if echo "$1" | grep -q "workspace>>"; then
		workspaces=$(hyprctl workspaces -j)
		workspaceIDs=$(echo "$workspaces" | jq -rc '[.[].id] | sort')
		echo "$workspaceIDs"
	fi
}

get_focused_program() {
    local thisLine="$1"
    if echo "$thisLine" | grep -q "activewindow>>"; then
    
        clientFullTitle=$(sed -E 's/^activewindow>>//' <<< "$thisLine")
clientName=$(sed -E 's/^[^,]*,//' <<< "$clientFullTitle")
echo "$clientName"

    fi
}

get_focused_workspace() {
    local thisLine="$1"
    if echo "$thisLine" | grep -qE "workspace>>|focusedmon>>"; then
        focused_ws=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .activeWorkspace.id')
        echo "$focused_ws"
    fi
}

get_active_workspaces() {
    local thisLine="$1"
    # Trigger on workspace changes or monitor focus changes
    if echo "$thisLine" | grep -qE "workspace>>|focusedmon>>"; then
        # Get active workspace ID from each monitor
        activeIDs=$(hyprctl monitors -j | jq -rc '[.[].activeWorkspace.id] | sort')
        echo "$activeIDs"
		printf "" >&1
    fi
}
