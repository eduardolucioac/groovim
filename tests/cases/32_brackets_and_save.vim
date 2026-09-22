" The keys that arrived the day the list of pending things emptied.
"
" Walking from one bracket to the one that closes it, saving under another name,
" and taking a line away. Three of the four are what was left of that list; the
" fourth, the line, was asked for on the same day.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

let g:GT_FILE = "/tmp/GrooVim_brackets_case.txt"
let g:GT_OTHER = "/tmp/GrooVim_brackets_case_other.txt"

func! GT_Body()

  " ---- Ctrl-b walks the brackets
  "
  " It is the "%" of Vim, which needs no help from anybody, given a key a
  " conventional editor would look for. The key used to be the visual block,
  " which is on F2->b now.
  enew!
  call setline(1, ["if (algo) {", "  x = 1;", "}", "fim"])
  call cursor(1, 11)
  call GT_Press("\<C-b>")
  call GT_Ok("Ctrl-b goes from the { to the } that closes it",
    \ line(".") == 3 && col(".") == 1, "   (line " . line(".") . " column " . col(".") . ")")
  call GT_Press("\<C-b>")
  call GT_Ok("  and back from the } to the {",
    \ line(".") == 1 && col(".") == 11, "   (line " . line(".") . " column " . col(".") . ")")
  call cursor(1, 4)
  call GT_Press("\<C-b>")
  call GT_Ok("  and it is brackets of every kind, not braces alone", col(".") == 9,
    \ "   (column " . col(".") . ", where the \")\" is)")
  call GT_Ok("  in insert mode too", maparg("<C-b>", "i") =~ "%",
    \ "   [" . maparg("<C-b>", "i") . "]")
  call GT_Ok("  and in visual, taking the selection with it",
    \ maparg("<C-b>", "v") =~ "%", "   [" . maparg("<C-b>", "v") . "]")

  " ---- and the block it used to be is on F2->b
  exec "normal! \<Esc>"
  call cursor(1, 1)
  call GT_Press("\<F2>b")
  call GT_Ok("F2 b enters the visual block", mode() ==# "\<C-v>",
    \ "   (mode [" . strtrans(mode()) . "])")
  exec "normal! \<Esc>"

  " ---- F2 l takes the line away, and leaves the transfer area alone
  "
  " In a conventional editor, deleting a line does not cost you what you copied
  " ten minutes ago. Every delete of GrooVim goes to the "_" register for that.
  call GrooVim_ClipSet("do not touch me")
  call setline(1, ["um", "dois", "tres", "quatro"])
  call cursor(2, 1)
  call GT_Press("\<F2>l")
  call GT_Ok("F2 l takes the line away",
    \ getline(1, "$") ==# ["um", "tres", "quatro"], "   " . string(getline(1, "$")))
  call GT_Ok("  and what you had copied is still there",
    \ GrooVim_ClipGet() ==# "do not touch me", "   [" . GrooVim_ClipGet() . "]")

  call setline(1, ["um", "dois", "tres", "quatro"])
  call cursor(2, 1)
  call feedkeys("v", "x")
  call cursor(3, 2)
  call GT_Press("\<F2>l")
  call GT_Ok("  and over a selection it takes every line it touches, whole",
    \ getline(1, "$") ==# ["um", "quatro"], "   " . string(getline(1, "$")) .
    \ "   (three characters were selected, not two lines)")

  " ---- and "save as", which goes on editing the new one
  call delete(g:GT_FILE)
  call delete(g:GT_OTHER)
  call writefile(["uma linha"], g:GT_FILE)
  exec "edit! " . g:GT_FILE
  call setline(1, ["uma linha", "e outra"])
  call timer_start(100, {t -> GrooVim_SaveAs()})
  call timer_start(400, {t -> feedkeys("2\<CR>", "t")})
  call timer_start(700, {t -> feedkeys("\<C-u>" . fnamemodify(g:GT_OTHER, ":t") . "\<CR>", "t")})
  call GT_When('expand("%:p") ==# g:GT_OTHER', "GT_AfterSaveAs")
endfunc

func! GT_AfterSaveAs()
  call GT_Ok("save as leaves you editing the NEW file",
    \ expand("%:p") ==# g:GT_OTHER, "   [" . expand("%:t") . "]")
  call GT_Ok("  which is on disk, with what you had",
    \ filereadable(g:GT_OTHER) && readfile(g:GT_OTHER) ==# ["uma linha", "e outra"],
    \ "   " . string(filereadable(g:GT_OTHER) ? readfile(g:GT_OTHER) : []))
  call GT_Ok("  and the one you came from is as it was",
    \ readfile(g:GT_FILE) ==# ["uma linha"], "   " . string(readfile(g:GT_FILE)) .
    \ "   (a copy is the other key, F2->y: that one leaves you where you were)")
  call GT_Ok("and it sits with the other two that save",
    \ !empty(filter(copy(g:GrooVim_Shortcuts),
    \   'get(v:val, "group", "") ==# "F5" && v:val.key ==# "a" && v:val.what =~ "another name"')),
    \ "   (F5->s saves, F5->e saves every changed file, F5->a saves as)")
  call GT_Ok("and the two ask the SAME question, in one place",
    \ GT_FunctionText("GrooVim_SaveAs") =~ "GrooVim_AskFileWhere" &&
    \ GT_FunctionText("GrooVim_SaveACopy") =~ "GrooVim_AskFileWhere",
    \ "   (forty lines twice would drift the day one of them was touched)")

  " ---- and the list of pending things is empty
  "
  " The LIST, which is the section of the .vimrc. A "ToDo" written beside the
  " code it is about is another thing and lives where it is.
  call GT_Ok("nothing is left on the task list",
    \ empty(filter(readfile($GROOVIM_TEST_VIMRC), 'v:val =~ "^\" \\(ToDo\\|Bug\\|TODO\\):"')),
    \ "   (every entry was read against the code and answered)")
  call GT_Ok("  and the README says the same",
    \ empty(filter(readfile(fnamemodify($GROOVIM_TEST_VIMRC, ":h") . "/README.md"),
    \   'v:val =~ "^ \\* \\(ToDo\\|Bug\\|TODO\\):"')),
    \ "   (the two lists had drifted once, twenty nine entries against twenty one)")

  call delete(g:GT_FILE)
  call delete(g:GT_OTHER)
  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
