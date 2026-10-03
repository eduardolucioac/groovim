" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
" SHORTCUTS (COMMANDZ)
" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" Note: The F keys, and the wait for the second key that makes a shortcut. Which
" shortcut does what is NOT here: it is read from the one list in the help part,
" and this is the machine that reads the keys and looks it up.

" Note: How long GrooVim waits for the SECOND key of a shortcut, in
" milliseconds. When it runs out with nothing typed, the F key repeats the last
" command IT ran: the window closing and the repeat are the same instant, so
" there is no second wait after the first.
"
" Raise it if a second key of yours is being lost. Measured: with 400, a key
" pressed 600ms after the F key arrives too late and what runs in its place is
" the repetition -- the previous command instead of the one you were typing. The
" long trips of a keyboard, an F key at one corner and an arrow at the other,
" take longer than they feel like they do, and 1000 held all of them.
"
" Pressing the same F key twice repeats at once and owes nothing to this number.
let g:GrooVim_CommandZWait = get(g:, "GrooVim_CommandZWait", 400)

let g:GrooVim_CommandZUnblock = 1
" Note: The cursor keeps the colour of the mode the key was pressed in, for as
" long as the shortcut takes.
"
" A shortcut fired from insert mode arrives through a "<C-o>", which steps out
" of insert, and then GrooVim WAITS for the second key of the combination -- in
" slices, with a "sleep" between them, and a "sleep" is exactly when Vim runs
" its timers. So the cursor was painted by the mode of that moment, which is
" normal: measured, "orange, green, orange" on a command that never left insert.
"
" The "finally" is not decoration. Interrupting a prompt with Ctrl-C walks out
" of here, and a flag left standing would keep the cursor orange in every mode
" from then on -- the same trap that once left CommandZ blocked for good.
"
" Only from insert. A shortcut fired from normal mode has nothing to hold, and
" one fired from visual really does end the selection -- the ":" of its mapping
" does it -- so normal is the truth there.
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

" Note: What each F key repeats. One entry per group, because F2 remembering
" what F3 did is not a memory, it is a mix-up: measured with real keys, "F3 d"
" and then "F2 c" and then F3 alone did NOTHING, because the F2 had taken the
" only slot there was and a slot of another key is thrown away.
let g:GrooVim_CommandZChars = {"F2": "", "F3": "", "F4": "", "F5": ""}

" Note: The key each group is pressed with, so that a key read here can be told
" apart from the letter of a shortcut.
let s:GrooVim_CommandZKeys = {"F2": "\<f2>", "F3": "\<f3>", "F4": "\<f4>", "F5": "\<f5>"}

" Note: For the two commands that have to put their own key back: a macro
" replays F keys, and replaying them writes over what the group was repeating.
func! GrooVim_CommandZRemember(group, char) abort
  let g:GrooVim_CommandZChars[a:group] = a:char
endfunc

func! GrooVim_CommandZForget(group) abort
  let g:GrooVim_CommandZChars[a:group] = ""
endfunc

