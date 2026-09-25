"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
"USABILITY
"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" Note: Always show what mode we're currently editing in! By Questor
set showmode

" Note: Word wrap, the one of the View menu of Notepad++. Off by default, which
" is what GrooVim always did, and asked on the view screen of "F5->c".
"
" Note: "linebreak" goes with it, and it is not an extra: what Notepad++ does is
" break the line at a SPACE, and Vim without "linebreak" breaks in the middle of
" a word. The restriction that "linebreak" did nothing while "list" was on is of
" an older Vim -- GrooVim asks for 9.2, where the two work together, and "list"
" here is always on because the guides need it.
"
" Note: A plain ":set" and no autocmd to spread it. It reaches the window you are
" on and becomes the default of every window opened afterwards, which is what a
" preference should do -- and it leaves the help window alone, which asks for
" "wrap" of its own and would lose it to anything that reimposed this on every
" "WinEnter"! By Questor
let g:GrooVim_WordWrap = get(g:, "GrooVim_WordWrap", 0)
func! GrooVim_WordWrapSet() abort
  if g:GrooVim_WordWrap
    set wrap linebreak
  else
    set nowrap nolinebreak
  endif
endfunc
call GrooVim_WordWrapSet()

" Note: Allow backspacing over everything in insert mode! By Questor
set backspace=indent,eol,start

" Note: Remember more commands and search history! By Questor
set history=1000

" Note: Use many/muchos levels of undo! By Questor
set undolevels=1000

" Note: Ignore case when searching! By Questor
set ignorecase

" Note: When searching try to be smart about cases! By Questor
" set smartcase

" Note: Makes search act like search in modern browsers ("highlight"
" occurrences already in typing)! By Questor
set incsearch

" Note: Search/replace "globally" (on a line) by default! By Questor
set gdefault

" Note: Return to last edit position when opening files (you want this!)! By Questor
autocmd! BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif
set viminfo^=%

" Note: Bind <F1> to show the keyword under cursor general help that can still be
" entered manually, with :h! By Questor
if has("autocmd")
  augroup vim_files
    autocmd! filetype vim noremap <buffer> <F1> <Esc>:help <C-r><C-w><cr>
    autocmd! filetype vim noremap! <buffer> <F1> <Esc>:help <C-r><C-w><cr>
  augroup end
endif

" Note: Turn persistent undo on means that you can undo even when you close a
" buffer/VIM! By Questor
" Note: The directory must exist, otherwise "undofile" silently fails to write
" the undo history! By Questor
try
  let g:GrooVim_UndoDir = g:GrooVim_State . "/undo"
  if !isdirectory(g:GrooVim_UndoDir)
    call mkdir(g:GrooVim_UndoDir, "p", 0700)
  endif
  exec "set undodir=" . escape(g:GrooVim_UndoDir, " \\")
  set undofile
catch
endtry

"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
"INDENTATION AND SYNTAX
"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" Note: Always set autoindenting on! By Questor
" set autoindent

" Note: Copy the previous indentation on autoindenting! By Questor
" set copyindent

"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
"PLUGINS CONFIGURATION
"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

"* NERDTree

" Note: Store the bookmarks file! By Questor
let NERDTreeBookmarksFile = g:GrooVim_State . "/NERDTreeBookmarks"

" Note: Show the bookmarks table on startup! By Questor
let NERDTreeShowBookmarks = 1

" Note: Show hidden files, too! By Questor
let NERDTreeShowFiles = 1

" Note: Quit on opening files from the tree! By Questor
" let NERDTreeQuitOnOpen = 1

" Note: Highlight the selected entry in the tree! By Questor
let NERDTreeHighlightCursorline = 1

" Note: Use a single click to fold/unfold directories and a double click to open
" files! By Questor
let NERDTreeMouseMode=2

" Note: NERDTree always open on the right side! By Questor
let NERDTreeWinPos = "right"

" Note: A file chosen in the tree opens in a TAB OF ITS OWN.
"
" Note: It used to open in the window you came from, which means the file you
" were reading is gone from the screen -- you asked to open one more, not to
" swap the one you had. Every editor with a file tree opens a document beside
" the ones already open, and the tabs of GrooVim are where the open ones live.
"
" Note: "reuse" is kept as it was: a file already open somewhere is JUMPED to
" instead of opened again, which is what you meant by choosing it.
"
" Note: A directory is untouched -- there "open" means unfold, and a folder in
" a tab of its own would be a tab with a tree in it! By Questor
let g:NERDTreeCustomOpenArgs =
 \ {"file": {"reuse": "all", "where": "t", "keepopen": 1}, "dir": {}}

"* move-vim

" Note: Mapping to move-vim! By Questor
if g:enable_move_vim
  " Note: TWO settings and not one. The plugin asks which modifier moves a LINE
  " and, separately, which one moves a SELECTION -- and only the first was ever
  " given, so a selection went on waiting for "Alt+j" and "Alt+k", which nobody
  " here presses. Measured: with two lines selected, "Ctrl+J" and "Ctrl+K" left
  " the file exactly as it was, while the same keys moved a single line.
  "
  " Note: It is the same key for both on purpose: moving a line and moving the
  " lines you marked are one idea, and the number of them is not the user's
  " problem! By Questor
  let g:move_key_modifier = "C"
  let g:move_key_modifier_visualmode = "C"
  inoremap <silent> <C-k> <C-o>:call GrooVim_Move_Vim_OnInsert("up")<cr>
  inoremap <silent> <C-j> <C-o>:call GrooVim_Move_Vim_OnInsert("down")<cr>
  " Note: This workaround is for the "Move Vim" can be fired in insert mode! By Questor
  func! GrooVim_Move_Vim_OnInsert(direc)
    if a:direc == "up"
      exec "norm \<C-k>"
    elseif a:direc == "down"
      exec "norm \<C-j>"
    endif
  endfun
endif

"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
"ENCODING
"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

set encoding=utf-8
set termencoding=utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,big5,gb2312,latin1

fun! ViewUTF8()
  set encoding=utf-8
  set termencoding=big5
endfun

fun! UTF8()
  set encoding=utf-8
  set termencoding=big5
  set fileencoding=utf-8
  set fileencodings=ucs-bom,big5,utf-8,latin1
endfun

fun! Big5()
  set encoding=big5
  set fileencoding=big5
endfun

