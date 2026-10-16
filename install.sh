#!/usr/bin/env bash
#
# Needs bash, and says so on purpose. It was written in plain sh for a while, to
# reach machines that ship none, and the price was a temporary file and a "while
# read" loop where one line of bash had been. Every distribution GrooVim aims at
# has bash, and a shape carried for years costs more than what it reaches.
#
# Installs GrooVim: a Vim of its own, the GrooVim that runs on it, and the
# "groovim" command that reaches the two.
#
#   ./install.sh                installs, or brings an installation up to date
#   ./install.sh --rebuild      builds the Vim again even if the one there serves
#   ./install.sh --uninstall    takes GrooVim out again
#   ./install.sh --help         every option
#
# Run it again whenever you want: it builds the Vim only if the one it finds does
# not serve, and everything else it does is simply done again.
#
# Why a Vim of its own: GrooVim leans on things a distribution build often
# leaves out. The Vim shipped by CachyOS, to name the one this was written on,
# comes with "-clipboard -X11 -wayland" -- copying to the system clipboard only
# works there through a cascade of workarounds. Building once removes the
# question of what the user happens to have.
#
# It does NOT touch the Vim of the system. Everything lands under a prefix of
# its own, and "groovim" is what reaches it. Your "vim" stays yours.

# No "pipefail" on purpose. Reading a Vim with "vim --version | head -1" makes
# Vim die of SIGPIPE when head closes the pipe, and with "pipefail" that kills
# the whole script -- AFTER it has already printed the line, so it looks like it
# simply stopped for no reason. Measured: exit 141 right after the first version
# line. Every command whose failure matters is checked on its own.
set -eu

# ---------------------------------------------------------------- defaults ---

PREFIX="${GROOVIM_PREFIX:-$HOME/.local/share/groovim}"
BINDIR="${GROOVIM_BINDIR:-$HOME/.local/bin}"
SOURCE="${GROOVIM_SOURCE:-$HOME/.cache/groovim/vim}"
VERSION=""
VIMRC=""
ASSUME_YES=0
SKIP_DEPS=0
JOBS="$(nproc 2>/dev/null || echo 2)"
# Who this build says modified it. Vim prints it on the opening screen and in
# ":version", under "Modified by".
MODIFIED_BY="${GROOVIM_MODIFIED_BY:-Questor the Elf (eduardolucioac)}"
# The home of GrooVim: where its code is installed, and where it keeps its
# plugins, its session, its saved options, its undo and its viminfo.
GROOVIM_HOME_DIR="${GROOVIM_HOME:-$HOME/.groovim}"
# Where a link goes so that "sudo groovim" finds the command. This is the first
# choice, not the answer: sudo is asked where it really looks, because not every
# distribution keeps this directory in its "secure_path" -- Rocky and openSUSE
# do not.
SYSTEM_LINK_DIR="${GROOVIM_SYSTEM_BINDIR:-/usr/local/bin}"
SYSTEM_LINK=1
PLUGINS=1

# Where a desktop looks for what it can open and for the pictures of it. The
# user's own directories and not the ones of the system: GrooVim installs itself
# for whoever runs this, and asks for no password to do it.
APPS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
ICONS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor"
DESKTOP=1

# Taking it out again, and whether what you WROTE goes with it.
UNINSTALL=0
PURGE=0

# The plugins GrooVim uses, and what each one is for. They were never installed
# by this script, and the README asked you to clone them by hand -- so a machine
# that had only run install.sh had a F4->n that called into nothing.
#
# Only these names are touched. Anything else of yours in the same directory is
# left where it is.
#
# A RELEASE goes in, and not whatever the default branch of each one happens to
# be on the day you install. It is the same rule the Vim above is built by: the
# series is pinned and the newest release INSIDE it is the one taken, so a fix
# arrives on its own and a new major -- which is where a plugin changes the
# commands GrooVim drives it by -- does not arrive behind your back. A machine
# installed today and one installed next year get the same editor.
#
# Each line: name|where it comes from|the series|what it is for
GROOVIM_PLUGINS="
nerdtree|https://github.com/preservim/nerdtree.git|7|the file tree of F4->n
tcomment_vim|https://github.com/tomtom/tcomment_vim.git|4|the comment toggle, which Vim has no command of its own for
vim-move|https://github.com/matze/vim-move.git|v1|moving a line or a selection up and down
"

# What GrooVim used to install and does not any more.
GROOVIM_PLUGINS_GONE="vim-bookmarks"
# Building takes minutes. An installation that is already there and serves is not
# built again unless you say so.
REBUILD=0

# Where the battery landed, when it was copied: the last step says so.
TESTS_HERE=""

HERE="$(cd "$(dirname "$0")" && pwd)"

# What GrooVim needs from the Vim it runs on. Measured, not guessed: each line
# is a feature some part of GrooVim calls, with the release that brought it.
# 9.2, and the clipboard is what asks for it: "v:clipproviders", "clipmethod",
# ":clipreset" and the "osc52" package all arrived in it. The indent guides need
# only 9.0 ("leadmultispace"), which used to be the number here.
readonly MINIMUM_VERSION=902

# ------------------------------------------------------------------ output ---

blue()   { printf '\033[1;34m%s\033[0m\n' "$*"; }
green()  { printf '\033[1;32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[1;33m%s\033[0m\n' "$*"; }
red()    { printf '\033[1;31m%s\033[0m\n' "$*" >&2; }
step()   { printf '\n\033[1;34m==>\033[0m \033[1m%s\033[0m\n' "$*"; }

die() { red "$*"; exit 1; }

ask() {
  # ask "text" -> 0 when yes
  [ "$ASSUME_YES" -eq 1 ] && return 0
  local answer
  printf '%s [y/N] ' "$1"
  # Note: With no terminal to ask -- a run from a script, from a pipe -- the
  # answer is NO and the shell says nothing about it. The error of a /dev/tty
  # that is not there is noise in the middle of an answer.
  read -r answer </dev/tty 2>/dev/null || { echo; return 1; }
  [[ "$answer" =~ ^[yY]$ ]]
}