func! GrooVim_CommandZRun(GrooVim_CommandZFCallerNow, modType) abort

  " Note: Clears the screen before reading the next key of the combination.
  redraw!

  " Note: Waits for the second key, in slices of twenty milliseconds.
  "
  " The FIRST slice is what lets the key arrive. A terminal sends an F key as an
  " escape sequence, and reading before it has all landed reads nothing --
  " measured with real keys through a real terminal, with no wait at all the
  " second key is never seen. Five milliseconds were already enough on all four
  " F keys; twenty is the slice, and the slice does that job.
  "
  " And it goes on waiting to the end of the budget, because one flat sleep
  " gives up on anyone slower than itself: measured, a second key pressed 600ms
  " after the F key is lost with a budget of 400.
  let l:key = ""
  let l:waited = 0
  while l:key == "" && l:waited < g:GrooVim_CommandZWait
    sleep 20m
    let l:waited = l:waited + 20
    let l:key = getchar(0)
  endwhile

  " Note: What was pressed, and what it means.
  "
  " The SAME F key again means "do that again". It is read as a key and not
  " timed, so it repeats at once and there is nothing new to remember.
  "
  " ANOTHER F key is not a second key at all -- it is another shortcut starting
  " -- so nothing is repeated and the key is handed back, to run as itself. It
  " used to be swallowed here.
  "
  " Anything else IS the second key, and it becomes what this F key repeats from
  " now on.
  "
  " And nothing at all, the budget spent, repeats what this key last ran. That
  " is the whole of "do that again": press the key, do not press another.
  if l:key != "" && l:key !=# get(s:GrooVim_CommandZKeys, a:GrooVim_CommandZFCallerNow, "")
    if index(values(s:GrooVim_CommandZKeys), l:key) >= 0
      call feedkeys(l:key, "t")
      return
    endif
    let g:GrooVim_CommandZChars[a:GrooVim_CommandZFCallerNow] = l:key
  endif

  let l:char = get(g:GrooVim_CommandZChars, a:GrooVim_CommandZFCallerNow, "")

  if l:char != "" && g:GrooVim_CommandZUnblock == 1
    " Note: Prevents rerun a command while another is in progress.
    "
    " The "try/finally" is what keeps a Ctrl-C from locking CommandZ for good:
    " interrupting a prompt raises an exception, the function used to be
    " abandoned with this flag still at zero, and from then on NO F key worked
    " anymore.
    let g:GrooVim_CommandZUnblock = 0
    try

    " Note: The shortcut is LOOKED UP, not spelled out.
    "
    " This was three hundred lines of "if the key is this, do that" -- fifty of
    " them, in four blocks, one per F key. Every shortcut lived in two places at
    " once: an "if" here and an entry in the list the help is written from, and
    " the two drifted. A key that moved group stayed answering under the old
    " one; a key the list claimed did not answer at all.
    "
    " Now the list is the only place. What a shortcut IS -- its group, its key,
    " the modes it answers in, what it does and how to say so -- is written
    " once, and the help, the menu and this all read it.
    for l:one in g:GrooVim_Shortcuts

      " Note: Only what is reached by an F key. The list holds the whole map of
      " GrooVim now -- "Ctrl+C", "Alt+Shift+Up", "m" and the rest are on it, for
      " the menu and the help to show -- and those are mapped where they are
      " mapped and never come through here.
      if !has_key(l:one, "group") || l:one.group !=# a:GrooVim_CommandZFCallerNow
       \ || !GrooVim_ShortcutIsKey(l:char, l:one.key)
       \ || stridx(l:one.modes, a:modType) < 0
        continue
      endif

      " Note: The key is ours, but what it does is not here. Saying so beats
      " what it used to do, which was to call a function that was never defined
      " and show "E117: Unknown function" over the bar.
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
      " that is read only.
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

" Note: And the four keys that start all of it, in the three modes. Each one
" calls the same machine with its own name, and the machine reads the key that
" comes after.
"
" Through "<C-o>" in insert mode, which steps out for ONE command and comes
" back, and through ":<C-u>" in visual, which drops the range Vim would put on
" the command line.
nnoremap <silent> <script> <F2> :call GrooVim_CommandZ("F2", "n")<cr>
inoremap <silent> <script> <F2> <C-o>:call GrooVim_CommandZ("F2", "i")<cr>
vnoremap <silent> <script> <F2> :<C-u>call GrooVim_CommandZ("F2", "v")<cr>

nnoremap <silent> <script> <F3> :call GrooVim_CommandZ("F3", "n")<cr>
inoremap <silent> <script> <F3> <C-o>:call GrooVim_CommandZ("F3", "i")<cr>
vnoremap <silent> <script> <F3> :<C-u>call GrooVim_CommandZ("F3", "v")<cr>

nnoremap <silent> <script> <F4> :call GrooVim_CommandZ("F4", "n")<cr>
inoremap <silent> <script> <F4> <C-o>:call GrooVim_CommandZ("F4", "i")<cr>
vnoremap <silent> <script> <F4> :<C-u>call GrooVim_CommandZ("F4", "v")<cr>

nnoremap <silent> <script> <F5> :call GrooVim_CommandZ("F5", "n")<cr>
inoremap <silent> <script> <F5> <C-o>:call GrooVim_CommandZ("F5", "i")<cr>
vnoremap <silent> <script> <F5> :<C-u>call GrooVim_CommandZ("F5", "v")<cr>
