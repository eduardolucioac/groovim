" Navegar pela lista: o Enter, e os links que apontam para lugares que mudaram.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Nome(expand("<sfile>:t:r"))

" ---- Enter leva para a aba, o arquivo e a linha certos
exec "edit " . g:GT_FIX . "/a.txt"
exec "tabnew " . g:GT_FIX . "/b.txt"
sleep 60m
tabn 1
call GT_MontaBusca("ALVO", 2, ["0", "0", "0", "1," . g:GT_FIX . "/a.txt,2,24",
  \ "0", "0", "0", "2," . g:GT_FIX . "/b.txt,4,22"])
call GrooVim_SearchGuySync()
call GT_Ok("a lista abriu na aba 1", GT_VaiParaLista(), "   " . GT_Layout())
call cursor(8, 1)
call feedkeys("\<Enter>", "x")
call GT_Ok("Enter foi para a aba certa", tabpagenr() == 2, "   (aba " . tabpagenr() . ")")
call GT_Ok("Enter foi para o arquivo certo", expand('%:t') ==# "b.txt", "   [" . expand('%:t') . "]")
call GT_Ok("Enter foi para a linha certa", line(".") == 4, "   (linha " . line(".") . ")")

" ---- a aba guardada nem existe mais
tabonly! | exec "edit " . g:GT_FIX . "/a.txt"
call GT_MontaBusca("ALVO", 1, ["0", "0", "0", "9," . g:GT_FIX . "/b.txt,2,1"])
call GrooVim_SearchGuySync()
call GT_VaiParaLista()
call cursor(4, 1)
call GrooVim_SearchGuyNavigate()
call GT_Ok("aba inexistente: abriu sem travar", expand('%:t') ==# "b.txt", "   [" . expand('%:t') . "]")
call GT_Ok("aba inexistente: linha certa", line(".") == 2, "   (linha " . line(".") . ")")

" ---- a aba existe, mas com outro arquivo
tabonly! | exec "edit " . g:GT_FIX . "/a.txt"
exec "tabnew " . g:GT_FIX . "/c.txt"
sleep 60m
tabn 1
call GT_MontaBusca("ALVO", 1, ["0", "0", "0", "2," . g:GT_FIX . "/b.txt,2,1"])
call GrooVim_SearchGuySync()
call GT_VaiParaLista()
call cursor(4, 1)
call GrooVim_SearchGuyNavigate()
call GT_Ok("aba com outro arquivo: abriu o certo", expand('%:t') ==# "b.txt", "   [" . expand('%:t') . "]")

" ---- o arquivo ja esta aberto em OUTRA aba: nao pode abrir de novo
tabonly! | exec "edit " . g:GT_FIX . "/a.txt"
exec "tabnew " . g:GT_FIX . "/c.txt"
exec "tabnew " . g:GT_FIX . "/b.txt"
sleep 60m
let g:GT_ABAS = tabpagenr("$")
tabn 1
call GT_MontaBusca("ALVO", 1, ["0", "0", "0", "2," . g:GT_FIX . "/b.txt,4,1"])
call GrooVim_SearchGuySync()
call GT_VaiParaLista()
call cursor(4, 1)
call GrooVim_SearchGuyNavigate()
call GT_Ok("achou o arquivo ja aberto", expand('%:t') ==# "b.txt", "   [" . expand('%:t') . "]")
call GT_Ok("nao abriu uma aba a mais", tabpagenr("$") == g:GT_ABAS, "   (abas " . tabpagenr("$") . ", antes " . g:GT_ABAS . ")")

" ---- caminho com virgula: a entrada e lida pelas PONTAS
tabonly! | exec "edit " . g:GT_FIX . "/a.txt"
call GT_MontaBusca("achei", 1, ["0", "0", "0", "1," . g:GT_FIX . "/vir,gula.txt,2,1"])
call GrooVim_SearchGuySync()
call GT_VaiParaLista()
call cursor(4, 1)
call GrooVim_SearchGuyNavigate()
call GT_Ok("caminho com virgula: abriu o certo", expand('%:t') ==# "vir,gula.txt", "   [" . expand('%:t') . "]")
call GT_Ok("caminho com virgula: linha certa", line(".") == 2, "   (linha " . line(".") . ")")

call GT_Fim()
