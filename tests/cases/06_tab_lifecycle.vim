" A lista é um acessório da aba: ":q" fecha a aba, e reabrir um arquivo pela
" lista traz a lista junto.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Nome(expand("<sfile>:t:r"))

exec "edit " . g:GT_FIX . "/a.txt"
call GT_MontaBusca("ALVO", 2, ["0", "0", "0", "1," . g:GT_FIX . "/a.txt,2,1",
  \ "0", "0", "0", "2," . g:GT_FIX . "/b.txt,2,1"])
exec "tabnew " . g:GT_FIX . "/b.txt"
sleep 80m
tabn 1 | sleep 80m

" A aba montada por "tabnew" nao pode ter o arquivo duas vezes: o "TabEnter"
" dispara ANTES de o arquivo carregar, e a lista era construida numa janela que
" o arquivo depois ocupava.
call GT_Ok("tabnew montou a aba certa", GT_Layout() ==# "[a.txt+GrooVim_SearchGuyResults1][b.txt+GrooVim_SearchGuyResults2]", "   " . GT_Layout())

" ---- ":q" DENTRO da lista fecha a aba inteira
tabn 2
call GT_VaiParaLista()
call GT_Ok("estamos na lista da aba 2", expand('%:t') =~ "SearchGuyResults", "   [" . expand('%:t') . "]")
quit
sleep 80m
call GT_Ok(":q na lista fechou a ABA", tabpagenr("$") == 1, "   (abas " . tabpagenr("$") . ")   " . GT_Layout())
call GT_Ok("a outra aba ficou intacta", GT_Layout() ==# "[a.txt+GrooVim_SearchGuyResults1]", "   " . GT_Layout())

" ---- ":q" na janela do ARQUIVO faz o mesmo
exec "tabnew " . g:GT_FIX . "/b.txt"
sleep 80m
call GT_Ok("montou a aba 2 de novo", tabpagenr("$") == 2, "   " . GT_Layout())
call GrooVim_SearchGuyFocusWindow(g:GT_FIX . "/b.txt", 1)
quit
sleep 80m
call GT_Ok(":q no arquivo fechou a ABA", tabpagenr("$") == 1, "   (abas " . tabpagenr("$") . ")   " . GT_Layout())
call GT_Nota("o buffer da lista da aba fechada sobreviveu? " . bufexists("GrooVim_SearchGuyResults2") . "   (tem que ser 0)")
call GT_Ok("o buffer da lista foi embora junto", bufexists("GrooVim_SearchGuyResults2") == 0, "")

" ---- o link do arquivo fechado reabre, COM lista
call GT_VaiParaLista()
call cursor(8, 1)
call GrooVim_SearchGuyNavigate()
call GT_Ok("reabriu o arquivo fechado", expand('%:t') ==# "b.txt", "   [" . expand('%:t') . "]")
call GT_Ok("a aba reaberta veio COM a lista", GT_PaineisNaAba() == 1, "   (paineis " . GT_PaineisNaAba() . ")   " . GT_Layout())

" ---- a lista sozinha nao segura a aba
call GrooVim_SearchGuyFocusWindow(g:GT_FIX . "/b.txt", 1)
quit
sleep 80m
call GT_Ok("a lista sozinha nao segurou a aba", tabpagenr("$") == 1, "   (abas " . tabpagenr("$") . ")   " . GT_Layout())

call GT_Fim()
