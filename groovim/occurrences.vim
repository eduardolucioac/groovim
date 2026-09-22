func! GrooVim_SearchGuySyncNow(timer) abort
  " Note: Checked again because the timer runs later and the search may have been
  " ended in the meantime! By Questor
  if g:GrooVim_SearchGuyEnabled == 1 && g:searchReplace_InAllOpened == 1
    call GrooVim_SearchGuySync()
  endif
endfunc

if g:enable_nerdtree_vim
  " Note: Opens and closes the "Nerd Tree", sharing the SAME tree between the
  " tabs. "NERDTreeMirror" is what brings the tree of another tab into this one,
  " and it complains when there is none to mirror, hence the "silent!".
  " "NERDTreeFocus" opens it if needed and puts the cursor inside it! By Questor
  "
  " Note: The state is asked to NERDTree itself instead of being remembered in a
  " variable of ours: closing the tree with "q" would desync such a variable and
  " the next call would refuse to reopen! By Questor
  func! GrooVim_NERDTreeIsOpen()
    if !exists("g:NERDTree")
      return 0
    endif
    try
      return g:NERDTree.ExistsForTab() && g:NERDTree.IsOpen()
    catch
      return 0
    endtry
  endfunc

  " Note: Is there a tree in ANY tab to be mirrored? Asking first avoids the
  " "No trees to mirror" notice that NERDTree prints on every first open! By Questor
  " Note: Does THIS tab already own a tree, open or merely closed? By Questor
  func! GrooVim_NERDTreeExistsForTab()
    if !exists("g:NERDTree")
      return 0
    endif
    try
      return g:NERDTree.ExistsForTab()
    catch
      return 0
    endtry
  endfunc

  func! GrooVim_NERDTreeExistsAnywhere()
    for l:buffer in range(1, bufnr("$"))
      if bufexists(l:buffer) && bufname(l:buffer) =~ "NERD_tree_"
        return 1
      endif
    endfor
    return 0
  endfunc

  func! GrooVim_ToggleNERDTreeTabs()

    " Note: NERDTree draws its window by editing a buffer, and Vim reports that
    " as "N fewer lines". Raising "report" while it works keeps the bar quiet! By Questor
    let l:reportSaved = &report
    set report=9999

    try

    if GrooVim_NERDTreeIsOpen()
      silent! NERDTreeClose
    else
      " Note: Mirror only when the tree to be shared comes from ANOTHER tab. If
      " this tab already owns one (it was merely closed), "NERDTreeFocus" brings
      " it back and asking to mirror would only print a notice! By Questor
      if !GrooVim_NERDTreeExistsForTab() && GrooVim_NERDTreeExistsAnywhere()
        silent! NERDTreeMirror
      endif
      silent! NERDTreeFocus
    endif

    finally
      let &report = l:reportSaved
    endtry

  endfunc
endif

" Note: When entering a tab opens the occurrences list if the search with list
" is enabled! By Questor
func! GrooVim_SearchGuySync() abort
  if bufexists("GrooVim_SearchGuyResults" . tabpagenr()) == 0

    call GrooVim_PutOnEditWindow()

    " Note: "setlocal" and NOT "set": on an option that belongs to a buffer or a
    " window, ":set" writes the local value AND the global default, so a "set
    " noma" here would lock EVERY buffer opened afterwards. Measured: open the
    " help once and the next empty buffer answers "E21: Cannot make changes,
    " 'modifiable' is off" over a command that was not changing anything. The
    " "set cursorline" leaked the same way, over the "set nocursorline" GrooVim
    " sets on purpose! By Questor
    setlocal ma
    exec "set splitbelow"
    silent exec "split GrooVim_SearchGuyResults" . tabpagenr()
    exec "put =g:matchedLinesGlobal"
    setlocal cursorline
    " Note: "norm!" and not "norm": the list turns off the editing keys with
    " buffer mappings, and without the "!" this code would run through them and
    " do something else entirely! By Questor
    exec "norm! ggdd"
    setlocal noma nomodified
    call GrooVim_SearchGuyPanelSetup()
  endif
endfunc

