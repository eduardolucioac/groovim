" Note: Record a macro! By Questor
func! GrooVim_XenRec() range abort

  " Note: The same keys start and stop. It used to take "F5", a whole key of its
  " own for one job, and "F5" is now the file commands! By Questor
  if reg_recording() != ""
    exec "norm! q"
    call GrooVim_XenRecTrimKey()
    call GrooVim_GrooVimBarMsg("Macro recorded! Use F2->w to run it!", 5)
    return
  endif

  call GrooVim_GrooVimBarMsg("Use F2->q again to stop the recording!", 5)
  exec "norm! qa"

endfunc

" Note: Takes the keys that STOPPED the recording off the end of it.
"
" Note: Vim records a key BEFORE the mapping decides what to do with it, so both
" the "F2" and the "q" pressed to stop land inside the macro -- and running it
" would fire CommandZ in the middle of your own keys. Measured on the register,
" the tail is "<80>k2q": the key code of "F2" and then the "q", sometimes with a
" modifier mark in front! By Questor
func! GrooVim_XenRecTrimKey() abort
  " Note: Cut at the LAST "F2", and not with a pattern of byte codes: measured,
  " "\%x80" does not match the raw byte 0x80 that the key leaves behind, because
  " on its own it is not valid UTF-8. The key itself, written as "\<F2>", carries
  " exactly the bytes to look for! By Questor
  let l:recorded = getreg("a")
  let l:where = strridx(l:recorded, "\<F2>")
  if l:where >= 0
    call setreg("a", strpart(l:recorded, 0, l:where))
  endif
endfunc

" Note: Run a macro certain number of times or repeatedly until the last line! By Questor
let g:GrooVim_XenPlayRunningWithSearch = 0
func! GrooVim_XenPlay(repeatExecution) range abort

  if a:repeatExecution == 0
    exec "norm @a"
    " Note: For unknown reasons the value of the variable "g: GrooVim_CommandZChar"
    " lost in the execution of the command, not allowing simple repetition and so
    " the workaround! By Questor
    let g:GrooVim_CommandZChar = "119"
  elseif a:repeatExecution == 1
    let g:block_GrooVim_HLNext = 1
    let g:GrooVim_XenPlayRunningWithSearch = 0
    " Note: Asked ONCE, and repeated as it is until the answer serves. It used to
    " ask again with another sentence, "use a valid one!", which threw away the
    " part that tells you about the "x" just when you most needed to read it! By
    " Questor
    let l:numberOfRepetitions = GrooVim_AskUntilValid(
     \ "Number of repetitions (use \"x\" to execute to last/first line): ",
     \ {answer -> GrooVim_IsRepetitionCount(answer)})
    " Note: Runs up to the last/first row!! By Questor
    if l:numberOfRepetitions == "x"
      " Note: "set nowrapscan" serves to avoid going back to the beginning! By Questor
      set nowrapscan
      let l:stopWhile = 0
      let l:firstExecution = 1
      let l:executionDirection = ""
      while l:stopWhile == 0
        let l:posBefore = getpos(".")
        if (l:posBefore[1] >= getpos("$")[1] || l:posBefore[1] == 1) && l:firstExecution == 0 && g:GrooVim_XenPlayRunningWithSearch == 0
          let l:stopWhile = 1
        endif

        " Note: If there are no more occurrences of a search then stops execution! By Questor
        try
          " Note: Tests if still there are occurrences! By Questor
          if l:executionDirection != "" && g:GrooVim_XenPlayRunningWithSearch == 1
            if l:executionDirection == "d"
              exec "norm n"
            endif
            if l:executionDirection == "u"
              exec "norm N"
            endif
            call setpos(".", l:posBefore)
          endif
          exec "norm @a"

        catch
          let l:stopWhile = 1
        endtry

        let l:posAfter = getpos(".")

        if l:posBefore[1] == l:posAfter[1] && l:firstExecution == 1 && g:GrooVim_XenPlayRunningWithSearch == 0

          if l:posBefore[1] != getpos("$")[1] && l:posBefore[1] != 1
            call GrooVim_GrooVimBarMsg("This macro isn't compatible with the execution that you selected. The current line will be always the same!", 4)
          endif
          let l:stopWhile = 1

        endif

        if l:executionDirection != ""
          if l:executionDirection == "d"
            if l:posBefore[1] > l:posAfter[1]
              let l:stopWhile = 1
            endif
          endif
          if l:executionDirection == "u"
            if l:posBefore[1] < l:posAfter[1]
              let l:stopWhile = 1
            endif
          endif
        endif

        if l:executionDirection == ""
          if l:posBefore[1] < l:posAfter[1] || (l:posBefore[1] == l:posAfter[1] && l:posBefore[2] < l:posAfter[2])
            let l:executionDirection = "d"
          endif
          if l:posBefore[1] > l:posAfter[1] || (l:posBefore[1] == l:posAfter[1] && l:posBefore[2] > l:posAfter[2])
            let l:executionDirection = "u"
          endif
        endif

        if l:stopWhile == 0 && g:GrooVim_GrooVimBarMsgEnabled == 0
          call GrooVim_GrooVimBarMsg("Use Ctrl+C to stop!", 1)
          " Note: The "redraw!" is to ensure that the message is displayed!! By Questor
          redraw!
        endif

        " Note: To see execution! By Questor
        redraw!

        let l:firstExecution = 0

      endwhile
      set wrapscan
    else

      " Note: Performs "n" times! The answer was already validated when it was
      " asked! By Questor
      for i in range(1, l:numberOfRepetitions)

        " Note: If there are no more occurrences of a search then stops execution! By Questor
        try
          exec "norm @a"
        catch
          let l:stopWhile = 1
        endtry

        let g:onMoveScreen = 1
        if g:GrooVim_GrooVimBarMsgEnabled == 0
          call GrooVim_GrooVimBarMsg("Use Ctrl+C to stop!", 1)
          " Note: The "redraw!" is to ensure that the message is displayed! By Questor
          redraw!
        endif
        " Note: To see execution! By Questor
        redraw!
      endfor

    endif

    " Note: For unknown reasons the value of the variable "g: GrooVim_CommandZChar"
    " lost in the execution of the command, not allowing simple repetition and so
    " the workaround! By Questor
    let g:GrooVim_CommandZChar = "101"

    let g:GrooVim_XenPlayRunningWithSearch = 0

  endif

  let g:block_GrooVim_HLNext = 0

