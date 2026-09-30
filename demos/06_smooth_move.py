#!/usr/bin/env python3
"""Walking the text smoothly: Alt+Shift and the arrows.

It glides instead of jumping, it goes over the places where there is no text --
short lines, the gap after the end of one -- and it carries a selection along
if there is one.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lib import Demo

demo = Demo("06_smooth_move", [
    "the first line, a long one, is where this starts",
    "short",
    "",
    "another long line, further down and to the right",
    "tiny",
    "and the last one, which is long again as well",
], colunas=84, alturas=12)

demo.espera(0.7)

# Note: Put where the walk starts in one go -- "30|" is a column, and a demo
# that spends four seconds walking to the place it wants to start from is four
# seconds of nothing.
demo.tecla("30|", espera=0.6)
demo.tecla("A-S-Down", espera=0.9)
demo.tecla("A-S-Down", espera=0.9)
demo.tecla("A-S-Down", espera=1.0)
demo.tecla("A-S-Right", espera=0.9)
demo.tecla("A-S-Up", espera=1.0)
demo.tecla("A-S-Up", espera=1.4)

caminho = demo.fim()
print(caminho)
