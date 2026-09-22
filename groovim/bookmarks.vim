"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
"BOOKMARKS
"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" Note: Lines you mark and then walk between, with a sign drawn in the margin and
" a note you can write on any of them. It is the "Search -> Bookmark" menu of
" Notepad++, and it survives closing GrooVim.
"
" Note: This was a plugin -- vim-bookmarks, of Mattes Groeger, MIT -- and it is
" where the IDEA and the shape of the commands come from. Not one line of it is
" here: it was written again on the sign API of Vim 9, which did not exist when
" that plugin was written, and the difference is not decoration. That plugin
" places its signs with "sign place ... file=", the old API with no GROUP, and
" the signs of a file went down every time another window took the focus --
" measured with ":sign place", every mark gone while the list had the focus and
" every one back on returning. A group is per buffer and belongs to whoever named
" it, so nobody else's signs are ever touched and ours are never dropped.
"
" Note: What was left behind on purpose: the integration with Unite and with
" CtrlP, the aliases of commands renamed years ago, saving per working directory,
" and moving a mark up and down a file. What came: marking, the note, walking,
" the list, clearing, and what is kept on disk! By Questor

" Note: Where the marks live, in memory. One entry per marked line:
"
"   g:GrooVim_Bookmarks["/path/file"] = [{"line": 12, "note": "", "text": "x = 1", "id": 9501}]
"
" Note: The "id" is of the SIGN, and it is good only while the buffer is loaded.
" Everything else is what goes to disk! By Questor
let g:GrooVim_Bookmarks = get(g:, "GrooVim_Bookmarks", {})

" Note: A group of our own. It is the whole reason this is written here and not
" taken from the plugin: signs of a group are addressed by buffer and by group,
" so ours are never confused with the signs of anybody else -- a linter, a
" debugger, a diff -- and never taken down with them! By Questor
let s:group = "GrooVim_Bookmarks"

let g:GrooVim_BookmarkSign = get(g:, "GrooVim_BookmarkSign", "⚑")
let g:GrooVim_BookmarkNoteSign = get(g:, "GrooVim_BookmarkNoteSign", "i")

" Note: Every sign has to be ONE cell wide. The margin is two cells and Vim puts
" a space after the sign, so a sign of two cells leaves the text of that one line
" shifted against every other line of the file. Measured on the sign the plugin
" ships, "☰": "strwidth" says 2 against 1 for the flag! By Questor
func! GrooVim_BookmarksDefine() abort
  " Note: The flag of a plain mark keeps the colour it had. The one of a line
  " with something written on it is YELLOW and says "i": it is another thing to
  " find at a glance, not the same thing in another shade! By Questor
  highlight default link GrooVim_BookmarkSignHl Identifier
  highlight GrooVim_BookmarkNoteSignHl ctermfg=yellow guifg=yellow ctermbg=NONE guibg=NONE

  " Note: And the balloon that shows what is written, in the same yellow: dark
  " letters on it, because a balloon is a piece of paper laid over the text and
  " not a hole in it! By Questor
  highlight GrooVim_BookmarkNotePopup ctermfg=black ctermbg=yellow guifg=#232629 guibg=#f6d32d
  call sign_define("GrooVim_Bookmark",
   \ {"text": strwidth(g:GrooVim_BookmarkSign) == 1 ? g:GrooVim_BookmarkSign : ">",
   \  "texthl": "GrooVim_BookmarkSignHl"})
  call sign_define("GrooVim_BookmarkNote",
   \ {"text": strwidth(g:GrooVim_BookmarkNoteSign) == 1 ? g:GrooVim_BookmarkNoteSign : "i",
   \  "texthl": "GrooVim_BookmarkNoteSignHl"})
endfunc

" Note: The file this buffer is, as a path, and an empty string when there is no
" file to speak of. A buffer with no name cannot be marked: there would be
" nothing to write down and nothing to come back to.
"
" Note: And neither can a buffer that is not a FILE. The tree, the help and the
" panels of GrooVim all have names -- "GrooVim_BookmarksList1" is a name -- so
" asking for the name was not enough: measured, a mark landed on line 1 of the
" list of marks itself, and the next time the list was built that line came back
" as a mark, with the heading of the list as its text. What tells them apart is
" "buftype", which is empty only for a real file! By Questor
func! GrooVim_BookmarksFileHere() abort
  if &buftype !=# ""
    return ""
  endif
  return expand("%:p")
