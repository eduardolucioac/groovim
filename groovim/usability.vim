" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
" USABILITY
" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" The settings that decide how the editor feels under the hands: the word wrap
" of the View menu, how much Vim remembers, what Backspace is allowed to delete,
" and the search that ignores case until you type one.

" $$$$$$$$$$$$$$$$$$$$$$$

" Note: Always show what mode we're currently editing in.
set showmode

" Note: Word wrap, the one of the View menu of Notepad++ (inspiration). Off by
" default, which is what GrooVim always did, and asked on the view screen of
" "F5->c".
"
" "linebreak" goes with it, and it is not an extra: what Notepad++ does is break
" the line at a SPACE, and Vim without "linebreak" breaks in the middle of a
" word. The restriction that "linebreak" did nothing while "list" was on is of
" an older Vim -- GrooVim asks for 9.2, where the two work together, and "list"
" here is always on because the guides need it.
"
" No autocmd to spread it: it reaches the window you are on and becomes the
" default of every window opened afterwards, which is what a preference should
" do. Anything that reimposed it on every "WinEnter" would take the "wrap" away
" from the help and from the panels, which ask for it themselves.
let g:GrooVim_WordWrap = get(g:, "GrooVim_WordWrap", 0)
" Note: The default of every window from now on, and the window you are on --
" unless the window you are on is an ACCESSORY. A panel always wraps and the
" help always wraps, whatever your documents are set to: they are lists and
" text, and a line of them running off the screen is an answer you cannot read.
"
" A plain ":set" would have reached them, because ":set" on a window option
" writes the global value AND the local one of the window you happen to be
" standing in -- and you may well be standing in the list when you turn the word
" wrap off. Measured: it came back "nowrap" and the list had to be closed and
" opened again to read it.
func! GrooVim_WordWrapSet() abort
  let &g:wrap = g:GrooVim_WordWrap
  let &g:linebreak = g:GrooVim_WordWrap

  if !GrooVim_IsHelperBuffer(bufname("%"))
    let &l:wrap = g:GrooVim_WordWrap
    let &l:linebreak = g:GrooVim_WordWrap
  endif
endfunc
call GrooVim_WordWrapSet()

" Note: Allow backspacing over everything in insert mode.
set backspace=indent,eol,start

" Note: Remember more commands and search history.
set history=1000

" Note: Use many levels of undo.
set undolevels=1000

" Note: Ignore case when searching. Tip: When searching try to be smart about
" cases: `set smartcase`.
set ignorecase

" Note: Makes search act like search in modern browsers ("highlight" occurrences
" already in typing).
set incsearch

" Note: Search/replace "globally" (on a line) by default.
set gdefault

" Note: Return to last edit position when opening files (you want this!).
autocmd! BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif
set viminfo^=%

" Note: Turn persistent undo on means that you can undo even when you close a
" buffer/VIM.
"
" The directory must exist, otherwise "undofile" silently fails to write the
" undo history.
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

" Tip: Always set autoindenting on: `set autoindent`.

" Tip: Copy the previous indentation on autoindenting: `set copyindent`.

"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
"PLUGINS CONFIGURATION
"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

"* NERDTree

" Note: Store the bookmarks file.
let NERDTreeBookmarksFile = g:GrooVim_State . "/NERDTreeBookmarks"

" Note: Show the bookmarks table on startup.
let NERDTreeShowBookmarks = 1

" Note: Show hidden files, too.
let NERDTreeShowFiles = 1

" Tip: Quit on opening files from the tree: `let NERDTreeQuitOnOpen = 1`.

" Note: Highlight the selected entry in the tree.
let NERDTreeHighlightCursorline = 1

" Note: Use a single click to fold/unfold directories and a double click to open
" files.
let NERDTreeMouseMode=2

" Note: NERDTree always open on the right side.
let NERDTreeWinPos = "right"

" Note: A file chosen in the tree opens in a TAB OF ITS OWN.
"
" It used to open in the window you came from, which means the file you were
" reading is gone from the screen -- you asked to open one more, not to swap the
" one you had. Every editor with a file tree opens a document beside the ones
" already open, and the tabs of GrooVim are where the open ones live.
"
" "reuse" is kept as it was: a file already open somewhere is JUMPED to instead
" of opened again, which is what you meant by choosing it.
"
" A directory is untouched -- there "open" means unfold, and a folder in a tab
" of its own would be a tab with a tree in it.
let g:NERDTreeCustomOpenArgs =
 \ {"file": {"reuse": "all", "where": "t", "keepopen": 1}, "dir": {}}

