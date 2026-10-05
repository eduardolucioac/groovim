" The name of a tab is always a document of yours, never the name of the list.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

exec "edit " . g:GT_FIX . "/a.txt"
call GT_BuildSearch("TARGET", 2, ["0", "0", "0", "1," . g:GT_FIX . "/a.txt,2,1"])
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
call GrooVim_PanelFocus(g:GT_FIX . "/b.txt", 1)
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

" ---- and with more tabs than the line is wide, the line SCROLLS
"
" It used to be written whole and Vim cut what did not fit, and what it cut was
" the left end: going back to an old tab left you on a tab whose name was off
" the screen. The one thing a tab line is for is saying where you are.
"
" The window of tabs follows you now, moving only as much as it has to, which is
" what Notepad++ does with the same problem.
func! GT_Drawn()
  return substitute(GrooVim_TabLine(), '%#\w*#\|%\d*T', "", "g")
endfunc
func! GT_Shows(tab)
  return stridx(GT_Drawn(), GrooVim_TabLabel(a:tab)) >= 0
endfunc

let g:GT_WIDE = &columns
set columns=60
tabonly!
for g:GT_N in ["um", "dois", "tres", "quatro", "cinco", "seis", "sete", "oito",
  \ "nove", "dez", "onze", "doze"]
  exec "tabnew " . g:GT_FIX . "/tl_" . g:GT_N . ".txt"
endfor

let g:GT_LOST = []
for g:GT_AT in range(1, tabpagenr("$"))
  exec "tabnext " . g:GT_AT
  if !GT_Shows(g:GT_AT)
    call add(g:GT_LOST, g:GT_AT)
  endif
endfor
call GT_Ok("walking every tab, the one you are on is always drawn",
  \ empty(g:GT_LOST), "   " . (empty(g:GT_LOST) ? "(" . tabpagenr("$") .
  \ " tabs in " . &columns . " columns)" : string(g:GT_LOST)))

let g:GT_BACK = []
for g:GT_AT in range(tabpagenr("$"), 1, -1)
  exec "tabnext " . g:GT_AT
  if !GT_Shows(g:GT_AT)
    call add(g:GT_BACK, g:GT_AT)
  endif
endfor
call GT_Ok("  and walking back as well", empty(g:GT_BACK),
  \ "   " . (empty(g:GT_BACK) ? "(which is the way it was lost)" : string(g:GT_BACK)))

exec "tabnext " . tabpagenr("$")
call GT_Ok("a mark says the line goes on to the left",
  \ GT_Drawn() =~ g:GrooVim_TabMoreLeft, "   [" . GT_Drawn() . "]")
tabnext 1
call GT_Ok("  and to the right", GT_Drawn() =~ g:GrooVim_TabMoreRight,
  \ "   [" . GT_Drawn() . "]")
call GT_Ok("  and the line never runs past the terminal",
  \ strdisplaywidth(GT_Drawn()) <= &columns,
  \ "   (" . strdisplaywidth(GT_Drawn()) . " of " . &columns . " columns)")

tabonly!
let &columns = g:GT_WIDE

" ---- two tabs with the same file name
"
" The name alone is what a tab wants to be, and two of them written the same way
" is a tab line that cannot answer the one question it exists to answer. It came
" up for real with the "help.vim" of the project open beside the "help.vim" of
" the installation: two different files, one name, and no way to tell which tab
" was which.
exec "silent! !mkdir -p " . g:GT_OUT . "/um/dentro " . g:GT_OUT . "/dois/dentro"
call writefile(["um"], g:GT_OUT . "/um/igual.txt")
call writefile(["dois"], g:GT_OUT . "/dois/igual.txt")
call writefile(["um"], g:GT_OUT . "/um/dentro/fundo.txt")
call writefile(["dois"], g:GT_OUT . "/dois/dentro/fundo.txt")

exec "edit! " . g:GT_OUT . "/um/igual.txt"
exec "tabnew " . g:GT_OUT . "/dois/igual.txt"
call GT_Ok("two tabs with one name show the directory that differs",
  \ GrooVim_TabLabel(1) ==# "um/igual.txt" && GrooVim_TabLabel(2) ==# "dois/igual.txt",
  \ "   [" . GrooVim_TabLabel(1) . "] [" . GrooVim_TabLabel(2) . "]")

exec "tabnew " . g:GT_FIX . "/a.txt"
call GT_Ok("  and a tab that collides with nobody keeps its plain name",
  \ GrooVim_TabLabel(3) ==# "a.txt", "   [" . GrooVim_TabLabel(3) . "]")

exec "tabnew " . g:GT_OUT . "/um/dentro/fundo.txt"
exec "tabnew " . g:GT_OUT . "/dois/dentro/fundo.txt"
call GT_Ok("  and when the directory is the same too, the deeper one answers",
  \ GrooVim_TabLabel(4) ==# "um/.../fundo.txt" &&
  \ GrooVim_TabLabel(5) ==# "dois/.../fundo.txt",
  \ "   [" . GrooVim_TabLabel(4) . "] [" . GrooVim_TabLabel(5) . "]" .
  \ "   (what lies between is the same for both, so it is not an answer)")

" The same FILE in two tabs is not a collision of names: no path separates it
" from itself, and a tab that answered with one would be answering a question
" nobody asked.
exec "tabnew " . g:GT_OUT . "/um/igual.txt"
call GT_Ok("  and the same file in two tabs keeps its plain name",
  \ GrooVim_TabLabel(1) ==# "um/igual.txt" && GrooVim_TabLabel(6) ==# "um/igual.txt",
  \ "   [" . GrooVim_TabLabel(1) . "] [" . GrooVim_TabLabel(6) . "]" .
  \ "   (both still answer the \"dois/igual.txt\" of tab 2)")
exec "tabclose 6"

exec "tabclose 2"
call GT_Ok("  and closing one gives the other its plain name back",
  \ GrooVim_TabLabel(1) ==# "igual.txt", "   [" . GrooVim_TabLabel(1) . "]" .
  \ "   (measured against the other tabs, not kept in a list)")

tabonly!

call GT_Done()
