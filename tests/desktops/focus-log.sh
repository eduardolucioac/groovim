#!/bin/bash
SAIDA="$1"
{ echo "tty=$(tty)"; echo "pid=$$"; } > "$SAIDA"
printf '\e[?1004h' > /dev/tty
fim=$((SECONDS + 40))
while [ $SECONDS -lt $fim ]; do
  IFS= read -r -s -t 1 -N 3 c < /dev/tty && printf '[%s] em %ss\n' "$(printf '%s' "$c" | cat -v)" "$SECONDS" >> "$SAIDA"
done
