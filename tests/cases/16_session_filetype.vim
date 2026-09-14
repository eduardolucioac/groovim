" A file that comes back from the session comes back AS ITSELF.
"
" A command run from inside an autocmd fires no autocmds of its own unless the
" autocmd asks for it with "++nested". The session is loaded from a "VimEnter",
" so without it the ":edit" written in the session opened every file with no
" "BufRead" -- and with no "BufRead" there is no filetype detection. Measured:
" a ".py" coming back with "&filetype" empty, no syntax, no indent rules and no
" guides, while the same file named on the command line opened as "python".
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

" This part runs during STARTUP, and that is the point: the session has to be on
" disk before the VimEnter that loads it. Sourcing with "-S" is not an autocmd,
" so the ":edit" below detects the filetype the normal way -- and the session is
" written with GrooVim's own "mksession", not with a line made up here.
let g:GrooVim_SessionAuto = 1
let g:GrooVim_SessionFile = g:GT_FIX . "/session_of_16.vim"
exec "edit " . g:GT_FIX . "/irregular.py"
let g:GT_FT_DIRECT = &filetype
let g:GT_SW_DIRECT = &shiftwidth
call GrooVim_SessionSave()
bwipeout!

func! GT_Body()
  call GT_When('bufname("%") =~ "irregular.py"', "GT_Check")
endfunc

func! GT_Check()
  call GT_Ok("opened by hand it is python", g:GT_FT_DIRECT ==# "python", "   [" . g:GT_FT_DIRECT . "]")
  call GT_Ok("the session brought the file back", bufname("%") =~ "irregular.py", "   [" . bufname("%") . "]")
  call GT_Ok("and it came back AS PYTHON", &filetype ==# "python",
    \ "   [" . &filetype . "]   (empty is the defect: the VimEnter was not ++nested)")
  call GT_Ok("with the syntax on", &syntax ==# "python", "   [" . &syntax . "]")
  call GT_Ok("with the width of the language", &shiftwidth == g:GT_SW_DIRECT,
    \ "   (" . &shiftwidth . ", by hand it is " . g:GT_SW_DIRECT . ")")
  call GT_Ok("and with the guides drawn to that width",
    \ strchars(matchstr(&listchars, 'leadmultispace:\zs.*')) == g:GT_SW_DIRECT,
    \ "   [" . matchstr(&listchars, 'leadmultispace:\zs.*') . "]")

  call delete(g:GrooVim_SessionFile)
  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
