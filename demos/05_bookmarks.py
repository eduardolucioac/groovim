#!/usr/bin/env python3
"""Marked lines: the bookmarks of the Search menu of Notepad++.

F4->b marks the line you are on and the mark shows in the margin. F4->i writes
a note on it. "m" and "M" walk from one to the next and back, and F4->l lists
every one of them in a panel.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lib import Demo

demo = Demo("05_bookmarks", [
    "func open(path)",
    "  read(path)",
    "  parse()",
    "  return",
    "end",
    "",
    "func save(path)",
    "  write(path)",
    "end",
], colunas=84, alturas=16)

demo.espera(0.7)

# ---- two marks
demo.tecla("Down", espera=0.3)
demo.tecla("F4", "b", espera=0.9)
demo.tecla("Down", "Down", "Down", "Down", "Down", "Down", espera=0.5)
demo.tecla("F4", "b", espera=1.0)

# ---- a note on this one
demo.tecla("F4", "i", espera=1.0)
demo.escreve("watch the encoding here", por_tecla=0.05, espera=0.6)
demo.tecla("Enter", espera=1.3)

# ---- walking between them
demo.tecla("m", espera=1.0)
demo.tecla("m", espera=1.2)

# ---- and all of them in a list
demo.tecla("F4", "l", espera=1.8)

caminho = demo.fim()
print(caminho)
