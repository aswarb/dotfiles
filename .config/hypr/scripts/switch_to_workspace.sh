#!/bin/sh

readonly SIGNAL_TRUE=0
readonly SIGNAL_FALSE=1

target=$1

MONITORS_JSON=$(hyprctl monitors -j)
WORKSPACES_JSON=$(hyprctl workspaces -j)

monitor_ids=( $(jq -r '.[].id' <<< "$MONITORS_JSON") )
# aWorkspace = active workspaces
aWorkspace_ids=( $(jq -r '.[].activeWorkspace.id' <<< "$MONITORS_JSON") )


function workspaceIsActive {
	for i in "${!monitor_ids[@]}"; do
		if [ "$1" -eq "${aWorkspace_ids[i]}" ]; then
			return $SIGNAL_TRUE  # Found
		fi
	done
	return $SIGNAL_FALSE  # Not found
}
function listContains {
	local list=$1
	local target=("$@")

	for i in "${!list[@]}"; do
		if [ "${target}" = "${list[i]}" ]; then
			return $SIGNAL_TRUE
		fi
	done
	return $SIGNAL_FALSE
}

function indexOf {
	local target=$1
	shift
	local list=("$@") 

	for i in "${!list[@]}"; do
		if [ "$target" = "${list[i]}" ]; then
			echo "$i"
			return $SIGNAL_TRUE
		fi
	done
	echo ""
	return $SIGNAL_FALSE
}

function countWorkspacesForMonitor {
	local target=$1
	echo $(jq  --argjson monId "$target" -r '[.[] | select(.monitorID == $monId)] | length' <<< "$WORKSPACES_JSON") 
}

function swapWorkspaces {
	local workspace_t1=$1
	local workspace_t2=$2

	local monitor_t1=$(jq --argjson workspaceId "$workspace_t1" -r '.[] | select(.activeWorkspace.id == $workspaceId) | .id' <<< $MONITORS_JSON)
	local monitor_t2=$(jq --argjson workspaceId "$workspace_t2" -r '.[] | select(.activeWorkspace.id == $workspaceId) | .id' <<< $MONITORS_JSON)
	
	echo "$monitor_t1" "$monitor_t2"
	hyprctl dispatch swapactiveworkspaces "$monitor_t1" "$monitor_t2"

	return $SIGNAL_FALSE
}

function moveWorkspaceToMonitor {
	hyprctl dispatch moveworkspacetomonitor "$1" "$2"
	return $SIGNAL_TRUE
}

function getActiveWorkspace {
	hyprctl activeworkspace -j | jq  '.id'
}

function getCurrentMonitor {
	hyprctl activeworkspace -j | jq  '.monitorID'
}

function switchToWorkspace {
	moveWorkspaceToMonitor "$1" ""
	hyprctl dispatch workspace $1;
	return $SIGNAL_TRUE
}

#echo ${aWorkspace_ids[@]}}
currentWorkspace=$(getActiveWorkspace)
currentMonitor=$(getCurrentMonitor)
cursorX=$(hyprctl cursorpos -j | jq '.x')
cursorY=$(hyprctl cursorpos -j | jq '.y')
#echo "currentMonitor" ${currentMonitor}
#echo "currentWorkspace" ${currentWorkspace}

echo "Target Workspace: " ${target}
echo "Current Workspace: " ${currentWorkspace}}
echo "Current Monitor: " ${currentMonitor}}
if workspaceIsActive "${target}"; then
	echo "Here1"
	swapWorkspaces "${target}" "${currentWorkspace}"
  #echo "Workspace ${target} is in use"
else
	echo "Here2"
	moveWorkspaceToMonitor "${target}" "${currentMonitor}"
	hyprctl dispatch workspace ${target}
  #echo "Workspace ${target} is NOT in use"
fi
echo "Trying to keep cursor at" "${cursorX}" "${cursorY}"
hyprctl dispatch movecursor ${cursorX} ${cursorY}