" Note: And the DOUBLE CLICK opens it the same way, which it did not.
"
" Two doors to the same thing, and only one of them had been given the rule.
" What the setting above reaches is the "custom open" of NERDTree, which is what
" <Enter> is bound to; the double click is bound to another function of the
" plugin ("activateFileNode"), and that one has the old way written INTO it --
" "where: p", the window you came from -- where no setting can reach it.
" Reported from the tree panel: Enter opened a tab and a double click on the
" same file took the place of what was being read.
"
" So the double click is bound to the custom open as well, which is the one
" GrooVim has already described: a tab of its own, and a file already open
" jumped to instead of opened twice.
"
" "override" is not decoration: NERDTree keeps its key maps in a list by key and
" scope and REFUSES to replace one that is already there unless it is told to --
" measured, without it the double click went on opening in the window you came
" from and nothing said why.
"
" At "VimEnter", because the plugins are loaded after this file is read and the
" function that takes a key map does not exist yet when these lines run.
if g:enable_nerdtree_vim

  " Note: WHERE a file chosen in the tree goes: a tab of its own, which is what
  " the setting above says -- unless the page you are on is the empty "new 1"
  " GrooVim opens with, and then it goes IN it.
  "
  " "p" is the window you came from, which on a fresh page IS that page: the
  " tree is beside it and nothing else is open. It is how NERDTree opened files
  " before GrooVim asked for a tab, so the plugin does its own bookkeeping and
  " the tree stays where it is.
  func! GrooVim_TreeOpenArgs() abort

    let l:args = get(get(g:, "NERDTreeCustomOpenArgs", {}), "file",
     \ {"reuse": "all", "where": "t", "keepopen": 1})

    if GrooVim_FreshPageWindow()
      let l:args = extend(copy(l:args), {"where": "p"})
    endif

    return l:args

  endfunc

  func! GrooVim_TreeOpenFile(node) abort
    call a:node.activate(GrooVim_TreeOpenArgs())
  endfunc

  " Note: A bookmark can be a file or a folder, and the folder unfolds instead
  " of opening -- the same two roads the plugin itself takes for them.
  func! GrooVim_TreeOpenBookmark(node) abort
    if a:node.path.isDirectory
      call a:node.activate(b:NERDTree,
       \ get(get(g:, "NERDTreeCustomOpenArgs", {}), "dir", {}))
    else
      call a:node.activate(b:NERDTree, GrooVim_TreeOpenArgs())
    endif
  endfunc

  " Note: BOTH keys that open a file in the tree -- the <Enter> and the double
  " click -- go through the same two functions, so the mouse and the keyboard
  " cannot land in different places. The <Enter> of the tree is the "custom
  " open" of NERDTree, which is a key of its own and can be changed, so it is
  " asked for by name and not spelled out.
  func! GrooVim_TreeOpenKeys() abort

    if !exists("*NERDTreeAddKeyMap")
      return
    endif

    for l:key in ["<2-LeftMouse>", get(g:, "NERDTreeMapCustomOpen", "<CR>")]
      call NERDTreeAddKeyMap({"key": l:key, "scope": "FileNode",
       \ "callback": "GrooVim_TreeOpenFile", "override": 1,
       \ "quickhelpText": "open in a tab of its own"})
      call NERDTreeAddKeyMap({"key": l:key, "scope": "Bookmark",
       \ "callback": "GrooVim_TreeOpenBookmark", "override": 1,
       \ "quickhelpText": "open in a tab of its own"})
    endfor

  endfunc

  augroup GrooVim_TreeMouse
    autocmd!
    autocmd VimEnter * call GrooVim_TreeOpenKeys()
  augroup END

endif

"* move-vim

" Note: Mapping to move-vim.
if g:enable_move_vim

  " Note: TWO settings and not one. The plugin asks which modifier moves a LINE
  " and, separately, which one moves a SELECTION -- and only the first was ever
  " given, so a selection went on waiting for "Alt+j" and "Alt+k", which nobody
  " here presses. Measured: with two lines selected, "Ctrl+J" and "Ctrl+K" left
  " the file exactly as it was, while the same keys moved a single line.
  "
  " It is the same key for both on purpose: moving a line and moving the lines
  " you marked are one idea, and the number of them is not the user's problem.
  let g:move_key_modifier = "C"

  let g:move_key_modifier_visualmode = "C"
  inoremap <silent> <C-k> <C-o>:call GrooVim_Move_Vim_OnInsert("up")<cr>
  inoremap <silent> <C-j> <C-o>:call GrooVim_Move_Vim_OnInsert("down")<cr>

  " Note: This workaround is for the "Move Vim" can be fired in insert mode.
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

