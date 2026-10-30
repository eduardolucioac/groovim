" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
" SESSION (AND EVERY WAY OF CLOSING)
" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" What is open when you leave and what comes back when you return: the tabs, the
" files, the cursors. And the other half of it, the ways of closing -- a file, a
" tab, everything -- because what closes decides what is saved.

" $$$$$$$$$$$$$$$$$$$$$$$

" The session: which files were open, in which tabs, with which layout.
"
" Saved by itself when you leave and brought back when you open GrooVim with no
" file, the way Notepad++ (inspiration) does. Turn it off to do it by hand
" instead, with F5->[ and F5->].
"
" What it does NOT carry is unsaved text: ":mksession" writes down which files
" were open, not what you had typed into them. So closing with something unsaved
" still asks, session or no session.
let g:GrooVim_SessionAuto = get(g:, "GrooVim_SessionAuto", 1)
let g:GrooVim_SessionFile = get(g:, "GrooVim_SessionFile", g:GrooVim_State . "/session.vim")

" Note: What the session carries, and what it deliberately does NOT.
"
" Out go "options" and "folds": they would bring back the settings of the day
" the session was saved, over the ones GrooVim has just set, and folds of files
" that may have changed since.
"
" Out go "winsize", "winpos" and "resize" as well. They write a "set lines=24
" columns=80" into the session and FORCE it back on the next start -- measured,
" and it is why the editor opened not fitting the terminal. In a terminal the
" size belongs to the terminal.
set sessionoptions=buffers,curdir,tabpages

" Note: Written BESIDE the real one and moved into place, which is one rename
" and cannot be read half done.
"
" It matters because this is written on a CLOCK now and not only on the way out
" -- see the unsaved text further down -- and a crash can land in the middle of
" anything. A session half written is a session that fails to load, and that is
" the tabs of the day before gone for nothing.
func! GrooVim_SessionSave() abort

  call mkdir(fnamemodify(g:GrooVim_SessionFile, ":h"), "p")

  let l:temp = g:GrooVim_SessionFile . ".new"
  try
    exec "mksession! " . fnameescape(l:temp)
  catch
    call delete(l:temp)
    return
  endtry

  if filereadable(l:temp)
    call rename(l:temp, g:GrooVim_SessionFile)
  endif

endfunc

" Note: The directory you STARTED IN wins over the one the session remembers.
"
" A session carries the working directory it was saved in -- "mksession" writes
" a "cd" into it -- so coming back brought that directory along, and the file
" tree opened wherever you had been days ago instead of where you just ran the
" command.
"
" With a file named there was never a problem, because then no session comes
" back at all. It is the empty call -- which is exactly the one that restores --
" that had it, and the two now behave the same.
"
" Put back AFTER sourcing, and not prevented: the session names its files while
" it loads, and a directory changed under it would be a session looking for
" files that are no longer where it left them.
func! GrooVim_SessionLoad() abort

  if !filereadable(g:GrooVim_SessionFile)
    return
  endif

  let l:startedIn = getcwd()

  " Note: The rule of one tab per file is held while the session is being laid
  " out. The session is a script that makes the tabs one by one, and a tab
  " closing itself in the middle of it would leave the rest of the script
  " writing into the wrong ones. A session written by a GrooVim that has the
  " rule has no two tabs over one file to begin with.
  let l:oneWas = g:GrooVim_TabOnePerFile
  let g:GrooVim_TabOnePerFile = 0

  try
    exec "source " . fnameescape(g:GrooVim_SessionFile)
  finally
    let g:GrooVim_TabOnePerFile = l:oneWas
  endtry

  if getcwd() !=# l:startedIn && isdirectory(l:startedIn)
    exec "cd " . fnameescape(l:startedIn)
  endif

  call GrooVim_SessionDropGhosts()

endfunc

" Note: A session written days ago can name files that are not there any more --
" one that was deleted, or one under "/tmp" after the machine was restarted. Vim
" brings those back as EMPTY buffers carrying the old name, and it looks like
" the editor opened something broken.
"
" And with nothing left to show, the welcome screen comes back: an empty Vim
" that hides its own welcome looks like something went wrong.
func! GrooVim_SessionDropGhosts() abort

  for l:buffer in getbufinfo({"buflisted": 1})
    if l:buffer.name != "" && !filereadable(l:buffer.name)
      exec "silent! bwipeout! " . l:buffer.bufnr
    endif
  endfor

  for l:buffer in getbufinfo({"buflisted": 1})
    if l:buffer.name != ""
      return
    endif
  endfor

  silent! intro

endfunc

