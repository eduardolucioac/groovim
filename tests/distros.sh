#!/usr/bin/env bash
#
# Runs install.sh on a throwaway machine of each distribution, and says what
# came out.
#
# What this is for: install.sh has to work on a machine it has never seen, and
# the only honest way to know is to give it one. A CentOS 7 killed it five times
# over -- the package manager read off the name of the distribution, a failed
# package step, a flag that turned every optional feature into a requirement,
# "git -C", and a link into a directory sudo does not search. None of those show
# up on the machine it was written on.
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
#
# It leaves nothing behind: every container is removed when it ends.

set -u

BASE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$BASE/.." && pwd)"

BATTERY=0
WANTED=()
for argument in "$@"; do
  case "$argument" in
    --battery) BATTERY=1 ;;
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
#   name|image|how to install sudo|the group that sudo trusts
#
# The bootstrap installs sudo and nothing else on purpose -- not even git. git
# is one of the build dependencies install.sh is supposed to put in by itself,
# and handing it over would hide whether it does.
# Alpine and Void are deliberately NOT here. Neither ships bash, and install.sh
# asks for it: they are bases to build containers on, not machines anybody sits
# at and edits a file on. Supporting them cost a temporary file and a loop where
# one line of bash had been, and carrying that shape for years to reach them is
# a worse trade than leaving them out.
MACHINES="
debian|docker.io/library/debian:12|apt-get update -qq && apt-get install -y -qq sudo|sudo
ubuntu|docker.io/library/ubuntu:24.04|apt-get update -qq && apt-get install -y -qq sudo|sudo
fedora|docker.io/library/fedora:41|dnf install -y -q sudo|wheel
rocky|docker.io/library/rockylinux:9|dnf install -y -q sudo|wheel
arch|docker.io/library/archlinux:latest|pacman -Sy --noconfirm --quiet sudo|wheel
opensuse|docker.io/opensuse/tumbleweed|zypper -n -q install sudo|wheel
"

# Colours, and only when someone is looking.
if [ -t 1 ]; then
  RED=$'\033[1;31m'; GREEN=$'\033[1;32m'; YELLOW=$'\033[1;33m'; BLUE=$'\033[1;34m'; OFF=$'\033[0m'
else
  RED=""; GREEN=""; YELLOW=""; BLUE=""; OFF=""
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
# Plain sh on purpose. Alpine ships no bash, and a harness written in bash
# cannot report that the script it is testing needs one.
set -u
cd "$HOME" || exit 1
mkdir -p groovim && tar -C groovim -xzf /opt/groovim.tgz || exit 1
cd groovim || exit 1

# install.sh asks for bash. Said here so that a machine without one explains
# itself instead of failing at a shebang.
if ! command -v bash >/dev/null 2>&1; then
  echo "===> there is no bash here, and install.sh asks for one"
  exit 0
fi

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
INSIDE
chmod +x "$WORK/inside.sh"

wanted() {
  [ "${#WANTED[@]}" -eq 0 ] && return 0
  local one
  for one in "${WANTED[@]}"; do [ "$one" = "$1" ] && return 0; done
  return 1
}

printf '%s\n' "$MACHINES" | while IFS='|' read -r name image bootstrap group; do
  [ -n "$name" ] || continue
  wanted "$name" || continue

  echo
  echo "${BLUE}=== $name${OFF}   ($image)"

  container="groovim-test-$name-$$"
  if ! $RUNTIME run -d --name "$container" "$image" sleep infinity >/dev/null 2>&1; then
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

  $RUNTIME exec -e "BATTERY=$BATTERY" -u groo "$container" /opt/inside.sh 2>&1 \
    | sed 's/^/  /'

  $RUNTIME rm -f "$container" >/dev/null 2>&1
done

echo
echo "Every container is gone. What to read above: the install has to end with 0,"
echo "\"edits a file\" has to come back [alfa/], and \"sudo finds it\" has to name a"
echo "path -- that last one is the secure_path, and it is the one that lies."
