let g:GrooVim_CommandZUnblock = 1
" Note: The cursor keeps the colour of the mode the key was pressed in, for as
" long as the shortcut takes.
"
" Note: A shortcut fired from insert mode arrives through a "<C-o>", which steps
" out of insert, and then GrooVim WAITS for the second key of the combination --
" in slices, with a "sleep" between them, and a "sleep" is exactly when Vim runs
" its timers. So the cursor was painted by the mode of that moment, which is
" normal: measured, "orange, green, orange" on a command that never left insert.
"
" Note: The "finally" is not decoration. Interrupting a prompt with Ctrl-C walks
" out of here, and a flag left standing would keep the cursor orange in every
" mode from then on -- the same trap that once left CommandZ blocked for good.
"
" Note: Only from insert. A shortcut fired from normal mode has nothing to hold,
" and one fired from visual really does end the selection -- the ":" of its
" mapping does it -- so normal is the truth there! By Questor
func! GrooVim_CommandZ(GrooVim_CommandZFCallerNow, modType) abort

  if a:modType ==# "i"
    let g:GrooVim_CursorColorHoldInsert = 1
  endif

  try
    call GrooVim_CommandZRun(a:GrooVim_CommandZFCallerNow, a:modType)
  finally
    if a:modType ==# "i"
      let g:GrooVim_CursorColorHoldInsert = 0
      if exists("*GrooVim_CursorColorSoon")
        call GrooVim_CursorColorSoon()
      endif
    endif
  endtry

endfunc

" Note: What each F key repeats. One entry per group, because F2 remembering what
" F3 did is not a memory, it is a mix-up: measured with real keys, "F3 d" and then
" "F2 c" and then F3 alone did NOTHING, because the F2 had taken the only slot
" there was and a slot of another key is thrown away! By Questor
let g:GrooVim_CommandZChars = {"F2": "", "F3": "", "F4": "", "F5": ""}

" Note: The key each group is pressed with, so that a key read here can be told
" apart from the letter of a shortcut! By Questor
let s:GrooVim_CommandZKeys = {"F2": "\<f2>", "F3": "\<f3>", "F4": "\<f4>", "F5": "\<f5>"}

" Note: For the two commands that have to put their own key back: a macro replays
" F keys, and replaying them writes over what the group was repeating! By Questor
func! GrooVim_CommandZRemember(group, char) abort
  let g:GrooVim_CommandZChars[a:group] = a:char
endfunc

func! GrooVim_CommandZForget(group) abort
  let g:GrooVim_CommandZChars[a:group] = ""
endfunc

func! GrooVim_CommandZRun(GrooVim_CommandZFCallerNow, modType) abort

  " Note: Clears the screen before reading the next key of the combination! By Questor
  redraw!

  " Note: Waits for the second key, in slices of twenty milliseconds.
  "
  " Note: The FIRST slice is what lets the key arrive. A terminal sends an F key
  " as an escape sequence, and reading before it has all landed reads nothing --
  " measured with real keys through a real terminal, with no wait at all the
  " second key is never seen. Five milliseconds were already enough on all four F
  " keys; twenty is the slice, and the slice does that job.
  "
  " Note: And it goes on waiting to the end of the budget, because one flat sleep
  " gives up on anyone slower than itself: measured, a second key pressed 600ms
  " after the F key is lost with a budget of 400! By Questor
  let l:key = ""
  let l:waited = 0
  while l:key == "" && l:waited < g:GrooVim_CommandZWait
    sleep 20m
    let l:waited = l:waited + 20
    let l:key = getchar(0)
  endwhile

  " Note: What was pressed, and what it means.
  "
  " Note: The SAME F key again means "do that again". It is read as a key and not
  " timed, so it repeats at once and there is nothing new to remember.
  "
  " Note: ANOTHER F key is not a second key at all -- it is another shortcut
  " starting -- so nothing is repeated and the key is handed back, to run as
  " itself. It used to be swallowed here.
  "
  " Note: Anything else IS the second key, and it becomes what this F key repeats
  " from now on.
  "
  " Note: And nothing at all, the budget spent, repeats what this key last ran.
  " That is the whole of "do that again": press the key, do not press another! By
  " Questor
  if l:key != "" && l:key !=# get(s:GrooVim_CommandZKeys, a:GrooVim_CommandZFCallerNow, "")
    if index(values(s:GrooVim_CommandZKeys), l:key) >= 0
      call feedkeys(l:key, "t")
      return
    endif
    let g:GrooVim_CommandZChars[a:GrooVim_CommandZFCallerNow] = l:key
  endif

  let l:char = get(g:GrooVim_CommandZChars, a:GrooVim_CommandZFCallerNow, "")

  if l:char != "" && g:GrooVim_CommandZUnblock == 1
    " Note: Prevents rerun a command while another is in progress! By Questor
    " Note: The "try/finally" is what keeps a Ctrl-C from locking CommandZ for
    " good: interrupting a prompt raises an exception, the function used to be
    " abandoned with this flag still at zero, and from then on NO F key worked
    " anymore! By Questor
    let g:GrooVim_CommandZUnblock = 0
    try

    " Note: The shortcut is LOOKED UP, not spelled out.
    "
    " Note: This was three hundred lines of "if the key is this, do that" -- fifty
    " of them, in four blocks, one per F key. Every shortcut lived in two places
    " at once: an "if" here and an entry in the list the help is written from, and
    " the two drifted. A key that moved group stayed answering under the old one;
    " a key the list claimed did not answer at all.
    "
    " Note: Now the list is the only place. What a shortcut IS -- its group, its
    " key, the modes it answers in, what it does and how to say so -- is written
    " once, and the help, the menu and this all read it! By Questor
    for l:one in g:GrooVim_Shortcuts

      if l:one.group !=# a:GrooVim_CommandZFCallerNow
       \ || !GrooVim_ShortcutIsKey(l:char, l:one.key)
       \ || stridx(l:one.modes, a:modType) < 0
        continue
      endif

      " Note: The key is ours, but what it does is not here. Saying so beats
      " what it used to do, which was to call a function that was never defined
      " and show "E117: Unknown function" over the bar! By Questor
      if !GrooVim_ShortcutAvailable(l:one)
        call GrooVim_GrooVimBarMsg(l:one.group . "->" . l:one.key . " needs " .
         \ l:one.needs.name . ", which is not installed here!", 6)
        break
      endif

      " Note: The net. A shortcut that edits meets a buffer which refuses with
      " "E21", and the error of Vim is not an answer to give anybody. Caught
      " HERE, at the one door every shortcut goes through, so that no list of
      " what edits and what does not has to be kept -- and a shortcut written
      " tomorrow is covered by it too. "E45" is the same thing said by a file
      " that is read only! By Questor
      try
        call GrooVim_ShortcutRun(l:one, a:modType)
      catch /E21:\|E45:/
        call GrooVim_CannotChangeSay()
      endtry
      break

    endfor

    finally
      let g:GrooVim_CommandZUnblock = 1
    endtry
  endif

endfunc

nnoremap <silent> <script> <F9> :call GrooVim_ToogleGrooVimHelp()<cr>