" Note: Turns the window into what it really is: a list you read and navigate,
" never one you type into.
"
" Note: Written for the occurrence list and used by the list of marks too. What
" is here is what ANY panel of GrooVim needs -- a buffer that is not a file, that
" cannot be typed into, and where every key that would change text does nothing.
" What each panel puts on top of it is its own: the bar it writes and what Enter
" does on a line! By Questor
func! GrooVim_PanelSetup() abort

  " Note: "nofile" and "nobuflisted" so the list does not behave like a file you
  " forgot to save: it was showing up as modified and listed in ":ls"! By Questor
  setlocal buftype=nofile
  " Note: "wipe" so the list dies together with its window. Kept around, the old
  " buffer made "bufexists()" say there was already a list in a tab that had
  " none, and no new one was built! By Questor
  setlocal bufhidden=wipe
  setlocal noswapfile
  setlocal nobuflisted

  " Note: And no vertical edge. It marks where a line of text gets too long,
  " which means nothing in a list whose lines are as long as they need to be.
  "
  " Note: Said HERE and not left to the rule that draws it. That rule runs on
  " entering a window and asks whether the buffer is a file -- and when it runs,
  " the window has just been split and the buffer is still an ordinary one: what
  " makes it a panel is this very function, a moment later. So the panel takes
  " the line off itself, which holds whatever order things happen in! By Questor
  setlocal colorcolumn=

  " Note: The buffer is already "nomodifiable", so these keys could only produce
  " an "E21" error. Turned off, they simply do nothing.
  "
  " Note: The rule is the same in both modes: what would CHANGE the text is off,
  " what reads, moves or copies stays. So "y", the arrows, "PageUp"/"PageDown"
  " and "Alt" with the arrows are all left alone, and so is the visual mode:
  " selecting a result and copying it is useful!
  "
  " Note: The list is not only the obvious letters. GrooVim gives a conventional
  " editor meaning to keys that Vim does not touch, and several of them end up
  " editing: "Shift-Up" is "i", "Ctrl-V" pastes, "Ctrl-X" cuts the selection,
  " and "Enter", "Del" and "Backspace" delete what is selected! By Questor
  let l:offOnNormal = ["i", "I", "a", "A", "o", "O", "s", "S", "c", "C",
                    \ "r", "R", "x", "X", "d", "D", "p", "P", "u", "U",
                    \ "J", "~", "gi", "gI", "gR", "gJ", "gp", "gP",
                    \ "gu", "gU", "g~", "<Del>", "<BS>", "<S-Up>", "<C-V>"]

  let l:offOnVisual = ["i", "a", "s", "S", "c", "C", "r", "R", "x", "X",
                    \ "d", "D", "p", "P", "u", "U", "J", "~", "gJ", "gp",
                    \ "gP", "gu", "gU", "g~", "gq", "<", ">", "=",
                    \ "<Del>", "<BS>", "<S-Up>", "<Enter>", "<C-V>", "<C-X>"]

  for l:key in l:offOnNormal
    exec "nnoremap <buffer> <silent> " . l:key . " <Nop>"
  endfor

  for l:key in l:offOnVisual
    exec "xnoremap <buffer> <silent> " . l:key . " <Nop>"
  endfor

  call GrooVim_PanelColours()

endfunc

" Note: A panel is not a file, and reading one as if it were leaves a wall of one
" colour. What is in it has SHAPE: a heading, the name of a file, the rules that
" separate one file from the next, the number of each line and the arrow on the
" one you came from -- and each of those is worth its own colour, the way the
" results of Notepad++ are.
"
" Note: The rules are put on the BUFFER and not on a file type of its own: a
" panel is built and filled by GrooVim, so there is nothing to detect and nobody
" else to hand this to.
"
" Note: "default link" so that a colour scheme can say otherwise, and to the
" groups Vim already has: what is a file name here is what a file name is
" anywhere, and a scheme that knows about "Directory" already knows what to do
" with it! By Questor
func! GrooVim_PanelColours() abort

  syntax clear

  " Note: The heading BEFORE the plain rule: Vim takes the first item that
  " matches at a place, and a heading is a rule with a name in the middle of
  " it! By Questor
  syntax match GrooVimPanelTitle "^-\+\[ .\{-} \]-\+$"
  syntax match GrooVimPanelRule "^-\+$"
  syntax match GrooVimPanelFile "^/.*$"
  syntax match GrooVimPanelHere "^->"
  syntax match GrooVimPanelWhere "|\d\+|"

  highlight default link GrooVimPanelTitle Statement
  highlight default link GrooVimPanelRule Comment
  highlight default link GrooVimPanelFile Directory
  " Note: Yellow letters and nothing behind them. It was linked to "Todo", which
  " is yellow the other way round -- dark letters on a yellow band -- and a band
  " on the line you came from shouts where a mark only has to point! By Questor
  highlight default GrooVimPanelHere ctermfg=yellow guifg=#ffff60
  highlight default link GrooVimPanelWhere Number

