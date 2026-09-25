" The session: which files were open, in which tabs.
"
" Kept on its own when you leave and brought back when you open with no file.
" The commands by hand only work while the automatic one is off -- otherwise
" they say so, instead of pretending they did something.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

func! GT_Body()
  let g:GrooVim_SessionFile = g:GT_OUT . "/test_session.vim"
  call delete(g:GrooVim_SessionFile)

  call GT_Ok("the automatic one comes ON out of the box", g:GrooVim_SessionAuto == 1, "")
  call GT_Ok("the session file stays with GrooVim",
    \ g:GrooVim_SessionFile !~ '^\~/[^.]' && g:GrooVim_SessionFile !~ "/vim_session$",
    \ "   [" . g:GrooVim_SessionFile . "]   (it used to be ~/vim_session, at the root of HOME)")

  " ---- with the automatic one ON, by hand it warns and writes nothing
  let g:GrooVim_GrooVimBarMsgValue = ""
  call GrooVim_SessionSaveByHand()
  call GT_Ok("automatic on: saving by hand warns",
    \ g:GrooVim_GrooVimBarMsgValue =~ "already saves itself",
    \ "   [" . g:GrooVim_GrooVimBarMsgValue . "]")
  call GT_Ok("  and it wrote no file at all", !filereadable(g:GrooVim_SessionFile), "")

  let g:GrooVim_GrooVimBarMsgValue = ""
  call GrooVim_SessionLoadByHand()
  call GT_Ok("automatic on: loading by hand warns",
    \ g:GrooVim_GrooVimBarMsgValue =~ "comes back by itself",
    \ "   [" . g:GrooVim_GrooVimBarMsgValue . "]")

  " ---- with the automatic one OFF, by hand it works
  let g:GrooVim_SessionAuto = 0
  let g:GrooVim_GrooVimBarMsgValue = ""
  call GrooVim_SessionLoadByHand()
  call GT_Ok("no session saved yet: it says so", g:GrooVim_GrooVimBarMsgValue =~ "no saved session",
    \ "   [" . g:GrooVim_GrooVimBarMsgValue . "]")

  exec "edit " . g:GT_FIX . "/a.txt"
  exec "tabnew " . g:GT_FIX . "/b.txt"
  let g:GrooVim_GrooVimBarMsgValue = ""
  call GrooVim_SessionSaveByHand()
  call GT_Ok("automatic off: it really saved", filereadable(g:GrooVim_SessionFile), "")
  call GT_Ok("  and it said it saved", g:GrooVim_GrooVimBarMsgValue =~ "Session saved",
    \ "   [" . g:GrooVim_GrooVimBarMsgValue . "]")
  call GT_Ok("  the session wrote down both files",
    \ join(readfile(g:GrooVim_SessionFile), "\n") =~ "a.txt" &&
    \ join(readfile(g:GrooVim_SessionFile), "\n") =~ "b.txt", "")

  " ---- what the session does NOT bring back
  call GT_Ok("sessionoptions without \"options\"", &sessionoptions !~ "options",
    \ "   [" . &sessionoptions . "]   (it would bring back the options of the day it was saved)")
  call GT_Ok("sessionoptions keeps the tabs", &sessionoptions =~ "tabpages", "")

  " ---- the directory you started in wins over the one the session remembers
  "
  " A session carries the working directory it was saved in -- "mksession"
  " writes a "cd" into it -- so coming back brought that directory along, and
  " the file tree opened wherever you had been days ago instead of where you
  " just ran the command. Measured through a real terminal: "groovim" started
  " inside one directory, with no file named, opened its tree on the directory
  " of the session.
  "
  " With a file named there was never a problem, because then no session comes
  " back at all. It is the empty call -- the one that restores -- that had it.
  let s:startedIn = getcwd()
  let s:elsewhere = fnamemodify(g:GT_OUT, ":p:h")
  call GT_Ok("setup: two directories to tell apart",
    \ isdirectory(s:elsewhere) && s:elsewhere !=# s:startedIn,
    \ "   [" . s:startedIn . "] [" . s:elsewhere . "]")

  call writefile(["cd " . fnameescape(s:elsewhere)], g:GrooVim_SessionFile)
  call GrooVim_SessionLoad()
  call GT_Ok("a session that carries another directory does not take you there",
    \ getcwd() ==# s:startedIn, "   [" . getcwd() . "]")
  call GT_Ok("  and it is put back AFTER the session is read",
    \ GT_FunctionText("GrooVim_SessionLoad") =~ "source" &&
    \ match(GT_FunctionText("GrooVim_SessionLoad"), "cd ") >
    \   match(GT_FunctionText("GrooVim_SessionLoad"), "source"),
    \ "   (a directory changed under a session is a session looking for files\n" .
    \ "    that are no longer where it left them)")
  call delete(g:GrooVim_SessionFile)

  " ---- and the automatic one holds again
  let g:GrooVim_SessionAuto = 1
  call delete(g:GrooVim_SessionFile)
  call GrooVim_SessionSave()
  call GT_Ok("saving automatically writes straight away", filereadable(g:GrooVim_SessionFile), "")
  call delete(g:GrooVim_SessionFile)

  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
