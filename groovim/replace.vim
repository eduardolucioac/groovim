" Note: Treat a string and return a substring to use in prompts! By Questor
func! GrooVim_SubstringToPrompt(stringToBeTreated) abort
  let l:lineSplited = split(a:stringToBeTreated, "\n")
  let l:transferAreaToShow = ""
  try
    " if len(l:lineSplited) > 1
      if strlen(l:lineSplited[0]) > 70
        let l:transferAreaToShow = l:lineSplited[0][0:70] . "..."
      else
        if len(l:lineSplited) > 1
          let l:transferAreaToShow = l:lineSplited[0] . "..."
        else
          let l:transferAreaToShow = l:lineSplited[0]
        endif
      endif
  catch

  endtry
  return l:transferAreaToShow
endfunc

" Note: Searches for current selection or word under cursor! By Questor
let g:configureGrooVim_EntertainmentReplace_Confirmation = get(g:, "configureGrooVim_EntertainmentReplace_Confirmation", 1)
let g:searchReplace_InAllOpened = get(g:, "searchReplace_InAllOpened", 0)
let g:configureGrooVim_EntertainmentReplace_AskTheValueToBeReplaced = get(g:, "configureGrooVim_EntertainmentReplace_AskTheValueToBeReplaced", 1)
let g:configureGrooVim_EntertainmentReplace_FromCurrentPosition = get(g:, "configureGrooVim_EntertainmentReplace_FromCurrentPosition", 1)
func! GrooVim_EntertainmentReplace(mod) range abort

  " Note: Where the cursor was before anything happened. Notepad++ puts the caret
  " back where it was once a "Replace All" finishes, and ":substitute" leaves it on
  " the last replaced line instead. Restored in the "finally", so an interruption
  " also brings you back. "winsaveview()" keeps the scroll position too, not only
  " the line and the column! By Questor
  let l:viewBefore = winsaveview()

  " Note: Raised for the WHOLE function, and this is the one that matters most:
  " the ":substitute" with confirmation waits for an answer per occurrence, and
  " the CapsLock timer redrawing the bar underneath was wiping the highlight of
  " the match being decided and moving the cursor off the question! By Questor
  try

  " Note: Set "ignorecase" if is off! By Questor
  if !&ignorecase && g:searchReplace_CaseSensitive == 0
    " Note: Case sensitive search! By Questor
    set ignorecase
  endif

  let l:valueToReplace = ""

  if a:mod == "v"
    " Note: Preserve transfer area! By Questor
    let l:saved_reg = GrooVim_ClipGet()
    " Note: Reselect visual area and yank! By Questor
    exec "norm gvy"
    let l:valueToReplace = GrooVim_ClipGet()
  else
    let l:valueToReplace = expand("<cword>")
  endif

  if a:mod == "v"
    " Note: Preserve transfer area! By Questor
    call GrooVim_ClipSet(l:saved_reg)
  endif

  " Note: Paints what is being offered before asking, so you SEE it: the
  " selection in visual mode, the word under the cursor otherwise.
  "
  " Note: The "redraw" is what actually paints the mark. Measured on the terminal:
  " without it NOTHING is painted while the prompt waits, in either mode. I had
  " claimed otherwise before, misled by a test that was catching the paint Vim
  " does by itself while a selection is being dragged.
  "
  " Note: The price is that in VISUAL mode the prompt then lands on the second
  " line of the command area, with a blank line above it. Four ways around it
  " were measured (no redraw, "redraw!", clearing the message first, turning
  " "showmode" off) and none avoided it! By Questor
  let l:selectionMatch = GrooVim_OfferHighlight(a:mod)
  redraw

  if g:configureGrooVim_EntertainmentReplace_AskTheValueToBeReplaced == 1
    let l:stopWhile = 0
    while l:stopWhile == 0
      " Note: With nothing under the cursor there is no value to offer, and saying
      " "empty to use \"\"" would be a lie twice over: there is no value to use,
      " and the loop around here only lets go of a NON empty answer.
      "
      " Note: "(required)" and not an instruction because it states the RULE, the
      " way the neighbouring prompts state "[in use: ...]" and "[0[default]/1]". And
      " it is true here: the loop really does enforce it! By Questor
      if ("" . l:valueToReplace . "") != ""
        let l:promptToReplace = "Value that will be REPLACED (empty to use \"" . GrooVim_SubstringToPrompt(l:valueToReplace) . "\"): "
      else
        let l:promptToReplace = "Value that will be REPLACED (required): "
      endif
      let l:valueToReplaceTemp = (input(l:promptToReplace))
      if ("" . l:valueToReplaceTemp . "") != "" || ("" . l:valueToReplace . "") != ""
        let l:stopWhile = 1
        if l:valueToReplaceTemp != ""
          let l:valueToReplace = l:valueToReplaceTemp
        endif
      endif
    endwhile
  endif

  let l:valueThatWillReplace = GrooVim_EscapeSubstituteReplacement(input("Value that will REPLACE \"" . GrooVim_SubstringToPrompt(l:valueToReplace) . "\" (empty to use transfer area value \"" . GrooVim_SubstringToPrompt(GrooVim_ClipGet()) . "\"): "))

  if l:valueThatWillReplace == ""
    let l:valueThatWillReplace = GrooVim_EscapeSubstituteReplacement(GrooVim_ClipGet())
  endif

  let l:valueThatWillReplace = l:valueThatWillReplace

  " Note: Cleared before the substitution, so it does not compete with the
  " "IncSearch" that marks the occurrence under decision! By Questor
  call GrooVim_SelectionHighlightClear(l:selectionMatch)
  let l:selectionMatch = -1

  let l:pattern = GrooVim_EscapeSubstituteValueToSearch(l:valueToReplace)

  let l:confirmOrNot = ""

  if g:configureGrooVim_EntertainmentReplace_Confirmation == 1
    let l:confirmOrNot = "c"
  endif

  " Note: Where the replace should begin, taken BEFORE the cursor is moved just
  " below. With the cursor on the first column, "b" jumps to the PREVIOUS line,
  " so using "." for the range made "begin from current position" start one line
  " too early and replace what was above the cursor! By Questor
  let l:startLine = line(".")

  if a:mod == "v"
    exec "norm \<Left>"
  else
    exec "norm b\<Left>"
  endif

  " Note: Tells whether the file wrapped around, so that the hint at the end of
  " this function does not overwrite a message that actually matters! By Questor
  let l:wrapped = 0

  if g:searchReplace_InAllOpened != 1
    if g:configureGrooVim_EntertainmentReplace_FromCurrentPosition == 1

      " Note: Replace begin from current position! By Questor
      try
        exec l:startLine . ",$s#" . l:pattern . "#" . l:valueThatWillReplace . "#" . l:confirmOrNot
      catch /E486/
        " Note: Nothing from here down, and the wrap below still has to run! By Questor
      endtry

      " Note: Wrap around, like Notepad++: having reached the end of the file, if
      " occurrences were left BEHIND the starting point the replace continues from
      " the top, and says so.
      "
      " Note: Only WITH confirmation. Without it there is nobody to warn and
      " nothing to decide, so wrapping would simply replace everything, which is
      " what turning "begin from current position" OFF already does. Keeping the
      " option meaningful means that, without confirmation, it does exactly what
      " it says: from the cursor down! By Questor
      if l:startLine > 1 && g:configureGrooVim_EntertainmentReplace_Confirmation == 1
        let l:leftBehind = GrooVim_CountOccurrences(l:pattern, 1, l:startLine - 1)
        if l:leftBehind > 0
          let l:wrapped = l:leftBehind
          call GrooVim_GrooVimBarMsg("Reached the end of the file: continuing from the top (" . l:leftBehind . " to go)!", 6)
          " Note: The message has to reach the screen BEFORE the confirmation
          " prompts start, otherwise you would be answering them without knowing
          " that the file wrapped around! By Questor
          redraw
          try
            exec "1," . (l:startLine - 1) . "s#" . l:pattern . "#" . l:valueThatWillReplace . "#" . l:confirmOrNot
          catch /E486/
          endtry
        endif
      endif

    else
      exec "%s#" . l:pattern . "#" . l:valueThatWillReplace . "#" . l:confirmOrNot
    endif
  else
    " Note: "let g:tryCathOnTabDo = 1" -> If there is no value to replace in one
    " of the tabs, the process do not raises an error! By Questor
    let g:tryCathOnTabDo = 1
    let g:keepCursorOnTabDo = 1
    try
      call GrooVim_TabDo("%s#" . l:pattern . "#" . l:valueThatWillReplace . "#" . l:confirmOrNot)
    finally
      let g:tryCathOnTabDo = 0
      let g:keepCursorOnTabDo = 0
    endtry
  endif

  if l:wrapped > 0
    " Note: What actually happened matters more than the hint below! By Questor
    call GrooVim_GrooVimBarMsg("Reached the end of the file: " . l:wrapped . " occurrence(s) replaced from the top!", 6)
  else
    call GrooVim_GrooVimBarMsg("You could set me using F5->c and then [r]!", 5)
  endif

  finally
    " Note: Safety net: an interruption must not leave the text painted! By Questor
    call GrooVim_SelectionHighlightClear(l:selectionMatch)
    " Note: Back to where you were, like Notepad++! By Questor
    call winrestview(l:viewBefore)
  endtry

