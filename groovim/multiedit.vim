" Note: Writing in several places at once -- the multiple carets of Notepad++,
" which are its "Shift+Alt+arrows" (a column) and its "Ctrl+click" (wherever you
" like).
"
" Note: Vim has neither. What it has is the visual BLOCK, and a block is not
" this: you cannot type into it -- an "I" or an "A" is asked for first, the other
" lines only change when you press "Esc", and the column is the same on every
" line. Measured on four lines, entering the block and typing "XYZ": the "X" ran
" as the "x" of Vim and took a character off each line.
"
" Note: There is a plugin for this, "vim-visual-multi", eight and a half
" thousand lines in twenty five files, and inside its own mode it takes "m",
" "M", "n", "N", "q", "Q", "s", "Tab" and most of the arrows with modifiers --
" which here are the marked lines, the search, the tabs and the brackets. It
" would not be a feature arriving, it would be half of GrooVim changing meaning
" while the mode is up. What is here is the BASIC of it, written where the rest
" of GrooVim is and in the keys GrooVim already uses! By Questor

" Note: Where the other carets are: a line and a column each, and the one the
" terminal really draws is not among them -- a terminal has ONE cursor, and the
" others are painted as a colour on the character they sit on. It is what the
" plugin does too! By Questor
let g:GrooVim_MultiPoints = []

let s:on = 0
let s:column = 0

" Note: The places are chosen first and moved afterwards, and "Esc" is the line
" between the two: the first one SEALS the places -- from there the arrows move
" them all -- and the second one ends the whole thing.
"
" Note: One key for both because they are the same idea said twice: "I am done
" with this". Done choosing, then done editing! By Questor
let s:marking = 0
let s:anchor = []
let s:far = 0
let s:ids = []
let s:queue = []
let s:waiting = 0

highlight GrooVimMultiCaret ctermbg=208 ctermfg=232 guibg=#ff8700 guifg=#080808
if &t_Co < 256 && !has("gui_running")
  highlight GrooVimMultiCaret ctermbg=yellow ctermfg=black
endif

" Note: The carets are drawn with a match, which belongs to the WINDOW and not
" to the buffer -- and that is right here: the carets of a run of typing belong
" to the window you are typing in! By Questor
func! GrooVim_MultiDraw() abort

  for l:id in s:ids
    silent! call matchdelete(l:id)
  endfor
  let s:ids = []

  for l:point in g:GrooVim_MultiPoints
    call add(s:ids, matchaddpos("GrooVimMultiCaret",
     \ [[l:point[0], GrooVim_MultiColumnHere(l:point[0], l:point[1]), 1]]))
  endfor

endfunc

" Note: Where the caret of a line really falls. A line shorter than the column
" you are writing in takes the text at ITS end, which is what a block "A" of Vim
" does -- and it means no line is left out! By Questor
func! GrooVim_MultiColumnHere(line, column) abort
  return min([a:column, max([len(getline(a:line)) + 1, 1])])
endfunc

func! GrooVim_MultiClear() abort

  let g:GrooVim_MultiPoints = []
  let s:on = 0
  let s:column = 0
  let s:marking = 0
  let s:anchor = []
  let s:far = 0
  let s:queue = []

  call GrooVim_MultiDraw()
  call GrooVim_MultiKeysOff()

endfunc

" Note: What every caret does when a key that MOVES is pressed. The motion is
" run at each caret, from where THAT caret is -- so "word right" is each one's
" own next word, and "end of line" is each one's own end, on lines of every
" length! By Questor
" Note: The keys with a modifier move EVERY caret, in both shapes of this. The
" plain arrows are the difference between the two: in the column they are the
" block -- "Down" takes in one more line -- and in the places they are how you
" WALK to the next place, so there they move nobody but you.
"
" Note: Which is not a taste either. Marking several places is choosing where
" they are, and arrows that drag the carets already marked would take the
" chosen places away as you went looking for the next one! By Questor
let s:moves = {
 \ "<C-Left>":  "b",
 \ "<C-Right>": "el",
 \ "<Home>":    "0",
 \ "<End>":     "$l"
 \ }

let s:movesColumn = {
 \ "<Left>":    "h",
 \ "<Right>":   "l"
 \ }

