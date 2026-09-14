" Replacing across several tabs, and TabDo giving each one its cursor back.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

let g:configureGrooVim_EntertainmentReplace_Confirmation = 0
let g:configureGrooVim_EntertainmentReplace_AskTheValueToBeReplaced = 1
let g:searchReplace_InAllOpened = 1

exec "edit " . g:GT_FIX . "/a.txt"
exec "tabnew " . g:GT_FIX . "/b.txt"

" the cursor of tab 2 on a known spot, far from any ALVO
tabn 2 | call cursor(4, 3)
tabn 1 | call cursor(4, 8)
let g:GT_TAB = tabpagenr()
let g:GT_LINE = line(".")
let g:GT_COL = col(".")

call feedkeys("ALVO\<CR>ACERTOU\<CR>", "t")
call GrooVim_EntertainmentReplace("n")
call feedkeys("", "x")

call GT_Ok("came back to the tab it started on", tabpagenr() == g:GT_TAB, "   (tab " . tabpagenr() . ")")
call GT_Ok("cursor: same line", line(".") == g:GT_LINE, "   (" . line(".") . ", expected " . g:GT_LINE . ")")
call GT_Ok("cursor: same column", col(".") == g:GT_COL, "   (" . col(".") . ", expected " . g:GT_COL . ")")
call GT_Ok("tab 1 replaced", getline(1,"$") ==# ["=== ABA A ===", "primeira ocorrencia de ACERTOU aqui", "linha comum", "segunda ocorrencia de ACERTOU aqui"], "   " . string(getline(1,"$")))

tabn 2
call GT_Ok("tab 2 replaced (two on the same line)", getline(4) ==# "quarta ocorrencia de ACERTOU e ACERTOU na mesma linha", "   [" . getline(4) . "]")
call GT_Ok("the cursor of tab 2 was kept", line(".") == 4 && col(".") == 3, "   (line " . line(".") . " col " . col(".") . ", expected 4/3)")
call GT_Ok("the TabDo flags were cleared", g:tryCathOnTabDo == 0 && g:keepCursorOnTabDo == 0, "")

" ---- the two meanings of TabDo, without going through the replace
tabonly! | %delete _ | call setline(1, ["a","b","c","d","e"]) | call cursor(2, 1)
tabnew | call setline(1, ["a","b","c","d","e"]) | call cursor(2, 1)
tabn 1
call TabDo("call cursor(5, 1)")
call GT_Ok("without the flag: the cursor MOVES (the old behaviour)", line(".") == 5, "   (line " . line(".") . ")")
tabn 2
call GT_Ok("without the flag: the cursor of tab 2 moves as well", line(".") == 5, "   (line " . line(".") . ")")

tabn 1 | call cursor(2, 1)
tabn 2 | call cursor(3, 1)
tabn 1
let g:keepCursorOnTabDo = 1
call TabDo("call cursor(5, 1)")
let g:keepCursorOnTabDo = 0
call GT_Ok("with the flag: tab 1 came back", line(".") == 2, "   (line " . line(".") . ")")
call GT_Ok("with the flag: back to the tab it started on", tabpagenr() == 1, "   (tab " . tabpagenr() . ")")
tabn 2
call GT_Ok("with the flag: tab 2 came back", line(".") == 3, "   (line " . line(".") . ")")

call GT_Done()
