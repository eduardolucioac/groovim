#!/bin/bash
# Runs the automated battery of GrooVim.
#
#   ./run.sh                  uses ../.vimrc
#   ./run.sh ~/.vimrc         tests another one
#   ./run.sh '' 03_panel      a single case
#
# Exits 0 only if every case reaches its end and no check fails.

cd "$(dirname "$0")" || exit 1
BASE="$PWD"
VIMRC="${1:-$BASE/../.vimrc}"
FILTER="${2:-}"
# Which Vim binary. Lets the battery run inside the Vim that GrooVim builds for
# itself with install-vim.sh, and not only the one of the system.
VIM="${GROOVIM_TEST_VIM:-vim}"
TIMEOUT="${GROOVIM_TEST_TIMEOUT:-90}"

if [ ! -f "$VIMRC" ]; then
  echo "I cannot find the .vimrc at: $VIMRC"; exit 1
fi

# The cases run over a COPY of the fixtures. A case that changes a file in
# memory never gets near the originals.
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
cp -r "$BASE/fixtures/." "$WORK/"

mkdir -p "$BASE/results"
rm -f "$BASE/results"/*.txt

export GROOVIM_TEST_FIXTURES="$WORK"
export GROOVIM_TEST_OUT="$BASE/results"

# A throwaway GrooVim home, one per run.
#
# Without it the cases contaminate each other: each opens Vim with NO file, which
# is exactly when GrooVim brings the session back -- and it is the session of the
# previous case, with tabs and buffers already there and wrong. Same trap as the
# viminfo, by another road.
export GROOVIM_HOME="$WORK/.groovim"

echo "vimrc: $VIMRC"
echo "vim:   $("$VIM" --version | sed -n '1p')"
echo

TOTAL=0; FAILURES=0; BROKEN=0

for CASE in "$BASE"/cases/[0-9]*.vim; do
  NAME="$(basename "$CASE" .vim)"
  [ -n "$FILTER" ] && [[ "$NAME" != *"$FILTER"* ]] && continue

  # "script" gives a real terminal: without it "input()" and the keys of the
  # mappings do not behave as they do in real use.
  #
  # "-i NONE" is essential: without it Vim restores the viminfo and each case
  # starts with the buffer list of the previous one -- including a ghost
  # occurrence list, which makes the "bufexists()" of Sync give up on building
  # the real one. It was the cause of results that changed without the code
  # changing.
  #
  # "-n" turns off the swap file, or an interrupted case leaves a .swp that
  # stops the next one at a recovery prompt.
  timeout "$TIMEOUT" script -qc "'$VIM' -N -u '$VIMRC' -i NONE -n -S '$CASE'" /dev/null >/dev/null 2>&1
  OUTPUT="$BASE/results/$NAME.txt"

  echo "=== $NAME ==="
  if [ ! -f "$OUTPUT" ]; then
    echo "  !! produced no result at all (hung or died at the start)"
    BROKEN=$((BROKEN + 1)); echo; continue
  fi

  sed '/^END$/d; s/^/ /' "$OUTPUT"

  # "-a": a result with an accent or with the indent guide must not be taken
  # for a binary file.
  N=$(grep -ac ' ok$\|ok   \|FAILED' "$OUTPUT")
  F=$(grep -ac 'FAILED' "$OUTPUT")
  TOTAL=$((TOTAL + N)); FAILURES=$((FAILURES + F))

  if ! grep -aq '^END$' "$OUTPUT"; then
    echo "  !! the case did not reach its end -- it stopped after the last line above"
    BROKEN=$((BROKEN + 1))
  fi
  echo
done

echo "-----------------------------------------------"
printf 'checks: %s   failures: %s   incomplete cases: %s\n' "$TOTAL" "$FAILURES" "$BROKEN"
if [ "$FAILURES" -eq 0 ] && [ "$BROKEN" -eq 0 ]; then
  echo "everything passed."
  exit 0
fi
exit 1
