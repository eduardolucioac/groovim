" How a copy leaves this machine.
"
" GrooVim promises to work on a headless server reached by SSH, and there the
" only way out is OSC 52: an escape sequence the TERMINAL turns into a clipboard
" entry. No X, no Wayland, no tool to call.
"
" What this case guards is the question that decides whether it is used at all.
" Getting it wrong is silent: a copy simply never arrives, and nothing on screen
" says why.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

" Asks the question with a given terminal and a given environment, and puts both
" back afterwards, so one answer cannot decide the next.
func! GT_Asking(term, ...)
  let l:vars = a:0 > 0 ? a:1 : {}
  let l:keptTerm = &term
  let l:kept = {}
  for l:name in ["SSH_TTY", "SSH_CONNECTION", "KONSOLE_VERSION", "TMUX",
    \ "TERM_PROGRAM", "VTE_VERSION", "KITTY_WINDOW_ID"]
    let l:kept[l:name] = eval("$" . l:name)
    exec "let $" . l:name . " = ''"
  endfor
  for [l:name, l:value] in items(l:vars)
    exec "let $" . l:name . " = '" . l:value . "'"
  endfor

  let &term = a:term
  let l:answer = GrooVim_TerminalDoesOSC52()

  let &term = l:keptTerm
  for [l:name, l:value] in items(l:kept)
    exec "let $" . l:name . " = '" . l:value . "'"
  endfor
  return l:answer
endfunc

" Vim refuses an empty "term" outright, which is why the code does not look for
" one. Proved here rather than assumed, because it is the reason a branch is
" missing.
func! GT_TermRefusesEmpty()
  let l:kept = &term
  try
    let &term = ""
    let &term = l:kept
    return 0
  catch /E529/
    return 1
  catch
    let &term = l:kept
    return 0
  endtry
endfunc

" ---- there is a terminal, so it is tried
"
" This used to be a list of terminals that name themselves in their own
" environment: $KONSOLE_VERSION, $VTE_VERSION, $TERM_PROGRAM. A list like that is
" never finished -- VTE alone covers GNOME, XFCE, MATE and Terminator, but COSMIC
" is not VTE and whatever is written next will not be there either. Every one of
" them answered "no" by default, and here a "no" is silent.
"
" The two mistakes are not the same size: the sequence costs nothing when it is
" not understood, and costs the copy when it is not sent.
for s:term in ["xterm-256color", "xterm", "linux", "foot", "screen-256color",
  \ "rxvt-unicode-256color", "alacritty", "contour", "st-256color",
  \ "xfce4-terminal", "cosmic-term", "terminal-nobody-has-written-yet"]
  call GT_Ok("[" . s:term . "] is a terminal, so we try", GT_Asking(s:term) == 1, "")
endfor

" ---- and this is the check that refuses a list
call GT_Ok("with NOTHING in the environment, we still try",
  \ GT_Asking("xterm-256color", {}) == 1,
  \ "   (no KONSOLE_VERSION, no VTE_VERSION, no TERM_PROGRAM, no TMUX, no SSH)")
call GT_Ok("  and a terminal nobody has heard of is not worse off",
  \ GT_Asking("something-new", {}) == GT_Asking("xterm-256color", {"KONSOLE_VERSION": "260801"}),
  \ "   (the answer cannot depend on being on a list)")

" ---- what there is no point in trying
call GT_Ok("a dumb terminal is taken at its word", GT_Asking("dumb") == 0, "")
call GT_Ok("  and there is no emptier case to guard",
  \ GT_TermRefusesEmpty() == 1,
  \ "   (Vim answers E529 to an empty \"term\", so the code does not test for one)")

" ---- the register a copy goes to
call GT_Ok("the register is one Vim knows",
  \ index(["+", "*", "\""], GrooVim_ClipReg()) >= 0,
  \ "   [" . GrooVim_ClipReg() . "]   (clipmethod " .
  \ (exists("v:clipmethod") ? v:clipmethod : "-") . ")")

if exists("+clipmethod")
  call GT_Ok("osc52 is in the cascade", &clipmethod =~ "osc52",
    \ "   [" . &clipmethod . "]")
  call GT_Ok("  and it is the LAST of them", &clipmethod =~ "osc52$",
    \ "   [" . &clipmethod . "]   (a machine with a clipboard of its own, or a tool to call, never reaches it)")
endif

" ---- paste through OSC 52 stays off
"
" A paste asks the terminal and waits for an answer many never send, and Vim
" blocks until Ctrl-C. Copy is what crosses SSH; reading back is not worth
" hanging the editor for.
call GT_Ok("OSC 52 paste is off", get(g:, "osc52_disable_paste", 0) == 1, "")

call GT_Done()
