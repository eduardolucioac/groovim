" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
" DIALOGUES (AND BALLOONS)
" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" The windows that say something over the text: the DIALOGUES, which wait for an
" answer, and the BALLOONS, which say one thing and go away by themselves.
"
" A dialogue is a window that says something and waits. The About of the "?"
" section is the first one; an information, a warning, a question with Yes and
" No are the same window with other words and other buttons in it.
"
" What one is made of: lines of text, a row of buttons under them, and -- while
" it is up -- the only thing in GrooVim that reads a key. The menu of F10 works
" the same way, and a dialogue that let the file behind it answer would not be a
" dialogue.
"
" The buttons are walked with |<Left>| and |<Right>| , pressed with |<Enter>| or
" with the key written beside the label, and clicked with the mouse. An address
" anywhere in the text is a link: it is drawn as one and a click opens it.
"
" "c" copies what a dialogue says, and it is not a button. It is the same on
" every one of them, and a button that is on every window teaches nothing -- it
" only takes room from the ones that differ. Ctrl+C would be the obvious key and
" cannot be used: measured, it does not arrive here at all, it INTERRUPTS -- the
" filter never ran and the keys after it were never read.

" $$$$$$$$$$$$$$$$$$$$$$$

" Note: The dialogue that is on the screen, or empty while there is none: only
" one is ever up.
let s:dialog = {}

" Note: The colours of a dialogue are the colours of the menu, because they are
" the same window to the eye: near black on near white, the chosen thing in the
" blue of "PopupSelected". Only the link is its own, and it is drawn the way
" every browser has drawn one since there were browsers.
if &t_Co >= 256 || has("gui_running")
  highlight GrooVimDialogLink ctermbg=255 ctermfg=25 cterm=underline
   \ guibg=#eff0f1 guifg=#005faf gui=underline
else
  highlight GrooVimDialogLink ctermbg=white ctermfg=blue cterm=underline
endif

func! GrooVim_DialogColours() abort
  for l:pair in [["GrooVimDialogOn", "PopupSelected"],
   \ ["GrooVimDialogLink", "GrooVimDialogLink"]]
    try
      call prop_type_add(l:pair[0], {"highlight": l:pair[1]})
    catch
    endtry
  endfor
endfunc

" Note: Where the addresses are in a line, as [column, length] and in BYTES,
" which is what a text property counts in.
func! GrooVim_DialogLinks(line) abort
  let l:out = []
  let l:at = 0
  while 1
    let l:found = matchstrpos(a:line, 'https\=://\S\+', l:at)
    if l:found[1] < 0 | break | endif
    call add(l:out, [l:found[1] + 1, l:found[2] - l:found[1], l:found[0]])
    let l:at = l:found[2]
  endwhile
  return l:out
endfunc

" Note: The row of buttons, and where each one sits on it -- the drawing and the
" clicking read the same answer, so a button cannot be painted in one place and
" pressed in another.
func! GrooVim_DialogButtons() abort
  let l:text = ""
  let l:at = []
  for l:button in get(s:dialog, "buttons", [])
    if l:text !=# "" | let l:text = l:text . "   " | endif
    let l:label = "[ " . l:button.label . " (" . l:button.key . ") ]"
    call add(l:at, [strlen(l:text) + 1, strlen(l:label)])
    let l:text = l:text . l:label
  endfor
  return [l:text, l:at]
endfunc

" Note: Draws it again, which is how the chosen button moves: a popup is text,
" and what is blue about one line of it is a property ON that text.
func! GrooVim_DialogPaint() abort

  if get(s:dialog, "id", 0) <= 0 | return | endif

  let l:painted = []
  for l:line in s:dialog.lines
    let l:props = []
    for l:link in GrooVim_DialogLinks(l:line)
      call add(l:props, {"col": l:link[0], "length": l:link[1],
       \ "type": "GrooVimDialogLink"})
    endfor
    call add(l:painted, {"text": l:line, "props": l:props})
  endfor

  let [l:text, l:at] = GrooVim_DialogButtons()
  if l:text !=# ""
    let l:here = l:at[s:dialog.chosen]
    call add(l:painted, {"text": ""})
    call add(l:painted, {"text": l:text, "props": [{"col": l:here[0],
     \ "length": l:here[1], "type": "GrooVimDialogOn"}]})
  endif

  call popup_settext(s:dialog.id, l:painted)

