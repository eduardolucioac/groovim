" Replacing inside one buffer: the counter, the wrap, and the cursor coming back.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

let g:searchReplace_InAllOpened = 0
let g:configureGrooVim_EntertainmentReplace_AskTheValueToBeReplaced = 1
let g:configureGrooVim_EntertainmentReplace_Confirmation = 0
let g:configureGrooVim_EntertainmentReplace_FromCurrentPosition = 1

" ---- the counter must not touch the text nor "gdefault"
%delete _ | call setline(1, ["a x a", "b", "a", "c x", "a a a"])
call GT_Ok("counter: 'a' in lines 1-3", GrooVim_CountOccurrences("a", 1, 3) == 3, "   (found " . GrooVim_CountOccurrences("a", 1, 3) . ")")
call GT_Ok("counter: 'a' in the whole file", GrooVim_CountOccurrences("a", 1, 5) == 6, "   (found " . GrooVim_CountOccurrences("a", 1, 5) . ")")
call GT_Ok("counter: something absent gives zero", GrooVim_CountOccurrences("zzz", 1, 5) == 0, "")
call GT_Ok("the counter did not change the text", getline(1,"$") ==# ["a x a", "b", "a", "c x", "a a a"], "")
call GT_Ok("gdefault kept", &gdefault == 1, "   (the counter turns it off and has to put it back)")

" ---- the wrap only happens WITH confirmation
" With nothing to answer, going on from the top would be the same as "replace all".
let g:configureGrooVim_EntertainmentReplace_Confirmation = 1
%delete _ | call setline(1, ["target 1", "target 2", "middle", "target 3", "target 4"])
call cursor(3, 1)
let g:GrooVim_GrooVimBarMsgValue = ""
call feedkeys("target\<CR>NEW\<CR>aa", "t")
call GrooVim_EntertainmentReplace("n")
call feedkeys("", "x")
call GT_Ok("wrap: replaced EVERY occurrence", getline(1,"$") ==# ["NEW 1", "NEW 2", "middle", "NEW 3", "NEW 4"], "   " . string(getline(1,"$")))
call GT_Ok("wrap: said it went on from the top", g:GrooVim_GrooVimBarMsgValue =~ "from the top", "   [" . g:GrooVim_GrooVimBarMsgValue . "]")

%delete _ | call setline(1, ["nothing here", "nothing there", "target 1", "target 2"])
call cursor(1, 1)
let g:GrooVim_GrooVimBarMsgValue = ""
call feedkeys("target\<CR>Y\<CR>aa", "t")
call GrooVim_EntertainmentReplace("n")
call feedkeys("", "x")
call GT_Ok("nothing above: it does not say so", g:GrooVim_GrooVimBarMsgValue !~ "from the top", "   [" . g:GrooVim_GrooVimBarMsgValue . "]")

" ---- the cursor comes back to where it was, like in Notepad++
let g:configureGrooVim_EntertainmentReplace_Confirmation = 0
let g:configureGrooVim_EntertainmentReplace_FromCurrentPosition = 0
%delete _ | call setline(1, ["TARGET one", "two", "three TARGET", "four the end", "five"])
call cursor(4, 7)
call feedkeys("TARGET\<CR>X\<CR>", "t")
call GrooVim_EntertainmentReplace("n")
call feedkeys("", "x")
call GT_Ok("no confirmation: the cursor comes back", line(".") == 4 && col(".") == 7, "   (line " . line(".") . " col " . col(".") . ", expected 4/7)")
call GT_Ok("no confirmation: it replaced", getline(1,"$") ==# ["X one", "two", "three X", "four the end", "five"], "   " . string(getline(1,"$")))

let g:configureGrooVim_EntertainmentReplace_Confirmation = 1
let g:configureGrooVim_EntertainmentReplace_FromCurrentPosition = 1
%delete _ | call setline(1, ["TARGET one", "two", "three TARGET", "four the end", "five TARGET"])
call cursor(4, 7)
call feedkeys("TARGET\<CR>Y\<CR>aa", "t")
call GrooVim_EntertainmentReplace("n")
call feedkeys("", "x")
call GT_Ok("with confirmation: the cursor comes back", line(".") == 4 && col(".") == 7, "   (line " . line(".") . " col " . col(".") . ")")
call GT_Ok("with confirmation: replaced all of it", getline(1,"$") ==# ["Y one", "two", "three Y", "four the end", "five Y"], "   " . string(getline(1,"$")))

" ---- the scrolling comes back too ("winsaveview", not just line and column)
let g:configureGrooVim_EntertainmentReplace_Confirmation = 0
let g:configureGrooVim_EntertainmentReplace_FromCurrentPosition = 0
%delete _ | call setline(1, map(range(1,300), '"line ".v:val." TARGET"'))
call cursor(150, 3)
normal! zz
let g:GT_TOP = line("w0")
call feedkeys("TARGET\<CR>Z\<CR>", "t")
call GrooVim_EntertainmentReplace("n")
call feedkeys("", "x")
call GT_Ok("300 lines: the cursor comes back", line(".") == 150 && col(".") == 3, "   (line " . line(".") . " col " . col(".") . ")")
call GT_Ok("300 lines: the scrolling was kept", line("w0") == g:GT_TOP, "   (top " . line("w0") . ", expected " . g:GT_TOP . ")")

" ---- Ctrl-C and Ctrl-X
%delete _ | call setline(1, ["alpha beta gamma"]) | call cursor(1, 7)
execute "normal viw\<C-c>"
call GT_Ok("Ctrl-C copied the word", getreg('"') ==# "beta", "   [" . getreg('"') . "]")
call GT_Ok("Ctrl-C kept the marks of the selection", getpos("'<")[2] == 7 && getpos("'>")[2] == 10, "   ('< " . getpos("'<")[2] . " '> " . getpos("'>")[2] . ")")
%delete _ | call setline(1, ["alpha beta gamma"]) | call cursor(1, 7)
execute "normal viw\<C-x>"
call GT_Ok("Ctrl-X cut it", getline(1) ==# "alpha  gamma" && getreg('"') ==# "beta", "   [" . getline(1) . "]")

call GT_Ok("cmdheight is 1", &cmdheight == 1, "   (" . &cmdheight . ")")

call GT_Done()
