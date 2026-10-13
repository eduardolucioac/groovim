" Marking every occurrence of a word -- the "Style all occurrences of token" of
" Notepad++.
"
" It does not move the cursor and does not touch the search: you can mark a name
" and go on searching for something else.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

let g:GT_SEARCH = fnamemodify($GROOVIM_TEST_VIMRC, ":h") . "/groovim/search.vim"
let g:GT_OPTIONS = fnamemodify($GROOVIM_TEST_VIMRC, ":h") . "/groovim/options.vim"

" Which columns of a screen line are painted with the mark.
"
" "screenattr" is the only honest way to ask: a match put up with "matchadd" is
" not in the syntax stack and not in the text, it is paint.
"
" The plain attribute is taken from a line that has NOTHING marked in it. Taking
" it from column 1 of the line being looked at reads the mark itself as plain and
" answers with the columns that are NOT marked -- which is how this was wrong the
" first time.
" Note: The symbols are turned off while the question is asked. With "list" on
" and a "space:" in "listchars", a space is drawn as a character of its own and
" in a colour of its own, so every space read as painted -- measured, columns
" [1,2,3,4,5,6,8] where the mark covers [1,2,3,4,5]. What is being asked here is
" which columns of the TEXT carry the mark, and a symbol is not text.
func! GT_Painted(line, plainLine)
  let l:kept = &l:list
  setlocal nolist
  redraw

  " Screen columns are not text columns: a margin for the signs sits before the
  " text. "screenpos" says where character 1 really landed.
  let l:off = screenpos(win_getid(), a:line, 1).col - 1
  let l:plain = screenattr(a:plainLine, 1 + l:off)
  let l:cols = []
  for l:c in range(1 + l:off, 40 + l:off)
    if screenattr(a:line, l:c) != l:plain && screenchar(a:line, l:c) != 32
      call add(l:cols, l:c - l:off)
    endif
  endfor

  let &l:list = l:kept
  redraw
  return l:cols
endfunc

