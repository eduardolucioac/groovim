" Note: Get shown messages! By Questor
let g:messagesHolder = ""
func! GrooVim_GetMessages() abort
  let g:messagesHolder = ""
  redir => g:messagesHolder
    silent exec "messages"
  redir end
endfunc

" Note: Return the last shown message! By Questor
func! GrooVim_ReturnLastMessage() abort
  call GrooVim_GetMessages()
  let l:messagesHolderSplitted = split(g:messagesHolder, "\n")
  if len(l:messagesHolderSplitted) >= 1
    return [l:messagesHolderSplitted[len(l:messagesHolderSplitted) - 1], len(l:messagesHolderSplitted)]
  else
    return ["", 0]
  endif
endfunc

let g:lastMessageWorkaroundShowed = ""
let g:lastMessageWorkaroundShowedIndex = 0

" Note: Finds the keyboard LEDs that report the CapsLock state. This used to
" call "xset", which needs X11 and forks a shell about once per second. Reading
" the LED works on Wayland, on X11 and on a bare tty, costs a file read and
" needs no graphical session. On a machine with no physical keyboard (a
" headless server) there is simply no LED and the check turns itself off! By Questor
func! GrooVim_CapsLockLedsFind() abort
  let l:leds = []
  try
    for l:led in glob("/sys/class/leds/*capslock*/brightness", 0, 1)
      if filereadable(l:led)
        call add(l:leds, l:led)
      endif
    endfor
  catch
  endtry
  return l:leds
endfunc

let g:GrooVim_CapsLockLeds = GrooVim_CapsLockLedsFind()

" Note: There can be one LED per keyboard, so any of them lit means it is on! By Questor
func! GrooVim_CapsLockIsOn() abort
  for l:led in g:GrooVim_CapsLockLeds
    try
      if str2nr(get(readfile(l:led), 0, "0")) > 0
        return 1
      endif
    catch
    endtry
  endfor
  return 0
endfunc

" Note: Check if caps lock is on! By Questor
let g:GrooVim_CheckCapsLockReturn = 0
let g:GrooVim_CheckCapsLockMsg = 0
" Note: Reading a file does not disturb the screen the way "system()" did, so
" neither the "redraw!" nor the workaround that put the last message back on
" screen after it are needed here anymore! By Questor
"
" Note: This acts only when the state CHANGED, instead of on a clock. The old
" gate compared against the moment of the last CALL, and the moment was updated
" on every call, so while the cursor was busy the gate simply never opened: the
" warning only showed up after a pause followed by more cursor movement! By Questor
"
" Note: Mind the order! "GrooVim_GrooVimBarMsg()" refuses to show anything while
" "g:GrooVim_CheckCapsLockReturn" is 1, so the warning must be pushed BEFORE
" that flag is raised! By Questor
func! GrooVim_CheckCapsLock() range abort

  " Note: Nothing to read, nothing to do! By Questor
  if empty(g:GrooVim_CapsLockLeds)
    return
  endif

  let l:isOn = GrooVim_CapsLockIsOn()

  if l:isOn == g:GrooVim_CheckCapsLockReturn
    return
  endif

  if l:isOn
    " Note: This warning have a special condition and only
    " disappears if capslock is off! When caps lock is on
    " any other message will be shown! By Questor
    call GrooVim_GrooVimBarMsg("((( CAPS LOCK IS ON, OH NO!!! =| )))", 0)
    let g:GrooVim_CheckCapsLockMsg = 1
    let g:GrooVim_CheckCapsLockReturn = 1
  else
    let g:GrooVim_CheckCapsLockReturn = 0
    if g:GrooVim_CheckCapsLockMsg == 1
      let g:GrooVim_CheckCapsLockMsg = 0
      call GrooVim_GrooVimBarMsg("", "")
    endif
  endif

endfunc

" Note: The caps lock is watched by its OWN timer instead of riding on cursor
" events. Reading the LED costs a small file read, and this way the warning
" appears (and disappears) even when you are not touching anything! By Questor
let g:GrooVim_CapsLockPollMs = get(g:, "GrooVim_CapsLockPollMs", 300)

" Note: Raised while an interactive prompt of GrooVim is on screen. The timer
" below stays out of the way then: its status line redraw was wiping the match
" highlight of a ":substitute" with confirmation and moving the cursor off the
" question! By Questor
let g:GrooVim_Busy = 0

" Note: What the bar announces while an operation is running! By Questor
let g:GrooVim_GrooVimBarContext = ""

