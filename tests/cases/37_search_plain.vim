" The search with NO list: what F3->f does when the occurrence list is off.
"
" The list has a case of its own (03_panel, 08_list_survives and the ones around
" them). This is the other half: no panel, the text itself, and the cursor.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

func! GT_Body()

  let g:search_WithList = 0
  let g:GrooVim_SearchGuyEnabled = 0
  exec "enew!"
  call setline(1, ["um", "dois", "maria tem", "tres", "maria de novo"])
  call cursor(1, 1)

  " ---- the search BEFORE this one stops being painted when the search opens
  "
  " "hlsearch" paints whatever is in the search register, and the register
  " outlives the session: Vim keeps it in the "viminfo" and hands it back the
  " next time GrooVim opens. So merely opening the search lit up a word searched
  " for yesterday -- measured through a terminal, with the prompt still waiting
  " for the first letter and "v:hlsearch" already 1.
  let @/ = "dois"
  set hlsearch
  call GT_Ok("setup: the search before this one is painted",
    \ v:hlsearch == 1, "   (@/ is \"" . @/ . "\")")

  call timer_start(100, {t -> GrooVim_EasySearch("n")})
  call timer_start(400, {t -> execute("let g:GT_WHILE_ASKING = v:hlsearch")})
  call timer_start(700, {t -> feedkeys("maria\<CR>", "t")})
  call GT_When('line(".") == 3 || line(".") == 5', "GT_AfterSearch")

endfunc

func! GT_AfterSearch()

  call GT_Ok("nothing is painted while the search is being typed",
    \ get(g:, "GT_WHILE_ASKING", -1) == 0,
    \ "   (v:hlsearch " . get(g:, "GT_WHILE_ASKING", -1) .
    \ ")   (the register is kept, which is what n and N walk by)")

  " ---- and the search GOES to what it found
  "
  " It used to run and then put the cursor back where it started: the matches
  " lit up and you were left standing where you were, with "n" as the only way
  " to reach the first one.
  call GT_Ok("the search goes to the first match",
    \ line(".") == 3, "   (line " . line(".") . " of [" . getline(".") . "])")
  call GT_Ok("  and it is painted now",
    \ v:hlsearch == 1 && @/ =~ "maria", "   (@/ is \"" . @/ . "\")")
  call GT_Ok("  and the cursor is not put back where it started",
    \ GT_FunctionText("GrooVim_EasySearch") !~ "setpos(\\\\\".\\\\\", \\[\" \\. l:initialPos",
    \ "   (with the LIST the cursor going back is right, and it is done there)")

  " ---- and what is not there is said, not thrown
  call cursor(1, 1)
  let g:GrooVim_GrooVimBarMsgValue = ""
  call timer_start(100, {t -> GrooVim_EasySearch("n")})
  call timer_start(400, {t -> feedkeys("zebra\<CR>", "t")})
  call GT_When('g:GrooVim_GrooVimBarMsgValue =~ "Nothing found"', "GT_AfterNothing")

endfunc

func! GT_AfterNothing()

  call GT_Ok("what is not there is said on the bar",
    \ g:GrooVim_GrooVimBarMsgValue =~ "Nothing found" &&
    \ g:GrooVim_GrooVimBarMsgValue =~ "zebra",
    \ "   [" . g:GrooVim_GrooVimBarMsgValue .
    \ "]   (Vim answers \"E486: Pattern not found\" in red)")
  call GT_Ok("  and the cursor stays where it was",
    \ line(".") == 1, "   (line " . line(".") . ")")
  call GT_Ok("  and the pattern is still the one n walks by",
    \ @/ =~ "zebra", "   [" . @/ . "]")

  let g:search_WithList = 1
  call GT_Done()

endfunc

call GT_AfterStartup("GT_Body")