endfunc

" Note: And what the occurrence list puts on top of it: the bar it writes, and
" what Enter does on a line! By Questor
func! GrooVim_SearchGuyPanelSetup() abort

  call GrooVim_PanelSetup()

  " Note: The bar of the list says what Notepad++ says on its "Search results":
  " the value, the hits, the files. Line, column and percentage mean nothing
  " here! By Questor
  let &l:statusline = "%!GrooVim_SearchGuyBar()"

  " Note: "Enter" to jump to the occurrence, which is what the key means
  " everywhere else in a list. A double click does the same! By Questor
  nnoremap <buffer> <silent> <Enter> :call GrooVim_SearchGuyNavigate()<cr>
  nnoremap <buffer> <silent> <2-LeftMouse> :call GrooVim_SearchGuyNavigate()<cr>

endfunc

" Note: "Search \"value\" (N hits in M files of K searched)", the way Notepad++
" reports it. Everything comes from the navigation array that was already being
" built: an entry is either an occurrence ("tab,file,line,column") or a "0" for
" the separators and the file names! By Questor
func! GrooVim_SearchGuyBar() abort

  let l:hits = 0
  let l:files = {}
  for l:entry in g:matchedLinesGlobalNavArray
    if l:entry != "0"
      let l:hits = l:hits + 1
      let l:entryParts = split(l:entry, ",")
      let l:files[l:entryParts[0] . "," . l:entryParts[1]] = 1
    endif
  endfor

  " Note: "%" starts a format item in a status line, so a searched value carrying
  " one has to be doubled or the bar would eat it! By Questor
  let l:value = substitute(g:GrooVim_SearchGuyValue, "%", "%%", "g")

  return "Search \"" . l:value . "\" (" .
    \ l:hits . " hit" . (l:hits == 1 ? "" : "s") . " in " .
    \ len(l:files) . " file" . (len(l:files) == 1 ? "" : "s") . " of " .
    \ g:GrooVim_SearchGuyFilesSearched . " searched)"

endfunc

" Note: Walks the windows of the CURRENT tab looking for one, and says whether it
" found it. The name is a pattern for the list and an exact full path for a file!
" By Questor
func! GrooVim_PanelFocus(name, byPath) abort
  for l:window in range(1, winnr("$"))
    exec l:window . "wincmd w"
    if a:byPath
      if expand('%:p') ==# a:name
        return 1
      endif
    elseif expand('%:t') =~ a:name
      return 1
    endif
  endfor
  return 0
endfunc

" Note: Whether this tab holds any document of yours, or only accessories! By
" Questor
func! GrooVim_SearchGuyTabHasFile() abort
  for l:buffer in tabpagebuflist(tabpagenr())
    if !GrooVim_IsHelperBuffer(bufname(l:buffer))
      return 1
    endif
  endfor
  return 0
endfunc

" Note: The same thing across every tab, because a file can be open somewhere
" else than where it was when the search ran! By Questor
func! GrooVim_SearchGuyFindFile(path) abort
  let l:tabNow = tabpagenr()
  for l:tab in range(1, tabpagenr("$"))
    exec "tabn " . l:tab
    if GrooVim_PanelFocus(a:path, 1)
      return 1
    endif
  endfor
  exec "tabn " . l:tabNow
  return 0
endfunc