" Note: Only with no file on the command line. Opening "groovim file.txt" means
" you want THAT file, not everything you had open last time. "++nested" is what
" makes the files come back as FILES. A command run from inside an autocmd fires
" no autocmds of its own unless the autocmd asks for it, so the ":edit" written
" in the session opened every file with no "BufRead" -- and with no "BufRead"
" there is no filetype detection: measured, "&filetype" empty on a ".py" that
" opens as "python" when named on the command line. No syntax, no indent rules,
" no indent guides.
augroup GrooVim_Session
  autocmd!
  autocmd VimLeavePre * if g:GrooVim_SessionAuto == 1 | call GrooVim_SessionSave() | endif
  autocmd VimEnter * ++nested if g:GrooVim_SessionAuto == 1 && argc() == 0 |
        \ call GrooVim_SessionLoad() | endif

  " Note: And the text that was not saved comes back AFTER the session, which
  " is what opened the tabs it belongs in -- a document whose tab is already
  " there is filled in, and only one that is not gets a tab of its own.
  "
  " With a file named on the command line too, and not only on the empty call
  " the session answers to: what you have not saved is yours whichever way you
  " opened the editor.
  autocmd VimEnter * ++nested call GrooVim_UnsavedRestore()
augroup END

" Note: By hand only when it is not automatic. With the session saving itself,
" saving it again by hand would be a command that does nothing you can see -- so
" it says so instead of pretending.
func! GrooVim_SessionSaveByHand() abort
  if g:GrooVim_SessionAuto == 1
    call GrooVim_GrooVimBarMsg("The session already saves itself! Turn it off with F5->c!", 6)
    return
  endif
  call GrooVim_SessionSave()
  call GrooVim_GrooVimBarMsg("Session saved!", 5)
endfunc

func! GrooVim_SessionLoadByHand() abort
  if g:GrooVim_SessionAuto == 1
    call GrooVim_GrooVimBarMsg("The session comes back by itself! Turn it off with F5->c!", 6)
    return
  endif
  if !filereadable(g:GrooVim_SessionFile)
    call GrooVim_GrooVimBarMsg("There is no saved session yet! Save one with F5->[!", 6)
    return
  endif
  call GrooVim_SessionLoad()
endfunc

