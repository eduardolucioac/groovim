" How a copy leaves this machine.
"
" GrooVim promises to work on a headless server reached by SSH, and there the
" only way out is OSC 52: an escape sequence the TERMINAL turns into a clipboard
" entry. No X, no Wayland, no tool to call.
"
" What this case guards is the question that decides whether it is used at all:
" does this terminal do OSC 52? Getting it wrong is silent. A copy simply never
" arrives, and nothing on screen says why.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

" The environment is put back after each question, so one answer cannot decide
" the next.
func! GT_Asking(vars)
  let l:kept = {}
  for l:name in ["SSH_TTY", "SSH_CONNECTION", "KONSOLE_VERSION", "TMUX",
    \ "TERM_PROGRAM", "VTE_VERSION", "KITTY_WINDOW_ID"]
    let l:kept[l:name] = eval("$" . l:name)
    exec "let $" . l:name . " = ''"
  endfor
  for [l:name, l:value] in items(a:vars)
    exec "let $" . l:name . " = '" . l:value . "'"
  endfor
  let l:answer = GrooVim_TerminalDoesOSC52()
  for [l:name, l:value] in items(l:kept)
    exec "let $" . l:name . " = '" . l:value . "'"
  endfor
  return l:answer
endfunc

" ---- a terminal that says nothing about itself
call GT_Ok("nothing known: we do not assume", GT_Asking({}) == 0,
  \ "   (term " . &term . ")")

" ---- the terminals that identify themselves in their own environment
"
" The osc52 package of Vim asks with a DA1 query and believes only an answer
" that advertises "52". Several terminals do OSC 52 without ever saying so that
" way, so their own variables are what we go by.
call GT_Ok("Konsole says so in KONSOLE_VERSION",
  \ GT_Asking({"KONSOLE_VERSION": "260801"}) == 1, "")
call GT_Ok("kitty, in KITTY_WINDOW_ID",
  \ GT_Asking({"KITTY_WINDOW_ID": "1"}) == 1, "")
call GT_Ok("the ones that fill TERM_PROGRAM",
  \ GT_Asking({"TERM_PROGRAM": "iTerm.app"}) == 1, "")
call GT_Ok("VTE from 0.72 on",
  \ GT_Asking({"VTE_VERSION": "7200"}) == 1, "")
call GT_Ok("  and not before it",
  \ GT_Asking({"VTE_VERSION": "6003"}) == 0, "   (it did not forward OSC 52 yet)")
call GT_Ok("tmux forwards it to whatever is around it",
  \ GT_Asking({"TMUX": "/tmp/tmux-1000/default,1,0"}) == 1, "")

" ---- and over SSH, where none of that survives
"
" This is the case that was wrong, and the one GrooVim exists for. Every
" variable above is set by the terminal in the shell IT started; ssh carries
" none of them across. The far end sees a bare "xterm-256color" and used to
" conclude the terminal could do nothing -- on the very machine where OSC 52 is
" the ONLY thing that can carry a copy out.
call GT_Ok("over SSH we try, because nothing else can work",
  \ GT_Asking({"SSH_TTY": "/dev/pts/0"}) == 1,
  \ "   (the terminal of the other end is unknowable from here)")
call GT_Ok("  SSH_CONNECTION answers for it too",
  \ GT_Asking({"SSH_CONNECTION": "10.0.0.1 22 10.0.0.2 22"}) == 1,
  \ "   (there is no tty when the command came with the ssh line)")

" ---- the register a copy goes to
call GT_Ok("the register is one Vim knows",
  \ index(["+", "*", "\""], GrooVim_ClipReg()) >= 0,
  \ "   [" . GrooVim_ClipReg() . "]   (clipmethod " .
  \ (exists("v:clipmethod") ? v:clipmethod : "-") . ")")

if exists("+clipmethod")
  call GT_Ok("osc52 is in the cascade", &clipmethod =~ "osc52",
    \ "   [" . &clipmethod . "]")
  call GT_Ok("  and it is the LAST of them",
    \ &clipmethod =~ "osc52$",
    \ "   [" . &clipmethod . "]   (a machine with a clipboard of its own keeps using it)")
endif

" ---- paste through OSC 52 stays off
"
" A paste asks the terminal and waits for an answer many never send, and Vim
" blocks until Ctrl-C. Copy is what crosses SSH; reading back is not worth
" hanging the editor for.
call GT_Ok("OSC 52 paste is off", get(g:, "osc52_disable_paste", 0) == 1, "")

call GT_Done()
