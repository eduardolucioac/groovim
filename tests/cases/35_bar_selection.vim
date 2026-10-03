" How much is selected, on the bar: the "Sel" of Notepad++.
"
" Measured through the function the bar calls, with the selection ALIVE. A
" "<Cmd>" inside the same feedkeys is what makes that possible: it runs without
" leaving visual mode, so "mode()" and the two ends of the selection are the
" ones the bar would see on its redraw.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

" The answer of the bar for the keys given, with the selection still held.
"
" Asked ONCE and kept: the keys move the cursor, so asking a second time to
" print what was compared would measure a different selection.
func! GT_SelectionWith(keys)
  let g:GT_SEL = "(it never ran)"
  call feedkeys(a:keys . "\<Cmd>let g:GT_SEL = GrooVim_BarSelection()\<cr>\<Esc>", "x")
  return g:GT_SEL
endfunc

func! GT_Body()
  exec "enew"

  " ---- characters, on one line and across lines
  call setline(1, ["alpha bravo charlie", "delta echo", "foxtrot golf hotel"])
  call cursor(1, 1)
  let l:sel = GT_SelectionWith("v4l")
  call GT_Ok("five characters of one line", l:sel ==# " [5,1]",
    \ "   [" . l:sel . "]")

  call cursor(1, 1)
  let l:sel = GT_SelectionWith("vj")
  call GT_Ok("a selection that crosses a line", l:sel ==# " [20,2]",
    \ "   [" . l:sel . "]   (19 of the first line and 1 of the second)")

  " ---- whole lines
  call cursor(1, 1)
  let l:sel = GT_SelectionWith("V2j")
  call GT_Ok("three whole lines", l:sel ==# " [47,3]",
    \ "   [" . l:sel . "]   (19 + 10 + 18, and the line breaks are not characters)")

  " ---- a block, which is the F2->b of GrooVim and not a Ctrl-V (that pastes)
  call cursor(1, 1)
  let l:sel = GT_SelectionWith("\<F2>b2j3l")
  call GT_Ok("a block of three lines by four columns", l:sel ==# " [12,3]",
    \ "   [" . l:sel . "]")

  " ---- characters and not bytes
  call setline(1, "ação coração")
  call cursor(1, 1)
  let l:sel = GT_SelectionWith("v11l")
  call GT_Ok("an accented letter counts as ONE", l:sel ==# " [12,1]",
    \ "   [" . l:sel . "]   (14 bytes, 12 characters)")

  " ---- nothing at all while there is no selection
  call GT_Ok("nothing while you are only typing", GrooVim_BarSelection() ==# "",
    \ "   [" . GrooVim_BarSelection() . "]")

  " ---- the bar really carries it
  call GT_Ok("and the bar asks for it", GrooVim_GrooVimBarWhere() =~# "GrooVim_BarSelection",
    \ "   [" . GrooVim_GrooVimBarWhere() . "]")

  " ---- over the limit the characters are not counted
  "
  " The limit exists for the TIME it takes: counting walks the selected text on
  " every redraw, which is every key of a selection that is growing.
  %delete _
  call setline(1, map(range(1, 30), {_, n -> "line " . n}))
  let g:GrooVim_SelectionCountLimit = 10
  call cursor(1, 1)
  let l:sel = GT_SelectionWith("V20j")
  call GT_Ok("over the limit, only the lines are said", l:sel ==# " [-,21]",
    \ "   [" . l:sel . "]")

  call cursor(1, 1)
  let l:sel = GT_SelectionWith("V2j")
  call GT_Ok("  and under it the characters come back",
    \ l:sel =~# "^ \\[\\d\\+,3\\]$", "   [" . l:sel . "]")
  let g:GrooVim_SelectionCountLimit = 2000

  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