" Note: The keys taken while the carets are up, and what they were before.
"
" Note: Taken and GIVEN BACK, and that is not the same as unmapped: "Ctrl+Left"
" and "Ctrl+Right" are keys GrooVim already has in insert -- the word back and
" the word forward -- and an "iunmap" of those would not restore them, it would
" DELETE them, for the rest of the session. "maparg" with the fourth argument
" hands the whole mapping over, and "mapset" puts it back exactly as it was! By
" Questor
let s:taken = []
let s:kept = []

func! GrooVim_MultiKeysTake(key, what) abort

  let l:was = maparg(a:key, "i", 0, 1)
  if !empty(l:was)
    call add(s:kept, l:was)
  endif

  call add(s:taken, a:key)
  exec "inoremap <silent> " . a:key . " " . a:what

endfunc

" Note: While the carets are up, the arrows MOVE them all, and in the column
" "Up" and "Down" grow the block instead -- there they are the block, here they
" are how you get to the next place.
"
" Note: Through "<Cmd>" and not through a "<C-o>:". The "<C-o>" steps out of
" insert to run one command, and stepping out FIRES "InsertLeave". ":h map-cmd"
" never leaves the mode at all -- and a motion run from inside it moves the
" cursor just the same: measured, a caret on another line walking to ITS next
" word while the real cursor walked to its own, with the mode still insert! By
" Questor
func! GrooVim_MultiKeysOn(column) abort

  let l:all = copy(s:moves)
  if a:column || !s:marking
    call extend(l:all, s:movesColumn)
  endif

  for l:key in keys(l:all)
    call GrooVim_MultiKeysTake(l:key,
     \ "<Cmd>call GrooVim_MultiMove(" . string(l:all[l:key]) . ")<cr>")
  endfor

  if a:column
    call GrooVim_MultiKeysTake("<Down>", "<Cmd>call GrooVim_MultiFar(1)<cr>")
    call GrooVim_MultiKeysTake("<Up>", "<Cmd>call GrooVim_MultiFar(-1)<cr>")
  elseif s:marking
    call GrooVim_MultiKeysTake("<Down>", "<Cmd>call GrooVim_MultiWalk(1)<cr>")
    call GrooVim_MultiKeysTake("<Up>", "<Cmd>call GrooVim_MultiWalk(-1)<cr>")

    " Note: While the places are still being chosen, "Esc" seals them instead of
    " ending. Through "<Cmd>", which does not leave insert at all -- so nothing
    " has to be entered again afterwards, and nothing blinks! By Questor
    call GrooVim_MultiKeysTake("<Esc>", "<Cmd>call GrooVim_MultiSeal()<cr>")
  else
    call GrooVim_MultiKeysTake("<Down>", "<Cmd>call GrooVim_MultiMove('j')<cr>")
    call GrooVim_MultiKeysTake("<Up>", "<Cmd>call GrooVim_MultiMove('k')<cr>")
  endif

  nnoremap <silent> <Esc> :call GrooVim_MultiClear()<cr>

endfunc

" Note: The places are chosen; from here they move together.
"
" Note: The keys are handed back and taken again, because which key does what
" is exactly what changed: the arrows were YOUR walk and are now everybody's
" movement, and "Esc" was this, and is the end from here! By Questor
func! GrooVim_MultiSeal() abort

  if !s:on || s:column || !s:marking
    return
  endif

  call GrooVim_MultiKeysOff()
  let s:marking = 0
  call GrooVim_MultiKeysOn(0)

  call GrooVim_GrooVimBarMsg(len(g:GrooVim_MultiPoints) .
   \ " place(s) set: everything moves them all now -- Esc ends it!", 4)

endfunc

func! GrooVim_MultiKeysOff() abort

  for l:key in s:taken
    exec "silent! iunmap " . l:key
  endfor
  let s:taken = []

  for l:was in s:kept
    silent! call mapset("i", 0, l:was)
  endfor
  let s:kept = []

  silent! nunmap <Esc>

endfunc

" Note: Every caret moves, each one running the motion where IT is.
"
" Note: The letters still in the queue are written FIRST. They were typed where
" the carets are NOW, and a caret that moved before they landed would write them
" somewhere nobody asked for.
"
" Note: "keepjumps", because this is one key of yours and not one jump for every
" caret there is -- Ctrl+O would otherwise walk you back through places you
" never went! By Questor
func! GrooVim_MultiMove(motion) abort

  if empty(g:GrooVim_MultiPoints)
    return
  endif

  if !empty(s:queue)
    call GrooVim_MultiFlush()
  endif

  let l:cursorWas = [line("."), col(".")]

  for l:which in range(len(g:GrooVim_MultiPoints))
    let l:point = g:GrooVim_MultiPoints[l:which]
    call cursor(l:point[0], GrooVim_MultiColumnHere(l:point[0], l:point[1]))
    exec "keepjumps normal! " . a:motion
    let g:GrooVim_MultiPoints[l:which] = [line("."), col(".")]
  endfor

  call cursor(l:cursorWas[0], l:cursorWas[1])
  exec "keepjumps normal! " . a:motion

  call GrooVim_MultiMerge()
  call GrooVim_MultiDraw()