endfunc

" Note: Opens one. What it is given: a "title", the "lines" it says, the
" "buttons" under them, and -- for a dialogue that a shortcut opens -- that
" "shortcut", as the two keys it is pressed with, so that pressing it again
" closes the window.
"
" A button is a label, the key that presses it, and what it does: "run" is the
" name of a function and "args" what to call it with. A button with "close" in
" it takes the window down afterwards.
func! GrooVim_Dialog(spec) abort

  let s:dialog = {"lines": a:spec.lines, "chosen": 0, "waiting": 0,
   \ "buttons": get(a:spec, "buttons", []),
   \ "shortcut": get(a:spec, "shortcut", []),
   \ "text": join(a:spec.lines, "\n"), "id": 0}

  " Note: The chosen one starts on the LAST button, which is where the way out
  " is. Enter on a window you have just opened should not do anything you have
  " to undo.
  let s:dialog.chosen = max([len(s:dialog.buttons) - 1, 0])

  if !has("popupwin")
    call GrooVim_DialogOnScreen(a:spec)
    return
  endif

  call GrooVim_DialogColours()
  call GrooVim_CursorHide()

  let s:dialog.id = popup_dialog([""], {"title": get(a:spec, "title", ""),
   \ "padding": [0, 1, 0, 1], "highlight": "GrooVimMenu",
   \ "mapping": 0, "filter": "GrooVim_DialogFilter",
   \ "callback": "GrooVim_DialogClosed"})
  call GrooVim_DialogPaint()

endfunc

func! GrooVim_DialogUp() abort
  return get(s:dialog, "id", 0) > 0
endfunc

func! GrooVim_DialogClose() abort
  if GrooVim_DialogUp()
    call popup_close(s:dialog.id)
  endif
endfunc

" Note: However it was closed, the cursor of the terminal comes back. On the
" callback and not beside each way out, because this is the one place every one
" of them goes through.
func! GrooVim_DialogClosed(id, result) abort
  let s:dialog.id = 0
  let s:dialog.waiting = 0
  call GrooVim_CursorShow()
endfunc

" Note: What a dialogue says, on the clipboard. The TEXT, without the buttons:
" they are a way of pressing this window and not something it tells you.
func! GrooVim_DialogCopy() abort
  call GrooVim_ClipSet(s:dialog.text)
  call GrooVim_GrooVimBarMsg("What it says is on the clipboard!", 4)
endfunc

" Note: An address, handed to whatever the desktop opens addresses with -- there
" is no browser of ours, and there should not be one.
"
" With no desktop to open it on, which is every GrooVim reached over SSH, the
" address goes to the clipboard instead: that is the useful half of "open it"
" when there is nothing to open it in, and the clipboard of GrooVim travels
" through the terminal, so it lands on the machine you are SITTING at.
func! GrooVim_DialogPage(url) abort

  let l:opener = executable("xdg-open") ? "xdg-open"
   \ : (executable("open") ? "open" : "")

  if l:opener ==# "" || (l:opener ==# "xdg-open"
   \ && empty($DISPLAY) && empty($WAYLAND_DISPLAY))
    call GrooVim_ClipSet(a:url)
    call GrooVim_GrooVimBarMsg("No desktop here, so the address went to the clipboard!", 6)
    return
  endif

  " Note: A job and not a "system()", for the same reason the clipboard uses
  " one: a browser starting up is not something Vim should be waiting for.
  call job_start([l:opener, a:url],
   \ {"in_io": "null", "out_io": "null", "err_io": "null"})
  call GrooVim_GrooVimBarMsg("The page went to your browser!", 4)

endfunc

func! GrooVim_DialogPress(which) abort
  let l:button = s:dialog.buttons[a:which]
  if get(l:button, "run", "") !=# ""
    call call(l:button.run, get(l:button, "args", []))
  endif
  if get(l:button, "close", 0)
    call GrooVim_DialogClose()
  endif
endfunc

func! GrooVim_DialogWalk(step) abort
  if empty(s:dialog.buttons) | return | endif
  let s:dialog.chosen = (s:dialog.chosen + a:step + len(s:dialog.buttons))
   \ % len(s:dialog.buttons)
  call GrooVim_DialogPaint()
endfunc

