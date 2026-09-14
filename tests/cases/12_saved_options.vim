" Keeping an option for the next session.
"
" The saving path has been in GrooVim_OptsUpdate since 2014, in the third
" parameter, and was never called -- which is why it had three defects, one per
" situation. This case exercises the three.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

func! GT_Body()
  " an options file of this test alone, so the one of the user is not touched
  let g:GrooVim_OptsFile = g:GT_OUT . "/test_opts.vim"
  call delete(g:GrooVim_OptsFile)

  call GT_Ok("the file lives OUTSIDE ~/.vim/plugin", g:GrooVim_OptsFile !~ "plugin/",
    \ "   (or the Vim of the system would load it on its own)")

  " ---- 1: saving when the file does not exist yet
  let err = ""
  try
    call GrooVim_OptsUpdate("let g:test_one =", "let g:test_one = 7", 1)
  catch
    let err = v:exception
  endtry
  call GT_Ok("no such file: no exception", err ==# "", "   [" . err . "]   (it was E121)")
  call GT_Ok("  and the option was written", filereadable(g:GrooVim_OptsFile) &&
    \ index(readfile(g:GrooVim_OptsFile), "let g:test_one = 7") >= 0,
    \ "   " . string(filereadable(g:GrooVim_OptsFile) ? readfile(g:GrooVim_OptsFile) : []))

  " ---- 2: a NEW option in a file that already holds another
  let err = ""
  try
    call GrooVim_OptsUpdate("let g:test_two =", "let g:test_two = 8", 1)
  catch
    let err = v:exception
  endtry
  call GT_Ok("new option: no exception", err ==# "", "   [" . err . "]")
  call GT_Ok("  added the right option",
    \ readfile(g:GrooVim_OptsFile) ==# ["let g:test_one = 7", "let g:test_two = 8"],
    \ "   " . string(readfile(g:GrooVim_OptsFile)) . "   (it used to duplicate the wrong line)")

  " ---- 3: changing an option that is already there
  let err = ""
  try
    call GrooVim_OptsUpdate("let g:test_one =", "let g:test_one = 9", 1)
  catch
    let err = v:exception
  endtry
  call GT_Ok("option already there: no exception", err ==# "", "   [" . err . "]   (it was E121 in the exec)")
  call GT_Ok("  changed it in the file",
    \ readfile(g:GrooVim_OptsFile) ==# ["let g:test_one = 9", "let g:test_two = 8"],
    \ "   " . string(readfile(g:GrooVim_OptsFile)))
  call GT_Ok("  and applied it in the session", exists("g:test_one") && g:test_one == 9,
    \ "   (g:test_one = " . (exists("g:test_one") ? g:test_one : "does not exist") . ")")

  " ---- and what was saved comes back in a new session
  let g:test_one = 0
  exec "source " . fnameescape(g:GrooVim_OptsFile)
  call GT_Ok("the saved file loads back", g:test_one == 9, "   (" . g:test_one . ")")

  " ---- only applying writes nothing
  call delete(g:GrooVim_OptsFile)
  call GrooVim_OptsUpdate("let g:test_three =", "let g:test_three = 3", 0)
  call GT_Ok("only applying does NOT create the file", !filereadable(g:GrooVim_OptsFile), "")
  call GT_Ok("  but it holds in the session", exists("g:test_three") && g:test_three == 3, "")

  call delete(g:GrooVim_OptsFile)
  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
