" The last question of every configuration screen: just apply, or keep it.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

func! GT_Body()
  let g:GrooVim_OptsFile = g:GT_OUT . "/opts_of_15.vim"
  call delete(g:GrooVim_OptsFile)

  call GT_Ok("the general screen exists", exists("*GrooVim_ConfigureGeneral"), "")
  call GT_Ok("F5 + c gets to it", 1, "   (letter c in the F5 block)")

  " ---- the text of the question comes from the options, like the others
  call GT_Ok("the final question is built like the others",
    \ GrooVim_OptionsToPrompt(["a","s"], "a", "") ==# '[a[default]/s]? ',
    \ "   [Just apply or apply and save " . GrooVim_OptionsToPrompt(["a","s"], "a", "") . "]")

  " ---- answering "a": applies and does NOT write
  call GrooVim_OptsBegin()
  let g:GrooVim_SessionAuto = 0
  call GrooVim_OptsUpdate("let g:GrooVim_SessionAuto =", "let g:GrooVim_SessionAuto = 0", 0)
  call GT_Ok("the option went into the list of what can be kept",
    \ len(g:GrooVim_OptsPending) == 1, "   (" . len(g:GrooVim_OptsPending) . ")")
  call feedkeys("a\<CR>", "t")
  call GrooVim_OptsEnd()
  call feedkeys("", "x")
  call GT_Ok("answering \"a\": wrote no file", !filereadable(g:GrooVim_OptsFile), "")
  call GT_Ok("  but the option holds in the session", g:GrooVim_SessionAuto == 0, "")
  call GT_Ok("  and the list was emptied", empty(g:GrooVim_OptsPending), "")

  " ---- answering "s": applies AND writes
  call GrooVim_OptsBegin()
  let g:GrooVim_SessionAuto = 1
  call GrooVim_OptsUpdate("let g:GrooVim_SessionAuto =", "let g:GrooVim_SessionAuto = 1", 0)
  call feedkeys("s\<CR>", "t")
  call GrooVim_OptsEnd()
  call feedkeys("", "x")
  call GT_Ok("answering \"s\": wrote the file", filereadable(g:GrooVim_OptsFile), "")
  call GT_Ok("  with the right option",
    \ filereadable(g:GrooVim_OptsFile) &&
    \ index(readfile(g:GrooVim_OptsFile), "let g:GrooVim_SessionAuto = 1") >= 0,
    \ "   " . string(filereadable(g:GrooVim_OptsFile) ? readfile(g:GrooVim_OptsFile) : []))

  " ---- and what was kept comes back
  let g:GrooVim_SessionAuto = 0
  exec "source " . fnameescape(g:GrooVim_OptsFile)
  call GT_Ok("what was kept loads back", g:GrooVim_SessionAuto == 1, "")

  " ---- two options at once
  call GrooVim_OptsBegin()
  call GrooVim_OptsUpdate("let g:test_p =", "let g:test_p = 1", 0)
  call GrooVim_OptsUpdate("let g:test_q =", "let g:test_q = 2", 0)
  call feedkeys("s\<CR>", "t")
  call GrooVim_OptsEnd()
  call feedkeys("", "x")
  call GT_Ok("keeps both at once",
    \ index(readfile(g:GrooVim_OptsFile), "let g:test_p = 1") >= 0 &&
    \ index(readfile(g:GrooVim_OptsFile), "let g:test_q = 2") >= 0,
    \ "   " . string(readfile(g:GrooVim_OptsFile)))

  call delete(g:GrooVim_OptsFile)
  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