" Note: A click: on a button it presses it, on an address it opens it, and
" anywhere else -- inside the window or out of it -- it does nothing. Clicking
" outside does not close a dialogue: the ways out are the ones written on it.
func! GrooVim_DialogClicked() abort

  let l:where = getmousepos()
  if l:where.winid != s:dialog.id || l:where.line <= 0 | return | endif

  " Note: The row of buttons is the last line, with a blank one before it.
  if l:where.line == len(s:dialog.lines) + 2
    let [l:text, l:at] = GrooVim_DialogButtons()
    let l:which = 0
    for l:one in l:at
      if l:where.column >= l:one[0] && l:where.column < l:one[0] + l:one[1]
        let s:dialog.chosen = l:which
        call GrooVim_DialogPaint()
        call GrooVim_DialogPress(l:which)
        return
      endif
      let l:which = l:which + 1
    endfor
    return
  endif

  if l:where.line > len(s:dialog.lines) | return | endif
  for l:link in GrooVim_DialogLinks(s:dialog.lines[l:where.line - 1])
    if l:where.column >= l:link[0] && l:where.column < l:link[0] + l:link[1]
      call GrooVim_DialogPage(l:link[2])
      return
    endif
  endfor

endfunc

" Note: While it is up, every key comes here, so nothing walks the file behind
" it, and only the ways out written on the window take it down.
"
" The keys VIM sends itself are swallowed and nothing else. They begin with the
" two bytes 0x80 0xFD -- measured, one of them, "<80><fd>`", used to arrive on
" its own and shut the window in the instant it opened. The mouse is in that
" same family and is asked about FIRST, because a click is somebody's.
"
" A shortcut is read here key by key, both of them, and not handed back to the
" CommandZ. Measured with mappings on: the F key handed back never came to this
" filter again -- Vim had already turned it into the command its mapping says,
" and what arrived was that command, letter by letter.
func! GrooVim_DialogFilter(id, key) abort

  if a:key ==# "\<LeftMouse>"
    call GrooVim_DialogClicked()
    return 1
  endif

  if a:key[0:1] ==# "\x80\xfd"
    return 1
  endif

  if s:dialog.waiting
    let s:dialog.waiting = 0
    if a:key ==# s:dialog.shortcut[1]
      call GrooVim_DialogClose()
    endif
    return 1
  endif

  if len(s:dialog.shortcut) == 2 && a:key ==# s:dialog.shortcut[0]
    let s:dialog.waiting = 1
    return 1
  endif

  if a:key ==# "\<Esc>"
    call GrooVim_DialogClose()
    return 1
  endif

  if a:key ==# "\<Left>" || a:key ==# "\<S-Tab>"
    call GrooVim_DialogWalk(-1)
    return 1
  endif

  if a:key ==# "\<Right>" || a:key ==# "\<Tab>"
    call GrooVim_DialogWalk(1)
    return 1
  endif

  if a:key ==# "\<CR>" && !empty(s:dialog.buttons)
    call GrooVim_DialogPress(s:dialog.chosen)
    return 1
  endif

  let l:which = 0
  for l:button in s:dialog.buttons
    if a:key ==# l:button.key
      let s:dialog.chosen = l:which
      call GrooVim_DialogPaint()
      call GrooVim_DialogPress(l:which)
      return 1
    endif
    let l:which = l:which + 1
  endfor

  " Note: And the one key every dialogue answers, button or no button.
  if a:key ==# "c"
    call GrooVim_DialogCopy()
  endif

  return 1

endfunc

" Note: The same dialogue where there are no popups to draw one with. It says
" the same things and answers the same keys; what it cannot do is be a window.
func! GrooVim_DialogOnScreen(spec) abort

  for l:line in s:dialog.lines
    echo l:line
  endfor
  let [l:text, l:at] = GrooVim_DialogButtons()
  if l:text !=# ""
    echo ""
    echo l:text
  endif

  while 1
    let l:key = getchar()
    let l:key = type(l:key) == type(0) ? nr2char(l:key) : l:key
    if l:key ==# "c"
      call GrooVim_DialogCopy()
      continue
    endif
    let l:which = 0
    let l:pressed = -1
    for l:button in s:dialog.buttons
      if l:key ==# l:button.key | let l:pressed = l:which | endif
      let l:which = l:which + 1
    endfor
    if l:pressed >= 0
      call GrooVim_DialogPress(l:pressed)
      if get(s:dialog.buttons[l:pressed], "close", 0) | break | endif
      continue
    endif
    break
  endwhile

endfunc

" Note: A balloon: one line said over the text, where the cursor is, that goes
" away by itself. It is not a dialogue -- it waits for nothing, it blocks
" nothing, and you go on typing with it up.
"
" It goes down on the cursor MOVING or on |<Esc>| , and those are two different
" roads: the moving is Vim's own, asked for with "moved", and the Esc is the
" filter below. A balloon with no filter cannot be dismissed on purpose, and one
" that swallowed keys would be a dialogue wearing another name.
"
" The colours are the colours of the menu, which is where GrooVim says things
" over the text. One source for them, in the menu part.
let s:tip = 0
let s:tipWhere = ""

" Note: Whether a balloon is up. Asked by whoever put one there, because it can
" have gone down without them -- the cursor moved, or Esc was pressed.
func! GrooVim_TipUp() abort
  return s:tip != 0 && !empty(popup_getpos(s:tip))
endfunc

" Note: What the balloon is saying, for whoever has to check it.
func! GrooVim_TipText() abort
  if !GrooVim_TipUp()
    return ""
  endif
  return join(getbufline(winbufnr(s:tip), 1, "$"), "\n")
endfunc

" Note: Where the balloon that is up was PUT, for whoever has to check it. Said
" and not worked out from the screen: a popup in the middle of a short window and
" one at the cursor can land on the same row, and then no measurement of where it
" is tells you what it was asked to be.
func! GrooVim_TipWhere() abort
  return GrooVim_TipUp() ? s:tipWhere : ""
endfunc

func! GrooVim_TipClose() abort
  if s:tip
    try
      call popup_close(s:tip)
    catch
    endtry
    let s:tip = 0
  endif
endfunc

" Note: Every key is handed back to Vim -- "0" means "not mine" -- so the only
" one this takes is the Esc that closes it. Measured: with the balloon up, the
" letters typed went into the file.
func! GrooVim_TipFilter(id, key) abort
  if a:key ==# "\<Esc>"
    call GrooVim_TipClose()
    return 1
  endif
  return 0
endfunc

" Note: Where a balloon goes: at the CURSOR, which is where your eyes are, or in
" the MIDDLE of the screen, which is where they are not.
"
" The middle is for insert mode. At the cursor it would sit on the very text you
" are typing, and the one thing you must not lose sight of while typing is the
" line you are writing.
func! GrooVim_Tip(text, ...) abort
  let l:where = a:0 > 0 ? a:1 : "cursor"

  if !exists("*popup_atcursor")
    call GrooVim_GrooVimBarMsg(a:text, 6)
    return 0
  endif

  call GrooVim_TipClose()
  let s:tipWhere = l:where

  let l:how = {"highlight": "GrooVimMenu", "border": [],
   \ "borderchars": ["\u2500", "\u2502", "\u2500", "\u2502",
   \                "\u250C", "\u2510", "\u2518", "\u2514"],
   \ "moved": "any", "close": "click", "filter": "GrooVim_TipFilter"}

  if l:where ==# "center"
    let s:tip = popup_create(" " . a:text . " ",
     \ extend(copy(l:how), {"pos": "center"}))
  else
    let s:tip = popup_atcursor(" " . a:text . " ",
     \ extend(copy(l:how), {"line": "cursor+1"}))
  endif

  return s:tip
endfunc

" Note: The whole path of the file you are on, which the bar can only show as
" much of as fits. Said where your eyes already are and not on the bar, because
" the bar is where the SHORT one already is.
"
" From INSERT mode it goes up LATER, on a timer of zero, and in the middle of
" the screen. Both for the same reason: the key was read inside an "i_CTRL-O",
" which runs one command and goes back to insert, and going back MOVES the
" cursor -- measured, the balloon went up and came straight back down, because
" "moved" is what takes it down. The timer lets the cursor land first, and the
" middle keeps it off the line you are typing.
func! GrooVim_PathTip(...) abort
  let l:mode = a:0 > 0 ? a:1 : "n"

  let l:name = expand("%:p")
  if l:name ==# ""
    let l:name = GrooVim_NewNameOf(bufnr("%"))
  endif
  let l:text = l:name ==# "" ? "This one has no name yet!" : l:name

  if l:mode =~# "i"
    call timer_start(0, {-> GrooVim_Tip(l:text, "center")})
    return
  endif

  call GrooVim_Tip(l:text)
endfunc
