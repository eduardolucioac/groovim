#!/usr/bin/env bash
#
# Runs install.sh on a throwaway machine of each distribution, and says what
# came out.
#
# What this is for: install.sh has to work on a machine it has never seen, and
# the only honest way to know is to give it one. Every defect it has ever had
# was of that kind -- a package manager read off the NAME of the distribution
# instead of what was installed, a failed package step that ended everything, a
# flag that turned every optional feature into a requirement, and a link into a
# directory sudo does not search. Not one of them shows up on the machine it was
# written on.
#
# Each container is built to look like a machine somebody uses, and NOT like a
# container: a normal user, with sudo, who owns nothing of the system. A
# container out of the box runs as root with no sudo at all, which would skip
# the three things most likely to break -- installing packages, the sudoers
# secure_path, and writing into directories of your own.
#
# Usage:
#   ./tests/distros.sh                 every distribution below
#   ./tests/distros.sh debian fedora   only these
#   ./tests/distros.sh --battery       and run the 500-odd checks in each
#   ./tests/distros.sh --ssh           leave them up, each on its own ssh port
#   ./tests/distros.sh --stop          take down what --ssh left
#
# Without "--ssh" it leaves nothing behind: every container is removed when it
# ends. With it, each machine stays up with an sshd of its own so GrooVim can be
# used by hand -- over a real terminal, which is the only way to try the keys,
# the menu and the colours. The port is bound to 127.0.0.1, so what is listening
# is reachable from this machine and from nowhere else.

set -u

BASE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$BASE/.." && pwd)"

BATTERY=0
SSH=0
STOP=0
WANTED=()
for argument in "$@"; do
  case "$argument" in
    --battery) BATTERY=1 ;;
    --ssh)     SSH=1 ;;
    --stop)    STOP=1 ;;
    -h|--help) sed -n '2,26p' "$0" | sed 's/^#\( \|$\)//'; exit 0 ;;
    *) WANTED+=("$argument") ;;
  esac
done

RUNTIME=""
for candidate in podman docker; do
  if command -v "$candidate" >/dev/null 2>&1; then RUNTIME="$candidate"; break; fi
done
if [ -z "$RUNTIME" ]; then
  echo "There is no podman and no docker here. Install one of them:"
  echo "  arch:   sudo pacman -S podman"
  echo "  debian: sudo apt-get install podman"
  exit 1
fi

# The machines. Each line:
#
#   name|image|how to install sudo|the group that sudo trusts|the sshd package
#
# The bootstrap installs sudo and nothing else on purpose -- not even git. git
# is one of the build dependencies install.sh is supposed to put in by itself,
# and handing it over would hide whether it does. The sshd is the exception,
# and it goes in only under "--ssh", after the install has already run.
# The six GrooVim aims at, and nothing else: machines somebody sits at, on a
# desktop or in a VM. Anything built on one of them arrives here through its
# package manager, which is what install.sh actually looks at.
MACHINES="
debian|docker.io/library/debian:12|apt-get update -qq && apt-get install -y -qq sudo|sudo|apt-get install -y -qq openssh-server
ubuntu|docker.io/library/ubuntu:24.04|apt-get update -qq && apt-get install -y -qq sudo|sudo|apt-get install -y -qq openssh-server
fedora|docker.io/library/fedora:41|dnf install -y -q sudo|wheel|dnf install -y -q openssh-server
rocky|docker.io/library/rockylinux:9|dnf install -y -q sudo|wheel|dnf install -y -q openssh-server
arch|docker.io/library/archlinux:latest|pacman -Sy --noconfirm --quiet sudo|wheel|pacman -S --noconfirm --quiet openssh
opensuse|docker.io/opensuse/tumbleweed|zypper -n -q install sudo|wheel|zypper -n -q install openssh-server
"

# Colours, and only when someone is looking.
if [ -t 1 ]; then
  RED=$'\033[1;31m'; GREEN=$'\033[1;32m'; YELLOW=$'\033[1;33m'; BLUE=$'\033[1;34m'; OFF=$'\033[0m'