usage() {
  # The block of comment at the top, and only it: reading up to a fixed line
  # number leaked code into the help the moment the header grew.
  awk 'NR>2 && /^#/ {sub(/^# ?/, ""); print; next} NR>2 {exit}' "$0"
  cat <<'END'

Options:
  --version TAG      Vim tag to build (default: the newest release)
  --prefix DIR       where Vim goes      (default: ~/.local/share/groovim)
  --bindir DIR       where "groovim" goes(default: ~/.local/bin)
  --vimrc FILE       which .vimrc it runs(default: the one next to this script)
  --jobs N           parallel compilation (default: as many as you have cores)
  --modified-by NAME who this build says modified it, shown on the opening
                     screen and in ":version"
  --home DIR         where GrooVim lives      (default: ~/.groovim)
  --no-system-link   do not offer to link the command where sudo looks, which
                     is what makes "sudo groovim" find it
  --rebuild          build the Vim again even if the one installed already serves
  --no-deps          do not install build dependencies
  --no-plugins       do not install the plugins GrooVim uses. What depends on
                     one then says so instead of running
  --no-desktop       do not install the menu entry and the icons
  --uninstall        take GrooVim out: the command, the Vim it built, the menu
                     entry and the icons. What you chose and wrote -- the
                     options, the session, the marked lines, the plugins -- is
                     asked about, and kept unless you say otherwise
  --purge            with --uninstall, take that too, without asking
  --yes              answer yes to everything
  --help             this

Environment: GROOVIM_PREFIX, GROOVIM_BINDIR, GROOVIM_SOURCE, GROOVIM_MODIFIED_BY
GROOVIM_HOME and GROOVIM_SYSTEM_BINDIR do the same as the options of the same
name.
END
}

# ----------------------------------------------------------------- options ---

while [ $# -gt 0 ]; do
  case "$1" in
    --version)   VERSION="${2:?--version needs a tag}"; shift ;;
    --prefix)    PREFIX="${2:?--prefix needs a directory}"; shift ;;
    --bindir)    BINDIR="${2:?--bindir needs a directory}"; shift ;;
    --vimrc)     VIMRC="${2:?--vimrc needs a file}"; shift ;;
    --jobs)      JOBS="${2:?--jobs needs a number}"; shift ;;
    --modified-by) MODIFIED_BY="${2:?--modified-by needs a name}"; shift ;;
    --home)      GROOVIM_HOME_DIR="${2:?--home needs a directory}"; shift ;;
    --no-system-link) SYSTEM_LINK=0 ;;
    --rebuild)   REBUILD=1 ;;
    --no-deps)   SKIP_DEPS=1 ;;
    --no-plugins) PLUGINS=0 ;;
    --no-desktop) DESKTOP=0 ;;
    --uninstall) UNINSTALL=1 ;;
    --purge)     PURGE=1 ;;
    --yes|-y)    ASSUME_YES=1 ;;
    --help|-h)   usage; exit 0 ;;
    *)           die "I do not know the option \"$1\". Try --help." ;;
  esac
  shift
done

[ -n "$VIMRC" ] || VIMRC="$HERE/.vimrc"

# ------------------------------------------------------- what a Vim is worth ---

# The first line of "vim --version", without a pipe that can kill Vim with
# SIGPIPE on the way.
version_first_line() {
  "$1" --version 2>/dev/null | sed -n '1p'
}

# Every "+feature"/"-feature" of a Vim, one per line.
vim_features() {
  "$1" --version 2>/dev/null | tr ' ' '\n' | grep -E '^[+-][a-z_0-9]+$' || true
}

# Prints what is missing for GrooVim, one per line. Silence means it serves.
missing_for_groovim() {
  local vim_bin="$1"
  local version feature

  if ! "$vim_bin" --version >/dev/null 2>&1; then
    echo "it does not even run"
    return
  fi

  # 900 is Vim 9.0. "v:versionlong" would be finer, but this is enough and
  # works on the old ones we are refusing anyway.
  version="$(version_first_line "$vim_bin" | grep -oE '[0-9]+\.[0-9]+' | sed -n '1p' | tr -d '.')"
  version="${version:-0}"
  [ "${#version}" -eq 2 ] && version="${version}0"
  if [ "$version" -lt "$MINIMUM_VERSION" ]; then
    echo "Vim $version, and GrooVim asks for $MINIMUM_VERSION or newer (the clipboard uses the providers of 9.2)"
  fi

  local every_one
  every_one="$(vim_features "$vim_bin")"
  for feature in clipboard popupwin terminal; do
    if printf '%s\n' "$every_one" | grep -qx -- "-$feature"; then
      case "$feature" in
        # Not a failure of the build: "+clipboard" is only defined when the
        # machine that BUILT it had the headers of X11 or the client library of
        # Wayland -- read in "feature.h", FEAT_XCLIPBOARD asks for HAVE_X11 and
        # FEAT_WAYLAND_CLIPBOARD for HAVE_WAYLAND, and both of those are written
        # by configure out of what it found. A headless server has neither, and
        # a Vim built there comes out short of the feature no matter who builds
        # it. GrooVim goes on working: the clipboard provider it uses needs only
        # "+eval", so OSC 52 carries the copy through the terminal.
        clipboard) echo "-clipboard: the copy goes out through OSC 52 instead (nothing to install; pasting from another application is what you lose)" ;;
        popupwin)  echo "-popupwin: no native menus" ;;
        terminal)  echo "-terminal: no terminal inside the editor" ;;
      esac
    fi
  done
}


# --------------------------------------------------------------- distros ---

# The build dependencies of Vim, for the distributions GrooVim aims at: Debian,
# Ubuntu, Fedora, Rocky, Arch and openSUSE, and whatever is built on them.
#
# The manager is whichever one is INSTALLED, and not whichever one the name of
# the distribution suggests. This used to read /etc/os-release and map the
# family to a command, which is wrong in both directions: a machine can call
# itself one thing and carry another manager, and a derivative nobody has heard
# of has a name no list will ever have. Asking the machine what it HAS cannot be
# wrong that way, and there is no list of names to keep up to date.
#
# The manager also decides the NAMES of the packages, because each one carries
# exactly one naming scheme. So this single question answers both.
#
# A machine with none of these says so and offers to go on: GrooVim does not
# need to install anything to be installed, only to find the headers already
# there.
#
# Each line: manager|command to install|packages
distro_dependencies() {
  local recipe
  # The order matters only inside a family: Debian has both "apt" and
  # "apt-get", and a distribution can keep an old name aliased to a new
  # manager. First one wins.
  for recipe in \
    "pacman|sudo pacman -S --needed --noconfirm|base-devel ncurses libx11 libxt python git findutils" \
    "apt-get|sudo apt-get install -y|build-essential libncurses-dev libx11-dev libxt-dev python3-dev git findutils" \
    "apt|sudo apt install -y|build-essential libncurses-dev libx11-dev libxt-dev python3-dev git findutils" \
    "dnf|sudo dnf install -y|gcc make ncurses-devel libX11-devel libXt-devel python3-devel git findutils" \
    "zypper|sudo zypper install -y|gcc make ncurses-devel libX11-devel libXt-devel python3-devel git findutils" \
  ; do
    if command -v "${recipe%%|*}" >/dev/null 2>&1; then
      echo "$recipe"
      return 0
    fi
  done
  echo ""
}

