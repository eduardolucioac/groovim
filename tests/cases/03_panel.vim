" The occurrence list: what it is (buffer, bar) and how it behaves.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

exec "edit " . g:GT_FIX . "/a.txt"
call GT_BuildSearch("TARGET", 2, ["0", "0", "0", "1," . g:GT_FIX . "/a.txt,2,21", "1," . g:GT_FIX . "/a.txt,4,22",
  \ "0", "0", "0", "2," . g:GT_FIX . "/b.txt,2,21", "2," . g:GT_FIX . "/b.txt,4,20", "2," . g:GT_FIX . "/b.txt,4,31"])
call GrooVim_SearchGuySync()
call GT_Ok("the list opened", GT_GoToList(), "   " . GT_Layout())

" ---- a panel always wraps, whatever the editor is set to
"
" The two are not the same question. Word wrap is about your documents; a panel
" is a LIST, and a line of it that runs off the screen is an answer you cannot
" read -- the path, the line and the text of an occurrence, cut where the window
" happens to end.
call GT_Ok("the list wraps", &wrap == 1, "   (and the editor is on " .
  \ (g:GrooVim_WordWrap ? "wrap" : "nowrap") . ")")
call GT_Ok("  and it folds at a space, not inside a path", &linebreak == 1, "")

let s:was = g:GrooVim_WordWrap
let g:GrooVim_WordWrap = 0
call GrooVim_WordWrapSet()
call GT_Ok("  and turning the word wrap of the editor OFF does not reach it",
  \ &wrap == 1, "   (it is \"setlocal\", so it belongs to this window)")
let g:GrooVim_WordWrap = s:was
call GrooVim_WordWrapSet()

