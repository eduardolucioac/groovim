" As perguntas de configuração: o texto do prompt é montado a partir das opções,
" e só uma resposta válida sai da pergunta.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Nome(expand("<sfile>:t:r"))

" ---- o texto sai das opcoes, e nao de uma frase escrita a mao
call GT_Ok("numerico, padrao 0, agora 0",
  \ GrooVim_OptionsToPrompt([0,1], 0, 0) ==# '[0[default]/1][now: "0"]? ',
  \ "   [" . GrooVim_OptionsToPrompt([0,1], 0, 0) . "]")
call GT_Ok("numerico, padrao 1, agora 0",
  \ GrooVim_OptionsToPrompt([0,1], 1, 0) ==# '[0/1[default]][now: "0"]? ',
  \ "   [" . GrooVim_OptionsToPrompt([0,1], 1, 0) . "]")
call GT_Ok("texto, padrao f, agora b",
  \ GrooVim_OptionsToPrompt(["f","b"], "f", "b") ==# '[f[default]/b][now: "b"]? ',
  \ "   [" . GrooVim_OptionsToPrompt(["f","b"], "f", "b") . "]")
call GT_Ok("sem valor em vigor: nao mostra o now",
  \ GrooVim_OptionsToPrompt([0,1], 0, "") ==# '[0[default]/1]? ',
  \ "   [" . GrooVim_OptionsToPrompt([0,1], 0, "") . "]")
call GT_Ok("tres opcoes acompanham a lista",
  \ GrooVim_OptionsToPrompt([0,1,2], 2, 1) ==# '[0/1/2[default]][now: "1"]? ',
  \ "   [" . GrooVim_OptionsToPrompt([0,1,2], 2, 1) . "]")

" ---- validacao
call GT_Ok("aceita uma opcao da lista", GrooVim_ValidateOptions("1", [0,1], 0) == 1, "")
call GT_Ok("aceita a outra", GrooVim_ValidateOptions("0", [0,1], 1) == 1, "")
call GT_Ok("recusa o que nao esta na lista", GrooVim_ValidateOptions("aa", [0,1], 0) == 0, "")
call GT_Ok("recusa parecido mas diferente", GrooVim_ValidateOptions("01", [0,1], 0) == 0, "")
call GT_Ok("vazio vale quando ha valor em vigor", GrooVim_ValidateOptions("", [0,1], 0) == 1, "")
call GT_Ok("vazio NAO vale sem valor em vigor", GrooVim_ValidateOptions("", [0,1], "") == 0, "   (e o que torna a resposta obrigatoria)")
call GT_Ok("lista vazia + vazio: nao trava mais", GrooVim_ValidateOptions("", [], 0) == 1, "   (antes a condicao estava DENTRO do laco)")
call GT_Ok("opcao de texto", GrooVim_ValidateOptions("b", ["f","b"], "f") == 1, "")
call GT_Ok("texto fora da lista", GrooVim_ValidateOptions("x", ["f","b"], "f") == 0, "")

" ---- a pergunta so termina com resposta valida
let g:searchReplace_CaseSensitive = 0
call feedkeys("aa\<CR>zz\<CR>1\<CR>", "t")
let g:GT_R = GrooVim_GetOptions("Teste", [0,1], 0, g:searchReplace_CaseSensitive)
call feedkeys("", "x")
call GT_Ok("duas respostas invalidas e depois a boa", g:GT_R ==# "1", "   [" . g:GT_R . "]")

call feedkeys("\<CR>", "t")
let g:GT_R = GrooVim_GetOptions("Teste", [0,1], 0, 1)
call feedkeys("", "x")
call GT_Ok("vazio mantem o valor em vigor", g:GT_R == 1, "   [" . g:GT_R . "]")

call feedkeys("\<CR>", "t")
let g:GT_R = GrooVim_GetOptions("Teste", [0,1], 1, "")
call feedkeys("", "x")
call GT_Ok("sem valor em vigor, vazio pega o padrao", g:GT_R == 1, "   [" . g:GT_R . "]")

" ---- a pergunta da macro: mesmo mecanismo, mesma coerencia
call GT_Ok("aceita o x", GrooVim_IsRepetitionCount("x") == 1, "")
call GT_Ok("aceita um numero", GrooVim_IsRepetitionCount("3") == 1, "")
call GT_Ok("recusa zero", GrooVim_IsRepetitionCount("0") == 0, "")
call GT_Ok("recusa negativo", GrooVim_IsRepetitionCount("-2") == 0, "")
call GT_Ok("recusa texto", GrooVim_IsRepetitionCount("abc") == 0, "")
call GT_Ok("recusa vazio", GrooVim_IsRepetitionCount("") == 0, "")
call GT_Ok("recusa 3abc", GrooVim_IsRepetitionCount("3abc") == 0, "   (o str2nr lia como 3)")
call GT_Ok("recusa 1.5", GrooVim_IsRepetitionCount("1.5") == 0, "")
call GT_Ok("recusa X maiusculo", GrooVim_IsRepetitionCount("X") == 0, "")
call GT_Ok("aceita numero grande", GrooVim_IsRepetitionCount("100") == 1, "")

" ---- o ajudante generico: repete ate passar no teste
call feedkeys("abc\<CR>0\<CR>3abc\<CR>4\<CR>", "t")
let g:GT_R = GrooVim_AskUntilValid("Teste: ", {a -> GrooVim_IsRepetitionCount(a)})
call feedkeys("", "x")
call GT_Ok("tres invalidas e depois a boa", g:GT_R ==# "4", "   [" . g:GT_R . "]")

call feedkeys("zz\<CR>x\<CR>", "t")
let g:GT_R = GrooVim_AskUntilValid("Teste: ", {a -> GrooVim_IsRepetitionCount(a)})
call feedkeys("", "x")
call GT_Ok("invalida e depois o x", g:GT_R ==# "x", "   [" . g:GT_R . "]")

call GT_Fim()
