" Undo and redo, and selecting the whole buffer.
"
" Vim undoes with "u" and redoes with "Ctrl-r". GrooVim keeps the redo where Vim
" put it and moves the undo to "Ctrl-u", so the two sit next to each other and
" work the same in normal, insert and visual -- which they do not in bare Vim.
" "Ctrl-z" is deliberately dead: in a terminal it would suspend the editor.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

func! GT_Body()
  exec "edit " . g:GT_FIX . "/a.txt"
  " The cursor, placed on purpose: "A" appends to the line it is ON, and an
  " earlier case can leave it elsewhere through the session.
  call cursor(1, 1)
  let l:original = getline(1, "$")

  " ---- Ctrl-z does nothing, on purpose
  call GT_Ok("Ctrl-z is dead in normal", maparg("<C-z>", "n") ==# "<Nop>", "   [" . maparg("<C-z>", "n") . "]")
  call GT_Ok("Ctrl-z is dead in insert", maparg("<C-z>", "i") ==# "<Nop>", "")
  call GT_Ok("Ctrl-z is dead in visual", maparg("<C-z>", "v") ==# "<Nop>", "")
  call GT_Ok("nothing was mapped to Ctrl-y", maparg("<C-y>", "n") ==# "",
    \ "   (insert mode keeps the Ctrl-y of Vim: copy the character above)")

  " ---- normal mode
  call setline(1, "changed by hand")
  call GT_Ok("setup: the line changed", getline(1) ==# "changed by hand", "")
  call feedkeys("\<C-u>", "x")
  call GT_Ok("normal: Ctrl-u undid it", getline(1, "$") ==# l:original, "   [" . getline(1) . "]")
  call feedkeys("\<C-r>", "x")
  call GT_Ok("normal: Ctrl-r brought it back", getline(1) ==# "changed by hand", "   [" . getline(1) . "]")
  call feedkeys("\<C-u>", "x")

  " ---- insert mode, where bare Vim does something else entirely
  "
  " The Ctrl-u of Vim in insert mode wipes what you typed on the line, and its
  " Ctrl-r asks for a register. Both are remapped here.
  call GT_Ok("insert: Ctrl-u is remapped", maparg("<C-u>", "i") =~ "GrooVim_InsertUndo",
    \ "   [" . maparg("<C-u>", "i") . "]   (bare Vim would wipe the line)")
  call GT_Ok("insert: Ctrl-r is remapped", maparg("<C-r>", "i") =~ "GrooVim_InsertRedo",
    \ "   (bare Vim would ask for a register)")
  call cursor(1, 1)
  call feedkeys("A EXTRA\<Esc>", "x")
  call GT_Ok("setup: typed at the end", getline(1) =~ "EXTRA$", "   [" . getline(1) . "]")
  call feedkeys("i\<C-u>\<Esc>", "x")
  call GT_Ok("insert: Ctrl-u undid the typing", getline(1, "$") ==# l:original, "   [" . getline(1) . "]")
  call feedkeys("i\<C-r>\<Esc>", "x")
  call GT_Ok("insert: Ctrl-r brought it back", getline(1) =~ "EXTRA$", "   [" . getline(1) . "]")
  call feedkeys("i\<C-u>\<Esc>", "x")

  " ---- visual mode
  call GT_Ok("visual: Ctrl-u is remapped", maparg("<C-u>", "v") =~ "GrooVim_VisualUndo",
    \ "   (bare Vim would scroll half a page)")
  call GT_Ok("visual: Ctrl-r is remapped", maparg("<C-r>", "v") =~ "GrooVim_VisualRedo", "")
  call setline(2, "changed again")
  call feedkeys("v\<C-u>\<Esc>", "x")
  call GT_Ok("visual: Ctrl-u undid it", getline(1, "$") ==# l:original, "   [" . getline(2) . "]")

  " ---- the undo survives closing the file, because it is written to disk
  call GT_Ok("undofile is on", &undofile == 1, "")
  call GT_Ok("and it lives with GrooVim", &undodir =~ g:GrooVim_Home,
    \ "   [" . &undodir . "]")

  " ---- selecting the whole buffer: it moved from F2 to F3
  "
  " The "'<" and "'>" marks are only written when you LEAVE visual mode, so the
  " "<Esc>" is part of the measurement, not tidying up.
  exec "edit " . g:GT_FIX . "/b.txt"
  call cursor(2, 3)
  call feedkeys("\<F3>a\<Esc>", "x")
  call GT_Ok("F3 and then a selected the whole buffer",
    \ line("'<") == 1 && line("'>") == line("$"),
    \ "   (from line " . line("'<") . " to " . line("'>") . " of " . line("$") . ")")
  call GT_Ok("  and it is a LINE selection", visualmode() ==# "V", "   [" . visualmode() . "]")

  " A small selection of its own, so what comes next cannot pass by accident.
  call feedkeys("2GVj\<Esc>", "x")
  call GT_Ok("setup: lines 2 to 3 selected", line("'<") == 2 && line("'>") == 3,
    \ "   (from " . line("'<") . " to " . line("'>") . ")")
  call feedkeys("\<F2>a\<Esc>", "x")
  call GT_Ok("F2 and then a selects nothing any more",
    \ line("'<") == 2 && line("'>") == 3,
    \ "   (from " . line("'<") . " to " . line("'>") . ")   (it used to be the F2 key)")
  call GT_Ok("  and it did not type an \"a\" into the file either",
    \ getline(2) ==# "third occurrence of TARGET here", "   [" . getline(2) . "]")

  " ---- Ctrl-C copies and leaves the cursor WHERE IT WAS
"
" A plain "y" in visual mode drops the cursor at the start of what was selected,
" which is of Vim and of nothing else: in a conventional editor you copy and go
" on from where you are.
"
" The mode afterwards is NOT asked about: "feedkeys(..., "x")" ends insert mode
" when the keys run out, so it answers "n" here whatever the mapping does -- and
" it answered "n" for the "yi" that was here before this changed.
%delete _
call setline(1, ["uma linha de teste", "outra linha"])
call cursor(1, 5)
call feedkeys("vlll", "x")
let g:GT_AT = getcurpos()[1:2]
call GT_Ok("setup: selecting, the cursor is at the far end", g:GT_AT ==# [1, 8],
  \ "   " . string(g:GT_AT))
call feedkeys("\<C-c>", "x")
call GT_Ok("Ctrl-C leaves the cursor where it was", getcurpos()[1:2] ==# g:GT_AT,
  \ "   " . string(getcurpos()[1:2]) . "   (a plain \"y\" would drop it at column 5)")
call GT_Ok("  and it copied what was selected", GrooVim_ClipGet() ==# "linh",
  \ "   [" . GrooVim_ClipGet() . "]")

" ---- and the WINDOW does not jump either
"
" A yank over a selection that runs off the screen scrolls the window to its
" start, and putting the cursor back does not bring the window with it: the text
" jumped under the cursor. "winsaveview" holds both.
"
" The selection is built so that the cursor is on the screen and the OTHER end of
" it is far above: that is the shape that moved the window, because the ":" of
" the mapping takes the cursor to the start of the range -- far off the screen --
" and the "gv" that brings it back lands more than a screen away, which is when
" Vim CENTRES what it lands on. Taking the window after the "gv", as this used to,
" held a place the user had never been looking at.
let g:GT_KEPT_LINES = &lines
set lines=43
%delete _
call setline(1, map(range(1, 300), '"linha " . v:val'))
call cursor(40, 1)
call feedkeys("v", "x")
call cursor(115, 1)
call winrestview({"topline": 80})
let g:GT_VIEW = [line("."), col("."), line("w0")]
call GT_Ok("setup: the cursor is on the screen, the other end is not",
  \ g:GT_VIEW[2] == 80 && line(".") == 115 && line(".") <= line("w$"),
  \ "   (window " . line("w0") . ".." . line("w$") . ", cursor " . line(".") .
  \ ", the selection starts on 40)")
call feedkeys("\<C-c>", "x")
call GT_Ok("Ctrl-C leaves the window where it was", line("w0") == g:GT_VIEW[2],
  \ "   (top line " . line("w0") . ", and it was " . g:GT_VIEW[2] . ")")
call GT_Ok("  with the cursor still on it",
  \ [line("."), col(".")] ==# g:GT_VIEW[0:1],
  \ "   (line " . line(".") . ", and it was " . g:GT_VIEW[0] . ")")
call GT_Ok("  because the key never opens a command line",
  \ maparg("<C-c>", "v") =~ "<Cmd>" && GT_FunctionText("GrooVim_CopyHere") !~ "normal! gv",
  \ "   (a \":\" in visual mode moves the cursor to the first line of the range)")
let &lines = g:GT_KEPT_LINES

call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
