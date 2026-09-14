# Bateria automática do GrooVim

Testes que rodam sozinhos, para não quebrar o que já funciona. Complementam o
`_TESTE_GROOVIM/00_ROTEIRO.md`, que é o teste manual — este aqui verifica o
comportamento por dentro; o roteiro verifica o que se vê.

## Rodar

```bash
./rodar.sh                    # usa ../groovim/.vimrc
./rodar.sh ~/.vimrc           # testa o que está instalado
./rodar.sh '' 03_painel       # um caso só
```

Sai com `0` só se todos os casos chegarem ao fim e nenhuma verificação falhar.
A bateria inteira leva cerca de **1,5 segundo**.

Um caso que trava é detectado: o executor mata em 90 segundos e avisa
`o caso nao chegou ao fim`. Para baixar essa espera:
`GROOVIM_TESTE_TEMPO=15 ./rodar.sh`.

## Os casos

| caso | o que cobre |
|---|---|
| `01_replace` | contador de ocorrências, `gdefault`, wrap com confirmação, cursor e rolagem voltando ao lugar, `Ctrl-C`/`Ctrl-X`, `cmdheight` |
| `02_abas_replace` | substituição em várias abas, cursor de **cada** aba preservado, as duas semânticas do `TabDo` |
| `03_painel` | a lista como buffer de leitura (`nofile`, `wipe`, não listado), a barra do Notepad++, `Enter` navega e `Del` não |
| `04_teclas` | nenhuma tecla de edição faz nada na lista, em normal **e** em visual; `y`, setas, `gg`, `G` e `PageDown` continuam |
| `05_navegacao` | `Enter` leva ao lugar certo; links para aba inexistente, aba com outro arquivo, arquivo já aberto, caminho com vírgula |
| `06_ciclo_abas` | `:q` fecha a **aba** (das duas janelas), o buffer da lista morre junto, reabrir traz a lista |
| `07_tabline` | o rótulo da aba é sempre um arquivo seu, a contagem ignora acessórios, o `+` de modificado |
| `08_lista_sobrevive` | fechado o último arquivo a lista fica; reabrir a partir dela; a saída pelo `:q` |
| `09_opcoes` | o texto do prompt montado a partir das opções, e a validação das respostas |
| `10_guias` | a largura da guia de indentação seguindo `shiftwidth`/`tabstop` |
| `11_movimento` | `Ctrl-Alt` com as setas andando em linha reta, mesmo por linhas curtas |
| `12_opcoes_salvas` | guardar uma opção para a próxima sessão, e o "só aplicar" |
| `13_arquivo` | o grupo `F5` (salvar, fechar) e a macro que para com as mesmas teclas |
| `14_sessao` | a sessão automática, e os comandos manuais avisando quando ela está ligada |
| `15_aplicar_guardar` | a pergunta final das telas: só aplicar, ou aplicar e guardar |

Cada caso escreve em `resultados/<nome>.txt`, **linha a linha**, e termina
com `FIM` — o executor cobra essa marca. Um caso que termina fazendo o próprio
Vim sair usa `GT_FimAqui()` antes do passo que sai.

## Ver a tela

Para qualquer pergunta de **layout** — onde o prompt caiu, se sobrou linha em
branco, o que a aba mostra, se a barra mudou — inspecionar o estado por dentro
não serve. Use:

```bash
./tela.sh meu_roteiro.vim [arquivo]
```

O roteiro agenda teclas e termina saindo:

```vim
call timer_start(400,  {-> feedkeys("\<F3>f", "t")})
call timer_start(900,  {-> feedkeys("ALVO\<CR>", "t")})
call timer_start(2400, {-> execute("qa!")})
```

O `tela.py` reconstrói a tela a partir do que o Vim mandou para o terminal.

**Cuidado:** o Vim redesenha só o que mudou, então a reconstrução pode misturar
o desenho novo com restos do antigo. Quando a pergunta for *em que coluna está
tal caractere*, use `screenchar(linha, coluna)` de dentro do próprio Vim — é a
tela que ele enxerga, sem intermediário. O caso `10_guias` faz isso.

## Armadilhas que custaram caro

Cada uma destas já produziu um diagnóstico errado. Estão aqui para não se repetir.

