" The help of F9 opens in a TAB of its own.
"
" Two hundred and seventy lines of reading do not belong in half a screen, and
" they do not belong on top of the document you opened them to ask about.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

func! GT_Labels()
  let l:names = []
  for l:tab in range(1, tabpagenr("$"))
    call add(l:names, GrooVim_TabLabel(l:tab))
  endfor
  return l:names
endfunc

func! GT_Body()
  tabonly!
  exec "edit " . g:GT_FIX . "/a.txt"
  exec "$tabnew " . g:GT_FIX . "/b.txt"
  tabfirst
  call GT_Ok("setup: two tabs, we are in the first",
    \ GT_Labels() ==# ["a.txt", "b.txt"] && tabpagenr() == 1, "   " . string(GT_Labels()))

  call GrooVim_ToogleGrooVimHelp()
  call GT_Ok("F9 opened a tab, it did not split one",
    \ tabpagenr("$") == 3 && winnr("$") == 1,
    \ "   (" . tabpagenr("$") . " tabs, " . winnr("$") . " window)")
  call GT_Ok("  at the END of the tab line, where a new tab goes",
    \ tabpagenr() == 3 && bufname("%") ==# "GrooVimHelp", "   " . string(GT_Labels()))
  call GT_Ok("  and the tab is named after it",
    \ GT_Labels()[2] ==# "GrooVimHelp",
    \ "   " . string(GT_Labels()) . "   (\"[GrooVim]\" would say nothing)")
  call GT_Ok("  the documents were not touched",
    \ GT_Labels()[0] ==# "a.txt" && GT_Labels()[1] ==# "b.txt", "   " . string(GT_Labels()))
  call GT_Ok("  and the help is really in it", line("$") > 200 && &modifiable == 0,
    \ "   (" . line("$") . " lines, modifiable=" . &modifiable . ")")

  " ---- and asking again puts you back where you asked from
  call GrooVim_ToogleGrooVimHelp()
  call GT_Ok("F9 again closed the tab", tabpagenr("$") == 2 && !bufexists("GrooVimHelp"),
    \ "   " . string(GT_Labels()))
  call GT_Ok("  and put us back where we asked from", tabpagenr() == 1,
    \ "   (tab " . tabpagenr() . ", we asked from 1)   (a toggle that leaves you elsewhere is not one)")

  " ---- from the last tab too
  tablast
  call GrooVim_ToogleGrooVimHelp()
  call GT_Ok("from the last tab: the help still goes after it", tabpagenr() == 3,
    \ "   " . string(GT_Labels()))
  call GrooVim_ToogleGrooVimHelp()
  call GT_Ok("  and we come back to it", tabpagenr() == 2 && tabpagenr("$") == 2,
    \ "   (tab " . tabpagenr() . " of " . tabpagenr("$") . ")")

  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
