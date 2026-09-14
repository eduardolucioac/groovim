" The "F5" group (file commands) and the macro that stops with the same keys.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

let g:GT_MACRO = []

func! GT_Body()
  " ---- F5 became a "super" key, like F2, F3 and F4
  call GT_Ok("F5 calls CommandZ in normal", maparg("<F5>", "n") =~ 'CommandZ("F5"', "   [" . maparg("<F5>", "n") . "]")
  call GT_Ok("F5 calls CommandZ in insert", maparg("<F5>", "i") =~ 'CommandZ("F5"', "")
  call GT_Ok("F5 calls CommandZ in visual", maparg("<F5>", "v") =~ 'CommandZ("F5"', "")
  call GT_Ok("F5 no longer stops the macro by itself", maparg("<F5>", "n") !~ "norm q", "")

  " ---- closing asks instead of refusing
  call GT_Ok("the close that asks exists", exists("*GrooVim_CloseAsking"), "")

  " ---- F5 + s saves
  let file = g:GT_OUT . "/saved_by_f5.txt"
  call delete(file)
  exec "edit " . file
  call setline(1, "written by F5")
  call GT_Ok("before saving the file does not exist", !filereadable(file), "")
  call feedkeys("\<F5>s", "x")
  call GT_Ok("F5 + s wrote it to disk", filereadable(file) &&
    \ readfile(file) ==# ["written by F5"], "   " . string(filereadable(file) ? readfile(file) : []))
  call GT_Ok("  and the buffer is no longer modified", &modified == 0, "")

  " ---- F5 + a saves all of them
  let other = g:GT_OUT . "/saved_by_f5_two.txt"
  call delete(other)
  call setline(1, "the first one changed again")
  exec "tabnew " . other
  call setline(1, "the second one")
  call feedkeys("\<F5>a", "x")
  call GT_Ok("F5 + a wrote both", filereadable(other) &&
    \ readfile(file) ==# ["the first one changed again"] && readfile(other) ==# ["the second one"],
    \ "   " . string(readfile(file)) . " " . string(filereadable(other) ? readfile(other) : []))
  tabonly!
  call delete(file) | call delete(other)

  " ---- the macro: the same keys start it and stop it
  "
  " The steps wait for the condition instead of counting time: with "t" feedkeys
  " only queues, and Vim processes it when it gets back to the main loop.
  exec "edit " . g:GT_FIX . "/macro.txt"
  call cursor(1, 1)
  call feedkeys("\<F2>q", "t")
  call GT_When('reg_recording() != ""', "GT_MacroRecording")
endfunc

func! GT_MacroRecording()
  call GT_Ok("F2 + q started recording", reg_recording() ==# "a", "   [" . reg_recording() . "]")
  call feedkeys("A;\<Esc>j", "t")
  call GT_When('getline(1) =~ ";$"', "GT_MacroTyped")
endfunc

func! GT_MacroTyped()
  call feedkeys("\<F2>q", "t")
  call GT_When('reg_recording() == ""', "GT_MacroStopped")
endfunc

func! GT_MacroStopped()
  call GT_Ok("F2 + q again stopped it", reg_recording() ==# "", "   [" . reg_recording() . "]")
  call GT_Ok("the register did not keep the keys that stopped it", getreg("a") ==# "A;\<Esc>j",
    \ "   [" . strtrans(getreg("a")) . "]   (the F2 and the q do go into the recording)")
  call feedkeys("\<F2>w", "t")
  call GT_When('getline(2) =~ ";$"', "GT_MacroRanOnce")
endfunc

func! GT_MacroRanOnce()
  call feedkeys("\<F2>w", "t")
  call GT_When('getline(3) =~ ";$"', "GT_MacroRanTwice")
endfunc

func! GT_MacroRanTwice()
  call GT_Ok("the macro runs, and runs again",
    \ getline(1, "$") ==# ["item alpha;", "item beta;", "item gamma;", "item delta", "item epsilon"],
    \ "   " . string(getline(1, "$")))
  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
