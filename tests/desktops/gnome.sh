#!/bin/bash
# Inside the container: GNOME Shell as a nested Wayland server, two terminals of
# GNOME Console, and the raise.
#
# GNOME Shell tells nobody which window has the focus -- "Introspect.GetWindows"
# answers "GetWindows is not allowed" to an ordinary caller, measured -- so the
# instrument here is the same extension one of the roads uses: it lists the
# windows with a "focus" of their own. The road that USES it is taken out of the
# function for the second run, which is how the other road is measured alone.
set -u
export XDG_RUNTIME_DIR="/tmp/run-$(id -u)"
mkdir -p "$XDG_RUNTIME_DIR" && chmod 700 "$XDG_RUNTIME_DIR"
export DISPLAY=:99 LIBGL_ALWAYS_SOFTWARE=1
Xvfb :99 -screen 0 1280x800x24 >/dev/null 2>&1 &
sleep 2

dbus-run-session -- bash -c '
  gnome-shell --nested --wayland > /tmp/shell.log 2>&1 &
  sleep 18
  export WAYLAND_DISPLAY=wayland-0
  gnome-extensions enable window-calls@domandoman.xyz >/dev/null 2>&1
  sleep 2

  windows() {
    gdbus call --session --dest org.gnome.Shell \
      --object-path /org/gnome/Shell/Extensions/Windows \
      --method org.gnome.Shell.Extensions.Windows.List 2>/dev/null
  }
  focus_of() { windows | sed "s/},{/}\n{/g" | grep -o "\"id\":[0-9]*\|\"focus\":[a-z]*" | paste - -; }

  kgx -- bash /opt/focus-log.sh /tmp/A.txt >/dev/null 2>&1 &
  sleep 7
  INSIDE_A="$(sed -n "s/^pid=//p" /tmp/A.txt)"
  ID_A="$(windows | grep -o "\"id\":[0-9]*" | head -1 | cut -d: -f2)"
  # Note: The other window is of ANOTHER application on purpose. A terminal of
  # GNOME is one process for every window it has, so two of them would be one
  # pid with two windows -- and then "present the window of this application"
  # has two to choose from and no way of telling which is yours. With one
  # window of each, what each road does is readable.
  zenity --info --text="WINDOW B" --title=WINDOW_B >/dev/null 2>&1 &
  sleep 7
  ID_B="$(windows | sed "s/},{/}\n{/g" | grep -i zenity | grep -o "\"id\":[0-9]*" | head -1 | cut -d: -f2)"
  echo "   window A is $ID_A (the Console, where a GrooVim would be), B is $ID_B (another application)"

  gdbus call --session --dest org.gnome.Shell \
    --object-path /org/gnome/Shell/Extensions/Windows \
    --method org.gnome.Shell.Extensions.Windows.Activate "$ID_B" >/dev/null 2>&1
  sleep 2
  echo "   focus put on B:"; focus_of | sed "s/^/      /"

  echo "   --- with the extension installed (the road that matches by process)"
  . /opt/raise.sh
  groovim_raise "$INSIDE_A"; echo "      groovim_raise: $?"
  sleep 3; focus_of | sed "s/^/      /"

  gdbus call --session --dest org.gnome.Shell \
    --object-path /org/gnome/Shell/Extensions/Windows \
    --method org.gnome.Shell.Extensions.Windows.Activate "$ID_B" >/dev/null 2>&1
  sleep 2
  echo "   --- and with that road taken OUT: only the terminal asked to present itself"
  echo "   focus put back on B:"; focus_of | sed "s/^/      /"
  . /opt/raise-no-extension.sh
  groovim_raise "$INSIDE_A"; echo "      groovim_raise: $?"
  sleep 3; focus_of | sed "s/^/      /"
' 2>&1 | grep -vE "^dbus-daemon|WARNING|^$"
