" With the last file closed, the list stays -- like the results panel of
" Notepad++, which does not depend on a document being open. It is what you
" reopen the interesting files from.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

exec "edit " . g:GT_FIX . "/a.txt"
call GT_BuildSearch("ALVO", 2, ["0", "0", "0", "1," . g:GT_FIX . "/a.txt,2,1",
  \ "0", "0", "0", "2," . g:GT_FIX . "/b.txt,2,1"])
exec "tabnew " . g:GT_FIX . "/b.txt"
sleep 80m
call GT_Ok("setup: two tabs with a list", tabpagenr("$") == 2, "   " . GT_Layout())

" ---- close the file of tab 2: the tab goes, because there is another one
call GrooVim_SearchGuyFocusWindow(g:GT_FIX . "/b.txt", 1)
quit
sleep 80m
call GT_Ok("with another tab: the tab of the closed file goes", tabpagenr("$") == 1, "   (tabs " . tabpagenr("$") . ")   " . GT_Layout())

" ---- close the LAST file: the list STAYS
call GrooVim_SearchGuyFocusWindow(g:GT_FIX . "/a.txt", 1)
quit
sleep 120m
call GT_Ok("last file closed, the list STAYS", GT_PanelsInTab() == 1, "   " . GT_Layout())
call GT_Ok("the list is on its own", winnr("$") == 1, "   (windows " . winnr("$") . ")")
call GT_Ok("we are inside it", expand('%:t') =~ "SearchGuyResults", "   [" . expand('%:t') . "]")
call GT_Ok("the list still holds the occurrences", line("$") == 8, "   (" . line("$") . " lines)")
call GT_Ok("the bar is still the one of Notepad++", GrooVim_SearchGuyBar() =~ "hits in", "   [" . GrooVim_SearchGuyBar() . "]")

" ---- and a file opens from it, WITHOUT leaving the list behind
call cursor(4, 1)
call GrooVim_SearchGuyNavigate()
call GT_Ok("opened from the lone list", expand('%:t') ==# "a.txt", "   [" . expand('%:t') . "]")
call GT_Ok("on the right line", line(".") == 2, "   (line " . line(".") . ")")
call GT_Ok("the file went into the SAME tab", tabpagenr("$") == 1, "   (tabs " . tabpagenr("$") . ")   " . GT_Layout())
call GT_Ok("the list is still there", GT_PanelsInTab() == 1, "   " . GT_Layout())
call GT_Ok("the file went ABOVE the list", bufname(winbufnr(1)) =~ "a.txt", "   [" . fnamemodify(bufname(winbufnr(1)), ":t") . " / " . fnamemodify(bufname(winbufnr(2)), ":t") . "]")

" ---- and the second file, that one does go into a new tab
call GT_GoToList()
call cursor(8, 1)
call GrooVim_SearchGuyNavigate()
call GT_Ok("the second file opened in a new tab", tabpagenr("$") == 2, "   (tabs " . tabpagenr("$") . ")   " . GT_Layout())
call GT_Ok("and it is the right one", expand('%:t') ==# "b.txt", "   [" . expand('%:t') . "]")

" ---- the same with ":q" from INSIDE the list, which nearly quit Vim
tabonly!
call GT_GoToList()
call GT_Ok("one tab, file + list", winnr("$") == 2, "   " . GT_Layout())
call GT_Ok("the cursor is on the list", expand('%:t') =~ "SearchGuyResults", "   [" . expand('%:t') . "]")
quit
sleep 150m
call GT_Ok(":q on the list closed the FILE, not Vim", winnr("$") == 1 && expand('%:t') =~ "SearchGuyResults", "   " . GT_Layout())
call GT_Ok("the list still holds the occurrences", line("$") == 8, "   (" . line("$") . " lines)")

" ---- and how you leave: ":q" from inside the lone list closes Vim
call GT_Note("about to :q on the lone list -- Vim has to quit here")
call GT_DoneHere()
quit
sleep 200m
call GT_Ok(":q on the lone list quit Vim", 0, "   (this line only shows if it did NOT quit)")
