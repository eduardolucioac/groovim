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

" Note: A document that was NEVER SAVED, with changes in it, about to be closed.
"
" ":confirm" of Vim asks "Save changes to "Untitled"? [Y]es, (N)o, (C)ancel" and
" its Yes has nowhere to write: a nameless buffer has no file name, so Vim
" answers "E32: No file name" and the close is given up on. A question whose
" first answer cannot be given is worse than no question.
"
" So it is asked here, before the close, and it is the same short question every
" editor asks -- Save "new 1"? -- with the Yes of it leading to the one question
" of the "save as": WHERE to put it, with the folder you are in written in.
" After that the document has a name and ":confirm" finds nothing left to ask.
" A No clears the "modified" flag, which is that same answer given a moment
" earlier, and an <Esc> gives the close up.
"
" The document is settled where it LIVES -- "win_execute" writes it in its own
" window, in another tab if that is where it is -- so closing a side of the tab
" line asks about each one without walking you through the tabs.
"
" It hands back 0 when nothing was settled, and then nothing is closed.
func! GrooVim_CloseNamelessSettle(buffer) abort

  if bufname(a:buffer) !=# "" || !getbufvar(a:buffer, "&modified")
   \ || getbufvar(a:buffer, "&buftype") !=# ""
    return 1
  endif

  let l:windows = win_findbuf(a:buffer)
  if empty(l:windows)
    return 1
  endif

  let l:answer = GrooVim_ScreenAsk("Save \"" . GrooVim_NewNameOf(a:buffer) . "\" " .
   \ GrooVim_OptionsToPrompt(["y", "n"], "y", ""),
   \ {answer -> answer ==# "" || answer ==# "y" || answer ==# "n"})
  echomsg "   "

  if l:answer ==# "n"
    call setbufvar(a:buffer, "&modified", 0)
    return 1
  endif

  " Note: No name to suggest: the one written in the question is the name of the
  " file you are ON, and this document is another one.
  let l:where = GrooVim_AskFileWhere("file", "")

  try
    call win_execute(l:windows[0], "saveas " . fnameescape(l:where))
    call GrooVim_GrooVimBarMsg("Saved as \"" . fnamemodify(l:where, ":t") .
     \ "\"! Closing it now.", 4)
  catch
    call GrooVim_GrooVimBarMsg("It can't be saved! Reason: \"" . v:exception . "\"", 4)
    redraw!
    return 0
  endtry

  return 1

endfunc

" Note: The same, for every document of the tabs that are about to go, asked
" before anything is closed -- half a tab line closed and then a question is no
" way to be asked anything.
func! GrooVim_CloseNamelessTabs(tabs) abort
  for l:tab in a:tabs
    for l:buffer in tabpagebuflist(l:tab)
      if !GrooVim_CloseNamelessSettle(l:buffer)
        return 0
      endif
    endfor
  endfor
  return 1
endfunc

" Note: Closing, asking about what would be lost. ":confirm" is what turns the
" refusal of Vim -- "E37: No write since last change" -- into a question you can
" answer: save, throw away, or go back. Writing that by hand would be repeating
" what Vim already knows.
"
" What it cannot answer is a document with no name, which is settled first.
" ":tabonly" takes every OTHER tab with it; a window takes nothing with it while
" another window still shows the same document.
func! GrooVim_CloseAsking(command) abort

  if a:command ==# "tabonly"
    if !GrooVim_CloseNamelessTabs(filter(range(1, tabpagenr("$")),
     \ "v:val != tabpagenr()"))
      return
    endif
  elseif len(win_findbuf(bufnr("%"))) == 1
    if !GrooVim_CloseNamelessSettle(bufnr("%"))
      return
    endif
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
    if !GrooVim_CloseNamelessTabs([tabpagenr()])
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

  if !GrooVim_CloseNamelessSettle(bufnr("%"))
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
    if !GrooVim_CloseNamelessTabs([l:target])
      return
    endif
    let l:before = tabpagenr("$")
    exec "confirm " . l:target . "tabclose"
    if tabpagenr("$") == l:before
      return
    endif
  endwhile
endfunc