endfunc

" Note: Where the marks of a file are kept, made on first use! By Questor
func! GrooVim_BookmarksOf(file) abort
  if !has_key(g:GrooVim_Bookmarks, a:file)
    let g:GrooVim_Bookmarks[a:file] = []
  endif
  return g:GrooVim_Bookmarks[a:file]
endfunc

" Note: The SIGN is the truth about which line a mark is on.
"
" Note: Insert a line above a mark and Vim moves the sign with the text; the
" number written down here does not move by itself. So before anything reads the
" marks -- to walk them, to list them, to write them down -- the numbers are read
" back from the signs of the buffer, when there IS a buffer. A file nobody has
" opened keeps the numbers it was saved with, which is all anybody knows about
" it! By Questor
func! GrooVim_BookmarksRefresh(file) abort

  let l:buffer = bufnr(a:file)
  if l:buffer < 0 || !bufloaded(l:buffer)
    return
  endif

  let l:placed = sign_getplaced(l:buffer, {"group": s:group})
  if empty(l:placed)
    return
  endif

  let l:where = {}
  for l:sign in l:placed[0].signs
    let l:where[l:sign.id] = l:sign.lnum
  endfor

  for l:one in GrooVim_BookmarksOf(a:file)
    if has_key(l:where, l:one.id)
      let l:one.line = l:where[l:one.id]
      let l:text = getbufline(l:buffer, l:one.line)
      let l:one.text = empty(l:text) ? "" : trim(l:text[0])
    endif
  endfor

endfunc

" Note: The mark of a line, or nothing! By Questor
func! GrooVim_BookmarkAt(file, line) abort
  for l:one in GrooVim_BookmarksOf(a:file)
    if l:one.line == a:line
      return l:one
    endif
  endfor
  return {}
endfunc

" Note: Draws the sign of one mark, taking down whatever was there for it. The
" sign says whether the line carries a note: two signs, so that a line with
" something written on it can be told from a line without, at a glance! By
" Questor
func! GrooVim_BookmarkSignSet(file, one) abort
  let l:buffer = bufnr(a:file)
  if l:buffer < 0 || !bufloaded(l:buffer)
    return
  endif
  if a:one.id > 0
    call sign_unplace(s:group, {"buffer": l:buffer, "id": a:one.id})
  endif
  let a:one.id = sign_place(0, s:group,
   \ a:one.note ==# "" ? "GrooVim_Bookmark" : "GrooVim_BookmarkNote",
   \ l:buffer, {"lnum": a:one.line, "priority": 10})
endfunc

" Note: Puts the signs of a file up, all of them. Called when a window shows the
" file, which is the moment the marks of a file opened again have to appear! By
" Questor
func! GrooVim_BookmarksPlace() abort
  let l:file = GrooVim_BookmarksFileHere()
  if l:file ==# "" || !has_key(g:GrooVim_Bookmarks, l:file)
    return
  endif
  let l:buffer = bufnr(l:file)
  if l:buffer < 0 || !bufloaded(l:buffer)
    return
  endif
  call sign_unplace(s:group, {"buffer": l:buffer})
  for l:one in GrooVim_BookmarksOf(l:file)
    let l:one.id = 0
    call GrooVim_BookmarkSignSet(l:file, l:one)
  endfor
endfunc

" Note: Marks the line the cursor is on, or takes the mark off it! By Questor
func! GrooVim_BookmarkToggle() abort

  let l:file = GrooVim_BookmarksFileHere()
  if l:file ==# ""
    call GrooVim_GrooVimBarMsg("This one cannot be marked: a mark needs a file to come back to!", 5)
    return
  endif

  call GrooVim_BookmarksRefresh(l:file)
  let l:one = GrooVim_BookmarkAt(l:file, line("."))

  if !empty(l:one)
    if l:one.id > 0
      call sign_unplace(s:group, {"buffer": bufnr(l:file), "id": l:one.id})
    endif
    call filter(g:GrooVim_Bookmarks[l:file], 'v:val isnot l:one')
    call GrooVim_GrooVimBarMsg("Mark taken off line " . line(".") . "!", 4)
  else
    let l:new = {"line": line("."), "note": "", "text": trim(getline(".")), "id": 0}
    call add(g:GrooVim_Bookmarks[l:file], l:new)
    call GrooVim_BookmarkSignSet(l:file, l:new)
    call GrooVim_GrooVimBarMsg("Line " . line(".") . " marked!", 4)
  endif

  call GrooVim_BookmarksSave()
  call GrooVim_BookmarkListRefresh()