else
  RED=""; GREEN=""; YELLOW=""; BLUE=""; OFF=""
fi

# "--stop" only takes down what "--ssh" left, and does nothing else.
if [ "$STOP" -eq 1 ]; then
  gone=0
  for container in $($RUNTIME ps -a --format '{{.Names}}' 2>/dev/null | grep '^groovim-ssh-' || true); do
    $RUNTIME rm -f "$container" >/dev/null 2>&1 && gone=$((gone + 1))
    echo "  gone: $container"
  done
  [ "$gone" -eq 0 ] && echo "  there was nothing up."
  exit 0
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# The repository, without the git directory and without what a previous run
# left. This is what the container installs from.
tar -C "$REPO" --exclude=.git --exclude=tests/results -czf "$WORK/groovim.tgz" . || exit 1

# What runs INSIDE the container, once it has a user. Written once and used by
# every machine, because nothing in it is about a distribution -- which is the
# whole point of the exercise.
cat > "$WORK/inside.sh" <<'INSIDE'
#!/bin/sh
set -u
cd "$HOME" || exit 1
mkdir -p groovim && tar -C groovim -xzf /opt/groovim.tgz || exit 1
cd groovim || exit 1

echo "===> install"
./install.sh --yes
echo "[install ended with $?]"

echo "===> what came out"
if [ -x "$HOME/.local/bin/groovim" ]; then
  printf 'alfa\nbeta\n' > /tmp/t.txt
  PATH="$HOME/.local/bin:$PATH"
  if groovim -c 'normal Gdd' -c wq /tmp/t.txt >/dev/null 2>&1; then
    echo "edits a file: [$(tr '\n' '/' < /tmp/t.txt)]"
  else
    echo "edits a file: NO"
  fi
  echo "sudo finds it: $(sudo sh -c 'command -v groovim' 2>/dev/null || echo NO)"
  # Whole words, with "grep -x". An anchored "grep -o" reported "+clipboard"
  # and "-clipboard" at once on the same Vim, which cannot both be true: it was
  # matching the front of a longer word.
  echo "features: $("$HOME/.local/share/groovim/bin/vim" --version 2>/dev/null \
    | tr ' \t' '\n\n' | grep -xE '[+-](clipboard|popupwin|terminal|python3(/dyn)?|X11|xterm_clipboard)' \
    | sort -u | tr '\n' ' ')"
  echo "plugins: $(ls "$HOME/.groovim/pack/groovim/start" 2>/dev/null | tr '\n' ' ')"
else
  echo "there is no groovim command"
fi

if [ "${BATTERY:-0}" = "1" ]; then
  echo "===> battery"
  ./tests/run.sh 2>&1 | tail -3
fi

# Under "--ssh" the machine is going to be USED, so the checks above must not be
# the first thing its owner sees. GrooVim saves a session and brings it back, so
# the file this script edited came up on the first run -- with no opening screen,
# because Vim only draws one when it starts with no file. That looked like two
# defects and was only my own leftovers.
if [ "${SSH_MODE:-0}" = "1" ]; then
  rm -rf "$HOME/.groovim/session.vim" "$HOME/.groovim/undo" \
    "$HOME/.groovim/viminfo" /tmp/t.txt
  echo "===> state cleared: the first groovim here starts fresh"
fi
INSIDE
chmod +x "$WORK/inside.sh"

wanted() {
  [ "${#WANTED[@]}" -eq 0 ] && return 0
  local one
  for one in "${WANTED[@]}"; do [ "$one" = "$1" ] && return 0; done
  return 1
}

