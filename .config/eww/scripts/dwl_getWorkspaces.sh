#!/bin/sh
# Tags that exist anywhere: occupied or currently displayed -> [1,2,5]
. ~/.config/eww/scripts/dwl-common.sh
follow '
$2 == "tags" {
	occ[$1] = $3; sel[$1] = $4
	mask = 0
	for (m in occ) mask = or(mask, or(occ[m], sel[m]))
	out = "["
	for (i = 0; i < 9; i++)
		if (and(mask, lshift(1, i)))
			out = out (out == "[" ? "" : ",") (i + 1)
	out = out "]"
	if (out != last) { print out; fflush(); last = out }
}'
