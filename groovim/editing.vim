" Note: Scrolls with the wheel allowing the cursor over "invalid" areas! By Questor
func! GrooVim_ScrollAdm(mod, direction) range abort
  if &virtualedit == "onemore"
    set virtualedit=all
  endif

  if a:mod == "v"
    exec "norm gv"
  endif

  if a:direction == "u"
    exec "norm \<Up>\<Up>\<Up>"
  elseif a:direction == "d"
    exec "norm \<Down>\<Down>\<Down>"
  endif

  let g:onMoveScreen = 1
endfunc

" Note: Serves to avoid the side effect of capslock status checking! By Questor
nnoremap <silent> <LeftMouse> :let g:onMoveScreen = 1<cr><LeftMouse>

nnoremap <silent> <C-b> <Esc>:call GrooVim_SetVisualBlock()<cr><C-v>
inoremap <silent> <C-b> <Esc>:call GrooVim_SetVisualBlock()<cr><C-v>
vnoremap <silent> <C-b> <Esc>:call GrooVim_SetVisualBlock()<cr><C-v>

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
  exec "norm \<C-r>"
endfunc

" Note: Allows "Space" in normal mode! By Questor
noremap <silent> <script> <Space> :call GrooVim_SpaceOnNormalMode()<cr>
func! GrooVim_SpaceOnNormalMode() abort
  exec "norm i\<Space>"
endfunc

" Note: Allows faster switching between windows with "Ctrl+w"! By Questor
nnoremap <silent> <C-w> <C-w><C-w>
inoremap <silent> <C-w> <Esc><C-w><C-w>
vnoremap <silent> <C-w> <Esc><C-w><C-w>

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
vnoremap <silent> <C-x> di

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
vnoremap <silent> <expr> <C-c> ":\<C-u>call GrooVim_CopyHere()\<cr>" . (&modifiable ? "i" : "")

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
  exec "norm i\<cr>\<Esc>"
endfunc

" Note: "Normal" backspace/delete in visual mode! By Questor
vmap <silent> <script> <Backspace> "_x
vmap <silent> <script> <Del> "_d

" Note: Allows "multimode" use of backspace key in a conventional way! By Questor
nmap <silent> <script> <Backspace> :call GrooVim_NormalBackspace()<cr>

func! GrooVim_NormalBackspace() abort

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
  if col(".") == 1 && getline(".") == ""
    exec "normal i\<Tab>"
  else
    exec "normal >>"
    if len(split(getline("."), '\zs')) == col(".")
      exec "normal \<Right>"
    endif
  endif
endfunc

inoremap <silent> <S-Tab> <C-o><<
nnoremap <silent> <S-Tab> <<
vnoremap <silent> <Tab> >><Esc>gv
vnoremap <silent> <S-Tab> <<<Esc>gv

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

nnoremap <silent> <script> <2-Leftmouse> :call GrooVim_SelectNSearch(0, "n")<cr>
inoremap <silent> <script> <2-Leftmouse> <Esc>:call GrooVim_SelectNSearch(0, "i")<cr>
vnoremap <silent> <script> <2-Leftmouse> :<C-u>call GrooVim_SelectNSearch(0, "v")<cr>

