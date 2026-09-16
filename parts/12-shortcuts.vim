let g:GrooVim_CommandZMoment = 0
let g:GrooVim_CommandZChar = ""
let g:GrooVim_CommandZUnblock = 1
let g:GrooVim_CommandZFCaller = ""
func! GrooVim_CommandZ(GrooVim_CommandZFCallerNow, modType) abort

  let l:GrooVim_CommandZNowChar = ""

  " Note: This logic allows rerun the last command just using an F key (1, 2, 3...). If
  " there is a single F? in few milliseconds, the last command is executed without
  " waiting for a new key to compose a command. If a new key was informed fast enough
  " it rerun the last command! If an different F? is informed it will wait for a key
  " combination to compose the command! By Questor

  let l:GrooVim_CommandZMomentNow = GrooVim_GetMilliseconds()

  " Note: Clears the screen before reading the next key of the combination! By Questor
  redraw!

  if (l:GrooVim_CommandZMomentNow - g:GrooVim_CommandZMoment) > g:GrooVim_CommandZRepeat || g:GrooVim_CommandZFCaller != a:GrooVim_CommandZFCallerNow

    " Note: Waits for the second key, and goes on waiting in small slices.
    "
    " Note: The first sleep is what lets the key ARRIVE -- a terminal sends an
    " arrow as an escape sequence, and reading before it has all landed reads
    " nothing. It is also what settles whatever the mapping itself left behind:
    " asking "getchar" straight away, with no sleep at all, picked up the wrong
    " key and the real one then ran as itself. Measured, and the whole battery
    " said so.
    "
    " Note: What is NEW is everything after it. One flat sleep gave up on anyone
    " slower than itself, and the second key then ran as itself: "F2" and then
    " the Up arrow -- the longest trip on this keyboard -- was lost past 400ms
    " while the arrow went on to move the cursor, and the tab closers went the
    " same way back when they lived on the Shifted keys. Now the waiting goes on
    " in 20ms slices until the key comes or the patience runs out! By Questor
    exec "sleep " . g:GrooVim_CommandZSettle . "m"
    let l:GrooVim_CommandZNowChar = getchar(0)
    let l:waited = g:GrooVim_CommandZSettle
    while l:GrooVim_CommandZNowChar == "" && l:waited < g:GrooVim_CommandZWait
      exec "sleep 20m"
      let l:waited = l:waited + 20
      let l:GrooVim_CommandZNowChar = getchar(0)
    endwhile
    if l:GrooVim_CommandZNowChar != "" && l:GrooVim_CommandZNowChar != "\<f2>" && l:GrooVim_CommandZNowChar != "\<f3>" && l:GrooVim_CommandZNowChar != "\<f4>" && l:GrooVim_CommandZNowChar != "\<f5>"
      let g:GrooVim_CommandZChar = l:GrooVim_CommandZNowChar
    endif
    if g:GrooVim_CommandZFCaller != a:GrooVim_CommandZFCallerNow && l:GrooVim_CommandZNowChar == ""
      let g:GrooVim_CommandZChar = ""
    endif
  endif
  " Note: To debug! By Questor
  " echo g:GrooVim_CommandZChar
  let g:GrooVim_CommandZMoment = l:GrooVim_CommandZMomentNow
  if g:GrooVim_CommandZChar != "" && g:GrooVim_CommandZUnblock == 1
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
       \ || !GrooVim_ShortcutIsKey(g:GrooVim_CommandZChar, l:one.key)
       \ || stridx(l:one.modes, a:modType) < 0
        continue
      endif

      call GrooVim_ShortcutRun(l:one, a:modType)
      break

    endfor

    finally
      let g:GrooVim_CommandZUnblock = 1
    endtry
  endif
  let g:GrooVim_CommandZFCaller = a:GrooVim_CommandZFCallerNow

endfunc

nnoremap <silent> <script> <F9> :call GrooVim_ToogleGrooVimHelp()<cr>

