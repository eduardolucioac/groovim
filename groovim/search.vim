let g:tabChanged = 0
let g:block_GrooVim_HLNext = 0
highlight WhiteOnRed ctermbg=red ctermfg=white
highlight WhiteOnBlue ctermbg=blue ctermfg=white
func! GrooVim_HLNext(moveType, blinkTime, searchMoveInverter, moment) abort

  let g:GrooVim_XenPlayRunningWithSearch = 1

  if g:block_GrooVim_HLNext == 0

    if a:moment == 0

      let g:cursor_pos_last = getpos(".")

    elseif a:moment == 1

      " * System (v:searchforward) is forward!
      if v:searchforward == 1
        " n -> forward
        " N -> backward
        " * I want (g:grooVimSearchFoward) forward!
        if g:grooVimSearchFoward == 1
          " n -> n
          " N -> N
          " let l:searchMoveDirection = 1
          if a:moveType == "f"
            let l:searchMoveDirection = 1
          elseif a:moveType == "b"
            let l:searchMoveDirection = 0
          endif
        " * I want (g:grooVimSearchFoward) backward!
        elseif g:grooVimSearchFoward == 0
          " n -> N
          " N -> n
          " let l:searchMoveDirection = 0
          if a:moveType == "f"
            let l:searchMoveDirection = 0
          elseif a:moveType == "b"
            let l:searchMoveDirection = 1
          endif
        endif
      " * System (v:searchforward) is backward!
      elseif v:searchforward == 0
        " n -> backward
        " N -> forward
        " * I want (g:grooVimSearchFoward) forward!
        if g:grooVimSearchFoward == 1
          " n -> N
          " N -> n
          " let l:searchMoveDirection = 1
          if a:moveType == "f"
            let l:searchMoveDirection = 1
          elseif a:moveType == "b"
            let l:searchMoveDirection = 0
          endif
        " * I want (g:grooVimSearchFoward) backward!
        elseif g:grooVimSearchFoward == 0
          " n -> n
          " N -> N
          " let l:searchMoveDirection = 0
          if a:moveType == "f"
            let l:searchMoveDirection = 0
          elseif a:moveType == "b"
            let l:searchMoveDirection = 1
          endif
        endif
      endif

      let [bufnum, lnum, col, off] = getpos('.')
      let matchlen = strlen(matchstr(strpart(getline('.'),col-1),@/))
      let target_pat = '\c\%#'.@/

      " Note: Foward -> blink: red/Backyard -> blink: blue.
      if l:searchMoveDirection == 1
        let ring = matchadd('WhiteOnRed', target_pat, 101)
      elseif l:searchMoveDirection == 0
        let ring = matchadd('WhiteOnBlue', target_pat, 101)
      endif

      redraw
      exec 'sleep ' . float2nr(a:blinkTime * 200) . 'm'
      call matchdelete(ring)
      redraw

      let l:cursor_pos_now = getpos(".")

      let l:tabChanged = 0

      if g:searchReplace_InAllOpened == 1
        if l:searchMoveDirection == 1 && l:cursor_pos_now[1] < g:cursor_pos_last[1]
          let g:block_GrooVim_HLNext = 1
          let g:tabChanged = 1
          tabnext
        elseif l:searchMoveDirection == 0 && l:cursor_pos_now[1] > g:cursor_pos_last[1]
          let g:block_GrooVim_HLNext = 1
          let g:tabChanged = 1
          tabprev
        elseif l:cursor_pos_now[1] == g:cursor_pos_last[1] && l:cursor_pos_now[2] == g:cursor_pos_last[2]
          if l:searchMoveDirection == 1
              let g:block_GrooVim_HLNext = 1
              let g:tabChanged = 1
              tabnext
          elseif l:searchMoveDirection == 0
              let g:block_GrooVim_HLNext = 1
              let g:tabChanged = 1
              tabprev
          endif
        endif
      endif

      while g:tabChanged == 1

        " Note: Positioning in the correct window.

        call GrooVim_PutOnEditWindow()

        try
          if l:searchMoveDirection == 1
            exec "norm gg0n"
          elseif l:searchMoveDirection == 0
            exec "norm G$N"
          endif
          let g:block_GrooVim_HLNext = 0
          let g:tabChanged = 0
        catch
          if l:searchMoveDirection == 1
            tabnext
          elseif l:searchMoveDirection == 0
            tabprev
          endif
        endtry
      endwhile

    endif

  endif

