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

  " ---- and the automatic one holds again
  let g:GrooVim_SessionAuto = 1
  call delete(g:GrooVim_SessionFile)
  call GrooVim_SessionSave()
  call GT_Ok("saving automatically writes straight away", filereadable(g:GrooVim_SessionFile), "")
  call delete(g:GrooVim_SessionFile)

  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