install_dependencies() {
  local recipe manager command packages package missing

  step "Build dependencies"

  if [ "$SKIP_DEPS" -eq 1 ]; then
    yellow "  skipped by --no-deps"
    return 0
  fi

  recipe="$(distro_dependencies)"
  if [ -z "$recipe" ]; then
    yellow "  I do not know this distribution. Install by hand:"
    echo "    a C compiler, make, git, and the development headers of"
    echo "    ncurses, libX11, libXt and python3"
    ask "  Go on anyway?" || exit 1
    return 0
  fi

  manager="${recipe%%|*}"
  command="$(echo "$recipe" | cut -d'|' -f2)"
  packages="${recipe##*|}"

  echo "  this machine installs things with $manager"
  echo "  $command $packages"
  if ! ask "  Run it? (it asks for your password)"; then
    yellow "  not installing. If the build fails, this is the first place to look."
    return 0
  fi

  # A package step that fails does NOT end the install. The packages are a
  # convenience: the machine may have the headers already, and what is really
  # missing says so a minute later in the words of configure, which are far
  # more precise than the ones of a package manager. A machine whose
  # repositories answer nothing -- behind a proxy, offline, or simply older
  # than its mirrors -- reaches the build this way and only then says what it
  # could not find.
  # shellcheck disable=SC2086
  if $command $packages; then
    return 0
  fi

  # One name that does not exist, or one that its own distribution cannot
  # resolve today, must not take the other five with it. Measured: a machine
  # where the headers of Xt would not install while every other package went
  # in, and the whole build was lost over the one that did not matter.
  yellow "  the whole list did not go in. Trying one at a time:"
  missing=""
  for package in $packages; do
    # shellcheck disable=SC2086
    if $command $package >/dev/null 2>&1; then
      green "    $package"
    else
      missing="$missing $package"
      yellow "    $package -- no"
    fi
  done

  if [ -n "$missing" ]; then
    echo
    yellow "  these did not go in:$missing"
    echo "    Of them, only the headers of ncurses stop the build; the rest just"
    echo "    take features away. Going on is worth it -- configure names exactly"
    echo "    what it cannot find, and it may find everything."
    ask "  Go on?" || exit 1
  fi
}

# The plain commands the build reaches for -- not the libraries, which are the
# packages above, but the tools the Makefile of Vim runs.
#
# Asked BEFORE the build because of what a minimal openSUSE cost: its image has
# no "find", and nothing said so until "make install", four minutes in, where
# the only clue was "chmod: missing operand after '755'". Two seconds here
# instead of four minutes there.
check_the_tools() {
  local tool missing

  step "Tools"

  missing=""
  for tool in git make find sed grep awk tar; do
    command -v "$tool" >/dev/null 2>&1 || missing="$missing $tool"
  done
  command -v cc >/dev/null 2>&1 || command -v gcc >/dev/null 2>&1 ||
    missing="$missing a-C-compiler"

  if [ -z "$missing" ]; then
    green "  git, make, find, a compiler and the usual text tools are all here"
    return 0
  fi

  yellow "  these are not here:$missing"
  echo "    The build uses every one of them, and the error it gives when one is"
  echo "    missing says nothing about which. Install them and run this again."
  ask "  Go on anyway?" || exit 1
}

# ------------------------------------------------------------- our own name ---

# The first line of the screen Vim shows when it opens with no file.
#
# A patch on the source, because Vim has no flag for it: "--with-modified-by"
# ADDS a line, it does not change this one. Applied to a freshly checked-out
# tree on every build, so it never stacks up.
readonly SPLASH_FROM='N_("VIM - Vi IMproved"),'
readonly SPLASH_TO="N_(\"GrooVim - Vi IMproved'n'GrooVIed!\"),"

brand_the_splash() {
  local file="$SOURCE/src/version.c"

  step "Our name on the opening screen"
  [ -f "$file" ] || die "There is no $file. Did the download work?"

  if grep -qF "GrooVim - Vi IMproved" "$file"; then
    green "  already there"
    return 0
  fi
  if ! grep -qF -- "$SPLASH_FROM" "$file"; then
    die "I cannot find the line to change in src/version.c -- Vim may have reworded it.
     Looking for: $SPLASH_FROM"
  fi

  sed -i "s|$SPLASH_FROM|$SPLASH_TO|" "$file"
  grep -qF "GrooVim - Vi IMproved" "$file" || die "The change to src/version.c did not take."
  green "  $SPLASH_TO"
}

# ------------------------------------------------------------------ build ---

latest_version() {
  git ls-remote --tags --refs https://github.com/vim/vim.git \
    | awk -F/ '{print $NF}' | grep -E '^v?9\.[0-9]+\.[0-9]+$' \
    | sort -V | tail -1
}

fetch_source() {
  step "Vim source"

  if [ -z "$VERSION" ]; then
    echo "  looking for the newest release..."
    VERSION="$(latest_version)"
    [ -n "$VERSION" ] || die "I could not find the tags of Vim. Is there network?"
  fi
  echo "  version $VERSION"

  mkdir -p "$(dirname "$SOURCE")"
  if [ -d "$SOURCE/.git" ]; then
    echo "  reusing $SOURCE"
    # Throw away what the last build changed -- our own patch to version.c
    # included -- so every build starts from what upstream actually released.
    #
    # Grouped in a subshell so that the three are one thing: a failure in any
    # of them stops the rest and says so, and the "cd" cannot leak into what
    # runs after it.
    (
      cd "$SOURCE" || exit 1
      git checkout -q -- .
      git fetch --depth 1 origin "refs/tags/$VERSION:refs/tags/$VERSION" 2>/dev/null || true
      git checkout -q "$VERSION"
    ) || die "I could not put $SOURCE on $VERSION."
  else
    echo "  cloning into $SOURCE"
    git clone --depth 1 --branch "$VERSION" https://github.com/vim/vim.git "$SOURCE"
  fi
}

# Is a usable X here? Both headers, because they come from two packages and a
# machine can have one without the other.
#
# This is not about preferring X. "--with-x" is a DEMAND: configure stops with
# "could not configure X" when it is given and X is not all there, and that
# contradicts what this script tells the user two steps earlier -- that only the
# headers of ncurses stop a build. Measured on a machine where the headers of
# Xt refused to install while those of X11 went in: half an X killed the whole
# thing. It is also the case of a server with no X at all.
have_x() {
  local dir
  for dir in /usr/include /usr/local/include; do
    if [ -f "$dir/X11/Xlib.h" ] && [ -f "$dir/X11/Intrinsic.h" ]; then
      return 0
    fi
  done
  return 1
}

