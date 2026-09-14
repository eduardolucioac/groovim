" A lista de ocorrências: o que ela é (buffer, barra) e como se comporta.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

exec "edit " . g:GT_FIX . "/a.txt"
call GT_BuildSearch("ALVO", 2, ["0", "0", "0", "1," . g:GT_FIX . "/a.txt,2,24", "1," . g:GT_FIX . "/a.txt,4,23",
  \ "0", "0", "0", "2," . g:GT_FIX . "/b.txt,2,24", "2," . g:GT_FIX . "/b.txt,4,22", "2," . g:GT_FIX . "/b.txt,4,29"])
call GrooVim_SearchGuySync()
call GT_Ok("a lista abriu", GT_GoToList(), "   " . GT_Layout())

" ---- o buffer nao pode se comportar como um arquivo esquecido
call GT_Ok("buftype = nofile", &buftype ==# "nofile", "   [" . &buftype . "]")
call GT_Ok("nao aparece no :ls", &buflisted == 0, "")
call GT_Ok("nao aparece como modificado", &modified == 0, "")
call GT_Ok("nao e modificavel", &modifiable == 0, "")
call GT_Ok("bufhidden = wipe", &bufhidden ==# "wipe", "   [" . &bufhidden . "]   (senao o buffer velho impede a proxima lista)")

" ---- a barra e a do Notepad++, e so nesta janela
call GT_Ok("barra: texto do Notepad++", GrooVim_SearchGuyBar() ==# 'Search "ALVO" (5 hits in 2 files of 2 searched)', "   [" . GrooVim_SearchGuyBar() . "]")
call GT_Ok("barra e local da janela", &l:statusline ==# "%!GrooVim_SearchGuyBar()", "   [" . &l:statusline . "]")
wincmd p
call GT_Ok("a janela do arquivo mantem a barra do GrooVim", &l:statusline ==# "", "   [" . &l:statusline . "]")
call GT_GoToList()

" ---- singular, plural e o "%" que a barra comeria
let g:matchedLinesGlobalNavArray = ["0", "1,/x/a.txt,2,1"]
let g:GrooVim_SearchGuyFilesSearched = 1
call GT_Ok("singular: 1 hit in 1 file of 1", GrooVim_SearchGuyBar() ==# 'Search "ALVO" (1 hit in 1 file of 1 searched)', "   [" . GrooVim_SearchGuyBar() . "]")
let g:matchedLinesGlobalNavArray = []
call GT_Ok("zero ocorrencias", GrooVim_SearchGuyBar() ==# 'Search "ALVO" (0 hits in 0 files of 1 searched)', "   [" . GrooVim_SearchGuyBar() . "]")
let g:GrooVim_SearchGuyValue = "50%"
let g:matchedLinesGlobalNavArray = ["1,/x/a.txt,2,1"]
call GT_Ok("valor com % nao quebra a barra", GrooVim_SearchGuyBar() =~ '50%%', "   [" . GrooVim_SearchGuyBar() . "]")

" ---- Enter navega, Del nao navega mais
call GT_Ok("<Enter> e mapeamento do buffer", get(maparg("<Enter>", "n", 0, 1), "buffer", 0) == 1, "")
call GT_Ok("<Enter> navega", maparg("<Enter>", "n") =~ "SearchGuyNavigate", "   [" . maparg("<Enter>", "n") . "]")
call GT_Ok("<Del> NAO navega mais", maparg("<Del>", "n") ==# "<Nop>", "   [" . maparg("<Del>", "n") . "]")
call GT_Ok("GrooVim_DelBehavior foi removida", exists("*GrooVim_DelBehavior") == 0, "")

call GT_Done()
