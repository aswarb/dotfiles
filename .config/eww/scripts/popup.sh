#!/bin/sh
# Toggle one of the bar's popups, closing whichever other one is up.
#
# The buttons used to do this inline:
#
#   eww close calendar; eww update cal_open=false ctl_open=${!ctl_open}; eww open --toggle control
#
# Three independent client round-trips per click, and the two halves disagree
# about what "open" means: `--toggle` reads the daemon's real window list,
# while `update` flips a mirror variable that only the stylesheet ever looks
# at. Click faster than the panel can map and the calls from two clicks
# interleave -- the mirror ends up saying open while nothing is up, or the
# reverse. The button behaved like a switch loosely related to the panel
# rather than the panel's own switch.
#
# This is the single authority. One instance at a time, so clicks queue
# instead of racing; the decision is taken from the real window list, never
# from the mirror; and the mirror is written last, from what was actually
# done. It cannot drift, because nothing else decides anything.

set -eu

want=$1                       # calendar | control

lock="${XDG_RUNTIME_DIR:-/tmp}/eww-popup.lock"
exec 9>"$lock"
# Drop a click that lands while a previous one is still mid-flight, rather
# than queuing behind it. This was `-w 2` -- wait for the lock, then run
# anyway -- which is exactly backwards for a toggle: a click banked up during
# the first click's open/update round-trip still fires afterward, replaying
# a toggle decision made against state that has since moved on. That banked,
# stale toggle IS the flicker.
flock -n 9 || exit 0

# Get the focused monitor from the eww variable
focused_mon=$(eww get focusedMonitor 2>/dev/null || echo "0")

# Build the window names for this monitor
cal_win="calendar${focused_mon}"
ctl_win="control${focused_mon}"

all="${cal_win} ${ctl_win}"

# "id: name" per line; popups are opened without an id, so the two match.
# Joined with spaces (not left as newlines) because the membership checks
# below match on " name " -- against a newline-joined list that boundary
# never lands on a space, so the calendar/control case always missed and the
# script only ever opened, never closed.
open=$(eww active-windows | sed 's/^[^:]*: *//' | tr '\n' ' ')

case " $open " in
  *" ${want}${focused_mon} "*) target="" ;;   # it is up, so this click is the one that closes it
  *)           target="${want}${focused_mon}" ;;
esac

for w in $all; do
  case " $open " in *" $w "*) up=1 ;; *) up=0 ;; esac
  if [ "$w" = "$target" ]; then
    [ "$up" = 1 ] || eww open "$w"
  else
    [ "$up" = 0 ] || eww close "$w"
  fi
done

[ "$target" = "${cal_win}" ] && cal=true || cal=false
[ "$target" = "${ctl_win}"  ] && ctl=true || ctl=false
eww update "cal_open=$cal" "ctl_open=$ctl"