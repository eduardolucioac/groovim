" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
" MACROS (AND THE CASE OF A WORD)
" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" Keys recorded and played back, the copy of a whole file, and the three cases a
" word can be written in -- UPPER, lower and Title. What they have in common is
" that each one is a small operation on text that nothing else needed to know
" about.

" $$$$$$$$$$$$$$$$$$$$$$$

" Note: Record a macro.
func! GrooVim_XenRec() range abort

  " Note: The same keys start and stop. It used to take "F5", a whole key of its
  " own for one job, and "F5" is now the file commands.
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
" Vim records a key BEFORE the mapping decides what to do with it, so both the
" "F2" and the "q" pressed to stop land inside the macro -- and running it would
" fire CommandZ in the middle of your own keys. Measured on the register, the
" tail is "<80>k2q": the key code of "F2" and then the "q", sometimes with a
" modifier mark in front.
func! GrooVim_XenRecTrimKey() abort

  " Note: Cut at the LAST "F2", and not with a pattern of byte codes: measured,
  " "\%x80" does not match the raw byte 0x80 that the key leaves behind, because
  " on its own it is not valid UTF-8. The key itself, written as "\<F2>",
  " carries exactly the bytes to look for.
  let l:recorded = getreg("a")

  let l:where = strridx(l:recorded, "\<F2>")
  if l:where >= 0
    call setreg("a", strpart(l:recorded, 0, l:where))
  endif
endfunc

" Note: Run a macro certain number of times or repeatedly until the last line.
let g:GrooVim_XenPlayRunningWithSearch = 0
func! GrooVim_XenPlay(repeatExecution) range abort

  if a:repeatExecution == 0
    exec "norm @a"

    " Note: Running a macro REPLAYS keys, F keys among them, and replaying one
    " writes over what its group was repeating. So F2 is told again that it was
    " "w" -- this very command -- or pressing F2 alone afterwards would do
    " whatever the macro happened to press last.
    call GrooVim_CommandZRemember("F2", "119")

  elseif a:repeatExecution == 1
    let g:block_GrooVim_HLNext = 1
    let g:GrooVim_XenPlayRunningWithSearch = 0

    " Note: Asked ONCE, and repeated as it is until the answer serves. It used
    " to ask again with another sentence, "use a valid one!", which threw away
    " the part that tells you about the "x" just when you most needed to read
    " it.
    let l:numberOfRepetitions = GrooVim_ScreenAsk(
     \ "Number of repetitions (use \"x\" to execute to last/first line): ",
     \ {answer -> GrooVim_IsRepetitionCount(answer)})

    " Note: Runs up to the last/first row!.
    if l:numberOfRepetitions == "x"

      " Note: "set nowrapscan" serves to avoid going back to the beginning.
      set nowrapscan

      let l:stopWhile = 0
      let l:firstExecution = 1
      let l:executionDirection = ""
      while l:stopWhile == 0
        let l:posBefore = getpos(".")
        if (l:posBefore[1] >= getpos("$")[1] || l:posBefore[1] == 1) && l:firstExecution == 0 && g:GrooVim_XenPlayRunningWithSearch == 0
          let l:stopWhile = 1
        endif

        " Note: If there are no more occurrences of a search then stops
        " execution.
        try

          " Note: Tests if still there are occurrences.
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

          " Note: The "redraw!" is to ensure that the message is displayed!.
          redraw!

        endif

        " Note: To see execution.
        redraw!

        let l:firstExecution = 0

      endwhile
      set wrapscan
    else

      " Note: Performs "n" times! The answer was already validated when it was
      " asked.
      for i in range(1, l:numberOfRepetitions)

        " Note: If there are no more occurrences of a search then stops
        " execution.
        try
          exec "norm @a"
        catch
          let l:stopWhile = 1
        endtry

        let g:onMoveScreen = 1
        if g:GrooVim_GrooVimBarMsgEnabled == 0
          call GrooVim_GrooVimBarMsg("Use Ctrl+C to stop!", 1)

          " Note: The "redraw!" is to ensure that the message is displayed.
          redraw!

        endif

        " Note: To see execution.
        redraw!

      endfor

    endif

    " Note: The same as above, for the macro that runs a number of times.
    call GrooVim_CommandZRemember("F2", "101")

    let g:GrooVim_XenPlayRunningWithSearch = 0

  endif

  let g:block_GrooVim_HLNext = 0

