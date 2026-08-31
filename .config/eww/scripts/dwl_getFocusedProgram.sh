#!/bin/sh
# Title of the focused client on the focused monitor
. ~/.config/eww/scripts/dwl-common.sh
follow '
$2 == "title" {
	title[$1] = (NF > 2) ? substr($0, index($0, " title ") + 7) : ""
}
$2 == "selmon" && $3 == 1 {
	t = title[$1]
	if (t != last) { print t; fflush(); last = t }
}'
