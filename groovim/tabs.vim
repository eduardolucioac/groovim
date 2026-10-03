" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
" TABS (AND THE TAB LINE)
" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" Note: The tab line and what is written on it, the names of documents that have
" no name yet, and the windows that are accessories of a tab instead of
" documents of yours -- the tree, the lists, the help.
"
" The windows that are accessories of a tab and not documents of yours. In one
" place because more than one thing needs to know it.
func! GrooVim_IsHelperBuffer(name) abort
  return a:name =~ "GrooVim_SearchGuyResults" || a:name =~ "GrooVim_BookmarksList" ||
   \ a:name =~ "NERD_tree_" || a:name =~ "GrooVimHelp"
endfunc

" Note: Try to ensure that open in an editor window.
"
" It walks the windows a bounded number of times. It used to be a "while" that
" pressed "<C-w>" until it landed on an editor: with nothing but accessories
" open that day never came and Vim froze.
func! GrooVim_PutOnEditWindow() range abort
  for l:window in range(1, winnr("$"))
    if !GrooVim_IsHelperBuffer(expand('%:t'))
      return
    endif
    exec "wincmd w"
  endfor
endfunc

" Note: The label is always a document of YOURS -- the accessories are skipped,
" or standing on the occurrence list would rename the tab to
" "GrooVim_SearchGuyResults1" -- and a document you have not saved yet shows as
" "new 1", "new 2"... the way Notepad++ names them, instead of "[No Name]".
"
" A name ON SCREEN and not a name on the buffer: ":file new 1" would be one
" line, and it would make ":w" write a file called "new 1" into whatever
" directory you happen to be in. Nameless, Vim goes on asking you where to save
" -- the Save As of Notepad++, and the reason its "new 1" is not a file either.
"
" The number is handed out the first time the buffer is DRAWN and then kept on
" the buffer, so it never changes under you and the tabs get theirs left to
" right. And it is the LOWEST one nobody is using: close "new 2" of "new 1, new
" 2, new 3" and the next document is "new 2" again, as in Notepad++. A counter
" that only grows would have you at "new 47" on a morning when three documents
" were ever open at once.
func! GrooVim_NewNameOf(buffer) abort

  if !GrooVim_IsADocument(a:buffer)
    return ""
  endif

  let l:name = getbufvar(a:buffer, "GrooVim_NewName", "")
  if l:name != ""
    return l:name
  endif

  " Note: Only what is ON SCREEN holds a slot -- a buffer shown in some window
  " of some tab.
  "
  " Closing a tab does not delete its buffer, it hides it, so counting
  " everything LISTED would keep the number of a document you closed and hand
  " you "new 4" right after closing "new 2". A document that was saved has a
  " name of its own now and stops counting too: both give their number back
  " without anything having to remember to do it.
  let l:taken = {}
  for l:info in getbufinfo({"buflisted": 1})
    if l:info.bufnr == a:buffer || empty(l:info.windows)
     \ || !GrooVim_IsADocument(l:info.bufnr)
      continue
    endif
    let l:other = getbufvar(l:info.bufnr, "GrooVim_NewName", "")
    if l:other != ""
      let l:taken[str2nr(matchstr(l:other, '\d\+'))] = 1
    endif
  endfor

  let l:slot = 1
  while has_key(l:taken, l:slot)
    let l:slot = l:slot + 1
  endwhile

  let l:name = "new " . l:slot
  call setbufvar(a:buffer, "GrooVim_NewName", l:name)
  return l:name
endfunc

" Note: A document of yours that has never been saved -- which is what gets a
" "new N". Not a file (it has a name), not an accessory of a tab (the occurrence
" list and the help are not buffers you edit).
func! GrooVim_IsADocument(buffer) abort
  return bufname(a:buffer) == "" && getbufvar(a:buffer, "&buftype") == ""
   \ && buflisted(a:buffer)
endfunc

" Note: What the bar calls the file of the window being drawn. It is "%f" plus
" the "new N" above.
func! GrooVim_FileLabel() abort
  let l:name = GrooVim_NewNameOf(bufnr("%"))
  return l:name != "" ? l:name : expand("%")
endfunc