endfunc

" Note: Sets the type of search to be performed depending on user choice.
let g:search_WithList = get(g:, "search_WithList", 0)
func! GrooVim_SearchWithMyOptions(mod) range abort

  let l:callGrooVim_SearchGuy = 1

  " Note: If the search with lists is enabled closes the lists and allows
  " performing the search on next call only.
  if g:GrooVim_SearchGuyEnabled == 1

    let g:matchedLinesGlobal = ""
    let g:matchedLinesGlobalNavArray = []
    let g:GrooVim_SearchGuyEnabled = 0
    let l:callGrooVim_SearchGuy = 0
    call GrooVim_TabDo("call GrooVim_SearchGuyPrepare()")

  endif

  if l:callGrooVim_SearchGuy == 1
    if g:search_WithList == 1
      call GrooVim_SearchGuy(a:mod)
    elseif g:search_WithList == 0
      call GrooVim_EasySearch(a:mod)
    endif
  endif

endfunc

" Note: Keeps the selection visible while a prompt is open. Yanking with "gvy"
" ends visual mode and the marks stop being painted, so the value offered on the
" prompt had no counterpart on the text.
"
" Note: "\%V" is the regex atom for "inside the Visual area", and it keeps
" working after visual mode ended, matching what "gv" would reselect, which is
" exactly the case here.
func! GrooVim_SelectionHighlight() abort
  try
    return matchadd("Visual", '\%V.\%V\|\%V')
  catch
    return -1
  endtry
endfunc

" Note: Where the word under the cursor begins and how long it is, which is the
" value offered when nothing is selected.
"
" Note: The boundaries come from "searchpos()" with the word atoms, and not from
" walking the string by index, because indexing a String in Vim walks BYTES and
" would cut an accented word in half.
func! GrooVim_WordUnderCursorPos() abort

  " Note: Nothing to mark if the cursor is not sitting on a word.
  if matchstr(getline("."), '\%' . col(".") . 'c.') !~ '\k'
    return []
  endif

  let l:first = searchpos('\<', 'bcn', line("."))
  let l:last = searchpos('\>', 'cn', line("."))

  if empty(l:first) || l:first[0] == 0 || empty(l:last) || l:last[0] == 0
    return []
  endif

  return [l:first[0], l:first[1], l:last[1] - l:first[1]]

endfunc

" Note: Marks whatever is being OFFERED on the prompt: the selection in visual
" mode, the word under the cursor otherwise. Same idea in both, so that the
" question always has a counterpart on the text.
func! GrooVim_OfferHighlight(mod) abort
  if a:mod == "v"
    return GrooVim_SelectionHighlight()
  endif
  let l:where = GrooVim_WordUnderCursorPos()
  if empty(l:where)
    return -1
  endif
  try
    return matchaddpos("Visual", [l:where])
  catch
    return -1
  endtry
endfunc

func! GrooVim_SelectionHighlightClear(matchId) abort
  if a:matchId > 0
    silent! call matchdelete(a:matchId)
  endif
endfunc

" Note: Searches for current selection or word under cursor.
let g:search_Direction = get(g:, "search_Direction", "f")
let g:searchReplace_CaseSensitive = get(g:, "searchReplace_CaseSensitive", 0)

