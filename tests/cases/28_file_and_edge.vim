" The settings of the FILE that is open, and the line that says a line is long.
"
" Both come from menus of Notepad++: Encoding and "EOL Conversion" for the first,
" "Vertical Edge" for the second. What they have in common is that they are about
" the DOCUMENT and the screen, not about what a key does.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

" Where a column of the buffer lands on the screen. The numbers take room on the
" left, so the two cannot be compared directly.
func! GT_ScreenCol(column)
  return screenpos(0, 1, 1).col + a:column - 1
endfunc

func! GT_EdgeDrawnOn(line, column)
  redraw
  return screenattr(a:line, GT_ScreenCol(a:column))
   \ != screenattr(a:line, GT_ScreenCol(a:column - 1))
endfunc

func! GT_Body()

" ---- the vertical edge
call GT_Ok("the edge is on column 79", g:GrooVim_EdgeColumn == 79,
  \ "   (" . g:GrooVim_EdgeColumn . ")   (a line of 79 fits in 80, so the mark sits on the first column you should not reach)")
call GT_Ok("  and Vim was told to draw it", &colorcolumn ==# "79",
  \ "   [colorcolumn=" . &colorcolumn . "]")

" Drawn on a narrow column, because the terminal a case runs in is 80 wide and
" column 79 plus the numbers falls off the edge of it.
exec "edit! " . g:GT_OUT . "/edge.txt"
%delete _
call setline(1, ["curta", "", "outra"])
let g:GrooVim_EdgeColumn = 20
call GrooVim_EdgeSet()

call GT_Ok("the line is drawn on a SHORT line", GT_EdgeDrawnOn(1, 20),
  \ "   (\"curta\" is 5 characters and the mark is on 20)")
call GT_Ok("  and on an EMPTY one", GT_EdgeDrawnOn(2, 20),
  \ "   (a match can only paint a character that EXISTS; this is a column)")

let g:GrooVim_EdgeColumn = 0
call GrooVim_EdgeSet()
call GT_Ok("0 takes the line away", &colorcolumn ==# "" && !GT_EdgeDrawnOn(1, 20),
  \ "   [colorcolumn=" . &colorcolumn . "]")
