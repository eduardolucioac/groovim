" The indent settings, as a screen: the "Tab Settings" of Notepad++.
"
" Width, whether Tab puts spaces, and whether the guides are drawn -- asked the
" way every other screen of GrooVim asks, and ending with the same "just apply or
" apply and save".
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

func! GT_Guide()
  return matchstr(&listchars, 'leadmultispace:\zs.*')
endfunc

func! GT_Body()
  let g:GrooVim_OptsFile = g:GT_OUT . "/opts_of_20.vim"
  call delete(g:GrooVim_OptsFile)
  exec "edit " . g:GT_FIX . "/indent.sh"

  " ---- the prompt of a free number, next to the one of a list
  call GT_Ok("number prompt, nothing in force",
    \ GrooVim_NumberToPrompt(2, "") ==# '[a number, 2[default]]? ',
    \ "   [" . GrooVim_NumberToPrompt(2, "") . "]")
  call GT_Ok("number prompt, with a value in force",
    \ GrooVim_NumberToPrompt(2, 4) ==# '[a number, 2[default]][in use: "4"]? ',
    \ "   [" . GrooVim_NumberToPrompt(2, 4) . "]")

  call feedkeys("zz\<CR>0\<CR>3abc\<CR>6\<CR>", "t")
  let g:GT_R = GrooVim_GetNumber("Test", 2, 4)
  call feedkeys("", "x")
  call GT_Ok("three bad answers and then the good one", g:GT_R ==# "6", "   [" . g:GT_R . "]")

  call feedkeys("\<CR>", "t")
  let g:GT_R = GrooVim_GetNumber("Test", 2, 4)
  call feedkeys("", "x")
  call GT_Ok("empty keeps the value in force", g:GT_R == 4, "   [" . g:GT_R . "]")

  call feedkeys("\<CR>", "t")
  let g:GT_R = GrooVim_GetNumber("Test", 2, "")
  call feedkeys("", "x")
  call GT_Ok("with nothing in force, empty takes the default", g:GT_R == 2, "   [" . g:GT_R . "]")

  " ---- the screen: width 8, spaces on, guides on, just apply
  call GrooVim_IndentWidthApply(2)
  call feedkeys("8\<CR>1\<CR>1\<CR>a\<CR>", "t")
  call GrooVim_ConfigureIndent()
  call feedkeys("", "x")
  call GT_Ok("the width moved the three options at once",
    \ &tabstop == 8 && &shiftwidth == 8 && &softtabstop == 8,
    \ "   (ts=" . &tabstop . " sw=" . &shiftwidth . " sts=" . &softtabstop . ")")
  call GT_Ok("  and the global default went with it",
    \ &g:shiftwidth == 8, "   (global sw=" . &g:shiftwidth . ")   (or the next file opens on the old one)")
  call GT_Ok("  and the guide follows the width", strchars(GT_Guide()) == 8,
    \ "   [" . GT_Guide() . "]")
  call GT_Ok("Tab puts spaces", &expandtab == 1, "")
  call GT_Ok("answering \"a\": nothing was written", !filereadable(g:GrooVim_OptsFile), "")

  " ---- a real tab instead of spaces
  call feedkeys("\<CR>0\<CR>\<CR>a\<CR>", "t")
  call GrooVim_ConfigureIndent()
  call feedkeys("", "x")
  call GT_Ok("Tab puts a real tab now", &expandtab == 0, "")
  call GT_Ok("  and the width was kept by the empty answer", &shiftwidth == 8, "   (sw=" . &shiftwidth . ")")

  " ---- and it really types a tab
  %delete _
  call setline(1, "X")
  call cursor(1, 1)
  call feedkeys("\<Tab>", "x")
  call GT_Ok("a real tab lands in the line", getline(1) =~ "^\t", "   [" . strtrans(getline(1)) . "]")
  call feedkeys("\<CR>1\<CR>\<CR>a\<CR>", "t")
  call GrooVim_ConfigureIndent()
  call feedkeys("", "x")
  %delete _
  call setline(1, "X")
  call cursor(1, 1)
  call feedkeys("\<Tab>", "x")
  call GT_Ok("spaces again, and no tab in the line", getline(1) !~ "\t" && getline(1) =~ "^ \\+X",
    \ "   [" . strtrans(getline(1)) . "]")

  " ---- the guides are asked ONE SCREEN OVER now
  "
  " They are a symbol painted on the screen and not a rule about what <Tab> does,
  " which is where Notepad++ keeps them: View, Show Symbol. So the indent screen
  " asks two things, and the view screen asks about the guide beside the dot on a
  " space and the arrow on a tab.
  " The variable and not the word: the body still explains, in a comment, why
  " the guides are not asked here, and ":function" prints comments too.
  call GT_Ok("the indent screen no longer touches the guide",
    \ GT_FunctionText("GrooVim_ConfigureIndent") !~ "IndentGuideChar",
    \ "   (it asks the width and what <Tab> puts, and stops there)")

  let g:GrooVim_IndentGuideChar = "|"
  call GrooVim_SymbolsSet()
  call feedkeys("\<CR>0\<CR>\<CR>a\<CR>", "t")
  call GrooVim_ConfigureView()
  call feedkeys("", "x")
  call GT_Ok("guides off: no guide in listchars", GT_Guide() ==# "", "   [" . &listchars . "]")
  call GT_Ok("  and trail and nbsp stayed", &listchars =~ "trail:" && &listchars =~ "nbsp:", "")
  call GT_Ok("  and the char you chose was remembered", g:GrooVim_IndentGuideCharLast ==# "|",
    \ "   [" . g:GrooVim_IndentGuideCharLast . "]")

  call feedkeys("\<CR>1\<CR>\<CR>a\<CR>", "t")
  call GrooVim_ConfigureView()
  call feedkeys("", "x")
  call GT_Ok("guides on again, with the SAME char", strcharpart(GT_Guide(), 0, 1) ==# "|",
    \ "   [" . GT_Guide() . "]   (and not the factory one)")

  " ---- and the other symbol of that screen
  call feedkeys("1\<CR>\<CR>\<CR>a\<CR>", "t")
  call GrooVim_ConfigureView()
  call feedkeys("", "x")
  " Anchored at the start or after a comma: "leadmultispace:" ENDS with the
  " string "space:", so a plain match answers yes to the guide.
  call GT_Ok("space and tab on: a dot on every space",
    \ &listchars =~ '\(^\|,\)space:', "   [" . &listchars . "]")
  call GT_Ok("  and an arrow on every tab", &listchars =~ "tab:\u2192", "")
  call feedkeys("0\<CR>\<CR>\<CR>a\<CR>", "t")
  call GrooVim_ConfigureView()
  call feedkeys("", "x")
  call GT_Ok("off again: no dot on a space", &listchars !~ '\(^\|,\)space:',
    \ "   [" . &listchars . "]   (and the guide, which ENDS in \"space:\", is not it)")
  call GT_Ok("  but a tab is STILL named", &listchars =~ "tab:",
    \ "   [" . &listchars . "]   (with none, Vim draws a tab as \"^I\")")

  " ---- answering "s" keeps the three for the next time
  let g:GrooVim_IndentGuideChar = "┊"
  call feedkeys("4\<CR>1\<CR>s\<CR>", "t")
  call GrooVim_ConfigureIndent()
  call feedkeys("", "x")
  call GT_Ok("answering \"s\": the file was written", filereadable(g:GrooVim_OptsFile), "")
  let g:GT_KEPT = filereadable(g:GrooVim_OptsFile) ? readfile(g:GrooVim_OptsFile) : []
  call GT_Ok("  the width was kept", index(g:GT_KEPT, "let g:GrooVim_IndentWidth = 4") >= 0,
    \ "   " . string(g:GT_KEPT))
  call GT_Ok("  the spaces answer was kept", index(g:GT_KEPT, "let g:GrooVim_IndentExpandTab = 1") >= 0, "")
  call GT_Ok("  and the guide char is NOT of this screen any more",
    \ match(g:GT_KEPT, "GrooVim_IndentGuideChar") < 0,
    \ "   (the view screen keeps that one)")

  let g:GrooVim_IndentWidth = 0
  exec "source " . fnameescape(g:GrooVim_OptsFile)
  call GT_Ok("what was kept loads back", g:GrooVim_IndentWidth == 4, "   (" . g:GrooVim_IndentWidth . ")")
  call delete(g:GrooVim_OptsFile)

  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
