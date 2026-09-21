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

# The plugins GrooVim uses, and what each one is for. They were never installed
# by this script, and the README asked you to clone them by hand -- so a machine
# that had only run install.sh had a F4->n that called into nothing.
#
# Only these names are touched. Anything else of yours in the same directory is
# left where it is.
#
# Each line: name|where it comes from|what it is for
GROOVIM_PLUGINS="
nerdtree|https://github.com/preservim/nerdtree.git|the file tree of F4->n
tcomment_vim|https://github.com/tomtom/tcomment_vim.git|the comment toggle, which Vim has no command of its own for
vim-move|https://github.com/matze/vim-move.git|moving a line or a selection up and down
"

# What GrooVim used to install and does not any more.
GROOVIM_PLUGINS_GONE="vim-bookmarks"
# Building takes minutes. An installation that is already there and serves is not
# built again unless you say so.
REBUILD=0

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
  read -r answer </dev/tty || return 1
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
        clipboard) echo "-clipboard: copying to the system clipboard depends on workarounds" ;;
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
  # its own! By Questor
  mkdir -p "$to"
  rm -rf "$to/groovim" "$to/.vimrc"
  cp "$from/.vimrc" "$to/.vimrc"
  cp -r "$from/groovim" "$to/groovim"

  echo "  copied from $from"
  green "  $(ls "$to/groovim" | wc -l) parts in $to/groovim"
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

exec "\$GROOVIM_VIM" -u "\$GROOVIM_VIMRC" "\$@"
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
# Note: A link from a directory that IS in that path is the whole fix! By Questor
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
# told people about a Vim GrooVim was never going to use! By Questor
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
install_plugins() {
  local where name url what

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

  printf '%s\n' "$GROOVIM_PLUGINS" | while IFS='|' read -r name url what; do
    [ -n "$name" ] || continue
    if [ -d "$where/$name/.git" ]; then
      if ( cd "$where/$name" && git pull --quiet --ff-only ) >/dev/null 2>&1; then
        green "  $name -- up to date"
      else
        yellow "  $name -- there already, could not update it"
      fi
    elif git clone --quiet --depth 1 "$url" "$where/$name" >/dev/null 2>&1; then
      green "  $name -- $what"
    else
      yellow "  $name -- could not fetch it. What needs it will say so."
    fi
  done
}
install_groovim
install_plugins
write_groovim
offer_system_link
check_the_result
warn_about_path

step "Done"
echo "  Use it with:  groovim file.txt"
