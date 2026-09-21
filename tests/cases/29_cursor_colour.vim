" The colour of the cursor, and the modes a command passes through.
"
" Green in normal mode, orange in insert, blue in visual. A command fired from
" insert mode arrives through a "<C-o>", which steps OUT of insert, does its
" work and comes back -- and the cursor was painted at every step of that, so
" what you saw on a command that never left insert was orange, green, orange.
"
" The colour is sent to the TERMINAL with "echoraw", and a case cannot read a
" terminal. So the emitter is replaced here by one that writes down what it was
" asked to paint, which is the same thing one step earlier. This case owns that
" replacement: it is the last thing it does, and nothing after it needs the real
" one.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

let g:GT_PAINTS = []

func! GrooVim_CursorColorEmit(color) abort
  call add(g:GT_PAINTS, a:color)
endfunc

func! GT_Press(keys)
  let g:GrooVim_CommandZMoment = 0
  call feedkeys(a:keys, "t")
endfunc

func! GT_Names(paints)
  let l:names = []
  for l:colour in a:paints
    call add(l:names, l:colour ==# g:cursorColorI ? "insert" :
      \ (l:colour ==# g:cursorColorV ? "visual" : "normal"))
  endfor
  return "[" . join(l:names, " ") . "]"
endfunc

func! GT_Body()
  call GT_Ok("the colour of the cursor is on for this case",
    \ g:GrooVim_CursorColorEnabled, "   (it is off on a plain console and in a GUI)")

  enew!
  setlocal filetype=vim
  call setline(1, ['" uma nota do vim', '" outra'])
  call cursor(1, 9)
  call feedkeys("i", "t")
  call timer_start(300, "GT_Shortcut")
endfunc

" ---- a shortcut fired from insert mode
func! GT_Shortcut(t)
  let g:GT_MODE_BEFORE = mode()
  let g:GT_PAINTS = []
  call GT_Press("\<F3>d")
  call timer_start(700, "GT_ShortcutDone")
endfunc

func! GT_ShortcutDone(t)
  let l:paints = copy(g:GT_PAINTS)
  call GT_Ok("setup: we really were in insert mode", g:GT_MODE_BEFORE ==# "i",
    \ "   (mode [" . strtrans(g:GT_MODE_BEFORE) . "])")
  call GT_Ok("F3 d from insert never paints the cursor green",
    \ index(l:paints, g:cursorColorNV) < 0,
    \ "   " . GT_Names(l:paints) . "   (it used to be orange, green, orange)")
  call GT_Ok("  and it ends orange, which is where it started",
    \ !empty(l:paints) && l:paints[-1] ==# g:cursorColorI,
    \ "   " . GT_Names(l:paints))

  " ---- and a movement fired from insert mode, which travels much longer
  let g:GT_PAINTS = []
  call feedkeys("\<A-S-Down>", "t")
  call timer_start(900, "GT_MovementDone")
endfunc

func! GT_MovementDone(t)
  let l:paints = copy(g:GT_PAINTS)
  call GT_Ok("Shift-Alt-Down from insert never paints it green either",
    \ index(l:paints, g:cursorColorNV) < 0,
    \ "   " . GT_Names(l:paints) . "   (the trip is long enough to SEE it turn)")
  call GT_Ok("  and it ends orange too",
    \ !empty(l:paints) && l:paints[-1] ==# g:cursorColorI,
    \ "   " . GT_Names(l:paints) . "   (mode [" . strtrans(mode()) . "])")

  " ---- and the mechanism that makes it so
  call GT_Ok("the paint waits for the mode to settle",
    \ GT_FunctionText("GrooVim_CursorColorSoon") =~ 'timer_start(0' &&
    \ GT_FunctionText("GrooVim_CursorColorSoon") =~ "timer_stop",
    \ "   (restarted at each change, so three changes paint once, at the end)")
  call GT_Ok("  and the shortcut holds the colour of insert while it waits",
    \ GT_FunctionText("GrooVim_CommandZ") =~ "CursorColorHoldInsert",
    \ "   (it waits for the second key with a \"sleep\", which is when Vim runs timers)")
  call GT_Ok("  and lets it go in a \"finally\"",
    \ GT_FunctionText("GrooVim_CommandZ") =~ 'finally\_.\{-}CursorColorHoldInsert = 0',
    \ "   (a Ctrl-C out of a prompt would leave the cursor orange for good)")
  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