endfunc

" Note: Walking to the next place: the cursor alone, one line at a time, keeping
" the column it is in.
"
" Note: The column is carried HERE and not left to Vim. Vim keeps it in
" "curswant", and coming into insert through one of these keys leaves that at
" one, whatever column you were in: measured, marking at line 1 column 4 and
" pressing "Down" landed on line 2 column 1. Written down and read back, the
" walk goes where a walk goes.
"
" Note: And it is picked up again whenever the cursor is somewhere else than
" where the last walk left it -- which is what typing, or a word, or an end of
" line, all do! By Questor
let s:walkColumn = 0
let s:walkLeft = []

func! GrooVim_MultiWalk(step) abort

  if [line("."), col(".")] != s:walkLeft
    let s:walkColumn = col(".")
  endif

  let l:line = line(".") + a:step
  if l:line < 1 || l:line > line("$")
    return
  endif

  call cursor(l:line, min([s:walkColumn, len(getline(l:line)) + 1]))
  let s:walkLeft = [line("."), col(".")]

endfunc

" Note: Two carets that land in the same place are one caret. Without this, a
" "Home" with three carets on one line leaves three of them on its first column,
" and every letter typed arrives three times! By Questor
func! GrooVim_MultiMerge() abort

  let l:seen = {}
  let l:kept = []

  for l:point in g:GrooVim_MultiPoints
    let l:where = l:point[0] . ":" . l:point[1]
    if !has_key(l:seen, l:where)
      let l:seen[l:where] = 1
      call add(l:kept, l:point)
    endif
  endfor

  let g:GrooVim_MultiPoints = l:kept

endfunc

" Note: A column of carets, which is the "Shift+Alt+arrows" of Notepad++.
"
" Note: It goes into insert AT ONCE, because that is the whole of what it is
" for: in Notepad++ you hold the keys, the carets appear, and you type. Asking
" for an "i" afterwards would be the block of Vim again.
"
" Note: The anchor is the line you started on and never moves; the arrows move
" the OTHER end, and the carets are every line between the two. So three times
" down and once up leaves two, and going past the anchor upwards puts them
" above. One key grows it and shrinks it, which is how the keys of Notepad++
" behave! By Questor
func! GrooVim_MultiColumnStart() abort

  if !GrooVim_CanChange()
    call GrooVim_CannotChangeSay()
    return
  endif

  call GrooVim_MultiClear()

  let s:on = 1
  let s:column = 1
  let s:anchor = [line("."), col(".")]
  let s:far = line(".")

  call GrooVim_MultiKeysOn(1)
  call GrooVim_GrooVimBarMsg(
   \ "Several lines at once: Up and Down take in lines, Esc ends it!", 4)

  " Note: "startinsert" and not an "i" fed as a key: fed keys would be read by
  " whatever is waiting for a key, and the F key that brought us here is! By
  " Questor
  startinsert

endfunc

" Note: The far end of the column walks, and the carets are made again from
" where the two ends are! By Questor
func! GrooVim_MultiFar(step) abort

  if !s:on || !s:column
    return
  endif

  let l:wanted = s:far + a:step
  if l:wanted < 1 || l:wanted > line("$")
    return
  endif
  let s:far = l:wanted

  let g:GrooVim_MultiPoints = []
  let l:from = min([s:anchor[0], s:far])
  let l:to = max([s:anchor[0], s:far])
  for l:line in range(l:from, l:to)
    if l:line != s:anchor[0]
      call add(g:GrooVim_MultiPoints, [l:line, s:anchor[1]])
    endif
  endfor

  call GrooVim_MultiDraw()

endfunc

