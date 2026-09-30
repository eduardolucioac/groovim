#!/usr/bin/env python3
"""Writing in several places at once: the two keys of it.

Act one, F2->n: whole LINES. The line you start on is the anchor, the arrows
take in the ones below, and what you type lands on every one of them.

Act two, F2->m: places that have nothing to do with each other. You mark them
one by one -- green while you are choosing -- and the first Esc sets them, turns
them yellow, and from there everything happens in all of them.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lib import Demo

demo = Demo("01_multi_caret", [
    "alpha  = 1",
    "beta   = 2",
    "gamma  = 3",
    "delta  = 4",
], colunas=76, alturas=12)

demo.espera(1.0)

# ---- act one: whole lines
demo.tecla("F2", "n")
demo.espera(0.6)
demo.tecla("Down", espera=0.45)
demo.tecla("Down", espera=0.45)
demo.tecla("Down", espera=0.8)
demo.escreve("const ", espera=1.2)
demo.tecla("Esc", espera=1.4)

# ---- act two: places of their own
demo.tecla("End", espera=0.5)
demo.tecla("F2", "m")
demo.espera(0.6)
demo.tecla("Down", "End", espera=0.5)
demo.tecla("F2", "m")
demo.espera(0.6)
demo.tecla("Down", "End", espera=0.5)
demo.tecla("F2", "m")
demo.espera(0.9)
demo.tecla("Esc", espera=1.0)
demo.escreve(";", espera=1.4)
demo.tecla("Esc", espera=0.6)
demo.tecla("Esc", espera=1.6)

caminho = demo.fim()
print(caminho)
