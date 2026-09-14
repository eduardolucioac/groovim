" O nome da aba é sempre um documento seu, nunca o nome da lista.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Nome(expand("<sfile>:t:r"))

exec "edit " . g:GT_FIX . "/a.txt"
call GT_MontaBusca("ALVO", 2, ["0", "0", "0", "1," . g:GT_FIX . "/a.txt,2,1"])
exec "tabnew " . g:GT_FIX . "/b.txt"
sleep 80m

call GT_Ok("a tabline e a do GrooVim", &tabline ==# "%!GrooVim_TabLine()", "   [" . &tabline . "]")
call GT_Ok("rotulo com o cursor no arquivo", GrooVim_TabLabel(tabpagenr()) ==# "b.txt", "   [" . GrooVim_TabLabel(tabpagenr()) . "]")

call GT_VaiParaLista()
call GT_Ok("estamos na lista", expand('%:t') =~ "SearchGuyResults", "   [" . expand('%:t') . "]")
call GT_Ok("o rotulo CONTINUA sendo o arquivo", GrooVim_TabLabel(tabpagenr()) ==# "b.txt", "   [" . GrooVim_TabLabel(tabpagenr()) . "]")
call GT_Ok("a tabline nao cita a lista", GrooVim_TabLine() !~ "SearchGuyResults", "   [" . substitute(GrooVim_TabLine(), '%#\w*#\|%\d*T', '', 'g') . "]")
call GT_Ok("a lista nao conta como janela", GrooVim_TabLine() !~ " 2 ", "   [" . substitute(GrooVim_TabLine(), '%#\w*#\|%\d*T', '', 'g') . "]")

" ---- o "+" de modificado continua aparecendo
call GrooVim_SearchGuyFocusWindow(g:GT_FIX . "/b.txt", 1)
call append(1, "sujou")
call GT_Ok("a tabline mostra o + de modificado", GrooVim_TabLine() =~ "+", "   [" . substitute(GrooVim_TabLine(), '%#\w*#\|%\d*T', '', 'g') . "]")

" ---- quem sabe o que e acessorio esta num lugar so
call GT_Ok("IsHelperBuffer reconhece a lista", GrooVim_IsHelperBuffer("GrooVim_SearchGuyResults3"), "")
call GT_Ok("IsHelperBuffer reconhece o NERDTree", GrooVim_IsHelperBuffer("NERD_tree_1"), "")
call GT_Ok("IsHelperBuffer reconhece a ajuda", GrooVim_IsHelperBuffer("GrooVimHelp"), "")
call GT_Ok("IsHelperBuffer nao pega um arquivo", !GrooVim_IsHelperBuffer("b.txt"), "")

" ---- PutOnEditWindow sai dos acessorios sem girar para sempre
call GT_VaiParaLista()
call GrooVim_PutOnEditWindow()
call GT_Ok("PutOnEditWindow foi para o arquivo", !GrooVim_IsHelperBuffer(expand('%:t')), "   [" . expand('%:t') . "]")

call GT_Fim()
