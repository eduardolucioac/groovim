" The name of a tab is always a document of yours, never the name of the list.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

exec "edit " . g:GT_FIX . "/a.txt"
call GT_BuildSearch("ALVO", 2, ["0", "0", "0", "1," . g:GT_FIX . "/a.txt,2,1"])
exec "tabnew " . g:GT_FIX . "/b.txt"
sleep 80m

call GT_Ok("the tab line is the one of GrooVim", &tabline ==# "%!GrooVim_TabLine()", "   [" . &tabline . "]")
call GT_Ok("label with the cursor on the file", GrooVim_TabLabel(tabpagenr()) ==# "b.txt", "   [" . GrooVim_TabLabel(tabpagenr()) . "]")

call GT_GoToList()
call GT_Ok("we are on the list", expand('%:t') =~ "SearchGuyResults", "   [" . expand('%:t') . "]")
call GT_Ok("the label is STILL the file", GrooVim_TabLabel(tabpagenr()) ==# "b.txt", "   [" . GrooVim_TabLabel(tabpagenr()) . "]")
call GT_Ok("the tab line does not name the list", GrooVim_TabLine() !~ "SearchGuyResults", "   [" . substitute(GrooVim_TabLine(), '%#\w*#\|%\d*T', '', 'g') . "]")
call GT_Ok("the list does not count as a window", GrooVim_TabLine() !~ " 2 ", "   [" . substitute(GrooVim_TabLine(), '%#\w*#\|%\d*T', '', 'g') . "]")

" ---- the "+" for modified still shows
call GrooVim_SearchGuyFocusWindow(g:GT_FIX . "/b.txt", 1)
call append(1, "dirty")
call GT_Ok("the tab line shows the + for modified", GrooVim_TabLine() =~ "+", "   [" . substitute(GrooVim_TabLine(), '%#\w*#\|%\d*T', '', 'g') . "]")

" ---- what counts as an accessory lives in one place only
call GT_Ok("IsHelperBuffer knows the list", GrooVim_IsHelperBuffer("GrooVim_SearchGuyResults3"), "")
call GT_Ok("IsHelperBuffer knows NERDTree", GrooVim_IsHelperBuffer("NERD_tree_1"), "")
call GT_Ok("IsHelperBuffer knows the help", GrooVim_IsHelperBuffer("GrooVimHelp"), "")
call GT_Ok("IsHelperBuffer does not catch a file", !GrooVim_IsHelperBuffer("b.txt"), "")

" ---- PutOnEditWindow leaves the accessories without spinning for ever
call GT_GoToList()
call GrooVim_PutOnEditWindow()
call GT_Ok("PutOnEditWindow went to the file", !GrooVim_IsHelperBuffer(expand('%:t')), "   [" . expand('%:t') . "]")

call GT_Done()
