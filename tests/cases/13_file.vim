" O grupo "F5" (comandos de arquivo) e a macro que para com as mesmas teclas.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

let g:GT_MACRO = []

func! GT_Body()
  " ---- F5 virou tecla "super", como F2, F3 e F4
  call GT_Ok("F5 chama o CommandZ em normal", maparg("<F5>", "n") =~ 'CommandZ("F5"', "   [" . maparg("<F5>", "n") . "]")
  call GT_Ok("F5 chama o CommandZ em insert", maparg("<F5>", "i") =~ 'CommandZ("F5"', "")
  call GT_Ok("F5 chama o CommandZ em visual", maparg("<F5>", "v") =~ 'CommandZ("F5"', "")
  call GT_Ok("F5 nao para mais a macro sozinho", maparg("<F5>", "n") !~ "norm q", "")

  " ---- fechar pergunta em vez de recusar
  call GT_Ok("existe o fechar que pergunta", exists("*GrooVim_CloseAsking"), "")

  " ---- F5 + s salva
  let arquivo = g:GT_OUT . "/salvo_pelo_f5.txt"
  call delete(arquivo)
  exec "edit " . arquivo
  call setline(1, "gravado pelo F5")
  call GT_Ok("antes de salvar o arquivo nao existe", !filereadable(arquivo), "")
  call feedkeys("\<F5>s", "x")
  call GT_Ok("F5 + s gravou no disco", filereadable(arquivo) &&
    \ readfile(arquivo) ==# ["gravado pelo F5"], "   " . string(filereadable(arquivo) ? readfile(arquivo) : []))
  call GT_Ok("  e o buffer nao esta mais modificado", &modified == 0, "")

  " ---- F5 + a salva todos
  let outro = g:GT_OUT . "/salvo_pelo_f5_dois.txt"
  call delete(outro)
  call setline(1, "primeiro mudou de novo")
  exec "tabnew " . outro
  call setline(1, "segundo")
  call feedkeys("\<F5>a", "x")
  call GT_Ok("F5 + a gravou os dois", filereadable(outro) &&
    \ readfile(arquivo) ==# ["primeiro mudou de novo"] && readfile(outro) ==# ["segundo"],
    \ "   " . string(readfile(arquivo)) . " " . string(filereadable(outro) ? readfile(outro) : []))
  tabonly!
  call delete(arquivo) | call delete(outro)

  " ---- a macro: as mesmas teclas comecam e param
  "
  " Os passos esperam a condicao em vez de marcar tempo: com "t" o feedkeys
  " enfileira, e o Vim so processa ao voltar ao laco principal.
  exec "edit " . g:GT_FIX . "/macro.txt"
  call cursor(1, 1)
  call feedkeys("\<F2>q", "t")
  call GT_When('reg_recording() != ""', "GT_MacroGravando")
endfunc

func! GT_MacroGravando()
  call GT_Ok("F2 + q comecou a gravar", reg_recording() ==# "a", "   [" . reg_recording() . "]")
  call feedkeys("A;\<Esc>j", "t")
  call GT_When('getline(1) =~ ";$"', "GT_MacroDigitou")
endfunc

func! GT_MacroDigitou()
  call feedkeys("\<F2>q", "t")
  call GT_When('reg_recording() == ""', "GT_MacroParou")
endfunc

func! GT_MacroParou()
  call GT_Ok("F2 + q de novo parou", reg_recording() ==# "", "   [" . reg_recording() . "]")
  call GT_Ok("o registro nao guardou as teclas que pararam", getreg("a") ==# "A;\<Esc>j",
    \ "   [" . strtrans(getreg("a")) . "]   (o F2 e o q entram na gravacao)")
  call feedkeys("\<F2>w", "t")
  call GT_When('getline(2) =~ ";$"', "GT_MacroRodouUma")
endfunc

func! GT_MacroRodouUma()
  call feedkeys("\<F2>w", "t")
  call GT_When('getline(3) =~ ";$"', "GT_MacroRodouDuas")
endfunc

func! GT_MacroRodouDuas()
  call GT_Ok("a macro roda, e roda de novo",
    \ getline(1, "$") ==# ["item alpha;", "item beta;", "item gamma;", "item delta", "item epsilon"],
    \ "   " . string(getline(1, "$")))
  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