" Note: The list is an accessory of the tab, not a window in its own right: once
" the file is closed there is nothing left to navigate FROM, so it must not keep
" the tab open by itself. This is what NERDTree does with its own window.
"
" Note: The "Busy" guard is because navigating walks through windows and tabs,
" and passing through a tab must not close it! By Questor
let g:GrooVim_SearchGuyBusy = 0
" Note: Only the occurrences list, on purpose. NERDTree has its own rule for its
" own window and two rules pulling the same window would fight! By Questor
func! GrooVim_SearchGuyCloseIfAlone() abort
  if g:GrooVim_SearchGuyBusy == 0 && winnr("$") == 1 &&
   \ bufname("%") =~ "GrooVim_SearchGuyResults"
    " Note: Through a timer because Vim refuses to change the window layout from
    " inside this autocmd ("E1312"). The timer runs right after it, already
    " outside! By Questor
    call timer_start(0, "GrooVim_SearchGuyCloseNow")
  endif
endfunc

func! GrooVim_SearchGuyCloseNow(timer) abort
  " Note: Checked again because the timer runs later and the window may already
  " have company by then! By Questor
  "
  " Note: Only while there are OTHER tabs. Closing the last file leaves the list
  " alone on the last tab and it STAYS there, the way the "Search results" panel
  " of Notepad++ outlives the documents: your results are what you reopen the
  " interesting files from. To leave, quit from the list itself -- it is the last
  " window by then, so Vim closes as usual! By Questor
  if tabpagenr("$") > 1 && winnr("$") == 1 &&
   \ bufname("%") =~ "GrooVim_SearchGuyResults"
    quit
  endif
endfunc

" Note: The list is not a window you close by itself. Quitting from inside it
" quits the FILE instead: the cursor is moved to the file window before ":q"
" runs, so it is the file that closes. From there the rule above decides -- with
" other tabs the list is left alone and the tab goes, and on the last tab the
" list stays, waiting for you to reopen whatever interests you.
"
" Note: One rule instead of a list of cases. Quitting from the list and quitting
" from the file now do exactly the same thing, and ":q" on a list that is alone
" is a plain last window, which closes Vim as always.
"
" Note: Only a new search (F3->f) ends the list itself, and it ends
" it in every tab! By Questor
func! GrooVim_SearchGuyQuitPre() abort
  if bufname("%") =~ "GrooVim_SearchGuyResults" && GrooVim_SearchGuyTabHasFile()
    call timer_start(0, "GrooVim_SearchGuyQuitTheFile")
  endif
endfunc

" Note: By the time this runs the ":q" already closed the LIST window -- Vim
" quits the window that was current when the command was typed, and moving the
" cursor from inside "QuitPre" does not change that. So the list is put back and
" the file is closed instead, which is the same as if you had typed ":q" over the
" file. The list buffer is "wipe", so it really was gone and "Sync" builds a new
" one! By Questor
func! GrooVim_SearchGuyQuitTheFile(timer) abort
  if GrooVim_SearchGuyTabHasFile()
    call GrooVim_SearchGuySync()
    if GrooVim_SearchGuyPutOnFileWindow()
      quit
    endif
  endif
endfunc

" Note: Goes to a window holding a document of yours, if this tab has one.
" Returns 1 when it got there! By Questor
func! GrooVim_SearchGuyPutOnFileWindow() abort
  for l:window in range(1, winnr("$"))
    if !GrooVim_IsHelperBuffer(expand('%:t'))
      return 1
    endif
    exec "wincmd w"
  endfor
  return 0
endfunc

" Note: In a group of its own, because there are "autocmd!" for "WinEnter *"
" further down that would wipe it! By Questor
augroup GrooVim_SearchGuyGroup
  autocmd!
  autocmd WinEnter * call GrooVim_SearchGuyCloseIfAlone()
  autocmd QuitPre * call GrooVim_SearchGuyQuitPre()
augroup END

