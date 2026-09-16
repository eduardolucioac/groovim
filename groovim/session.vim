func! GrooVim_SessionSave() abort
  call mkdir(fnamemodify(g:GrooVim_SessionFile, ":h"), "p")
  exec "mksession! " . fnameescape(g:GrooVim_SessionFile)
endfunc

func! GrooVim_SessionLoad() abort
  if !filereadable(g:GrooVim_SessionFile)
    return
  endif
  exec "source " . fnameescape(g:GrooVim_SessionFile)
  call GrooVim_SessionDropGhosts()
endfunc

" Note: A session written days ago can name files that are not there any more --
" one that was deleted, or one under "/tmp" after the machine was restarted. Vim
" brings those back as EMPTY buffers carrying the old name, and it looks like the
" editor opened something broken.
"
" Note: And with nothing left to show, the welcome screen comes back: an empty
" Vim that hides its own welcome looks like something went wrong! By Questor
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
" you want THAT file, not everything you had open last time!
"
" Note: "++nested" is what makes the files come back as FILES. A command run from
" inside an autocmd fires no autocmds of its own unless the autocmd asks for it,
" so the ":edit" written in the session opened every file with no "BufRead" --
" and with no "BufRead" there is no filetype detection: measured, "&filetype"
" empty on a ".py" that opens as "python" when named on the command line. No
" syntax, no indent rules, no indent guides! By Questor
augroup GrooVim_Session
  autocmd!
  autocmd VimLeavePre * if g:GrooVim_SessionAuto == 1 | call GrooVim_SessionSave() | endif
  autocmd VimEnter * ++nested if g:GrooVim_SessionAuto == 1 && argc() == 0 |
        \ call GrooVim_SessionLoad() | endif
augroup END

" Note: By hand only when it is not automatic. With the session saving itself,
" saving it again by hand would be a command that does nothing you can see -- so
" it says so instead of pretending! By Questor
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

" Note: Closing, asking about what would be lost.
"
" Note: ":confirm" is what turns the refusal of Vim -- "E37: No write since last
" change" -- into a question you can answer: save, throw away, or go back. Writing
" that by hand would be repeating what Vim already knows! By Questor
func! GrooVim_CloseAsking(command) abort
  exec "confirm " . a:command
endfunc

" Note: Closes every tab on ONE SIDE of the one you are in -- the "Close All to
" the Right" and "Close All to the Left" of the Notepad++ tab menu.
"
" Note: One tab at a time, and always the NEIGHBOUR: closing shifts the numbers
" of every tab after it, so a list of numbers read up front would be wrong by the
" second one. Asking "who is next to me" again each round cannot go stale.
"
" Note: It asks about unsaved text, like every other way of closing in GrooVim.
" And if you answer "Cancel" the count of tabs does not move -- which is how this
" knows to stop, instead of asking the same question for ever! By Questor
" Note: A new tab, at the END of the tab line, and one you can type in. See the
" long notes on "$tabnew" and on the lock that used to leak, in
" "GrooVim_TabClose" and in the help toggle! By Questor
func! GrooVim_TabNew() abort
  $tabnew
  setlocal ma
endfunc

" Note: Closing the tab you are in.
"
" Note: Vim REFUSES to close the last tab -- "E784: Cannot close last tab page"
" -- so on that one what closes is the DOCUMENT instead, leaving the empty one
" Notepad++ calls "new 1".
"
" Note: ":enew" for the empty one, and then wiping the document that was there.
" ":bdelete" on its own reads better and is WRONG here: it hands you a fresh
" empty buffer only when there is no other buffer around, and after a few tabs
" have been closed there always is -- measured, closing the last tab showed a
" file closed three tabs ago instead of an empty page. ":enew" always opens an
" empty one, and the wipe is what keeps the closed file from lingering in the
" buffer list.
"
" Note: The "confirm" is on the ":enew", which is what abandons the document, so
" unsaved text is asked about before anything happens. Answering "Cancel" leaves
" the buffer where it was, and the "if" below sees that nothing moved and wipes
" nothing! By Questor
func! GrooVim_TabClose() abort

  if tabpagenr("$") > 1
    confirm tabclose
    return
  endif

  " Note: The accessories of a tab -- the occurrence list, the tree -- are not
  " documents of yours, so the closing lands on the document beside them! By
  " Questor
  if GrooVim_IsHelperBuffer(expand("%:t"))
    call GrooVim_PutOnEditWindow()
    if GrooVim_IsHelperBuffer(expand("%:t"))
      call GrooVim_GrooVimBarMsg("There is no document here to close!", 5)
      return
    endif
  endif

  let l:document = bufnr("%")
  confirm enew
  if bufnr("%") != l:document
    exec "silent! bwipeout " . l:document
  endif

endfunc

func! GrooVim_TabCloseSide(side) abort
  while 1
    let l:target = a:side > 0 ? tabpagenr() + 1 : tabpagenr() - 1
    if l:target < 1 || l:target > tabpagenr("$")
      return
    endif
    let l:before = tabpagenr("$")
    exec "confirm " . l:target . "tabclose"
    if tabpagenr("$") == l:before
      return
    endif
  endwhile
endfunc

" Tip: Try to "balance" the distribution of the keys to preserve your
" hands! By Questor

" Note: How long GrooVim waits for the SECOND key of a shortcut, in
" milliseconds. Raise it if a shortcut of yours is being lost between the F key
" and the letter! By Questor
let g:GrooVim_CommandZWait = get(g:, "GrooVim_CommandZWait", 1000)

" Note: How long it waits before LOOKING for that key the first time. A terminal
" sends an arrow or an F key as an escape sequence, and reading before it has all
" landed reads nothing! By Questor
let g:GrooVim_CommandZSettle = get(g:, "GrooVim_CommandZSettle", 400)

" Note: How close together the SAME F key has to be pressed to mean "do that
" again", in milliseconds! By Questor
let g:GrooVim_CommandZRepeat = get(g:, "GrooVim_CommandZRepeat", 400)

