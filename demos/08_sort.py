#!/usr/bin/env python3
"""Putting the selected lines in order: F2->o.

Twice over the same four lines, because the second time is what a sort of a
text editor usually cannot do: a BLOCK says which column to compare FROM, so
the same lines come out in order of the NAME instead of the date.

The result comes back selected either time, which is what the last press shows.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lib import Demo

demo = Demo("08_sort", [
    "2026-03-11  Maria",
    "2024-07-02  Joao",
    "2025-12-30  Ana",
    "2023-05-20  Bruno",
], colunas=72, alturas=12)

demo.espera(0.8)

# Note: Selected with the keys of GrooVim and not with a "V": Shift+Down is how
# a selection is opened here, and a demo that uses the Vim underneath to set up
# what it is about shows the wrong editor.
demo.tecla("S-Down", espera=0.5)
demo.tecla("Down", espera=0.35)
demo.tecla("Down", espera=0.35)
demo.tecla("Down", espera=0.9)

demo.tecla("F2", "o", espera=2.0)     # by the whole line, which begins with the date
demo.tecla("Esc", espera=0.9)

# Note: And now by a FIELD. The block opens on the column the names begin at and
# the sort compares FROM there -- the dates are left out of the comparison, not
# out of the lines.
#
# Back to the first line before opening it: the sort leaves you on the END of
# what it put in order, which is the last line, and a block opened there has
# nothing under it to take.
demo.tecla("gg", espera=0.4)
demo.tecla("13|", espera=0.7)
demo.tecla("F2", "b", espera=0.9)
demo.tecla("Down", espera=0.3)
demo.tecla("Down", espera=0.3)
demo.tecla("Down", espera=0.5)
demo.tecla("$", espera=1.0)

demo.tecla("F2", "o", espera=2.4)     # in order of the name, and still selected

caminho = demo.fim()
print(caminho)
