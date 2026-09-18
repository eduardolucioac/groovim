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

" ---- how a question is written: a yes and a no are numbers, a choice is letters
"
" "Get [0]filename or [1]filename and path" made the reader carry an arbitrary
" pairing in their head for as long as it was on screen. Nothing about a 0 means
" "filename". A 0 and a 1 mean no and yes, and that is all they should ever be
" asked to mean.
"
" This reads the source, because a question is not something a running Vim can be
" asked about.
let g:GT_Numbered = []
for g:GT_Line in GT_SourceLines()
  let g:GT_Q = matchstr(g:GT_Line, 'GrooVim_GetOptions(\s*\%(\n\s*.\)\?\s*"\zs[^"]*')
  if g:GT_Q ==# "" | continue | endif
  if g:GT_Q =~ '\[[0-9]\]'
    call add(g:GT_Numbered, g:GT_Q)
  endif
endfor
call GT_Ok("no question spells its answers out as numbers", empty(g:GT_Numbered),
  \ "   " . (empty(g:GT_Numbered) ? "(a choice is written with letters)" : string(g:GT_Numbered)))

" ---- and a choice really does answer to its letter
call feedkeys("p\<CR>", "t")
let g:GT_R = GrooVim_GetOptions("Get [f]filename or [p]filename and path", ["f", "p"], "f", "")
call feedkeys("", "x")
call GT_Ok("the filename question answers to [p]", g:GT_R ==# "p", "   [" . g:GT_R . "]")
call GT_Ok("  and the old 1 is not an answer any more",
  \ GrooVim_ValidateOptions("1", ["f", "p"], "f") == 0, "")

" ---- the general settings screen
let g:GT_KeptSession = g:GrooVim_SessionAuto
call feedkeys("0\<CR>a\<CR>", "t")
call GrooVim_ConfigureGeneral()
call feedkeys("", "x")
call GT_Ok("F5->c asks about the session, and answering it works",
  \ g:GrooVim_SessionAuto == 0, "")
let g:GrooVim_SessionAuto = g:GT_KeptSession

" ---- and nothing about the clipboard, anywhere
"
" OSC 52 is the LAST method of the cascade, so reaching it means everything else
" already failed. From there every knob could only SUBTRACT: turning it off left
" the file and nothing going out, and asking the terminal left "clipmethod=none"
" whenever it did not answer -- which is most terminals. Neither had a case where
" it left anyone better off, so neither exists.
call GT_Ok("no screen asks about the clipboard",
  \ empty(filter(GT_SourceLines(), 'v:val =~ "GetOptions" && v:val =~ "OSC 52"')), "")
call GT_Ok("and there is no switch left to ask about",
  \ !exists("g:GrooVim_EnableOSC52") && !exists("*GrooVim_OSC52Apply"),
  \ "   (a knob that can only subtract is not a knob)")
call GT_Ok("what replaced it has a name",
  \ exists("*GrooVim_ClipAssumed"),
  \ "   (GrooVim assumes OSC 52 and keeps its own copy beside it)")

" ---- what makes a KEPT answer work at all
"
" The answers you keep are read before any part of GrooVim, so that they win
" over the defaults. That only holds while every default is written as
" "get(g:, "name", ...)": a plain assignment would run over the kept value
" instead, silently. Seven of them were plain assignments until this moved.
let g:GT_Plain = []
let g:GT_Source = GT_SourceLines()
for g:GT_Line in g:GT_Source
  " A digit belongs to the name: "EnableOSC52" came out as "EnableOSC" while
  " this read letters only, and the check failed on a name that does not exist.
  let g:GT_Name = matchstr(g:GT_Line, 'GrooVim_OptsUpdate("let g:\zs[A-Za-z_0-9]\+')
  if g:GT_Name ==# "" | continue | endif
  if empty(filter(copy(g:GT_Source), 'v:val =~ "^let g:" . g:GT_Name . " = get(g:, "'))
    call add(g:GT_Plain, g:GT_Name)
  endif
endfor
call GT_Ok("every kept answer has a default that gives way to it", empty(g:GT_Plain),
  \ "   " . (empty(g:GT_Plain) ? "(all of them)" : string(g:GT_Plain)))

" ---- and the file is read before the parts, not after them
let g:GT_Vimrc = readfile($GROOVIM_TEST_VIMRC)
let g:GT_ReadAt = match(g:GT_Vimrc, 'source " . fnameescape(g:GrooVim_OptsFile)')
let g:GT_PartsAt = match(g:GT_Vimrc, '^\s*exec "source " . fnameescape(s:GrooVim_File)')
call GT_Ok("the .vimrc reads the kept answers", g:GT_ReadAt >= 0,
  \ "   (line " . (g:GT_ReadAt + 1) . ")")
call GT_Ok("  BEFORE it loads a single part",
  \ g:GT_ReadAt >= 0 && g:GT_PartsAt > g:GT_ReadAt,
  \ "   (kept answers on line " . (g:GT_ReadAt + 1) . ", the parts on line " . (g:GT_PartsAt + 1) . ")")

" ---- the bell, which "noerrorbells" does not cover
"
" From the manual of that option: "This only makes a difference for error
" messages, the bell will be used ALWAYS for a lot of errors without a message".
" A cursor that cannot move any further is one of those, so reaching the end of a
" line rang a real bell -- and over SSH that lights the bell mark on the tab of
" the terminal. Notepad++ does not beep there, or anywhere.
call GT_Ok("every bell is off", &belloff ==# "all", "   [belloff=" . &belloff . "]")
call GT_Ok("  and noerrorbells alone would not have done it",
  \ &errorbells == 0,
  \ "   (it only covers errors that come WITH a message)")

call GT_Done()
