" Note: The windows that are accessories of a tab and not documents of yours. In
" one place because more than one thing needs to know it! By Questor
func! GrooVim_IsHelperBuffer(name) abort
  return a:name =~ "GrooVim_SearchGuyResults" || a:name =~ "NERD_tree_" ||
   \ a:name =~ "GrooVimHelp"
endfunc

" Note: Try to ensure that open in an editor window! By Questor
"
" Note: It walks the windows a bounded number of times. It used to be a "while"
" that pressed "<C-w>" until it landed on an editor: with nothing but accessories
" open that day never came and Vim froze! By Questor
func! GrooVim_PutOnEditWindow() range abort
  for l:window in range(1, winnr("$"))
    if !GrooVim_IsHelperBuffer(expand('%:t'))
      return
    endif
    exec "wincmd w"
  endfor
endfunc

" Note: The default tab label is the buffer of the CURRENT window of the tab, so
" standing on the occurrences list renamed the tab to "GrooVim_SearchGuyResults1"
" and your file was no longer findable among many tabs. Here the label is always
" a document of yours: the accessories are skipped! By Questor
" Note: A document you have not saved yet shows as "new 1", "new 2"... the way
" Notepad++ names them, instead of the "[No Name]" of Vim.
"
" Note: A name ON SCREEN and not a name on the buffer. ":file new 1" would have
" been one line, and it would make ":w" write a file called "new 1" into whatever
" directory you happen to be in. Nameless, Vim goes on asking you where to save
" -- which is the Save As of Notepad++, and the reason its "new 1" is not a file
" either.
"
" Note: The number is handed out the first time the buffer is DRAWN and then kept
" on the buffer, so it never changes under you, and the tabs get theirs in the
" order they are drawn -- left to right.
"
" Note: And it is the LOWEST one nobody is using, not the next of a counter that
" only grows: close "new 2" of "new 1, new 2, new 3" and the one after it is
" "new 2" again. That is how Notepad++ hands them out, and a counter would have
" you at "new 47" on a morning when three documents were ever open at once! By
" Questor
func! GrooVim_NewNameOf(buffer) abort

  if !GrooVim_IsADocument(a:buffer)
    return ""
  endif

  let l:name = getbufvar(a:buffer, "GrooVim_NewName", "")
  if l:name != ""
    return l:name
  endif

  " Note: Only what is ON SCREEN holds a slot -- a buffer shown in some window of
  " some tab.
  "
  " Note: Closing a tab does not delete its buffer, it hides it, so counting
  " everything LISTED would keep the number of a document you closed and hand you
  " "new 4" right after closing "new 2". A document that was saved has a name of
  " its own now and stops counting too: both give their number back without
  " anything having to remember to do it! By Questor
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
" list and the help are not buffers you edit)! By Questor
func! GrooVim_IsADocument(buffer) abort
  return bufname(a:buffer) == "" && getbufvar(a:buffer, "&buftype") == ""
   \ && buflisted(a:buffer)
endfunc

" Note: What the bar calls the file of the window being drawn. It is "%f" plus
" the "new N" above! By Questor
func! GrooVim_FileLabel() abort
  let l:name = GrooVim_NewNameOf(bufnr("%"))
  return l:name != "" ? l:name : expand("%")
endfunc

func! GrooVim_TabLabel(tab) abort
  let l:buffers = tabpagebuflist(a:tab)
  let l:chosen = l:buffers[tabpagewinnr(a:tab) - 1]

  " Note: The window you are on comes first, so a tab split between two files
  " still follows where you are! By Questor
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
  " about which of your tabs it is! By Questor
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

