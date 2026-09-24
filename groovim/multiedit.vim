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

" Note: The colour the cursor of the terminal wears while the places are set --
" the yellow of the carets, because there it IS one of them! By Questor
let g:GrooVim_MultiCursorSet = get(g:, "GrooVim_MultiCursorSet", "#f6d32d")

" Note: What the cursor of the terminal should be painted with, asked by the
" part that paints it. Empty means "nothing to do with me"! By Questor
" Note: On whether this is UP, and not on whether there are carets yet: the
" column starts with none -- they arrive with the first arrow -- and asking for
" the carets left the cursor in the colour of insert until one appeared, which
" is the one moment it should already have changed! By Questor
func! GrooVim_MultiCursorColour() abort

  if !s:on
    return ""
  endif

  return s:marking ? g:cursorColorI : g:GrooVim_MultiCursorSet

endfunc

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

" Note: Two colours, because there are two moments. Orange while the places are
" being CHOSEN, when nothing you type is written; yellow once they are set, when
" everything you do happens in all of them. The colour is the answer to "can I
" write now?", and it is answered without a word! By Questor
highlight GrooVimMultiChoosing ctermbg=208 ctermfg=232 guibg=#ff8700 guifg=#080808
highlight GrooVimMultiCaret ctermbg=220 ctermfg=232 guibg=#f6d32d guifg=#080808
if &t_Co < 256 && !has("gui_running")
  highlight GrooVimMultiChoosing ctermbg=yellow ctermfg=black
  highlight GrooVimMultiCaret ctermbg=yellow ctermfg=black
endif

" Note: The carets are drawn with a match, which belongs to the WINDOW and not
" to the buffer -- and that is right here: the carets of a run of typing belong
" to the window you are typing in! By Questor
" Note: The cursor of the terminal is painted AFTER the mode settles, which is
" what the part that paints it does with every colour: a "startinsert" has not
" happened yet when the function that asked for it is still running! By Questor
func! GrooVim_MultiCursorSoon() abort
  if exists("*GrooVim_CursorColorSoon")
    call GrooVim_CursorColorSoon()
  endif
endfunc

