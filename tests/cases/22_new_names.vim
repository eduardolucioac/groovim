" A document you have not saved yet is called "new 1", the way Notepad++ names
" them, and not "[No Name]".
"
" It is a name ON SCREEN only: the buffer stays nameless, so ":w" goes on asking
" where to save instead of writing a file called "new 1" into whatever directory
" you happen to be in.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

func! GT_Body()
  tabonly! | enew!

  call GT_Ok("setup: one tab, nothing open", tabpagenr("$") == 1 && bufname("%") ==# "", "")
  call GT_Ok("the first one is \"new 1\"", GrooVim_TabLabel(1) ==# "new 1",
    \ "   [" . GrooVim_TabLabel(1) . "]")
  call GT_Ok("and the bar says the same", GrooVim_FileLabel() ==# "new 1",
    \ "   [" . GrooVim_FileLabel() . "]")

  " ---- the number sticks to the buffer
  call GT_Ok("drawing it again does not renumber it", GrooVim_TabLabel(1) ==# "new 1" &&
    \ GrooVim_TabLabel(1) ==# "new 1", "   [" . GrooVim_TabLabel(1) . "]")

  " ---- and the next ones count up
  call GT_Press("\<F5>n")
  call GT_Ok("F5 n opened a second tab", tabpagenr("$") == 2, "   (tabs " . tabpagenr("$") . ")")
  call GT_Ok("  and it is \"new 2\"", GrooVim_TabLabel(2) ==# "new 2",
    \ "   [" . GrooVim_TabLabel(2) . "]")
  call GT_Press("\<F5>n")
  call GT_Ok("and the third is \"new 3\"", GrooVim_TabLabel(3) ==# "new 3",
    \ "   [" . GrooVim_TabLabel(3) . "]")
  call GT_Ok("the first one did not change", GrooVim_TabLabel(1) ==# "new 1",
    \ "   [" . GrooVim_TabLabel(1) . "]")

  " ---- the new tab lands at the END of the line, not beside the one you are on
  tabnext 1
  call GT_Press("\<F5>n")
  call GT_Ok("from tab 1, the new one went to the end",
    \ tabpagenr() == 4 && tabpagenr("$") == 4,
    \ "   (tab " . tabpagenr() . " of " . tabpagenr("$") . ")")
  call GT_Ok("  and it is \"new 4\"", GrooVim_TabLabel(4) ==# "new 4",
    \ "   [" . GrooVim_TabLabel(4) . "]")
  call GT_Ok("  and the ones before it did not move",
    \ GrooVim_TabLabel(1) ==# "new 1" && GrooVim_TabLabel(2) ==# "new 2" &&
    \ GrooVim_TabLabel(3) ==# "new 3",
    \ "   [" . GrooVim_TabLabel(1) . " " . GrooVim_TabLabel(2) . " " . GrooVim_TabLabel(3) . "]")

  " ---- a number that was freed comes back
  "
  " A counter that only grows would have you at "new 47" on a morning when three
  " documents were ever open at once.
  tabnext 2
  call GT_Press("\<F5>w")
  call GT_Ok("closed the middle one",
    \ tabpagenr("$") == 3 && GrooVim_TabLabel(1) ==# "new 1" &&
    \ GrooVim_TabLabel(2) ==# "new 3" && GrooVim_TabLabel(3) ==# "new 4",
    \ "   [" . GrooVim_TabLabel(1) . " " . GrooVim_TabLabel(2) . " " . GrooVim_TabLabel(3) . "]")
  call GT_Press("\<F5>n")
  call GT_Ok("the next one takes the free slot, not the next number",
    \ GrooVim_TabLabel(4) ==# "new 2",
    \ "   [" . GrooVim_TabLabel(4) . "]   (a counter would have said \"new 5\")")
  call GT_Ok("  and it is still at the end", tabpagenr() == 4 && tabpagenr("$") == 4,
    \ "   (tab " . tabpagenr() . " of " . tabpagenr("$") . ")")

  " ---- and the next one after that goes on from the top again
  call GT_Press("\<F5>n")
  call GT_Ok("with 1, 2, 3 and 4 taken, the next is \"new 5\"",
    \ GrooVim_TabLabel(5) ==# "new 5", "   [" . GrooVim_TabLabel(5) . "]")

  " ---- a file keeps its own name
  exec "tabnew " . g:GT_FIX . "/a.txt"
  call GT_Ok("a file is called by its name",
    \ GrooVim_TabLabel(tabpagenr()) ==# "a.txt",
    \ "   [" . GrooVim_TabLabel(tabpagenr()) . "]")
  call GT_Ok("  and so says the bar", GrooVim_FileLabel() =~ "a.txt",
    \ "   [" . GrooVim_FileLabel() . "]")

  " ---- the buffer is still nameless, which is the whole point
  tabonly! | enew!
  call setline(1, "typed and not saved")
  call GT_Ok("setup: an unsaved document called \"new 1\"",
    \ GrooVim_TabLabel(1) ==# "new 1", "   [" . GrooVim_TabLabel(1) . "]")
  call GT_Ok("  but Vim still has no name for it", bufname("%") ==# "" && expand("%") ==# "", "")
  let v:errmsg = ""
  silent! write
  call GT_Ok("writing it asks for a name instead of making a file",
    \ v:errmsg =~ "E32", "   [" . v:errmsg . "]")
  call GT_Ok("  and no file called \"new 1\" was created", !filereadable("new 1"), "")

  " ---- the accessories of a tab are not documents
  "
  " "enew!" first: the buffer above is unsaved, and opening a file over it answers
  " E37 -- which inside a timer opens a "Press ENTER" and hangs the case until the
  " runner kills it.
  enew!
  exec "edit " . g:GT_FIX . "/a.txt"
  call GT_BuildSearch("TARGET", 1, ["0", "0", "0", "1," . g:GT_FIX . "/a.txt,2,21"])
  call GrooVim_SearchGuySync()
  call GT_Ok("setup: the occurrence list is open", GT_GoToList(), "   " . GT_Layout())
  call GT_Ok("the list gets no \"new N\" of its own",
    \ GrooVim_NewNameOf(bufnr("%")) ==# "",
    \ "   [" . GrooVim_NewNameOf(bufnr("%")) . "]   (it is not a document of yours)")
  call GT_Ok("  and the tab is still named after the file",
    \ GrooVim_TabLabel(tabpagenr()) ==# "a.txt", "   [" . GrooVim_TabLabel(tabpagenr()) . "]")

  " ---- and F5->p opens a file BY NAME, in a tab of its own
  "
  " The one way into a tab that was missing: F5->n opens an empty one, the tree
  " opens what you can see from where you are, and a path you have in your hand
  " -- out of a message, a terminal, a build that failed -- had to go through
  " the ":e" of Vim.
  tabonly! | enew!
  let g:GT_OPEN = g:GT_OUT . "/abrir.txt"
  call writefile(["uma linha de um arquivo que existe"], g:GT_OPEN)
  call timer_start(100, {t -> GrooVim_FileOpen()})
  call timer_start(400, {t -> feedkeys(g:GT_OPEN . "\<CR>", "t")})
  call GT_When('expand("%:p") ==# g:GT_OPEN', "GT_AfterOpen")
endfunc

func! GT_AfterOpen()
  call GT_Ok("F5->p opens the file you name",
    \ expand("%:p") ==# g:GT_OPEN &&
    \ getline(1) ==# "uma linha de um arquivo que existe",
    \ "   [" . expand("%:t") . "]")
  call GT_Ok("  in a tab of its own, at the END of the line",
    \ tabpagenr() == tabpagenr("$") && tabpagenr("$") > 1,
    \ "   (tab " . tabpagenr() . " of " . tabpagenr("$") . ")")
  call GT_Ok("  and it asks the same question the saving asks",
    \ GT_FunctionText("GrooVim_FileOpen") =~ "GrooVim_AskFileName" &&
    \ GT_FunctionText("GrooVim_AskFileWhere") =~ "GrooVim_AskFileName",
    \ "   (so the two read alike, and <Tab> completes in both)")
  call GT_Ok("  and a folder is turned away, like a name that is missing",
    \ GT_FunctionText("GrooVim_FileOpen") =~ "isdirectory" &&
    \ GT_FunctionText("GrooVim_FileOpen") =~ "NAME is missing",
    \ "   (a folder is not a document)")

  " ---- and a file that is NOT there is asked about
  "
  " Vim opens a document under any name you type and says nothing, so a path
  " with one letter wrong came up as an empty tab wearing the name of the file
  " you meant -- and the file you meant was one letter away, still closed.
  tabonly! | enew!
  let g:GT_NOT_THERE = g:GT_OUT . "/nao_existe.txt"
  call delete(g:GT_NOT_THERE)
  call timer_start(100, {t -> GrooVim_FileOpen()})
  call timer_start(400, {t -> feedkeys(g:GT_NOT_THERE . "\<CR>", "t")})
  call timer_start(800, {t -> feedkeys("n\<CR>", "t")})
  call GT_When('g:GrooVim_GrooVimBarMsgValue =~ "Nothing opened"', "GT_AfterNotThere")
endfunc

func! GT_AfterNotThere()
  call GT_Ok("a file that is not there is asked about",
    \ g:GrooVim_GrooVimBarMsgValue =~ "Nothing opened" &&
    \ expand("%:p") !=# g:GT_NOT_THERE,
    \ "   [" . g:GrooVim_GrooVimBarMsgValue . "]   (and a no opens nothing)")
  call GT_Ok("  and the question offers to START it",
    \ GT_FunctionText("GrooVim_FileOpen") =~ "is not there. Start it" &&
    \ GT_FunctionText("GrooVim_FileOpen") =~
    \   'OptionsToPrompt(\["y", "n"\], "n"',
    \ "   (the default is the answer that opens nothing)")

  call delete(g:GT_OPEN)
  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
