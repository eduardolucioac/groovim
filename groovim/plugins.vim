"$$$$$$$$$$$$$$$$$$$$$$$$$$
"ENABLE PLUGINS
"$$$$$$$$$$$$$

" Note: Is a given plugin installed? Looks into the native package directories
" of Vim 8 and later AND into the "bundle" directory of Pathogen, so both ways
" of installing are recognized! By Questor
func! GrooVim_HasPlugin(name) abort
  for l:place in ["pack/*/start/", "pack/*/opt/", "bundle/"]
    if !empty(glob(g:GrooVim_Home . "/" . l:place . a:name, 0, 1))
      return 1
    endif
  endfor
  return 0
endfunc

" Note: Master switch: set it to 0 to ignore every plugin! By Questor
let g:enable_all_plugins = get(g:, "enable_all_plugins", 1)

" Note: The master switch is folded into each of the three below, so that every
" one of them is the ONE answer about its plugin. It used to be asked again at
" each place that used them -- "if g:enable_nerdtree_vim == 1 &&
" g:enable_all_plugins == 1" -- and a fourth reader that forgot the second half
" would see a plugin that is off as on! By Questor

" Note: Each plugin is now DETECTED instead of assumed. GrooVim promises to work
" depending only on the contents of this ".vimrc" (the "no plugin scenario"), so
" whatever is not installed simply stays quiet instead of failing. Set any of
" these before sourcing GrooVim to force a value! By Questor

" Note: tcomment.vim! By Questor
let g:enable_tcomment_vim = get(g:, "enable_tcomment_vim", GrooVim_HasPlugin("tcomment_vim")) && g:enable_all_plugins

" Note: nerdtree.vim! By Questor
let g:enable_nerdtree_vim = get(g:, "enable_nerdtree_vim", GrooVim_HasPlugin("nerdtree")) && g:enable_all_plugins

" Note: debugger.vim! No debug plugin is installed by the README instructions,
" so this one stays off unless you ask for it! By Questor

" Note: move.vim! By Questor
let g:enable_move_vim = get(g:, "enable_move_vim", GrooVim_HasPlugin("vim-move")) && g:enable_all_plugins

" Note: vim-bookmarks! By Questor
let g:enable_vim_bookmarks = get(g:, "enable_vim_bookmarks", GrooVim_HasPlugin("vim-bookmarks")) && g:enable_all_plugins

"$$$$$$$$$$$$$$$$$$$$$$$$$$

"$$$$$$$$$$$$$$$$$$$$$$$$$$
"PERFORMANCE
"$$$$$$$$$$$$$

" Note: You got a fast terminal! By Questor
set ttyfast

" Note: Increase scroll speed! By Questor
set ttyscroll=3

" Note: Remove cursor effects to improve performance! By Questor
set nocursorcolumn
set nocursorline

" Note: Limit the scope of syntax in very long lines to improve performance! By Questor
set synmaxcol=1000

" Note: Don't redraw while executing macros (good performance config)!
" Causes scroll "flickering"! By Questor
" set lazyredraw

