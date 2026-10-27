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

func! GrooVim_SessionSave() abort
  call mkdir(fnamemodify(g:GrooVim_SessionFile, ":h"), "p")
  exec "mksession! " . fnameescape(g:GrooVim_SessionFile)
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