endfunc

" Note: How many times a pattern appears in a range, without changing anything.
" The "n" flag of ":substitute" only reports the count.
"
" Note: "gdefault" is turned off while counting because it INVERTS the meaning of
" the "g" flag: with it on, "g" would ask for only the FIRST match per line and
" the count would come out short! By Questor
func! GrooVim_CountOccurrences(pattern, firstLine, lastLine) abort

  if a:pattern == "" || a:firstLine > a:lastLine || a:firstLine < 1
    return 0
  endif

  let l:gdefaultSaved = &gdefault
  let l:report = ""

  try
    set nogdefault
    redir => l:report
    silent exec a:firstLine . "," . a:lastLine . "s#" . a:pattern . "##gn"
  catch
    " Note: No match at all raises E486, and zero is the right answer! By Questor
  finally
    redir END
    let &gdefault = l:gdefaultSaved
  endtry

  return str2nr(matchstr(l:report, '\d\+'))

endfunc

" Note: Create a search pattern! The "/" is escaped because it separates a
" search command and the "#" because it separates a ":substitute" command! By Questor
"
" Note: And the whole word, when it is asked for: "\<" and "\>" are the edges of
" a word to Vim, so "cat" stops finding the "cat" inside "concatenate". It is the
" "Match whole word only" of Notepad++.
"
" Note: HERE and not at each caller, because this one function is where the
" search and the replace both build what they look for -- one place, and the two
" of them agree by construction.
"
" Note: The edges only mean something beside a letter, a digit or an underscore.
" Asking for the whole word of "a+b" builds a pattern that matches nothing, and
" that is what Notepad++ does with it too! By Questor
func! GrooVim_EscapeSubstituteValueToSearch(valueToTreat) abort
  let l:pattern = escape(a:valueToTreat, '\\/.*$^~[]#')
  let l:pattern = substitute(l:pattern, "\n$", "", "")
  if g:searchReplace_WholeWord == 1 && l:pattern != ""
    let l:pattern = '\<' . l:pattern . '\>'
  endif
  return l:pattern
