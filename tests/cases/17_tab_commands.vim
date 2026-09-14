" Carrying a tab along the tab line, and closing every tab on one side.
"
" Both come from the tab menu of Notepad++: dragging a tab to another place, and
" "Close All to the Right" / "Close All to the Left".
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

" The order of the tabs, by file name, so a failure reads as what you would see.
func! GT_TabOrder()
  let l:names = []
  for l:tab in range(1, tabpagenr("$"))
    call add(l:names, fnamemodify(bufname(tabpagebuflist(l:tab)[0]), ":t"))
  endfor
  return l:names
endfunc

func! GT_Body()
  " ---- carrying the tab: "Ctrl-Shift" with the arrows
  exec "edit " . g:GT_FIX . "/a.txt"
  exec "tabnew " . g:GT_FIX . "/b.txt"
  exec "tabnew " . g:GT_FIX . "/c.txt"
  tabfirst

  call GT_Ok("three tabs, in the order they were opened",
    \ GT_TabOrder() ==# ["a.txt", "b.txt", "c.txt"], "   " . string(GT_TabOrder()))
  call GT_Ok("the keys are mapped in the three modes",
    \ maparg("<C-S-Up>", "n") =~ "GrooVim_TabMove" && maparg("<C-S-Up>", "i") =~ "GrooVim_TabMove" &&
    \ maparg("<C-S-Down>", "v") =~ "GrooVim_TabMove", "")

  call feedkeys("\<C-S-Up>", "x")
  call GT_Ok("Ctrl-Shift-Up carried it to the right",
    \ GT_TabOrder() ==# ["b.txt", "a.txt", "c.txt"], "   " . string(GT_TabOrder()))
  call GT_Ok("  and we went with it", expand('%:t') ==# "a.txt" && tabpagenr() == 2,
    \ "   [" . expand('%:t') . "] tab " . tabpagenr())

  call feedkeys("\<C-S-Up>", "x")
  call GT_Ok("again, and it is the last one",
    \ GT_TabOrder() ==# ["b.txt", "c.txt", "a.txt"], "   " . string(GT_TabOrder()))

  " ---- at the end nothing happens, the way Notepad++ stops at the edge
  call feedkeys("\<C-S-Up>", "x")
  call GT_Ok("at the right end it stays put",
    \ GT_TabOrder() ==# ["b.txt", "c.txt", "a.txt"] && tabpagenr() == 3,
    \ "   " . string(GT_TabOrder()) . " tab " . tabpagenr())

  call feedkeys("\<C-S-Down>\<C-S-Down>", "x")
  call GT_Ok("Ctrl-Shift-Down carried it back to the front",
    \ GT_TabOrder() ==# ["a.txt", "b.txt", "c.txt"], "   " . string(GT_TabOrder()))
  call feedkeys("\<C-S-Down>", "x")
  call GT_Ok("at the left end it stays put too",
    \ GT_TabOrder() ==# ["a.txt", "b.txt", "c.txt"] && tabpagenr() == 1,
    \ "   " . string(GT_TabOrder()) . " tab " . tabpagenr())

  " ---- closing every tab to one side
  tabnext 2
  call GrooVim_TabCloseSide(1)
  call GT_Ok("to the right: closed c.txt only",
    \ GT_TabOrder() ==# ["a.txt", "b.txt"], "   " . string(GT_TabOrder()))
  call GT_Ok("  and left us where we were", expand('%:t') ==# "b.txt", "   [" . expand('%:t') . "]")

  exec "tabnew " . g:GT_FIX . "/c.txt"
  exec "tabnew " . g:GT_FIX . "/spaces.txt"
  tabnext 3
  call GrooVim_TabCloseSide(-1)
  call GT_Ok("to the left: closed the two before it",
    \ GT_TabOrder() ==# ["c.txt", "spaces.txt"], "   " . string(GT_TabOrder()))
  call GT_Ok("  and we are the first one now", tabpagenr() == 1 && expand('%:t') ==# "c.txt",
    \ "   tab " . tabpagenr() . " [" . expand('%:t') . "]")

  " ---- with nothing on that side it is a command that does nothing
  call GrooVim_TabCloseSide(-1)
  call GT_Ok("no tab on that side: nothing happens",
    \ GT_TabOrder() ==# ["c.txt", "spaces.txt"], "   " . string(GT_TabOrder()))

  " ---- and one side never takes the other with it
  tabnext 1
  call GrooVim_TabCloseSide(1)
  call GT_Ok("closing to the right leaves the tab you are in",
    \ tabpagenr("$") == 1 && expand('%:t') ==# "c.txt",
    \ "   " . string(GT_TabOrder()))

  " ---- through the real keys, and not only through the function
  exec "tabnew " . g:GT_FIX . "/a.txt"
  exec "tabnew " . g:GT_FIX . "/b.txt"
  tabnext 1
  call feedkeys("\<F5>>", "x")
  call GT_Ok("F5 and then > closed to the right",
    \ GT_TabOrder() ==# ["c.txt"], "   " . string(GT_TabOrder()))

  exec "tabnew " . g:GT_FIX . "/a.txt"
  exec "tabnew " . g:GT_FIX . "/b.txt"
  tablast
  call feedkeys("\<F5><", "x")
  call GT_Ok("F5 and then < closed to the left",
    \ GT_TabOrder() ==# ["b.txt"], "   " . string(GT_TabOrder()))

  " ---- unsaved text is asked about, not refused
  "
  " The question itself cannot be answered from here: ":confirm" reads the key
  " straight from the terminal and never looks at what "feedkeys" queued, so a
  " case that called this with a modified buffer would hang until the timeout.
  " Measured, from a timer and from startup alike. What IS checked here is that
  " the closing goes through the asking route; the question on screen is checked
  " with screen.sh, where it reads: Save changes to "..."?
  call GT_Ok("closing to the side goes through the asking route",
    \ execute("function GrooVim_TabCloseSide") =~ 'confirm',
    \ "   (a bare :tabclose would answer E37 and close nothing)")
  call GT_Ok("and so does closing the tab you are in",
    \ execute("function GrooVim_CloseAsking") =~ 'confirm', "")

  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
