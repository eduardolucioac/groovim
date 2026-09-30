" Where GrooVim IS, and where this run writes what it leaves behind.
"
" Normally the same directory -- there is only one of you. Under "sudo" it is
" not: the code, the plugins and the settings go on coming from the one
" installation, which is the point of having one, but a session written by root
" into that directory would be owned by root, and its owner could not write it
" again.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

func! GT_Body()

  " ---- with nobody else involved, the two are one
  call GT_Ok("the installation and the traces are the same place by default",
    \ g:GrooVim_State ==# g:GrooVim_Home,
    \ "   [" . g:GrooVim_Home . "]")

  " ---- what belongs to the INSTALLATION, and is read
  call GT_Ok("the code and the plugins come from the installation",
    \ split(&runtimepath, ",")[0] ==# g:GrooVim_Home,
    \ "   [" . split(&runtimepath, ",")[0] . "]")
  call GT_Ok("and so do the saved options, which are configuration",
    \ stridx(g:GrooVim_OptsFile, g:GrooVim_Home) == 0,
    \ "   [" . g:GrooVim_OptsFile . "]")
  call GT_Ok("and the place a clipboard tool may be dropped by hand",
    \ stridx(g:GrooVim_ClipBinDir, g:GrooVim_Home) == 0,
    \ "   [" . g:GrooVim_ClipBinDir . "]")

  " ---- what this RUN writes, and must not land in somebody else's directory
  for l:pair in [["the session", g:GrooVim_SessionFile],
    \ ["the undo", g:GrooVim_UndoDir],
    \ ["the viminfo", &viminfofile],
    \ ["the clipboard file", g:GrooVim_ClipFile]]
    call GT_Ok(l:pair[0] . " is written where the traces go",
      \ stridx(l:pair[1], g:GrooVim_State) == 0, "   [" . l:pair[1] . "]")
  endfor

  " ---- and the two really can be told apart
  "
  " This is what the "groovim" command does for anyone who is not the user
  " GrooVim was installed for.
  call GT_Ok("GROOVIM_STATE is what pulls the two apart",
    \ GT_SourceLines()->join("\n") =~ "GROOVIM_STATE",
    \ "   (the .vimrc reads it)")
  call GT_Ok("  and the command sets it for whoever is not the owner",
    \ filereadable(expand("~/.local/bin/groovim"))
    \ ? join(readfile(expand("~/.local/bin/groovim")), "\n") =~ "GROOVIM_STATE"
    \ : 1,
    \ "   " . (filereadable(expand("~/.local/bin/groovim")) ? "" : "(not installed here)"))

  " ---- and the battery travels with what it tests
  "
  " The tests are ABOUT the installation: they run on the Vim it built, and the
  " ".vimrc" they read by default is the one beside them -- which, once they are
  " installed, is the installed one. Whoever installed GrooVim can ask it whether
  " it works without going back for the project.
  if !GT_Project()
    call GT_NotTheProject("the installer taking the battery along")
  else
    let l:installer = fnamemodify($GROOVIM_TEST_VIMRC, ":h") . "/install.sh"
    let l:text = join(readfile(l:installer), "\n")
    call GT_Ok("the installer takes the battery along",
      \ l:text =~ 'cp -r "$from/tests" "$to/tests"',
      \ "   (so " . g:GrooVim_Home . "/tests/run.sh is there after installing)")
    call GT_Ok("  and leaves no results of another machine in it",
      \ l:text =~ 'rm -rf "$to/tests/results"',
      \ "   (green answers nobody produced here are worse than none)")
    call GT_Ok("  and says so when it ends",
      \ l:text =~ "Check it with:", "")
  endif

  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
