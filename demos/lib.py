"""The typist of the demos.

A demo is a SCRIPT and not a recording made by hand. The reason is the same one
the battery has: what is recorded by hand rots the day the thing recorded
changes, and nobody records it again. This is regenerated with one command.

It opens a terminal of its own -- a pty of the size the GIF will have -- runs
GrooVim in it, presses real keys and writes down everything the terminal was
sent, with the times. That file is an asciicast, and "agg" turns it into a GIF.

Why not VHS, which is what everybody uses for this: its tape language has no
F1..F12, and GrooVim IS the F keys. It has no Alt with the arrows either, and no
mouse. This presses anything a keyboard can send.
"""

import json
import os
import pty
import select
import shutil
import struct
import fcntl
import termios
import time

AQUI = os.path.dirname(os.path.abspath(__file__))
PROJETO = os.path.dirname(AQUI)

# The keys, by the name they are pressed with.
TECLAS = {
    "F1": "\x1bOP", "F2": "\x1bOQ", "F3": "\x1bOR", "F4": "\x1bOS",
    "F5": "\x1b[15~", "F6": "\x1b[17~", "F7": "\x1b[18~", "F8": "\x1b[19~",
    "F9": "\x1b[20~", "F10": "\x1b[21~", "F11": "\x1b[23~", "F12": "\x1b[24~",
    "Up": "\x1b[A", "Down": "\x1b[B", "Right": "\x1b[C", "Left": "\x1b[D",
    "Home": "\x1b[H", "End": "\x1b[F", "PageUp": "\x1b[5~", "PageDown": "\x1b[6~",
    "Del": "\x1b[3~", "Insert": "\x1b[2~",
    "Esc": "\x1b", "Enter": "\r", "Tab": "\t", "BS": "\x7f", "Space": " ",
    "S-Up": "\x1b[1;2A", "S-Down": "\x1b[1;2B",
    "S-Left": "\x1b[1;2D", "S-Right": "\x1b[1;2C",
    "A-S-Up": "\x1b[1;4A", "A-S-Down": "\x1b[1;4B",
    "A-S-Left": "\x1b[1;4D", "A-S-Right": "\x1b[1;4C",
    "C-A-Up": "\x1b[1;7A", "C-A-Down": "\x1b[1;7B",
    "C-A-Left": "\x1b[1;7D", "C-A-Right": "\x1b[1;7C",
    "C-Left": "\x1b[1;5D", "C-Right": "\x1b[1;5C",
    "C-Up": "\x1b[1;5A", "C-Down": "\x1b[1;5B",
}


class Demo:
    """One demo: a file to edit, a terminal, and the keys pressed in it."""

    def __init__(self, nome, linhas, colunas=80, alturas=14, arquivo="exemplo.txt",
                 opcoes=()):
        self.nome = nome
        self.colunas = colunas
        self.alturas = alturas
        self.casa = os.path.join("/tmp", "groovim-demo-" + nome)
        shutil.rmtree(self.casa, ignore_errors=True)
        os.makedirs(self.casa)
        self.alvo = os.path.join(self.casa, arquivo)
        with open(self.alvo, "w") as f:
            f.write("\n".join(linhas) + "\n")
        # Note: The settings a demo needs, written where GrooVim reads the ones
        # you chose to keep. A demo that has to show what a setting does cannot
        # ask for it on camera -- the answer would be the demo.
        if opcoes:
            os.makedirs(os.path.join(self.casa, ".groovim"), exist_ok=True)
            with open(os.path.join(self.casa, ".groovim", "opts.vim"), "w") as f:
                f.write("\n".join(opcoes) + "\n")
        self.eventos = []
        self._abre()

    def _abre(self):
        # A GrooVim of its own: its own home, no session of anybody's coming
        # back, nothing of the machine this was recorded on.
        ambiente = dict(
            os.environ,
            HOME=self.casa,
            TERM="xterm-256color",
            GROOVIM_HOME=os.path.join(self.casa, ".groovim"),
        )
        vim = os.path.expanduser("~/.local/share/groovim/bin/vim")
        vimrc = os.path.join(PROJETO, ".vimrc")
        self.pid, self.fd = pty.fork()
        if self.pid == 0:
            os.execve(vim, [vim, "-u", vimrc, "-i", "NONE", self.alvo], ambiente)
        fcntl.ioctl(self.fd, termios.TIOCSWINSZ,
                    struct.pack("HHHH", self.alturas, self.colunas, 0, 0))
        self.inicio = time.time()
        self._le(2.5)

    def _le(self, quanto):
        """Reads what the terminal was sent, keeping the time of each piece."""
        fim = time.time() + quanto
        while time.time() < fim:
            pronto, _, _ = select.select([self.fd], [], [], 0.05)
            if not pronto:
                continue
            try:
                dados = os.read(self.fd, 65536)
            except OSError:
                return
            if dados:
                self.eventos.append([round(time.time() - self.inicio, 3), "o",
                                     dados.decode("utf-8", "replace")])

    def tecla(self, *nomes, espera=0.7):
        """Presses keys by name: tecla("F2", "n")."""
        for nome in nomes:
            os.write(self.fd, TECLAS.get(nome, nome).encode())
            self._le(0.12)
        self._le(espera)

    def escreve(self, texto, por_tecla=0.09, espera=0.7):
        """Types, one key at a time, the way a person does."""
        for letra in texto:
            os.write(self.fd, letra.encode())
            self._le(por_tecla)
        self._le(espera)

    def espera(self, quanto):
        """Stands still, which is what lets the eye read the screen."""
        self._le(quanto)

    def fim(self, caminho=None):
        """Closes the terminal and writes the asciicast."""
        try:
            os.kill(self.pid, 9)
            os.waitpid(self.pid, 0)
        except Exception:
            pass
        caminho = caminho or os.path.join(AQUI, self.nome + ".cast")
        cabecalho = {"version": 2, "width": self.colunas, "height": self.alturas,
                     "env": {"TERM": "xterm-256color", "SHELL": "/bin/bash"}}
        with open(caminho, "w") as f:
            f.write(json.dumps(cabecalho) + "\n")
            for evento in self.eventos:
                f.write(json.dumps(evento) + "\n")
        shutil.rmtree(self.casa, ignore_errors=True)
        return caminho
