" The indent guides: the width is read from the options of Vim at drawing time.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

func! GT_Guide()
  " the part of listchars that draws the guides, or "" when there is none
  return matchstr(&listchars, 'leadmultispace:\zs.*')
endfunc
func! GT_GuideWidth()
  " how many columns between one guide and the next
  return strchars(GT_Guide())
endfunc

" The body runs after startup: see GT_AfterStartup in _common.vim.
func! GT_Body()
exec "edit " . g:GT_FIX . "/indent.sh"

call GT_Ok("there is a guide in listchars", GT_Guide() != "", "   [" . &listchars . "]")
" strcharpart and not [0]: string indexes in VimScript count BYTES, and the
" guide is multibyte
call GT_Ok("the character is the configured one", strcharpart(GT_Guide(), 0, 1) ==# g:GrooVim_IndentGuideChar, "   [" . strcharpart(GT_Guide(), 0, 1) . "]")

" ---- the width follows shiftwidth, at the moment it changes
for width in [2, 4, 8, 3]
  exec "set shiftwidth=" . width
  call GT_Ok("shiftwidth=" . width . " -> guide every " . width, GT_GuideWidth() == width, "   (guide every " . GT_GuideWidth() . ")")
endfor

" ---- shiftwidth=0 means "use tabstop"
set tabstop=6
set shiftwidth=0
call GT_Ok("shiftwidth=0 falls back to tabstop", GT_GuideWidth() == 6, "   (guide every " . GT_GuideWidth() . ", tabstop " . &tabstop . ")")
set tabstop=4
call GT_Ok("changing tabstop moves the guide too", GT_GuideWidth() == 4, "   (guide every " . GT_GuideWidth() . ")")

" ---- a width of 1 makes no sense: there is no guide to draw
set shiftwidth=1
call GT_Ok("shiftwidth=1 draws no guide", GT_Guide() ==# "", "   [" . &listchars . "]")
set shiftwidth=2
call GT_Ok("and it comes back when the width does", GT_GuideWidth() == 2, "")

" ---- the rest of listchars is not lost on the way
call GT_Ok("trail is still in listchars", &listchars =~ "trail:", "   [" . &listchars . "]")
call GT_Ok("nbsp is still in listchars", &listchars =~ "nbsp:", "")

" ---- turning the guides off
let g:GrooVim_IndentGuideChar = ""
call GrooVim_SymbolsSet()
call GT_Ok("no character, no guide", GT_Guide() ==# "", "   [" . &listchars . "]")
call GT_Ok("but trail and nbsp stay", &listchars =~ "trail:" && &listchars =~ "nbsp:", "   [" . &listchars . "]")
let g:GrooVim_IndentGuideChar = "┊"
call GrooVim_SymbolsSet()
call GT_Ok("turned back on", GT_Guide() != "", "")

" ---- a char Vim will not take
"
" One single-width char per column is what a "leadmultispace" wants, so an emoji
" or the comma that separates the fields is refused with "E1512"/"E1511". It is
" the CHARACTER that is refused and not the option -- the version of Vim has
" nothing to do with it, the installer refuses anything under 9.2 and
" "leadmultispace" is older than that. What has to survive is everything else:
" an empty "listchars" is the default of Vim showing through, "$" at the end of
" every line.
for GT_BAD in ["\U0001F600", ","]
  let g:GrooVim_IndentGuideChar = GT_BAD
  call GrooVim_GrooVimBarMsg("", "")
  call GrooVim_SymbolsSet()
  call GT_Ok("the char [" . GT_BAD . "] is refused, and draws no guide",
    \ GT_Guide() ==# "", "   [" . &listchars . "]")
  call GT_Ok("  but the other symbols stay",
    \ &listchars =~ "tab:" && &listchars =~ "trail:" && &listchars =~ "nbsp:",
    \ "   [" . &listchars . "]   (an empty listchars would draw a \"$\" on every line)")
  call GT_Ok("  and it says so instead of drawing nothing in silence",
    \ g:GrooVim_GrooVimBarMsgValue =~ "refused", "   [" . g:GrooVim_GrooVimBarMsgValue . "]")
endfor
let g:GrooVim_IndentGuideChar = "┊"
call GrooVim_GrooVimBarMsg("", "")
call GrooVim_SymbolsSet()
call GT_Ok("and a char it takes comes back to drawing", GT_Guide() != "",
  \ "   [" . GT_Guide() . "]")

" ---- where the guides land ON SCREEN, read from Vim itself
"
" listchars states the rule; this states the drawing. It is the proof that the
" guide marks every "shiftwidth" columns starting from the FIRST one, and not
" with a first gap different from the others.
set nonumber
exec "edit " . g:GT_FIX . "/spaces.txt"
for pair in [[2, [1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39]],
  \ [4, [1,5,9,13,17,21,25,29,33,37]],
  \ [8, [1,9,17,25,33]]]
  exec "set shiftwidth=" . pair[0]
  redraw
  " Screen columns are not text columns: a margin for the signs sits before the
  " text, and it is two cells wide. "screenpos" says where character 1 of the
  " line really landed, so what is counted here is the text and not the window.
  let off = screenpos(win_getid(), 1, 1).col - 1
  let columns = []
  for c in range(1 + off, 46 + off)
    if nr2char(screenchar(1, c)) ==# g:GrooVim_IndentGuideChar
      call add(columns, c - off)
    endif
  endfor
  call GT_Ok("on screen, shiftwidth=" . pair[0] . ": guides every " . pair[0],
    \ columns == pair[1], "   " . string(columns))
endfor

" ---- indenting: what the user calls "the width"
"
" A width only means what you expect while tabstop, shiftwidth and softtabstop
" agree. With the three together, Tab lands ON the width and then on twice it,
" wherever the line already was -- the way Notepad++ walks its tab stops.
"
" The real key, through the real mapping.
"
" The first version of this used "normal! i<Tab>", which does NOT go through the
" mappings and measured the Tab of insert mode -- precisely the only one GrooVim
" does not remap. Normal mode calls GrooVim_NormalTab, and that is where the
" defect was.
func! GT_Indent(startingIndent, howMany, ...)
  let key = a:0 > 0 ? a:1 : "\<Tab>"
  %delete _
  call setline(1, repeat(" ", a:startingIndent) . "X")
  let steps = [a:startingIndent]
  for i in range(1, a:howMany)
    call cursor(1, match(getline(1), "X") + 1)
    call feedkeys(key, "x")
    call add(steps, match(getline(1), "X"))
  endfor
  return steps
endfunc

exec "edit " . g:GT_FIX . "/indent.sh"
call GrooVim_IndentWidthHere(2)
call GT_Ok("width 2: Tab walks 2 by 2", GT_Indent(0, 3) == [0, 2, 4, 6], "   " . string(GT_Indent(0, 3)))

" shiftwidth alone does NOT change the Tab, and that is why the command exists
set shiftwidth=8
call GT_Ok("shiftround is on", &shiftround == 1, "   (it is what makes the indent REACH the stop)")

GrooVimIndent 8
call GT_Ok("GrooVimIndent moves the three options", &tabstop == 8 && &shiftwidth == 8 && &softtabstop == 8, "   (ts=" . &tabstop . " sw=" . &shiftwidth . " sts=" . &softtabstop . ")")
call GT_Ok("width 8, from zero: 8, 16, 24", GT_Indent(0, 3) == [0, 8, 16, 24], "   " . string(GT_Indent(0, 3)))
call GT_Ok("width 8, starting from 2: lands on 8", GT_Indent(2, 3) == [2, 8, 16, 24], "   " . string(GT_Indent(2, 3)) . "   (and not 2, 10, 18)")
call GT_Ok("width 8, starting from 5: lands on 8", GT_Indent(5, 2) == [5, 8, 16], "   " . string(GT_Indent(5, 2)))
call GT_Ok("the guide followed the command", GT_GuideWidth() == 8, "   (guide every " . GT_GuideWidth() . ")")

" ---- unindenting comes back through the same stops
call GT_Ok("Shift-Tab from 10 goes back to 8", GT_Indent(10, 2, "\<S-Tab>") == [10, 8, 0], "   " . string(GT_Indent(10, 2, "\<S-Tab>")))
call GT_Ok("Shift-Tab from 16 goes back to 8", GT_Indent(16, 2, "\<S-Tab>") == [16, 8, 0], "   " . string(GT_Indent(16, 2, "\<S-Tab>")))

GrooVimIndent 4
call GT_Ok("back to 4: 4, 8, 12", GT_Indent(0, 3) == [0, 4, 8, 12], "   " . string(GT_Indent(0, 3)))
call GT_Ok("from 3 it lands on 4", GT_Indent(3, 2) == [3, 4, 8], "   " . string(GT_Indent(3, 2)))

" the command refuses what is not a width
GrooVimIndent 0
call GT_Ok("refuses zero, keeps the width", &shiftwidth == 4, "   (sw=" . &shiftwidth . ")")
GrooVimIndent abc
call GT_Ok("refuses text, keeps the width", &shiftwidth == 4, "   (sw=" . &shiftwidth . ")")
GrooVimIndent 3abc
call GT_Ok("refuses 3abc, keeps the width", &shiftwidth == 4, "   (sw=" . &shiftwidth . ")")
GrooVimIndent
call GT_Ok("with no argument it changes nothing", &shiftwidth == 4, "   (sw=" . &shiftwidth . ")")

" ---- the encoding comes before the parts, and it is not a matter of taste
"
" Vim turns a "\uXXXX" in a double-quoted string into the bytes of whatever
" 'encoding' is at the moment it READS the line, and it takes that from the
" locale it started in. On a machine with no UTF-8 locale -- a headless server,
" a container, a sudo that strips LANG -- it starts in latin1, the "\u250A" of
" the guide collapses into one byte, and Vim refuses it with "E1512: Wrong
" character width". The guides went silently missing, and the "$" of the default
" listchars showed through in their place.
"
" This reads the file instead of the running Vim on purpose: under a UTF-8
" locale the bug cannot be reproduced, and the order in the file is what decides
" it on the machines where it can.
let l:lines = readfile($GROOVIM_TEST_VIMRC)
let l:encodingAt = match(l:lines, '^set encoding=utf-8')
let l:sourceAt = match(l:lines, '^\s*exec "source " . fnameescape')
call GT_Ok("the .vimrc sets the encoding", l:encodingAt >= 0, "   (line " . (l:encodingAt + 1) . ")")
call GT_Ok("  and it does it BEFORE sourcing a single part",
  \ l:encodingAt >= 0 && l:sourceAt > l:encodingAt,
  \ "   (encoding on line " . (l:encodingAt + 1) . ", the parts load on line " . (l:sourceAt + 1) . ")")
call GT_Ok("so the guide is a real character and not one byte",
  \ strchars(g:GrooVim_IndentGuideChar) == 1 && len(g:GrooVim_IndentGuideChar) > 1,
  \ "   [" . g:GrooVim_IndentGuideChar . "] " . len(g:GrooVim_IndentGuideChar) . " bytes")

" ---- and when the guide cannot be drawn, what is left is not nothing
"
" An empty listchars is not "no guides": it is the default of Vim showing
" through, which puts a "$" at the end of every line.
let l:kept = g:GrooVim_IndentGuideChar
let g:GrooVim_IndentGuideChar = "\uFF21"
call GrooVim_SymbolsSet()
call GT_Ok("a guide Vim refuses does not empty listchars", &listchars != "",
  \ "   [" . &listchars . "]   (a double width character: E1512)")
call GT_Ok("  and trail survives it", &listchars =~ "trail:", "   [" . &listchars . "]")
let g:GrooVim_IndentGuideChar = l:kept
call GrooVim_SymbolsSet()
call GT_Ok("and the real one comes back", GT_GuideWidth() > 0, "   [" . &listchars . "]")

call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