endfunc

" Note: Writes a note on the line, or changes the one that is there. A line that
" was not marked gets marked: asking for a note on a line and being told to mark
" it first would be a step for nothing.
"
" Note: The note that is there comes WRITTEN in the answer, to be edited or
" accepted, and an empty answer takes the note off and leaves the mark! By
" Questor
func! GrooVim_BookmarkAnnotate() abort

  let l:file = GrooVim_BookmarksFileHere()
  if l:file ==# ""
    call GrooVim_GrooVimBarMsg("This one cannot be marked: a mark needs a file to come back to!", 5)
    return
  endif

  call GrooVim_BookmarksRefresh(l:file)
  let l:one = GrooVim_BookmarkAt(l:file, line("."))
  if empty(l:one)
    let l:one = {"line": line("."), "note": "", "text": trim(getline(".")), "id": 0}
    call add(g:GrooVim_Bookmarks[l:file], l:one)
  endif

  call GrooVim_ScreenSay("Note on line " . line(".") . ": empty takes it off and leaves the mark")
  " Note: Not through "GrooVim_ScreenAsk": that one keeps asking until the answer
  " is one of a few, and a note is whatever you want to write. What it does bring
  " is the mark that opens every section of GrooVim, and that is taken from the
  " same place it takes it from. The note that is there comes written in the
  " answer, which is the second argument of "input()"! By Questor
  let l:note = input(g:GrooVim_ScreenMark . "Note: ", l:one.note)
  echomsg "   "

  let l:one.note = l:note
  call GrooVim_BookmarkSignSet(l:file, l:one)
  call GrooVim_BookmarksSave()
  call GrooVim_GrooVimBarMsg(l:note ==# "" ? "Note taken off!" : "Note written!", 4)
  call GrooVim_BookmarkListRefresh()

endfunc

" Note: Walks to the next marked line, or to the one before, going round the ends
" of the file the way a search does! By Questor
func! GrooVim_BookmarkWalk(forward) abort

  let l:file = GrooVim_BookmarksFileHere()
  call GrooVim_BookmarksRefresh(l:file)
  let l:lines = sort(map(copy(GrooVim_BookmarksOf(l:file)), 'v:val.line'), "n")

  if empty(l:lines)
    call GrooVim_GrooVimBarMsg("No marks in this file!", 4)
    return
  endif

  let l:now = line(".")
  if a:forward
    let l:next = filter(copy(l:lines), 'v:val > l:now')
    let l:where = empty(l:next) ? l:lines[0] : l:next[0]
  else
    let l:before = filter(copy(l:lines), 'v:val < l:now')
    let l:where = empty(l:before) ? l:lines[-1] : l:before[-1]
  endif

  call cursor(l:where, 1)
  normal! ^

endfunc

" Note: The list of marks, built the way the occurrence list of F3 is built --
" the same panel, the same shape and the same keys, because a list of places in
" your files is a list of places in your files. What differs is what is listed
" and what Enter does with it.
"
" Note: It was a quickfix window before, which is what Vim offers and what that
" plugin used. A quickfix window writes on its bar the COMMAND that filled it,
" knows nothing about separating one file from another, and does not put a mark
" on the line you came from! By Questor
let s:panel = "GrooVim_BookmarksList"

" Note: Whether the list is up. It is asked for once and then belongs to every
" tab, so it cannot be "is there a window here" -- a tab that has never seen it
" has to know to get one! By Questor
let g:GrooVim_BookmarkListOpen = 0

" Note: Up while the list is being brought into line across the tabs. The pass
" that does it is a "tabdo", and entering a tab is what asks for the sync in the
" first place -- so without this the pass asks for itself, once per tab, on a
" timer that runs later and undoes what the pass had just settled. Measured: the
" cursor was put into the list as asked and then taken out of it a moment later
" by a sync nobody had asked for. The occurrence list carries a flag of its own
" for the same reason! By Questor
let s:syncing = 0
let s:lines = ""
let s:nav = []

" Note: One line of the list, and its entry in the navigation array beside it.
" An entry is "line,path" and a "0" is a line you cannot jump from -- a
" separator, the name of a file. Read from the ENDS, because a path is allowed
" to carry a comma of its own! By Questor
func! GrooVim_BookmarkPanelLine(number, text, path) abort
  if a:number > 0
    let l:prefix = "|" . a:number . "|        "
    let s:lines = s:lines . strpart(l:prefix, 0, 8) . a:text . "\n"
    call add(s:nav, a:number . "," . a:path)
  else
    let s:lines = s:lines . a:text . "\n"
    call add(s:nav, "0")
  endif
endfunc

" Note: What a marked line shows: the text of the line, and what is written on it
" after it. A line with a note is still a line, and hiding it behind the note
" leaves you reading a note with no idea where it is! By Questor
func! GrooVim_BookmarkPanelText(one) abort
  let l:text = a:one.text ==# "" ? "empty line" : a:one.text
  return a:one.note ==# "" ? l:text : l:text . " [i: " . a:one.note . "]"
endfunc

func! GrooVim_BookmarkPanelBuild() abort

  let s:lines = ""
  let s:nav = []
  let l:first = 1

  for l:file in sort(keys(g:GrooVim_Bookmarks))
    call GrooVim_BookmarksRefresh(l:file)
    let l:marks = sort(copy(GrooVim_BookmarksOf(l:file)), {a, b -> a.line - b.line})
    if empty(l:marks)
      continue
    endif
    call GrooVim_BookmarkPanelLine(0, l:first
     \ ? "-------------------------------------------[ Bookmarks ]-------------------------------------------"
     \ : "-----------------------------------------------------------------------------------------------------", "")
    let l:first = 0
    call GrooVim_BookmarkPanelLine(0, l:file, "")
    call GrooVim_BookmarkPanelLine(0, "-----------------------------------------------------------------------", "")
    for l:one in l:marks
      call GrooVim_BookmarkPanelLine(l:one.line, GrooVim_BookmarkPanelText(l:one), l:file)
    endfor
  endfor

  return !empty(s:nav)

endfunc

" Note: "Bookmarks (N marks in M files)", the way the bar of the occurrence list
" says "Search ... (N hits in M files ...)". Everything comes from the navigation
" array that was already built! By Questor
func! GrooVim_BookmarkPanelBar() abort
  let l:marks = 0
  let l:files = {}
  for l:entry in s:nav
    if l:entry !=# "0"
      let l:marks = l:marks + 1
      let l:files[join(split(l:entry, ",")[1:], ",")] = 1
    endif
  endfor
  return "Bookmarks (" . l:marks . (l:marks == 1 ? " mark in " : " marks in ") .
   \ len(l:files) . (len(l:files) == 1 ? " file)" : " files)")
endfunc

func! GrooVim_BookmarkPanelSetup() abort

  " Note: Green, which is the colour of this list -- the heading and the rules
  " both, so that the one above the file name and the one below it read as the
  " same thing. The list of the search is yellow, and that is the whole of
  " telling one from the other at a glance! By Questor
  call GrooVim_PanelSetup("Bookmark", "Comment")

  " Note: And the one colour this panel has that the other does not: what is
  " WRITTEN on a line. The same yellow as the "i" drawn in the margin, so that
  " the two are plainly the same thing said in two places! By Questor
  syntax match GrooVimPanelNote "\[i: .*\]$"
  highlight default link GrooVimPanelNote GrooVim_BookmarkNoteSignHl

  let &l:statusline = "%!GrooVim_BookmarkPanelBar()"
  nnoremap <buffer> <silent> <Enter> :call GrooVim_BookmarkNavigate()<cr>
  nnoremap <buffer> <silent> <2-LeftMouse> :call GrooVim_BookmarkNavigate()<cr>
endfunc

" Note: Every mark of every file -- and the same key takes the list away again.
"
" Note: A key that opens a list and does nothing the second time leaves you
" hunting for another one to close it. Asked for again it was FILLING the list it
" had already built, which is work nobody asked for and which spoke: "4 fewer
" lines", "5 more lines", "--No lines in buffer--" over the bar, from the very
" commands that empty and fill the buffer! By Questor
func! GrooVim_BookmarkList() abort

  " Note: Open -> closed, and in EVERY tab, not only the one you are on. It is a
  " dock and not a window of a tab: Notepad++ shows its panels beside whatever
  " document you are looking at, and the occurrence list of F3 does the same.
  "
  " Note: The cursor goes back to a window with a file in it instead of being
  " left wherever the closing happened to leave it! By Questor
  if g:GrooVim_BookmarkListOpen
    let g:GrooVim_BookmarkListOpen = 0
    call GrooVim_BookmarkListEverywhere()
    call GrooVim_PutOnEditWindow()
    return
  endif


  if !GrooVim_BookmarkPanelBuild()
    call GrooVim_GrooVimBarMsg("No marks anywhere!", 4)
    return
  endif

  let g:GrooVim_BookmarkListOpen = 1
  call GrooVim_BookmarkListEverywhere()

  " Note: And the cursor goes INTO the list, because you asked for it to read it.
  " The sync leaves you where it found you -- it runs on its own, at moments
  " nobody chose -- so the one moment somebody DID choose says so here! By
  " Questor
  call GrooVim_PanelFocus(s:panel, 0)

endfunc

" Note: The pass over every tab, with the flag up so that entering each of them
" does not ask for the pass again! By Questor
func! GrooVim_BookmarkListEverywhere() abort
  let s:syncing = 1
  try
    call GrooVim_TabDo("call GrooVim_BookmarkListSync()")
  finally
    let s:syncing = 0
  endtry
endfunc

" Note: The list in front of you follows what you do to the marks. Mark a line
" with the list open and the line is in it; take the mark off and it is gone.
"
" Note: Only the tab you are on. The others are brought into line when you reach
" them, which is what the sync is for -- and walking every tab at every mark
" would be a lot of work for a list nobody is looking at! By Questor
func! GrooVim_BookmarkListRefresh() abort
  if !g:GrooVim_BookmarkListOpen
    return
  endif
  let l:back = win_getid()
  call GrooVim_BookmarkPanelBuild()
  if GrooVim_PanelFocus(s:panel, 0)
    call GrooVim_BookmarkPanelFill()
  endif
  call win_gotoid(l:back)
endfunc

" Note: Brings this tab into line with whether the list is open or not: it gets
" one if it has none, it loses the one it has, and a tab opened after the list
" was asked for gets it as it arrives.
"
" Note: One buffer PER TAB, named for it. One buffer shared by every tab would
" show the arrow of the tab you jumped from in all of them, and closing the last
" window of it would wipe what the others were showing -- which is why the
" occurrence list names its own the same way! By Questor
func! GrooVim_BookmarkListSync() abort

  " Note: Whatever this does, it leaves you where it found you.
  "
  " Note: It walks the windows of the tab to find the list, and walking them
  " MOVES you -- and this runs on its own, from a timer, at moments nobody chose:
  " entering a tab fires it, and so does the "tabdo" that brings every tab into
  " line. Measured: a mark was put on line 1 of the list itself, because the
  " timer had run during the wait for the second key of the shortcut and left the
  " cursor in the list while the key was still on its way! By Questor
  let l:back = win_getid()
  try
    call GrooVim_BookmarkListSyncHere()
  finally
    if !win_gotoid(l:back)
      call GrooVim_PutOnEditWindow()
    endif
  endtry

endfunc

func! GrooVim_BookmarkListSyncHere() abort

  let l:here = GrooVim_PanelFocus(s:panel, 0)

  if !g:GrooVim_BookmarkListOpen
    if l:here
      " Note: "silent!" because closing the LAST window of a tab is refused, and
      " being refused is the right answer there: a tab with nothing but this list
      " in it keeps it! By Questor
      silent! close
    endif
    return
  endif

  if l:here
    call GrooVim_BookmarkPanelFill()
    return
  endif

  call GrooVim_PutOnEditWindow()
  setlocal ma
  exec "set splitbelow"
  silent exec "split " . s:panel . tabpagenr()
  call GrooVim_BookmarkPanelFill()
  setlocal cursorline
  call GrooVim_BookmarkPanelSetup()

endfunc

" Note: And a tab reached later gets it too, which is the whole of being a dock.
"
" Note: Through a timer for the reason the occurrence list uses one: "tabnew
" {file}" fires "TabEnter" BEFORE the file is loaded, and building the list right
" there puts it in a window the file then lands on top of! By Questor
func! GrooVim_BookmarkListOnTab(timer) abort
  if g:GrooVim_BookmarkListOpen && !s:syncing
    call GrooVim_BookmarkListSync()
  endif
endfunc

" Note: "norm!" and not "norm": inside the panel the keys that edit are mapped to
" nothing, and without the "!" this would run through them and do nothing at
" all! By Questor
" Note: "silent" because emptying a buffer and filling it again SPEAKS -- "4
" fewer lines", "5 more lines", and "--No lines in buffer--" when it was already
" empty. None of that is news to anybody reading a list of marks! By Questor
func! GrooVim_BookmarkPanelFill() abort
  setlocal ma
  silent! exec "norm! ggdG"
  silent! exec "put =s:lines"
  silent! exec "norm! ggdd"
  setlocal noma nomodified
endfunc

" Note: Opens the marked line of the line the cursor is on -- Enter, or a double
" click, which is what the key means in every list of GrooVim.
"
" Note: And the list is built again with an "->" on the line you jumped FROM, so
" that coming back to it you can see where you were. It is what the occurrence
" list does! By Questor
func! GrooVim_BookmarkNavigate() abort

  let l:at = getpos(".")
  let l:index = l:at[1] - 1
  if l:index < 0 || l:index >= len(s:nav) || s:nav[l:index] ==# "0"
    return
  endif

  let l:entry = split(s:nav[l:index], ",")
  let l:line = l:entry[0]
  let l:path = join(l:entry[1:], ",")

  call GrooVim_BookmarkPanelFill()
  call setpos(".", l:at)
  setlocal ma
  exec "norm! 0i->"
  setlocal noma nomodified

  " Note: The file may not be open any more. Notepad++ opens the document again
  " when you click a result of a file that is not open, and this does the same --
  " above the list, so the list stays where it is! By Questor
  if !GrooVim_PanelFocus(l:path, 1)
    if GrooVim_SearchGuyTabHasFile()
      exec "tabnew " . fnameescape(l:path)
    else
      call GrooVim_PanelFocus(s:panel, 0)
      exec "aboveleft split " . fnameescape(l:path)
    endif
  endif

  call setpos(".", [0, str2nr(l:line), 1, 0])
  normal! ^

endfunc

" Note: Takes every mark off every file, and asks first! By Questor
func! GrooVim_BookmarkClearAll() abort

  let l:total = 0
  for l:file in keys(g:GrooVim_Bookmarks)
    let l:total = l:total + len(g:GrooVim_Bookmarks[l:file])
  endfor

  if l:total == 0
    call GrooVim_GrooVimBarMsg("No marks anywhere!", 4)
    return
  endif

  let l:answer = GrooVim_ScreenAsk("Take off all " . l:total . " marks, of every file " .
   \ GrooVim_OptionsToPrompt(["y", "n"], "n", ""),
   \ {answer -> answer ==# "" || answer ==# "y" || answer ==# "n"})
  echomsg "   "

  if l:answer !=# "y"
    call GrooVim_GrooVimBarMsg("Nothing taken off!", 4)
    return
  endif

  for l:buffer in range(1, bufnr("$"))
    if bufexists(l:buffer)
      call sign_unplace(s:group, {"buffer": l:buffer})
    endif
  endfor

  let g:GrooVim_Bookmarks = {}
  call GrooVim_BookmarksSave()
  call GrooVim_GrooVimBarMsg("All " . l:total . " marks taken off!", 4)
  call GrooVim_BookmarkListRefresh()

endfunc

" Note: What is kept on disk, beside the undo history and the rest of what
" GrooVim remembers.
"
" Note: As JSON, and not as a script to be executed the way that plugin wrote it.
" A file of state that is SOURCED is a file that can run anything! By Questor
func! GrooVim_BookmarksFile() abort
  return g:GrooVim_State . "/bookmarks"
endfunc

func! GrooVim_BookmarksSave() abort
  let l:keep = {}
  for l:file in keys(g:GrooVim_Bookmarks)
    call GrooVim_BookmarksRefresh(l:file)
    " Note: In the order of the file, and not in the order they were made. A file
    " of state is read by people too, and a list that jumps around is harder to
    " read than one that goes down the page! By Questor
    let l:marks = []
    for l:one in sort(copy(GrooVim_BookmarksOf(l:file)), {a, b -> a.line - b.line})
      call add(l:marks, {"line": l:one.line, "note": l:one.note, "text": l:one.text})
    endfor
    if !empty(l:marks)
      let l:keep[l:file] = l:marks
    endif
  endfor
  try
    call writefile([json_encode(l:keep)], GrooVim_BookmarksFile())
  catch
  endtry
endfunc

func! GrooVim_BookmarksLoad() abort
  let l:where = GrooVim_BookmarksFile()
  if !filereadable(l:where)
    return
  endif
  try
    let l:read = json_decode(join(readfile(l:where), ""))
  catch
    return
  endtry
  if type(l:read) != type({})
    return
  endif
  let g:GrooVim_Bookmarks = {}
  for l:file in keys(l:read)
    let l:marks = []
    for l:one in l:read[l:file]
      call add(l:marks, {"line": get(l:one, "line", 1), "note": get(l:one, "note", ""),
       \ "text": get(l:one, "text", ""), "id": 0})
    endfor
    let g:GrooVim_Bookmarks[l:file] = l:marks
  endfor
endfunc

" Note: The two keys you walk the marks with, because walking them is what you do
" over and over: "m" for the next one and "M" for the one before. F4 has what is
" not walking -- the menu of F10 and the list of F9 are written from the F keys.
"
" Note: They take the "m" that sets a mark of Vim and the "M" that jumps to the
" middle of the screen. It is a trade made with open eyes: this replaces what
" marks were FOR, with a sign you can see, a list you can walk and a file that
" survives closing GrooVim -- and ":mark a" still writes one from the command
" line. Inside NERDTree the "m" of its own menu is untouched, because a mapping
" of a BUFFER wins over a global one! By Questor
nnoremap <silent> m :call GrooVim_BookmarkWalk(1)<cr>
nnoremap <silent> M :call GrooVim_BookmarkWalk(0)<cr>

" Note: What is written on a line is SHOWN when you stand on it.
"
" Note: A note you cannot read without opening a list is half a note. The "i" in
" the margin says there is something written; this says what. It is the shape a
" linter uses to tell you what is wrong with a line, and the reason is the same:
" the place to read about a line is beside the line.
"
" Note: It goes up and comes down by itself, on the cursor moving. Only when the
" LINE changes, or walking along the same line would take it down and put it up
" again at every step.
"
" Note: And only for a file that HAS marks. This runs on every movement of the
" cursor, in every buffer, so the first thing it asks is the cheapest one there
" is -- and a file nobody has marked is out before anything else happens! By
" Questor
let s:notePopup = 0
let s:noteLine = 0

func! GrooVim_BookmarkNoteHide() abort
  if s:notePopup
    try
      call popup_close(s:notePopup)
    catch
    endtry
    let s:notePopup = 0
    let s:noteLine = 0
  endif
endfunc

func! GrooVim_BookmarkNoteShow() abort

  if !exists("*popup_atcursor")
    return
  endif

  if line(".") == s:noteLine && s:notePopup
    return
  endif
  call GrooVim_BookmarkNoteHide()

  let l:file = expand("%:p")
  if l:file ==# "" || !has_key(g:GrooVim_Bookmarks, l:file)
    return
  endif

  let l:one = GrooVim_BookmarkAt(l:file, line("."))
  if empty(l:one) || l:one.note ==# ""
    return
  endif

  let s:noteLine = line(".")
  let s:notePopup = popup_atcursor(" " . l:one.note . " ",
   \ {"highlight": "GrooVim_BookmarkNotePopup", "border": [],
   \  "borderchars": ["─", "│", "─", "│", "┌", "┐", "┘", "└"],
   \  "moved": "any", "line": "cursor+1", "close": "click"})

endfunc

" Note: The margin is always THERE, and not only when a sign is in it. With
" "auto" it appears and vanishes with the signs, and the whole text of the file
" slides two columns sideways when it does! By Questor
set signcolumn=yes

" Note: The margin is not a grey band either. The colour scheme paints
" "SignColumn" with a background of its own -- measured, "ctermbg=242" against a
" text area with none -- so an empty margin was a grey stripe down the side of
" every file! By Questor
func! GrooVim_BookmarksColours() abort
  highlight SignColumn ctermbg=NONE guibg=NONE
endfunc

augroup GrooVim_Bookmarks
  autocmd!
  autocmd BufWinEnter,BufReadPost * call GrooVim_BookmarksPlace()
  autocmd CursorMoved * call GrooVim_BookmarkNoteShow()
  autocmd TabEnter * call timer_start(0, "GrooVim_BookmarkListOnTab")
  autocmd InsertEnter,WinLeave * call GrooVim_BookmarkNoteHide()
  autocmd ColorScheme * call GrooVim_BookmarksColours() | call GrooVim_BookmarksDefine()
  autocmd VimLeavePre * call GrooVim_BookmarksSave()
augroup end

call GrooVim_BookmarksDefine()
call GrooVim_BookmarksColours()
call GrooVim_BookmarksLoad()