endfunc

" Note: Duplicates the current line/selection! By Questor
" Note: "norm!" and not "norm": GrooVim remaps "p" to "P`]<Right>", which pastes
" BEFORE the cursor. Going through the mappings here made the copy land one
" character too early, turning "DUPLICAR" into "DUPLICADUPLICARR"! By Questor
" Note: The line the cursor is on, copied under itself, with the clipboard given
" back afterwards -- copying is how it is done, and it should not cost you what
" you had there.
"
" Note: A function because the dispatch spelled these three lines out TWICE, once
" for normal mode and once for insert, letter for letter! By Questor
func! GrooVim_DuplicateLine() abort
  let l:saved_reg = GrooVim_ClipGet()
  exec "norm yyo\<Esc>p"
  call GrooVim_ClipSet(l:saved_reg)
endfunc

" Note: The selection, copied under itself -- and then the key of the last command
" is FORGOTTEN, so holding the F key down does not replicate this one. A selection
" duplicated again and again, from a selection that has moved each time, is not
" what anybody means by "do that again"! By Questor
func! GrooVim_DuplicateSelection() abort
  call GrooVim_DuplicateVisualSelection()
  let g:GrooVim_CommandZChar = ""
endfunc

func! GrooVim_DuplicateVisualSelection() range abort
  let l:saved_reg = GrooVim_ClipGet()
  exec "norm! gvygv\<Esc>p"
  call GrooVim_ClipSet(l:saved_reg)
endfunc

" Note: Opens the .vimrc of GrooVim in a tab of its own! By Questor
exec "nnoremap <silent> <leader>zv :tabedit " . fnameescape(g:GrooVim_Vimrc) . "<cr>"

" Note: Reads the .vimrc again, in every tab.
"
" Note: Plain mappings with the path written in at load time, and NOT a function
" that does the work: sourcing the .vimrc redefines every function it holds, and
" Vim refuses to redefine one that is RUNNING -- "E127: Cannot redefine function
" ...: It is in use". Measured, with the reload wrapped in a function of its
" own! By Questor
exec "nnoremap <silent> <leader>zvv :tabdo source " . fnameescape(g:GrooVim_Vimrc) . "<cr>:tabfirst<cr>"

" Note: Clears the search register! By Questor
nnoremap <silent> <leader>z/ :nohlsearch<cr>


" Note: Save to disk and open in a new tab a copy of the current file! By Questor
func! GrooVim_SaveACopy() range abort

    let l:valueToPath = ""
    let l:stopWhile = 0
    while l:stopWhile == 0
      let l:valueToPath = input("PATH to save your file copy (type \"0\" to use transfer area \"" . GrooVim_SubstringToPrompt(GrooVim_ClipGet()) . "\", \"1\" to use empty, \"2\" to use current file path or enter one): ")
      if l:valueToPath == "0"
        if !empty(matchstr(GrooVim_ClipGet(), "\/$"))
          let l:stopWhile = 1
          let l:valueToPath = GrooVim_ClipGet()
        else
          call GrooVim_GrooVimBarMsg("Missing end \"/\"!", 1)
          " Note: The "redraw!" is to ensure that the message is displayed! By Questor
          redraw!
        endif
      elseif l:valueToPath == "1"
        let l:stopWhile = 1
        let l:valueToPath = ""
      elseif l:valueToPath == "2"
        let l:stopWhile = 1
        let l:valueToPath = expand("%:h") . "/"
      elseif ("" . l:valueToPath . "") != ""
        if !empty(matchstr(l:valueToPath, "\/$"))
          let l:stopWhile = 1
        else
          call GrooVim_GrooVimBarMsg("Missing end \"/\"!", 1)
          redraw!
        endif
      endif
    endwhile

    let l:definePathWarning = ""
    let l:valueToName = ""
    let l:stopWhile = 0
    while l:stopWhile == 0
      if l:valueToPath == ""
        let l:definePathWarning = " (DEFINE A PATH TOO!)"
      endif
      let l:valueToName = input("NAME of the file copy to be saved" . l:definePathWarning . ": ")
      if ("" . l:valueToName . "") != ""
        if ("" . l:valueToName . "") != expand('%:t') || l:valueToPath != expand("%:h") . "/"
          let l:stopWhile = 1
        else
          call GrooVim_GrooVimBarMsg("Same name and path as the current file!", 1)
          redraw!
        endif
      endif
    endwhile

    try
      exec "w " . l:valueToPath . l:valueToName
      exec "tabnew " . l:valueToPath . l:valueToName
      call GrooVim_GrooVimBarMsg("A file copy was created!", 1)
      redraw!
    catch
      call GrooVim_GrooVimBarMsg("The file copy can't be saved! Reason: \"" . v:exception . "\"", 1)
      redraw!
    endtry

endfunc

" Note: Saves to disk! By Questor
" Note: Saving. In visual mode what is written is the SELECTION, to a file of its
" own; anywhere else it is the file you are in! By Questor
func! GrooVim_Save(mode) abort
  if a:mode ==# "v"
    call GrooVim_VisualWrite()
  else
    write
  endif
endfunc

func! GrooVim_VisualWrite() range abort
  " Note: Write! By Questor
  exec "w"
  " Note: Reselect area! By Questor
  exec "norm gv"
endfunc

" Note: Changes to uppercase/lowercase! By Questor
" Note: Title Case: the first letter of every word up, the rest down.
"
" Note: A substitution and not an operator, because Vim has "gU" and "gu" and
" nothing for this. "\u" raises the character that follows it and "\L" lowers
" everything after, so one pass does both halves of each word.
"
" Note: "\%V" is what keeps it INSIDE the selection. A plain ":s" works on whole
" LINES, and a selection of half a line would have taken the other half with it.
" It reads the area "gv" would bring back, which is why the "<Esc>" below comes
" BEFORE the substitution and not after: the area is only written down when
" visual mode ends.
"
" Note: In normal and insert mode it is the word under the cursor, selected here
" so that the same substitution serves all three modes! By Questor
" Note: Puts the cursor ON the text of the line when it is sitting PAST it.
"
" Note: GrooVim runs with "virtualedit=onemore", so the cursor can sit one column
" beyond the last character -- which is exactly where you are after typing to the
" end of a line. There is no word there, and "iw" then took only the last letter:
" changing the case of "total" gave back "totaL". Anything that works on "the
" word under the cursor" has to step onto the text first! By Questor
func! GrooVim_StepOntoTheText() abort
  let l:width = strlen(getline("."))
  if col(".") > l:width
    call cursor(line("."), max([1, l:width]))
  endif
endfunc

" Note: The case of the word under the cursor, with the cursor left WHERE IT WAS.
"
" Note: This used to be "norm gUiwe", and the "e" walks to the end of the word --
" so changing the case of a word you were in the middle of moved you to its last
" letter. Changing the case of a word is not a movement! By Questor
func! GrooVim_CaseOfTheWord(which) abort
  let l:view = winsaveview()
  call GrooVim_StepOntoTheText()
  exec "norm! g" . a:which . "iw"
  call winrestview(l:view)
endfunc

func! GrooVim_ToTitleCase(modType) range abort

  let l:search = @/

  " Note: Where you were. The substitution below leaves the cursor on the first
  " column of the line, and selecting the word walks to its end -- neither is a
  " place you asked to go! By Questor
  let l:view = winsaveview()

  " Note: "norm!" and not "norm": GrooVim remaps "v" in normal mode, and a bare
  " "norm gv" is read through the mappings! By Questor
  if a:modType == "v"
    exec "norm! gv\<Esc>"
  else
    call GrooVim_StepOntoTheText()
    exec "norm! viw\<Esc>"
  endif

  " Note: "gdefault" INVERTS the "g" flag, and GrooVim has it on -- so the "/g"
  " below would have meant "the first word and no more". Measured: only the first
  " word of the selection changed. The counter of occurrences turns it off for
  " the same reason, and puts it back the same way! By Questor
  let l:gdefault = &gdefault
  set nogdefault
  silent! exec "'<,'>s/\\%V\\<\\(\\w\\)\\(\\w*\\)/\\u\\1\\L\\2/g"
  let &gdefault = l:gdefault

  let @/ = l:search

  if a:modType == "v"
    " Note: Repositioning on final, like the upper and lower above! By Questor
    exec "norm! gv\<Esc>"
  else
    call winrestview(l:view)
  endif

endfunc

func! GrooVim_ToUpperLower(modType) range abort
  " Note: Reselect area! By Questor
  exec "norm gv"

  if a:modType == "Upper"
    exec "norm gU"
  endif

  if a:modType == "Lower"
    exec "norm gu"
  endif

  " Note: Repositioning on final! By Questor
  exec "norm gv\<Esc>"
endfunc

" Note: Sudo to write! By Questor
"cnoremap w!! w !sudo tee % >/dev/null