" Note: Entering and leaving an operation: raises the busy flag and puts its name
" on the bar, then takes both back. Every function that asks something goes
" through this pair, inside a try/finally, so an interruption cannot leave the
" bar lying about what is happening! By Questor
" Note: Runs anything as a NAMED OPERATION: announces it on the bar, holds the
" busy flag while it runs, and takes both back at the end, whatever happens,
" including an interruption.
"
" Note: This is where the context lives now. A feature that asks the user
" something does not need to know any of this: it is enough to be INVOKED
" through here, and the name travels with the invocation. Adding a new one costs
" a single line at the point that triggers it! By Questor
func! GrooVim_Operation(context, funcName, args) abort
  call GrooVim_ContextEnter(a:context)
  try
    return call(a:funcName, a:args)
  finally
    call GrooVim_ContextLeave()
  endtry
endfunc

" Note: Operations can call one another (the search with list calls the plain
" search), so what was announced before is put back instead of simply cleared!
" By Questor
let g:GrooVim_ContextStack = []

func! GrooVim_ContextEnter(context) abort
  call add(g:GrooVim_ContextStack, g:GrooVim_GrooVimBarContext)
  let g:GrooVim_Busy = 1
  let g:GrooVim_GrooVimBarContext = a:context
  " Note: Whatever was on the bar was said BEFORE this operation and has nothing
  " to do with it, so it goes. Messages raised DURING the operation still show up
  " next to the context, which is how a warning like the one about wrapping to
  " the top of the file survives.
  "
  " Note: Going through GrooVim_GrooVimBarMsg() and not clearing the variables by
  " hand is deliberate: it refuses to erase anything while the CapsLock is on, and
  " that warning must not be swallowed by an operation! By Questor
  call GrooVim_GrooVimBarMsg("", "")
  call GrooVim_ContextRedraw()
endfunc

func! GrooVim_ContextLeave() abort
  if !empty(g:GrooVim_ContextStack)
    let g:GrooVim_GrooVimBarContext = remove(g:GrooVim_ContextStack, -1)
  else
    let g:GrooVim_GrooVimBarContext = ""
  endif
  " Note: Still busy if an outer operation is going on! By Questor
  let g:GrooVim_Busy = g:GrooVim_GrooVimBarContext != "" ? 1 : 0
  call GrooVim_ContextRedraw()
endfunc

func! GrooVim_ContextRedraw() abort
  if v:vim_did_enter
    try
      redrawstatus!
    catch
    endtry
  endif
endfunc

func! GrooVim_CapsLockPoll(timerId) abort
  " Note: Stay out of the way while a movement is being animated, or while a
  " prompt is waiting for an answer! By Questor
  if g:GrooVim_GroovyMoveEnabled == 0 || g:GrooVim_Busy
    return
  endif
  call GrooVim_CheckCapsLock()
  call GrooVim_GrooVimBarMsgExpire()
endfunc

" Note: Reloading the ".vimrc" (F5->r) would otherwise pile up one
" timer per reload! By Questor
if exists("g:GrooVim_CapsLockTimer")
  try
    call timer_stop(g:GrooVim_CapsLockTimer)
  catch
  endtry
endif
let g:GrooVim_CapsLockTimer = -1
if !empty(g:GrooVim_CapsLockLeds) && exists("*timer_start")
  let g:GrooVim_CapsLockTimer = timer_start(g:GrooVim_CapsLockPollMs, "GrooVim_CapsLockPoll", {"repeat": -1})
endif

" Note: The exclamation in "autocmd!" avoids redefining this event when reload
" ".vimrc"! By Questor

" Note: Ensures state of "virtualedit" before any editing! By Questor
autocmd! InsertEnter * call GrooVim_InsertEnterPerforms()
func! GrooVim_InsertEnterPerforms() abort
  if g:onMoveScreen == 0
    if &virtualedit == "all"
      set virtualedit=onemore
    endif
  endif
endfunc

" Note: Repositions the cursor in the correct location when exiting insert mode! By Questor
autocmd! InsertLeave * call GrooVim_InsertLeavePerforms()
func! GrooVim_InsertLeavePerforms() abort
  exec "norm `^"
endfunc

" Note: Ensures state of "virtualedit" before any editing! By Questor
autocmd! InsertCharPre * call GrooVim_InsertCharPrePerforms()
func! GrooVim_InsertCharPrePerforms() abort
  if &virtualedit == "all"
    set virtualedit=onemore
  endif
endfunc

" Note: Check caps lock status! By Questor
autocmd! CursorHold * call GrooVim_CheckCapsLockTimer()
autocmd! CursorHoldI * call GrooVim_CheckCapsLockTimer()
let g:reloadVimrc = 0
func! GrooVim_CheckCapsLockTimer() abort
  if g:onCursorMoved == 0 && g:onMoveScreen == 0

    call GrooVim_CheckCapsLock()
    call GrooVim_GrooVimBarMsgExpire()

  else
    let g:onMoveScreen = 0
    let g:GrooVim_GroovyMoveEnabled = 1
  endif

  checktime
