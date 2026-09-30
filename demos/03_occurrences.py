#!/usr/bin/env python3
"""The occurrence list: the panel of Notepad++.

F3->f searches, and offers the word under the cursor -- Enter takes the offer.
With the list switched on, every line the word is in comes up in a panel of its
own, and Enter on one of them goes there.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lib import Demo

demo = Demo("03_occurrences", [
    "alpha = 1",
    "beta  = alpha + 2",
    "gamma = alpha * 3",
    "delta = 4",
    "sigma = alpha - 5",
], colunas=84, alturas=16, opcoes=["let g:search_WithList = 1"])

demo.espera(0.7)
demo.tecla("F3", "f", espera=1.5)     # it offers the word under the cursor
demo.tecla("Enter", espera=2.0)       # taking the offer opens the list
demo.tecla("Down", espera=0.7)
demo.tecla("Down", espera=0.9)
demo.tecla("Enter", espera=1.8)       # and it goes to that occurrence

caminho = demo.fim()
print(caminho)