" Note: A document with CHANGES in it, about to be closed, and the question
" GrooVim asks about it instead of the dialog Vim would put up.
"
" ":confirm" of Vim asks "Save changes to "/home/.../teste.txt"? [Y]es, (N)o,
" (C)ancel" -- a line and a half of path, three answers written three different
" ways, and none of them the way anything else here is asked. And on a document
" with NO NAME its Yes has nowhere to write: a nameless buffer has no file name,
" so Vim answers "E32: No file name" and the close is given up on. A question
" whose first answer cannot be given is worse than no question.
"
" So it is asked here, before the close, and it is the same short question the
" rest of GrooVim asks -- Save "teste.txt"? , Save "new 1"? -- in the same place
" and with the same letters. A document that was never saved goes on to the one
" question of the "save as": WHERE to put it, with the folder you are in written
" in. After that there is nothing left for ":confirm" to ask. A No clears the
" "modified" flag, which is that same answer given a moment earlier, and an
" <Esc> gives the close up.
"
" The document is settled where it LIVES -- "win_execute" writes it in its own
" window, in another tab if that is where it is -- so closing a side of the tab
" line asks about each one without walking you through the tabs.
"
" The "tabs" are the ones about to go, and they are what tells a document being
" LOST from one that will still be on the screen afterwards: a window of it left
" standing outside them means nothing is being lost, and nothing is asked.
"
" It hands back 0 when nothing was settled, and then nothing is closed.
func! GrooVim_CloseSettle(buffer, tabs) abort

  if !getbufvar(a:buffer, "&modified") || getbufvar(a:buffer, "&buftype") !=# ""
    return 1
  endif

  let l:windows = win_findbuf(a:buffer)
  if empty(l:windows)
    return 1
  endif

  for l:window in l:windows
    if index(a:tabs, win_id2tabwin(l:window)[0]) < 0
      return 1
    endif
  endfor

  " Note: WHICH document, said the way the bar at the bottom says it: the whole
  " path, shortened to what is left of the line. Two files called "teste.txt" in
  " two folders are two files, and the one you are about to lose is worth
  " naming. The name of a document that was never saved is all there is of it.
  let l:nameless = bufname(a:buffer) ==# ""
  let l:tail = " " . GrooVim_OptionsToPrompt(["y", "n"], "y", "")
  let l:name = l:nameless ? GrooVim_NewNameOf(a:buffer)
   \ : GrooVim_PathShort(fnamemodify(bufname(a:buffer), ":p"),
   \   &columns - strdisplaywidth(g:GrooVim_ScreenMark . "Save \"\"" . l:tail) - 2)

  let l:answer = GrooVim_ScreenAsk("Save \"" . l:name . "\"" . l:tail,
   \ {answer -> answer ==# "" || answer ==# "y" || answer ==# "n"})

  " Note: And the question is taken off the screen. It is asked on the way OUT
  " of a document -- what comes after it is a tab closing, which draws the text
  " and the tab line again and leaves the command line alone: the question sat
  " there, answered, over whatever you went to next.
  redraw!

  if l:answer ==# "n"
    call setbufvar(a:buffer, "&modified", 0)
    return 1
  endif

  " Note: A document that has a name is written where it already is; one that
  " has none is asked about first. No name to suggest there: the one written in
  " that question is the name of the file you are ON, and this is another.
  let l:write = "write"
  if l:nameless
    let l:where = GrooVim_AskFileWhere("", "")
    let l:name = fnamemodify(l:where, ":t")
    let l:write = "saveas! " . fnameescape(l:where)
  endif

  try
    call win_execute(l:windows[0], l:write)
    call GrooVim_GrooVimBarMsg("Saved \"" . l:name . "\"! Closing it now.", 4)
  catch
    call GrooVim_GrooVimBarMsg("It can't be saved! Reason: \"" . v:exception . "\"", 4)
    redraw!
    return 0
  endtry

  redraw!
  return 1

endfunc

" Note: The same, for every document of the tabs that are about to go, asked
" before anything is closed -- half a tab line closed and then a question is no
" way to be asked anything.
func! GrooVim_CloseSettleTabs(tabs) abort
  for l:tab in a:tabs
    for l:buffer in tabpagebuflist(l:tab)
      if !GrooVim_CloseSettle(l:buffer, a:tabs)
        return 0
      endif
    endfor
  endfor
  return 1
endfunc

" Note: Closing, after asking about what would be lost. Every document going
" with it is settled first, so ":confirm" finds nothing left to ask -- it stays
" on as the backstop it is: the refusal of Vim, "E37: No write since last
" change", turned into a question instead of an error.
"
" Which tabs go depends on the command: ":tabonly" takes every OTHER one, ":qa"
" takes them all, and a ":q" takes a window -- which loses nothing while another
" window still shows the same document.
func! GrooVim_CloseAsking(command) abort

  " Note: Closing the WHOLE editor does not ask any more: what is not saved is
  " COPIED and comes back on the next start, the way Notepad++ (inspiration)
  " answers its own "x". Closing a tab or a window goes on asking, because there
  " you are throwing one document away on purpose.
  "
  " And only when the copies were really written: "GrooVim_UnsavedWrite" answers
  " 0 when one of them could not be, and then the question is still the right
  " thing to do.
  if a:command ==# "qa" && g:GrooVim_UnsavedAuto && GrooVim_UnsavedWrite()
    qa!
    return
  endif

  let l:tabs = []
  if a:command ==# "tabonly"
    let l:tabs = filter(range(1, tabpagenr("$")), "v:val != tabpagenr()")
  elseif a:command ==# "qa"
    let l:tabs = range(1, tabpagenr("$"))
  endif

  if !empty(l:tabs)
    if !GrooVim_CloseSettleTabs(l:tabs)
      return
    endif
  elseif !GrooVim_CloseSettle(bufnr("%"), [tabpagenr()])
    return
  endif

  exec "confirm " . a:command

endfunc

" Note: Closing the tab you are in. Vim REFUSES to close the last tab -- "E784:
" Cannot close last tab page" -- so on that one what closes is the DOCUMENT
" instead, leaving the empty one Notepad++ calls "new 1". ":enew" for the empty
" one, and then wiping the document that was there. ":bdelete" on its own reads
" better and is WRONG here: it hands you a fresh empty buffer only when there is
" no other buffer around, and after a few tabs have been closed there always is
" -- measured, closing the last tab showed a file closed three tabs ago instead
" of an empty page. ":enew" always opens an empty one, and the wipe is what
" keeps the closed file from lingering in the buffer list.
"
" The "confirm" is on the ":enew", which is what abandons the document, so
" unsaved text is asked about before anything happens. Answering "Cancel" leaves
" the buffer where it was, and the "if" below sees that nothing moved and wipes
" nothing.
func! GrooVim_TabClose() abort

  if tabpagenr("$") > 1
    if !GrooVim_CloseSettleTabs([tabpagenr()])
      return
    endif
    confirm tabclose
    return
  endif

  " Note: The accessories of a tab -- the occurrence list, the tree -- are not
  " documents of yours, so the closing lands on the document beside them.
  if GrooVim_IsHelperBuffer(expand("%:t"))
    call GrooVim_PutOnEditWindow()
    if GrooVim_IsHelperBuffer(expand("%:t"))
      call GrooVim_GrooVimBarMsg("There is no document here to close!", 5)
      return
    endif
  endif

  if !GrooVim_CloseSettle(bufnr("%"), [tabpagenr()])
    return
  endif

  let l:document = bufnr("%")
  confirm enew
  if bufnr("%") != l:document
    exec "silent! bwipeout " . l:document
  endif

endfunc

" Note: Closes every tab on ONE SIDE of the one you are in -- the "Close All to
" the Right" and "Close All to the Left" of the Notepad++ tab menu.
"
" One tab at a time, and always the NEIGHBOUR: closing shifts the numbers of
" every tab after it, so a list of numbers read up front would be wrong by the
" second one. Asking "who is next to me" again each round cannot go stale.
"
" It asks about unsaved text, like every other way of closing in GrooVim. And if
" you answer "Cancel" the count of tabs does not move -- which is how this knows
" to stop, instead of asking the same question for ever.
func! GrooVim_TabCloseSide(side) abort
  while 1
    let l:target = a:side > 0 ? tabpagenr() + 1 : tabpagenr() - 1
    if l:target < 1 || l:target > tabpagenr("$")
      return
    endif
    if !GrooVim_CloseSettleTabs([l:target])
      return
    endif
    let l:before = tabpagenr("$")
    exec "confirm " . l:target . "tabclose"
    if tabpagenr("$") == l:before
      return
    endif
  endwhile
endfunc


" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
" THE INBOX (A FILE HANDED TO A GrooVim ALREADY OPEN)
" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" Note: "groovim -j file" opens the file in a GrooVim that is ALREADY running
" instead of starting another one -- "just reuse an instance" -- and this is the
" half that listens.
"
" Vim has a way of its own for this, "--remote-tab", and it is not the one used
" here: it rides on "+clientserver", which on Unix means X11. Measured, and it
" works on a desktop -- the file lands in a tab of the running GrooVim. It also
" does not exist on an SSH, in a container or on a machine with no desktop,
" which is where GrooVim is at home, so taking it would have meant a feature
" that is there on the machine nobody needs it on.
"
" What is here is a MAILBOX, and it asks for nothing but a directory both sides
" can write in. Every GrooVim opens one of its own, named for the moment it
" opened and the process it is, and reads it on a clock. "groovim -j" writes the
" path of the file into the mailbox of the oldest one still alive. The name
" carries both halves because both are needed: the TIME says which GrooVim was
" there first, and the PID is how the one handing the file over finds out
" whether it is still there.
let g:GrooVim_InboxDir = get(g:, "GrooVim_InboxDir", g:GrooVim_State . "/inbox")
let g:GrooVim_InboxPollMs = get(g:, "GrooVim_InboxPollMs", 400)

func! GrooVim_InboxMine() abort
  if !exists("s:inbox")
    let s:inbox = g:GrooVim_InboxDir . "/" . localtime() . "." . getpid()
  endif
  return s:inbox
endfunc

" Note: The mailbox is opened EMPTY and on a clock of its own.
"
" A timer and not "CursorHold": that one fires once after you stop typing and
" not again until you press something, so a GrooVim left alone on a screen would
" never hear anything. A timer fires while Vim sits waiting for a key, which is
" exactly when a file handed from somewhere else should come up.
func! GrooVim_InboxOpen() abort

  if !isdirectory(g:GrooVim_InboxDir)
    silent! call mkdir(g:GrooVim_InboxDir, "p", 0700)
  endif
  if !isdirectory(g:GrooVim_InboxDir)
    return
  endif

  call writefile([], GrooVim_InboxMine())
  call timer_start(g:GrooVim_InboxPollMs, "GrooVim_InboxRead", {"repeat": -1})

endfunc

" Note: What was left in the mailbox, opened in a tab each.
"
" ":tabedit" and not a window of its own: the tab it opens is a tab of GrooVim
" like any other -- it is born at the END of the line, and a file already open
" is not opened twice, you land on the tab that has it.
"
" Nothing is opened while a QUESTION is on the screen. A tab opening under a
" prompt would take the keys it was waiting for, and the file is not going
" anywhere: the next tick of the clock finds it still there.
"
" The mailbox is taken AWAY and an empty one put in its place before a line of
" it is read. What arrives between the two is written into a file nobody reads
" again, which is one request lost; what would be lost by reading first and
" emptying afterwards is anything that arrives while the tabs are opening, which
" is a much longer moment. The name it is taken away to begins with a dot, which
" is how the other half knows it is not a mailbox.
func! GrooVim_InboxRead(timer) abort

  if g:GrooVim_Busy
    return
  endif

  let l:mine = GrooVim_InboxMine()
  if getfsize(l:mine) <= 0
    return
  endif

  let l:reading = g:GrooVim_InboxDir . "/." . getpid() . ".reading"
  if rename(l:mine, l:reading) != 0
    return
  endif
  call writefile([], l:mine)

  let l:paths = filter(readfile(l:reading), 'v:val !=# ""')
  call delete(l:reading)

  for l:path in l:paths
    try
      call GrooVim_OpenInTab(l:path)
      call GrooVim_GrooVimBarMsg("\"" . fnamemodify(l:path, ":t") .
       \ "\" was handed to this GrooVim!", 5)
    catch
      call GrooVim_GrooVimBarMsg("\"" . l:path . "\" could not be opened! Reason: \"" .
       \ v:exception . "\"", 5)
    endtry
  endfor

  redraw!

endfunc

" Note: And it is taken down on the way out, so that nobody hands a file to a
" GrooVim that is not there any more. The one left behind by a GrooVim that was
" KILLED is swept by whoever tries to use it: the process it names is asked
" whether it is alive first.
autocmd! VimLeave * call delete(GrooVim_InboxMine())

call GrooVim_InboxOpen()

" $$$$$$$$$$$$$$$$$$$$$$$

" Note: The text you had NOT saved, kept across the way out -- and across a
" crash.
"
" What the session carries is which files were open; what you had typed into
" them it cannot carry, because ":mksession" writes down names and not text. So
" closing GrooVim with something unsaved used to be a question for every
" document, and a power cut was a loss.
"
" Notepad++ (inspiration) does not ask: it keeps a COPY of every document that
" has text not yet written to disk, and on the next start the document is back
" the way you left it, still marked as not saved -- the "+" on the bar and in
" the tab line. GrooVim does the same here, with the copies in
" "~/.groovim/unsaved".
"
" It is the whole EDITOR closing that behaves this way -- F5->x, the "x" of the
" window of Notepad++. Closing a TAB is another thing and goes on asking: there
" you are throwing one document away on purpose, and nothing is coming back to
" tell you about it.
"
" The copies are written on a clock as well, and that is the half that answers a
" crash: nothing is written only on the way out, because the way out is exactly
" what a crash does not have.
let g:GrooVim_UnsavedAuto = get(g:, "GrooVim_UnsavedAuto", 1)
let g:GrooVim_UnsavedDir = get(g:, "GrooVim_UnsavedDir", g:GrooVim_State . "/unsaved")
let g:GrooVim_UnsavedEveryMs = get(g:, "GrooVim_UnsavedEveryMs", 5000)

" Note: One set of copies per GrooVim, named after the process that wrote them:
" two editors open at once would otherwise write over each other. The one a
" GrooVim leaves behind is taken over by the next one to open -- and only when
" the process that wrote it is GONE, which is what tells a GrooVim that closed
" from one that is still running beside this one.
func! GrooVim_UnsavedIndexOf(pid) abort
  return g:GrooVim_UnsavedDir . "/" . a:pid . ".index"
endfunc

func! GrooVim_UnsavedCopyOf(pid, buffer) abort
  return g:GrooVim_UnsavedDir . "/" . a:pid . "." . a:buffer . ".txt"
endfunc

" Note: Whether a process is still there. "/proc" is asked first, which is the
" machine GrooVim runs on; where there is no "/proc" the question goes to
" "kill -0", which answers without touching anything.
func! GrooVim_ProcessAlive(pid) abort

  if a:pid <= 0
    return 0
  endif

  if isdirectory("/proc/1")
    return isdirectory("/proc/" . a:pid)
  endif

  silent! call system("kill -0 " . shellescape(a:pid))
  return v:shell_error == 0

endfunc

" Note: A document of YOURS with text not yet on disk. The accessories of a tab
" -- the tree, the lists, the help -- are not documents, and a buffer that is
" not loaded has nothing to copy.
func! GrooVim_UnsavedWorth(buffer) abort
  return getbufvar(a:buffer, "&modified") && getbufvar(a:buffer, "&buftype") ==# ""
   \ && bufloaded(a:buffer) && !GrooVim_IsHelperBuffer(bufname(a:buffer))
endfunc

" Note: The copies, written. One file per document and one index naming them,
" which is what the next GrooVim reads.
"
" Answers 1 when every document that needed a copy got one -- and that is what
" the way out asks before it stops asking you about them: if a copy could not be
" written, the question is still the right thing to do.
func! GrooVim_UnsavedWrite() abort

  if !g:GrooVim_UnsavedAuto
    return 0
  endif

  if !isdirectory(g:GrooVim_UnsavedDir)
    silent! call mkdir(g:GrooVim_UnsavedDir, "p", 0700)
  endif
  if !isdirectory(g:GrooVim_UnsavedDir)
    return 0
  endif

  let l:pid = getpid()
  let l:entries = []
  let l:kept = {}
  let l:all = 1

  for l:info in getbufinfo({"buflisted": 1})

    let l:buffer = l:info.bufnr
    if !getbufvar(l:buffer, "&modified")
     \ || getbufvar(l:buffer, "&buftype") !=# ""
     \ || GrooVim_IsHelperBuffer(bufname(l:buffer))
      continue
    endif

    let l:copy = GrooVim_UnsavedCopyOf(l:pid, l:buffer)

    " Note: A document still MODIFIED and no longer LOADED is the way OUT
    " itself: Vim unloads the buffers first and fires "VimLeavePre" after, so
    " the last write of all found nothing to read -- and, finding nothing, took
    " the copies down. Measured, with one document open: everything written a
    " second earlier was gone by the time the editor was.
    "
    " The copy on disk was written while the document WAS loaded, and that copy
    " is the text. It is kept as it is, with the name and the line, which can
    " all be asked of a buffer that is not loaded.
    if !bufloaded(l:buffer)
      if !filereadable(l:copy)
        continue
      endif

    " Note: A copy is only written again when the TEXT has changed. The index
    " is written on every pass -- it carries the tab you are on, which changes
    " by walking and not by typing -- and without this every walk between tabs
    " would write every document out again.
    elseif get(s:unsavedTicks, l:buffer, -1) == l:info.changedtick
     \ && filereadable(l:copy)
    elseif writefile(getbufline(l:buffer, 1, "$"), l:copy) != 0
      let l:all = 0
      continue
    else
      let s:unsavedTicks[l:buffer] = l:info.changedtick
    endif
    let l:kept[l:copy] = 1

    " Note: The name of the file as well as its text, and the TIME the file had
    " on disk when the copy was taken: coming back, a file that somebody else
    " has written to since is worth saying out loud before your own text is put
    " over the screen.
    let l:path = bufname(l:buffer) ==# ""
     \ ? "" : fnamemodify(bufname(l:buffer), ":p")
    call add(l:entries, {
     \ "path": l:path,
     \ "name": GrooVim_NewNameOf(l:buffer),
     \ "copy": l:copy,
     \ "line": l:buffer == bufnr("%") ? line(".") : l:info.lnum,
     \ "col": l:buffer == bufnr("%") ? col(".") : 1,
     \ "disk": l:path ==# "" ? 0 : getftime(l:path)})

  endfor

  " Note: And the copies of documents that have been SAVED since -- or thrown
  " away -- are taken down, so that what is in the directory is what is really
  " waiting to come back.
  for l:old in glob(g:GrooVim_UnsavedDir . "/" . l:pid . ".*.txt", 0, 1)
    if !has_key(l:kept, l:old)
      call delete(l:old)
    endif
  endfor

  let l:index = GrooVim_UnsavedIndexOf(l:pid)
  if empty(l:entries)
    call delete(l:index)
    return l:all
  endif

  " Note: And WHICH document was in front when this was written, so that coming
  " back lands on the tab you were on and not on the last one that happened to
  " be filled in. It is written whether that document has text to keep or not --
  " you can close GrooVim standing on a file you had just saved, with what is
  " not saved waiting in another tab.
  if writefile([json_encode({"here": GrooVim_UnsavedHereNow(),
   \ "files": l:entries})], l:index) != 0
    let l:all = 0
  endif

  return l:all

endfunc

" Note: How a document is NAMED between one GrooVim and the next: its file,
" when it has one, and its "new N" when it has not. The second is not as solid
" as the first -- the numbers are handed out again on the way back -- but it is
" all a document with no file has, and it is only used to choose a tab.
func! GrooVim_UnsavedNameOf(buffer) abort
  return bufname(a:buffer) ==# ""
   \ ? "new:" . GrooVim_NewNameOf(a:buffer)
   \ : "file:" . fnamemodify(bufname(a:buffer), ":p")
endfunc

func! GrooVim_UnsavedHereNow() abort
  let l:buffer = bufnr("%")
  if GrooVim_IsHelperBuffer(bufname(l:buffer)) || &buftype !=# ""

    " Note: Standing in the tree or in a list is standing in a tab all the same:
    " what is wanted is the DOCUMENT of that tab.
    for l:other in tabpagebuflist(tabpagenr())
      if !GrooVim_IsHelperBuffer(bufname(l:other))
       \ && getbufvar(l:other, "&buftype") ==# ""
        return GrooVim_UnsavedNameOf(l:other)
      endif
    endfor
    return ""
  endif
  return GrooVim_UnsavedNameOf(l:buffer)
endfunc

" Note: The clock. Only when something has CHANGED since the last copy, which is
" what the stamp below is for: with nothing typed, this costs one comparison.
"
" The document in FRONT is part of the stamp, because it is written down too:
" the tab you are on changes by walking and not by typing, and without it in
" here the index went on naming the tab you were in when you last typed --
" measured, a crash on tab 1 coming back on tab 3.
let s:unsavedStamp = ""
let s:unsavedTicks = {}

func! GrooVim_UnsavedSoon(...) abort

  if !g:GrooVim_UnsavedAuto
    return
  endif

  let l:stamp = []
  for l:info in getbufinfo({"buflisted": 1})
    if GrooVim_UnsavedWorth(l:info.bufnr)
      call add(l:stamp, l:info.bufnr . ":" . l:info.changed . ":" . l:info.changedtick)
    endif
  endfor

  let l:now = join(l:stamp, ",") . "|" . GrooVim_UnsavedHereNow()
  if l:now ==# s:unsavedStamp
    return
  endif

  let s:unsavedStamp = l:now
  call GrooVim_UnsavedWrite()

endfunc

" Note: The CLOCK writes the session too, and not only the copies.
"
" A crash takes the way out with it, and the way out is where the session was
" written: measured with the editor killed outright, the text came back and the
" three tabs it was in did not -- one tab, with the document that had the copy.
" The layout is as much "where you were" as the text is.
"
" Only from the timer, which is what the argument says: the events that also
" call the copies -- leaving a buffer, losing the focus, a write -- happen far
" more often, and the layout changes slowly.
func! GrooVim_UnsavedClock(timer) abort

  call GrooVim_UnsavedSoon()

  if g:GrooVim_SessionAuto == 1
    call GrooVim_SessionSave()
  endif

endfunc

" Note: And what a GrooVim that is gone left behind comes back, on the next
" start. Straight back, with no question: you did not throw it away, and a
" question about text you never meant to lose is a question with one answer.
"
" The documents come back MODIFIED, which is the whole point: the "+" is on the
" bar and in the tab line, and closing one tab goes on asking about it.
func! GrooVim_UnsavedRestore() abort

  if !g:GrooVim_UnsavedAuto || !isdirectory(g:GrooVim_UnsavedDir)
    return
  endif

  let l:mine = GrooVim_UnsavedIndexOf(getpid())
  let l:back = 0
  let l:changed = []

  " Note: Where the session left us, which is the tab GrooVim was on when it
  " was closed in the ordinary way -- "mksession" writes that down too. It is
  " the answer to fall back on, because putting the documents back walks
  " through tabs and would leave you on the last one filled in.
  let l:wasWindow = win_getid()
  let l:here = ""
  let l:hereWindow = 0

  for l:index in sort(glob(g:GrooVim_UnsavedDir . "/*.index", 0, 1))

    if l:index ==# l:mine
     \ || GrooVim_ProcessAlive(str2nr(fnamemodify(l:index, ":t:r")))
      continue
    endif

    let l:entries = GrooVim_UnsavedIndexRead(l:index)
    if empty(l:entries)
      call delete(l:index)
      continue
    endif

    if GrooVim_UnsavedIndexHere(l:index) !=# ""
      let l:here = GrooVim_UnsavedIndexHere(l:index)
    endif

    for l:entry in l:entries
      if GrooVim_UnsavedPut(l:entry, l:changed)
        let l:back = l:back + 1
        if l:here !=# "" && l:here ==# (get(l:entry, "path", "") !=# ""
         \ ? "file:" . l:entry.path : "new:" . get(l:entry, "name", ""))
          let l:hereWindow = win_getid()
        endif
      endif
    endfor

    " Note: Taken down only AFTER this GrooVim has written copies of its own:
    " between the two there is a moment with the text in a buffer and nowhere
    " else, and that moment is exactly what this whole part exists to avoid.
    call GrooVim_UnsavedWrite()
    for l:entry in l:entries
      call delete(get(l:entry, "copy", ""))
    endfor
    call delete(l:index)

  endfor

  " Note: And the tab you were on when you closed is the tab you come back to.
  "
  " The document that was in front is looked for among the ones just put back
  " first, and then among the ones the session opened -- you can close GrooVim
  " standing on a file you had just saved, with what is not saved waiting in
  " another tab. Failing both, the session's own answer is left as it was.
  if l:hereWindow > 0
    call win_gotoid(l:hereWindow)
  elseif l:here =~# "^file:"
   \ && bufnr(strpart(l:here, 5)) > 0
   \ && !empty(win_findbuf(bufnr(strpart(l:here, 5))))
    call win_gotoid(win_findbuf(bufnr(strpart(l:here, 5)))[0])
  elseif l:wasWindow > 0
    call win_gotoid(l:wasWindow)
  endif

  if l:back == 0
    return
  endif

  redraw!
  if empty(l:changed)
    call GrooVim_GrooVimBarMsg(l:back .
     \ " document(s) came back with text that is not saved yet!", 6)
  else
    call GrooVim_GrooVimBarMsg(l:back . " document(s) came back, and \"" .
     \ join(map(copy(l:changed), 'fnamemodify(v:val, ":t")'), "\", \"") .
     \ "\" changed on disk meanwhile!", 8)
  endif

endfunc

" Note: An index read, in either shape one can have. A LIST is what the first
" of these held -- the documents and nothing else; a DICTIONARY is the one with
" the tab you were on written into it as well. The older shape is still read,
" because it may be somebody's unsaved text, written by the GrooVim that was
" running when this one was installed over it.
func! GrooVim_UnsavedIndexRead(index) abort

  let l:read = []
  try
    let l:read = json_decode(join(readfile(a:index), ""))
  catch
    return []
  endtry

  if type(l:read) == v:t_list
    return l:read
  endif

  return type(l:read) == v:t_dict ? get(l:read, "files", []) : []

endfunc

" Note: And which document was in FRONT when it was written, by the name a
" document has between one GrooVim and the next.
func! GrooVim_UnsavedIndexHere(index) abort

  let l:read = []
  try
    let l:read = json_decode(join(readfile(a:index), ""))
  catch
    return ""
  endtry

  return type(l:read) == v:t_dict ? get(l:read, "here", "") : ""

endfunc

" Note: One document put back where it belongs: in the tab the session already
" opened for it, or in one of its own. A document that never had a file comes
" back as a document with no file -- it gets its "new N" like any other.
func! GrooVim_UnsavedPut(entry, changed) abort

  let l:copy = get(a:entry, "copy", "")
  if l:copy ==# "" || !filereadable(l:copy)
    return 0
  endif

  let l:text = readfile(l:copy)
  let l:path = get(a:entry, "path", "")

  if l:path !=# ""

    let l:buffer = bufnr(l:path)
    let l:windows = l:buffer > 0 ? win_findbuf(l:buffer) : []
    if !empty(l:windows)
      call win_gotoid(l:windows[0])
    else
      call GrooVim_OpenInTab(l:path)
    endif

    if get(a:entry, "disk", 0) > 0 && getftime(l:path) > a:entry.disk
      call add(a:changed, l:path)
    endif

  else

    let l:page = GrooVim_UnsavedEmptyPage()
    if empty(l:page)
      tabnew
    else
      exec "tabnext " . l:page[0]
      exec l:page[1] . "wincmd w"
    endif

  endif

  if !GrooVim_CanChangeQuiet()
    return 0
  endif

  silent! call setline(1, empty(l:text) ? [""] : l:text)
  if line("$") > max([len(l:text), 1])
    silent! exec (max([len(l:text), 1]) + 1) . ",$delete _"
  endif

  call cursor(min([get(a:entry, "line", 1), line("$")]), get(a:entry, "col", 1))
  return 1

endfunc

" Note: An empty page to put a document with NO FILE back into, wherever it is.
"
" The session leaves one standing for every tab that held a nameless document --
" ":mksession" writes down the tab and not the text -- so coming back there is
" an empty "new N" waiting in exactly the place the document belongs. Without
" this it was left where it was and the document opened in a tab of its own
" beside it: measured, three tabs where two were meant.
"
" "GrooVim_FreshPageWindow" is the other half of the same idea and answers only
" for an editor with ONE tab, which is not where this happens.
"
" Answers [tab, window], or an empty list when there is no such page.
func! GrooVim_UnsavedEmptyPage() abort

  for l:tab in range(1, tabpagenr("$"))

    let l:found = 0
    let l:window = 0
    for l:which in range(1, len(tabpagebuflist(l:tab)))

      let l:buffer = tabpagebuflist(l:tab)[l:which - 1]
      if GrooVim_IsHelperBuffer(bufname(l:buffer))
        continue
      endif

      if l:found || !GrooVim_IsADocument(l:buffer)
       \ || getbufvar(l:buffer, "&modified")
       \ || getbufline(l:buffer, 1, "$") !=# [""]
        let l:found = 0
        break
      endif

      let l:found = 1
      let l:window = l:which

    endfor

    if l:found
      return [l:tab, l:window]
    endif

  endfor

  return []

endfunc

" Note: The same question "GrooVim_CanChange" answers, asked without saying
" anything on the bar: a document that refuses to be changed is not one that was
" copied, so this is a net and not a message.
func! GrooVim_CanChangeQuiet() abort
  return &modifiable && !&readonly
endfunc

augroup GrooVim_Unsaved
  autocmd!
  autocmd CursorHold,CursorHoldI,BufLeave,FocusLost,BufWritePost *
   \ call GrooVim_UnsavedSoon()
  autocmd VimLeavePre * call GrooVim_UnsavedWrite()
augroup END

" Note: On a clock of its own as well as on the events above, because a hand
" that goes on typing never fires "CursorHold" -- and a crash does not wait for
" a pause.
call timer_start(g:GrooVim_UnsavedEveryMs, "GrooVim_UnsavedClock", {"repeat": -1})