endfunc

" Note: Duplicates the current line/selection.
"
" "norm!" and not "norm": GrooVim remaps "p" to "P`]<Right>", which pastes
" BEFORE the cursor. Going through the mappings here made the copy land one
" character too early, turning "DUPLICAR" into "DUPLICADUPLICARR".
"
" The line the cursor is on, copied under itself, with the clipboard given back
" afterwards -- copying is how it is done, and it should not cost you what you
" had there.
"
" A function because the dispatch spelled these three lines out TWICE, once for
" normal mode and once for insert, letter for letter.
func! GrooVim_DuplicateLine() abort

  " Note: "yyp" and not "yyo<Esc>p". The "o" OPENS a line, and opening a line
  " under a comment makes Vim write the comment leader on it -- that is the "o"
  " of "formatoptions", which for a Vim file is "croql". Measured: duplicating
  " the line " uma nota do vim" gave "" uma nota do vim", with the quote
  " doubled. And it depended on the file type, because the leader does: the same
  " duplication in a python file came back clean.
  "
  " "p" puts a whole line under this one on its own. There was never any need to
  " open one first.
  "
  " The whole view and not only the cursor, so that the line you were on is
  " still the line you are on, in the same column, and the window has not moved:
  " "p" leaves the cursor on the COPY, which is not where you were.
  let l:view = winsaveview()

  let l:saved_reg = GrooVim_ClipGet()
  exec "norm! yyp"
  call winrestview(l:view)
  call GrooVim_ClipSet(l:saved_reg)

endfunc

" Note: The selection, copied under itself -- and then the key of the last
" command is FORGOTTEN, so holding the F key down does not replicate this one. A
" selection duplicated again and again, from a selection that has moved each
" time, is not what anybody means by "do that again".
func! GrooVim_DuplicateSelection() abort
  call GrooVim_DuplicateVisualSelection()
  call GrooVim_CommandZForget("F3")
endfunc

func! GrooVim_DuplicateVisualSelection() range abort

  " Note: The same as the line above it: where you were is where you stay. The
  " put leaves the cursor on the COPY, and the view is taken after the "gv"
  " because the ":" of the shortcut had already dropped the cursor on the first
  " line of the range.
  exec "norm! gv"
  let l:view = winsaveview()
  let l:saved_reg = GrooVim_ClipGet()
  exec "norm! ygv\<Esc>p"
  call winrestview(l:view)
  call GrooVim_ClipSet(l:saved_reg)

endfunc

" Note: Reads the .vimrc again, in every tab.
"
" Plain mappings with the path written in at load time, and NOT a function that
" does the work: sourcing the .vimrc redefines every function it holds, and Vim
" refuses to redefine one that is RUNNING -- "E127: Cannot redefine function
" ...: It is in use". Measured, with the reload wrapped in a function of its
" own.
exec "nnoremap <silent> <leader>zvv :tabdo source " . fnameescape(g:GrooVim_Vimrc) . "<cr>:tabfirst<cr>"

" Note: Clears the search register.
"
" And the marks with them. "Take the highlighting off" is one idea to a reader,
" not two, and having to remember which key clears which half would be a poor
" way of saying so.
nnoremap <silent> <leader>z/ :nohlsearch<bar>call GrooVim_MarkClear()<cr>

" Note: Where to put a file, asked once and used by both the copy and the
" "save as".
"
" It was written inside the copy, and the "save as" would have been the same
" forty lines a second time -- with the second one drifting from the first the
" day one of them was touched. What differs between them is one word in the
" question -- the "what", which names the copy and is left out of a plain save
" -- and what is DONE with the answer; the asking is the same.
"
" ONE question, the way every editor asks it: a name lands in the folder you
" are in, and a name with a path in front of it lands where the path says. It
" used to be two questions -- a PATH, with "0" for the transfer area, "1" for
" none and "2" for the folder of the file, then a NAME -- which is a menu to
" read through before you can answer "notes.txt".
"
" The folder you are in is written into the question, so a bare name holds no
" mystery about where it goes, and <Tab> completes paths.
"
" The name of the file you are on comes WRITTEN in the answer, ready to be
" edited or accepted -- which is what "Save a Copy As" of Notepad++ does. An
" unnamed buffer has no name to offer and starts empty, and so does a call that
" asks about ANOTHER document than the one you are on.
"
" The answer comes back as a full path. There is no way out but a valid answer
" or an Esc, which walks out of here and out of whoever called.
func! GrooVim_AskFileWhere(what, ...) abort

  let l:suggestion = a:0 > 0 ? a:1 : expand("%:t")

  while 1
    let l:head = "Filename" . (a:what ==# "" ? "" : " of the " . a:what)
    let l:room = &columns - strdisplaywidth(l:head .
     \ " (\"\") or path and filename: ") - 20
    let l:answer = GrooVim_Ask(l:head . " (\"" .
     \ GrooVim_PathShort(getcwd(), l:room) . "\") or path and filename: ",
     \ l:suggestion, "file")
    let l:answer = substitute(l:answer, "^\\s\\+\\|\\s\\+$", "", "g")

    if l:answer ==# ""
      call GrooVim_GrooVimBarMsg("A name is needed!", 1)
      redraw!
      continue
    endif

    " Note: ":p" spells the answer out whole: it stands "~" and a relative path
    " up against the folder you are in, and it ends a FOLDER with a "/", which
    " is how a folder with no file name in it is caught.
    let l:where = fnamemodify(l:answer, ":p")

    if l:where =~ "/$"
      call GrooVim_GrooVimBarMsg("\"" . l:answer . "\" is a folder, and a NAME is missing!", 1)
      redraw!
      continue
    endif
    if l:where ==# expand("%:p")
      call GrooVim_GrooVimBarMsg("Same name and path as the current file!", 1)
      redraw!
      continue
    endif

    " Note: A file that is already THERE is asked about before it is written
    " over -- "File already exists. Do you want to replace it?" , which is how
    " every editor asks. Vim refuses with "E13: File exists (add ! to
    " override)", an error about a flag of a command nobody typed, and the name
    " you spent a minute choosing is gone with it.
    "
    " A no asks for the name again instead of walking out: you came here to save
    " something, and it is not saved yet. The default is no -- the answer that
    " destroys nothing -- and whoever asked us writes with the "!" form, which
    " is what this question was asked for.
    if filereadable(l:where)
      let l:replace = GrooVim_ScreenAsk("\"" . GrooVim_PathShort(l:where, l:room) .
       \ "\" is already there. Replace it " .
       \ GrooVim_OptionsToPrompt(["y", "n"], "n", ""),
       \ {answer -> answer ==# "" || answer ==# "y" || answer ==# "n"})
      redraw!
      if l:replace !=# "y"
        continue
      endif
    endif

    return l:where
  endwhile

endfunc

" Note: Save to disk and open in a new tab a copy of the current file.
func! GrooVim_SaveACopy() range abort

  let l:where = GrooVim_AskFileWhere("copy")

  try
    exec "w! " . fnameescape(l:where)
    exec "tabnew " . fnameescape(l:where)
    call GrooVim_GrooVimBarMsg("A file copy was created!", 1)
    redraw!
  catch
    call GrooVim_GrooVimBarMsg("The file copy can't be saved! Reason: \"" . v:exception . "\"", 1)
    redraw!
  endtry

endfunc

" Note: Saves under another name and GOES ON EDITING that one, which is what
" "Save As" means everywhere. The copy of F2->y is the other half of the idea:
" it writes the file and leaves you where you were.
"
" ":saveas" is the command of Vim for exactly this -- it renames the buffer and
" writes it -- so what was open before stays on disk as it was, and the tab you
" are on is the new file from here.
func! GrooVim_SaveAs() range abort

  let l:where = GrooVim_AskFileWhere("")

  try
    exec "saveas! " . fnameescape(l:where)
    call GrooVim_GrooVimBarMsg("Saved as \"" . fnamemodify(l:where, ":t") .
     \ "\"! You are editing it now.", 4)
    redraw!
  catch
    call GrooVim_GrooVimBarMsg("It can't be saved! Reason: \"" . v:exception . "\"", 4)
    redraw!
  endtry

endfunc

" Note: Writes the file, whole, whatever mode you are in -- a selection changes
" nothing about saving, and the branch that used to be here for visual mode did
" the very same "w" as the other one.
"
" A document with NO NAME is asked where to go, which is what "save as" does and
" what every editor does with its first save. Before this it answered "E32: No
" file name" over an error of Vim, which is not an answer to give anybody.
func! GrooVim_Save() abort
  if expand("%") ==# ""
    call GrooVim_SaveAs()
    return
  endif
  write
endfunc

" Note: Puts the cursor ON the text of the line when it is sitting PAST it.
"
" GrooVim runs with "virtualedit=onemore", so the cursor can sit one column
" beyond the last character -- which is exactly where you are after typing to
" the end of a line. There is no word there, and "iw" then took only the last
" letter: changing the case of "total" gave back "totaL". Anything that works on
" "the word under the cursor" has to step onto the text first.
func! GrooVim_StepOntoTheText() abort
  let l:width = strlen(getline("."))
  if col(".") > l:width
    call cursor(line("."), max([1, l:width]))
  endif
endfunc

" Note: The case of the word under the cursor, with the cursor left WHERE IT
" WAS: changing the case of a word is not a movement.
func! GrooVim_CaseOfTheWord(which) abort
  let l:view = winsaveview()
  call GrooVim_StepOntoTheText()
  exec "norm! g" . a:which . "iw"
  call winrestview(l:view)
endfunc

" Note: Title Case: the first letter of every word up, the rest down.
"
" A substitution and not an operator, because Vim has "gU" and "gu" and nothing
" for this. "\u" raises the character that follows it and "\L" lowers everything
" after, so one pass does both halves of each word.
"
" "\%V" is what keeps it INSIDE the selection. A plain ":s" works on whole
" LINES, and a selection of half a line would have taken the other half with it.
" It reads the area "gv" would bring back, which is why the "<Esc>" below comes
" BEFORE the substitution and not after: the area is only written down when
" visual mode ends.
"
" In normal and insert mode it is the word under the cursor, selected here so
" that the same substitution serves all three modes.
func! GrooVim_ToTitleCase(modType) range abort

  let l:search = @/

  " Note: Where you were. The substitution below leaves the cursor on the first
  " column of the line, and selecting the word walks to its end -- neither is a
  " place you asked to go.
  let l:view = winsaveview()

  " Note: "norm!" and not "norm": GrooVim remaps "v" in normal mode, and a bare
  " "norm gv" is read through the mappings.
  if a:modType == "v"
    exec "norm! gv\<Esc>"
  else
    call GrooVim_StepOntoTheText()
    exec "norm! viw\<Esc>"
  endif

  " Note: "gdefault" INVERTS the "g" flag, and GrooVim has it on -- so the "/g"
  " below would have meant "the first word and no more". Measured: only the
  " first word of the selection changed. The counter of occurrences turns it off
  " for the same reason, and puts it back the same way.
  let l:gdefault = &gdefault
  set nogdefault
  silent! exec "'<,'>s/\\%V\\<\\(\\w\\)\\(\\w*\\)/\\u\\1\\L\\2/g"
  let &gdefault = l:gdefault

  let @/ = l:search

  if a:modType == "v"

    " Note: Repositioning on final, like the upper and lower above.
    exec "norm! gv\<Esc>"

  else
    call winrestview(l:view)
  endif

endfunc

" Note: Putting the selected lines IN ORDER, which is the sort of the TextFX of
" Notepad++ (inspiration) and the three answers that go with it: whether the
" case counts, whether it climbs or falls, and whether a line that repeats is
" kept. They are asked on F5->c and then |[t]| , and they are what F2->o reads.
let g:GrooVim_SortCase = get(g:, "GrooVim_SortCase", "s")
let g:GrooVim_SortOrder = get(g:, "GrooVim_SortOrder", "a")
let g:GrooVim_SortUnique = get(g:, "GrooVim_SortUnique", 1)

" Note: What a line is compared BY. From a column when a BLOCK says where to
" start looking -- which is what the "(at column)" of Notepad++ means -- and
" from the beginning when the selection is a plain one.
"
" Lowered when the case does not count, so the comparison itself is always the
" same one: "<#" and ">#", which answer the same whatever "ignorecase" is set
" to. A comparison that changes with a setting of the editor is a sort that
" changes with it.
func! GrooVim_SortKeyOf(line, column) abort
  let l:key = a:column > 1 ? strpart(a:line, a:column - 1) : a:line
  return g:GrooVim_SortCase ==# "s" ? l:key : tolower(l:key)
endfunc

" Note: The lines you have SELECTED, and only those: a sort that reaches past
" what you marked is a sort you cannot undo in your head.
"
" The order of two lines that compare the SAME is the order they were in --
" Vim sorts stably, which is what makes a sort by column leave the rest of the
" line as it found it.
func! GrooVim_SortLines() abort

  if !GrooVim_CanChange()
    return
  endif

  let l:from = line("'<")
  let l:to = line("'>")
  if l:from < 1 || l:to < l:from
    call GrooVim_GrooVimBarMsg("Select the lines you want in order first!", 5)
    return
  endif

  " Note: A BLOCK says WHERE the comparison starts; a plain selection compares
  " the whole line. Either end of the block may be the left one.
  let l:column = 1
  if visualmode() ==# "\<C-v>"
    let l:column = min([col("'<"), col("'>")])
  endif

  let l:lines = getline(l:from, l:to)
  let l:keyed = []
  for l:line in l:lines
    call add(l:keyed, [GrooVim_SortKeyOf(l:line, l:column), l:line])
  endfor

  call sort(l:keyed, {one, other -> one[0] <# other[0] ? -1 : (one[0] ># other[0] ? 1 : 0)})
  if g:GrooVim_SortOrder ==# "d"
    call reverse(l:keyed)
  endif

  " Note: The FIRST of the repeated ones stays, which after the sort is the one
  " that was highest up in the file. What repeats is decided by the key, so a
  " sort by column takes out the lines that read the same FROM that column.
  if g:GrooVim_SortUnique
    let l:seen = {}
    let l:only = []
    for l:pair in l:keyed
      if !has_key(l:seen, l:pair[0])
        let l:seen[l:pair[0]] = 1
        call add(l:only, l:pair)
      endif
    endfor
    let l:keyed = l:only
  endif

  let l:sorted = map(copy(l:keyed), "v:val[1]")
  call setline(l:from, l:sorted)

  " Note: And the lines that the unique left over are taken away. Written over
  " first and deleted afterwards, so the text never passes through a state with
  " a hole in it.
  let l:gone = len(l:lines) - len(l:sorted)
  if l:gone > 0
    silent exec (l:from + len(l:sorted)) . "," . l:to . "delete _"
  endif

  " Note: And the selection is NOT given back, which is why this one does not
  " ask for the "keepsel" the Title Case and the aligns ask for.
  "
  " The line between the two: a shortcut that leaves every line WHERE it was --
  " the case of its letters changed, its text pushed left or right -- gives the
  " selection back, because what was marked is still the same thing and you may
  " well want to do one more thing to it. A shortcut that MOVES the lines about
  " does not: after a sort the marked stretch holds other lines in another
  " order, and the unique may have left fewer of them, so what would be handed
  " back is an area that no longer means what you drew it to mean.
  "
  " The cursor stays on the first line of what was put in order, which is where
  " you look to see that it was.
  call cursor(l:from, 1)

  call GrooVim_GrooVimBarMsg(len(l:sorted) . " line(s) in order" .
   \ (l:gone > 0 ? ", and " . l:gone . " repeated one(s) taken off" : "") . "!", 4)

endfunc

" Note: Changes to uppercase/lowercase.
func! GrooVim_ToUpperLower(modType) range abort

  " Note: Reselect area.
  exec "norm gv"

  if a:modType == "Upper"
    exec "norm gU"
  endif

  if a:modType == "Lower"
    exec "norm gu"
  endif

  " Note: Repositioning on final.
  exec "norm gv\<Esc>"

endfunc

