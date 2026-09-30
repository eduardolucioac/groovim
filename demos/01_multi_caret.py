#!/usr/bin/env python3
"""Writing in several places at once: the two keys of it.

Act one, F2->n: whole LINES. The line you start on is the anchor, the arrows
take in the ones below, and what you type lands on every one of them.

Act two, F2->m: places that have nothing to do with each other -- three
different columns on three lines. They are marked one by one, green while you
are still choosing, and the first Esc sets them and turns them yellow. From
there everything happens in all of them.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lib import Demo

demo = Demo("01_multi_caret", [
    "print(alpha)",
    "log(beta)",
    "send(gamma)",
], colunas=84, alturas=10)

demo.espera(0.7)

# ---- act one: whole lines
demo.tecla("F2", "n", espera=0.5)
demo.tecla("Down", espera=0.35)
demo.tecla("Down", espera=0.7)
demo.escreve("await ", por_tecla=0.06, espera=0.7)
demo.tecla("Esc", espera=0.9)

# ---- act two: places of their own, each at its own column
#
# A caret is drawn OVER the character it sits on, so the places are characters
# and not the empty column after the end of a line: the first letter inside the
# parentheses, which on these three lines is three different columns.
demo.tecla("gg", espera=0.3)
demo.tecla(*(["Right"] * 12), espera=0.35)
demo.tecla("F2", "m", espera=0.55)
demo.tecla("Down", "Left", "Left", espera=0.35)
demo.tecla("F2", "m", espera=0.55)
demo.tecla("Down", "Right", espera=0.35)
demo.tecla("F2", "m", espera=0.8)
demo.tecla("Esc", espera=1.0)
demo.escreve("my_", por_tecla=0.1, espera=1.1)
demo.tecla("Esc", espera=0.4)
demo.tecla("Esc", espera=1.0)

caminho = demo.fim()
print(caminho)