func! GrooVim_TabLabel(tab) abort
  let l:buffers = tabpagebuflist(a:tab)
  let l:chosen = l:buffers[tabpagewinnr(a:tab) - 1]

  " Note: The window you are on comes first, so a tab split between two files
  " still follows where you are.
  if GrooVim_IsHelperBuffer(bufname(l:chosen))
    let l:chosen = 0
    for l:buffer in l:buffers
      if !GrooVim_IsHelperBuffer(bufname(l:buffer))
        let l:chosen = l:buffer
        break
      endif
    endfor
  endif

  " Note: A tab holding nothing but an accessory is named after the accessory --
  " the help is a tab of its own now, and "[GrooVim]" would tell you nothing
  " about which of your tabs it is.
  if l:chosen == 0
    let l:only = bufname(l:buffers[tabpagewinnr(a:tab) - 1])
    return l:only != "" ? fnamemodify(l:only, ":t") : "[GrooVim]"
  endif

  let l:name = fnamemodify(bufname(l:chosen), ":t")
  if l:name != ""
    return l:name
  endif

  let l:new = GrooVim_NewNameOf(l:chosen)
  return l:new != "" ? l:new : "[No Name]"
endfunc

" Note: Like the tab line Vim draws by itself, with the same window count and
" the same "+" for modified, except that only YOUR documents are counted: an
" accessory is not a window you opened.
"
" The mark the pinned tab wears. An arrow that comes back, because that is what
" the tab is for: |Alt+Down| returns to it from wherever you are. Set it to ""
" and the tab line says nothing, which leaves the message as the only way to
" know.
let g:GrooVim_TabPinMark = get(g:, "GrooVim_TabPinMark", "\u21A9")

" Note: Draws the tab line again, right now.
"
" Vim draws it when it has a reason of its own -- a tab opened, closed, entered
" -- and pinning a tab is none of those: the mark appeared and disappeared only
" at the next tab change, so taking the pin off left the mark sitting there.
" Measured: F5->t on the pinned tab, the pin gone by every count, the arrow
" still on the line.
func! GrooVim_TabLineRedraw() abort
  redrawtabline
endfunc

" Note: What one tab says, and nothing about where it is drawn: the marks in
" front of the name -- the pin, how many documents are in the tab, whether any
" of them is modified -- and then the name.
func! GrooVim_TabPiece(tab) abort

  let l:windows = 0
  let l:modified = 0
  for l:buffer in tabpagebuflist(a:tab)
    if !GrooVim_IsHelperBuffer(bufname(l:buffer))
      let l:windows = l:windows + 1
      if getbufvar(l:buffer, "&modified")
        let l:modified = 1
      endif
    endif
  endfor

  " Note: The mark of the pinned tab, which is the one |Alt+Down| takes you back
  " to. It is written here and not only said in a message: a message is gone by
  " the time you need to know, and what you need to know is WHICH tab it was --
  " at a glance, at any moment, without pressing anything.
  let l:pin = gettabvar(a:tab, "GrooVim_TabPinned", 0) ? g:GrooVim_TabPinMark : ""

  let l:prefix = l:pin . (l:windows > 1 ? l:windows : "") . (l:modified ? "+" : "")
  return " " . (l:prefix == "" ? "" : l:prefix . " ") . GrooVim_TabLabel(a:tab) . " "

endfunc

" Note: The first tab DRAWN, which is not always the first tab there is.
let s:tabFirst = 1

" Note: The marks at the ends, which say that the line goes on past them.
let g:GrooVim_TabMoreLeft = get(g:, "GrooVim_TabMoreLeft", "‹")
let g:GrooVim_TabMoreRight = get(g:, "GrooVim_TabMoreRight", "›")

" Note: A new tab, at the END of the tab line, and one you can type in. The
" "setlocal ma" is there because a ":set noma" written elsewhere leaks into
" every buffer opened afterwards -- see the note on it in
" "GrooVim_SearchGuySync".
func! GrooVim_TabNew() abort
  $tabnew
  setlocal ma
endfunc

" Note: The tab line, which SCROLLS instead of being cut: with more tabs than
" the terminal is wide, a WINDOW of tabs is drawn and the window follows you. It
" moves only as much as it has to for the tab you are ON to be whole on the
" screen, which is what Notepad++ does with the same problem, and a "‹" or a "›"
" at the end says the line goes on that way.
func! GrooVim_TabLine() abort

  let l:count = tabpagenr("$")
  let l:here = tabpagenr()
  let l:pieces = map(range(1, l:count), "GrooVim_TabPiece(v:val)")
  let l:widths = map(copy(l:pieces), "strdisplaywidth(v:val)")

  " Note: Two columns held back for the marks at the ends. Held back always and
  " not only when there is something to mark: a line that fits by exactly the
  " width of the mark it is about to need would scroll by one tab for every
  " redraw, back and forth.
  let l:room = &columns - 2

  if s:tabFirst > l:here
    let s:tabFirst = l:here
  endif
  if s:tabFirst < 1 || s:tabFirst > l:count
    let s:tabFirst = l:here
  endif

  " Note: And forward until the tab you are on fits whole.
  while s:tabFirst < l:here
    let l:used = 0
    for l:tab in range(s:tabFirst, l:here)
      let l:used = l:used + l:widths[l:tab - 1]
    endfor
    if l:used <= l:room
      break
    endif
    let s:tabFirst = s:tabFirst + 1
  endwhile

  let l:line = ""
  let l:used = 0
  let l:last = s:tabFirst - 1
  for l:tab in range(s:tabFirst, l:count)
    if l:used + l:widths[l:tab - 1] > l:room && l:tab != l:here
      break
    endif
    let l:line = l:line . (l:tab == l:here ? "%#TabLineSel#" : "%#TabLine#")
    " Note: Makes the tab clickable, just like the default one.
    let l:line = l:line . "%" . l:tab . "T" . l:pieces[l:tab - 1]
    let l:used = l:used + l:widths[l:tab - 1]
    let l:last = l:tab
  endfor

  let l:before = s:tabFirst > 1 ? "%#TabLine#" . g:GrooVim_TabMoreLeft : ""
  let l:after = l:last < l:count ? "%#TabLine#" . g:GrooVim_TabMoreRight : ""

  return l:before . l:line . l:after . "%#TabLineFill#%T"

