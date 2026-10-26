" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
" EDITING
" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" The keys that CHANGE the text and the rules they all answer to: a buffer that
" refuses to be changed, the undo and the redo of a conventional editor, the
" Tab, the Enter and the Backspace of one, and the keys that move a line or
" comment it.

" $$$$$$$$$$$$$$$$$$$$$$$

" Note: The buffer you are on may refuse to be changed. The tree of NERDTree,
" the occurrence list and the help are all like that, for example, and a key
" that edits met them with "E21: Cannot make changes, 'modifiable' is off" over
" the bar -- measured: Enter, Tab, Shift-Tab, Backspace, Del, Ctrl-x, Ctrl-v, p,
" Ctrl-r and the shortcuts that edit, eleven keys of a conventional editor
" answering with the error number of another editor entirely.
"
" ONE function decides and says so, and it is reached two ways: the keys that
" call a function of GrooVim ask it at the door, and the shortcuts of the F keys
" are caught by the net at the end of the dispatch -- which needs no list of
" what edits and what does not, and holds for shortcuts written after today.
"
" "readonly" as well as "modifiable": a file opened with "view", or one without
" write permission, refuses just the same.
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
" back the keys themselves, or nothing at all when the buffer refuses.
func! GrooVim_KeysIfCanChange(keys) abort
  return GrooVim_CanChange() ? a:keys : ""
endfunc

" Note: Scrolls with the wheel allowing the cursor over "invalid" areas.
func! GrooVim_ScrollAdm(mod, direction) range abort
  if &virtualedit == "onemore"
    set virtualedit=all
  endif

  " Note: No "gv" here: the wheel of visual mode comes through "<Cmd>" and the
  " selection was never lost.
  if a:direction == "u"
    exec "norm \<Up>\<Up>\<Up>"
  elseif a:direction == "d"
    exec "norm \<Down>\<Down>\<Down>"
  endif

  let g:onMoveScreen = 1
endfunc

" Note: Serves to avoid the side effect of capslock status checking.
nnoremap <silent> <LeftMouse> :let g:onMoveScreen = 1<cr><LeftMouse>

" Note: Takes the line away, and what was in the transfer area stays there.
"
" The "_" register is the one Vim throws things into, and GrooVim sends every
" delete to it on purpose: in a conventional editor deleting a line does not
" cost you what you copied ten minutes ago.
"
" Over a selection it takes every line the selection touches, whole, which is
" what "the line" means when more than one is in hand.
func! GrooVim_SuppressLine(mode) abort
  if !GrooVim_CanChange() | return | endif
  if a:mode ==# "v"

    " Note: "V" turns the selection into WHOLE lines before it goes. Selecting
    " three characters of a line and asking for the line to be taken away has to
    " take the line, not the three characters.
    exec "normal! gvV\"_d"

  else
    exec "normal! \"_dd"
  endif
endfunc

" Note: From one bracket to the one that closes it, and back: "(" to ")", "[" to
" "]", "{" to "}". Vim already PAINTS the pair under the cursor; this walks to
" it.
"
" It is the "%" of Vim, which needs no help from anybody, given a key a
" conventional editor would look for. In insert mode it goes out and back with a
" "<C-o>", and in visual it takes the selection with it -- which is how you grab
" a whole block from one bracket to the other.
"
" This key used to be the visual block, which is now on F2->b.
nnoremap <silent> <C-b> %
inoremap <silent> <C-b> <C-o>%
vnoremap <silent> <C-b> %

" Note: When enter "visual block" mode and allows select any area.
func! GrooVim_SetVisualBlock() range abort
  if &virtualedit == "onemore"
    set virtualedit=all
  endif
endfunc

" Note: Avoid "accidents" with "Ctrl+z"! "<nop>" equates to a "null" command.
nnoremap <silent> <C-z> <Nop>
inoremap <silent> <C-z> <Nop>
vnoremap <silent> <C-z> <Nop>

" Note: Allows "undo"/"redo" on normal mode homogeneously.
nnoremap <silent> <C-u> u

