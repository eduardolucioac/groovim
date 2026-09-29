"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
"APPEARANCE
"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" Note: Displays the number of each line.
set number

" Note: Always show current position.
set ruler

" Note: Height of the command bar! One line keeps the prompts of the "super
" commands" on the first line of the command area, without a blank line above
" them, and gives one more line to the text.
set cmdheight=1

" Note: For regular expressions turn magic on.
set magic

" Note: Show matching brackets when text indicator is over them.
set showmatch

" Note: How many tenths of a second to blink when matching brackets.
set mat=2

" Note: No sound, and "noerrorbells" is NOT enough for that. From its own
" manual: "This only makes a difference for error messages, the bell will be
" used ALWAYS for a lot of errors without a message". A cursor that cannot move
" any further is exactly one of those, so reaching the end of a line rang a real
" bell -- and over SSH that lights the bell mark on the tab of the terminal.
"
" Note: "belloff=all" is what covers them, and it is the behaviour GrooVim is
" after: Notepad++ does not beep when you reach the end of a line, or at
" anything else. Put "set belloff=" in your own configuration to have the bells
" back, and see ":help belloff" for silencing only some of them.
"
" Note: The two below are kept because they still say something: no bell for
" error messages, and the bell that does ring is a sound and not a screen flash
" ("visualbell" plus an empty "t_vb" was the old way of silencing Vim, and
" "belloff" replaced it).
set belloff=all
set noerrorbells
set novisualbell

" Note: Allow the cursor to go into "invalid" places.
" set virtualedit=all

" Note: Always turn on syntax highlighting for diffs (select by the file-suffix directly).
augroup PatchDiffHighlight
  autocmd! BufEnter  *.patch,*.rej,*.diff   syntax enable
augroup end

" Note: Displays messages on the scroll bar.
let g:GrooVim_GrooVimBarMsgValue = ""
let g:GrooVim_GrooVimBarMsgMoment = 0
let g:GrooVim_GrooVimBarMsgEnabled = 0
let g:GrooVim_GrooVimBarMsgDuration = 0
func! GrooVim_GrooVimBarMsg(msgValue, msgDuration) abort

  if g:GrooVim_CheckCapsLockReturn == 0
    if a:msgValue != ""
      let g:GrooVim_GrooVimBarMsgValue = " Hey: " . a:msgValue
      let g:GrooVim_GrooVimBarMsgMoment = localtime()
      let g:GrooVim_GrooVimBarMsgEnabled = 1
      let g:GrooVim_GrooVimBarMsgDuration = a:msgDuration
    else
      let g:GrooVim_GrooVimBarMsgValue = ""
      let g:GrooVim_GrooVimBarMsgEnabled = 0
    endif
    " Note: The status line is "%!GrooVim_GrooVimBar()", so it is Vim that calls
    " it when redrawing. Just calling it here changed nothing on screen: the
    " message only appeared at the next screen update, whenever that came.
    "
    " Note: ONLY after startup! Asking for a redraw while the ".vimrc" is still
    " being read makes Vim paint the screen BEFORE switching to the terminal
    " alternate screen, and everything painted there stays behind on the shell
    " when you quit Vim.
    if v:vim_did_enter
      try
        redrawstatus!
      catch
      endtry
    endif
  endif

endfun

" Note: Drops a timed message from the bar once its time is over.
func! GrooVim_GrooVimBarMsgExpire() abort
  if g:GrooVim_GrooVimBarMsgEnabled == 1 && g:GrooVim_CheckCapsLockReturn == 0
    if (localtime() - g:GrooVim_GrooVimBarMsgMoment) > g:GrooVim_GrooVimBarMsgDuration
      call GrooVim_GrooVimBarMsg("", "")
    endif
  endif
endfunc

" Note: Displays an information bar.
set laststatus=2
" Note: While an operation is asking something, its name takes the place of the
" "Powered by" on the bar, and the bar goes back to normal when it is over. The
" prompt itself stays clean: the context lives here, not glued to the question.
" Note: Where you are: the encoding, what ends a line, the flags of the buffer,
" the type, the line and the column. The half of the bar that every window
" wants!
"
" Note: The line ending is there because it can be CHANGED -- F5->c and then
" [f] -- and a setting you can change and cannot see is a setting you cannot
" trust. Notepad++ keeps it on its bar for the same reason.
func! GrooVim_GrooVimBarWhere() abort
  return '[%{(&fenc==""?&enc:&fenc).(&bomb?",B":"").",".&ff}%M%R%H%W] %y [%l/%L,%v] [%p%%]'
endfunc

func! GrooVim_GrooVimBar() abort

  let l:barContents = '%{GrooVim_FileLabel()} ' . GrooVim_GrooVimBarWhere()

  if g:GrooVim_GrooVimBarContext != ""
    return l:barContents . " " . g:GrooVim_GrooVimBarContext . g:GrooVim_GrooVimBarMsgValue
  endif

  return l:barContents . " Powered by [GrooVim =D " . g:grooVimVersion . "]!" . g:GrooVim_GrooVimBarMsgValue

endfun

