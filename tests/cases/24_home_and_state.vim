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

  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