" Note: Allows undo in a conventional way in the visual mode.
vnoremap <silent> <C-u> :<C-u>call GrooVim_VisualUndo()<cr>v
func! GrooVim_VisualUndo() range abort
  exec "norm u"
endfunc

" Note: Allows redo in a conventional way in the visual mode.
vnoremap <silent> <C-r> :<C-u>call GrooVim_VisualRedo()<cr>v
func! GrooVim_VisualRedo() range abort
  if !GrooVim_CanChange() | return | endif
  exec "norm \<C-r>"
endfunc

" Note: Allows undo in a conventional way in the insert mode.
inoremap <silent> <script> <C-u> <Esc><bar>:call GrooVim_InsertUndo()<cr>i
func! GrooVim_InsertUndo() abort
  exec "norm u"
endfunc

" Note: Allows redo in a conventional way in the insert mode.
inoremap <silent> <script> <C-r> <Esc><bar>:call GrooVim_InsertRedo()<cr>i
func! GrooVim_InsertRedo() abort
  if !GrooVim_CanChange() | return | endif
  exec "norm \<C-r>"
endfunc

" Note: Allows "Space" in normal mode.
"
" Through "norm!" and not "norm", and a buffer that refuses to change is told
" apart before either -- which is the same bug twice.
"
" ":normal" runs its keys THROUGH the mappings, and "i" is a mapping of its own
" inside the tree of NERDTree: it opens the file in a split. So a space pressed
" in the tree ran the "i" of NERDTree, the space itself was left over, came back
" to THIS mapping, which pressed "i" again -- and so on. Measured, one space on
" a folder of the tree: eight "E169: Command too recursive" over a red screen
" and an editor left at a "-- More --" prompt.
"
" "norm!" is the "i" of Vim and nobody else's, and the tree never gets that far
" anyway: it cannot be changed, and GrooVim says so the way it says it
" everywhere else.
noremap <silent> <script> <Space> :call GrooVim_SpaceOnNormalMode()<cr>
func! GrooVim_SpaceOnNormalMode() abort
  if !GrooVim_CanChange()
    return
  endif
  exec "norm! i\<Space>"
endfunc

" Note: Walking the windows of a tab, both ways.
"
" The line below is what makes the key ARRIVE. Vim does not read an "Esc" in
" front of a character as Alt: ":h :map-alt-keys" names Konsole and says so --
" "some mainstream terminals like gnome-terminal and konsole use the ESC
" prefix", and Vim "doesn't know what happened". Without it the mapping is there
" and the key does nothing.
"
" Alt with an ARROW, for example, never needed this -- "Alt+Left" and the others
" are sent as one whole escape sequence that Vim already knows. It is the
" printable characters that arrive as two.
"
" The price is that an "Esc" typed and a "," typed right after it, inside
" "ttimeoutlen", now read as Alt and comma. That is the price of every Alt
" mapping in every terminal, and 150ms is a long time for two fingers.
"
" In a "try", and only in a terminal: a Vim with no terminal codes to set
" throws, and there the key works on its own.
" And the sequence is parked on an F key nobody has, NOT on the name
" "<A-,>". In Vim that name is not a key at all, it is the CHARACTER with the
" eighth bit set: measured, "<A-,>" is "\u00AC" and "<A-.>" is "\u00AE" --
" and "<A-i>" is "e" with an acute, which is how typing a word in Portuguese
" came to jump the screen. Mapping the name maps the letter.
"
" "<F16>" and up are keys Vim knows and no terminal here sends -- Konsole stops
" at F12, read in its own key table -- so the sequence has a carrier of its own
" and the letters stay letters. The help goes on saying Alt+, because that IS
" the key you press; what changed is where GrooVim hangs it.
if !has("gui_running")
  try
    exec "set <F16>=\<Esc>,"
    exec "set <F17>=\<Esc>."
  catch
  endtry
endif

nnoremap <silent> <F16> <C-w>W
inoremap <silent> <F16> <Esc><C-w>W
vnoremap <silent> <F16> <Esc><C-w>W
nnoremap <silent> <F17> <C-w>w
inoremap <silent> <F17> <Esc><C-w>w
vnoremap <silent> <F17> <Esc><C-w>w

