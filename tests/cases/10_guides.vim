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
call GrooVim_IndentGuideSet()
call GT_Ok("no character, no guide", GT_Guide() ==# "", "   [" . &listchars . "]")
call GT_Ok("but trail and nbsp stay", &listchars =~ "trail:" && &listchars =~ "nbsp:", "   [" . &listchars . "]")
let g:GrooVim_IndentGuideChar = "┊"
call GrooVim_IndentGuideSet()
call GT_Ok("turned back on", GT_Guide() != "", "")

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
  let columns = []
  for c in range(1, 46)
    if nr2char(screenchar(1, c)) ==# g:GrooVim_IndentGuideChar
      call add(columns, c)
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
call SpecificTabConf(2)
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

call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
