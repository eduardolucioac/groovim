" Prelúdio comum a todos os casos.
"
" Cada caso começa com:
"   exec "source " . expand("<sfile>:p:h") . "/_common.vim"
"   call GT_Nome(expand("<sfile>:t:r"))
" e termina com:
"   call GT_Fim()
"
" O nome vem do PRÓPRIO arquivo, e não escrito à mão: renomear um caso e
" esquecer a string lá dentro produzia um caso que roda, grava num nome que
" ninguém procura, e é acusado de "não chegou ao fim".

let g:GT_BASE = expand("<sfile>:p:h:h")
let g:GT_FIX = $GROOVIM_TEST_FIXTURES != "" ? $GROOVIM_TEST_FIXTURES : g:GT_BASE . "/fixtures"
let g:GT_OUT = $GROOVIM_TEST_OUT != "" ? $GROOVIM_TEST_OUT : g:GT_BASE . "/results"
let g:GT_NOME = "sem-nome"
let g:GT_LINHAS = []

func! GT_Nome(nome)
  let g:GT_NOME = a:nome
  let g:GT_LINHAS = []
endfunc

" Grava a cada verificação, e não só no fim.
"
" Motivo: um caso que morre no meio (ou que o Vim encerra por conta própria)
" deixava o arquivo de resultado vazio, e um teste sem saída é indistinguível de
" um teste que nunca rodou. Gravando linha a linha, o que passou fica registrado
" e o ponto exato da parada aparece.
func! GT_Grava()
  call writefile(g:GT_LINHAS, g:GT_OUT . "/" . g:GT_NOME . ".txt")
endfunc

func! GT_Ok(descricao, condicao, extra)
  call add(g:GT_LINHAS, printf("  %-50s %s%s", a:descricao, (a:condicao ? "ok" : "FALHOU"), a:extra))
  call GT_Grava()
endfunc

" Uma anotação que não é verificação: serve para saber por onde o caso passou.
func! GT_Nota(texto)
  call add(g:GT_LINHAS, "  .. " . a:texto)
  call GT_Grava()
endfunc

func! GT_Fim()
  call add(g:GT_LINHAS, "FIM")
  call GT_Grava()
  qa!
endfunc

" Marca o fim ANTES de um passo que deve fazer o próprio Vim sair.
"
" Sem isso o executor acusaria "nao chegou ao fim" justamente quando o caso
" terminou como devia. Se o Vim NÃO sair, o que vier depois é gravado depois do
" FIM e a falha continua aparecendo.
func! GT_FimAqui()
  call add(g:GT_LINHAS, "FIM")
  call GT_Grava()
endfunc

" Roda o corpo do caso DEPOIS do arranque do Vim.
"
" Motivo: "vim -S caso.vim" sonda o script durante o arranque, e alguns eventos
" não acontecem lá. O "OptionSet" é um deles: um ":set shiftwidth=8" escrito
" direto no caso não dispara nada, enquanto o mesmo comando digitado à mão
" dispara. Um caso que dependa disso mediria o contrário do que acontece de
" verdade.
"
" Uso: ponha o corpo do caso numa função e chame
"   call GT_DepoisDoArranque("NomeDaFuncao")
" como última linha do arquivo.
func! GT_DepoisDoArranque(nomeDaFuncao)
  call timer_start(50, {-> call(a:nomeDaFuncao, [])})
endfunc

" Espera uma condição virar verdadeira e SÓ então segue.
"
" Motivo: marcar os passos com tempo fixo produz caso instável. O feedkeys com
" "t" enfileira as teclas, e o Vim só as processa ao voltar para o laço
" principal — um timer que dispara antes disso amostra cedo e o caso falha sem
" que nada esteja errado no produto. Medido: o mesmo caso passando e falhando
" em execuções seguidas.
"
" Uso:
"   call GT_Quando('reg_recording() != ""', "ProximoPasso")
"
" Desiste depois de "g:GT_LIMITE_ESPERA" tentativas e chama o próximo passo
" assim mesmo — um caso que trava é pior que um que falha.
let g:GT_LIMITE_ESPERA = 60

func! GT_Quando(condicao, proximoPasso)
  call GT_QuandoTenta(a:condicao, a:proximoPasso, 0)
endfunc

func! GT_QuandoTenta(condicao, proximoPasso, tentativa)
  if eval(a:condicao) || a:tentativa >= g:GT_LIMITE_ESPERA
    call call(a:proximoPasso, [])
    return
  endif
  call timer_start(50, {t -> GT_QuandoTenta(a:condicao, a:proximoPasso, a:tentativa + 1)})
endfunc

" ---- ajudantes usados por mais de um caso ----

" Quantas janelas de lista de ocorrências existem na aba atual.
func! GT_PaineisNaAba()
  let l:total = 0
  for l:janela in range(1, winnr("$"))
    if bufname(winbufnr(l:janela)) =~ "GrooVim_SearchGuyResults"
      let l:total = l:total + 1
    endif
  endfor
  return l:total
endfunc

" O layout de todas as abas, como "[a.txt+lista][b.txt+lista]". É o que torna
" legível a falha de uma aba montada errado.
func! GT_Layout()
  let l:texto = ""
  for l:aba in range(1, tabpagenr("$"))
    let l:texto = l:texto . "[" .
      \ join(map(tabpagebuflist(l:aba), 'fnamemodify(bufname(v:val), ":t")'), "+") . "]"
  endfor
  return l:texto
endfunc

" Vai para a janela da lista na aba atual. Devolve 1 se achou.
func! GT_VaiParaLista()
  return GrooVim_SearchGuyFocusWindow("GrooVim_SearchGuyResults", 0)
endfunc

" Monta o estado que uma busca com lista deixaria, sem depender das teclas.
"
" Motivo: chamar GrooVim_SearchGuy() direto de um script não reproduz o caminho
" real (que passa pelo F3) e o resultado varia. Para o que estes casos verificam
" — o painel, as teclas, a navegação — o estado montado à mão é estável e
" suficiente. O que depende do caminho real é conferido na tela, com screen.sh.
func! GT_MontaBusca(valor, arquivos, ocorrencias)
  " O registro de busca faz parte do estado que uma busca deixa. Sem ele o
  " "norm n" do fim da navegação erra, e um erro dentro de um comando disparado
  " por feedkeys() abre um "Press ENTER" que trava o caso até o timeout.
  let @/ = a:valor
  let g:GrooVim_SearchGuyValue = a:valor
  let g:GrooVim_SearchGuyFilesSearched = a:arquivos
  let g:GrooVim_SearchGuyEnabled = 1
  let g:search_WithList = 1
  let g:searchReplace_InAllOpened = 1
  let g:matchedLinesGlobalNavArray = a:ocorrencias
  let l:corpo = []
  for l:entrada in a:ocorrencias
    call add(l:corpo, l:entrada == "0" ? "-----" : "linha de " . l:entrada)
  endfor
  let g:matchedLinesGlobal = join(l:corpo, "\n")
endfunc