" Note: The "Match whole word only" of Notepad++: with it on, "cat" stops finding
" the "cat" inside "concatenate". Off by default, like the case, and asked on the
" search screen of "F5->c" beside it.
let g:searchReplace_WholeWord = get(g:, "searchReplace_WholeWord", 0)
let g:grooVimSearchFoward = 1
func! GrooVim_EasySearch(mod) range abort

  try

  " Note: Set "hlsearch" if is off.
  if !&hlsearch
    " Note: Highlight search results.
    set hlsearch
  endif

  " Note: Set "ignorecase" if is off.
  if !&ignorecase && g:searchReplace_CaseSensitive == 0
    " Note: Case sensitive search.
    set ignorecase
  endif

  " Note: Initialize the search.
  let g:block_GrooVim_HLNext = 0

  let l:valueToSearch = ""

  if a:mod == "v"
    " Note: Preserve transfer area.
    let l:saved_reg = GrooVim_ClipGet()
    " Note: Reselect visual area and yank.
    exec "norm gvy"
    let l:valueToSearch = GrooVim_ClipGet()
  else
    let l:valueToSearch = expand("<cword>")
  endif

  if a:mod == "v"
    " Note: Preserve transfer area.
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
  " "showmode" off) and none avoided it.
  let l:selectionMatch = GrooVim_OfferHighlight(a:mod)
  redraw

  let l:valueToSearchTemp = ""

  " Note: With nothing under the cursor there is no value to offer, and asking
  " "you want to use this value?" about an empty one makes no sense.
  "
  " Note: In that case the answer is REQUIRED, and the loop is what makes the
  " word true: searching for nothing would do nothing useful anyway. Ctrl-C gets
  " you out, and it no longer leaves CommandZ blocked.
  if ("" . l:valueToSearch . "") != ""
    let l:valueToSearchTemp = input("You want to use this value (leave empty for yes)? \"" . GrooVim_SubstringToPrompt(l:valueToSearch) . "\": ")
  else
    let l:valueToSearchTemp = ""
    while ("" . l:valueToSearchTemp . "") == ""
      let l:valueToSearchTemp = input("Type a value (required): ")
    endwhile
  endif

  call GrooVim_SelectionHighlightClear(l:selectionMatch)
  let l:selectionMatch = -1

  " Note: Define search pathern automatically.
  if l:valueToSearchTemp != ""
    let l:valueToSearch = l:valueToSearchTemp
  endif

  " Note: What you actually typed, kept for the bar of the occurrences list. The
  " pattern below is the escaped form, and showing it would leak the escaping to
  " a place where you just want to read what was searched.
  let g:GrooVim_SearchGuyValue = l:valueToSearch

  let l:pattern = GrooVim_EscapeSubstituteValueToSearch(l:valueToSearch)
  let l:search_Operator = ""

  " Note: Select operation type.
  if g:search_Direction == "b" && g:grooVimSearchFowardBlock == 0
    let l:search_Operator = "?"
    let g:grooVimSearchFoward = 0
  elseif g:search_Direction == "f" || g:grooVimSearchFowardBlock == 1
    let l:search_Operator = "/"
    let g:grooVimSearchFoward = 1
  endif

  " Note: This structure was made so that the search can be executed "immediately". With
  " "feedkeys" (below) this does not happen, causing sync issues with functions that
  " depend on "GrooVim_EasySearch" function runs first.
  " Note: Works but does not allow default "backward search".

  let @/ = l:pattern
  let l:initialPos = getpos(".")

  " Note: This operation is duplicated ("feedkeys" and "exec") causing a double
  " execution of the search, but it was the only way to not have problems with "n"
  " and "N" navigating and the search with list! If not done, the highlight is lost
  " after a few movements of the cursor.
  if g:search_WithList == 0
    call feedkeys("\<Esc>" . l:search_Operator . l:pattern . "\<cr>\<Esc>" . g:cmdLineCaller . "call setpos(\".\", [" . l:initialPos[0] . ", " . l:initialPos[1] . ", " . l:initialPos[2] . ", " . l:initialPos[3] . "])|redraw!\<cr>")
  else
    call feedkeys("\<Esc>" . l:search_Operator . l:pattern . "\<cr>")
  endif

  call GrooVim_GrooVimBarMsg("You could set me using F5->c and then [s]!", 5)

  finally
    " Note: Safety net: an interruption must not leave the text painted.
    call GrooVim_SelectionHighlightClear(l:selectionMatch)
  endtry

endfunc

" Note: Organizes occurrences and navigation lists.
let g:matchedLines = ""
func! GrooVim_SearchGuyMatches(linePosition, lineValue, tab, bufferName, line, column) range abort
  if a:linePosition != ""
    let l:linePositionPrefix = "|" . a:linePosition . "|        "
    let g:matchedLines =  g:matchedLines . strpart(l:linePositionPrefix, 0, 8) . a:lineValue . "\n"
  else
    let g:matchedLines =  g:matchedLines . a:lineValue . "\n"
  endif
  if a:tab != "" && a:line != "" && a:column != ""
    call add(g:matchedLinesGlobalNavArray, a:tab . "," . a:bufferName . "," . a:line . "," . a:column)
  else
    call add(g:matchedLinesGlobalNavArray, "0")
  endif