PORT=2200
printf '%s\n' "$MACHINES" | while IFS='|' read -r name image bootstrap group sshpkg; do
  [ -n "$name" ] || continue
  wanted "$name" || continue
  PORT=$((PORT + 1))

  echo
  echo "${BLUE}=== $name${OFF}   ($image)"

  # Under "--ssh" the name is stable, so that "--stop" can find it again, and a
  # port of its own is published -- on 127.0.0.1 only, so nothing of this is
  # reachable from the network.
  if [ "$SSH" -eq 1 ]; then
    container="groovim-ssh-$name"
    $RUNTIME rm -f "$container" >/dev/null 2>&1
    run_options="--name $container -p 127.0.0.1:$PORT:22"
  else
    container="groovim-test-$name-$$"
    run_options="--name $container"
  fi

  # shellcheck disable=SC2086
  if ! $RUNTIME run -d $run_options "$image" sleep infinity >/dev/null 2>&1; then
    echo "${RED}  could not start it -- is the image reachable?${OFF}"
    continue
  fi

  # A machine somebody uses: a normal user, in the group sudo trusts, who did
  # not install the system and cannot write outside their own home.
  if ! $RUNTIME exec "$container" sh -c "
    set -e
    $bootstrap >/dev/null 2>&1 || exit 1
    command -v groupadd >/dev/null && groupadd -f $group
    (command -v useradd >/dev/null && useradd -m -s /bin/sh -G $group groo) ||
      (command -v adduser >/dev/null && adduser -D -G $group groo) || exit 1
    mkdir -p /etc/sudoers.d
    echo 'groo ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/groo
    chmod 440 /etc/sudoers.d/groo
  " > "$WORK/bootstrap.log" 2>&1; then
    echo "${RED}  could not make a user with sudo on it:${OFF}"
    tail -6 "$WORK/bootstrap.log" | sed 's/^/    /' 
    $RUNTIME rm -f "$container" >/dev/null 2>&1
    continue
  fi

  $RUNTIME cp "$WORK/groovim.tgz" "$container:/opt/groovim.tgz" >/dev/null 2>&1
  $RUNTIME cp "$WORK/inside.sh" "$container:/opt/inside.sh" >/dev/null 2>&1

  $RUNTIME exec -e "BATTERY=$BATTERY" -e "SSH_MODE=$SSH" -u groo "$container" /opt/inside.sh 2>&1 \
    | sed 's/^/  /'

  if [ "$SSH" -eq 0 ]; then
    $RUNTIME rm -f "$container" >/dev/null 2>&1
    continue
  fi

  # An sshd, so that GrooVim can be used by hand. It goes in AFTER the install,
  # so that nothing it drags in can be mistaken for a dependency install.sh was
  # supposed to put there itself.
  if $RUNTIME exec "$container" sh -c "
    set -e
    $sshpkg >/dev/null 2>&1
    ssh-keygen -A >/dev/null 2>&1 || true
    mkdir -p /run/sshd /var/run/sshd
    echo 'groo:groovim' | chpasswd
    usermod -s /bin/bash groo 2>/dev/null || true
  " >/dev/null 2>&1 && $RUNTIME exec -d "$container" /usr/sbin/sshd -D >/dev/null 2>&1; then
    echo "${GREEN}  ssh is up on port $PORT${OFF}"
  else
    echo "${RED}  could not put an sshd on it${OFF}"
    continue
  fi
done

echo
if [ "$SSH" -eq 1 ]; then
  echo "The machines are up. GrooVim is installed on each, and \"groovim\" is on the"
  echo "PATH. The user is ${BLUE}groo${OFF}, the password is ${BLUE}groovim${OFF}:"
  echo
  $RUNTIME ps --format '{{.Names}} {{.Ports}}' 2>/dev/null | grep '^groovim-ssh-' \
    | while read -r container ports; do
        port="$(echo "$ports" | sed -n 's/.*:\([0-9]*\)->22.*/\1/p')"
        [ -n "$port" ] || continue
        printf '  %-10s ssh -p %s -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null groo@127.0.0.1\n' \
          "${container#groovim-ssh-}" "$port"
      done
  echo
  echo "  The two -o options are there because a machine that is thrown away and made"
  echo "  again has a new key every time, and ssh would refuse to talk to it."
  echo
  echo "  Take them all down with:  ./tests/distros.sh --stop"
else
  echo "Every container is gone. What to read above: the install has to end with 0,"
  echo "\"edits a file\" has to come back [alfa/], and \"sudo finds it\" has to name a"
  echo "path -- that last one is the secure_path, and it is the one that lies."
fi