" Note: The bar of the help: WHAT you are reading and WHERE in it you are.
"
" Note: Nothing else. No encoding and no flags -- the help is not a file you are
" going to save, and it is the same every time. No "Powered by", which is the
" banner of a DOCUMENT of yours. And no messages: an invitation to press F9 does
" not belong on the bar of the thing F9 opened. The occurrence list has a bar of
" its own for the same reasons.
func! GrooVim_GrooVimHelpBar() abort
  return "%f [%l/%L,%v] [%p%%]"
endfunc
set stl=%!GrooVim_GrooVimBar()
" Note: Displays a message on the initial run.
call GrooVim_GrooVimBarMsg("F9 for help and F10 for the menu!", 10)

" Note: The vertical edge, which is the "Vertical Edge Settings" of Notepad++: a
" line down the screen telling you where a line is getting long.
"
" Note: "colorcolumn" and not the "matchadd" that was here. A match can only
" paint a character that EXISTS, so the old one marked column 81 of the long
" lines and left nothing on the short ones -- a dotted trail instead of a line.
" "colorcolumn" paints the column on every row, which is the line Notepad++
" draws.
"
" Note: Column 79 and not 80. A line of 79 characters is the last one that fits
" in 80 columns, so the mark sits ON the first column you should not reach.
"
" Note: Set it to 0 to take the line away.
let g:GrooVim_EdgeColumn = get(g:, "GrooVim_EdgeColumn", 79)

" Note: A dark grey and not the blue that was here. The old one painted a handful
" of characters, one per long line; this one is a column down the whole window,
" and at that size a strong colour stops being a hint and becomes the thing you
" look at.
"
" Note: A teal was tried in its place, on the idea that a hue of its own would
" read as a rule. It read as a stripe: one cell is all a terminal has to draw in
" -- there is no half column -- so at that width the quiet colour is the one that
" behaves like a line and the vivid one becomes a band. Back to the grey! By
" Questor
highlight ColorColumn ctermbg=236 guibg=#303030

" Note: "colorcolumn" is window local, so it is set on entering a window, the
" same way the symbols are.
"
" Note: And ONLY where a file is edited. The line marks where a line of text gets
" too long, which means nothing in a window that holds no text of yours: it was
" being drawn down the occurrence list, the list of marks, the tree and the help,
" over lists whose lines are as long as they need to be.
func! GrooVim_EdgeSet() abort
  try
    let &l:colorcolumn = g:GrooVim_EdgeColumn > 0 && &buftype ==# ""
     \ ? string(g:GrooVim_EdgeColumn) : ""
  catch
  endtry
endfunc

augroup GrooVim_Edge
  autocmd!
  autocmd BufWinEnter,WinEnter * call GrooVim_EdgeSet()
augroup end
call GrooVim_EdgeSet()

" Note: Make trailing whitespace and non-breaking spaces visible.
set list
" Note: The trailing/non breaking space marks AND the indentation guides are all
" built by this one, so that both always agree on the same "listchars".
call GrooVim_SymbolsSet()

" " Note: Make tabs, trailing whitespace and non-breaking spaces visible.
" " Note: Type I.
" "exec "set listchars=tab:\uBB\uBB,trail:\uB7,nbsp:~"
" " Note: Type II.
" exec "set listchars=tab:▒░,trail:\uB7,nbsp:~"

" Note: Switch syntax highlighting on, when the terminal has colors.
if &t_Co > 2 || has("gui_running")
  syntax on
endif

" Note: The ":substitute" with confirmation paints the match under decision with
" "IncSearch" (see ":h :s_c"). Blue here, matching the blue that "N" uses when
" walking BACK through the search results.
"
" Note: This has to come AFTER "syntax on" and be repeated on "ColorScheme",
" because both reset the highlight groups.
" Note: "cterm=NONE gui=NONE" is not decoration: the default "IncSearch" carries
" "reverse", which SWAPS foreground and background and would show blue letters on
" a white block instead of white on blue.
let g:GrooVim_ReplaceHighlight = get(g:, "GrooVim_ReplaceHighlight", "cterm=NONE gui=NONE ctermbg=blue ctermfg=white guibg=blue guifg=white")
func! GrooVim_SetReplaceHighlight() abort
  try
    exec "highlight IncSearch " . g:GrooVim_ReplaceHighlight
  catch
  endtry
endfunc
call GrooVim_SetReplaceHighlight()
augroup GrooVim_ReplaceHighlightGroup
  autocmd!
  autocmd ColorScheme * call GrooVim_SetReplaceHighlight()
augroup end

" Note: Switch from block-cursor to vertical-line-cursor when going into/out of insert mode.
" let &t_SI = "\<Esc>]50;CursorShape=1\x7"
" let &t_EI = "\<Esc>]50;CursorShape=0\x7"

" Note: " Cursor -> Orange in insert mode and red in command mode!
" if you want to use rgb color formatting: konsoleprofile
" CustomCursorColor=#255255255.
" Note: One color per mode, so you know where you are without looking at the
" bar: green in normal, blue in visual, orange while typing.
let g:cursorColorI = get(g:, "cursorColorI", "orange")
let g:cursorColorNV = get(g:, "cursorColorNV", "green")
let g:cursorColorV = get(g:, "cursorColorV", "blue")
let g:cursorColorBlock = 0

