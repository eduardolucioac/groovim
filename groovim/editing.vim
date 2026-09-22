" Note: The buffer you are on may refuse to be changed. The tree of NERDTree,
" the occurrence list and the help are all like that, and a key that edits met
" them with "E21: Cannot make changes, 'modifiable' is off" over the bar --
" measured: Enter, Tab, Shift-Tab, Backspace, Del, Ctrl-x, Ctrl-v, p, Ctrl-r and
" the shortcuts that edit, eleven keys of a conventional editor answering with
" the error number of another editor entirely.
"
" Note: ONE function decides and says so, and it is reached two ways: the keys
" that call a function of GrooVim ask it at the door, and the shortcuts of the F
" keys are caught by the net at the end of the dispatch -- which needs no list of
" what edits and what does not, and holds for shortcuts written after today.
"
" Note: "readonly" as well as "modifiable": a file opened with "view", or one
" without write permission, refuses just the same! By Questor
func! GrooVim_CanChange() abort
  if &modifiable && !&readonly
    return 1
  endif
  call GrooVim_CannotChangeSay()
  return 0
endfunc

func! GrooVim_CannotChangeSay() abort
  call GrooVim_GrooVimBarMsg("This one cannot be changed!", 4)
endfunc

" Note: For the keys that are raw keys and not a call: an "<expr>" mapping hands
" back the keys themselves, or nothing at all when the buffer refuses! By Questor
func! GrooVim_KeysIfCanChange(keys) abort
  return GrooVim_CanChange() ? a:keys : ""
endfunc

" Note: Scrolls with the wheel allowing the cursor over "invalid" areas! By Questor
func! GrooVim_ScrollAdm(mod, direction) range abort
  if &virtualedit == "onemore"
    set virtualedit=all
  endif

  " Note: No "gv" here: the wheel of visual mode comes through "<Cmd>" and the
  " selection was never lost! By Questor

  if a:direction == "u"
    exec "norm \<Up>\<Up>\<Up>"
  elseif a:direction == "d"
    exec "norm \<Down>\<Down>\<Down>"
  endif

  let g:onMoveScreen = 1
endfunc

" Note: Serves to avoid the side effect of capslock status checking! By Questor
nnoremap <silent> <LeftMouse> :let g:onMoveScreen = 1<cr><LeftMouse>

" Note: Takes the line away, and what was in the transfer area stays there.
"
" Note: The "_" register is the one Vim throws things into, and GrooVim sends
" every delete to it on purpose: in a conventional editor deleting a line does
" not cost you what you copied ten minutes ago.
"
" Note: Over a selection it takes every line the selection touches, whole, which
" is what "the line" means when more than one is in hand! By Questor
func! GrooVim_SuppressLine(mode) abort
  if !GrooVim_CanChange() | return | endif
  if a:mode ==# "v"
    " Note: "V" turns the selection into WHOLE lines before it goes. Selecting
    " three characters of a line and asking for the line to be taken away has to
    " take the line, not the three characters! By Questor
    exec "normal! gvV\"_d"
  else
    exec "normal! \"_dd"
  endif
endfunc

" Note: From one bracket to the one that closes it, and back: "(" to ")", "[" to
" "]", "{" to "}". Vim already PAINTS the pair under the cursor; this walks to
" it.
"
" Note: It is the "%" of Vim, which needs no help from anybody, given a key a
" conventional editor would look for. In insert mode it goes out and back with a
" "<C-o>", and in visual it takes the selection with it -- which is how you grab
" a whole block from one bracket to the other.
"
" Note: This key used to be the visual block, which is now on F2->b! By Questor
nnoremap <silent> <C-b> %
inoremap <silent> <C-b> <C-o>%
vnoremap <silent> <C-b> %

" Note: When enter "visual block" mode and allows select any area! By Questor
func! GrooVim_SetVisualBlock() range abort
  if &virtualedit == "onemore"
    set virtualedit=all
  endif
endfunc

