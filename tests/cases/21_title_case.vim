" Title Case, and a copy that does not demand a writable buffer.
"
" The copy was the symptom; the cause was somewhere else. The help and the
" occurrence list locked themselves with ":set noma", and ":set" on an option
" that belongs to a buffer writes the GLOBAL default too -- so from the first F9
" of the session every new buffer was locked, and "Ctrl-C" (which ends in insert
" mode, the way a conventional editor leaves you able to type) answered "E21".
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

func! GT_Body()
  exec "enew"

  " ---- the word under the cursor, in normal mode
  call setline(1, "hello WORLD of vim")
  call cursor(1, 1)
  call feedkeys("\<F2>t", "x")
  call GT_Ok("normal: the word under the cursor", getline(1) ==# "Hello WORLD of vim",
    \ "   [" . getline(1) . "]")

  call cursor(1, 7)
  call feedkeys("\<F2>t", "x")
  call GT_Ok("normal: an all-caps word comes down too", getline(1) ==# "Hello World of vim",
    \ "   [" . getline(1) . "]")

  " ---- a selection, and ONLY the selection
  "
  " The selection is built with real motions inside ONE feedkeys. Entering visual
  " and then moving with cursor() from the script leaves the area in a state the
  " keys never produce, and the case measured something else entirely.
  call setline(1, "keep this and TITLE these WORDS and keep this too")
  call cursor(1, 15)
  call feedkeys("v15l\<F2>t", "x")
  call GT_Ok("visual: every word of the selection changed",
    \ getline(1) ==# "keep this and Title These Words and keep this too",
    \ "   [" . getline(1) . "]   (only the first one, with gdefault inverting the /g)")
  call GT_Ok("  and gdefault was put back", &gdefault == 1, "   (" . &gdefault . ")")
  call GT_Ok("  and NOTHING outside it did", getline(1) =~# "^keep this and " &&
    \ getline(1) =~# " and keep this too$",
    \ "   (a plain :s would have taken the whole line)")

  " ---- a selection inside one word
  call setline(1, "abc")
  call cursor(1, 1)
  call feedkeys("v2l\<F2>t", "x")
  call GT_Ok("visual: a whole short word", getline(1) ==# "Abc", "   [" . getline(1) . "]")

  " ---- where the word boundaries fall
  "
  " "==#" and not "=~": with "ignorecase" on, a match would pass over the very
  " text it was meant to reject.
  call setline(1, "o'brien don't x2 a_b end")
  call cursor(1, 1)
  call feedkeys("v$\<F2>t", "x")
  call GT_Ok("every word of the line starts with a capital",
    \ getline(1) ==# "O'Brien Don'T X2 A_b End",
    \ "   [" . getline(1) . "]   (an apostrophe ENDS a word, so \"don't\" is \"Don'T\")")

  " ---- the search register is given back
  let @/ = "something"
  call setline(1, "one two")
  call cursor(1, 1)
  call feedkeys("\<F2>t", "x")
  call GT_Ok("the search register was not stolen", @/ ==# "something", "   [" . @/ . "]")

  " ---- insert mode
  call setline(1, "typing here")
  call cursor(1, 1)
  call feedkeys("i\<F2>t\<Esc>", "x")
  call GT_Ok("insert: the word under the cursor", getline(1) ==# "Typing here",
    \ "   [" . getline(1) . "]")

  " ---- the cursor stays where it was
  "
  " Changing the case of a word is not a movement. Upper and lower ended with an
  " "e", which walks to the last letter; Title Case went through ":s", which
  " leaves the cursor on the first column of the line.
  call setline(1, "keep this middle word here")
  for l:pair in [["\<F2>\<Up>", "upper"], ["\<F2>\<Down>", "lower"], ["\<F2>t", "title"]]
    call setline(1, "keep this middle word here")
    call cursor(1, 13)
    call feedkeys(l:pair[0], "x")
    call GT_Ok(l:pair[1] . ": the cursor did not move",
      \ line(".") == 1 && col(".") == 13,
      \ "   (line " . line(".") . " col " . col(".") . ", it was 1/13)   [" . getline(1) . "]")
  endfor

  " ---- the cursor sitting PAST the end of the line
  "
  " GrooVim runs with "virtualedit=onemore", so the cursor can be one column
  " beyond the last character -- which is where you are after typing to the end
  " of a line. There is no word there, and "iw" took only the last letter:
  " "total" came back as "totaL".
  "
  " GT_Press and not feedkeys: pressing the same F key twice in a row this fast
  " means "do that again" to GrooVim, and the second shortcut would repeat the
  " first instead of running.
  let l:line = "    return total"
  for l:case in [["\<F2>\<Up>", "upper", "    return TOTAL"],
    \ ["\<F2>\<Down>", "lower", "    return total"],
    \ ["\<F2>t", "title", "    return Total"]]
    for l:col in [13, 16, 17]
      call setline(1, l:case[1] ==# "lower" ? "    return TOTAL" : l:line)
      call cursor(1, l:col)
      call GT_Press(l:case[0])
      call GT_Ok(l:case[1] . ": from column " . l:col . " of a 16 column line",
        \ getline(1) ==# l:case[2] && col(".") == l:col,
        \ "   [" . getline(1) . "] cursor " . col(".") .
        \ (l:col > 16 ? "   (past the end of the line)" : ""))
    endfor
  endfor

  " ---- and an empty line is not an error
  call setline(1, "")
  call cursor(1, 1)
  let v:errmsg = ""
  call GT_Press("\<F2>\<Up>")
  call GT_Ok("an empty line: nothing happens and nothing breaks",
    \ getline(1) ==# "" && v:errmsg ==# "", "   [" . v:errmsg . "]")

  " ---- nothing locks the buffers that come after it
  "
  " Measured: one ":set noma" and every buffer opened afterwards is locked.
  call GT_Ok("the global \"modifiable\" is on", &g:modifiable == 1, "")
  call GT_Ok("the help locks itself with setlocal",
    \ execute("function GrooVim_ToogleGrooVimHelp") =~ "setlocal noma" &&
    \ execute("function GrooVim_ToogleGrooVimHelp") !~ '\\s\\zsset noma',
    \ "   (\":set noma\" would lock every buffer of the session)")
  call GT_Ok("and so does the occurrence list",
    \ execute("function GrooVim_SearchGuySync") =~ "setlocal noma" &&
    \ execute("function GrooVim_SearchGuySync") !~ '\\s\\zsset noma', "")

  " ---- and the copy that used to demand a writable buffer
  call GT_Ok("Ctrl-C asks whether the buffer can be changed",
    \ maparg("<C-c>", "v") =~ "modifiable",
    \ "   [" . maparg("<C-c>", "v") . "]")

  call setline(1, "alpha beta gamma")
  call cursor(1, 7)
  setlocal nomodifiable
  let v:errmsg = ""
  call feedkeys("viw\<C-c>\<Esc>", "x")
  call GT_Ok("Ctrl-C on a locked buffer: no E21", v:errmsg !~ "E21", "   [" . v:errmsg . "]")
  call GT_Ok("  and it still copied", getreg('"') ==# "beta", "   [" . getreg('"') . "]")
  setlocal modifiable

  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
