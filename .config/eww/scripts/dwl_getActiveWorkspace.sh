#!/bin/sh
# Tags currently displayed on some monitor -> [1,3]
. ~/.config/eww/scripts/dwl-common.sh
follow '
$2 == "tags" {
	sel[$1] = $4
	mask = 0
	for (m in sel) mask = or(mask, sel[m])
	out = "["
	for (i = 0; i < 9; i++)
		if (and(mask, lshift(1, i)))
			out = out (out == "[" ? "" : ",") (i + 1)
	out = out "]"
	if (out != last) { print out; fflush(); last = out }
}'
