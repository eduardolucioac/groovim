" As guias de indentação: largura tirada das opções do Vim, na hora de desenhar.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

func! GT_Guia()
  " a parte do listchars que desenha as guias, ou "" quando nao ha
  return matchstr(&listchars, 'leadmultispace:\zs.*')
endfunc
func! GT_Largura()
  " quantas colunas entre uma guia e a proxima
  return strchars(GT_Guia())
endfunc

" O corpo roda depois do arranque: ver GT_AfterStartup no _common.vim.
func! GT_Body()
exec "edit " . g:GT_FIX . "/indent.sh"

call GT_Ok("ha guia no listchars", GT_Guia() != "", "   [" . &listchars . "]")
" strcharpart e nao [0]: o indice do VimScript conta BYTES, e a guia e multibyte
call GT_Ok("o caractere e o configurado", strcharpart(GT_Guia(), 0, 1) ==# g:GrooVim_IndentGuideChar, "   [" . strcharpart(GT_Guia(), 0, 1) . "]")

" ---- a largura segue o shiftwidth, na hora em que ele muda
for largura in [2, 4, 8, 3]
  exec "set shiftwidth=" . largura
  call GT_Ok("shiftwidth=" . largura . " -> guia de " . largura, GT_Largura() == largura, "   (guia de " . GT_Largura() . ")")
endfor

" ---- shiftwidth=0 significa "use o tabstop"
set tabstop=6
set shiftwidth=0
call GT_Ok("shiftwidth=0 cai no tabstop", GT_Largura() == 6, "   (guia de " . GT_Largura() . ", tabstop " . &tabstop . ")")
set tabstop=4
call GT_Ok("mudar o tabstop tambem move a guia", GT_Largura() == 4, "   (guia de " . GT_Largura() . ")")

" ---- largura 1 nao faz sentido: nao ha guia a desenhar
set shiftwidth=1
call GT_Ok("shiftwidth=1 nao desenha guia", GT_Guia() ==# "", "   [" . &listchars . "]")
set shiftwidth=2
call GT_Ok("e volta quando a largura volta", GT_Largura() == 2, "")

" ---- o resto do listchars nao se perde no caminho
call GT_Ok("trail continua no listchars", &listchars =~ "trail:", "   [" . &listchars . "]")
call GT_Ok("nbsp continua no listchars", &listchars =~ "nbsp:", "")

" ---- desligar as guias
let g:GrooVim_IndentGuideChar = ""
call GrooVim_IndentGuideSet()
call GT_Ok("sem caractere, sem guia", GT_Guia() ==# "", "   [" . &listchars . "]")
call GT_Ok("mas trail e nbsp ficam", &listchars =~ "trail:" && &listchars =~ "nbsp:", "   [" . &listchars . "]")
let g:GrooVim_IndentGuideChar = "┊"
call GrooVim_IndentGuideSet()
call GT_Ok("religou", GT_Guia() != "", "")

" ---- onde as guias caem NA TELA, lido do proprio Vim
"
" O listchars diz a regra; isto diz o desenho. E a prova de que a guia marca de
" "shiftwidth" em "shiftwidth" colunas a partir da PRIMEIRA, e nao um primeiro
" intervalo diferente dos outros.
set nonumber
exec "edit " . g:GT_FIX . "/fundo.txt"
for par in [[2, [1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39]],
  \ [4, [1,5,9,13,17,21,25,29,33,37]],
  \ [8, [1,9,17,25,33]]]
  exec "set shiftwidth=" . par[0]
  redraw
  let colunas = []
  for c in range(1, 46)
    if nr2char(screenchar(1, c)) ==# g:GrooVim_IndentGuideChar
      call add(colunas, c)
    endif
  endfor
  call GT_Ok("na tela, shiftwidth=" . par[0] . ": guias de " . par[0] . " em " . par[0],
    \ colunas == par[1], "   " . string(colunas))
endfor

" ---- tabular: o que o usuario chama de "largura"
"
" A largura so significa o que se espera enquanto tabstop, shiftwidth e
" softtabstop concordam. Com os tres juntos o Tab pousa NA largura e depois no
" dobro dela, venha a linha de onde vier -- como o Notepad++ anda pelas paradas.
" A tecla de verdade, pelo mapeamento de verdade.
"
" O primeiro teste disto usava "normal! i<Tab>", que NAO passa pelos mapeamentos
" e media o Tab do modo insert -- justamente o unico que o GrooVim nao remapeia.
" O modo normal chama GrooVim_NormalTab, e era ali que estava o defeito.
func! GT_Tabular(recuoInicial, quantos, ...)
  let tecla = a:0 > 0 ? a:1 : "\<Tab>"
  %delete _
  call setline(1, repeat(" ", a:recuoInicial) . "X")
  let passos = [a:recuoInicial]
  for i in range(1, a:quantos)
    call cursor(1, match(getline(1), "X") + 1)
    call feedkeys(tecla, "x")
    call add(passos, match(getline(1), "X"))
  endfor
  return passos
endfunc

exec "edit " . g:GT_FIX . "/indent.sh"
call SpecificTabConf(2)
call GT_Ok("largura 2: Tab anda de 2 em 2", GT_Tabular(0, 3) == [0, 2, 4, 6], "   " . string(GT_Tabular(0, 3)))

" so o shiftwidth: o Tab NAO muda, e por isso existe o comando
set shiftwidth=8
call GT_Ok("shiftround esta ligado", &shiftround == 1, "   (e o que faz o recuo ALCANCAR a parada)")

GrooVimIndent 8
call GT_Ok("GrooVimIndent move as tres opcoes", &tabstop == 8 && &shiftwidth == 8 && &softtabstop == 8, "   (ts=" . &tabstop . " sw=" . &shiftwidth . " sts=" . &softtabstop . ")")
call GT_Ok("largura 8, do zero: 8, 16, 24", GT_Tabular(0, 3) == [0, 8, 16, 24], "   " . string(GT_Tabular(0, 3)))
call GT_Ok("largura 8, comecando de 2: pousa em 8", GT_Tabular(2, 3) == [2, 8, 16, 24], "   " . string(GT_Tabular(2, 3)) . "   (e nao 2, 10, 18)")
call GT_Ok("largura 8, comecando de 5: pousa em 8", GT_Tabular(5, 2) == [5, 8, 16], "   " . string(GT_Tabular(5, 2)))
call GT_Ok("a guia acompanhou o comando", GT_Largura() == 8, "   (guia de " . GT_Largura() . ")")

" ---- desindentar volta pelas mesmas paradas
call GT_Ok("Shift-Tab de 10 volta para 8", GT_Tabular(10, 2, "\<S-Tab>") == [10, 8, 0], "   " . string(GT_Tabular(10, 2, "\<S-Tab>")))
call GT_Ok("Shift-Tab de 16 volta para 8", GT_Tabular(16, 2, "\<S-Tab>") == [16, 8, 0], "   " . string(GT_Tabular(16, 2, "\<S-Tab>")))

GrooVimIndent 4
call GT_Ok("voltando para 4: 4, 8, 12", GT_Tabular(0, 3) == [0, 4, 8, 12], "   " . string(GT_Tabular(0, 3)))
call GT_Ok("de 3 pousa em 4", GT_Tabular(3, 2) == [3, 4, 8], "   " . string(GT_Tabular(3, 2)))

" o comando recusa o que nao e largura
GrooVimIndent 0
call GT_Ok("recusa zero, mantem a largura", &shiftwidth == 4, "   (sw=" . &shiftwidth . ")")
GrooVimIndent abc
call GT_Ok("recusa texto, mantem a largura", &shiftwidth == 4, "   (sw=" . &shiftwidth . ")")
GrooVimIndent 3abc
call GT_Ok("recusa 3abc, mantem a largura", &shiftwidth == 4, "   (sw=" . &shiftwidth . ")")
GrooVimIndent
call GT_Ok("sem argumento nao muda nada", &shiftwidth == 4, "   (sw=" . &shiftwidth . ")")

call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
