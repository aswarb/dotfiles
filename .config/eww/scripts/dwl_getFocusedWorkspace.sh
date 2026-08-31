#!/bin/sh
# Lowest tag displayed on the focused monitor -> 2
. ~/.config/eww/scripts/dwl-common.sh
follow '
$2 == "selmon" && $3 == 1 { focused = $1 }
$2 == "tags" {
	sel[$1] = $4
	if (focused != "" && focused in sel) {
		n = 0
		for (i = 0; i < 9; i++)
			if (and(sel[focused], lshift(1, i))) { n = i + 1; break }
		if (n && n != last) { print n; fflush(); last = n }
	}
}'
