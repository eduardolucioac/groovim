#!/bin/sh
# Writes the shortcuts of GrooVim into the README, out of the one list they all
# come from.
#
#   ./tools/sync-readme.sh
#
# The README used to keep its own copy, and it drifted the furthest of all of
# them: it still listed a layout of three groups, with no "F5" at all, and the
# same letter three times over in one of them. A case of the battery refuses to
# pass while the file and the list disagree, and this is what puts them back
# together.

set -eu
cd "$(dirname "$0")/.." || exit 1

VIM="${GROOVIM_TEST_VIM:-$HOME/.local/share/groovim/bin/vim}"
[ -x "$VIM" ] || { echo "I cannot find the Vim of GrooVim at: $VIM"; exit 1; }

START="<!-- shortcuts: written by tools/sync-readme.sh, do not edit by hand -->"
END="<!-- shortcuts: end -->"

grep -qF "$START" README.md || { echo "There is no shortcuts block in README.md."; exit 1; }

BLOCK="$(mktemp)"
SCRIPT="$(mktemp --suffix=.vim)"
HOMEDIR="$(mktemp -d)"
trap 'rm -rf "$BLOCK" "$SCRIPT" "$HOMEDIR"' EXIT

cat > "$SCRIPT" <<VIMEOF
autocmd VimEnter * call timer_start(200, {t -> [writefile(GrooVim_ShortcutsMarkdown(), "$BLOCK"), execute("qa!")]})
VIMEOF

GROOVIM_HOME="$HOMEDIR" timeout 30 script -qc \
  "'$VIM' -N -u '$PWD/.vimrc' -i NONE -n -S '$SCRIPT'" /dev/null >/dev/null 2>&1

[ -s "$BLOCK" ] || { echo "GrooVim wrote nothing. Is it loading?"; exit 1; }

python3 - "$BLOCK" "$START" "$END" <<'PYEOF'
import sys
block, start, end = open(sys.argv[1], encoding="utf-8").read(), sys.argv[2], sys.argv[3]
s = open("README.md", encoding="utf-8").read()
a = s.index(start) + len(start)
b = s.index(end)
new = s[:a] + "\n" + block + s[b:]
if new == s:
    print("The README already says what the list says.")
else:
    open("README.md", "w", encoding="utf-8").write(new)
    print("The README now says what the list says.")
PYEOF
