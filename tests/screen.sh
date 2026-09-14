#!/bin/bash
# Mostra a TELA que o Vim desenhou, reconstruida a partir do que ele mandou para
# o terminal.
#
#   ./screen.sh roteiro.vim [arquivo]
#
# O "roteiro.vim" agenda as teclas com timer_start e termina com ":qa!".
# Exemplo:
#   call timer_start(400,  {-> feedkeys("\<F3>f", "t")})
#   call timer_start(900,  {-> feedkeys("ALVO\<CR>", "t")})
#   call timer_start(2400, {-> execute("qa!")})
#
# Para qualquer pergunta sobre LAYOUT -- onde o prompt caiu, se a barra mudou, o
# que a aba mostra, se ha uma linha em branco sobrando -- esta e a ferramenta.
# Inspecionar o estado por dentro (winnr, bufname) responde outra pergunta.

cd "$(dirname "$0")" || exit 1
ROTEIRO="$1"
ARQUIVO="${2:-$PWD/fixtures/a.txt}"
VIMRC="${VIMRC:-$PWD/../.vimrc}"

if [ -z "$ROTEIRO" ]; then
  echo "uso: ./screen.sh roteiro.vim [arquivo]"; exit 1
fi

# Uma "casa" do GrooVim descartável, pelo mesmo motivo do run.sh: sem isso o
# roteiro de tela grava a SUA sessão, com os arquivos temporários dele dentro.
export GROOVIM_HOME="$(mktemp -d)"
trap 'rm -rf "$GROOVIM_HOME"' EXIT

LOG="$(mktemp)"
trap 'rm -f "$LOG"' EXIT
timeout 20 script -qc "vim -N -u '$VIMRC' -i NONE -n -S '$ROTEIRO' '$ARQUIVO'" /dev/null > "$LOG" 2>&1
python3 "$PWD/screen.py" "$LOG"
