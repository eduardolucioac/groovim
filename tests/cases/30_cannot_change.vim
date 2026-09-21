" A buffer that refuses to be changed, and the keys that edit.
"
" The tree of NERDTree, the occurrence list and the help are all "nomodifiable".
" A key that edits met them with "E21: Cannot make changes, 'modifiable' is off"
" over the bar -- measured, eleven of them: Enter, Tab, Shift-Tab, Backspace,
" Del, Ctrl-x, Ctrl-v, p, Ctrl-r and the shortcuts that edit. The error number of
" another editor entirely, in an editor that promises to look like Notepad++.
"
" One function decides and says so, and it is reached two ways: the keys that
" call a function of GrooVim ask it at the door, and the shortcuts of the F keys
" are caught by a net at the end of the dispatch -- which needs no list of what
" edits and what does not, and holds for shortcuts written after today.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

func! GT_Locked()
  enew!
  call setline(1, ["uma linha", "outra", "terceira"])
  setlocal buftype=nofile nomodifiable
  call cursor(1, 3)
  let v:errmsg = ""
  let g:GrooVim_GrooVimBarMsgValue = ""
endfunc

func! GT_Key(name, keys)
  call GT_Locked()
  let l:text = getline(1, "$")
  try
    call feedkeys(a:keys, "x")
  catch
    call GT_Ok(a:name . ": no error from Vim", 0, "   (" . v:exception . ")")
    return
  endtry
  call GT_Ok(a:name . ": no error from Vim", v:errmsg !~ "E21" && v:errmsg !~ "E45",
    \ v:errmsg == "" ? "" : "   [" . v:errmsg . "]")
  call GT_Ok("  and GrooVim says what happened",
    \ g:GrooVim_GrooVimBarMsgValue =~ "cannot be changed",
    \ "   [" . trim(g:GrooVim_GrooVimBarMsgValue) . "]")
  call GT_Ok("  and the text is untouched", getline(1, "$") ==# l:text, "")
endfunc

func! GT_Body()
  for l:one in [["Enter", "\<Enter>"], ["Tab", "\<Tab>"], ["Shift-Tab", "\<S-Tab>"],
    \ ["Backspace", "\<BS>"], ["Del", "\<Del>"], ["Ctrl-v", "\<C-v>"], ["p", "p"],
    \ ["F3 d", "\<F3>d"], ["F2 h", "\<F2>h"]]
    call GT_Key(l:one[0], l:one[1])
  endfor

  " The selection keys, which go by another road: an "<expr>" mapping that hands
  " back nothing at all when the buffer refuses.
  call GT_Locked()
  call feedkeys("v\<Right>\<Del>", "x")
  call GT_Ok("Del over a selection: no error from Vim", v:errmsg !~ "E21",
    \ v:errmsg == "" ? "" : "   [" . v:errmsg . "]")
  call GT_Ok("  and it said so", g:GrooVim_GrooVimBarMsgValue =~ "cannot be changed", "")

  " ---- and the two roads that get there
  call GT_Ok("one function decides and says so", exists("*GrooVim_CanChange"),
    \ "   (the keys that call a function ask it at the door)")
  call GT_Ok("  and the shortcuts are caught by a net",
    \ GT_FunctionText("GrooVim_CommandZRun") =~ "E21",
    \ "   (no list of what edits has to be kept, and tomorrow's shortcut is covered)")
  call GT_Ok("  which reads readonly as well as modifiable",
    \ GT_FunctionText("GrooVim_CanChange") =~ "readonly",
    \ "   (a file opened with \"view\" refuses just the same)")

  " ---- and the quickfix window, where Enter belongs to Vim
  "
  " In a quickfix window Enter OPENS the line you are on, and it is not a mapping
  " there -- it is what the window does. A mapping of ours is global, so it went
  " over it and the list could not be used at all: measured on the bookmark list,
  " the Enter answered "This one cannot be changed!" and nothing opened. This is
  " every quickfix and location list, not only that one.
  enew!
  file /tmp/GrooVim_quickfix_case.txt
  call setline(1, ["um", "dois", "tres"])
  call setqflist([{"filename": expand("%:p"), "lnum": 2, "text": "a segunda"}])
  copen
  call GT_Ok("setup: the list is a quickfix window", &buftype ==# "quickfix",
    \ "   [" . &buftype . "]")
  call GT_Ok("  and Enter there is NOT a mapping of the buffer",
    \ get(maparg("<Enter>", "n", 0, 1), "buffer", 0) == 0,
    \ "   (which is why a global one went over it)")
  call cursor(1, 1)
  call feedkeys("\<Enter>", "x")
  call GT_Ok("Enter opens the line the list points at", line(".") == 2 &&
    \ &buftype ==# "", "   (line " . line(".") . ", buftype [" . &buftype . "])")
  cclose

  " ---- and a buffer that DOES accept changes is not touched by any of this
  enew!
  call setline(1, ["uma linha"])
  call cursor(1, 1)
  call feedkeys("\<Enter>", "x")
  call GT_Ok("and where changing IS allowed, the key still works",
    \ line("$") == 2, "   (" . line("$") . " lines)")

  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
