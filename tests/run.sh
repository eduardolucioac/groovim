#!/bin/bash
# Roda a bateria automática do GrooVim.
#
# Os testes ficam dentro do projeto: o ".vimrc" está um nível acima.
#
#   ./run.sh                 usa ../groovim/.vimrc
#   ./run.sh ~/.vimrc        usa outro .vimrc
#   ./run.sh '' 03_painel    roda um caso só
#
# Sai com 0 só se todos os casos terminarem e nenhuma verificação falhar.

cd "$(dirname "$0")" || exit 1
BASE="$PWD"
VIMRC="${1:-$BASE/../.vimrc}"
# Qual binario do Vim. Serve para rodar a bateria dentro do Vim proprio do
# GrooVim, construido pelo instalar-vim.sh, e nao so no do sistema.
VIM="${GROOVIM_TEST_VIM:-vim}"
FILTRO="${2:-}"
TEMPO="${GROOVIM_TEST_TIMEOUT:-90}"

if [ ! -f "$VIMRC" ]; then
  echo "Nao encontrei o .vimrc em: $VIMRC"; exit 1
fi

# Os casos rodam sobre uma CÓPIA das fixtures. Um caso que altere um arquivo em
# memória nunca chega perto dos originais.
TRABALHO="$(mktemp -d)"
trap 'rm -rf "$TRABALHO"' EXIT
cp -r "$BASE/fixtures/." "$TRABALHO/"

mkdir -p "$BASE/results"
rm -f "$BASE/results"/*.txt

export GROOVIM_TEST_FIXTURES="$TRABALHO"
export GROOVIM_TEST_OUT="$BASE/results"

# Uma "casa" do GrooVim descartável, uma por execução.
#
# Sem isso os casos se contaminam: cada um abre o Vim SEM arquivo, e a sessão
# automática do GrooVim restaura a do caso anterior -- as abas e os buffers
# chegam prontos e errados. É a mesma armadilha do viminfo, por outro caminho.
export GROOVIM_HOME="$TRABALHO/.groovim"

echo "vimrc: $VIMRC"
echo "vim:   $("$VIM" --version | sed -n '1p')"
echo

TOTAL=0; FALHAS=0; QUEBRADOS=0

for CASO in "$BASE"/cases/[0-9]*.vim; do
  NOME="$(basename "$CASO" .vim)"
  [ -n "$FILTRO" ] && [[ "$NOME" != *"$FILTRO"* ]] && continue

  # "script" dá um terminal de verdade: sem ele "input()" e as teclas dos
  # mapeamentos não se comportam como no uso real.
  #
  # "-i NONE" é essencial: sem ele o Vim restaura o viminfo e cada caso começa
  # com a lista de buffers do caso anterior -- inclusive uma lista de ocorrências
  # fantasma, que faz o "bufexists()" do Sync desistir de montar a de verdade.
  # Foi a causa de resultados que mudavam sem o código mudar.
  #
  # "-n" desliga o swap, senão um caso interrompido deixa um .swp que trava o
  # seguinte num prompt de recuperação.
  timeout "$TEMPO" script -qc "'$VIM' -N -u '$VIMRC' -i NONE -n -S '$CASO'" /dev/null >/dev/null 2>&1
  SAIDA="$BASE/results/$NOME.txt"

  echo "=== $NOME ==="
  if [ ! -f "$SAIDA" ]; then
    echo "  !! nao produziu resultado nenhum (travou ou morreu no inicio)"
    QUEBRADOS=$((QUEBRADOS + 1)); echo; continue
  fi

  sed '/^FIM$/d; s/^/ /' "$SAIDA"

  # "-a": um resultado com acento ou com a guia "|" nao pode virar binario
  N=$(grep -ac ' ok$\|ok   \|FALHOU' "$SAIDA")
  F=$(grep -ac 'FALHOU' "$SAIDA")
  TOTAL=$((TOTAL + N)); FALHAS=$((FALHAS + F))

  if ! grep -aq '^FIM$' "$SAIDA"; then
    echo "  !! o caso nao chegou ao fim -- parou depois da ultima linha acima"
    QUEBRADOS=$((QUEBRADOS + 1))
  fi
  echo
done

echo "-----------------------------------------------"
printf 'verificacoes: %s   falhas: %s   casos incompletos: %s\n' "$TOTAL" "$FALHAS" "$QUEBRADOS"
if [ "$FALHAS" -eq 0 ] && [ "$QUEBRADOS" -eq 0 ]; then
  echo "tudo passou."
  exit 0
fi
exit 1
