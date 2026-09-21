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

"* vim-bookmarks

" Note: The bookmarks: lines you mark and then walk between, with a sign drawn in
" the margin. It is what the "Search -> Bookmark" menu of Notepad++ does.
"
" Note: Its own keys are OFF. The plugin asks for "mm", "mn", "mp" and more, and
" every one of them takes the "m" of Vim -- which is how you SET A MARK. A plugin
" that comes to help with marks must not eat the marks; the bookmarks answer on
" F4 here, like everything else of GrooVim.
"
" Note: And the file it saves them in lives with the rest of what GrooVim keeps,
" beside the undo history and the bookmarks of the tree, instead of dropping a
" ".vim-bookmarks" in the home directory! By Questor
let g:bookmark_no_default_key_mappings = 1
let g:bookmark_auto_save_file = g:GrooVim_State . "/bookmarks"

" Note: The sign is the one Notepad++ draws, and the line is not painted: a
" bookmark says WHERE, it does not take the colours of the text away! By Questor
let g:bookmark_sign = "\u2691"
let g:bookmark_highlight_lines = 0

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

"* move-vim

" Note: Mapping to move-vim! By Questor
if g:enable_move_vim
  let g:move_key_modifier = "C"
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