# Only the flags this source actually offers. Asking "./configure --help" is
# what keeps the script from ageing: a flag that is renamed upstream simply
# stops being used, instead of breaking the build.
available_flags() {
  local configure_help="$1"
  local flags=(
    --with-features=huge
    --enable-multibyte
    --enable-terminal
    --enable-cscope
  )
  # No "--enable-fail-if-missing". It contradicts the list below: it turns
  # every one of these into a requirement, and the whole point of them is that
  # GrooVim takes what the machine has. Measured: a machine with no python3
  # stopped here with "could not configure python3" -- a headless server, where
  # there is no X and no Wayland either, and none of that should stop a terminal
  # Vim from being built.
  #
  # Nothing is lost by dropping it: "What came out" at the end reads the
  # features out of the Vim that was actually built and names every one that
  # is short. The report tells the truth either way; this only decides whether
  # there is a Vim to report on.
  local optional
  for optional in \
      --enable-python3interp=dynamic \
      --enable-clipboard \
      --with-x \
      --enable-xim \
      --enable-wayland \
      --enable-waylandclipboard \
      "--with-modified-by=$MODIFIED_BY"
  do
    # The flags that need an X to exist are left out when there is none: see
    # have_x above. Everything else only has to be a flag this source knows.
    case "$optional" in
      --with-x|--enable-xim) have_x || continue ;;
    esac
    if grep -q -- "${optional%%=*}" "$configure_help"; then
      flags+=("$optional")
    fi
  done
  printf '%s\n' "${flags[@]}"
}

build_vim() {
  local configure_help flags

  step "Building"
  cd "$SOURCE"

  configure_help="$(mktemp)"
  ./configure --help > "$configure_help" 2>&1 || true
  # An array, and the quotes around it, are what keep the spaces inside
  # "--with-modified-by=Questor the Elf (eduardolucioac)" together instead of
  # turning one flag into four.
  mapfile -t flags < <(available_flags "$configure_help")
  rm -f "$configure_help"

  echo "  prefix: $PREFIX"
  echo "  flags:"
  printf '    %s\n' "${flags[@]}"

  make distclean >/dev/null 2>&1 || true
  ./configure --prefix="$PREFIX" "${flags[@]}"

  echo "  compiling with $JOBS jobs..."
  make -j"$JOBS"
  make install
}

# ------------------------------------------------------------ the GrooVim ---

# Note: The code of GrooVim goes where GrooVim lives, beside the things it keeps
# there already -- its plugins, its session, its saved options, its undo. After
# this the "groovim" command needs to know ONE path, a short one that does not
# move when the checkout does, and the checkout can be thrown away.
install_groovim() {

  local from="$(cd "$(dirname "$VIMRC")" && pwd)"
  local to="$GROOVIM_HOME_DIR"

  step "GrooVim itself"

  if [ ! -d "$from/groovim" ]; then
    die "There is no \"groovim\" directory beside $VIMRC -- is this a GrooVim checkout?"
  fi

  # Note: COPIES and never links. A link would tie the installation to the
  # checkout it was made from: move that directory or throw it away and GrooVim
  # stops working, with nothing to say why. What is installed has to stand on
  # its own.
  mkdir -p "$to"
  rm -rf "$to/groovim" "$to/.vimrc" "$to/tests"
  cp "$from/.vimrc" "$to/.vimrc"
  cp -r "$from/groovim" "$to/groovim"

  echo "  copied from $from"
  green "  $(ls "$to/groovim" | wc -l) parts in $to/groovim"

  # Note: And the battery, because the tests are ABOUT what was installed. They
  # run on the Vim this builds, and the ".vimrc" they read by default is the one
  # beside them -- which, once they are here, is the installed one. Whoever
  # installed GrooVim can ask it whether it works without going back for the
  # project, and that is the whole point of shipping them.
  #
  # Note: The results of a previous run do not come along: they are of another
  # machine and another day, and a directory of green answers nobody produced
  # here is worse than no answers at all.
  if [ -d "$from/tests" ]; then
    cp -r "$from/tests" "$to/tests"
    rm -rf "$to/tests/results"
    TESTS_HERE="$to/tests/run.sh"
    green "  the battery in $to/tests"
  fi
}

# ---------------------------------------------------------------- desktop ---

