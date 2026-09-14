" The configuration questions: the prompt is built out of the options, and only
" a valid answer gets you out of the question.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

" ---- the text comes from the options, not from a sentence written by hand
call GT_Ok("numeric, default 0, now 0",
  \ GrooVim_OptionsToPrompt([0,1], 0, 0) ==# '[0[default]/1][now: "0"]? ',
  \ "   [" . GrooVim_OptionsToPrompt([0,1], 0, 0) . "]")
call GT_Ok("numeric, default 1, now 0",
  \ GrooVim_OptionsToPrompt([0,1], 1, 0) ==# '[0/1[default]][now: "0"]? ',
  \ "   [" . GrooVim_OptionsToPrompt([0,1], 1, 0) . "]")
call GT_Ok("text, default f, now b",
  \ GrooVim_OptionsToPrompt(["f","b"], "f", "b") ==# '[f[default]/b][now: "b"]? ',
  \ "   [" . GrooVim_OptionsToPrompt(["f","b"], "f", "b") . "]")
call GT_Ok("no value in force: no \"now\" is shown",
  \ GrooVim_OptionsToPrompt([0,1], 0, "") ==# '[0[default]/1]? ',
  \ "   [" . GrooVim_OptionsToPrompt([0,1], 0, "") . "]")
call GT_Ok("three options follow the list",
  \ GrooVim_OptionsToPrompt([0,1,2], 2, 1) ==# '[0/1/2[default]][now: "1"]? ',
  \ "   [" . GrooVim_OptionsToPrompt([0,1,2], 2, 1) . "]")

" ---- validation
call GT_Ok("takes an option from the list", GrooVim_ValidateOptions("1", [0,1], 0) == 1, "")
call GT_Ok("takes the other one", GrooVim_ValidateOptions("0", [0,1], 1) == 1, "")
call GT_Ok("refuses what is not on the list", GrooVim_ValidateOptions("aa", [0,1], 0) == 0, "")
call GT_Ok("refuses something close but different", GrooVim_ValidateOptions("01", [0,1], 0) == 0, "")
call GT_Ok("empty is valid when there is a value in force", GrooVim_ValidateOptions("", [0,1], 0) == 1, "")
call GT_Ok("empty is NOT valid without one", GrooVim_ValidateOptions("", [0,1], "") == 0, "   (this is what makes an answer required)")
call GT_Ok("empty list + empty answer: no longer hangs", GrooVim_ValidateOptions("", [], 0) == 1, "   (the test used to be INSIDE the loop)")
call GT_Ok("an option made of text", GrooVim_ValidateOptions("b", ["f","b"], "f") == 1, "")
call GT_Ok("text that is not on the list", GrooVim_ValidateOptions("x", ["f","b"], "f") == 0, "")

" ---- the question only ends with a valid answer
let g:searchReplace_CaseSensitive = 0
call feedkeys("aa\<CR>zz\<CR>1\<CR>", "t")
let g:GT_R = GrooVim_GetOptions("Test", [0,1], 0, g:searchReplace_CaseSensitive)
call feedkeys("", "x")
call GT_Ok("two bad answers and then the good one", g:GT_R ==# "1", "   [" . g:GT_R . "]")

call feedkeys("\<CR>", "t")
let g:GT_R = GrooVim_GetOptions("Test", [0,1], 0, 1)
call feedkeys("", "x")
call GT_Ok("empty keeps the value in force", g:GT_R == 1, "   [" . g:GT_R . "]")

call feedkeys("\<CR>", "t")
let g:GT_R = GrooVim_GetOptions("Test", [0,1], 1, "")
call feedkeys("", "x")
call GT_Ok("with no value in force, empty takes the default", g:GT_R == 1, "   [" . g:GT_R . "]")

" ---- the question of the macro: same machinery, same behaviour
call GT_Ok("takes the x", GrooVim_IsRepetitionCount("x") == 1, "")
call GT_Ok("takes a number", GrooVim_IsRepetitionCount("3") == 1, "")
call GT_Ok("refuses zero", GrooVim_IsRepetitionCount("0") == 0, "")
call GT_Ok("refuses a negative", GrooVim_IsRepetitionCount("-2") == 0, "")
call GT_Ok("refuses text", GrooVim_IsRepetitionCount("abc") == 0, "")
call GT_Ok("refuses empty", GrooVim_IsRepetitionCount("") == 0, "")
call GT_Ok("refuses 3abc", GrooVim_IsRepetitionCount("3abc") == 0, "   (str2nr read it as 3)")
call GT_Ok("refuses 1.5", GrooVim_IsRepetitionCount("1.5") == 0, "")
call GT_Ok("refuses a capital X", GrooVim_IsRepetitionCount("X") == 0, "")
call GT_Ok("takes a large number", GrooVim_IsRepetitionCount("100") == 1, "")

" ---- the general helper: asks again until the answer passes the test
call feedkeys("abc\<CR>0\<CR>3abc\<CR>4\<CR>", "t")
let g:GT_R = GrooVim_AskUntilValid("Test: ", {a -> GrooVim_IsRepetitionCount(a)})
call feedkeys("", "x")
call GT_Ok("three bad ones and then the good one", g:GT_R ==# "4", "   [" . g:GT_R . "]")

call feedkeys("zz\<CR>x\<CR>", "t")
let g:GT_R = GrooVim_AskUntilValid("Test: ", {a -> GrooVim_IsRepetitionCount(a)})
call feedkeys("", "x")
call GT_Ok("a bad one and then the x", g:GT_R ==# "x", "   [" . g:GT_R . "]")

call GT_Done()
