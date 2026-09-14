#!/bin/bash
# Shows the SCREEN Vim drew, rebuilt out of what it sent to the terminal.
#
#   ./screen.sh script.vim [file]
#
# The "script.vim" schedules the keys with timer_start and ends with ":qa!".
# For example:
#   call timer_start(400,  {-> feedkeys("\<F3>f", "t")})
#   call timer_start(900,  {-> feedkeys("TARGET\<CR>", "t")})
#   call timer_start(2400, {-> execute("qa!")})
#
# For any question about LAYOUT -- where the prompt landed, whether the bar
# changed, what the tab shows, whether there is a blank line left over -- this is
# the tool. Looking at the state from the inside (winnr, bufname) answers a
# different question.

cd "$(dirname "$0")" || exit 1
SCRIPT="$1"
FILE="${2:-$PWD/fixtures/a.txt}"
VIMRC="${VIMRC:-$PWD/../.vimrc}"

if [ -z "$SCRIPT" ]; then
  echo "usage: ./screen.sh script.vim [file]"; exit 1
fi

# A throwaway GrooVim "home", for the same reason as run.sh: without it the
# screen script saves YOUR session, with its own temporary files inside.
export GROOVIM_HOME="$(mktemp -d)"
LOG="$(mktemp)"
trap 'rm -rf "$GROOVIM_HOME"; rm -f "$LOG"' EXIT

timeout 20 script -qc "vim -N -u '$VIMRC' -i NONE -n -S '$SCRIPT' '$FILE'" /dev/null > "$LOG" 2>&1
python3 "$PWD/screen.py" "$LOG"
