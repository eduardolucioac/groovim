#!/bin/bash
# Opens the help of F9 straight out of the SOURCE, with no install in between.
#
#   ./tools/help.sh
#
# For the one question this answers: "how does what I just wrote in help.vim
# READ?". It is the real GrooVim, with the real F9 and the real Vim it builds
# for itself -- the help just happens to be already open when it starts. Write,
# quit, run it again.
#
# What it does NOT touch is your session. "GROOVIM_STATE" sends the session, the
# viminfo and the undo files to a directory of the moment, so previewing never
# reopens, saves or loses what you had open. The home stays the real one, so the
# plugins you have installed are the ones found -- the help hides the shortcuts
# of a plugin that is not there, and a preview with no plugins would be a
# different text.

cd "$(dirname "$0")/.." || exit 1
VIMRC="$PWD/.vimrc"

# The Vim GrooVim builds for itself, the same one the battery uses.
VIM="${GROOVIM_VIM:-$HOME/.local/share/groovim/bin/vim}"
if [ ! -x "$VIM" ]; then
  VIM="$(command -v vim)" || { echo "I cannot find a vim."; exit 1; }
  echo "The Vim of GrooVim is not built; falling back to: $VIM"
fi

GROOVIM_STATE="$(mktemp -d)"
export GROOVIM_STATE
trap 'rm -rf "$GROOVIM_STATE"' EXIT

exec "$VIM" -u "$VIMRC" -c "call GrooVim_ToogleGrooVimHelp()"
