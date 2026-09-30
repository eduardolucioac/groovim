#!/usr/bin/env python3
"""In and out of the modes, with one key each.

Shift+Up walks towards typing and back out of it; Shift+Down walks towards
selecting and back out of it. The bar at the bottom says which mode you are in,
and so does the colour of the cursor: green in normal, orange while typing,
blue over a selection.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lib import Demo

demo = Demo("07_modes", [
    "a line to type on",
    "and another one under it",
], colunas=84, alturas=12)

demo.espera(0.7)

# ---- towards typing, and back
demo.tecla("S-Up", espera=1.0)
demo.escreve("here I am -- ", por_tecla=0.07, espera=0.8)
demo.tecla("S-Up", espera=1.3)

# ---- towards selecting, and back
demo.tecla("S-Down", espera=1.0)
demo.tecla(*(["Right"] * 12), espera=0.8)
demo.tecla("Down", espera=1.0)
demo.tecla("S-Down", espera=1.4)

caminho = demo.fim()
print(caminho)