func! GrooVim_MultiDraw() abort

  for l:id in s:ids
    silent! call matchdelete(l:id)
  endfor
  let s:ids = []

  let l:colour = s:marking ? "GrooVimMultiChoosing" : "GrooVimMultiCaret"
  for l:point in g:GrooVim_MultiPoints
    call add(s:ids, matchaddpos(l:colour,
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

  " Note: And the cursor of the terminal goes back to the colour of the mode! By
  " Questor
  if exists("*GrooVim_CursorColorForMode")
    call GrooVim_CursorColorForMode()
  endif

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
 \ "<End>":     "end"
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

  " Note: And they change COLOUR, from the orange of choosing to the yellow of
  " writing -- the cursor of the terminal with them, because it is one of the
  " carets too. It is the answer to "can I write now?", given without a word! By
  " Questor
  call GrooVim_MultiDraw()
  if exists("*GrooVim_CursorColorForMode")
    call GrooVim_CursorColorForMode()
  endif

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

  " Note: The end of a line is a COLUMN and not a motion. "$" lands on the last
  " character and an "l" after it only goes past when "virtualedit" says it may
  " -- so the same key left the caret one column short wherever that option was
  " not what it usually is here, and a Del there took a character away instead
  " of taking the line break away: measured, "bbb" coming back as "bb"! By
  " Questor
  for l:which in range(len(g:GrooVim_MultiPoints))
    let l:point = g:GrooVim_MultiPoints[l:which]
    if a:motion ==# "end"
      let g:GrooVim_MultiPoints[l:which] =
       \ [l:point[0], len(getline(l:point[0])) + 1]
      continue
    endif
    call cursor(l:point[0], GrooVim_MultiColumnHere(l:point[0], l:point[1]))
    exec "keepjumps normal! " . a:motion
    let g:GrooVim_MultiPoints[l:which] = [line("."), col(".")]
  endfor

  if a:motion ==# "end"
    call cursor(l:cursorWas[0], len(getline(l:cursorWas[0])) + 1)
  else
    call cursor(l:cursorWas[0], l:cursorWas[1])
    exec "keepjumps normal! " . a:motion
  endif

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
  call GrooVim_MultiCursorSoon()

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
  call GrooVim_MultiCursorSoon()

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

  " Note: While the places are being chosen, what is typed is SWALLOWED.
  "
  " Note: Writing with one caret in a run that is about to have five is writing
  " in one place and meaning five: the column of every place still to be chosen
  " would already be wrong. "v:char" emptied is the way to say no -- measured,
  " the event firing and the line coming out exactly as it was! By Questor
  if s:marking
    let v:char = ""
    call GrooVim_GrooVimBarMsg(
     \ "Choosing where: press Esc to set the places, then write!", 3)
    return
  endif

  call add(s:queue, [line("."), col("."), a:char, 0, []])
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

  let s:cursorLine = line(".")
  let s:cursorColumn = col(".")

  for [l:atLine, l:atColumn, l:what, l:joinAt, l:each] in s:queue

    let s:lengthWas = l:what ==# "\<Tab>"
     \ ? len(getline(l:atLine)) - len(GrooVim_MultiTabAt(l:atColumn)) : 0

    let l:step = l:what ==# "\<BS>" ? -1 : (l:what ==# "\<Del>" ? 0 : 1)

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
    if l:what ==# "\<BS>" && l:atColumn == 1 && l:atLine > 1
      " Note: The real cursor joined its line to the one above. Vim moved the
      " cursor itself; every caret that was on the line that went is moved here
      " -- INCLUDING the one the cursor stands on, which is skipped everywhere
      " else because Vim does its work: there Vim did the work on the TEXT and
      " not on the caret, and a caret left on a line that no longer exists
      " writes where nobody is looking. Measured, typing after a backspace in
      " the first column: a third letter appeared on a line with no caret! By
      " Questor
      call GrooVim_MultiJoined(l:atLine, l:atLine - 1, l:joinAt, -1, 0)
    elseif l:what ==# "\<Del>" && l:joinAt > 0
      call GrooVim_MultiJoined(l:atLine + 1, l:atLine, l:joinAt, -1, 0)
    elseif l:what ==# "\<Del>"
      call GrooVim_MultiShift(l:atLine, l:atColumn + 1, -1, -1)
    elseif l:what ==# "\<CR>"
      " Note: The Enter of the real cursor cut its line in two: everything that
      " was below it is one line further down, and whatever sat after the cut on
      " that very line is now on the line BELOW, counting from its start.
      "
      " Note: And the caret the cursor stands on goes with it -- it is skipped
      " when the TEXT is written, because Vim writes there itself, and it is not
      " skipped here, because Vim moved the cursor and not the caret. Left
      " behind, it stayed on the line above the cut with the column it had, and
      " an Enter and a backspace -- which should leave a file exactly as it was
      " -- joined the wrong two lines: measured, "ccc ddd" and "eee fff" coming
      " back as "ccc dddeee"! By Questor
      call GrooVim_MultiCut(l:atLine, l:atColumn, -1, 0)
    elseif l:what ==# "\<Tab>"
      call GrooVim_MultiShift(l:atLine, l:atColumn,
       \ len(getline(l:atLine)) - s:lengthWas, -1)
    else
      call GrooVim_MultiShift(l:atLine, l:atColumn, l:step, -1)
    endif

    for l:which in range(len(g:GrooVim_MultiPoints))

      if l:which == l:same
        continue
      endif

      call GrooVim_MultiDo(l:which, l:what,
       \ l:which < len(l:each) ? l:each[l:which] : -1)

    endfor
  endfor

  let s:queue = []

  " Note: The real cursor is carried too. A caret ABOVE it that joined two lines
  " took a line out of the file, and Vim keeps a cursor on the line NUMBER it
  " was on -- which is somebody else's line now! By Questor
  if [line("."), col(".")] != [s:cursorLine, s:cursorColumn]
    call cursor(s:cursorLine, s:cursorColumn)
  endif

  call GrooVim_MultiDraw()

endfunc

" Note: Two lines became one. Everything that was on the line that went is on
" the one that received it, pushed along by however long that one already was;
" and everything below it comes up one.
"
" Note: "alsoCursor" says whether the REAL cursor has to come up as well. When
" the join was its own, Vim has already moved it; when it was a caret's, it has
" not, and nobody else will! By Questor
func! GrooVim_MultiJoined(gone, into, offset, except, alsoCursor) abort

  let l:which = 0
  for l:point in g:GrooVim_MultiPoints
    if l:which != a:except
      if l:point[0] == a:gone
        let g:GrooVim_MultiPoints[l:which] = [a:into, l:point[1] + a:offset]
      elseif l:point[0] > a:gone
        let g:GrooVim_MultiPoints[l:which][0] = l:point[0] - 1
      endif
    endif
    let l:which = l:which + 1
  endfor

  if a:alsoCursor
    if s:cursorLine == a:gone
      let s:cursorLine = a:into
      let s:cursorColumn = s:cursorColumn + a:offset
    elseif s:cursorLine > a:gone
      let s:cursorLine = s:cursorLine - 1
    endif
  endif

endfunc

" Note: One key, at one caret. The letters put themselves in; the others do what
" the key means -- and each one does it where THAT caret is, which is the whole
" idea: a Tab fills to the next stop of its own column, and an Enter cuts its
" own line! By Questor
func! GrooVim_MultiDo(which, what, room) abort

  let l:point = g:GrooVim_MultiPoints[a:which]
  let l:line = getline(l:point[0])
  let l:at = GrooVim_MultiColumnHere(l:point[0], l:point[1])

  if a:what ==# "\<BS>"
    if a:room >= 0
      " Note: In the first column a backspace does not take a character away: it
      " takes the LINE BREAK away, and the line goes up to join the one above.
      " "room" is how long that one was when the key was pressed! By Questor
      call setline(l:point[0] - 1, getline(l:point[0] - 1) . l:line)
      exec "silent " . l:point[0] . "delete _"
      let g:GrooVim_MultiPoints[a:which] = [l:point[0] - 1, a:room + 1]
      call GrooVim_MultiJoined(l:point[0], l:point[0] - 1, a:room, a:which, 1)
    elseif l:at > 1
      call setline(l:point[0],
       \ strcharpart(l:line, 0, l:at - 2) . strcharpart(l:line, l:at - 1))
      let g:GrooVim_MultiPoints[a:which][1] = l:at - 1
      call GrooVim_MultiShift(l:point[0], l:at, -1, a:which)
    endif
    return
  endif

  if a:what ==# "\<Del>"
    if a:room >= 0
      " Note: And at the end of the line it takes the break away FORWARD: the
      " line below comes up and joins this one! By Questor
      call setline(l:point[0], l:line . getline(l:point[0] + 1))
      exec "silent " . (l:point[0] + 1) . "delete _"
      call GrooVim_MultiJoined(l:point[0] + 1, l:point[0], a:room, a:which, 1)
    elseif l:at <= len(l:line)
      call setline(l:point[0],
       \ strcharpart(l:line, 0, l:at - 1) . strcharpart(l:line, l:at))
      call GrooVim_MultiShift(l:point[0], l:at + 1, -1, a:which)
    endif
    return
  endif

  if a:what ==# "\<CR>"
    call setline(l:point[0], strcharpart(l:line, 0, l:at - 1))
    call append(l:point[0], GrooVim_MultiIndentOf(l:line) . strcharpart(l:line, l:at - 1))
    let g:GrooVim_MultiPoints[a:which] =
     \ [l:point[0] + 1, len(GrooVim_MultiIndentOf(l:line)) + 1]
    call GrooVim_MultiCut(l:point[0], l:at, a:which, 1)
    return
  endif

  if a:what ==# "\<Tab>"
    let l:fill = GrooVim_MultiTabAt(l:at)
    call setline(l:point[0],
     \ strcharpart(l:line, 0, l:at - 1) . l:fill . strcharpart(l:line, l:at - 1))
    let g:GrooVim_MultiPoints[a:which][1] = l:at + len(l:fill)
    call GrooVim_MultiShift(l:point[0], l:at, len(l:fill), a:which)
    return
  endif

  call setline(l:point[0],
   \ strcharpart(l:line, 0, l:at - 1) . a:what . strcharpart(l:line, l:at - 1))
  let g:GrooVim_MultiPoints[a:which][1] = l:at + 1
  call GrooVim_MultiShift(l:point[0], l:at, 1, a:which)

endfunc

" Note: What a Tab puts in, at the column it is pressed in: the spaces up to the
" next stop, or a Tab itself when the file is written with them. Each caret has
" its own column, so each one fills its own distance! By Questor
func! GrooVim_MultiTabAt(column) abort

  if !&expandtab
    return "\t"
  endif

  let l:width = &softtabstop > 0 ? &softtabstop
   \ : (&shiftwidth > 0 ? &shiftwidth : &tabstop)
  return repeat(" ", l:width - ((a:column - 1) % l:width))

endfunc

" Note: The indent a line begins with, which is what Vim copies onto the line an
" "Enter" opens when "autoindent" is on -- and GrooVim has it on! By Questor
func! GrooVim_MultiIndentOf(line) abort
  return &autoindent ? matchstr(a:line, "^\\s*") : ""
endfunc

" Note: A line cut in two moves everything below it one line down, and whatever
" was on that line AFTER the cut goes with it -- to the new line, counting from
" where the cut left it! By Questor
" Note: "alsoCursor" says whether the REAL cursor has to go down as well. When
" the cut was its own, Vim has already taken it to the new line; when it was a
" caret's, nobody has -- and a cursor left a line short joins the wrong two
" lines the next time a backspace is pressed: measured, an Enter and a
" backspace, which should leave a file exactly as it was, eating a line of it!
" By Questor
func! GrooVim_MultiCut(line, column, except, alsoCursor) abort

  let l:which = 0
  for l:point in g:GrooVim_MultiPoints
    if l:which != a:except
      if l:point[0] > a:line
        let g:GrooVim_MultiPoints[l:which][0] = l:point[0] + 1
      elseif l:point[0] == a:line && l:point[1] >= a:column
        let g:GrooVim_MultiPoints[l:which] =
         \ [l:point[0] + 1, l:point[1] - a:column + 1]
      endif
    endif
    let l:which = l:which + 1
  endfor

  if a:alsoCursor
    if s:cursorLine > a:line
      let s:cursorLine = s:cursorLine + 1
    elseif s:cursorLine == a:line && s:cursorColumn >= a:column
      let s:cursorLine = s:cursorLine + 1
      let s:cursorColumn = s:cursorColumn - a:column + 1
    endif
  endif

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

" Note: The keys that are not characters have to be TOLD, one by one.
"
" Note: "InsertCharPre" hears the letters and nothing else: measured, typing a
" Tab, an Enter and a Del with the event watching, and only the letter after
" them was heard. That is why they did nothing to the other carets -- they never
" reached this at all.
"
" Note: Each of them hands the queue what it is and then returns the key itself,
" so the real cursor does its own work the way it always did, and the carets
" follow in the timer afterwards.
"
" Note: By NAME and not by the key. The key of a backspace is a control
" character, and a control character written into the command of a "<Cmd>" does
" not survive the trip: measured, the function never ran at all and the burst
" went on doing the wrong thing with nothing said about it! By Questor
let s:keyOf = {"BS": "\<BS>", "Del": "\<Del>", "CR": "\<CR>", "Tab": "\<Tab>"}

inoremap <silent> <expr> <BS> GrooVim_MultiKey("BS")
inoremap <silent> <expr> <Del> GrooVim_MultiKey("Del")
inoremap <silent> <expr> <CR> GrooVim_MultiKey("CR")
inoremap <silent> <expr> <Tab> GrooVim_MultiKey("Tab")

func! GrooVim_MultiKey(name) abort

  let l:key = s:keyOf[a:name]

  if empty(g:GrooVim_MultiPoints)
    return l:key
  endif

  " Note: Nothing is changed while the places are still being chosen, and that
  " includes these: an "Enter" there would move every place that is below it! By
  " Questor
  if s:marking
    call GrooVim_GrooVimBarMsg(
     \ "Choosing where: press Esc to set the places, then write!", 3)
    return ""
  endif

  " Note: A "<Cmd>" first, and the key itself after it.
  "
  " Note: The "<Cmd>" is what lets the queue be emptied BEFORE the key is looked
  " at, and it has to be emptied: the letters waiting in it have not moved the
  " carets yet, so a backspace arriving in the same burst would read a caret as
  " still being in the first column and take a line break away instead of a
  " letter. Measured, "XY" and a backspace in one go: the two lines were JOINED.
  "
  " Note: An "<expr>" cannot empty it -- it is under the |textlock| , and a
  " buffer changed from there is a change that does not happen -- but a "<Cmd>"
  " can: measured, a "setline" from inside one, with the mode still insert! By
  " Questor
  return "\<Cmd>call GrooVim_MultiTook('" . a:name . "')\<cr>" . l:key

endfunc

" Note: What a key that is not a character needs to know, asked while it is
" still true: how long the line that RECEIVES a join was -- for the real cursor
" and for every caret -- because after the key the two lines are already one! By
" Questor
func! GrooVim_MultiTook(name) abort

  let l:key = s:keyOf[a:name]

  if empty(g:GrooVim_MultiPoints)
    return
  endif

  if !empty(s:queue)
    call GrooVim_MultiFlush()
  endif

  let l:joinAt = 0
  if l:key ==# "\<BS>" && col(".") == 1 && line(".") > 1
    let l:joinAt = len(getline(line(".") - 1))
  elseif l:key ==# "\<Del>" && col(".") > len(getline(".")) && line(".") < line("$")
    let l:joinAt = len(getline("."))
  endif

  let l:each = []
  for l:point in g:GrooVim_MultiPoints
    let l:room = -1
    if l:key ==# "\<BS>" && l:point[1] <= 1 && l:point[0] > 1
      let l:room = len(getline(l:point[0] - 1))
    elseif l:key ==# "\<Del>"
     \ && l:point[1] > len(getline(l:point[0])) && l:point[0] < line("$")
      let l:room = len(getline(l:point[0]))
    endif
    call add(l:each, l:room)
  endfor

  call add(s:queue, [line("."), col("."), l:key, l:joinAt, l:each])
  call GrooVim_MultiSoon()

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
  return {"on": s:on, "column": s:column, "anchor": s:anchor, "far": s:far,
   \ "marking": s:marking}
endfunc