" Note: Allows yank a line without the return character.
nnoremap <silent> yy 0y$

" Note: Through GrooVim_ClipPaste and not a plain "P": with OSC 52 in use the
" "+" register is unreadable and "P" answered "E353: Nothing in register +" --
" see the long note at that function.
nnoremap <silent> p :call GrooVim_ClipPaste("n")<cr>
nnoremap <silent> <C-v> :call GrooVim_ClipPaste("n")<cr>

" Note: Allows "normal" paste in insert mode (no line breaks and without need of
" "Shift" key) (Ctrl+v).
inoremap <silent> <C-v> <C-o>:call GrooVim_ClipPaste("i")<cr>

" Note: Allows cut to insert mode in a conventional manner (Ctrl-x/Ctrl-v cycle)
" (do not need the "Shift" key).
vnoremap <silent> <expr> <C-x> GrooVim_KeysIfCanChange("di")

" Note: Allows copy to insert mode in a conventional manner (Ctrl-c/Ctrl-v
" cycle) (do not need the "Shift" key).
"
" Same shape as the Ctrl-x above on purpose: in an editor without modes you
" simply keep typing after copying or cutting, and landing on insert is what
" comes closest to that.
"
" Insert only where typing is POSSIBLE -- on a buffer you cannot change, the
" help or the occurrence list, it would answer "E21" over a command that changes
" nothing -- and only when Vim is not on its way back there BY ITSELF. A
" selection STARTED from insert mode, through a mouse drag or any road via
" "<C-o>", leaves Vim waiting to return to insert as soon as the selection ends,
" and the yank ends it: an "i" typed after the copy would land in the TEXT.
" "GrooVim_CopyHere()" decides, because only after the yank can it be seen --
" "mode(1)" answers "n" when the selection came from normal mode and "niI" when
" insert is waiting.
"
" A case cannot see that it worked: "feedkeys(..., \"x\")" ends insert mode when
" the keys run out, so "mode()" answers "n" whatever the mapping does.
vnoremap <silent> <C-c> <Cmd>call GrooVim_CopyHere()<cr>

" Note: Delete and backspace without yank.
nnoremap d "_d
nnoremap x "_x
vnoremap x "_x

" Note: Paste without yank (visual mode).
vnoremap <silent> p :<C-u>call GrooVim_ClipPaste("v")<cr>
vnoremap <silent> <C-v> :<C-u>call GrooVim_ClipPaste("v")<cr>

" Note: "Normal" movement with "Ctrl+Right".
nmap <silent> <C-Right> e
imap <silent> <C-Right> <C-o>e<Right>
vmap <silent> <C-Right> e

" Note: "Normal" movement with "Ctrl+Left".
nmap <silent> <C-Left> b
imap <silent> <C-Left> <C-o>b
vmap <silent> <C-Left> b

" Note: The <script> parameter prevents mapping to be overridden by a plugin.

" Note: Allows "multimode" use of enter key in a conventional way.
nnoremap <silent> <script> <Enter> :call GrooVim_NormalEnterOnNormalMode()<cr>
func! GrooVim_NormalEnterOnNormalMode() abort

  " Note: In a quickfix window, Enter belongs to Vim: it OPENS the line you are
  " on. And it is not a mapping there, it is what the window does -- so a
  " mapping of ours, which is global, went over it and the list could not be
  " used at all. Measured on the bookmark list: the Enter answered "This one
  " cannot be changed!" and nothing opened.
  "
  " This is every quickfix and location list, not only that one: the list of a
  " "make", of a "grep", of anything. A buffer with keys of its own -- the tree
  " of NERDTree -- needs nothing here, because a mapping of a BUFFER already
  " wins over a global one.
  if &buftype ==# "quickfix"
    exec "normal! \<CR>"
    return
  endif

  if !GrooVim_CanChange() | return | endif
  exec "norm i\<cr>\<Esc>"
endfunc

" Note: "Normal" backspace/delete in visual mode.
vnoremap <silent> <expr> <Backspace> GrooVim_KeysIfCanChange('"_x')
vnoremap <silent> <expr> <Del> GrooVim_KeysIfCanChange('"_d')

" Note: Allows "multimode" use of backspace key in a conventional way.
nmap <silent> <script> <Backspace> :call GrooVim_NormalBackspace()<cr>

func! GrooVim_NormalBackspace() abort

  if !GrooVim_CanChange() | return | endif

  let l:continue = 1

  if col(".") == 1 && l:continue == 1
    call feedkeys("\i")
    call feedkeys("\<Backspace>")
    call feedkeys("\<Esc>")
    let l:continue = 0
  endif

  if col(".") > 1 && l:continue == 1
    call feedkeys("\<Left>")
    call feedkeys("\"_x")
    let l:continue = 0
  endif

endfunc

" Note: Move to the next tab.
nnoremap <silent> <C-Up> :tabnext<cr>
inoremap <silent> <C-Up> <C-O>:tabnext<cr>
vnoremap <silent> <C-Up> :<C-U>tabnext<cr>v

" Note: Move to the previous tab.
nnoremap <silent> <C-Down> :tabprevious<cr>
inoremap <silent> <C-Down> <C-O>:tabprevious<cr>
vnoremap <silent> <C-Down> :<C-U>tabprevious<cr>v

" Note: Change the POSITION of the current tab, dragging it along the tab line.
"
" The same direction as the keys that walk the tabs, plus "Shift": "<C-Up>" goes
" to the next tab, so "<C-S-Up>" carries the tab THERE. Notepad++ drags the tab
" with the mouse; in a terminal the keyboard is what there is.
"
" At either end nothing happens, the way Notepad++ stops at the edge. A message
" on every press of a key you hold down would be noise.
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

" Note: Allows "multimode" use of the Del key.
func! GrooVim_NormalDel() abort

  if !GrooVim_CanChange() | return | endif

  let l:continue = 1

  " Note: This workaround is necessary when the line is empty to remove it.
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

" Note: "Multimode" tab.
nnoremap <silent> <Tab> :call GrooVim_NormalTab()<cr>

" Note: Allows Tab on normal mode when the line is empty.
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

" Note: Allows Tab on normal mode when the line is empty.
inoremap <silent> <S-Down> <Esc>v:<C-u>call GrooVim_AdjustOnEnterVisualMode()<cr>v

" Note: Exit visual mode.
vnoremap <silent> <S-Down> <Esc>:call GrooVim_VirtualEditAdjust()<cr>

" Note: Leaves the current mode with "<S-Up>" or "<S-Down>".
inoremap <silent> <S-Up> <Esc>:call GrooVim_VirtualEditAdjust()<cr>
nnoremap <silent> <S-Down> :call GrooVim_AdjustOnEnterVisualMode()<cr>v

" Note: The "<Esc>" "case" has influence in the code.

" Note: Allows adjust the "set virtualedit=onemore" parameter when exit the
" current mode you are.
func! GrooVim_VirtualEditAdjust() range abort
  set virtualedit=onemore
endfunc

" Note: Enter in insert mode simply and quickly!.
vnoremap <silent> <script> <S-Up> <Esc>i
nnoremap <silent> <script> <S-Up> i

" Note: Allows adjust the "set virtualedit=onemore" parameter when enter visual
" mode.
nnoremap <silent> <script> v :<C-u>call GrooVim_AdjustOnEnterVisualMode()<cr>v
func! GrooVim_AdjustOnEnterVisualMode() range abort
  set virtualedit=onemore
endfunc

" Note: Like tabdo but restore the current tab.
let g:tryCathOnTabDo = 0

" Note: With "g:keepCursorOnTabDo" the cursor of EVERY tab goes back to where it
" was, not only the tab you came from: ":tabdo %s" walks through all of them and
" leaves each cursor on its own last replaced line.
let g:keepCursorOnTabDo = 0
let g:GrooVim_TabDoViews = {}

" Note: Called through "tabdo", so they run once per tab and each one sees its
" own "tabpagenr()".
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

  " Note: "noautocmd" because this pass is pure bookkeeping and must not fire
  " the tab events that the real command fires.
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