endfunc

" Note: Create a ":substitute" REPLACEMENT value! The special chars here are not
" the same of a pattern: "&" means the whole match and "~" the previous
" replacement. The "#" is the separator we use! By Questor
func! GrooVim_EscapeSubstituteReplacement(valueToTreat) abort
  let l:replacement = escape(a:valueToTreat, '\\&~#')
  let l:replacement = substitute(l:replacement, "\n$", "", "")
  return l:replacement
endfunc

" Note: Allows a "super leader" that fires in any mode! With this approach I can map a
" larger amount of keys combinations! Note the use of the keys z, a and t in leader
" commands required for certain worarounds! By Questor

nnoremap <silent> <script> <F2> :call GrooVim_CommandZ("F2", "n")<cr>
inoremap <silent> <script> <F2> <C-o>:call GrooVim_CommandZ("F2", "i")<cr>
vnoremap <silent> <script> <F2> :<C-u>call GrooVim_CommandZ("F2", "v")<cr>

nnoremap <silent> <script> <F3> :call GrooVim_CommandZ("F3", "n")<cr>
inoremap <silent> <script> <F3> <C-o>:call GrooVim_CommandZ("F3", "i")<cr>
vnoremap <silent> <script> <F3> :<C-u>call GrooVim_CommandZ("F3", "v")<cr>

nnoremap <silent> <script> <F4> :call GrooVim_CommandZ("F4", "n")<cr>
inoremap <silent> <script> <F4> <C-o>:call GrooVim_CommandZ("F4", "i")<cr>
vnoremap <silent> <script> <F4> :<C-u>call GrooVim_CommandZ("F4", "v")<cr>

" Note: File commands. "F5" used to be a single key that stopped a macro
" recording; that job went back to F2->q, which now starts and stops
" with the same keys! By Questor
nnoremap <silent> <script> <F5> :call GrooVim_CommandZ("F5", "n")<cr>
inoremap <silent> <script> <F5> <C-o>:call GrooVim_CommandZ("F5", "i")<cr>
vnoremap <silent> <script> <F5> :<C-u>call GrooVim_CommandZ("F5", "v")<cr>

" Note: The session: which files were open, in which tabs, with which layout.
"
" Note: Saved by itself when you leave and brought back when you open GrooVim
" with no file, the way Notepad++ does. Turn it off to do it by hand instead,
" with F5->[ and F5->].
"
" Note: What it does NOT carry is unsaved text: ":mksession" writes down which
" files were open, not what you had typed into them. So closing with something
" unsaved still asks, session or no session! By Questor
let g:GrooVim_SessionAuto = get(g:, "GrooVim_SessionAuto", 1)
let g:GrooVim_SessionFile = get(g:, "GrooVim_SessionFile", g:GrooVim_State . "/session.vim")

" Note: What the session carries, and what it deliberately does NOT.
"
" Note: Out go "options" and "folds": they would bring back the settings of the
" day the session was saved, over the ones GrooVim has just set, and folds of
" files that may have changed since.
"
" Note: Out go "winsize", "winpos" and "resize" as well. They write a "set
" lines=24 columns=80" into the session and FORCE it back on the next start --
" measured, and it is why the editor opened not fitting the terminal. In a
" terminal the size belongs to the terminal! By Questor
set sessionoptions=buffers,curdir,tabpages

