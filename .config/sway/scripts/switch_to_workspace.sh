#!/bin/bash
target=$1
[ -z "$target" ] && exit 1

# Single IPC call, single jq invocation — extract everything we need at once
read current_monitor current_workspace target_output <<< $(swaymsg -t get_outputs -r | jq -r --arg t "$target" '
    (.[] | select(.focused==true) | .name) as $cm |
    (.[] | select(.focused==true) | .current_workspace) as $cw |
    ((.[] | select(.current_workspace == $t) | .name) // "none") as $to |
    "\($cm) \($cw) \($to)"
')

[ "$current_workspace" = "$target" ] && exit 0

if [ "$target_output" != "none" ]; then
    # Target is visible on another monitor — swap
    swaymsg "move workspace to output $target_output; [workspace=$target] move workspace to output $current_monitor"
else
    # Target not visible — check if it exists
    ws_exists=$(swaymsg -t get_workspaces -r | jq --arg t "$target" '[.[] | select(.name == $t)] | length')
    if [ "$ws_exists" -gt 0 ]; then
        swaymsg "[workspace=$target] move workspace to output $current_monitor; workspace $target"
    else
        swaymsg "focus output $current_monitor; workspace $target"
    fi
fi
