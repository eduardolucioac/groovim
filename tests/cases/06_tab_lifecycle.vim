" The list is an accessory of the tab: ":q" closes the tab, and opening a file
" again from the list brings the list along.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

exec "edit " . g:GT_FIX . "/a.txt"
call GT_BuildSearch("ALVO", 2, ["0", "0", "0", "1," . g:GT_FIX . "/a.txt,2,1",
  \ "0", "0", "0", "2," . g:GT_FIX . "/b.txt,2,1"])
exec "tabnew " . g:GT_FIX . "/b.txt"
sleep 80m
tabn 1 | sleep 80m

" A tab built by "tabnew" must not hold the file twice: "TabEnter" fires BEFORE
" the file is loaded, and the list was being built into a window that the file
" then took over.
call GT_Ok("tabnew built the right tab", GT_Layout() ==# "[a.txt+GrooVim_SearchGuyResults1][b.txt+GrooVim_SearchGuyResults2]", "   " . GT_Layout())

" ---- ":q" from INSIDE the list closes the whole tab
tabn 2
call GT_GoToList()
call GT_Ok("we are on the list of tab 2", expand('%:t') =~ "SearchGuyResults", "   [" . expand('%:t') . "]")
quit
sleep 80m
call GT_Ok(":q on the list closed the TAB", tabpagenr("$") == 1, "   (tabs " . tabpagenr("$") . ")   " . GT_Layout())
call GT_Ok("the other tab was left alone", GT_Layout() ==# "[a.txt+GrooVim_SearchGuyResults1]", "   " . GT_Layout())

" ---- ":q" on the FILE window does the same
exec "tabnew " . g:GT_FIX . "/b.txt"
sleep 80m
call GT_Ok("built tab 2 again", tabpagenr("$") == 2, "   " . GT_Layout())
call GrooVim_SearchGuyFocusWindow(g:GT_FIX . "/b.txt", 1)
quit
sleep 80m
call GT_Ok(":q on the file closed the TAB", tabpagenr("$") == 1, "   (tabs " . tabpagenr("$") . ")   " . GT_Layout())
call GT_Note("did the list buffer of the closed tab survive? " . bufexists("GrooVim_SearchGuyResults2") . "   (it has to be 0)")
call GT_Ok("the list buffer went away with it", bufexists("GrooVim_SearchGuyResults2") == 0, "")

" ---- the link of the closed file opens it again, WITH a list
call GT_GoToList()
call cursor(8, 1)
call GrooVim_SearchGuyNavigate()
call GT_Ok("opened the closed file again", expand('%:t') ==# "b.txt", "   [" . expand('%:t') . "]")
call GT_Ok("the reopened tab came WITH the list", GT_PanelsInTab() == 1, "   (panels " . GT_PanelsInTab() . ")   " . GT_Layout())

" ---- the list alone does not hold the tab open
call GrooVim_SearchGuyFocusWindow(g:GT_FIX . "/b.txt", 1)
quit
sleep 80m
call GT_Ok("the list alone did not hold the tab", tabpagenr("$") == 1, "   (tabs " . tabpagenr("$") . ")   " . GT_Layout())

call GT_Done()
