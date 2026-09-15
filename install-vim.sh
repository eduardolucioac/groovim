#!/usr/bin/env bash
#
# Builds a Vim for GrooVim alone, and a "groovim" command that runs it.
#
#   ./install-vim.sh --check      says whether the Vim you already have serves
#   ./install-vim.sh              builds and installs
#   ./install-vim.sh --help       every option
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
ONLY_CHECK=0
VIM_TO_CHECK="vim"
JOBS="$(nproc 2>/dev/null || echo 2)"
# Who this build says modified it. Vim prints it on the opening screen and in
# ":version", under "Modified by".
MODIFIED_BY="${GROOVIM_MODIFIED_BY:-Questor the Elf (eduardolucioac)}"

HERE="$(cd "$(dirname "$0")" && pwd)"

# What GrooVim needs from the Vim it runs on. Measured, not guessed: each line
# is a feature some part of GrooVim calls, with the release that brought it.
readonly MINIMUM_VERSION=900   # "leadmultispace", used by the indent guides

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
  --check [VIM]      only says whether a Vim serves, builds nothing. Without an
                     argument it looks at the "vim" of your PATH.
  --version TAG      Vim tag to build (default: the newest release)
  --prefix DIR       where Vim goes      (default: ~/.local/share/groovim)
  --bindir DIR       where "groovim" goes(default: ~/.local/bin)
  --vimrc FILE       which .vimrc it runs(default: the one next to this script)
  --jobs N           parallel compilation (default: as many as you have cores)
  --modified-by NAME who this build says modified it, shown on the opening
                     screen and in ":version"
  --no-deps          do not install build dependencies
  --yes              answer yes to everything
  --help             this

Environment: GROOVIM_PREFIX, GROOVIM_BINDIR, GROOVIM_SOURCE, GROOVIM_MODIFIED_BY
do the same as the options of the same name.
END
}

# ----------------------------------------------------------------- options ---

while [ $# -gt 0 ]; do
  case "$1" in
    --check)
      ONLY_CHECK=1
      # An optional binary right after: "--check /opt/vim/bin/vim". Anything
      # starting with "-" is the next option, not a path.
      if [ $# -gt 1 ] && [ "${2#-}" = "$2" ]; then
        VIM_TO_CHECK="$2"; shift
      fi
      ;;
    --version)   VERSION="${2:?--version needs a tag}"; shift ;;
    --prefix)    PREFIX="${2:?--prefix needs a directory}"; shift ;;
    --bindir)    BINDIR="${2:?--bindir needs a directory}"; shift ;;
    --vimrc)     VIMRC="${2:?--vimrc needs a file}"; shift ;;
    --jobs)      JOBS="${2:?--jobs needs a number}"; shift ;;
    --modified-by) MODIFIED_BY="${2:?--modified-by needs a name}"; shift ;;
    --no-deps)   SKIP_DEPS=1 ;;
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
    echo "Vim $version, and GrooVim asks for $MINIMUM_VERSION or newer (the indent guides use \"leadmultispace\")"
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

check_and_report() {
  local vim_bin="${1:-vim}"
  local missing

  step "Looking at $vim_bin"
  if ! command -v "$vim_bin" >/dev/null 2>&1 && [ ! -x "$vim_bin" ]; then
    yellow "  there is no $vim_bin here"
    return 1
  fi

  version_first_line "$vim_bin" | sed 's/^/  /'
  "$vim_bin" --version 2>/dev/null | grep -m1 "Modified by" | sed 's/^/  /'
  missing="$(missing_for_groovim "$vim_bin")"

  if [ -z "$missing" ]; then
    green "  it serves GrooVim as it is"
    return 0
  fi

  yellow "  it falls short:"
  printf '%s\n' "$missing" | sed 's/^/    - /'
  return 1
}

# --------------------------------------------------------------- distros ---