endfunc

" Note: Performs search in multiple tabs creating lists of occurrences.
func! GrooVim_SearchGuyTraveler(mod) range abort

  " Note: Counted BEFORE knowing whether there is a match, because Notepad++ says
  " "of N searched" about every file it looked at, not only the ones that had
  " something.
  let g:GrooVim_SearchGuyFilesSearched = g:GrooVim_SearchGuyFilesSearched + 1

  let l:theresAMatch = 1

  try
    exec "norm gg0n"
  catch
    let l:theresAMatch = 0
  endtry

  if l:theresAMatch == 1

    let g:matchedLines = ""
    " let l:theresAMatch = 0
    let l:cur_pos_last = [0,0,0]

    if g:matchedLinesGlobal == ""
      call GrooVim_SearchGuyMatches("", "-------------------------------------------[ Search List ]-------------------------------------------", "", "", "", "")
    else
      call GrooVim_SearchGuyMatches("", "-----------------------------------------------------------------------------------------------------", "", "", "", "")
    endif

    call GrooVim_SearchGuyMatches("", expand('%:p'), "", "", "", "")
    call GrooVim_SearchGuyMatches("", "-----------------------------------------------------------------------", "", "", "", "")

    while (getpos(".")[1] > l:cur_pos_last[1] || (getpos(".")[1] == l:cur_pos_last[1] && getpos(".")[2] > l:cur_pos_last[2])) && l:theresAMatch == 1
      let l:cur_pos_last = getpos(".")
      " Note: The FULL path, not just the file name: with it the list can open a
      " file again after you closed it, and two files with the same name in
      " different directories stop being the same entry.
      call GrooVim_SearchGuyMatches(getpos(".")[1], getline("."), tabpagenr(), expand('%:p'), getpos(".")[1], getpos(".")[2])
      exec "norm n"
    endwhile

    let g:matchedLinesGlobal = g:matchedLinesGlobal . g:matchedLines

  endif

endfunc

" Note: Searches for current selection or word under cursor. This is the main
" method of the functionality.
let g:matchedLinesGlobal = ""
let g:matchedLinesGlobalNavArray = []
let g:GrooVim_SearchGuyEnabled = 0
let g:GrooVim_SearchGuyValue = ""
let g:GrooVim_SearchGuyFilesSearched = 0
let g:grooVimSearchFowardBlock = 0
func! GrooVim_SearchGuy(mod) range abort

  " Note: Avoid search backward.
  let g:grooVimSearchFowardBlock = 1

  let l:searchMoveInverterHolder = getpos(".")

  let l:initialPos = getpos(".")

  call GrooVim_EasySearch(a:mod)

  let g:matchedLinesGlobal = ""
  let g:block_GrooVim_HLNext = 1
  let g:matchedLinesGlobalNavArray = []
  let g:GrooVim_SearchGuyEnabled = 0
  let g:GrooVim_SearchGuyFilesSearched = 0

  if g:searchReplace_InAllOpened == 1
    call GrooVim_TabDo("call GrooVim_SearchGuyTraveler(\"" . a:mod . "\")")
  else
    call GrooVim_SearchGuyTraveler(a:mod)
  endif

  let g:block_GrooVim_HLNext = 0
  let g:GrooVim_SearchGuyEnabled = 1

  call setpos(".", l:initialPos)

  call GrooVim_SearchGuySync()

  " Note: This "workaround" is to prevent a side effect that occurs when script
  " changing tab which that is the loss of search highlight. The presence of redraw
  " serves to remove the message generated by "set hlsearch".
  " call feedkeys("\<Esc>" . g:cmdLineCaller . "set hlsearch\<cr>\<Esc>" . g:cmdLineCaller . "redraw!\<cr>")

  let g:grooVimSearchFowardBlock = 0

  if g:search_Direction == "b"
    let g:grooVimSearchFoward = 0
  elseif g:search_Direction == "f"
    let g:grooVimSearchFoward = 1
  endif

  call GrooVim_GrooVimBarMsg("Use Enter or double click to navigate!", 4)

endfunc

