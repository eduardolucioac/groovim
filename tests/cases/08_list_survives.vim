" Fechado o último arquivo, a lista fica -- como o painel de resultados do
" Notepad++, que não depende de haver documento aberto. É dela que se reabre o
" que interessa.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Nome(expand("<sfile>:t:r"))

exec "edit " . g:GT_FIX . "/a.txt"
call GT_MontaBusca("ALVO", 2, ["0", "0", "0", "1," . g:GT_FIX . "/a.txt,2,1",
  \ "0", "0", "0", "2," . g:GT_FIX . "/b.txt,2,1"])
exec "tabnew " . g:GT_FIX . "/b.txt"
sleep 80m
call GT_Ok("montagem: duas abas com lista", tabpagenr("$") == 2, "   " . GT_Layout())

" ---- fecha o arquivo da aba 2: a aba some, porque ha outra
call GrooVim_SearchGuyFocusWindow(g:GT_FIX . "/b.txt", 1)
quit
sleep 80m
call GT_Ok("com outra aba: a aba do arquivo fechado some", tabpagenr("$") == 1, "   (abas " . tabpagenr("$") . ")   " . GT_Layout())

" ---- fecha o ULTIMO arquivo: a lista FICA
call GrooVim_SearchGuyFocusWindow(g:GT_FIX . "/a.txt", 1)
quit
sleep 120m
call GT_Ok("fechado o ultimo arquivo, a lista FICA", GT_PaineisNaAba() == 1, "   " . GT_Layout())
call GT_Ok("a lista ficou sozinha", winnr("$") == 1, "   (janelas " . winnr("$") . ")")
call GT_Ok("estamos dentro dela", expand('%:t') =~ "SearchGuyResults", "   [" . expand('%:t') . "]")
call GT_Ok("a lista ainda tem as ocorrencias", line("$") == 8, "   (" . line("$") . " linhas)")
call GT_Ok("a barra continua sendo a do Notepad++", GrooVim_SearchGuyBar() =~ "hits in", "   [" . GrooVim_SearchGuyBar() . "]")

" ---- e dela se reabre um arquivo, SEM deixar a lista para tras
call cursor(4, 1)
call GrooVim_SearchGuyNavigate()
call GT_Ok("reabriu a partir da lista sozinha", expand('%:t') ==# "a.txt", "   [" . expand('%:t') . "]")
call GT_Ok("na linha certa", line(".") == 2, "   (linha " . line(".") . ")")
call GT_Ok("o arquivo entrou na MESMA aba", tabpagenr("$") == 1, "   (abas " . tabpagenr("$") . ")   " . GT_Layout())
call GT_Ok("a lista continua ali", GT_PaineisNaAba() == 1, "   " . GT_Layout())
call GT_Ok("o arquivo ficou ACIMA da lista", bufname(winbufnr(1)) =~ "a.txt", "   [" . fnamemodify(bufname(winbufnr(1)), ":t") . " / " . fnamemodify(bufname(winbufnr(2)), ":t") . "]")

" ---- e o segundo arquivo, esse sim, em aba nova
call GT_VaiParaLista()
call cursor(8, 1)
call GrooVim_SearchGuyNavigate()
call GT_Ok("o segundo arquivo abriu em aba nova", tabpagenr("$") == 2, "   (abas " . tabpagenr("$") . ")   " . GT_Layout())
call GT_Ok("e o certo", expand('%:t') ==# "b.txt", "   [" . expand('%:t') . "]")

" ---- o mesmo dando ":q" DE DENTRO da lista, que e o que quase saiu do Vim
tabonly!
call GT_VaiParaLista()
call GT_Ok("uma aba, arquivo + lista", winnr("$") == 2, "   " . GT_Layout())
call GT_Ok("o cursor esta na lista", expand('%:t') =~ "SearchGuyResults", "   [" . expand('%:t') . "]")
quit
sleep 150m
call GT_Ok(":q na lista fechou o ARQUIVO, nao o Vim", winnr("$") == 1 && expand('%:t') =~ "SearchGuyResults", "   " . GT_Layout())
call GT_Ok("a lista continua com as ocorrencias", line("$") == 8, "   (" . line("$") . " linhas)")

" ---- e como se sai: ":q" de dentro da lista sozinha fecha o Vim
call GT_Nota("vai dar :q na lista sozinha -- o Vim tem que sair aqui")
call GT_FimAqui()
quit
sleep 200m
call GT_Ok(":q na lista sozinha saiu do Vim", 0, "   (esta linha so aparece se NAO saiu)")