# Note: Is there a DESKTOP on this machine?
#
# Two questions in one, and both are worth asking. A session RUNNING says so in
# the environment -- which desktop, which session, which display -- and that is
# the common case: somebody installing GrooVim from a terminal of their own
# desktop.
#
# A desktop that is INSTALLED and not running says nothing there, and that is
# the case of an installation over SSH: the machine has KDE or GNOME on it and
# whoever is installing is not sitting in front of it. What it does leave behind
# is the session files every display manager reads, so those answer for it.
#
# A server with neither has no menu to put anything in, and nothing is done.
have_desktop() {
  [ -n "${XDG_CURRENT_DESKTOP:-}${DESKTOP_SESSION:-}${WAYLAND_DISPLAY:-}${DISPLAY:-}" ] && return 0
  ls /usr/share/xsessions/*.desktop /usr/share/wayland-sessions/*.desktop \
    /usr/local/share/xsessions/*.desktop >/dev/null 2>&1
}

# Note: The entry of the menu and the pictures that go with it.
#
# One file and two icons, in the directories of the user and not of the system:
# GrooVim installs itself for whoever runs this and asks for no password to do
# it. KDE Plasma, GNOME, Xfce, Cinnamon, MATE and every other desktop that
# follows the freedesktop.org specification read those directories -- the entry
# is the same file for all of them, which is the whole point of the
# specification.
#
# "Terminal=true" is what makes a desktop open GrooVim in a terminal of its own,
# because GrooVim is a terminal editor and there is no window for it otherwise.
#
# ONE main category, "Utility", with "TextEditor" saying what kind. A second
# main one -- "Development" was there first -- puts GrooVim in the menu twice,
# which the validator of the specification says out loud when it is asked.
#
# The path of the command is written out whole. "groovim" alone would depend on
# the PATH the session happens to have, and a session is started long before a
# shell of yours reads anything.
#
# "--jrinst" is what makes a file opened from a file manager land in the GrooVim
# you already have open, in a tab of its own, instead of starting a second one
# -- several files at a time, which is what "%F" hands over. Clicking the entry
# with no file has nothing to hand over and opens a GrooVim, which is the only
# thing that can be SHOWN: a terminal program cannot raise the window of another
# terminal.
#
# The SVG is what a desktop wants -- it is drawn at whatever size the place it
# lands in asks for -- and the PNG goes in beside it for the few that do not
# read SVG. "Icon=groovim" names neither: the desktop picks whichever it can
# use, which is how an icon theme works.
install_desktop() {

  local entry="$APPS_DIR/groovim.desktop"

  step "The menu entry and the icons"

  if [ "$DESKTOP" -eq 0 ]; then
    yellow "  skipped by --no-desktop"
    return 0
  fi
  if ! have_desktop; then
    echo "  there is no desktop on this machine, so there is no menu to be in"
    return 0
  fi
  if [ ! -r "$HERE/groovim.svg" ] && [ ! -r "$HERE/groovim.png" ]; then
    yellow "  I cannot find the icons beside this script. Nothing installed."
    return 0
  fi

  mkdir -p "$APPS_DIR" "$ICONS_DIR/scalable/apps" "$ICONS_DIR/256x256/apps"

  [ -r "$HERE/groovim.svg" ] && cp "$HERE/groovim.svg" "$ICONS_DIR/scalable/apps/groovim.svg"
  [ -r "$HERE/groovim.png" ] && cp "$HERE/groovim.png" "$ICONS_DIR/256x256/apps/groovim.png"

  cat > "$entry" <<END
[Desktop Entry]
Type=Application
Version=1.0
Name=GrooVim
GenericName=Text Editor
Comment=Vi IMproved'n'GrooVIed -- Vim remodelled as a simpler, more intuitive editor
Exec=$BINDIR/groovim --jrinst %F
TryExec=$BINDIR/groovim
Icon=groovim
Terminal=true
StartupNotify=false
Categories=Utility;TextEditor;
Keywords=vim;groovim;editor;text;
MimeType=text/plain;text/english;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-pascal;text/x-tex;text/x-shellscript;application/x-shellscript;text/markdown;application/json;text/xml;
END

  # Note: A desktop entry that is wrong is worse than none -- some desktops hide
  # it and say nothing -- so it is read back by the tool that knows the rules,
  # when the tool is there.
  if command -v desktop-file-validate >/dev/null 2>&1; then
    if ! desktop-file-validate "$entry" 2>&1 | sed 's/^/    /'; then
      yellow "  the entry was written, and the validator above is not happy with it"
    fi
  fi

  # Note: The caches, which is what makes it show up WITHOUT logging out. Each
  # desktop keeps its own and each one of these is a no-op where it is not
  # wanted, so they are all asked and none is required.
  command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$APPS_DIR" >/dev/null 2>&1
  command -v gtk-update-icon-cache >/dev/null 2>&1 && gtk-update-icon-cache -q -f -t "$ICONS_DIR" >/dev/null 2>&1
  command -v xdg-desktop-menu >/dev/null 2>&1 && xdg-desktop-menu forceupdate >/dev/null 2>&1
  command -v kbuildsycoca6 >/dev/null 2>&1 && kbuildsycoca6 --noincremental >/dev/null 2>&1
  command -v kbuildsycoca5 >/dev/null 2>&1 && kbuildsycoca5 --noincremental >/dev/null 2>&1

  green "  $entry"
  echo "  icons in $ICONS_DIR (scalable and 256x256)"
  echo "  it opens in a terminal of its own, and takes files you drop on it"

  return 0
}

# -------------------------------------------------------------- uninstall ---

# Note: Taking GrooVim out, and the line this draws is between what GrooVim
# BROUGHT and what you WROTE.
#
# What it brought goes without asking: the command, the Vim built for it, the
# menu entry, the icons, the source it was built from. None of that is yours --
# it can all be put back by running this script again.
#
# What you wrote is another matter: the options you chose to keep, the session,
# the marked lines, the undo of every file, the plugins. That is asked about,
# and kept when the answer is no. "--purge" is the answer given in advance.
#
# Nothing here touches the directory this script was run FROM. A checkout is
# yours, and a script that deletes the repository it lives in is a script nobody
# can trust.
uninstall_groovim() {

  local candidate

  step "Taking GrooVim out"

  if [ -e "$BINDIR/groovim" ]; then
    rm -f "$BINDIR/groovim"
    green "  the command: $BINDIR/groovim"
  fi

  # Note: The link that makes "sudo groovim" work, and ONLY when it points at
  # the installation being taken out.
  #
  # A link somewhere else is somebody else's: another GrooVim installed under
  # another prefix, or one put there by hand. Reading where it points is the
  # only way to tell, and following it is what "readlink -f" does.
  #
  # It was made with a password and needs one to go.
  for candidate in "$SYSTEM_LINK_DIR" /usr/local/bin /usr/bin /bin; do
    [ -e "$candidate/groovim" ] || [ -L "$candidate/groovim" ] || continue
    if [ ! -L "$candidate/groovim" ]; then
      yellow "  $candidate/groovim is not a link of ours. Left where it is."
      break
    fi
    if [ "$(readlink "$candidate/groovim")" != "$BINDIR/groovim" ]; then
      yellow "  $candidate/groovim points somewhere else. Left where it is."
      break
    fi
    if [ -w "$candidate" ]; then
      rm -f "$candidate/groovim" && green "  the link for sudo: $candidate/groovim"
    elif command -v sudo >/dev/null 2>&1 && ask "  Take the link for sudo out too ($candidate/groovim)? (it asks for your password)"; then
      sudo rm -f "$candidate/groovim" && green "  the link for sudo: $candidate/groovim"
    else
      yellow "  left where it is: $candidate/groovim"
    fi
    break
  done

  if [ -d "$PREFIX" ] && [ -n "$PREFIX" ]; then
    rm -rf "$PREFIX"
    green "  the Vim it built: $PREFIX"
  fi

  if [ -d "$SOURCE" ] && [ -n "$SOURCE" ]; then
    rm -rf "$SOURCE"
    green "  the source it was built from: $SOURCE"
  fi

  rm -f "$APPS_DIR/groovim.desktop" \
    "$ICONS_DIR/scalable/apps/groovim.svg" "$ICONS_DIR/256x256/apps/groovim.png"
  command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$APPS_DIR" >/dev/null 2>&1
  command -v gtk-update-icon-cache >/dev/null 2>&1 && gtk-update-icon-cache -q -f -t "$ICONS_DIR" >/dev/null 2>&1
  command -v kbuildsycoca6 >/dev/null 2>&1 && kbuildsycoca6 --noincremental >/dev/null 2>&1
  green "  the menu entry and the icons"

  step "What you wrote"

  if [ ! -d "$GROOVIM_HOME_DIR" ]; then
    echo "  there is nothing in $GROOVIM_HOME_DIR"
  elif [ "$PURGE" -eq 1 ]; then
    rm -rf "$GROOVIM_HOME_DIR"
    green "  taken too, by --purge: $GROOVIM_HOME_DIR"
  else
    echo "  $GROOVIM_HOME_DIR holds the options you kept, the session, the marked"
    echo "  lines, the undo of every file you edited and the plugins."
    if ask "  Take that as well?"; then
      rm -rf "$GROOVIM_HOME_DIR"
      green "  taken: $GROOVIM_HOME_DIR"
    else
      echo "  kept. Installing GrooVim again finds it where it is."
    fi
  fi

  step "Done"
  echo "  GrooVim is out. Your own Vim was never touched."
  exit 0
}

# ---------------------------------------------------------------- wrapper ---

write_groovim() {
  local target="$BINDIR/groovim"

  step "The \"groovim\" command"
  mkdir -p "$BINDIR"

  cat > "$target" <<END
#!/usr/bin/env bash
#
# Runs the Vim of GrooVim, with the .vimrc of GrooVim. Written by
# install.sh -- run it again to change any of this.
#
# The Vim of the system is not involved: "vim" goes on being yours.

GROOVIM_VIM="\${GROOVIM_VIM:-$PREFIX/bin/vim}"
GROOVIM_VIMRC="\${GROOVIM_VIMRC:-$GROOVIM_HOME_DIR/.vimrc}"
GROOVIM_HOME="\${GROOVIM_HOME:-$GROOVIM_HOME_DIR}"
export GROOVIM_HOME

# Under "sudo" -- or as anyone who is not the user this was installed for -- the
# code, the plugins and the settings go on coming from the one installation.
# That is the point of having one.
#
# What must NOT come from there is what this run WRITES. Root writing a session
# into that directory leaves it owned by root, and the next time its owner opened
# GrooVim they could not write it any more. So the session, the undo, the viminfo
# and the clipboard file go to a GrooVim directory of whoever is running.
if [ "\$(id -u)" != "$(id -u)" ]; then
  GROOVIM_STATE="\${GROOVIM_STATE:-\$(getent passwd "\$(id -u)" | cut -d: -f6)/.groovim}"
  export GROOVIM_STATE
fi

if [ ! -x "\$GROOVIM_VIM" ]; then
  echo "groovim: I cannot find the Vim at \$GROOVIM_VIM" >&2
  echo "groovim: run install.sh again, or point GROOVIM_VIM at another one." >&2
  exit 1
fi

if [ ! -r "\$GROOVIM_VIMRC" ]; then
  echo "groovim: I cannot read the .vimrc at \$GROOVIM_VIMRC" >&2
  exit 1
fi

# The help of Vim, and then what GrooVim adds to it. Vim knows nothing of the
# flags of this script, so a "--help" that only asked Vim would leave them
# unanswerable.
for arg in "\$@"; do
  case "\$arg" in
    -h|--help)
      "\$GROOVIM_VIM" --help
      cat <<'GROOVIMHELP'

GrooVim adds:

   -j, --jrinst         Open the files in a GrooVim that is ALREADY running
                        ("just reuse an instance"), each in a tab of its own.
                        The oldest one still open takes them. With none open,
                        this one opens them as usual.
   -0, --stdin0         The list of files arriving on the standard input is
                        separated by NULs and not by line breaks, which is what
                        "grep -Z" and "find -print0" write.

And of its own accord:

   A list of file NAMES on the standard input is read and opened, so
   "find . -name '*.log' | groovim" works. A lone "-" among the arguments
   means what it means in Vim -- read the TEXT from there -- and then nothing
   is taken as a list.

   More than one file opens one TAB for each, as GrooVim does everywhere. Say
   "-p", "-o" or "-O" yourself and that arrangement is used instead.

Environment:

   GROOVIM_VIM          the Vim to run       GROOVIM_HOME   where GrooVim lives
   GROOVIM_VIMRC        the .vimrc to run    GROOVIM_STATE  where this run writes

Inside GrooVim, <F9> is its own help: every key, every screen, every setting.
GROOVIMHELP
      exit 0
      ;;
  esac
done

# Note: What is for this script, what is for Vim, and which of them are FILES.
#
# A flag of ours is taken out of the way -- Vim would not know what to do with
# it -- and everything else is handed over untouched. The files are told apart
# by not beginning with a "-", which is the same thing Vim does with its own
# command line, and they are what the handing over and the tabs below are about.
#
# A lone "-" is Vim's own: READ THE TEXT from the standard input. It is kept in
# the arguments and it turns the reading of a file list off, because the two
# cannot both have that input.
GROOVIM_STATE="\${GROOVIM_STATE:-\$GROOVIM_HOME}"
JUST_REUSE=0
STDIN_ZERO=0
TEXT_FROM_STDIN=0
ARGS=()
FILES=()

while [ \$# -gt 0 ]; do
  case "\$1" in
    -j|--jrinst) JUST_REUSE=1 ;;
    -0|--stdin0) STDIN_ZERO=1 ;;
    -)           TEXT_FROM_STDIN=1; ARGS+=("\$1") ;;
    -*)          ARGS+=("\$1") ;;
    *)           ARGS+=("\$1"); FILES+=("\$1") ;;
  esac
  shift
done

# Note: A list of file NAMES arriving on the standard input, which is how a
# search hands its answer to an editor:
#
#   find ./ -name '*.log' | groovim
#   find ./ -type f -exec grep -IiFl 'something' -- {} \\; | groovim
#
# One name per line, or separated by NULs with "-0", which is what "grep -Z" and
# "find -print0" write and the only form that survives a name with a line break
# in it.
#
# Vim needs a TERMINAL to be an editor in, and the one it had was taken by the
# pipe, so it is handed back from /dev/tty. Without a terminal to go back to --
# a cron job, a script with no session -- there is nothing to open anyway, and
# Vim says so itself.
if [ "\$TEXT_FROM_STDIN" -eq 0 ] && [ ! -t 0 ]; then
  if [ "\$STDIN_ZERO" -eq 1 ]; then
    while IFS= read -r -d "" name; do
      [ -n "\$name" ] && { ARGS+=("\$name"); FILES+=("\$name"); }
    done
  else
    while IFS= read -r name; do
      [ -n "\$name" ] && { ARGS+=("\$name"); FILES+=("\$name"); }
    done
  fi
  # The terminal is only taken back when there IS one to take: with none -- a
  # cron job, a file manager, a script with no session -- the redirection itself
  # fails, and the shell says so in a line nobody asked for. Tried first on a
  # command that can be silenced, which "exec" cannot -- and with the silence
  # asked for BEFORE the input, because a shell reads redirections from left to
  # right and the complaint is made by the one it is reading.
  if : 2>/dev/null < /dev/tty; then
    exec < /dev/tty
  fi
fi

# Note: "-j" hands the files to a GrooVim already open instead of starting
# another one.
#
# The mailbox of each running GrooVim is a file in "inbox/", named for the
# moment it opened and the process it is: the TIME says which was there first,
# and the PID is how this finds out whether it still is. Writing a line into
# one is the whole of handing a file over -- the GrooVim it belongs to reads it
# on a clock and opens a tab.
#
# A mailbox whose process is gone is swept here, which is the only place that
# can know: a GrooVim that was killed had no chance to take its own down.
if [ "\$JUST_REUSE" -eq 1 ] && [ "\${#FILES[@]}" -gt 0 ]; then
  mailbox=""
  for name in \$(ls "\$GROOVIM_STATE/inbox" 2>/dev/null | sort -n); do
    pid="\${name##*.}"
    case "\$pid" in
      ''|*[!0-9]*) continue ;;
    esac
    if kill -0 "\$pid" 2>/dev/null; then
      mailbox="\$GROOVIM_STATE/inbox/\$name"
      break
    fi
    rm -f "\$GROOVIM_STATE/inbox/\$name"
  done

  if [ -n "\$mailbox" ]; then
    for file in "\${FILES[@]}"; do
      printf '%s\\n' "\$(realpath -m -- "\$file")" >> "\$mailbox"
    done
    echo "groovim: handed over to the GrooVim already open (pid \$pid)."
    exit 0
  fi
  echo "groovim: there is no GrooVim open to hand it to, so this one opens it." >&2
fi

# Note: A TAB for each file, which is what GrooVim does with everything else.
#
# Vim opens many files as many BUFFERS and shows the first one, so a search that
# found twelve files looked like it had found one. "-p" is the flag that makes
# them tabs, and "tabpagemax" in the tabs part is what lets them all be there.
#
# Said by hand -- "-p", "-o" for windows one above the other, "-O" side by side
# -- that arrangement is the one used: somebody who names it means it.
if [ "\${#FILES[@]}" -gt 1 ]; then
  arrange=""
  for arg in "\${ARGS[@]}"; do
    case "\$arg" in
      -p*|-o*|-O*) arrange="\$arg"; break ;;
    esac
  done
  [ -z "\$arrange" ] && ARGS=("-p" "\${ARGS[@]}")
fi

exec "\$GROOVIM_VIM" -u "\$GROOVIM_VIMRC" "\${ARGS[@]}"
END

  chmod +x "$target"
  echo "  written to $target"
  echo "  it runs: $PREFIX/bin/vim -u $GROOVIM_HOME_DIR/.vimrc"
  echo "  under sudo it reads the same GrooVim and writes its own session apart"
}

# ------------------------------------------------------------ sudo groovim ---

# Note: "sudo" throws your PATH away and uses the "secure_path" of the sudoers
# file instead, and that almost never holds a directory belonging to a user. So
# "sudo groovim" answers "command not found" however well GrooVim is installed --
# measured, and it is the first thing anybody hits who wants to edit a file of
# the system.
#
# Note: A link from a directory that IS in that path is the whole fix.
# The directory to link into: one that sudo really searches. secure_path lives
# in the sudoers file, which a normal user cannot read, so it is not parsed --
# sudo is simply run, and the PATH it hands its command IS the answer. Guessing
# is what went wrong before: the secure_path of Rocky and of openSUSE is
# "/sbin:/bin:/usr/sbin:/usr/bin", with no /usr/local/bin in it, so the link
# landed somewhere sudo would never look. Two of the six.
sudo_bindir() {
  local sudo_path candidate
  sudo_path="$(sudo sh -c 'printf "%s" "$PATH"' 2>/dev/null || true)"
  [ -n "$sudo_path" ] || { echo "$SYSTEM_LINK_DIR"; return 0; }

  for candidate in "$SYSTEM_LINK_DIR" /usr/local/bin /usr/bin /bin; do
    case ":$sudo_path:" in
      *":$candidate:"*)
        if [ -d "$candidate" ]; then
          echo "$candidate"
          return 0
        fi ;;
    esac
  done
  echo ""
}

offer_system_link() {
  local candidate dir

  step "Reaching GrooVim through sudo"

  if [ "$SYSTEM_LINK" -eq 0 ]; then
    yellow "  skipped by --no-system-link"
    return 0
  fi
  if [ "$(id -u)" = "0" ]; then
    echo "  installed by root, so the command is already where sudo looks"
    return 0
  fi
  # Asked before sudo is, so that running this again costs no password.
  for candidate in "$SYSTEM_LINK_DIR" /usr/local/bin /usr/bin /bin; do
    if [ -e "$candidate/groovim" ]; then
      green "  already there: $candidate/groovim"
      return 0
    fi
  done
  if ! command -v sudo >/dev/null 2>&1; then
    yellow "  there is no sudo here. Nothing to do."
    return 0
  fi

  echo "  \"sudo groovim\" will not find $BINDIR/groovim: sudo replaces your PATH"
  echo "  with the secure_path of the sudoers file, and a directory of yours is"
  echo "  not in it."
  if ! ask "  Link it where sudo looks? (it asks for your password)"; then
    yellow "  not linking. To edit files of the system: sudo $BINDIR/groovim <file>"
    return 0
  fi

  dir="$(sudo_bindir)"
  if [ -z "$dir" ]; then
    red "  sudo searches none of /usr/local/bin, /usr/bin or /bin here."
    echo "    To edit files of the system: sudo $BINDIR/groovim <file>"
    return 0
  fi

  if sudo ln -s "$BINDIR/groovim" "$dir/groovim"; then
    green "  linked: $dir/groovim -> $BINDIR/groovim"
  else
    red "  could not link. To edit files of the system: sudo $BINDIR/groovim <file>"
  fi
}

# ---------------------------------------------------------------- closing ---

check_the_result() {
  local vim_bin="$PREFIX/bin/vim"
  step "What came out"
  [ -x "$vim_bin" ] || die "The build said it was fine but there is no $vim_bin."
  version_first_line "$vim_bin" | sed 's/^/  /'
  "$vim_bin" --version 2>/dev/null | grep -m1 "Modified by" | sed 's/^/  /'
  vim_features "$vim_bin" \
    | grep -E '^[+-](clipboard|xterm_clipboard|popupwin|terminal|python3|X11|wayland)$' \
    | sort -u | tr '\n' ' ' | sed 's/^/  /'
  echo

  local missing
  missing="$(missing_for_groovim "$vim_bin")"
  if [ -z "$missing" ]; then
    green "  it serves GrooVim"
  else
    yellow "  it came out short:"
    printf '%s\n' "$missing" | sed 's/^/    - /'
    echo "    (the headers of the missing library were probably not there when it built)"
  fi
}

# Whether this machine needs a clipboard tool, and it almost never does.
#
# The Vim built here talks to Wayland and to X11 itself -- "+wayland", "+X11",
# "+xterm_clipboard" -- and those come FIRST in the cascade, so a tool is only
# ever reached where both of them fail. On Wayland that means one thing: the
# compositor does not offer the protocol Vim's clipboard needs. ":h wayland"
# names them, "wlr-data-control-unstable-v1" and "ext-data-control-v1", and a
# compositor without either leaves Vim with no way in.
#
# Measured on the machine this was written on (KWin): "ext_data_control_manager_v1"
# is offered, Vim chooses "wayland" by itself, and the "wl-copy" installed here
# is never called.
#
# On a session with no compositor and no X -- an SSH, a container -- no tool
# works either, and there the answer is OSC 52, which GrooVim uses on its own.
check_the_clipboard() {
  step "The clipboard"

  if [ -n "${WAYLAND_DISPLAY:-}" ]; then
    if ! command -v wayland-info >/dev/null 2>&1; then
      echo "  Wayland session. Vim talks to the compositor itself when the compositor"
      echo "  offers \"wlr-data-control\" or \"ext-data-control\". To see whether yours does:"
      echo
      echo "    wayland-info | grep -E 'ext_data_control|zwlr_data_control'"
      return 0
    fi
    if wayland-info 2>/dev/null | grep -qE 'ext_data_control|zwlr_data_control'; then
      green "  your compositor offers the protocol Vim needs: nothing to install"
      return 0
    fi
    yellow "  your compositor does NOT offer \"wlr-data-control\" or \"ext-data-control\","
    echo "  which is what Vim needs to reach the clipboard by itself. Copying still"
    echo "  leaves through OSC 52; PASTING from another application is what stops"
    echo "  working. A tool covers both:"
    echo
    echo "    sudo pacman -S wl-clipboard     # or: sudo apt install wl-clipboard"
    echo
    echo "  GrooVim uses it on its own once it is in your PATH."
    return 0
  fi

  if [ -n "${DISPLAY:-}" ]; then
    green "  X11 session: Vim reaches the clipboard itself (+xterm_clipboard)"
    return 0
  fi

  echo "  no Wayland and no X here, so the clipboard goes through OSC 52 -- which"
  echo "  crosses an SSH by itself and needs nothing installed. Pasting from another"
  echo "  application is the one thing it cannot do: use the paste of your terminal"
  echo "  (usually Ctrl+Shift+V)."
}

warn_about_path() {
  case ":$PATH:" in
    *":$BINDIR:"*) return 0 ;;
  esac
  step "One more thing"
  yellow "  $BINDIR is not in your PATH."
  echo "  Add this to your ~/.bashrc (or the file of your shell):"
  echo
  echo "    export PATH=\"$BINDIR:\$PATH\""
}

# ------------------------------------------------------------------- main ---

blue "GrooVim -- a Vim of its own"

# Note: OUR Vim and not the one of the system. GrooVim is reached through the
# "groovim" command and runs on the Vim this script builds; what your
# distribution ships is none of its business, and looking at it here only ever
# told people about a Vim GrooVim was never going to use.
# Taking it out comes before everything the installing does: there is no Vim to
# look at, no dependency to install and nothing to build. It is here and not up
# with the options because a function has to be WRITTEN before it can be called.
if [ "$UNINSTALL" -eq 1 ]; then
  uninstall_groovim
fi

NEED_BUILD=1
if [ "$REBUILD" -eq 1 ]; then
  step "The Vim of GrooVim"
  echo "  building again, as asked"
elif [ -x "$PREFIX/bin/vim" ] && [ -z "$(missing_for_groovim "$PREFIX/bin/vim")" ]; then
  step "The Vim of GrooVim"
  version_first_line "$PREFIX/bin/vim" | sed 's/^/  /'
  green "  already built and serving. Use --rebuild to build it again."
  NEED_BUILD=0
fi

if [ "$NEED_BUILD" -eq 1 ]; then
  echo
  echo "  Going to build Vim into $PREFIX,"
  echo "  install GrooVim into $GROOVIM_HOME_DIR,"
  echo "  and write \"groovim\" into $BINDIR."
  ask "  Go on?" || { echo "  Nothing done."; exit 0; }
  install_dependencies
  check_the_tools
  fetch_source
  brand_the_splash
  build_vim
fi

# The three plugins, into the package directory GrooVim looks in. Not being able
# to fetch one is not a failure: GrooVim works without every one of them, and a
# shortcut whose plugin is missing now says which one instead of breaking.
# The newest release of a plugin INSIDE the series it is pinned to.
#
# The tags are read from the remote and nothing is cloned to find out, the way
# the newest Vim is looked for above. Only the tags of that series are kept --
# "7.1.3" and not "6.10.16", "v1.4" and not "v201" -- which also keeps the "sort
# -V" honest: every name left shares the same prefix, so what is compared is the
# numbers.
newest_release() {
  git ls-remote --tags --refs "$1" 2>/dev/null \
    | awk -F/ '{print $NF}' | grep -E "^$2\.[0-9]+(\.[0-9]+)*$" \
    | sort -V | tail -1
}

# One that is already there, put ON that release.
#
# A shallow clone has one commit and nothing else, so the tag is FETCHED by name
# before it can be checked out -- and the checkout leaves the plugin on a
# detached head, which is what a pinned release is. A "git pull" was what used to
# be here, and it would walk a plugin into its next major on its own.
at_release() {
  ( cd "$1" \
    && git fetch --quiet --depth 1 origin "+refs/tags/$3:refs/tags/$3" \
    && git checkout --quiet "$3" ) >/dev/null 2>&1
}

install_plugins() {
  local where name url series what tag

  step "Plugins"

  if [ "$PLUGINS" -eq 0 ]; then
    yellow "  skipped by --no-plugins"
    return 0
  fi
  if ! command -v git >/dev/null 2>&1; then
    yellow "  there is no git here, so there are no plugins."
    return 0
  fi

  where="$GROOVIM_HOME_DIR/pack/groovim/start"
  mkdir -p "$where"

  # A plugin GrooVim used to install and does not any more is TAKEN AWAY, and not
  # merely left off the list. Left where it was it would go on loading: its
  # autocommands would run, its signs would be drawn, and two pieces of code
  # would be doing the same job on the same file. The bookmarks are GrooVim's own
  # now -- see groovim/bookmarks.vim for why they had to be.
  #
  # Only a directory this installer put there itself, and only one of these
  # names. Anything else of yours in the same place is left alone.
  for name in $GROOVIM_PLUGINS_GONE; do
    if [ -d "$where/$name/.git" ]; then
      rm -rf "$where/$name"
      yellow "  $name -- taken away, GrooVim does this itself now"
    fi
  done

  printf '%s\n' "$GROOVIM_PLUGINS" | while IFS='|' read -r name url series what; do
    [ -n "$name" ] || continue

    tag="$(newest_release "$url" "$series")"
    if [ -z "$tag" ]; then
      yellow "  $name -- I found no release of the $series series. Is there network?"
      continue
    fi

    if [ -d "$where/$name/.git" ]; then
      if at_release "$where/$name" "$url" "$tag"; then
        green "  $name $tag -- up to date"
      else
        yellow "  $name -- there already, could not put it on $tag"
      fi
    elif git clone --quiet --depth 1 --branch "$tag" "$url" "$where/$name" >/dev/null 2>&1; then
      green "  $name $tag -- $what"
    else
      yellow "  $name -- could not fetch it. What needs it will say so."
    fi
  done
}
install_groovim
install_plugins
write_groovim
install_desktop
offer_system_link
check_the_result
check_the_clipboard
warn_about_path

step "Done"
echo "  Use it with:    groovim file.txt"
if [ -n "${TESTS_HERE:-}" ]; then
  echo "  Check it with:  $TESTS_HERE"
  echo "                  (about half a minute, and it says so itself)"
fi
