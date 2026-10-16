#!/bin/bash
# Inside the container: sway with its headless backend, two terminals, and the
# raise. sway answers which window has the focus, which is the instrument here.
set -u
export XDG_RUNTIME_DIR="/tmp/run-$(id -u)"
mkdir -p "$XDG_RUNTIME_DIR" && chmod 700 "$XDG_RUNTIME_DIR"
export WLR_BACKENDS=headless WLR_LIBINPUT_NO_DEVICES=1 WLR_RENDERER=pixman
echo "default_border none" > /tmp/sway.conf
sway --unsupported-gpu -c /tmp/sway.conf >/tmp/sway.log 2>&1 &
sleep 4
export SWAYSOCK="$(ls "$XDG_RUNTIME_DIR"/sway-ipc.* 2>/dev/null | head -1)"
[ -n "$SWAYSOCK" ] || { echo "   sway did not start:"; head -3 /tmp/sway.log; exit 1; }

focused() { swaymsg -t get_tree | jq -r '.. | objects | select(.focused == true) | .name' | head -1; }

swaymsg exec "foot -T WINDOW_A bash /opt/focus-log.sh /tmp/log.txt" >/dev/null 2>&1
sleep 3
INSIDE_A="$(sed -n 's/^pid=//p' /tmp/log.txt)"
swaymsg exec "foot -T WINDOW_B sleep 25" >/dev/null 2>&1
sleep 3

echo "   focused before: [$(focused)]"
. /opt/raise.sh
groovim_raise "$INSIDE_A"
echo "   groovim_raise:  $?"
sleep 2
echo "   focused after:  [$(focused)]"
