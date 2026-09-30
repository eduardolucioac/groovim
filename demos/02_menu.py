#!/usr/bin/env python3
"""The menu of F10: the map of the editor, and it does things.

A bar across the top with what GrooVim does, cut into sections. The arrows walk
it, an F key jumps straight to the section that F key lives in, and Enter runs
the line you are on -- here the Title Case of the word under the cursor.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lib import Demo

demo = Demo("02_menu", [
    "the quick brown fox",
    "jumps over the lazy dog",
], colunas=84, alturas=12)

demo.espera(0.6)

# the word the menu is going to change
demo.tecla(*(["Right"] * 4), espera=0.5)

demo.tecla("F10", espera=0.9)
demo.tecla("Right", espera=0.7)     # Edit
demo.tecla("Right", espera=0.7)     # Select
demo.tecla("Right", espera=0.9)     # Search
demo.tecla("F2", espera=0.9)        # straight back to Edit: the F key of it

# Title Case is the sixth line of that section
for _ in range(5):
    demo.tecla("Down", espera=0.3)
demo.espera(0.6)
demo.tecla("Enter", espera=1.6)

caminho = demo.fim()
print(caminho)