" Note: Jumps to the occurrence of the line under the cursor! By Questor
func! GrooVim_SearchGuyNavigate() range abort

  " Note: The list navigation is always forward to facilitate! By Questor
  let g:grooVimSearchFoward = 1

  let l:listPosLinCol = getpos(".")
  let l:listPosLinToArray = (l:listPosLinCol[1] - 1)
  if l:listPosLinToArray >= 0 && g:matchedLinesGlobalNavArray[l:listPosLinToArray] != 0

    " Note: An entry is "tab,path,line,column". Read from the ENDS because a path
    " is allowed to carry a comma of its own! By Questor
    let l:entry = split(g:matchedLinesGlobalNavArray[l:listPosLinToArray], ",")
    let l:entryTab = l:entry[0]
    let l:entryLine = l:entry[-2]
    let l:entryColumn = l:entry[-1]
    let l:entryPath = join(l:entry[1:-3], ",")

    let g:GrooVim_SearchGuyBusy = 1
    try

      if l:entryTab <= tabpagenr("$")
        exec "tabn " . l:entryTab
      endif

      " Note: Only if this tab still has a list. Rebuilding it is what puts the
      " "->" on the line you are jumping from! By Questor
      if GrooVim_PanelFocus("GrooVim_SearchGuyResults", 0)
        setlocal ma
        " Note: "norm!" for the same reason as in "GrooVim_SearchGuySync()":
        " these run inside the list, where "d", "i" and friends are mapped to
        " nothing! By Questor
        exec "norm! ggdG"
        exec "put =g:matchedLinesGlobal"
        exec "norm! ggdd"
        call setpos(".", l:listPosLinCol)
        exec "norm! 0i->"
        setlocal noma nomodified
      endif

      " Note: The file may not be open any more, and it may have moved to another
      " tab. Notepad++ opens the document again when you click a result of a file
      " that is not open, and this does the same.
      "
      " Note: This used to be a "while" pressing "<C-w>" until the name matched.
      " With the file closed the name never came and Vim froze! By Questor
      if !GrooVim_SearchGuyFindFile(l:entryPath)
        if GrooVim_SearchGuyTabHasFile()
          exec "tabnew " . fnameescape(l:entryPath)
        else
          " Note: The tab holds nothing but the list -- you closed everything and
          " kept the results. The file joins it right here, above the list, so the
          " results stay where they are instead of being left behind in a tab of
          " their own! By Questor
          call GrooVim_PanelFocus("GrooVim_SearchGuyResults", 0)
          exec "aboveleft split " . fnameescape(l:entryPath)
        endif
      endif

      " Note: The tab you land on gets its list, whether the file was already open
      " or had to be opened again: landing without the results would leave you
      " with no way back to them! By Questor
      if g:GrooVim_SearchGuyEnabled == 1 && g:searchReplace_InAllOpened == 1
        call GrooVim_SearchGuySync()
        " Note: "Sync" leaves you inside the list it has just built, so come back
        " to the file before placing the cursor on the occurrence! By Questor
        call GrooVim_PanelFocus(l:entryPath, 1)
      endif

      call setpos(".", [0, l:entryLine, l:entryColumn])
      exec "norm \<Left>n"

    finally
      let g:GrooVim_SearchGuyBusy = 0
    endtry

  endif

  if g:search_Direction == "b"
    let g:grooVimSearchFoward = 0
  elseif g:search_Direction == "f"
    let g:grooVimSearchFoward = 1
  endif

endfunc

" Note: Prepare "GrooVim_SearchGuy()" for a new run or closes it! By Questor
func! GrooVim_SearchGuyPrepare() abort

  if bufexists("GrooVim_SearchGuyResults" . tabpagenr()) == 1

    try
      " Note: With this approach I can effectively "destroy" the buffer not returning
      " "false" positives on "bufexists()" above! By Questor
      exec "bwipeout! GrooVim_SearchGuyResults" . tabpagenr()
    catch

    endtry

  endif

endfunc

" Note: For debugging purposes. To stop uses "0". Allows a "stop" on the line in that
" is called and displays a message! By Questor
func! GrooVim_PauseExecution(msg) abort
  echo "msg: \"" . a:msg . "\""
  while getchar() != 48
    exec "sleep 1000m"
  endwhile
endfunc

" Note: Allows normal use of the Enter (carriage return) key in visual mode! By Questor
" Note: There used to be a "<bar>" between the delete and the insert. It produces
" a literal "|", which in normal mode means "go to column 1", so the line break
" was inserted at the START of the line instead of where the selection was! By Questor
vnoremap <silent> <Enter> "_xi<cr><Esc>

" Note: Allows "multimode" normal use (delete) of the Del key! By Questor
nnoremap <silent> <script> <Del> :call GrooVim_NormalDel()<cr>

