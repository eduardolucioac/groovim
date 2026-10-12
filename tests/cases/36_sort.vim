" Putting the selected lines in order: the sort of F2->o and the three answers
" that steer it.
"
" The three are the ones of the TextFX of Notepad++: whether the case counts,
" whether the order climbs or falls, and whether a line that repeats is kept.
" They are asked on F5->c and then [t], and this is what reads them.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

" The lines, sorted by pressing the real keys over a real selection.
func! GT_Sorted(lines, keys)
  exec "enew!"
  call setline(1, a:lines)
  call cursor(1, 1)
  call GT_Press(a:keys)
  return getline(1, "$")
endfunc

func! GT_Body()

let s:fruit = ["banana", "Abacaxi", "cereja", "banana", "abacate"]

let g:GrooVim_SortCaseSensitive = 1
let g:GrooVim_SortAscending = 1
let g:GrooVim_SortUnique = 0
call GT_Ok("climbing, and the case counts",
  \ GT_Sorted(s:fruit, "VG\<F2>o") ==# ["Abacaxi", "abacate", "banana", "banana", "cereja"],
  \ "   " . string(GT_Sorted(s:fruit, "VG\<F2>o")) . "   (a capital comes before a small letter)")

let g:GrooVim_SortCaseSensitive = 0
call GT_Ok("  and with the case NOT counting it reads as a word does",
  \ GT_Sorted(s:fruit, "VG\<F2>o") ==# ["abacate", "Abacaxi", "banana", "banana", "cereja"],
  \ "   " . string(GT_Sorted(s:fruit, "VG\<F2>o")))

let g:GrooVim_SortAscending = 0
call GT_Ok("  and it falls when asked to",
  \ GT_Sorted(s:fruit, "VG\<F2>o") ==# ["cereja", "banana", "banana", "Abacaxi", "abacate"],
  \ "   " . string(GT_Sorted(s:fruit, "VG\<F2>o")))

let g:GrooVim_SortAscending = 1
let g:GrooVim_SortUnique = 1
call GT_Ok("  and only one of the lines that repeat is kept",
  \ GT_Sorted(s:fruit, "VG\<F2>o") ==# ["abacate", "Abacaxi", "banana", "cereja"],
  \ "   " . string(GT_Sorted(s:fruit, "VG\<F2>o")) . "   (five lines in, four out)")

" ---- and ONLY what you selected
let g:GrooVim_SortUnique = 0
call GT_Ok("nothing outside the selection moves",
  \ GT_Sorted(s:fruit, "Vjj\<F2>o") ==# ["Abacaxi", "banana", "cereja", "banana", "abacate"],
  \ "   " . string(GT_Sorted(s:fruit, "Vjj\<F2>o")) . "   (the last two were not selected)")

" ---- a BLOCK says where the comparison starts
"
" Which is the "(at column)" of Notepad++: you order by a field and the rest of
" the line comes along with it.
let g:GrooVim_SortCaseSensitive = 1
let s:fields = ["xx-3", "yy-1", "zz-2"]
call GT_Ok("a block orders by the column it starts at",
  \ GT_Sorted(s:fields, "3l\<F2>b2j\<F2>o") ==# ["yy-1", "zz-2", "xx-3"],
  \ "   " . string(GT_Sorted(s:fields, "3l\<F2>b2j\<F2>o")) . "   (by the digit, which is in the fourth column)")
call GT_Ok("  and a plain selection orders by the whole line",
  \ GT_Sorted(s:fields, "VG\<F2>o") ==# ["xx-3", "yy-1", "zz-2"],
  \ "   " . string(GT_Sorted(s:fields, "VG\<F2>o")))

" ---- with nothing selected it says so instead of sorting the file
exec "enew!"
call setline(1, ["um", "dois"])
let g:GrooVim_GrooVimBarMsgValue = ""
call GT_Press("\<F2>o")
call GT_Ok("with nothing selected it asks for a selection",
  \ g:GrooVim_GrooVimBarMsgValue =~ "Select the lines",
  \ "   [" . g:GrooVim_GrooVimBarMsgValue . "]")
call GT_Ok("  and the file was not touched", getline(1, "$") ==# ["um", "dois"],
  \ "   " . string(getline(1, "$")) . "   (a whole file sorted by accident is not undone by one undo in your head)")

" ---- the screen that asks the three
let s:was = [g:GrooVim_SortCaseSensitive, g:GrooVim_SortAscending, g:GrooVim_SortUnique]
call feedkeys("0\<CR>0\<CR>1\<CR>\<CR>", "t")
call GrooVim_ConfigureTools()
call feedkeys("", "x")
call GT_Ok("F5->c and then [t] asks the three and takes the answers",
  \ g:GrooVim_SortCaseSensitive == 0 && g:GrooVim_SortAscending == 0 &&
  \ g:GrooVim_SortUnique == 1,
  \ "   (case " . g:GrooVim_SortCaseSensitive . ", climbing " . g:GrooVim_SortAscending .
  \ ", unique " . g:GrooVim_SortUnique . ")")
call GT_Ok("  and the settings screen offers it",
  \ GT_FunctionText("GrooVim_Configure") =~ "\\[t\\]ools" &&
  \ GT_FunctionText("GrooVim_Configure") =~ "GrooVim_ConfigureTools",
  \ "   (beside [i]ndent, [v]iew, [f]ile, [s]earch, [r]eplace and [g]eneral)")
let [g:GrooVim_SortCaseSensitive, g:GrooVim_SortAscending, g:GrooVim_SortUnique] = s:was

call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