let g:GrooVim_EdgeColumn = 79
call GrooVim_EdgeSet()
call GT_Ok("and it comes back", &colorcolumn ==# "79", "")

" ---- the encodings GrooVim offers, and the letter each answers to
call GT_Ok("the five encodings of the menu are there",
  \ sort(keys(g:GrooVim_Encodings)) ==# ["a", "b", "e", "l", "u"],
  \ "   " . string(map(copy(g:GrooVim_Encodings), 'v:val.name')))
call GT_Ok("and the three line endings",
  \ sort(keys(g:GrooVim_LineEndings)) ==# ["m", "u", "w"],
  \ "   " . string(map(copy(g:GrooVim_LineEndings), 'v:val.name')))

" ---- converting: the text stays, the bytes change
let g:GT_FILE = g:GT_OUT . "/encoding.txt"
exec "edit! " . g:GT_FILE
%delete _
call setline(1, ["linha um", "linha dois"])
write
call GT_Ok("setup: written as it comes", &fileencoding ==# "utf-8" && &bomb == 0
  \ && &fileformat ==# "unix", "   [" . &fileencoding . " bomb=" . &bomb . " " . &fileformat . "]")
call GT_Ok("  and the letters say so", GrooVim_EncodingNow() ==# "u"
  \ && GrooVim_LineEndingNow() ==# "u", "")

call GrooVim_FileSettingsApply("b", "c", "w")
call GT_Ok("convert: utf-8 with BOM and CRLF", &bomb == 1 && &fileformat ==# "dos", "")
call GT_Ok("  and the buffer is marked as changed", &modified == 1,
  \ "   (Vim writes the encoding at the next write, and a buffer with nothing to write would never get there)")
call GT_Ok("  while the text is untouched", getline(1, "$") ==# ["linha um", "linha dois"], "")

write
let g:GT_BYTES = readfile(g:GT_FILE, "b")
call GT_Ok("on disk: the BOM is at the front",
  \ g:GT_BYTES[0][0:2] ==# "\xef\xbb\xbf", "   " . string(g:GT_BYTES[0][0:8]))
call GT_Ok("  and the lines end with CRLF",
  \ g:GT_BYTES[0] =~ "\r$", "   " . string(strtrans(g:GT_BYTES[0])))

" ---- and back
call GrooVim_FileSettingsApply("u", "c", "u")
write
let g:GT_BYTES = readfile(g:GT_FILE, "b")
call GT_Ok("back to utf-8 and LF: no BOM", g:GT_BYTES[0][0:2] !=# "\xef\xbb\xbf",
  \ "   " . string(g:GT_BYTES[0][0:8]))
call GT_Ok("  and no CR", g:GT_BYTES[0] !~ "\r", "")

" ---- reading again is refused while there is something to lose
call setline(1, "mudei isto")
call GT_Ok("setup: there are changes", &modified == 1, "")
let g:GrooVim_GrooVimBarMsgValue = ""
let g:GT_R = GrooVim_FileSettingsApply("a", "r", "u")
call GT_Ok("reading again is refused", g:GT_R == 0, "")
call GT_Ok("  and it says why", g:GrooVim_GrooVimBarMsgValue =~ "Save first",
  \ "   [" . g:GrooVim_GrooVimBarMsgValue . "]")
call GT_Ok("  and the change is still there", getline(1) ==# "mudei isto",
  \ "   [" . getline(1) . "]")

write
call GT_Ok("saved, and now reading again works",
  \ GrooVim_FileSettingsApply("u", "r", "u") == 1, "")
call GT_Ok("  and the file is the one it was", getline(1) ==# "mudei isto", "")

" ---- the answer to the encoding question is two letters, or the x that leaves
call GT_Ok("\"uc\" is utf-8 by converting", GrooVim_IsEncodingAnswer("uc") == 1, "")
call GT_Ok("\"br\" is utf-8 with BOM, by reading again", GrooVim_IsEncodingAnswer("br") == 1, "")
call GT_Ok("\"x\" on its own leaves", GrooVim_IsEncodingAnswer("x") == 1, "")
for s:no in ["u", "c", "uu", "cu", "zc", "ux", "uca", "", "UC"]
  call GT_Ok("  [" . s:no . "] is refused", GrooVim_IsEncodingAnswer(s:no) == 0, "")
endfor

" ---- and leaving really leaves, at either question
exec "edit! " . g:GT_FILE
%delete _
call setline(1, "intocado")
write
let g:GT_BEFORE = [&fileencoding, &bomb, &fileformat, &modified]

let g:GrooVim_GrooVimBarMsgValue = ""
call feedkeys("x\<CR>", "t")
call GrooVim_ConfigureFile()
call feedkeys("", "x")
call GT_Ok("x at the encoding: nothing changed",
  \ [&fileencoding, &bomb, &fileformat, &modified] ==# g:GT_BEFORE,
  \ "   [" . &fileencoding . " bomb=" . &bomb . " " . &fileformat . " modified=" . &modified . "]")
call GT_Ok("  and it says so", g:GrooVim_GrooVimBarMsgValue =~ "Nothing changed",
  \ "   [" . g:GrooVim_GrooVimBarMsgValue . "]")

let g:GrooVim_GrooVimBarMsgValue = ""
call feedkeys("bc\<CR>x\<CR>", "t")
call GrooVim_ConfigureFile()
call feedkeys("", "x")
call GT_Ok("x at the line ending: STILL nothing changed",
  \ [&fileencoding, &bomb, &fileformat, &modified] ==# g:GT_BEFORE,
  \ "   [" . &fileencoding . " bomb=" . &bomb . " " . &fileformat . " modified=" . &modified . "]" .
  \ "   (the encoding was answered and is not applied until both are in)")

" ---- and answering both does apply
call feedkeys("bc\<CR>w\<CR>", "t")
call GrooVim_ConfigureFile()
call feedkeys("", "x")
call GT_Ok("\"bc\" then \"w\": utf-8 with BOM and CRLF",
  \ &bomb == 1 && &fileformat ==# "dos",
  \ "   [" . &fileencoding . " bomb=" . &bomb . " " . &fileformat . "]")

" ---- and it no longer holds the screen waiting for Enter
call GT_Ok("the screen does not ask you to press Enter",
  \ GT_FunctionText("GrooVim_ConfigureFile") !~ "Press <Enter>", "")

" ---- and it lands on THIS tab and nowhere else
"
" The encoding, the BOM and what ends a line belong to the buffer, so a choice
" made on one document cannot reach another. Proved rather than assumed: every
" one of the three is a Vim option that also has a global value, and setting the
" global one is exactly the mistake that locked every buffer of the session when
" the help used ":set noma" instead of ":setlocal noma".
tabonly!
exec "edit! " . g:GT_OUT . "/tab_one.txt"
%delete _
call setline(1, "um")
write
exec "tabnew " . g:GT_OUT . "/tab_two.txt"
%delete _
call setline(1, "dois")
write
call GT_Ok("setup: two tabs, both utf-8 and unix",
  \ &fileencoding ==# "utf-8" && &bomb == 0 && &fileformat ==# "unix",
  \ "   (tab " . tabpagenr() . " of " . tabpagenr("$") . ")")

tabprevious
call GrooVim_FileSettingsApply("l", "c", "m")
call GT_Ok("tab 1 converted to utf-16 LE and CR",
  \ &fileencoding ==# "utf-16le" && &bomb == 1 && &fileformat ==# "mac",
  \ "   [" . &fileencoding . " bomb=" . &bomb . " " . &fileformat . "]")

tabnext
call GT_Ok("tab 2 was NOT touched",
  \ &fileencoding ==# "utf-8" && &bomb == 0 && &fileformat ==# "unix",
  \ "   [" . &fileencoding . " bomb=" . &bomb . " " . &fileformat . "]")
call GT_Ok("  and it was not marked as changed either", &modified == 0, "")

" A new tab after all that starts clean too: what was set is of the buffer, not
" a new default for everything that comes next.
tabnew
call GT_Ok("a tab opened afterwards starts clean",
  \ &bomb == 0 && &fileformat ==# "unix",
  \ "   [bomb=" . &bomb . " " . &fileformat . "]")
tabonly!

call delete(g:GT_OUT . "/tab_one.txt")
call delete(g:GT_OUT . "/tab_two.txt")
call delete(g:GT_FILE)
call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
