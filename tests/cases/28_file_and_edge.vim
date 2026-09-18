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
call GT_Ok("an empty answer changes nothing", GrooVim_IsEncodingAnswer("") == 1,
  \ "   (it is the default: <Enter> through the screen leaves it as it was)")
for s:no in ["u", "c", "uu", "cu", "zc", "ux", "uca", "UC", "x"]
  call GT_Ok("  [" . s:no . "] is refused", GrooVim_IsEncodingAnswer(s:no) == 0, "")
endfor

" ---- the language, which is the Language menu of Notepad++
"
" GrooVim keeps no list of its own: <Tab> completes among the file types this Vim
" ships, and an answer is valid when Vim knows it. That is the only list that can
" ever be right.
call GT_Ok("Vim knows a few hundred of them",
  \ len(getcompletion("", "filetype")) > 500,
  \ "   (" . len(getcompletion("", "filetype")) . ")")
call GT_Ok("a name it knows is an answer", GrooVim_IsLanguageAnswer("python") == 1, "")
call GT_Ok("  and so is \"none\"", GrooVim_IsLanguageAnswer("none") == 1,
  \ "   (the \"None (Normal Text)\" of that menu)")
call GT_Ok("  and empty, which leaves it alone", GrooVim_IsLanguageAnswer("") == 1, "")
call GT_Ok("a name it does not know is refused",
  \ GrooVim_IsLanguageAnswer("linguagem-que-nao-existe") == 0, "")

" It is asked on the VIEW screen and not on the file one: nothing about a
" language is ever written to the disk. The encoding and the line ending change
" the bytes in the file; a language changes how the same bytes are READ.
exec "edit! " . g:GT_FILE
%delete _
call setline(1, "x = 1")
write
call GT_Ok("the file screen does not ask about the language",
  \ GT_FunctionText("GrooVim_ConfigureFile") !~ "IsLanguageAnswer", "")
call GT_Ok("  and the view screen does",
  \ GT_FunctionText("GrooVim_ConfigureView") =~ "IsLanguageAnswer", "")

call feedkeys("\<CR>\<CR>python\<CR>a\<CR>", "t")
call GrooVim_ConfigureView()
call feedkeys("", "x")
call GT_Ok("choosing it changes the file type", &filetype ==# "python",
  \ "   [" . &filetype . "]")
call GT_Ok("  and does NOT mark the buffer as changed", &modified == 0,
  \ "   (a language is not written into the file; it is how Vim reads it)")

call feedkeys("\<CR>\<CR>none\<CR>a\<CR>", "t")
call GrooVim_ConfigureView()
call feedkeys("", "x")
call GT_Ok("\"none\" takes it off", &filetype ==# "",
  \ "   [" . &filetype . "]")

call feedkeys("\<CR>\<CR>\<CR>a\<CR>", "t")
let g:GT_WAS = &filetype
call GrooVim_ConfigureView()
call feedkeys("", "x")
call GT_Ok("and empty leaves it where it was", &filetype ==# g:GT_WAS, "")

" ---- an empty answer means "leave THIS alone", not "leave the screen"
exec "edit! " . g:GT_FILE
%delete _
call setline(1, "intocado")
write
let g:GT_BEFORE = [&fileencoding, &bomb, &fileformat, &modified]

" x on the encoding: the line ending is STILL asked, and answering it works.
let g:GrooVim_GrooVimBarMsgValue = ""
call feedkeys("\<CR>w\<CR>", "t")
call GrooVim_ConfigureFile()
call feedkeys("", "x")
call GT_Ok("empty on the encoding: the encoding is untouched",
  \ &fileencoding ==# g:GT_BEFORE[0] && &bomb == g:GT_BEFORE[1],
  \ "   [" . &fileencoding . " bomb=" . &bomb . "]")
call GT_Ok("  but the line ending was still ASKED and applied",
  \ &fileformat ==# "dos",
  \ "   [" . &fileformat . "]   (empty leaves one question alone, not the screen)")
call GT_Ok("  and it says what it did and what it did not",
  \ g:GrooVim_GrooVimBarMsgValue =~ "the encoding it had",
  \ "   [" . g:GrooVim_GrooVimBarMsgValue . "]")

" x on the line ending: the encoding is applied all the same.
exec "edit! " . g:GT_FILE
call feedkeys("bc\<CR>\<CR>", "t")
call GrooVim_ConfigureFile()
call feedkeys("", "x")
call GT_Ok("empty on the line ending: the encoding WAS applied", &bomb == 1, "")
call GT_Ok("  and the line ending was left where it was",
  \ &fileformat ==# g:GT_BEFORE[2],
  \ "   [" . &fileformat . "]")

" x on both: a screen you walked out of.
exec "edit! " . g:GT_FILE
let g:GT_AGAIN = [&fileencoding, &bomb, &fileformat]
let g:GrooVim_GrooVimBarMsgValue = ""
call feedkeys("\<CR>\<CR>", "t")
call GrooVim_ConfigureFile()
call feedkeys("", "x")
call GT_Ok("empty on both: nothing at all",
  \ [&fileencoding, &bomb, &fileformat] ==# g:GT_AGAIN,
  \ "   [" . &fileencoding . " bomb=" . &bomb . " " . &fileformat . "]")
call GT_Ok("  and it says so", g:GrooVim_GrooVimBarMsgValue =~ "Nothing changed",
  \ "   [" . g:GrooVim_GrooVimBarMsgValue . "]")

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
