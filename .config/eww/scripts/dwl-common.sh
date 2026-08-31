#!/bin/sh
# Shared bits for the dwl_* eww listeners.
#
# dwl serves its status on a unix socket (see setupipc() in dwl.c). On connect
# it replays the current snapshot, then streams every subsequent change, so a
# listener is correct immediately regardless of start order. Per monitor:
#   <output> title <title>
#   <output> appid <appid>
#   <output> fullscreen <0|1>
#   <output> floating <0|1>
#   <output> selmon <0|1>
#   <output> tags <occupied> <selected> <client-tags> <urgent>
#   <output> layout <symbol>
# The masks are bitfields over 9 tags.

DWL_SOCK="${DWL_SOCK:-${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/dwl-${WAYLAND_DISPLAY:-wayland-0}.sock}"

# retry covers eww starting before dwl has bound the socket
follow() {
	exec socat -u "UNIX-CONNECT:$DWL_SOCK,retry=30,interval=1" - 2>/dev/null | gawk "$1"
}