" Note: Like the tab line Vim draws by itself, with the same window count and the
" same "+" for modified, except that only YOUR documents are counted: an
" accessory is not a window you opened! By Questor
func! GrooVim_TabLine() abort
  let l:line = ""

  for l:tab in range(1, tabpagenr("$"))
    let l:line = l:line . (l:tab == tabpagenr() ? "%#TabLineSel#" : "%#TabLine#")
    " Note: Makes the tab clickable, just like the default one! By Questor
    let l:line = l:line . "%" . l:tab . "T"

    let l:windows = 0
    let l:modified = 0
    for l:buffer in tabpagebuflist(l:tab)
      if !GrooVim_IsHelperBuffer(bufname(l:buffer))
        let l:windows = l:windows + 1
        if getbufvar(l:buffer, "&modified")
          let l:modified = 1
        endif
      endif
    endfor

    let l:prefix = (l:windows > 1 ? l:windows : "") . (l:modified ? "+" : "")
    let l:line = l:line . " " . (l:prefix == "" ? "" : l:prefix . " ")
    let l:line = l:line . GrooVim_TabLabel(l:tab) . " "
  endfor

  return l:line . "%#TabLineFill#%T"
endfunc

set tabline=%!GrooVim_TabLine()

" Note: Displays the help for GrooVim. This text is in the own GrooVim body!! By Questor
" Note: Which tab you were reading when you asked for the help, so that asking
" again puts you back there. A toggle that leaves you somewhere else is not a
" toggle.
"
" Note: The number is enough and does not go stale: the help opens at the END of
" the tab line, so no tab in front of it ever changes number while it is up! By
" Questor
let s:helpCameFrom = 0

func! GrooVim_ToogleGrooVimHelp() range abort

  if bufexists("GrooVimHelp") == 0

    let s:helpCameFrom = tabpagenr()

    " Note: A TAB of its own and not a split of the one you are in. The help is
    " two hundred and seventy lines of reading, and half a screen is not where
    " you read it -- and it does not belong on top of the document you opened it
    " to ask about.
    "
    " Note: At the END of the tab line, where a new tab goes! By Questor
    $tabnew

    " Note: "setlocal" and NOT "set" -- see the long note in
    " "GrooVim_SearchGuySync()". This one was the loudest: opening the help
    " locked the global "modifiable", and from then on every new buffer of the
    " session answered "E21" to anything, a copy included! By Questor
    setlocal ma
    silent exec "file GrooVimHelp"
    exec "put =g:GrooVimHelp"
    exec "norm ggdd"
    setlocal wrap linebreak nolist textwidth=0 wrapmargin=0 formatoptions+=l
    " Note: The help syntax of Vim answers "E403: syntax sync: Line continuations
    " pattern specified twice" when it is loaded onto a buffer that is not a real
    " help FILE. Measured with nothing but "syntax on" in the vimrc, so it is not
    " GrooVim's to fix, and it colours the text correctly all the same.
    "
    " Note: Kept quiet, and "v:errmsg" handed back as it was -- a leftover error
    " message is read later as a real one, by a human and by the battery alike!
    " By Questor
    let l:errmsgWas = v:errmsg
    silent! setlocal syntax=help
    let v:errmsg = l:errmsgWas
    let &l:statusline = "%!GrooVim_GrooVimHelpBar()"
    " Note: The help was WRITTEN into, so Vim marks it changed and the bar shows
    " a "+" on a buffer nobody can change! By Questor
    setlocal noma nomodified
  else
    " Note: Wiping the buffer takes its tab with it, there being nothing else in
    " that tab. And wiping and not closing, so that "bufexists()" above answers
    " honestly the next time! By Questor
    exec "bwipeout! GrooVimHelp"

    if s:helpCameFrom > 0 && s:helpCameFrom <= tabpagenr("$")
      exec "tabnext " . s:helpCameFrom
    endif
    let s:helpCameFrom = 0
  endif

endfunc

" Note: Get current filename or filename and path and put on transfer area! By Questor
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

  " Note: Set the clipboard register! By Questor
  call GrooVim_ClipSet(l:filenameOrFilenameAndPath)

endfunc

