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
  call feedkeys("\<F5>.", "x")
  call GT_Ok("F5 and then . closed to the right",
    \ GT_TabOrder() ==# ["c.txt"], "   " . string(GT_TabOrder()))

  exec "tabnew " . g:GT_FIX . "/a.txt"
  exec "tabnew " . g:GT_FIX . "/b.txt"
  tablast
  call feedkeys("\<F5>,", "x")
  call GT_Ok("F5 and then , closed to the left",
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
    \ GT_FunctionText("GrooVim_TabCloseSide") =~ 'confirm',
    \ "   (a bare :tabclose would answer E37 and close nothing)")
  call GT_Ok("and so does closing the tab you are in",
    \ GT_FunctionText("GrooVim_CloseAsking") =~ 'confirm', "")

  " ---- F5 w closes the tab you are in
  tabonly!
  exec "edit " . g:GT_FIX . "/a.txt"
  exec "tabnew " . g:GT_FIX . "/b.txt"
  exec "tabnew " . g:GT_FIX . "/c.txt"
  call GT_Ok("setup: three tabs, we are in the last",
    \ GT_TabOrder() ==# ["a.txt", "b.txt", "c.txt"] && tabpagenr() == 3,
    \ "   " . string(GT_TabOrder()) . " tab " . tabpagenr())
  call feedkeys("\<F5>w", "x")
  call GT_Ok("F5 and then w closed the tab we were in",
    \ GT_TabOrder() ==# ["a.txt", "b.txt"], "   " . string(GT_TabOrder()))

  " ---- and on the LAST tab, which Vim refuses to close
  "
  " ":tabclose" answers "E784: Cannot close last tab page" and closes nothing.
  " What has to close there is the document, leaving the empty one Notepad++
  " calls "new 1". Note that b.txt is still a listed buffer at this point, left
  " over from the tabs above -- which is exactly the case where a bare
  " ":bdelete" shows you that old file instead of an empty page.
  tabonly!
  exec "edit " . g:GT_FIX . "/a.txt"
  call GT_Ok("setup: one tab, one file", tabpagenr("$") == 1 && expand("%:t") ==# "a.txt",
    \ "   " . string(GT_TabOrder()))
  let v:errmsg = ""
  call feedkeys("\<F5>w", "x")
  call GT_Ok("last tab: no E784", v:errmsg !~ "E784", "   [" . v:errmsg . "]")
  call GT_Ok("last tab: the tab is still there", tabpagenr("$") == 1, "   (tabs " . tabpagenr("$") . ")")
  call GT_Ok("last tab: the document was closed", expand("%:t") ==# "",
    \ "   [" . expand("%:t") . "]   (an empty one, the \"new 1\" of Notepad++)")
  call GT_Ok("last tab: and it is empty and writable",
    \ line("$") == 1 && getline(1) ==# "" && &modifiable == 1, "")
  call GT_Ok("last tab: the file is gone from the buffer list",
    \ len(filter(getbufinfo({"buflisted": 1}), 'v:val.name =~ "a.txt"')) == 0,
    \ "   (the wipe after the :enew is what removes it)")

  " ---- and the letters that moved out of the way
  call GT_Ok("F5 e is the one that saves every changed file",
    \ !empty(filter(copy(g:GrooVim_Shortcuts),
    \ 'get(v:val, "group", "") ==# "F5" && v:val.key ==# "e" && v:val.run =~ "wa"')),
    \ "   (a is now close everything)")

  " ---- walking the windows of a tab, both ways
  "
  " It was "Ctrl+W", which only ever went forward. Alt and not Ctrl because a
  " terminal cannot send "Ctrl" with a comma: the keyboard table of Konsole has
  " no entry for Comma or Period, and with no entry what arrives is the bare
  " character -- so a "<C-,>" mapping would never fire, here or over an SSH.
  for s:mode in ["n", "i", "v"]
    call GT_Ok("Alt+, and Alt+. walk the windows in mode " . s:mode,
      \ maparg("<A-,>", s:mode) =~ "C-W.W" && maparg("<A-.>", s:mode) =~ "C-W.w",
      \ "   [" . maparg("<A-,>", s:mode) . "] [" . maparg("<A-.>", s:mode) . "]")
  endfor
  " And the key has to ARRIVE. Vim does not read an "Esc" in front of a
  " character as Alt -- ":h :map-alt-keys" names Konsole as one of the terminals
  " that send it that way -- so the mapping was there and the key did nothing.
  " What answers it is the sequence being declared as the key itself.
  let s:said = execute("set <A-,>?") . execute("set <A-.>?")
  call GT_Ok("  and GrooVim tells Vim which sequence the key IS",
    \ s:said =~ "\\^\\[," && s:said =~ "\\^\\[\\.",
    \ "   [" . trim(substitute(s:said, "\n", " ", "g")) . "]")

  call GT_Ok("  and they go opposite ways",
    \ maparg("<A-,>", "n") !=# maparg("<A-.>", "n"),
    \ "   (W is the window before this one, w the next)")
  call GT_Ok("and Ctrl+W is Vim's own again",
    \ maparg("<C-w>", "n") ==# "" && maparg("<C-w>", "i") ==# "",
    \ "   (the key every window command begins with, and the\n" .
    \ "    \"delete the word behind\" of every terminal in insert)")

  " Really walked, and not only mapped.
  tabonly! | only!
  exec "edit " . g:GT_FIX . "/a.txt"
  split
  call GT_Ok("setup: two windows", winnr("$") == 2, "   (" . winnr("$") . ")")
  let s:where = winnr()
  call GT_Press("\<A-.>")
  call GT_Ok("Alt+. moved to the other one", winnr() != s:where,
    \ "   (window " . s:where . " -> " . winnr() . ")")
  call GT_Press("\<A-,>")
  call GT_Ok("  and Alt+, came back", winnr() == s:where,
    \ "   (window " . winnr() . ")")
  only!

  " ---- and what left the list of shortcuts
  "
  " "Select an area" and "the gv of Vim" went with the key that called them, and
  " so did the code behind the first: a function nothing can reach is not a
  " feature, it is weight.
  call GT_Ok("nothing is left calling the range selection",
    \ !exists("*GrooVim_SelectRange") && !exists("g:GrooVim_SelectRangeInitialize"),
    \ "   (it went with F3 and Del, which is the only key that ever called it)")
  call GT_Ok("  and no shortcut names it",
    \ empty(filter(copy(g:GrooVim_Shortcuts),
    \   'has_key(v:val, "run") && type(v:val.run) == type("")
    \   && v:val.run =~ "SelectRange"')), "")

  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
