" Substituição num buffer só: contador, wrap, e o cursor voltando ao lugar.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

let g:searchReplace_InAllOpened = 0
let g:configureGrooVim_EntertainmentReplace_AskTheValueToBeReplaced = 1
let g:configureGrooVim_EntertainmentReplace_Confirmation = 0
let g:configureGrooVim_EntertainmentReplace_FromCurrentPosition = 1

" ---- o contador nao pode alterar o texto nem o "gdefault"
%delete _ | call setline(1, ["a x a", "b", "a", "c x", "a a a"])
call GT_Ok("contador: 'a' nas linhas 1-3", GrooVim_CountOccurrences("a", 1, 3) == 3, "   (achou " . GrooVim_CountOccurrences("a", 1, 3) . ")")
call GT_Ok("contador: 'a' no arquivo todo", GrooVim_CountOccurrences("a", 1, 5) == 6, "   (achou " . GrooVim_CountOccurrences("a", 1, 5) . ")")
call GT_Ok("contador: inexistente da zero", GrooVim_CountOccurrences("zzz", 1, 5) == 0, "")
call GT_Ok("contador nao alterou o texto", getline(1,"$") ==# ["a x a", "b", "a", "c x", "a a a"], "")
call GT_Ok("gdefault preservado", &gdefault == 1, "   (o contador o desliga e tem que repor)")

" ---- o wrap so acontece COM confirmacao
" Sem interatividade, continuar do topo seria o mesmo que "replace all".
let g:configureGrooVim_EntertainmentReplace_Confirmation = 1
%delete _ | call setline(1, ["alvo 1", "alvo 2", "meio", "alvo 3", "alvo 4"])
call cursor(3, 1)
let g:GrooVim_GrooVimBarMsgValue = ""
call feedkeys("alvo\<CR>NOVO\<CR>aa", "t")
call GrooVim_EntertainmentReplace("n")
call feedkeys("", "x")
call GT_Ok("wrap: trocou TODAS as ocorrencias", getline(1,"$") ==# ["NOVO 1", "NOVO 2", "meio", "NOVO 3", "NOVO 4"], "   " . string(getline(1,"$")))
call GT_Ok("wrap: avisou que continuou do topo", g:GrooVim_GrooVimBarMsgValue =~ "from the top", "   [" . g:GrooVim_GrooVimBarMsgValue . "]")

%delete _ | call setline(1, ["nada aqui", "nada ali", "alvo 1", "alvo 2"])
call cursor(1, 1)
let g:GrooVim_GrooVimBarMsgValue = ""
call feedkeys("alvo\<CR>Y\<CR>aa", "t")
call GrooVim_EntertainmentReplace("n")
call feedkeys("", "x")
call GT_Ok("sem ocorrencia acima: nao avisa", g:GrooVim_GrooVimBarMsgValue !~ "from the top", "   [" . g:GrooVim_GrooVimBarMsgValue . "]")

" ---- o cursor volta para onde estava, como no Notepad++
let g:configureGrooVim_EntertainmentReplace_Confirmation = 0
let g:configureGrooVim_EntertainmentReplace_FromCurrentPosition = 0
%delete _ | call setline(1, ["ALVO um", "dois", "tres ALVO", "quatro fim", "cinco"])
call cursor(4, 7)
call feedkeys("ALVO\<CR>X\<CR>", "t")
call GrooVim_EntertainmentReplace("n")
call feedkeys("", "x")
call GT_Ok("sem confirmacao: cursor volta", line(".") == 4 && col(".") == 7, "   (linha " . line(".") . " col " . col(".") . ", esperado 4/7)")
call GT_Ok("sem confirmacao: trocou", getline(1,"$") ==# ["X um", "dois", "tres X", "quatro fim", "cinco"], "   " . string(getline(1,"$")))

let g:configureGrooVim_EntertainmentReplace_Confirmation = 1
let g:configureGrooVim_EntertainmentReplace_FromCurrentPosition = 1
%delete _ | call setline(1, ["ALVO um", "dois", "tres ALVO", "quatro fim", "cinco ALVO"])
call cursor(4, 7)
call feedkeys("ALVO\<CR>Y\<CR>aa", "t")
call GrooVim_EntertainmentReplace("n")
call feedkeys("", "x")
call GT_Ok("com confirmacao: cursor volta", line(".") == 4 && col(".") == 7, "   (linha " . line(".") . " col " . col(".") . ")")
call GT_Ok("com confirmacao: trocou tudo", getline(1,"$") ==# ["Y um", "dois", "tres Y", "quatro fim", "cinco Y"], "   " . string(getline(1,"$")))

" ---- a rolagem tambem volta ("winsaveview", nao so linha e coluna)
let g:configureGrooVim_EntertainmentReplace_Confirmation = 0
let g:configureGrooVim_EntertainmentReplace_FromCurrentPosition = 0
%delete _ | call setline(1, map(range(1,300), '"linha ".v:val." ALVO"'))
call cursor(150, 3)
normal! zz
let g:GT_TOPO = line("w0")
call feedkeys("ALVO\<CR>Z\<CR>", "t")
call GrooVim_EntertainmentReplace("n")
call feedkeys("", "x")
call GT_Ok("300 linhas: cursor volta", line(".") == 150 && col(".") == 3, "   (linha " . line(".") . " col " . col(".") . ")")
call GT_Ok("300 linhas: rolagem preservada", line("w0") == g:GT_TOPO, "   (topo " . line("w0") . ", esperado " . g:GT_TOPO . ")")

" ---- Ctrl-C e Ctrl-X
%delete _ | call setline(1, ["alpha beta gamma"]) | call cursor(1, 7)
execute "normal viw\<C-c>"
call GT_Ok("Ctrl-C copiou a palavra", getreg('"') ==# "beta", "   [" . getreg('"') . "]")
call GT_Ok("Ctrl-C manteve as marcas da selecao", getpos("'<")[2] == 7 && getpos("'>")[2] == 10, "   ('< " . getpos("'<")[2] . " '> " . getpos("'>")[2] . ")")
%delete _ | call setline(1, ["alpha beta gamma"]) | call cursor(1, 7)
execute "normal viw\<C-x>"
call GT_Ok("Ctrl-X recortou", getline(1) ==# "alpha  gamma" && getreg('"') ==# "beta", "   [" . getline(1) . "]")

call GT_Ok("cmdheight e 1", &cmdheight == 1, "   (" . &cmdheight . ")")

call GT_Done()
