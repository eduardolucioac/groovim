#!/usr/bin/env python3
"""The linter of GrooVim, and the formatter of its notes.

    ./tools/lint.py            says what is wrong
    ./tools/lint.py --fix      reflows the notes and writes the files

There is no "black" for VimScript. The only linter there is, "vint", has had no
release since 2019 and judges a style of its own -- so this is ours, and it
checks the four things this project decided:

  * every part opens with a banner and a name;
  * a line does not run past 85 columns;
  * no line ends in blank space;
  * no line is indented with a tab.

Two numbers and not one. Notes are REWRITTEN to 80, which is where --fix wraps
them, and nothing is COMPLAINED about until 85: the five columns in between are
for the line that would read worse broken than long -- a name, an address, a
word that has nowhere to break.

Past 85 it is an error on a comment, which --fix can rewrite, and a warning on
code, which it cannot: there are lines that will not break -- the text of the
help, a long "exec" -- and a rule that cannot be obeyed is a rule nobody reads.
"""

import os
import re
import sys

# Where a note is wrapped, and where complaining starts.
LARGURA = 80
LIMITE = 85
AQUI = os.path.dirname(os.path.abspath(__file__))
PROJETO = os.path.dirname(AQUI)


def arquivos():
    partes = sorted(
        os.path.join("groovim", f)
        for f in os.listdir(os.path.join(PROJETO, "groovim"))
        if f.endswith(".vim"))
    return [".vimrc"] + partes


# ---------------------------------------------------------------- the notes ---

def e_comentario(linha):
    return linha.lstrip().startswith('"')


def e_bandeira(linha):
    """A line that is a drawing and not a sentence: the "$" of a section, the
    "=D" of the ones at the top of the .vimrc, a row of dashes. Whatever it is,
    it is one thing repeated, it has no words in it, and nobody reflows it."""
    if not e_comentario(linha):
        return False
    conteudo = re.sub(r'^\s*"\s*', "", linha).strip()
    if conteudo == "":
        return False
    return re.fullmatch(r"(.{1,2}?)\1{4,}", conteudo) is not None


def texto_de(linha):
    """What a comment line SAYS, without the quote and the space after it."""
    return re.sub(r'^\s*"\s?', "", linha).rstrip()


def literal(paragrafo):
    """A paragraph nobody may reflow: an example, a command, a drawing.

    What gives it away is the shape. A line of prose begins at the left of the
    block; an example is pushed further in, or carries the ">" and "<" that Vim
    help uses to open and close one. Rewrapping those turns a command you can
    copy into a sentence you cannot.
    """
    for linha in paragrafo:
        conteudo = texto_de(linha)
        if conteudo.startswith(" ") or conteudo.startswith("\t"):
            return True
        if conteudo.endswith(">") or conteudo == "<":
            return True
    return False


def enrola(texto, recuo):
    """The words of one paragraph, broken at the width."""
    largura = LARGURA - len(recuo) - 2         # the recuo, the quote, the space
    saida = []
    linha = ""
    for palavra in texto.split():
        if linha == "":
            linha = palavra
        elif len(linha) + 1 + len(palavra) <= largura:
            linha = linha + " " + palavra
        else:
            saida.append(recuo + '" ' + linha)
            linha = palavra
    if linha:
        saida.append(recuo + '" ' + linha)
    return saida


def reflui(paragrafo, recuo):
    """One paragraph, rewrapped to the limit. The "Note:" stays at the front.

    And a "Note:" that is found INSIDE the paragraph is not inside it at all:
    it is another note that was written under this one with no blank line
    between them, and joining the two is exactly what this used to do. Thirty
    four of them were joined that way before the rule existed -- "...walking two
    by two. Note: What a key really delivers" -- so the split is done here, and
    the notes come out two again, with the blank line the style wants.
    """
    junto = " ".join(texto_de(l) for l in paragrafo).strip()
    if junto == "":
        return paragrafo
    pedacos = re.split(r"\s+(?=Note:\s)", junto)
    saida = []
    for numero, pedaco in enumerate(pedacos):
        if numero:
            saida.append(recuo + '"')
        saida.extend(enrola(pedaco, recuo))
    return saida


def blocos(linhas):
    """Walks the file handing over each block of comment lines it finds."""
    i = 0
    while i < len(linhas):
        if not e_comentario(linhas[i]) or e_bandeira(linhas[i]):
            i += 1
            continue
        comeco = i
        recuo = re.match(r"^\s*", linhas[i]).group(0)
        while (i < len(linhas) and e_comentario(linhas[i])
               and not e_bandeira(linhas[i])
               and re.match(r"^\s*", linhas[i]).group(0) == recuo):
            i += 1
        yield comeco, i, recuo


