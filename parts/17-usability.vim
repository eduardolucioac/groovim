"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
"USABILITY
"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" Note: Always show what mode we're currently editing in! By Questor
set showmode

" Note: Don't wrap lines! By Questor
set nowrap

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
  let g:GrooVim_UndoDir = g:GrooVim_Home . "/undo"
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
let NERDTreeBookmarksFile = g:GrooVim_Home . "/NERDTreeBookmarks"

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
if g:enable_move_vim == 1 && g:enable_all_plugins == 1
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