**Marcar os passos com tempo fixo produz caso instável.** O `feedkeys` com `"t"`
enfileira as teclas, e o Vim só as processa ao voltar para o laço principal — um
timer que dispara antes disso amostra cedo, e o caso falha sem que nada esteja
errado no produto. Medido: o mesmo caso passando e falhando em execuções
seguidas. Use `GT_Quando('condição', "ProximoPasso")`, que espera a condição
virar verdadeira antes de seguir.

**A sessão automática contamina do mesmo jeito.** Cada caso abre o Vim sem
arquivo, que é justamente quando o GrooVim traz a sessão de volta — e ela é a do
caso anterior, com abas e buffers já prontos e errados. O executor dá a cada
execução uma `GROOVIM_HOME` descartável, o que isola de uma vez a sessão, as
opções salvas, o undo e o `viminfo` do GrooVim.

**O `viminfo` contamina tudo.** Sem `-i NONE`, o Vim restaura a lista de buffers
da execução anterior — inclusive uma lista de ocorrências fantasma, que faz o
`bufexists()` do `Sync` desistir de montar a de verdade. Sintoma: resultados que
mudam sem o código mudar. O executor já passa `-i NONE -n`.

**`normal!` NÃO passa pelos mapeamentos — e às vezes é isso que você quer medir.**
Um teste do `Tab` feito com `normal! i<Tab>` mede o `Tab` nativo do modo insert,
que é justamente o único que o GrooVim não remapeia: o defeito estava no modo
normal e o teste passava. Para exercitar a tecla como o usuário a aperta, use
`feedkeys(tecla, "x")`.

**`:normal` sem `!` passa pelos mapeamentos.** A lista desliga `d`, `i` e `p` com
mapeamentos de buffer; um `norm ggdG` de dentro dela vira outra coisa e o Vim
trava esperando um movimento para o operador `>`. Dentro do painel é sempre
`norm!`.

**Um erro dentro de `feedkeys()` abre um "Press ENTER"** que espera para sempre
num script. Foi o que travou o `05` antes de o `@/` fazer parte do estado
montado.

**Gravar o resultado só no fim engana.** Um caso que morre no meio deixava o
arquivo vazio, e teste sem saída é indistinguível de teste que não rodou. O
`GT_Ok()` grava a cada verificação, e o `GT_Fim()` escreve `FIM` — o executor
cobra essa marca.

**`feedkeys(..., "x")` não entra na gravação de macro.** Medido: gravando com
`"x"`, o registro sai vazio; com `"t"` e timers, sai o que foi digitado. Um caso
de macro feito com `"x"` mede o contrário do que acontece ao teclar.

**`feedkeys(..., "x")` encerra o modo insert.** Para medir algo *durante* o
insert, mande as teclas com `"t"` e amostre de um `timer_start` — o `mode()`
confirma se você está mesmo lá. O caso `11_movimento` encadeia timers por isso.

**`feedkeys` com `:` digita no buffer.** O GrooVim remapeia `:`. Para comandos,
use `execute("...")` dentro do `timer_start`, não `feedkeys(":...")`. Já
modificou arquivos de fixture por engano.

**Chamar `GrooVim_SearchGuy()` direto não reproduz o caminho do `F3`.** Para o
painel, as teclas e a navegação, o `GT_MontaBusca()` monta o estado à mão e é
estável. O que depende do caminho real se confere na tela, com o `tela.sh`.

**`vim -S` sonda o caso durante o ARRANQUE, e nem todo evento acontece lá.** O
`OptionSet` é o exemplo: um `:set shiftwidth=8` escrito direto no caso não
dispara nada, enquanto o mesmo comando digitado à mão dispara. Um caso que
dependa disso mede o contrário do que acontece de verdade. Ponha o corpo numa
função e chame `GT_DepoisDoArranque("NomeDaFuncao")`.

**`l:` não existe fora de função.** Num caso solto, `for l:x in [...]` aborta o
laço inteiro em silêncio — e um laço que não roda não produz falha, produz
*ausência*. Use um nome simples.

**Índice de string conta bytes.** `guia[0]` num caractere como `┊` devolve meio
caractere. Use `strcharpart()`.

**Filtrar a saída esconde falha.** Rode o executor inteiro e leia o resumo.

## Fixtures

Os casos rodam sobre uma **cópia** de `fixtures/`, feita em `/tmp` a cada
execução, e com uma `GROOVIM_HOME` descartável ao lado dela. Um caso que altere um arquivo em memória nunca chega perto dos
originais. `resultados/` é descartável e está no `.gitignore`.