" Note: One caret where the cursor is, which is the "Ctrl+click" of Notepad++.
"
" Note: It opens for writing at once, like the column does, and for the same
" reason: in Notepad++ you click and type. Between one caret and the next you
" walk with whatever moves the cursor IN insert -- the arrows, the words, the
" ends of the line -- and press it again where you want the next one.
"
" Note: No arrows are taken here, and that is the difference from the column:
" there they grow the block, and here they are how you get to the next place! By
" Questor
func! GrooVim_MultiPoint() abort

  if !GrooVim_CanChange()
    call GrooVim_CannotChangeSay()
    return
  endif

  if s:column
    call GrooVim_MultiClear()
  endif

  " Note: Once the places are sealed they are the places. Saying so beats
  " marking one more in a run where the arrows have already moved every caret
  " somewhere else! By Questor
  if s:on && !s:marking
    call GrooVim_GrooVimBarMsg(
     \ "The places are set: Esc ends it, and then you can mark again!", 4)
    return
  endif

  let l:here = [line("."), col(".")]
  for l:point in g:GrooVim_MultiPoints
    if l:point[0] == l:here[0] && l:point[1] == l:here[1]
      return
    endif
  endfor

  let s:on = 1
  let s:marking = 1
  call add(g:GrooVim_MultiPoints, l:here)
  call GrooVim_MultiKeysOff()
  call GrooVim_MultiKeysOn(0)
  call GrooVim_MultiDraw()
  call GrooVim_GrooVimBarMsg(len(g:GrooVim_MultiPoints) .
   \ " place(s): walk and press it again, or type -- Esc sets them!", 4)

  " Note: Already writing, and nothing to do. "mode(1)" and not "mode()":
  " pressed while you are typing, this arrives through the "<C-o>" of its own
  " mapping, and inside a "<C-o>" the short mode() says "n" while the long one
  " says "niI" -- insert is coming back on its own, and a "startinsert" here
  " would be a second one! By Questor
  if mode(1) !~# "^ni" && mode() !~# "^i"
    startinsert
  endif

endfunc

" Note: Every character typed is written down and handed to a timer.
"
" Note: NOT written straight into the other lines: "InsertCharPre" is under the
" |textlock| and a buffer changed from there is a change that does not happen --
" measured, the event firing with the carets in place and the lines coming out
" untouched. A timer of zero runs as soon as the lock is off, and the same is
" true of the "<expr>" mapping of the backspace below.
"
" Note: ONE timer and a queue, and not a timer for each character: with the keys
" arriving in a burst the timers ran out of order, and a backspace ate the wrong
" letter -- measured, typing "XY", a backspace and "ZZZ" left the other lines
" with a letter the first line did not have! By Questor
func! GrooVim_MultiTyped(char) abort

  if empty(g:GrooVim_MultiPoints)
    return
  endif

  call add(s:queue, [line("."), col("."), a:char])
  call GrooVim_MultiSoon()

endfunc

func! GrooVim_MultiSoon() abort

  if s:waiting
    return
  endif

  let s:waiting = 1
  call timer_start(0, {t -> GrooVim_MultiFlush()})

endfunc

" Note: What was typed, put where the other carets are.
"
" Note: The line and column of the REAL cursor come along with each character,
" because a caret sharing that line has to be moved by the character Vim itself
" has already put there: it sat further along the line, and now it sits one
" further! By Questor
func! GrooVim_MultiFlush() abort

  let s:waiting = 0
  if empty(g:GrooVim_MultiPoints)
    let s:queue = []
    return
  endif

  for [l:atLine, l:atColumn, l:what] in s:queue

    let l:step = l:what ==# "\<BS>" ? -1 : 1

    " Note: WHICH caret the cursor is standing on, asked BEFORE anything moves.
    " Vim has already written there, so that one is not written again -- and
    " asking afterwards found nothing, because the line below had just moved it
    " one along: measured, the caret under the cursor taking every letter twice,
    " "AQUI-" coming out as "AAQQUUII--"! By Questor
    let l:same = -1
    for l:which in range(len(g:GrooVim_MultiPoints))
      if g:GrooVim_MultiPoints[l:which][0] == l:atLine
       \ && g:GrooVim_MultiPoints[l:which][1] == l:atColumn
        let l:same = l:which
        break
      endif
    endfor

    " Note: The character Vim put in itself moves whatever was after it -- and
    " the caret the cursor stands on travels with the cursor! By Questor
    call GrooVim_MultiShift(l:atLine, l:atColumn, l:step, -1)

    for l:which in range(len(g:GrooVim_MultiPoints))

      if l:which == l:same
        continue
      endif

      let l:point = g:GrooVim_MultiPoints[l:which]
      let l:line = getline(l:point[0])
      let l:at = GrooVim_MultiColumnHere(l:point[0], l:point[1])

      if l:step < 0
        if l:at > 1
          call setline(l:point[0],
           \ strcharpart(l:line, 0, l:at - 2) . strcharpart(l:line, l:at - 1))
          let g:GrooVim_MultiPoints[l:which][1] = l:at - 1
          call GrooVim_MultiShift(l:point[0], l:at, -1, l:which)
        endif
      else
        call setline(l:point[0],
         \ strcharpart(l:line, 0, l:at - 1) . l:what . strcharpart(l:line, l:at - 1))
        let g:GrooVim_MultiPoints[l:which][1] = l:at + 1
        call GrooVim_MultiShift(l:point[0], l:at, 1, l:which)
      endif

    endfor
  endfor

  let s:queue = []
  call GrooVim_MultiDraw()