endfunc
" Note: And the same thing for visual mode, where "CursorHold" never happens.
"
" Note: A movement puts itself out of reach while it runs -- hold the key down
" and what you get is ONE movement, not the ten that would be queued -- and what
" puts it back on its feet is the "else" above, which only runs when Vim is idle
" with nothing waiting. That is the whole point: idle means the keys you pressed
" during the trip were already thrown away.
"
" Note: It used to be reached in visual mode by leaving the mode -- the movement
" ended with an "<Esc>" -- and that is what made the marking of the selection
" flash off and on. "SafeState" is the event for exactly this moment, "when
" nothing is pending, going to wait for the user to type a character", and it
" does not fire while there is typeahead. Measured with three keys fed at once:
" one movement, which is what holding the key down must do! By Questor
autocmd! SafeState * call GrooVim_SafeStatePerforms()
func! GrooVim_SafeStatePerforms() abort
  if g:onMoveScreen == 1 && mode() =~# "^[vV\<C-v>]"
    let g:onMoveScreen = 0
    let g:GrooVim_GroovyMoveEnabled = 1
  endif
endfunc

" Note: Execution delay (in milliseconds). Zero is deliberate: "CursorHold"
" does NOT repeat while Vim is idle (see ":h CursorHold"), it fires once after
" the user stops typing. Zero makes GrooVim react immediately -- the Caps Lock
" and the message of the bar, which is what is left here -- and it costs nothing
" now that no shell command runs from here! By Questor
set updatetime=0

" Note: Allows controlling the status of a number of GrooVim features! By Questor
autocmd! CursorMoved * call GrooVim_VimStatus()
autocmd! CursorMovedI * call GrooVim_VimStatus()
let g:lastMode = ""
let g:onCursorMoved = 0
let g:modeNow = ""
func! GrooVim_VimStatus() abort

  let g:onCursorMoved = 1
  if g:onMoveScreen == 0

"     Note: Checks the status of the capslock when Vim the changes its mode or
"     if Vim is in visual mode!! By Questor

    let g:modeNow = mode()

    if g:modeNow != g:lastMode || g:modeNow == "v"
      " Note: Avoids the need to fire twice "GrooVim_GroovyMove()" when we change
      " the mode! By Questor
        let g:GrooVim_GroovyMoveEnabled = 1
      call GrooVim_CheckCapsLock()
      if g:GrooVim_GrooVimBarMsgEnabled == 1 && g:GrooVim_CheckCapsLockReturn == 0 && g:GrooVim_CheckCapsLockMsg == 1
        call GrooVim_GrooVimBarMsg("", "")
        let g:GrooVim_CheckCapsLockMsg = 0
      endif
    endif

    " Note: When on visual-block mode allows select any area! By Questor
    if mode() != "\<C-v>"
      if &virtualedit == "all"
        set virtualedit=onemore
      endif
    endif

    let g:lastMode = g:modeNow

  endif
  let g:onCursorMoved = 0
endfunc

nnoremap <silent> <ScrollWheelUp> :call GrooVim_ScrollAdm("n", "u")<cr>
nnoremap <silent> <S-ScrollWheelUp> :call GrooVim_ScrollAdm("n", "u")<cr>
nnoremap <silent> <ScrollWheelDown> :call GrooVim_ScrollAdm("n", "d")<cr>
nnoremap <silent> <S-ScrollWheelDown> :call GrooVim_ScrollAdm("n", "d")<cr>

inoremap <silent> <ScrollWheelUp> <C-o>:call GrooVim_ScrollAdm("i", "u")<cr>
inoremap <silent> <S-ScrollWheelUp> <C-o>:call GrooVim_ScrollAdm("i", "u")<cr>
inoremap <silent> <ScrollWheelDown> <C-o>:call GrooVim_ScrollAdm("i", "d")<cr>
inoremap <silent> <S-ScrollWheelDown> <C-o>:call GrooVim_ScrollAdm("i", "d")<cr>

" Note: The wheel of visual mode goes through "<Cmd>" for the same reason the
" movement keys do: a ":" would take the cursor to the first line of the range
" and the window with it, and the "gv" that put the selection back landed more
" than a screen away, which makes Vim CENTRE what it lands on. Measured, window
" on 80..120 and cursor on 115: one notch UP moved the cursor three lines up and
" the window fifteen lines DOWN, to 95..135! By Questor
vnoremap <ScrollWheelUp> <Cmd>call GrooVim_ScrollAdm("v", "u")<cr>
vnoremap <S-ScrollWheelUp> <Cmd>call GrooVim_ScrollAdm("v", "u")<cr>
vnoremap <ScrollWheelDown> <Cmd>call GrooVim_ScrollAdm("v", "d")<cr>
vnoremap <S-ScrollWheelDown> <Cmd>call GrooVim_ScrollAdm("v", "d")<cr>

