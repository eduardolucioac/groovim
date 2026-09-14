" Guardar uma opção para a próxima sessão.
"
" O caminho de salvar existe desde 2014 no GrooVim_OptsUpdate, no terceiro
" parâmetro, e nunca foi chamado -- por isso tinha três defeitos, um em cada
" situação. Este caso exercita as três.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

func! GT_Body()
  " um arquivo de opções só deste teste, para não encostar no do usuário
  let g:GrooVim_OptsFile = g:GT_OUT . "/opts_do_teste.vim"
  call delete(g:GrooVim_OptsFile)

  call GT_Ok("o arquivo fica FORA de ~/.vim/plugin", g:GrooVim_OptsFile !~ "plugin/",
    \ "   (senao o Vim do sistema o carregaria sozinho)")

  " ---- 1: salvar quando o arquivo ainda nao existe
  let erro = ""
  try
    call GrooVim_OptsUpdate("let g:teste_um =", "let g:teste_um = 7", 1)
  catch
    let erro = v:exception
  endtry
  call GT_Ok("arquivo inexistente: sem excecao", erro ==# "", "   [" . erro . "]   (era E121)")
  call GT_Ok("  e a opcao foi escrita", filereadable(g:GrooVim_OptsFile) &&
    \ index(readfile(g:GrooVim_OptsFile), "let g:teste_um = 7") >= 0,
    \ "   " . string(filereadable(g:GrooVim_OptsFile) ? readfile(g:GrooVim_OptsFile) : []))

  " ---- 2: uma opcao NOVA num arquivo que ja tem outra
  let erro = ""
  try
    call GrooVim_OptsUpdate("let g:teste_dois =", "let g:teste_dois = 8", 1)
  catch
    let erro = v:exception
  endtry
  call GT_Ok("opcao nova: sem excecao", erro ==# "", "   [" . erro . "]")
  call GT_Ok("  acrescentou a opcao certa",
    \ readfile(g:GrooVim_OptsFile) ==# ["let g:teste_um = 7", "let g:teste_dois = 8"],
    \ "   " . string(readfile(g:GrooVim_OptsFile)) . "   (antes duplicava a linha errada)")

  " ---- 3: trocar uma opcao que ja esta la
  let erro = ""
  try
    call GrooVim_OptsUpdate("let g:teste_um =", "let g:teste_um = 9", 1)
  catch
    let erro = v:exception
  endtry
  call GT_Ok("opcao existente: sem excecao", erro ==# "", "   [" . erro . "]   (era E121 no exec)")
  call GT_Ok("  trocou no arquivo",
    \ readfile(g:GrooVim_OptsFile) ==# ["let g:teste_um = 9", "let g:teste_dois = 8"],
    \ "   " . string(readfile(g:GrooVim_OptsFile)))
  call GT_Ok("  e aplicou na sessao", exists("g:teste_um") && g:teste_um == 9,
    \ "   (g:teste_um = " . (exists("g:teste_um") ? g:teste_um : "nao existe") . ")")

  " ---- e o que foi salvo volta numa sessao nova
  let g:teste_um = 0
  exec "source " . fnameescape(g:GrooVim_OptsFile)
  call GT_Ok("o arquivo salvo carrega de volta", g:teste_um == 9, "   (" . g:teste_um . ")")

  " ---- so aplicar nao escreve nada
  call delete(g:GrooVim_OptsFile)
  call GrooVim_OptsUpdate("let g:teste_tres =", "let g:teste_tres = 3", 0)
  call GT_Ok("so aplicar NAO cria o arquivo", !filereadable(g:GrooVim_OptsFile), "")
  call GT_Ok("  mas vale na sessao", exists("g:teste_tres") && g:teste_tres == 3, "")

  call delete(g:GrooVim_OptsFile)
  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
