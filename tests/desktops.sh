#!/usr/bin/env bash
#
# Runs the raise of GrooVim on a desktop of each kind, in a throwaway machine,
# and says what came out.
#
# What this is for: "groovim --jrinst" brings the GrooVim you already have open
# to the FRONT, and how a window is raised is the one thing that is different on
# every desktop. The machine this was written on runs KDE, so everything else
# was written from the interfaces it calls -- which is another way of saying
# nobody had seen it work. This gives each of them a machine.
#
# What is measured is never the message the command prints. It is the window
# manager itself, asked which window is active before and after, and the
# terminal of the first window, which writes down every focus it gains and
# loses. They have to agree.
#
# Usage:
#   ./tests/desktops.sh                 every desktop below
#   ./tests/desktops.sh xfce sway       only these
#   ./tests/desktops.sh --keep          leave the images behind for the next run
#
# The GNOME one is the slowest by far: a GNOME Shell of its own, nested inside a
# screen nobody looks at, and the extension that answers for it downloaded from
# extensions.gnome.org -- the released one, because the main branch of that
# extension throws "w is not defined" on GNOME 46 and raises nothing. Measured.
set -u

BASE="$(cd "$(dirname "$0")" && pwd)"
PIECES="$BASE/desktops"
KEEP=0
WANTED=()
for argument in "$@"; do
  case "$argument" in
    --keep) KEEP=1 ;;
    -h|--help) sed -n '2,26p' "$0" | sed 's/^#\( \|$\)//'; exit 0 ;;
    *) WANTED+=("$argument") ;;
  esac
done

RUNTIME=""
for candidate in podman docker; do
  command -v "$candidate" >/dev/null 2>&1 && { RUNTIME="$candidate"; break; }
done
[ -n "$RUNTIME" ] || { echo "There is no podman and no docker here."; exit 1; }

# The "groovim" command of this machine is where the raise lives, and the
# function is taken out of it whole -- what is measured is the code that is
# installed and not a copy of it written for the occasion.
COMMAND="${GROOVIM_COMMAND:-$HOME/.local/bin/groovim}"
[ -r "$COMMAND" ] || { echo "I cannot read $COMMAND -- install GrooVim first."; exit 1; }

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
sed -n '/^groovim_raise()/,/^}/p' "$COMMAND" > "$WORK/raise.sh"
[ -s "$WORK/raise.sh" ] || { echo "There is no groovim_raise() in $COMMAND."; exit 1; }

# The same function with the road of the GNOME extension taken out, which is how
# the road under it is measured on its own.
# The road after it is the X11 one, and its first line is what says the skipping
# is over. A marker taken from a NOTE drifts the day the note is reworded --
# measured, with the file ending in the middle of a function and the shell
# saying "unexpected end of file".
awk '
  /# Note: GNOME, through "Window Calls"/ { skipping = 1 }
  /DISPLAY:-/ { skipping = 0 }
  !skipping
' "$WORK/raise.sh" > "$WORK/raise-no-extension.sh"
bash -n "$WORK/raise-no-extension.sh" 2>/dev/null || {
  echo "The copy without the extension road does not parse -- the markers drifted."
  exit 1
}

cp "$PIECES"/focus-log.sh "$PIECES"/x11.sh "$PIECES"/sway.sh "$PIECES"/gnome.sh "$WORK/"

if [ -t 1 ]; then
  GREEN=$'\033[1;32m'; YELLOW=$'\033[1;33m'; BLUE=$'\033[1;34m'; OFF=$'\033[0m'
else
  GREEN=""; YELLOW=""; BLUE=""; OFF=""
fi

# name|what it is|the image to build|how to run it
DESKTOPS="
xfce|Xfce, through its own xfwm4|x11|MANAGER=xfwm4
mate|MATE, through marco|x11|MANAGER=marco
cinnamon|Cinnamon, through muffin|x11|MANAGER=muffin
metacity|the window manager of GNOME on X11|x11|MANAGER=metacity
sway|sway, on Wayland, with its headless backend|sway|
gnome|GNOME Shell 46, nested, on Wayland|gnome|
"

