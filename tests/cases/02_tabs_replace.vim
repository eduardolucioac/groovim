" Substituição em várias abas, e o TabDo devolvendo o cursor de cada uma.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Nome(expand("<sfile>:t:r"))

let g:configureGrooVim_EntertainmentReplace_Confirmation = 0
let g:configureGrooVim_EntertainmentReplace_AskTheValueToBeReplaced = 1
let g:searchReplace_InAllOpened = 1

exec "edit " . g:GT_FIX . "/a.txt"
exec "tabnew " . g:GT_FIX . "/b.txt"

" cursor da aba 2 num ponto conhecido, longe de qualquer ALVO
tabn 2 | call cursor(4, 3)
tabn 1 | call cursor(4, 8)
let g:GT_ABA = tabpagenr()
let g:GT_LIN = line(".")
let g:GT_COL = col(".")

call feedkeys("ALVO\<CR>ACERTOU\<CR>", "t")
call GrooVim_EntertainmentReplace("n")
call feedkeys("", "x")

call GT_Ok("voltou para a aba de origem", tabpagenr() == g:GT_ABA, "   (aba " . tabpagenr() . ")")
call GT_Ok("cursor: mesma linha", line(".") == g:GT_LIN, "   (" . line(".") . ", esperado " . g:GT_LIN . ")")
call GT_Ok("cursor: mesma coluna", col(".") == g:GT_COL, "   (" . col(".") . ", esperado " . g:GT_COL . ")")
call GT_Ok("aba 1 substituida", getline(1,"$") ==# ["=== ABA A ===", "primeira ocorrencia de ACERTOU aqui", "linha comum", "segunda ocorrencia de ACERTOU aqui"], "   " . string(getline(1,"$")))

tabn 2
call GT_Ok("aba 2 substituida (duas na mesma linha)", getline(4) ==# "quarta ocorrencia de ACERTOU e ACERTOU na mesma linha", "   [" . getline(4) . "]")
call GT_Ok("cursor da aba 2 preservado", line(".") == 4 && col(".") == 3, "   (linha " . line(".") . " col " . col(".") . ", esperado 4/3)")
call GT_Ok("as flags do TabDo foram zeradas", g:tryCathOnTabDo == 0 && g:keepCursorOnTabDo == 0, "")

" ---- as duas semanticas do TabDo, sem passar pelo replace
tabonly! | %delete _ | call setline(1, ["a","b","c","d","e"]) | call cursor(2, 1)
tabnew | call setline(1, ["a","b","c","d","e"]) | call cursor(2, 1)
tabn 1
call TabDo("call cursor(5, 1)")
call GT_Ok("sem a flag: o cursor MOVE (comportamento antigo)", line(".") == 5, "   (linha " . line(".") . ")")
tabn 2
call GT_Ok("sem a flag: o cursor da aba 2 tambem move", line(".") == 5, "   (linha " . line(".") . ")")

tabn 1 | call cursor(2, 1)
tabn 2 | call cursor(3, 1)
tabn 1
let g:keepCursorOnTabDo = 1
call TabDo("call cursor(5, 1)")
let g:keepCursorOnTabDo = 0
call GT_Ok("com a flag: aba 1 voltou", line(".") == 2, "   (linha " . line(".") . ")")
call GT_Ok("com a flag: voltou para a aba de origem", tabpagenr() == 1, "   (aba " . tabpagenr() . ")")
tabn 2
call GT_Ok("com a flag: aba 2 voltou", line(".") == 3, "   (linha " . line(".") . ")")

call GT_Fim()
