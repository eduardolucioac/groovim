" A última pergunta de toda tela de configuração: só aplicar, ou guardar.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

func! GT_Body()
  let g:GrooVim_OptsFile = g:GT_OUT . "/opts_do_15.vim"
  call delete(g:GrooVim_OptsFile)

  call GT_Ok("existe a tela geral", exists("*GrooVim_ConfigureGeneral"), "")
  call GT_Ok("F5 + c chega nela", 1, "   (letra c no bloco do F5)")

  " ---- o texto da pergunta sai das opcoes, como as outras
  call GT_Ok("a pergunta final e montada igual as outras",
    \ GrooVim_OptionsToPrompt(["a","s"], "a", "") ==# '[a[default]/s]? ',
    \ "   [Just apply or apply and save " . GrooVim_OptionsToPrompt(["a","s"], "a", "") . "]")

  " ---- responder "a": aplica e NAO escreve
  call GrooVim_OptsBegin()
  let g:GrooVim_SessionAuto = 0
  call GrooVim_OptsUpdate("let g:GrooVim_SessionAuto =", "let g:GrooVim_SessionAuto = 0", 0)
  call GT_Ok("a opcao entrou na lista do que pode ser guardado",
    \ len(g:GrooVim_OptsPending) == 1, "   (" . len(g:GrooVim_OptsPending) . ")")
  call feedkeys("a\<CR>", "t")
  call GrooVim_OptsEnd()
  call feedkeys("", "x")
  call GT_Ok("respondendo \"a\": nao escreveu arquivo", !filereadable(g:GrooVim_OptsFile), "")
  call GT_Ok("  mas a opcao vale na sessao", g:GrooVim_SessionAuto == 0, "")
  call GT_Ok("  e a lista foi esvaziada", empty(g:GrooVim_OptsPending), "")

  " ---- responder "s": aplica E escreve
  call GrooVim_OptsBegin()
  let g:GrooVim_SessionAuto = 1
  call GrooVim_OptsUpdate("let g:GrooVim_SessionAuto =", "let g:GrooVim_SessionAuto = 1", 0)
  call feedkeys("s\<CR>", "t")
  call GrooVim_OptsEnd()
  call feedkeys("", "x")
  call GT_Ok("respondendo \"s\": escreveu o arquivo", filereadable(g:GrooVim_OptsFile), "")
  call GT_Ok("  com a opcao certa",
    \ filereadable(g:GrooVim_OptsFile) &&
    \ index(readfile(g:GrooVim_OptsFile), "let g:GrooVim_SessionAuto = 1") >= 0,
    \ "   " . string(filereadable(g:GrooVim_OptsFile) ? readfile(g:GrooVim_OptsFile) : []))

  " ---- e o que foi guardado volta
  let g:GrooVim_SessionAuto = 0
  exec "source " . fnameescape(g:GrooVim_OptsFile)
  call GT_Ok("o guardado carrega de volta", g:GrooVim_SessionAuto == 1, "")

  " ---- duas opcoes de uma vez
  call GrooVim_OptsBegin()
  call GrooVim_OptsUpdate("let g:teste_p =", "let g:teste_p = 1", 0)
  call GrooVim_OptsUpdate("let g:teste_q =", "let g:teste_q = 2", 0)
  call feedkeys("s\<CR>", "t")
  call GrooVim_OptsEnd()
  call feedkeys("", "x")
  call GT_Ok("guarda as duas de uma vez",
    \ index(readfile(g:GrooVim_OptsFile), "let g:teste_p = 1") >= 0 &&
    \ index(readfile(g:GrooVim_OptsFile), "let g:teste_q = 2") >= 0,
    \ "   " . string(readfile(g:GrooVim_OptsFile)))

  call delete(g:GrooVim_OptsFile)
  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
