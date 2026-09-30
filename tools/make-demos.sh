#!/bin/bash
# Makes the demo GIFs of GrooVim, out of the scripts in "demos/".
#
#   ./tools/make-demos.sh                 all of them
#   ./tools/make-demos.sh 01_multi_caret  one, by name
#
# Each script presses real keys in a GrooVim of its own and writes an asciicast;
# "agg" turns that into the GIF. Nothing here is recorded by hand -- change the
# editor, run this again, and the GIFs say what the editor says now.
#
# What it needs: the Vim GrooVim builds (install.sh), and "agg":
#
#   paru -S asciinema-agg-bin        # Arch, CachyOS
#   cargo install --git https://github.com/asciinema/agg
#   podman run --rm -v "$PWD:/d" ghcr.io/asciinema/agg /d/x.cast /d/x.gif

set -eu
cd "$(dirname "$0")/.." || exit 1

FILTER="${1:-}"
AGG="${AGG:-agg}"

if ! command -v "$AGG" >/dev/null 2>&1; then
  echo "I cannot find \"agg\", which is what turns a recording into a GIF."
  echo "Install it with:  paru -S asciinema-agg-bin"
  echo "Or point AGG at it:  AGG=/path/to/agg ./tools/make-demos.sh"
  exit 1
fi

# The look of the GIFs, in one place.
#
# The font size decides how big the GIF comes out: 14 over 84 columns lands near
# 725 pixels, which is the width a README shows without shrinking it.
FONT_SIZE="${GROOVIM_DEMO_FONT:-14}"
FONT_FAMILY="${GROOVIM_DEMO_FONT_FAMILY:-MesloLGS Nerd Font Mono,JetBrains Mono,DejaVu Sans Mono}"
LINE_HEIGHT="${GROOVIM_DEMO_LINE_HEIGHT:-1.2}"

# The COLOURS of the terminal, and they are not a taste: they are the ones
# GrooVim is drawn against. This is Breeze Teal, the scheme of KDE, written out
# as agg wants it -- background, foreground, the eight normal colours and the
# eight bright ones.
#
# The built-in themes of agg (monokai, dracula, nord...) are the palettes of
# OTHER editors, and a demo painted in one of them shows a GrooVim nobody has:
# the first cut of these was in monokai and the greens and oranges of the real
# thing came out as other greens and other oranges.
#
# Any of the names agg knows still works: GROOVIM_DEMO_THEME=github-light.
THEME="${GROOVIM_DEMO_THEME:-141618,eff0f1,232629,ed1515,2fbf6f,f67400,1d99f3,9b59b6,16a085,eff0f1,7f8c8d,f44f4f,1cdc9a,fdbc4b,3daee9,b76ecf,1abc9c,fcfcfc}"
# A pause longer than this is cut down to it: standing still is what lets the eye
# read, but three seconds of nothing is three seconds of file.
IDLE="${GROOVIM_DEMO_IDLE:-1.0}"
# A hair faster than it was typed. A demo is read, not followed key by key.
SPEED="${GROOVIM_DEMO_SPEED:-1.15}"

for SCRIPT in demos/[0-9]*.py; do
  NAME="$(basename "$SCRIPT" .py)"
  [ -n "$FILTER" ] && [[ "$NAME" != *"$FILTER"* ]] && continue

  echo "==> $NAME"
  python3 "$SCRIPT" >/dev/null
  CAST="demos/$NAME.cast"
  GIF="demos/$NAME.gif"

  "$AGG" --font-size "$FONT_SIZE" --font-family "$FONT_FAMILY" \
    --line-height "$LINE_HEIGHT" --theme "$THEME" --speed "$SPEED" \
    --idle-time-limit "$IDLE" --last-frame-duration 2 \
    "$CAST" "$GIF" >/dev/null

  # Note: The FIRST frame for the size. A GIF stores the others as the rectangle
  # that CHANGED, so asking the file its dimensions answers one line per frame.
  SIZE="$(du -h "$GIF" | cut -f1)"
  DIMS="$(identify -format '%wx%h' "$GIF[0]" 2>/dev/null || echo '?')"
  FRAMES="$(identify "$GIF" 2>/dev/null | wc -l)"
  SECONDS_LONG="$(ffprobe -v error -show_entries format=duration \
    -of default=noprint_wrappers=1:nokey=1 "$GIF" 2>/dev/null || echo '?')"
  echo "    $GIF -- $DIMS, $FRAMES frames, ${SECONDS_LONG}s, $SIZE"
done
