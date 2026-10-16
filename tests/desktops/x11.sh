#!/bin/bash
# Inside the container: an X11 desktop, two windows, and the raise of GrooVim.
#
# Xvfb is the screen nobody looks at, and the window manager is the real one of
# the desktop being measured -- xfwm4 is Xfce, marco is MATE, muffin is
# Cinnamon. What is measured is not the manager: it is whether the window of
# the GrooVim comes back to the front when the command asks for it.
#
# Two instruments, and they agree or the run is worth nothing: "xdotool
# getactivewindow" asks the window manager which window is active, and the
# terminal of the first window writes down every focus it gains and loses.
set -u
export DISPLAY=:99
Xvfb :99 -screen 0 1280x800x24 >/dev/null 2>&1 &
sleep 2
$MANAGER >/tmp/wm.log 2>&1 &
sleep 3

xterm -title "WINDOW A" -e bash /opt/focus-log.sh /tmp/log.txt >/dev/null 2>&1 &
sleep 3
INSIDE_A="$(sed -n 's/^pid=//p' /tmp/log.txt)"
xterm -title "WINDOW B" -e sleep 25 >/dev/null 2>&1 &
sleep 3

echo "   window manager: $MANAGER"
echo "   active before:  [$(xdotool getactivewindow getwindowname 2>&1 | head -1)]"
. /opt/raise.sh
groovim_raise "$INSIDE_A"
echo "   groovim_raise:  $?"
sleep 2
echo "   active after:   [$(xdotool getactivewindow getwindowname 2>&1 | head -1)]"
echo "   what A saw:     $(grep -o '\[.*\] em [0-9]*s' /tmp/log.txt | tr '\n' ' ')"