# The build dependencies of Vim, by family. Only the families are listed:
# derivatives arrive here through ID_LIKE.
distro_dependencies() {
  local id like
  id="$(. /etc/os-release 2>/dev/null && echo "${ID:-}")"
  like="$(. /etc/os-release 2>/dev/null && echo "${ID_LIKE:-}")"

  case " $id $like " in
    *" arch "*|*" cachyos "*|*" manjaro "*)
      echo "pacman|sudo pacman -S --needed --noconfirm|base-devel ncurses libx11 libxt python git" ;;
    *" debian "*|*" ubuntu "*)
      echo "apt|sudo apt-get install -y|build-essential libncurses-dev libx11-dev libxt-dev python3-dev git" ;;
    *" fedora "*|*" rhel "*|*" centos "*)
      echo "dnf|sudo dnf install -y|gcc make ncurses-devel libX11-devel libXt-devel python3-devel git" ;;
    *" suse "*|*" opensuse "*)
      echo "zypper|sudo zypper install -y|gcc make ncurses-devel libX11-devel libXt-devel python3-devel git" ;;
    *" alpine "*)
      echo "apk|sudo apk add|build-base ncurses-dev libx11-dev libxt-dev python3-dev git" ;;
    *" void "*)
      echo "xbps|sudo xbps-install -Sy|base-devel ncurses-devel libX11-devel libXt-devel python3-devel git" ;;
    *" gentoo "*)
      echo "emerge|sudo emerge -n|sys-libs/ncurses x11-libs/libX11 x11-libs/libXt dev-lang/python dev-vcs/git" ;;
    *)
      echo "" ;;
  esac
}

install_dependencies() {
  local recipe manager command packages

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

  echo "  distribution of the $manager family"
  echo "  $command $packages"
  if ! ask "  Run it? (it asks for your password)"; then
    yellow "  not installing. If the build fails, this is the first place to look."
    return 0
  fi
  # shellcheck disable=SC2086
  $command $packages
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
    git -C "$SOURCE" checkout -q -- .
    git -C "$SOURCE" fetch --depth 1 origin "refs/tags/$VERSION:refs/tags/$VERSION" 2>/dev/null || true
    git -C "$SOURCE" checkout -q "$VERSION"
  else
    echo "  cloning into $SOURCE"
    git clone --depth 1 --branch "$VERSION" https://github.com/vim/vim.git "$SOURCE"
  fi
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
    --enable-fail-if-missing
  )
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

# ---------------------------------------------------------------- wrapper ---

write_groovim() {
  local target="$BINDIR/groovim"

  step "The \"groovim\" command"
  mkdir -p "$BINDIR"

  cat > "$target" <<END
#!/usr/bin/env bash
#
# Runs the Vim of GrooVim, with the .vimrc of GrooVim. Written by
# install-vim.sh -- run it again to change any of this.
#
# The Vim of the system is not involved: "vim" goes on being yours.

GROOVIM_VIM="\${GROOVIM_VIM:-$PREFIX/bin/vim}"
GROOVIM_VIMRC="\${GROOVIM_VIMRC:-$VIMRC}"

if [ ! -x "\$GROOVIM_VIM" ]; then
  echo "groovim: I cannot find the Vim at \$GROOVIM_VIM" >&2
  echo "groovim: run install-vim.sh again, or point GROOVIM_VIM at another one." >&2
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
  echo "  it runs: $PREFIX/bin/vim -u $VIMRC"
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

if [ "$ONLY_CHECK" -eq 1 ]; then
  if check_and_report "$VIM_TO_CHECK"; then
    echo
    green "You do not need to build anything."
  else
    echo
    yellow "Run this script with no options to build one that does serve."
  fi
  exit 0
fi

check_and_report "vim" || true

echo
echo "  Going to build Vim into $PREFIX"
echo "  and write \"groovim\" into $BINDIR."
ask "  Go on?" || { echo "  Nothing done."; exit 0; }

install_dependencies
fetch_source
brand_the_splash
build_vim
write_groovim
check_the_result
warn_about_path

step "Done"
echo "  Use it with:  groovim file.txt"