def formata(linhas):
    """The file with its notes reflowed. Only the notes: a block that does not
    begin with "Note:" is somebody's commented-out code or a heading, and the
    only safe thing to do with those is nothing."""
    saida = []
    fim_anterior = 0
    for comeco, fim, recuo in blocos(linhas):
        saida.extend(linhas[fim_anterior:comeco])
        bloco = linhas[comeco:fim]
        if not texto_de(bloco[0]).startswith("Note:"):
            saida.extend(bloco)
            fim_anterior = fim
            continue
        paragrafo = []
        novo = []
        for linha in bloco + [None]:
            vazia = linha is None or texto_de(linha) == ""
            # Note: And a line that OPENS with "Note:" opens a paragraph, blank
            # line above it or not. Without this the two notes were one block of
            # prose to join, and joining them is what did the damage.
            if not vazia and paragrafo and texto_de(linha).startswith("Note:"):
                novo.extend(paragrafo if literal(paragrafo)
                            else reflui(paragrafo, recuo))
                novo.append(recuo + '"')
                paragrafo = [linha]
                continue
            if vazia:
                if paragrafo:
                    novo.extend(paragrafo if literal(paragrafo)
                                else reflui(paragrafo, recuo))
                    paragrafo = []
                if linha is not None:
                    novo.append(linha.rstrip())
            else:
                paragrafo.append(linha)
        saida.extend(novo)
        fim_anterior = fim
    saida.extend(linhas[fim_anterior:])
    return saida


# ------------------------------------------------------------- the checking ---

def cabecalho(linhas):
    """The name in the banner at the top of a file, or "" when there is none.

    A banner is a drawing, a name, and the drawing again. The ".vimrc" opens
    with three lines of name between two drawings, which is why what is read
    here is "the first words between two of them" and not "the line after".
    """
    for i in range(min(len(linhas), 40)):
        if not e_bandeira(linhas[i]):
            continue
        for j in range(i + 2, min(i + 6, len(linhas))):
            if e_bandeira(linhas[j]):
                nomes = [texto_de(l).strip() for l in linhas[i + 1:j]]
                nomes = [n for n in nomes if n]
                return nomes[0] if nomes else ""
    return ""


def olha(caminho, linhas):
    erros = []
    avisos = []

    if cabecalho(linhas) == "":
        erros.append("%s: no banner with a name at the top" % caminho)

    for numero, linha in enumerate(linhas, 1):
        onde = "%s:%d" % (caminho, numero)
        if linha != linha.rstrip():
            erros.append("%s: blank space at the end of the line" % onde)
        if re.match(r"^ *\t", linha):
            erros.append("%s: indented with a tab" % onde)
        if len(linha) > LIMITE and not e_bandeira(linha):
            exemplo = e_comentario(linha) and texto_de(linha).startswith(" ")
            if e_comentario(linha) and not exemplo:
                erros.append("%s: a comment of %d columns, past the %d it is"
                             " given (--fix wraps it at %d)"
                             % (onde, len(linha), LIMITE, LARGURA))
            else:
                avisos.append("%s: %d columns" % (onde, len(linha)))
    return erros, avisos


def main():
    conserta = "--fix" in sys.argv
    quietos = "--quiet" in sys.argv
    os.chdir(PROJETO)

    erros = []
    avisos = []
    mexidos = []
    for caminho in arquivos():
        linhas = open(caminho).read().splitlines()
        if conserta:
            novo = formata(linhas)
            if novo != linhas:
                open(caminho, "w").write("\n".join(novo) + "\n")
                mexidos.append(caminho)
                linhas = novo
        e, a = olha(caminho, linhas)
        erros.extend(e)
        avisos.extend(a)

    if mexidos:
        print("reflowed: " + ", ".join(mexidos))
        print()
    for erro in erros:
        print("  " + erro)
    if avisos and not quietos:
        if erros:
            print()
        print("  and %d lines of CODE past %d columns, which is a warning and"
              % (len(avisos), LIMITE))
        print("  not a failure -- the text of the help and some execs cannot be")
        print("  broken. --quiet leaves this out.")
        for aviso in avisos[:10]:
            print("    " + aviso)
        if len(avisos) > 10:
            print("    ... and %d more" % (len(avisos) - 10))
    if not erros:
        print("\nnothing to fix." if not avisos else "\nno errors.")
    return 1 if erros else 0


if __name__ == "__main__":
    sys.exit(main())
