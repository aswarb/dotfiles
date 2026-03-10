#!/bin/bash
LOCKFILE="/tmp/niri-ws.lock"
exec 9>"$LOCKFILE"
flock -n 9 || exit 0
TARGET="$1"
CURRENT_OUTPUT=$(niri msg --json focused-output | jq -r '.name')
WS=$(niri msg --json workspaces | jq -r ".[] | select(.name == \"$TARGET\")")
if [ -n "$WS" ]; then
    WS_FOCUSED=$(echo "$WS" | jq -r '.is_focused')
    
    if [ "$WS_FOCUSED" = "true" ]; then
        exit 0
    fi
    
    WS_OUTPUT=$(echo "$WS" | jq -r '.output')
    WS_ACTIVE=$(echo "$WS" | jq -r '.is_active')
    
    if [ "$WS_OUTPUT" = "$CURRENT_OUTPUT" ]; then
        printf '%s\n' \
            "{\"Action\":{\"FocusWorkspace\":{\"reference\":{\"Name\":\"$TARGET\"}}}}" \
            | socat STDIO "$NIRI_SOCKET"
    elif [ "$WS_ACTIVE" = "true" ]; then
        # Target is actively displayed on the other monitor — swap
        CURRENT_WS_NAME=$(niri msg --json workspaces | jq -r ".[] | select(.output == \"$CURRENT_OUTPUT\" and .is_active == true) | .name")
        
        printf '%s\n%s\n%s\n' \
            "{\"Action\":{\"FocusMonitor\":{\"output\":\"$WS_OUTPUT\"}}}" \
            "{\"Action\":{\"FocusWorkspace\":{\"reference\":{\"Name\":\"$TARGET\"}}}}" \
            "{\"Action\":{\"MoveWorkspaceToMonitor\":{\"output\":\"$CURRENT_OUTPUT\",\"reference\":null}}}" \
            | socat STDIO "$NIRI_SOCKET"
        
        if [ -n "$CURRENT_WS_NAME" ] && [ "$CURRENT_WS_NAME" != "null" ]; then
            printf '%s\n%s\n%s\n' \
                "{\"Action\":{\"FocusMonitor\":{\"output\":\"$CURRENT_OUTPUT\"}}}" \
                "{\"Action\":{\"FocusWorkspace\":{\"reference\":{\"Name\":\"$CURRENT_WS_NAME\"}}}}" \
                "{\"Action\":{\"MoveWorkspaceToMonitor\":{\"output\":\"$WS_OUTPUT\",\"reference\":null}}}" \
                | socat STDIO "$NIRI_SOCKET"
        fi
        
        printf '%s\n%s\n' \
            "{\"Action\":{\"FocusMonitor\":{\"output\":\"$CURRENT_OUTPUT\"}}}" \
            "{\"Action\":{\"FocusWorkspace\":{\"reference\":{\"Name\":\"$TARGET\"}}}}" \
            | socat STDIO "$NIRI_SOCKET"
    else
        # Target is inactive on the other monitor — just move it, no swap
        printf '%s\n%s\n%s\n%s\n' \
            "{\"Action\":{\"FocusMonitor\":{\"output\":\"$WS_OUTPUT\"}}}" \
            "{\"Action\":{\"FocusWorkspace\":{\"reference\":{\"Name\":\"$TARGET\"}}}}" \
            "{\"Action\":{\"MoveWorkspaceToMonitor\":{\"output\":\"$CURRENT_OUTPUT\",\"reference\":null}}}" \
            "{\"Action\":{\"FocusMonitor\":{\"output\":\"$CURRENT_OUTPUT\"}}}" \
            | socat STDIO "$NIRI_SOCKET"
    fi
else
    MAX_IDX=$(niri msg --json workspaces | jq "[.[] | select(.output == \"$CURRENT_OUTPUT\") | .idx] | max")
    printf '%s\n%s\n' \
        "{\"Action\":{\"FocusWorkspace\":{\"reference\":{\"Index\":$MAX_IDX}}}}" \
        "{\"Action\":{\"SetWorkspaceName\":{\"name\":\"$TARGET\",\"reference\":null}}}" \
        | socat STDIO "$NIRI_SOCKET"
fi
