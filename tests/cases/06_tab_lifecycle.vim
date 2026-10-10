" The list is an accessory of the tab: ":q" closes the tab, and opening a file
" again from the list brings the list along.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

exec "edit " . g:GT_FIX . "/a.txt"
call GT_BuildSearch("TARGET", 2, ["0", "0", "0", "1," . g:GT_FIX . "/a.txt,2,1",
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
call GrooVim_PanelFocus(g:GT_FIX . "/b.txt", 1)
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
call GrooVim_PanelFocus(g:GT_FIX . "/b.txt", 1)
quit
sleep 80m
call GT_Ok("the list alone did not hold the tab", tabpagenr("$") == 1, "   (tabs " . tabpagenr("$") . ")   " . GT_Layout())

" ---- a file already open is not opened again
"
" It is what every conventional editor does, and it is caught at the BIRTH of a
" tab: a tab made for a file that is already somewhere gives way and you land on
" the tab that has it. Walking buffers inside a tab of your own is untouched --
" closing that tab under you would be a surprise of the worst kind.
tabonly! | exec "edit! " . g:GT_FIX . "/a.txt"
exec "tabnew " . g:GT_FIX . "/b.txt"
sleep 80m
call GT_Ok("two different files, two tabs", tabpagenr("$") == 2,
  \ "   (tabs " . tabpagenr("$") . ")")

exec "tabnew " . g:GT_FIX . "/a.txt"
sleep 120m
call GT_Ok("  and a third tab for a file already open gives way",
  \ tabpagenr("$") == 2 && expand("%:t") ==# "a.txt",
  \ "   (tabs " . tabpagenr("$") . ", on " . expand("%:t") . ")")
call GT_Ok("  and it says why", g:GrooVim_GrooVimBarMsgValue =~ "already open",
  \ "   [" . g:GrooVim_GrooVimBarMsgValue . "]")

" An EMPTY tab and then the file: the mark is taken off by a document, so this
" is the same case written in two steps.
tabnew
exec "edit " . g:GT_FIX . "/b.txt"
sleep 120m
call GT_Ok("  and so does an empty tab that then opens one",
  \ tabpagenr("$") == 2 && expand("%:t") ==# "b.txt",
  \ "   (tabs " . tabpagenr("$") . ", on " . expand("%:t") . ")")

exec "tabnew " . g:GT_FIX . "/c.txt"
sleep 80m
call GT_Ok("  and a file nobody has opens its tab as always",
  \ tabpagenr("$") == 3 && expand("%:t") ==# "c.txt",
  \ "   (tabs " . tabpagenr("$") . ", on " . expand("%:t") . ")")

" ---- and a new tab is born at the END of the line
"
" Vim puts it after the tab you are on. The line of tabs is a history -- the
" order you opened them in -- and a tab opened from the middle pushed everything
" to its right along.
tabfirst
exec "tabnew " . g:GT_OUT . "/fim.txt"
sleep 80m
call GT_Ok("a tab opened from the FIRST one lands at the end",
  \ tabpagenr() == tabpagenr("$") && expand("%:t") ==# "fim.txt",
  \ "   (tab " . tabpagenr() . " of " . tabpagenr("$") . ")")

exec "tabnext 2"
tabnew
sleep 80m
call GT_Ok("  and so does an empty one, opened from the middle",
  \ tabpagenr() == tabpagenr("$"),
  \ "   (tab " . tabpagenr() . " of " . tabpagenr("$") . ")")
tabonly!

call GT_Done()