func! GT_Body()
  set nonumber
  enew
  call setline(1, ["total = 0", "subtotal here", "outra coisa"])
  call cursor(1, 1)

  " ---- nothing is marked to begin with
  call GT_Ok("nothing is marked to begin with", g:GrooVim_MarkedWord ==# "", "")

  call GT_Press("\<F3>m")
  call GT_Ok("F3 m marked the word under the cursor", g:GrooVim_MarkedWord ==# "total",
    \ "   [" . g:GrooVim_MarkedWord . "]")

  redraw
  call GT_Ok("and the word is painted", GT_Painted(1, 3) ==# [1,2,3,4,5],
    \ "   (columns " . string(GT_Painted(1, 3)) . " of \"total = 0\")")
  call GT_Ok("but \"subtotal\" is NOT", empty(GT_Painted(2, 3)),
    \ "   " . string(GT_Painted(2, 3)) . "   (a whole word, not a piece of one)")

  " ---- and it disturbs nothing while it is up
  call GT_Ok("the search register was not touched", @/ !=# "total", "   [" . @/ . "]")
  call GT_Ok("and the cursor did not move", line(".") == 1 && col(".") == 1,
    \ "   (line " . line(".") . " col " . col(".") . ")")

  " ---- the same key takes them down
  call GT_Press("\<F3>m")
  call GT_Ok("pressing it again cleared the marks", g:GrooVim_MarkedWord ==# "", "")
  redraw
  call GT_Ok("  and nothing is painted any more", empty(GT_Painted(1, 3)),
    \ "   " . string(GT_Painted(1, 3)))

  " ---- and so does the key that clears the search highlight
  call cursor(1, 1)
  call GT_Press("\<F3>m")
  call GT_Ok("setup: marked again", g:GrooVim_MarkedWord ==# "total", "")
  call GT_Press("\<F3>/")
  call GT_Ok("F3 / clears the marks as well as the highlight",
    \ g:GrooVim_MarkedWord ==# "",
    \ "   (\"take the highlighting off\" is one idea, not two)")

  " ---- a selection, and not only the word under the cursor
  call setline(1, ["abc def", "xx def yy"])
  call cursor(1, 5)
  call GT_Press("v2l\<F3>m")
  call GT_Ok("in visual mode it marks the selection", g:GrooVim_MarkedWord ==# "def",
    \ "   [" . g:GrooVim_MarkedWord . "]")
  call GrooVim_MarkClear()

  " ---- and it follows you into another window
  call cursor(1, 1)
  call GT_Press("\<F3>m")
  let l:hereMatches = len(filter(getmatches(), 'v:val.group ==# "GrooVimMark"'))
  split
  call GT_Ok("the mark is up in a window you split into",
    \ len(filter(getmatches(), 'v:val.group ==# "GrooVimMark"')) == l:hereMatches,
    \ "   (a match belongs to a window, so it is put up again on entering one)")
  quit
  call GrooVim_MarkClear()

  " ---- and the double click is Vim's own again
  "
  " There was a mapping on it that ran "viw" -- which is what Vim does on a
  " double click anyway, ":h double-click" -- and before that SLEPT 250ms
  " reading the keyboard, in case a "z" came, and then searched for the word. So
  " every double click waited a quarter of a second to do what Vim does at once,
  " for a key nothing ever wrote down.
  "
  " And the mapping cost more than the wait: Vim extends a double click to the
  " MATCHING bracket when you click on one, and "viw" took that away. Measured
  " through a real terminal on "chamada(um, dois)": clicking the "(" now yanks
  " "(um, dois)", and under the mapping it yanked "chamada".
  enew!
  call GT_Ok("no mapping stands in front of the double click",
    \ maparg("<2-LeftMouse>", "n") ==# "" && maparg("<2-LeftMouse>", "i") ==# "" &&
    \ maparg("<2-LeftMouse>", "v") ==# "",
    \ "   [" . maparg("<2-LeftMouse>", "n") . "]")
  call GT_Ok("  and the function behind it went with it",
    \ !exists("*GrooVim_SelectNSearch"),
    \ "   (nothing could reach it any more: the key was the only caller)")
  call GT_Ok("  and no shortcut on the list names it",
    \ empty(filter(copy(g:GrooVim_Shortcuts),
    \   'has_key(v:val, "run") && type(v:val.run) == type("")
    \   && v:val.run =~ "SelectNSearch"')), "")
  call GT_Ok("and the mouse is still on, or none of it would work",
    \ &mouse !=# "", "   [mouse=" . &mouse . "]")

  " The panels keep a double click of their own, which is another thing: there
  " it means "take me to this line", and it is written on the buffer alone.
  call GT_Ok("the panels keep their own, on their own buffer",
    \ GT_FunctionText("GrooVim_SearchGuyPanelSetup") =~ "2-LeftMouse",
    \ "   (there it means \"take me to this line\")")

  " ---- and the keys that walk between what a search found
  "
  " They paint the match they land on for four tenths of a second, which is what
  " tells you WHICH of them you are on when every one is highlighted the same.
  "
  " They were written at the end of the settings part, which is about the
  " screens of F5->c, while the function they call lives in the search part. A
  " key written apart from the thing it presses is a key nobody finds.
  %delete _
  call setline(1, ["alpha one", "nothing", "alpha two", "nothing", "alpha three"])
  let @/ = "alpha"
  call cursor(1, 1)
  call feedkeys("n", "x")
  call GT_Ok("n goes to the next match", line(".") == 3, "   (line " . line(".") . ")")
  " The paint cannot be caught from here: the blink is SYNCHRONOUS -- it paints,
  " redraws, sleeps and takes it off -- so by the time the key has returned
  " there is nothing left to look at. What is asked is that it still blinks.
  call GT_Ok("  and blinks on the one it landed on",
    \ GT_FunctionText("GrooVim_HLNext") =~ "matchadd('WhiteOnRed'" &&
    \ GT_FunctionText("GrooVim_HLNext") =~ "sleep" &&
    \ GT_FunctionText("GrooVim_HLNext") =~ "matchdelete",
    \ "   (red going forward, blue coming back)")
  call feedkeys("N", "x")
  call GT_Ok("N goes back", line(".") == 1, "   (line " . line(".") . ")")
  call GT_Ok("and both are written where the search is",
    \ !empty(filter(readfile(g:GT_SEARCH), 'v:val =~ "nnoremap .*<expr> n "')) &&
    \ empty(filter(readfile(g:GT_OPTIONS), 'v:val =~ "GrooVim_HLNext"')),
    \ "   (they call GrooVim_HLNext, which is in search.vim)")

  " ---- the mark is the WORD, and a selection changes nothing
"
" It used to take what was SELECTED when there was a selection, which is another
" feature wearing this key: marking "my selected text" lit up every place those
" three words happen to appear in a row, which is a search and not a mark.
exec "enew!"
call setline(1, ["alpha beta gamma", "beta alpha beta"])
call cursor(1, 1)
call GT_Press("vj$\<F2>b")
exec "normal! \<Esc>"
call cursor(1, 7)
call GT_Press("\<F3>m")
call GT_Ok("over a selection it still marks the WORD under the cursor",
  \ g:GrooVim_MarkedWord ==# "beta", "   [" . g:GrooVim_MarkedWord . "]")
call GrooVim_MarkClear()

call GT_Ok("  and what it asks for takes no mode at all",
  \ GT_FunctionText("GrooVim_MarkWhat") !~ "a:mode" &&
  \ GT_FunctionText("GrooVim_MarkWhat") =~ "cword",
  \ "   (the word under the cursor, and nothing else)")

" ---- and a cursor over a SPACE marks nothing
"
" "<cword>" of Vim hands back the next word on the line when the cursor sits on
" a blank, so a cursor resting on a space lit up the word AHEAD of it -- a word
" nobody pointed at. The cursor of a terminal is a block over one character.
exec "enew!"
call setline(1, ["alpha beta", "beta gamma"])
call cursor(1, 6)
call GT_Press("\<F3>m")
call GT_Ok("over a space it marks nothing",
  \ g:GrooVim_MarkedWord ==# "", "   [" . g:GrooVim_MarkedWord . "]" .
  \ "   (the word next to the cursor is not the word it is on)")

call cursor(1, 7)
call GT_Press("\<F3>m")
call GT_Ok("  and one column to the right it marks that word",
  \ g:GrooVim_MarkedWord ==# "beta", "   [" . g:GrooVim_MarkedWord . "]")
call GrooVim_MarkClear()

call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