" Note: Serves to synchronize in others tabs certain "states"! Always runs when a tab is accessed.
autocmd! TabEnter * call GrooVim_TabParadise()
func! GrooVim_TabParadise() abort
  " Note: If there is a search list this list is open in the current tab if the
  " functionality is enabled.
  "
  " Note: Through a timer because "tabnew {file}" fires "TabEnter" BEFORE the file
  " is loaded: building the list right here put it in a window that the file then
  " landed on top of, and the tab ended up with the file twice and no list. The
  " timer runs once the tab has settled.
  "
  " Note: Not while navigating, which puts the list in place by itself at the
  " moment it knows the tab is ready.
  if g:GrooVim_SearchGuyBusy == 0 &&
   \ g:GrooVim_SearchGuyEnabled == 1 && g:searchReplace_InAllOpened == 1
    call timer_start(0, "GrooVim_SearchGuySyncNow")
  endif
endfunc


" Note: Every occurrence of a word, marked -- the "Style all occurrences of
" token" of Notepad++.
"
" Note: "matchadd" and NOT the search register: this does not move the cursor,
" does not touch what "n" would find next, and does not turn the search
" highlight on. You can mark a name and go on searching for something else, which
" is the whole point of marking it.
"
" Note: A match belongs to a WINDOW, so it is put up again whenever you enter
" one. Otherwise splitting, or walking to another tab, would lose it -- and a
" mark you have to make again in every window is not worth making.
let g:GrooVim_MarkedWord = ""
let s:markIds = {}

highlight GrooVimMark ctermbg=148 ctermfg=232 guibg=#afd700 guifg=#080808
if &t_Co < 256 && !has("gui_running")
  highlight GrooVimMark ctermbg=green ctermfg=black
endif

" Note: What to mark: the selection if there is one, the word under the cursor
" otherwise -- the same two things every other command of GrooVim works on! By
" Questor
func! GrooVim_MarkWhat(mode) abort
  if a:mode ==# "v"
    let l:saved = GrooVim_ClipGet()
    exec "norm! gvy"
    let l:what = @"
    call GrooVim_ClipSet(l:saved)
    return l:what
  endif
  call GrooVim_StepOntoTheText()
  return expand("<cword>")
endfunc

func! GrooVim_MarkClear() abort
  for l:window in range(1, winnr("$"))
    let l:id = get(s:markIds, win_getid(l:window), 0)
    if l:id > 0
      silent! call matchdelete(l:id, win_getid(l:window))
    endif
  endfor
  let s:markIds = {}
  let g:GrooVim_MarkedWord = ""
endfunc

" Note: Puts the mark up in THIS window, if there is a word marked and it is not
" up here already.
func! GrooVim_MarkHere() abort

  if g:GrooVim_MarkedWord ==# "" || has_key(s:markIds, win_getid())
    return
  endif

  " Note: "\V" and every backslash escaped: a word with a "." or a "*" in it is
  " text and not a pattern. "\<" and "\>" so that "total" does not light up
  " inside "subtotal".
  let l:pattern = '\V\<' . escape(g:GrooVim_MarkedWord, '\') . '\>'
  let l:pattern = (g:searchReplace_CaseSensitive == 1 ? '\C' : '\c') . l:pattern

  try
    let s:markIds[win_getid()] = matchadd("GrooVimMark", l:pattern, -1)
  catch
  endtry
endfunc

func! GrooVim_MarkWord(mode) abort

  let l:what = GrooVim_MarkWhat(a:mode)

  if l:what ==# "" || l:what =~ "\n"
    call GrooVim_GrooVimBarMsg("There is no word here to mark!", 5)
    return
  endif

  " Note: The same word again takes the marks down. One key that marks and
  " unmarks, the way one key opens and closes the help.
  if g:GrooVim_MarkedWord ==# l:what
    call GrooVim_MarkClear()
    call GrooVim_GrooVimBarMsg("Marks cleared!", 4)
    return
  endif

  call GrooVim_MarkClear()
  let g:GrooVim_MarkedWord = l:what
  call GrooVim_MarkHere()
  call GrooVim_GrooVimBarMsg("Marked every \"" . l:what . "\"! Press again to clear!", 5)
endfunc

augroup GrooVim_Mark
  autocmd!
  autocmd WinEnter,BufWinEnter * call GrooVim_MarkHere()
augroup END
