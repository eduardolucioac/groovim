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
  let g:GrooVim_NewNameCount = 0

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

  " ---- a file keeps its own name
  exec "tabnew " . g:GT_FIX . "/a.txt"
  call GT_Ok("a file is called by its name", GrooVim_TabLabel(4) ==# "a.txt",
    \ "   [" . GrooVim_TabLabel(4) . "]")
  call GT_Ok("  and so says the bar", GrooVim_FileLabel() =~ "a.txt",
    \ "   [" . GrooVim_FileLabel() . "]")

  " ---- the buffer is still nameless, which is the whole point
  tabonly! | enew!
  let g:GrooVim_NewNameCount = 0
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

  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