" Note: Avoid "accidents" with "Ctrl+z"! "<nop>" equates to a "null" command! By Questor
nnoremap <silent> <C-z> <Nop>
inoremap <silent> <C-z> <Nop>
vnoremap <silent> <C-z> <Nop>

" Note: Allows "undo"/"redo" on normal mode homogeneously! By Questor
nnoremap <silent> <C-u> u

" Note: Allows undo in a conventional way in the visual mode! By Questor
vnoremap <silent> <C-u> :<C-u>call GrooVim_VisualUndo()<cr>v
func! GrooVim_VisualUndo() range abort
  exec "norm u"
endfunc

" Note: Allows redo in a conventional way in the visual mode! By Questor
vnoremap <silent> <C-r> :<C-u>call GrooVim_VisualRedo()<cr>v
func! GrooVim_VisualRedo() range abort
  if !GrooVim_CanChange() | return | endif
  exec "norm \<C-r>"
endfunc

" Note: Allows undo in a conventional way in the insert mode! By Questor
inoremap <silent> <script> <C-u> <Esc><bar>:call GrooVim_InsertUndo()<cr>i
func! GrooVim_InsertUndo() abort
  exec "norm u"
endfunc

" Note: Allows redo in a conventional way in the insert mode! By Questor
inoremap <silent> <script> <C-r> <Esc><bar>:call GrooVim_InsertRedo()<cr>i
func! GrooVim_InsertRedo() abort
  if !GrooVim_CanChange() | return | endif
  exec "norm \<C-r>"
endfunc

" Note: Allows "Space" in normal mode! By Questor
noremap <silent> <script> <Space> :call GrooVim_SpaceOnNormalMode()<cr>
func! GrooVim_SpaceOnNormalMode() abort
  exec "norm i\<Space>"
endfunc

" Note: Walking the windows of a tab, both ways.
"
" Note: It was "Ctrl+w", which only ever went FORWARD -- and took from Vim the
" key every window command of it begins with, and from insert mode the "delete
" the word behind" that every terminal has. Both are back to being themselves.
"
" Note: Alt and not Ctrl, and this is not a taste: a terminal has no way of
" sending "Ctrl" with a comma. The keyboard table of Konsole has no entry for
" it, and with no entry what arrives is the bare "," -- measured in its own
" default.keytab, which names no Comma and no Period. Alt is sent as an "Esc"
" in front of the character, which every terminal does and which crosses an SSH
" the same way.
"
" Note: And the line below is what makes it arrive as a KEY. Vim does not read
" an "Esc" in front of a character as Alt: ":h :map-alt-keys" names Konsole and
" says so -- "some mainstream terminals like gnome-terminal and konsole use the
" ESC prefix", and Vim "doesn't know what happened". The mapping was there and
" the key did nothing; measured, window 1 of 2 before and window 1 after.
" Telling Vim which sequence the key IS, the mapping answers: measured again,
" window 2 and then back to 1.
"
" Note: Alt with an ARROW never needed this -- "Alt+Left" and the others are
" sent as one whole escape sequence that Vim already knows. It is the printable
" characters that arrive as two.
"
" Note: The price is that an "Esc" typed and a "," typed right after it, inside
" "ttimeoutlen", now read as Alt and comma. That is the price of every Alt
" mapping in every terminal, and 150ms is a long time for two fingers.
"
" Note: In a "try", and only in a terminal: a Vim with no terminal codes to set
" throws, and there the key works on its own! By Questor
if !has("gui_running")
  try
    exec "set <A-,>=\<Esc>,"
    exec "set <A-.>=\<Esc>."
  catch
  endtry
endif

nnoremap <silent> <A-,> <C-w>W
inoremap <silent> <A-,> <Esc><C-w>W
vnoremap <silent> <A-,> <Esc><C-w>W
nnoremap <silent> <A-.> <C-w>w
inoremap <silent> <A-.> <Esc><C-w>w
vnoremap <silent> <A-.> <Esc><C-w>w

" Note: Allows yank a line without the return character! By Questor
nnoremap <silent> yy 0y$