endfunc

" Note: A character put into a line moves every caret of THAT line that sits at
" or after it. Two carets on one line is the whole reason: without this, writing
" in the first would leave the second one character behind for every letter
" typed.
"
" Note: "at or after" and not only after, and that is the caret the cursor is
" standing on: it is skipped when the text is written, because Vim has already
" written there, but it has to TRAVEL with the cursor -- left behind, it stops
" being the cursor's own caret at the second letter and the line takes the text
" twice! By Questor
func! GrooVim_MultiShift(line, column, step, except) abort

  let l:which = 0
  for l:point in g:GrooVim_MultiPoints
    if l:which != a:except && l:point[0] == a:line && l:point[1] >= a:column
      let g:GrooVim_MultiPoints[l:which][1] = l:point[1] + a:step
    endif
    let l:which = l:which + 1
  endfor

endfunc

" Note: The backspace has to be told, because it types nothing and
" "InsertCharPre" never hears it! By Questor
inoremap <silent> <expr> <BS> GrooVim_MultiBack()
func! GrooVim_MultiBack() abort

  if !empty(g:GrooVim_MultiPoints)
    call add(s:queue, [line("."), col("."), "\<BS>"])
    call GrooVim_MultiSoon()
  endif

  return "\<BS>"

endfunc

augroup GrooVim_Multi
  autocmd!
  autocmd InsertCharPre * call GrooVim_MultiTyped(v:char)

  " Note: Leaving insert ends it, which is the "Esc" of the two keys. It also
  " ends when you leave the window: the carets are a match of THIS window, and
  " carets left behind in a place you cannot see are carets that will write
  " where you are not looking! By Questor
  autocmd InsertLeave * call GrooVim_MultiEnd()
  autocmd WinLeave,BufLeave * call GrooVim_MultiClear()
augroup END

" Note: What is still in the queue is written BEFORE letting go.
"
" Note: The queue is emptied by a timer, and a timer runs when Vim is waiting.
" An "Esc" pressed right after the last letter arrives before the wait does --
" and the carets were dropped with the letter still in hand: measured, typing
" and leaving in one go, the other lines came out short of the last characters.
"
" Note: And whether insert really ended is asked AFTERWARDS, not now. Leaving it
" is not the same as ending it: a "<C-o>" steps out to run one command and
" walks straight back in, firing "InsertLeave" on the way -- and twenty six keys
" of GrooVim are written that way, the paste, the unindent, the wheel, the page,
" and the F keys themselves. Every one of them would have ended this. A timer of
" zero runs after the dust settles, and by then Vim is back in insert if it was
" ever leaving at all! By Questor
func! GrooVim_MultiEnd() abort

  if empty(g:GrooVim_MultiPoints)
    return
  endif

  if !empty(s:queue)
    call GrooVim_MultiFlush()
  endif

  call timer_start(0, {t -> GrooVim_MultiEndedReally()})

endfunc

" Note: "mode(1)" and not "mode()". Inside a "<C-o>" the short one says "n" --
" it is insert-normal, and the short form calls that normal -- so asking the
" short one threw the carets away on the very key that was adding another:
" measured, the list going from one caret to one OTHER caret instead of two! By
" Questor
func! GrooVim_MultiEndedReally() abort

  if mode(1) =~# "^i" || mode(1) =~# "^ni"
    return
  endif

  call GrooVim_MultiClear()

endfunc

" Note: For the battery to look at what cannot be read from outside! By Questor
func! GrooVim_MultiState() abort
  return {"on": s:on, "column": s:column, "anchor": s:anchor, "far": s:far}
endfunc