build_x11() {
  cat > "$WORK/Containerfile" <<'END'
FROM docker.io/library/debian:12
RUN apt-get update -qq && apt-get install -y -qq --no-install-recommends \
    xvfb xterm xdotool wmctrl procps ca-certificates dbus dbus-x11 \
    dconf-gsettings-backend xfwm4 xfconf metacity \
    marco mate-settings-daemon-common mate-control-center-common mate-desktop-common \
    muffin cinnamon-settings-daemon cinnamon-desktop-data \
    && rm -rf /var/lib/apt/lists/*
COPY focus-log.sh x11.sh raise.sh raise-no-extension.sh /opt/
RUN chmod +x /opt/*.sh
END
}

build_sway() {
  cat > "$WORK/Containerfile" <<'END'
FROM docker.io/library/debian:12
RUN apt-get update -qq && apt-get install -y -qq --no-install-recommends \
    sway foot jq procps ca-certificates dbus dbus-x11 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -s /bin/bash measurer
COPY focus-log.sh sway.sh raise.sh raise-no-extension.sh /opt/
RUN chmod +x /opt/*.sh
USER measurer
WORKDIR /home/measurer
END
}

build_gnome() {
  cat > "$WORK/Containerfile" <<'END'
FROM docker.io/library/ubuntu:24.04
ENV container=podman DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq && apt-get install -y -qq --no-install-recommends \
    systemd systemd-sysv dbus dbus-x11 \
    gnome-shell gnome-console zenity xvfb jq procps curl unzip ca-certificates \
    libgl1-mesa-dri \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -s /bin/bash measurer \
    && systemctl set-default multi-user.target
COPY focus-log.sh gnome.sh raise.sh raise-no-extension.sh /opt/
RUN chmod +x /opt/*.sh
CMD ["/sbin/init"]
END
}

ran=0
# Note: Line by line, and the loop is NOT on the other side of a pipe: what it
# counts has to be readable afterwards, and a pipe would count it in a shell of
# its own.
while IFS='|' read -r name what image how; do
  [ -n "$name" ] || continue
  if [ "${#WANTED[@]}" -gt 0 ]; then
    found=0
    for one in "${WANTED[@]}"; do [ "$one" = "$name" ] && found=1; done
    [ "$found" -eq 1 ] || continue
  fi

  printf '\n%s==> %s%s\n' "$BLUE" "$what" "$OFF"
  ran=$((ran + 1))

  "build_$image"
  if ! $RUNTIME build -t "groovim-desktop-$image" "$WORK" >/dev/null 2>&1; then
    printf '%s   the machine could not be built%s\n' "$YELLOW" "$OFF"
    continue
  fi

  # GNOME needs a machine with systemd running in it: gnome-shell asks logind
  # who is logged in and dies when nobody answers. Measured: "LoginManagerSystemd
  # ... Could not connect: No such file or directory", and the shell never
  # finished starting.
  if [ "$image" = "gnome" ]; then
    $RUNTIME rm -f groovim-desktop-gnome >/dev/null 2>&1
    $RUNTIME run -d --name groovim-desktop-gnome --systemd=always \
      "groovim-desktop-gnome" >/dev/null 2>&1
    sleep 10
    $RUNTIME exec -u measurer groovim-desktop-gnome bash -c '
      cd /tmp
      curl -s "https://extensions.gnome.org/extension-info/?uuid=window-calls@domandoman.xyz&shell_version=46" -o info.json
      url="$(grep -o "\"download_url\": *\"[^\"]*\"" info.json | cut -d\" -f4)"
      [ -n "$url" ] || exit 0
      curl -sL "https://extensions.gnome.org$url" -o wc.zip
      mkdir -p ~/.local/share/gnome-shell/extensions/window-calls@domandoman.xyz
      cd ~/.local/share/gnome-shell/extensions/window-calls@domandoman.xyz
      unzip -o -q /tmp/wc.zip' >/dev/null 2>&1
    $RUNTIME exec -u measurer groovim-desktop-gnome bash /opt/gnome.sh 2>&1 | sed 's/^/   /'
    $RUNTIME rm -f groovim-desktop-gnome >/dev/null 2>&1
  elif [ "$image" = "sway" ]; then
    $RUNTIME run --rm "groovim-desktop-$image" bash /opt/sway.sh 2>&1 | sed 's/^/   /'
  else
    $RUNTIME run --rm -e "$how" "groovim-desktop-$image" \
      dbus-run-session -- bash /opt/x11.sh 2>&1 | sed 's/^/   /'
  fi
done <<< "$DESKTOPS"

if [ "$KEEP" -eq 0 ]; then
  for image in x11 sway gnome; do
    $RUNTIME rmi -f "groovim-desktop-$image" >/dev/null 2>&1
  done
fi

[ "$ran" -eq 0 ] && { echo "Nothing to run. The names are: xfce mate cinnamon metacity sway gnome"; exit 1; }
printf '\n%sRead the two answers of each one: the window manager and the terminal have to agree.%s\n' "$GREEN" "$OFF"
