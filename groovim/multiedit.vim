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
  let s:anchor = []
  let s:far = 0
  let s:queue = []

  call GrooVim_MultiDraw()
  call GrooVim_MultiKeysOff()

endfunc

" Note: While the carets are up, the arrows GROW the column and "Esc" ends it.
" The mappings live only for as long as the carets do: outside this, "Down" is
" the "Down" of everybody! By Questor
func! GrooVim_MultiKeysOn(column) abort

  " Note: Through "<Cmd>" and not through a "<C-o>:". The "<C-o>" steps out of
  " insert to run one command, and stepping out FIRES "InsertLeave" -- which is
  " what ends this mode. So the first arrow killed the very thing it was there
  " to grow: measured, the carets emptied and the mapping was gone before the
  " second press. ":h map-cmd" never leaves the mode at all! By Questor
  if a:column
    inoremap <silent> <Down> <Cmd>call GrooVim_MultiFar(1)<cr>
    inoremap <silent> <Up> <Cmd>call GrooVim_MultiFar(-1)<cr>
  endif

  nnoremap <silent> <Esc> :call GrooVim_MultiClear()<cr>

endfunc

func! GrooVim_MultiKeysOff() abort
  silent! iunmap <Down>
  silent! iunmap <Up>
  silent! nunmap <Esc>
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

" Note: One caret where the cursor is, which is the "Ctrl+click" of Notepad++:
" press it at each place you want, walk between them with anything that moves
" the cursor, and then type -- what you write goes to every one of them.
"
" Note: No insert here, and no arrows taken: between one caret and the next you
" need the keyboard to be the keyboard, because choosing WHERE is the whole
" gesture. You type when you are done choosing! By Questor
func! GrooVim_MultiPoint() abort

  if !GrooVim_CanChange()
    call GrooVim_CannotChangeSay()
    return
  endif

  if s:column
    call GrooVim_MultiClear()
  endif

  let l:here = [line("."), col(".")]
  for l:point in g:GrooVim_MultiPoints
    if l:point[0] == l:here[0] && l:point[1] == l:here[1]
      return
    endif
  endfor

  let s:on = 1
  call add(g:GrooVim_MultiPoints, l:here)
  call GrooVim_MultiKeysOn(0)
  call GrooVim_MultiDraw()
  call GrooVim_GrooVimBarMsg(len(g:GrooVim_MultiPoints) .
   \ " place(s) marked: mark more, then type -- Esc ends it!", 4)

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
" and leaving in one go, the other lines came out short of the last characters!
" By Questor
func! GrooVim_MultiEnd() abort

  if !empty(s:queue)
    call GrooVim_MultiFlush()
  endif

  call GrooVim_MultiClear()

endfunc

" Note: For the battery to look at what cannot be read from outside! By Questor
func! GrooVim_MultiState() abort
  return {"on": s:on, "column": s:column, "anchor": s:anchor, "far": s:far}
endfunc