" ---- the buffer must not behave like a file you forgot to save
call GT_Ok("buftype = nofile", &buftype ==# "nofile", "   [" . &buftype . "]")
call GT_Ok("does not show up in :ls", &buflisted == 0, "")
call GT_Ok("does not show up as modified", &modified == 0, "")
call GT_Ok("is not modifiable", &modifiable == 0, "")
call GT_Ok("bufhidden = wipe", &bufhidden ==# "wipe", "   [" . &bufhidden . "]   (or the old buffer stops the next list from being built)")

" ---- the bar is the one of Notepad++, and only on this window
call GT_Ok("bar: the text of Notepad++", GrooVim_SearchGuyBar() ==# 'Search "TARGET" (5 hits in 2 files of 2 searched)', "   [" . GrooVim_SearchGuyBar() . "]")
call GT_Ok("the bar belongs to this window", &l:statusline ==# "%!GrooVim_SearchGuyBar()", "   [" . &l:statusline . "]")
wincmd p
call GT_Ok("the file window keeps the bar of GrooVim", &l:statusline ==# "", "   [" . &l:statusline . "]")
call GT_GoToList()

" ---- singular, plural, and the "%" the bar would eat
let g:matchedLinesGlobalNavArray = ["0", "1,/x/a.txt,2,1"]
let g:GrooVim_SearchGuyFilesSearched = 1
call GT_Ok("singular: 1 hit in 1 file of 1", GrooVim_SearchGuyBar() ==# 'Search "TARGET" (1 hit in 1 file of 1 searched)', "   [" . GrooVim_SearchGuyBar() . "]")
let g:matchedLinesGlobalNavArray = []
call GT_Ok("no occurrences at all", GrooVim_SearchGuyBar() ==# 'Search "TARGET" (0 hits in 0 files of 1 searched)', "   [" . GrooVim_SearchGuyBar() . "]")
let g:GrooVim_SearchGuyValue = "50%"
let g:matchedLinesGlobalNavArray = ["1,/x/a.txt,2,1"]
call GT_Ok("a value with % does not break the bar", GrooVim_SearchGuyBar() =~ '50%%', "   [" . GrooVim_SearchGuyBar() . "]")

" ---- Enter navigates, Del does not navigate any more
call GT_Ok("<Enter> is a mapping of the buffer", get(maparg("<Enter>", "n", 0, 1), "buffer", 0) == 1, "")
call GT_Ok("<Enter> navigates", maparg("<Enter>", "n") =~ "SearchGuyNavigate", "   [" . maparg("<Enter>", "n") . "]")
call GT_Ok("<Del> does NOT navigate any more", maparg("<Del>", "n") ==# "<Nop>", "   [" . maparg("<Del>", "n") . "]")
call GT_Ok("GrooVim_DelBehavior was removed", exists("*GrooVim_DelBehavior") == 0, "")

" ---- and the walk that FINDS the occurrences, which is another thing
"
" Everything above is about the panel, over a list built by hand. This is the
" list being built: the traveler walking the file and writing down every match.
"
" It used to start with "norm gg0n" -- to the top, then to the NEXT match -- and
" the top IS the match when a file begins with one, so it jumped over it.
" Measured through a real terminal: a file with the word on line 1 column 1 and
" again on line 2 answered "1 hit" and listed only the second; moving the word
" one column to the right brought both back.
func! GT_Travelled(lines)
  wincmd p
  %delete _
  call setline(1, a:lines)
  let @/ = "alpha"
  let g:matchedLines = ""
  let g:matchedLinesGlobal = ""
  let g:matchedLinesGlobalNavArray = []
  let g:GrooVim_SearchGuyFilesSearched = 0
  call GrooVim_SearchGuyTraveler("")
  let l:found = len(filter(copy(g:matchedLinesGlobalNavArray), 'v:val != "0"'))
  call GT_GoToList()
  return l:found
endfunc

let g:GT_FIRST = GT_Travelled(["alpha at one", "beta", "alpha at three"])
call GT_Ok("the walk takes a match on the first character of the file",
  \ g:GT_FIRST == 2, "   (" . g:GT_FIRST . " of 2)")
let g:GT_SHIFTED = GT_Travelled(["x alpha at one", "beta", "alpha at three"])
call GT_Ok("  the same as one a column further in", g:GT_SHIFTED == 2,
  \ "   (" . g:GT_SHIFTED . " of 2)   (this one always worked, which is what pointed at the other)")
let g:GT_NONE = GT_Travelled(["nothing here", "nor here"])
call GT_Ok("  and a file with none says none", g:GT_NONE == 0,
  \ "   (" . g:GT_NONE . ")")

" ---- the rule a panel draws is as wide as the panel, and no wider
"
" It was a hundred and three dashes written into the string, with the label
" counted out by hand in the middle of them. The panels wrap AND break at a
" space, so one column over the edge was not one column of damage: the rule
" folded at the last space before it -- the one inside "[ Search List ]" -- and
" half of it went down to the next row, taking a line of the list with it.
call GT_Ok("the rule is as wide as the panel has room for",
  \ strdisplaywidth(GrooVim_PanelRule("Search List")) == GrooVim_PanelRoom(),
  \ "   (" . strdisplaywidth(GrooVim_PanelRule("Search List")) . " of " .
  \ GrooVim_PanelRoom() . " columns)")
call GT_Ok("  and the label sits in the middle of it",
  \ GrooVim_PanelRule("Search List") =~ "^-\\+\\[ Search List \\]-\\+$",
  \ "   (so it stays in the middle at any width)")
call GT_Ok("  and the shorter one never goes over either",
  \ strdisplaywidth(GrooVim_PanelRuleShort()) <= GrooVim_PanelRoom(),
  \ "   (" . strdisplaywidth(GrooVim_PanelRuleShort()) .
  \ " columns, and it divides INSIDE what the other opened)")
call GT_Ok("  and the room is the panel's own, gutter taken off",
  \ GT_FunctionText("GrooVim_PanelRoom") =~ "screenpos" &&
  \ GT_FunctionText("GrooVim_PanelRoom") =~ "win_screenpos",
  \ "   (the numbers and the column the signs sit in are not text)")
call GT_Ok("  and no panel writes a rule of its own any more",
  \ empty(filter(GT_SourceLines(), 'v:val =~ "\"-\\{20,}"')),
  \ "   (a hundred and three dashes fit one window and no other)")

call GT_Done()
