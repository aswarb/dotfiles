#!/bin/sh
# Focused monitor index from dwl's selmon event -> 0 | 1 | ...
. ~/.config/eww/scripts/dwl-common.sh
follow '
$2 == "selmon" && $3 == 1 {
    print $1
    fflush()
}'