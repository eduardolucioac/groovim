" Marking every occurrence of a word -- the "Style all occurrences of token" of
" Notepad++.
"
" It does not move the cursor and does not touch the search: you can mark a name
" and go on searching for something else.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

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

  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
