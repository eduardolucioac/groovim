" Navigating from the list: the Enter, and links that point at places which have
" changed since the search ran.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

" ---- Enter goes to the right tab, the right file and the right line
exec "edit " . g:GT_FIX . "/a.txt"
exec "tabnew " . g:GT_FIX . "/b.txt"
sleep 60m
tabn 1
call GT_BuildSearch("TARGET", 2, ["0", "0", "0", "1," . g:GT_FIX . "/a.txt,2,21",
  \ "0", "0", "0", "2," . g:GT_FIX . "/b.txt,4,20"])
call GrooVim_SearchGuySync()
call GT_Ok("the list opened on tab 1", GT_GoToList(), "   " . GT_Layout())
call cursor(8, 1)
call feedkeys("\<Enter>", "x")
call GT_Ok("Enter went to the right tab", tabpagenr() == 2, "   (tab " . tabpagenr() . ")")
call GT_Ok("Enter went to the right file", expand('%:t') ==# "b.txt", "   [" . expand('%:t') . "]")
call GT_Ok("Enter went to the right line", line(".") == 4, "   (line " . line(".") . ")")

" ---- the tab it remembers is not there any more
tabonly! | exec "edit " . g:GT_FIX . "/a.txt"
call GT_BuildSearch("TARGET", 1, ["0", "0", "0", "9," . g:GT_FIX . "/b.txt,2,1"])
call GrooVim_SearchGuySync()
call GT_GoToList()
call cursor(4, 1)
call GrooVim_SearchGuyNavigate()
call GT_Ok("tab gone: opened it again without hanging", expand('%:t') ==# "b.txt", "   [" . expand('%:t') . "]")
call GT_Ok("tab gone: right line", line(".") == 2, "   (line " . line(".") . ")")

" ---- the tab is there, but holding another file
tabonly! | exec "edit " . g:GT_FIX . "/a.txt"
exec "tabnew " . g:GT_FIX . "/c.txt"
sleep 60m
tabn 1
call GT_BuildSearch("TARGET", 1, ["0", "0", "0", "2," . g:GT_FIX . "/b.txt,2,1"])
call GrooVim_SearchGuySync()
call GT_GoToList()
call cursor(4, 1)
call GrooVim_SearchGuyNavigate()
call GT_Ok("tab holding another file: opened the right one", expand('%:t') ==# "b.txt", "   [" . expand('%:t') . "]")

" ---- the file is already open in ANOTHER tab: it must not be opened again
tabonly! | exec "edit " . g:GT_FIX . "/a.txt"
exec "tabnew " . g:GT_FIX . "/c.txt"
exec "tabnew " . g:GT_FIX . "/b.txt"
sleep 60m
let g:GT_TABS = tabpagenr("$")
tabn 1
call GT_BuildSearch("TARGET", 1, ["0", "0", "0", "2," . g:GT_FIX . "/b.txt,4,1"])
call GrooVim_SearchGuySync()
call GT_GoToList()
call cursor(4, 1)
call GrooVim_SearchGuyNavigate()
call GT_Ok("found the file that was already open", expand('%:t') ==# "b.txt", "   [" . expand('%:t') . "]")
call GT_Ok("did not open one tab more", tabpagenr("$") == g:GT_TABS, "   (tabs " . tabpagenr("$") . ", before " . g:GT_TABS . ")")

" ---- a path with a comma: the entry is read from its ENDS
tabonly! | exec "edit " . g:GT_FIX . "/a.txt"
call GT_BuildSearch("found", 1, ["0", "0", "0", "1," . g:GT_FIX . "/com,ma.txt,2,1"])
call GrooVim_SearchGuySync()
call GT_GoToList()
call cursor(4, 1)
call GrooVim_SearchGuyNavigate()
call GT_Ok("path with a comma: opened the right one", expand('%:t') ==# "com,ma.txt", "   [" . expand('%:t') . "]")
call GT_Ok("path with a comma: right line", line(".") == 2, "   (line " . line(".") . ")")

call GT_Done()