endfunc

set tabline=%!GrooVim_TabLine()

" Note: Displays the help for GrooVim. This text is in the own GrooVim body!.
"
" Which tab you were reading when you asked for the help, so that asking again
" puts you back there. A toggle that leaves you somewhere else is not a toggle.
"
" The number is enough and does not go stale: the help opens at the END of the
" tab line, so no tab in front of it ever changes number while it is up.
let s:helpCameFrom = 0

func! GrooVim_ToogleGrooVimHelp() range abort

  if bufexists("GrooVimHelp") == 0

    let s:helpCameFrom = tabpagenr()

    " Note: A TAB of its own and not a split of the one you are in. The help is
    " two hundred and seventy lines of reading, and half a screen is not where
    " you read it -- and it does not belong on top of the document you opened it
    " to ask about.
    "
    " At the END of the tab line, where a new tab goes.
    $tabnew

    " Note: "setlocal" and NOT "set" -- see the long note in
    " "GrooVim_SearchGuySync()". This one was the loudest: opening the help
    " locked the global "modifiable", and from then on every new buffer of the
    " session answered "E21" to anything, a copy included.
    setlocal ma
    silent exec "file GrooVimHelp"
    exec "put =g:GrooVimHelp"
    exec "norm ggdd"
    setlocal wrap linebreak nolist textwidth=0 wrapmargin=0 formatoptions+=l
    " Note: The help syntax of Vim answers "E403: syntax sync: Line
    " continuations pattern specified twice" when it is loaded onto a buffer
    " that is not a real help FILE. Measured with nothing but "syntax on" in the
    " vimrc, so it is not GrooVim's to fix, and it colours the text correctly
    " all the same.
    "
    " Kept quiet, and "v:errmsg" handed back as it was -- a leftover error
    " message is read later as a real one, by a human and by the battery alike.
    let l:errmsgWas = v:errmsg
    silent! setlocal syntax=help
    let v:errmsg = l:errmsgWas
    let &l:statusline = "%!GrooVim_GrooVimHelpBar()"
    " Note: The help was WRITTEN into, so Vim marks it changed and the bar shows
    " a "+" on a buffer nobody can change.
    setlocal noma nomodified
  else
    " Note: Wiping the buffer takes its tab with it, there being nothing else in
    " that tab. And wiping and not closing, so that "bufexists()" above answers
    " honestly the next time.
    exec "bwipeout! GrooVimHelp"

    if s:helpCameFrom > 0 && s:helpCameFrom <= tabpagenr("$")
      exec "tabnext " . s:helpCameFrom
    endif
    let s:helpCameFrom = 0
  endif

endfunc

" Note: Get current filename or filename and path and put on transfer area.
func! GrooVim_GetFileNameAndPath() range abort

  let l:filenameOrFilenameAndPath = ""

  let l:getFilenameOrFilenameAndPath = GrooVim_GetOptions(
   \ "Get [f]filename or [p]filename and path", ["f", "p"], "f", "")
  if l:getFilenameOrFilenameAndPath ==# "f"
    let l:filenameOrFilenameAndPath = expand('%:t')
    echomsg " -> Filename \"" . l:filenameOrFilenameAndPath . "\" on transfer area!"
  elseif l:getFilenameOrFilenameAndPath ==# "p"
    let l:filenameOrFilenameAndPath = expand('%:p')
    echomsg " -> Filename and path \"" . l:filenameOrFilenameAndPath . "\" on transfer area!"
  endif

  " Note: Set the clipboard register.
  call GrooVim_ClipSet(l:filenameOrFilenameAndPath)

endfunc

