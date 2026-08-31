#!/bin/sh
# Layout symbol of the focused monitor -> []=
# dwl prints selmon before layout within each monitor's block.
. ~/.config/eww/scripts/dwl-common.sh
follow '
$2 == "selmon" && $3 == 1 { focused = $1 }
$2 == "layout" && $1 == focused {
	if ($3 != last) { print $3; fflush(); last = $3 }
}'