" Note: Through GrooVim_ClipPaste and not a plain "P": with OSC 52 in use the
" "+" register is unreadable and "P" answered "E353: Nothing in register +" --
" see the long note at that function! By Questor
nnoremap <silent> p :call GrooVim_ClipPaste("n")<cr>
nnoremap <silent> <C-v> :call GrooVim_ClipPaste("n")<cr>

" Note: Allows "normal" paste in insert mode (no line breaks and without need of
" "Shift" key) (Ctrl+v)! By Questor
inoremap <silent> <C-v> <C-o>:call GrooVim_ClipPaste("i")<cr>

" Note: Allows cut to insert mode in a conventional manner (Ctrl-x/Ctrl-v cycle)
" (do not need the "Shift" key)! By Questor
vnoremap <silent> <expr> <C-x> GrooVim_KeysIfCanChange("di")

" Note: Allows copy to insert mode in a conventional manner (Ctrl-c/Ctrl-v cycle)
" (do not need the "Shift" key)! By Questor
" Note: Same shape as the Ctrl-x above on purpose: in an editor without modes you
" simply keep typing after copying or cutting, and landing on insert is what
" comes closest to that! By Questor
" Note: Copies and comes back to typing, which is what a conventional editor
" leaves you able to do after a copy.
"
" Note: The "i" only where typing is POSSIBLE. On a buffer you cannot change --
" the help, the occurrence list -- it answered "E21: Cannot make changes,
" 'modifiable' is off" over a command that changes nothing! By Questor
" Note: The "i" is typed by the MAPPING, the way it always was -- the function
" only copies and puts the cursor back.
"
" Note: A case cannot see that it worked. "feedkeys(..., \"x\")" ENDS insert mode
" when the keys it was given run out, so a case that presses this and asks
" "mode()" is answered "n" -- and it answers "n" for the plain "yi" that was here
" before, which is how I know it is the asking and not the answer! By Questor
vnoremap <expr> <C-c> "\<Cmd>call GrooVim_CopyHere()\<cr>" . (&modifiable ? "i" : "")

" Note: Delete and backspace without yank! By Questor
nnoremap d "_d
nnoremap x "_x
vnoremap x "_x

" Note: Paste without yank (visual mode)! By Questor
vnoremap <silent> p :<C-u>call GrooVim_ClipPaste("v")<cr>
vnoremap <silent> <C-v> :<C-u>call GrooVim_ClipPaste("v")<cr>

" Note: "Normal" movement with "Ctrl+Right"! By Questor
nmap <silent> <C-Right> e
imap <silent> <C-Right> <C-o>e<Right>
vmap <silent> <C-Right> e

" Note: "Normal" movement with "Ctrl+Left"! By Questor
nmap <silent> <C-Left> b
imap <silent> <C-Left> <C-o>b
vmap <silent> <C-Left> b

" Note: The <script> parameter prevents mapping to be overridden by a plugin! By Questor

" Note: Allows "multimode" use of enter key in a conventional way! By Questor
nnoremap <silent> <script> <Enter> :call GrooVim_NormalEnterOnNormalMode()<cr>
func! GrooVim_NormalEnterOnNormalMode() abort

  " Note: In a quickfix window, Enter belongs to Vim: it OPENS the line you are
  " on. And it is not a mapping there, it is what the window does -- so a
  " mapping of ours, which is global, went over it and the list could not be
  " used at all. Measured on the bookmark list: the Enter answered "This one
  " cannot be changed!" and nothing opened.
  "
  " Note: This is every quickfix and location list, not only that one: the list
  " of a "make", of a "grep", of anything. A buffer with keys of its own -- the
  " tree of NERDTree -- needs nothing here, because a mapping of a BUFFER
  " already wins over a global one! By Questor
  if &buftype ==# "quickfix"
    exec "normal! \<CR>"
    return
  endif

  if !GrooVim_CanChange() | return | endif
  exec "norm i\<cr>\<Esc>"
endfunc

" Note: "Normal" backspace/delete in visual mode! By Questor
vnoremap <silent> <expr> <Backspace> GrooVim_KeysIfCanChange('"_x')
vnoremap <silent> <expr> <Del> GrooVim_KeysIfCanChange('"_d')

" Note: Allows "multimode" use of backspace key in a conventional way! By Questor
nmap <silent> <script> <Backspace> :call GrooVim_NormalBackspace()<cr>

func! GrooVim_NormalBackspace() abort

  if !GrooVim_CanChange() | return | endif

  let l:continue = 1

  if col(".") == 1 && l:continue == 1
    " call GrooVim_PauseExecution("A")
    call feedkeys("\i")
    call feedkeys("\<Backspace>")
    call feedkeys("\<Esc>")
    let l:continue = 0
  endif

  if col(".") > 1 && l:continue == 1
    " call GrooVim_PauseExecution("A")
    call feedkeys("\<Left>")
    call feedkeys("\"_x")
    let l:continue = 0
  endif

endfunc

" Note:  Move to the next tab! By Questor
nnoremap <silent> <C-Up> :tabnext<cr>
inoremap <silent> <C-Up> <C-O>:tabnext<cr>
vnoremap <silent> <C-Up> :<C-U>tabnext<cr>v

" Note:  Move to the previous tab! By Questor
nnoremap <silent> <C-Down> :tabprevious<cr>
inoremap <silent> <C-Down> <C-O>:tabprevious<cr>
vnoremap <silent> <C-Down> :<C-U>tabprevious<cr>v

" Note: Change the POSITION of the current tab, dragging it along the tab line.
"
" Note: The same direction as the keys that walk the tabs, plus "Shift": "<C-Up>"
" goes to the next tab, so "<C-S-Up>" carries the tab THERE. Notepad++ drags the
" tab with the mouse; in a terminal the keyboard is what there is.
"
" Note: At either end nothing happens, the way Notepad++ stops at the edge. A
" message on every press of a key you hold down would be noise! By Questor
func! GrooVim_TabMove(step) abort
  let l:target = tabpagenr() + a:step
  if l:target < 1 || l:target > tabpagenr("$")
    return
  endif
  exec "tabmove " . (a:step > 0 ? "+1" : "-1")
endfunc

nnoremap <silent> <C-S-Up> :call GrooVim_TabMove(1)<cr>
inoremap <silent> <C-S-Up> <C-O>:call GrooVim_TabMove(1)<cr>
vnoremap <silent> <C-S-Up> :<C-U>call GrooVim_TabMove(1)<cr>gv

nnoremap <silent> <C-S-Down> :call GrooVim_TabMove(-1)<cr>
inoremap <silent> <C-S-Down> <C-O>:call GrooVim_TabMove(-1)<cr>
vnoremap <silent> <C-S-Down> :<C-U>call GrooVim_TabMove(-1)<cr>gv

" Note: Allows "multimode" use of the Del key! By Questor
func! GrooVim_NormalDel() abort

  if !GrooVim_CanChange() | return | endif

  let l:continue = 1

  " Note: This workaround is necessary when the line is empty to remove it! By Questor
  if getline(".") == "" && l:continue == 1
    call feedkeys("_dd")
    " call feedkeys("0")
    let l:continue = 0
  endif

  if col(".") == col("$") && l:continue == 1
    call feedkeys("\i")
    call feedkeys("\<Right>")
    call feedkeys("\<Del>")
    call feedkeys("\<Esc>")
    let l:continue = 0
  endif

  if l:continue == 1
    call feedkeys("\"_x")
    let l:continue = 0
  endif

endfunc

" Note: "Multimode" tab! By Questor
nnoremap <silent> <Tab> :call GrooVim_NormalTab()<cr>

" Note: Allows Tab on normal mode when the line is empty! By Questor
func! GrooVim_NormalTab() abort
  if !GrooVim_CanChange() | return | endif
  if col(".") == 1 && getline(".") == ""
    exec "normal i\<Tab>"
  else
    exec "normal >>"
    if len(split(getline("."), '\zs')) == col(".")
      exec "normal \<Right>"
    endif
  endif
endfunc

inoremap <silent> <expr> <S-Tab> GrooVim_KeysIfCanChange("\<C-o><<")
nnoremap <silent> <expr> <S-Tab> GrooVim_KeysIfCanChange("<<")
vnoremap <silent> <expr> <Tab> GrooVim_KeysIfCanChange(">>\<Esc>gv")
vnoremap <silent> <expr> <S-Tab> GrooVim_KeysIfCanChange("<<\<Esc>gv")

" Note: Allows Tab on normal mode when the line is empty! By Questor
inoremap <silent> <S-Down> <Esc>v:<C-u>call GrooVim_AdjustOnEnterVisualMode()<cr>v

" Note: Exit visual mode! Questor
vnoremap <silent> <S-Down> <Esc>:call GrooVim_VirtualEditAdjust()<cr>

" Note: Leaves the current mode with "<S-Up>" or "<S-Down>"! By Questor
inoremap <silent> <S-Up> <Esc>:call GrooVim_VirtualEditAdjust()<cr>
nnoremap <silent> <S-Down> :call GrooVim_AdjustOnEnterVisualMode()<cr>v

" Note: The "<Esc>" "case" has influence in the code! By Questor

" Note: Allows adjust the "set virtualedit=onemore" parameter when exit the current
" mode you are! By Questor
func! GrooVim_VirtualEditAdjust() range abort
  set virtualedit=onemore
endfunc

" Note: Enter in insert mode simply and quickly!! By Questor
vnoremap <silent> <script> <S-Up> <Esc>i
nnoremap <silent> <script> <S-Up> i

" Note: Allows adjust the "set virtualedit=onemore" parameter when enter visual
" mode! By Questor
nnoremap <silent> <script> v :<C-u>call GrooVim_AdjustOnEnterVisualMode()<cr>v
func! GrooVim_AdjustOnEnterVisualMode() range abort
  set virtualedit=onemore
endfunc

" Note: Like tabdo but restore the current tab! By Questor
let g:tryCathOnTabDo = 0

" Note: With "g:keepCursorOnTabDo" the cursor of EVERY tab goes back to where it
" was, not only the tab you came from: ":tabdo %s" walks through all of them and
" leaves each cursor on its own last replaced line! By Questor
let g:keepCursorOnTabDo = 0
let g:GrooVim_TabDoViews = {}

" Note: Called through "tabdo", so they run once per tab and each one sees its own
" "tabpagenr()"! By Questor
func! GrooVim_TabDoViewSave() abort
  let g:GrooVim_TabDoViews[tabpagenr()] = winsaveview()
endfunc

func! GrooVim_TabDoViewRestore() abort
  if has_key(g:GrooVim_TabDoViews, tabpagenr())
    call winrestview(g:GrooVim_TabDoViews[tabpagenr()])
  endif
endfunc

func! GrooVim_TabDo(command) abort
  let currTab=tabpagenr()
  " Note: "noautocmd" because this pass is pure bookkeeping and must not fire the
  " tab events that the real command fires! By Questor
  if g:keepCursorOnTabDo == 1
    let g:GrooVim_TabDoViews = {}
    silent noautocmd tabdo call GrooVim_TabDoViewSave()
    exec "noautocmd tabn " . currTab
  endif
  if g:tryCathOnTabDo == 0
    exec "tabdo " . a:command
  elseif g:tryCathOnTabDo == 1
    try
      exec "tabdo " . a:command
    catch
    endtry
  endif
  if g:keepCursorOnTabDo == 1
    silent noautocmd tabdo call GrooVim_TabDoViewRestore()
  endif
  exec "tabn " . currTab
endfunc
com! -nargs=+ -complete=command Tabdo call GrooVim_TabDo(<q-args>)

" Note: The double click is Vim's own.
"
" Note: There was a mapping here that did "viw" -- which is what Vim does on a
" double click anyway, ":h double-click" -- and, before that, SLEPT 250ms
" reading the keyboard, in case a "z" came: then it searched for the word. So
" every double click waited a quarter of a second to do what Vim does at once,
" for a key nothing ever wrote down. Searching for the word under the cursor is
" F3->m and the panel it opens! By Questor

