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

  " ---- F3 l takes the line away, and leaves the transfer area alone
  "
  " In a conventional editor, deleting a line does not cost you what you copied
  " ten minutes ago. Every delete of GrooVim goes to the "_" register for that.
  call GrooVim_ClipSet("do not touch me")
  call setline(1, ["um", "dois", "tres", "quatro"])
  call cursor(2, 1)
  call GT_Press("\<F3>l")
  call GT_Ok("F3 l takes the line away",
    \ getline(1, "$") ==# ["um", "tres", "quatro"], "   " . string(getline(1, "$")))
  call GT_Ok("  and what you had copied is still there",
    \ GrooVim_ClipGet() ==# "do not touch me", "   [" . GrooVim_ClipGet() . "]")

  call setline(1, ["um", "dois", "tres", "quatro"])
  call cursor(2, 1)
  call feedkeys("v", "x")
  call cursor(3, 2)
  call GT_Press("\<F3>l")
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
  call timer_start(400, {t -> feedkeys("\<C-u>" . g:GT_OTHER . "\<CR>", "t")})
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
  " ---- and it is ONE question, which names the folder you are in
  "
  " It used to ask for a PATH -- with "0" for the transfer area, "1" for none and
  " "2" for the folder of the file -- and then for a NAME: a menu to read through
  " before you can answer "notes.txt".
  call GT_Ok("where to save is one question, and a name is enough",
    \ GT_FunctionText("GrooVim_AskFileName") =~ "getcwd()" &&
    \ len(split(GT_FunctionText("GrooVim_AskFileName"), "GrooVim_Ask(")) == 2,
    \ "   (a path in front of the name puts it elsewhere)")
  call GT_Ok("  and the folder you are in is written into it",
    \ GT_FunctionText("GrooVim_AskFileName") =~ "GrooVim_PathShort(getcwd()",
    \ "   (so a bare name holds no mystery about where it goes)")
  call GT_Ok("  and the opening of F5->p asks that same question",
    \ GT_FunctionText("GrooVim_FileOpen") =~ "GrooVim_AskFileName" &&
    \ GT_FunctionText("GrooVim_AskFileWhere") =~ "GrooVim_AskFileName",
    \ "   (written once, so the two cannot drift apart)")
  call GT_Ok("  and a folder with no name in it is turned away",
    \ GT_FunctionText("GrooVim_AskFileWhere") =~ 'fnamemodify(l:answer, ":p")' &&
    \ GT_FunctionText("GrooVim_AskFileWhere") =~ "NAME is missing",
    \ "   (\":p\" ends a folder with a \"/\", which is how it is caught)")

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
  if !GT_Project()
    call GT_NotTheProject("the task list of the README")
  else
    call GT_Ok("  and the README says the same",
      \ empty(filter(readfile(fnamemodify($GROOVIM_TEST_VIMRC, ":h") . "/README.md"),
      \   'v:val =~ "^ \\* \\(ToDo\\|Bug\\|TODO\\):"')),
      \ "   (the two lists had drifted once, twenty nine entries against twenty one)")
  endif

  call delete(g:GT_FILE)
  call delete(g:GT_OTHER)

  " ---- saving a document that has no name yet asks where to put it
  "
  " It answered "E32: No file name" over an error of Vim, which is not an answer
  " to give anybody. What every editor does with a first save is ask, which is
  " what "save as" already did.
  call GT_Ok("the save asks when there is no name",
    \ GT_FunctionText("GrooVim_Save") =~ "GrooVim_SaveAs" &&
    \ GT_FunctionText("GrooVim_Save") =~ 'expand("%") ==# ""',
    \ "   (and writes the file, whole, when there is one)")
  call GT_Ok("  and it writes the file and not a selection",
    \ GT_FunctionText("GrooVim_Save") !~ "VisualWrite" &&
    \ GT_FunctionText("GrooVim_Save") =~ "write",
    \ "   (the branch for visual mode did the very same \"w\")")

  " ---- and CLOSING one asks about it, instead of the dialog of Vim
  "
  " ":confirm" asks "Save changes to "Untitled"? [Y]es, (N)o, (C)ancel" and its
  " Yes has nowhere to write: a nameless buffer has no file name, so Vim answers
  " "E32: No file name" and gives the close up. A question whose first answer
  " cannot be given is worse than no question.
  let g:GT_CLOSED = g:GT_OUT . "/fechado.txt"
  call delete(g:GT_CLOSED)
  tabnew
  call setline(1, ["nao salvei isto"])
  call timer_start(100, {t -> GrooVim_TabClose()})
  call timer_start(400, {t -> feedkeys("y\<CR>", "t")})
  call timer_start(700, {t -> feedkeys("\<C-u>" . g:GT_CLOSED . "\<CR>", "t")})
  call GT_When('tabpagenr("$") == 1', "GT_AfterCloseAsking")
endfunc

func! GT_AfterCloseAsking()
  call GT_Ok("closing a document never saved writes it where you say",
    \ filereadable(g:GT_CLOSED) && readfile(g:GT_CLOSED) ==# ["nao salvei isto"],
    \ "   " . string(filereadable(g:GT_CLOSED) ? readfile(g:GT_CLOSED) : []) .
    \ "   (the Yes of Vim had nowhere to write it)")
  call GT_Ok("  and the tab went",
    \ tabpagenr("$") == 1, "   (tabs " . tabpagenr("$") . ")")
  call delete(g:GT_CLOSED)

  call GT_Ok("and throwing it away is the other answer",
    \ GT_FunctionText("GrooVim_CloseSettle") =~ 'OptionsToPrompt(\["y", "n"\]' &&
    \ GT_FunctionText("GrooVim_CloseSettle") =~
    \   'setbufvar(a:buffer, "&modified", 0)',
    \ "   (which is what the (N)o of Vim did, and it worked)")
  call GT_Ok("  and a document that is NOT yours is never asked about",
    \ GT_FunctionText("GrooVim_CloseSettle") =~ '&buftype',
    \ "   (the occurrence list, the tree: they are accessories of a tab)")
  call GT_Ok("  and every way of closing asks first",
    \ GT_FunctionText("GrooVim_CloseAsking") =~ "CloseSettle" &&
    \ GT_FunctionText("GrooVim_TabClose") =~ "CloseSettle" &&
    \ GT_FunctionText("GrooVim_TabCloseSide") =~ "CloseSettle",
    \ "   (F5->q, F5->o, F5->w, F5->, and F5->.)")
  call GT_Ok("  without walking you through the tabs to do it",
    \ GT_FunctionText("GrooVim_CloseSettle") =~ "win_execute" &&
    \ GT_FunctionText("GrooVim_CloseSettle") =~ "win_findbuf",
    \ "   (it is written in its own window, wherever that window is)")

  " ---- and a document WITH a name is asked about the same way
  "
  " ":confirm" of Vim asks "Save changes to "/home/.../teste.txt"? [Y]es, (N)o,
  " (C)ancel" -- a line and a half of path, three answers written three
  " different ways, and none of them the way anything else here is asked.
  call writefile(["uma linha"], g:GT_CLOSED)
  exec "tabedit " . g:GT_CLOSED
  call setline(1, ["uma linha", "e outra"])
  call timer_start(100, {t -> GrooVim_TabClose()})
  call timer_start(400, {t -> feedkeys("y\<CR>", "t")})
  call GT_When('tabpagenr("$") == 1', "GT_AfterCloseNamed")
endfunc

func! GT_AfterCloseNamed()
  call GT_Ok("a document with a name is asked about the same way",
    \ readfile(g:GT_CLOSED) ==# ["uma linha", "e outra"],
    \ "   " . string(readfile(g:GT_CLOSED)) .
    \ "   (one question, one place, the same letters)")
  call GT_Ok("  and it is written where it already is",
    \ GT_FunctionText("GrooVim_CloseSettle") =~ 'l:write = "write"' &&
    \ GT_FunctionText("GrooVim_CloseSettle") =~ "saveas",
    \ "   (a document that was never saved is asked WHERE first)")
  call GT_Ok("  and it says WHICH file, the way the bar at the bottom does",
    \ GT_FunctionText("GrooVim_CloseSettle") =~ "GrooVim_PathShort" &&
    \ GT_FunctionText("GrooVim_CloseSettle") =~ "&columns",
    \ "   (the whole path, shortened to what is left of the line)")
  call GT_Ok("  and it is taken off the screen once answered",
    \ len(split(GT_FunctionText("GrooVim_CloseSettle"), "redraw!")) >= 3,
    \ "   (a tab closing draws the text again and leaves the command line be)")
  call GT_Ok("  and a document still open somewhere else is not asked about",
    \ GT_FunctionText("GrooVim_CloseSettle") =~ "win_id2tabwin" &&
    \ GT_FunctionText("GrooVim_CloseSettle") =~ "index(a:tabs",
    \ "   (nothing is being lost while a window of it is left standing)")
  call GT_Ok("  and leaving GrooVim asks about every tab",
    \ GT_FunctionText("GrooVim_CloseAsking") =~ '"qa"' &&
    \ GT_FunctionText("GrooVim_CloseAsking") =~ 'range(1, tabpagenr("\$"))',
    \ "   (F5->x, which takes them all with it)")
  call delete(g:GT_CLOSED)

  " ---- and a file that is already there is asked about before it is written over
  "
  " Vim refuses with "E13: File exists (add ! to override)", an error about a
  " flag of a command nobody typed, and the name you spent a minute choosing is
  " gone with it.
  let g:GT_THERE = g:GT_OUT . "/ja_existe.txt"
  call writefile(["ja estava aqui"], g:GT_THERE)
  tabnew
  call setline(1, ["algo novo"])
  call timer_start(100, {t -> GrooVim_SaveAs()})
  call timer_start(400, {t -> feedkeys("\<C-u>" . g:GT_THERE . "\<CR>", "t")})
  call timer_start(700, {t -> feedkeys("y\<CR>", "t")})
  call GT_When('expand("%:p") ==# g:GT_THERE', "GT_AfterReplace")
endfunc

func! GT_AfterReplace()
  call GT_Ok("a file already there is replaced when you say so",
    \ readfile(g:GT_THERE) ==# ["algo novo"],
    \ "   " . string(readfile(g:GT_THERE)) . "   (and not an E13 about a flag)")
  call GT_Ok("  and the question is asked where the name is asked",
    \ GT_FunctionText("GrooVim_AskFileWhere") =~ "filereadable(l:where)" &&
    \ GT_FunctionText("GrooVim_AskFileWhere") =~ "is already there. Replace it",
    \ "   (one question about one answer, in the place it was given)")
  call GT_Ok("  and a no asks for the name again, instead of walking out",
    \ GT_FunctionText("GrooVim_AskFileWhere") =~ 'l:replace !=# "y"',
    \ "   (you came here to save something, and it is not saved yet)")
  call GT_Ok("  and the default is the answer that destroys nothing",
    \ GT_FunctionText("GrooVim_AskFileWhere") =~
    \   'OptionsToPrompt(\["y", "n"\], "n"',
    \ "   (nothing is written over by an <Enter> you did not read)")
  call GT_Ok("  and whoever asked writes with the form that overrides",
    \ GT_FunctionText("GrooVim_SaveAs") =~ "saveas! " &&
    \ GT_FunctionText("GrooVim_SaveACopy") =~ 'exec "w! ' &&
    \ GT_FunctionText("GrooVim_CloseSettle") =~ "saveas! ",
    \ "   (which is what the question was asked for)")
  call delete(g:GT_THERE)

  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
