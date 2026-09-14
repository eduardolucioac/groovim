" A sessão: quais arquivos estavam abertos, em que abas.
"
" Guardada sozinha ao sair e trazida de volta ao abrir sem arquivo. Os comandos
" manuais só valem quando o automático está desligado -- caso contrário eles
" avisam, em vez de fingir que fizeram algo.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Nome(expand("<sfile>:t:r"))

func! GT_Corpo()
  let g:GrooVim_SessionFile = g:GT_OUT . "/sessao_do_teste.vim"
  call delete(g:GrooVim_SessionFile)

  call GT_Ok("o automatico vem LIGADO de fabrica", g:GrooVim_SessionAuto == 1, "")
  call GT_Ok("o arquivo da sessao fica com o GrooVim",
    \ g:GrooVim_SessionFile !~ '^\~/[^.]' && g:GrooVim_SessionFile !~ "/vim_session$",
    \ "   [" . g:GrooVim_SessionFile . "]   (antes era ~/vim_session, na raiz do HOME)")

  " ---- com o automatico LIGADO, o manual avisa e nao escreve
  let g:GrooVim_GrooVimBarMsgValue = ""
  call GrooVim_SessionSaveByHand()
  call GT_Ok("automatico ligado: salvar a mao avisa",
    \ g:GrooVim_GrooVimBarMsgValue =~ "already saves itself",
    \ "   [" . g:GrooVim_GrooVimBarMsgValue . "]")
  call GT_Ok("  e nao escreveu arquivo nenhum", !filereadable(g:GrooVim_SessionFile), "")

  let g:GrooVim_GrooVimBarMsgValue = ""
  call GrooVim_SessionLoadByHand()
  call GT_Ok("automatico ligado: recarregar a mao avisa",
    \ g:GrooVim_GrooVimBarMsgValue =~ "comes back by itself",
    \ "   [" . g:GrooVim_GrooVimBarMsgValue . "]")

  " ---- com o automatico DESLIGADO, o manual funciona
  let g:GrooVim_SessionAuto = 0
  let g:GrooVim_GrooVimBarMsgValue = ""
  call GrooVim_SessionLoadByHand()
  call GT_Ok("sem sessao salva ainda: avisa", g:GrooVim_GrooVimBarMsgValue =~ "no saved session",
    \ "   [" . g:GrooVim_GrooVimBarMsgValue . "]")

  exec "edit " . g:GT_FIX . "/a.txt"
  exec "tabnew " . g:GT_FIX . "/b.txt"
  let g:GrooVim_GrooVimBarMsgValue = ""
  call GrooVim_SessionSaveByHand()
  call GT_Ok("automatico desligado: salvou mesmo", filereadable(g:GrooVim_SessionFile), "")
  call GT_Ok("  e disse que salvou", g:GrooVim_GrooVimBarMsgValue =~ "Session saved",
    \ "   [" . g:GrooVim_GrooVimBarMsgValue . "]")
  call GT_Ok("  a sessao anotou os dois arquivos",
    \ join(readfile(g:GrooVim_SessionFile), "\n") =~ "a.txt" &&
    \ join(readfile(g:GrooVim_SessionFile), "\n") =~ "b.txt", "")

  " ---- o que a sessao NAO carrega
  call GT_Ok("sessionoptions sem \"options\"", &sessionoptions !~ "options",
    \ "   [" . &sessionoptions . "]   (traria de volta as opcoes do dia em que foi salva)")
  call GT_Ok("sessionoptions guarda as abas", &sessionoptions =~ "tabpages", "")

  " ---- e o automatico volta a valer
  let g:GrooVim_SessionAuto = 1
  call delete(g:GrooVim_SessionFile)
  call GrooVim_SessionSave()
  call GT_Ok("o salvar automatico escreve direto", filereadable(g:GrooVim_SessionFile), "")
  call delete(g:GrooVim_SessionFile)

  call GT_Fim()
endfunc

call GT_DepoisDoArranque("GT_Corpo")