" Note: Sends the color to the terminal right now.
"
" Note: "OSC 12" is the standard sequence to set the cursor color and "OSC 112"
" resets it. The old code used an OSC 50 payload that only Konsole understands
" AND forked "konsoleprofile" three times (on load, on VimEnter and on
" VimLeave). This speaks to any terminal that listens (Konsole, xterm, kitty,
" alacritty, foot, wezterm...), forks nothing and works over SSH.
func! GrooVim_CursorColorEmit(color) abort
  call echoraw("\<Esc>]12;" . a:color . "\x7")
endfunc

" Note: Which color belongs to the mode we are in.
"
" Note: "t_SI"/"t_EI" only know insert from everything else, so they cannot tell
" visual from normal. The "ModeChanged" event can, and it is what paints visual
" blue.
func! GrooVim_CursorColorForMode() abort
  let l:mode = mode()
  let l:visual = l:mode ==# "v" || l:mode ==# "V" || l:mode ==# "\<C-v>"
        \ || l:mode ==# "s" || l:mode ==# "S" || l:mode ==# "\<C-s>"

  " Note: Not while GroovyMove is travelling out of insert mode: there the cursor
  " belongs to insert from end to end.
  "
  " Note: But never over a mode that CAN be seen. The flag says "we came from
  " insert", and if it is ever left standing -- an interrupted movement used to
  " leave it so -- believing it over "mode()" painted the cursor green in visual
  " mode, which is blue. What Vim reports wins.
  " Note: While there are carets up, the real cursor is ONE OF THEM and wears
  " their colour -- orange while the places are being chosen, yellow once they
  " are set. Without this the last place marked looked different from all the
  " others, because what is drawn on it is not a caret at all: it is the cursor
  " of the terminal, in the colour of insert mode.
  if exists("*GrooVim_MultiCursorColour")
    let l:multi = GrooVim_MultiCursorColour()
    if l:multi !=# ""
      call GrooVim_CursorColorEmit(l:multi)
      return
    endif
  endif

  if g:GrooVim_CursorColorHoldInsert == 1 && !l:visual
    call GrooVim_CursorColorEmit(g:cursorColorI)
    return
  endif

  if l:visual
    call GrooVim_CursorColorEmit(g:cursorColorV)
  elseif l:mode =~# "^[iR]"
    call GrooVim_CursorColorEmit(g:cursorColorI)
  else
    call GrooVim_CursorColorEmit(g:cursorColorNV)
  endif
endfunc

" Note: Paints by the mode the editor SETTLES in, and not by every mode it goes
" through on the way.
"
" Note: A shortcut fired from insert mode passes through normal mode to do its
" work and comes back -- so the cursor went orange, green, orange, and what you
" see is a blink of the wrong colour on a command that never left the mode it was
" called from. Every movement key out of insert does the same, and so does every
" command of the F keys.
"
" Note: The timer is RESTARTED at each change, so a command that changes the mode
" three times paints once, at the end, by the mode it really ended in. Zero is
" enough: a timer of zero runs on the next pass of the main loop, which is after
" the command has finished. If the mode is the same as it was, the colour is the
" same, and nothing is ever seen to change.
let g:GrooVim_CursorColorTimer = -1
func! GrooVim_CursorColorSoon() abort
  if g:GrooVim_CursorColorTimer != -1
    try
      call timer_stop(g:GrooVim_CursorColorTimer)
    catch
    endtry
  endif
  let g:GrooVim_CursorColorTimer = timer_start(0, {t -> GrooVim_CursorColorForMode()})
endfunc

" Note: Paints the cursor right now. "t_EI" alone would only fire when leaving
" insert mode.
func! GrooVim_CursorColorNow() abort
  if g:GrooVim_CursorColorHoldInsert == 1
    return
  endif
  call GrooVim_CursorColorEmit(g:cursorColorNV)
endfunc

" Note: Gives the cursor back to the terminal when leaving.
func! GrooVim_CursorColorReset() abort
  call echoraw("\<Esc>]112\x7")
endfunc

" Note: A plain Linux console has no colored cursor and inside a GUI these
" terminal codes make no sense.
let g:GrooVim_CursorColorEnabled = !has("gui_running") && &term !~ "^\\(linux\\|dumb\\|cons\\)"
if g:GrooVim_CursorColorEnabled
  augroup GrooVim_CursorColor
    autocmd!
    autocmd VimEnter * call GrooVim_CursorColorNow()
    autocmd VimLeave * call GrooVim_CursorColorReset()

    " Note: "ModeChanged" covers every mode, which is why "t_SI" and "t_EI" are
    " left alone: they only know insert from everything else, and setting them as
    " well painted the cursor twice.
    "
    " Note: And through "Soon", which waits for the mode to settle: see there for
    " why a command that comes back to the mode it was called from must not show
    " a colour of its own.
    autocmd ModeChanged * call GrooVim_CursorColorSoon()
  augroup end
endif

