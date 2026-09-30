#!/usr/bin/env python3
"""The About, which is a dialogue: buttons, and two ways out.

Left and Right walk the buttons, the blue one is the chosen one, Enter presses
it and the mouse clicks it. "c" copies what a dialogue says -- any of them --
and an address in the text is a link.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lib import Demo

demo = Demo("04_about", [
    "GrooVim: a Vim of its own, remodelled for a",
    "simpler, smarter experience.",
], colunas=84, alturas=14)

demo.espera(0.6)
demo.tecla("F5", "/", espera=1.6)
demo.tecla("Left", espera=1.0)      # to "Open page"
demo.tecla("Right", espera=1.0)     # back to the way out
demo.tecla("Esc", espera=1.2)

caminho = demo.fim()
print(caminho)
