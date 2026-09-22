"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
"SHORTCUTS (AND REMOVE VIM STUPID BEHAVIOR)
"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" Note: Every mapping of visual mode here reaches its function through "<Cmd>",
" and not through the ":<C-u>" that GrooVim used for ten years.
"
" Note: Typing ":" in visual mode puts the cursor on the FIRST line of the range
" (see ":h v_:") and the window goes there with it, so every one of these
" functions had to put the selection back with a "gv" -- and a "gv" that lands
" more than a screen away makes Vim CENTRE what it lands on. Measured: window on
" 80..120 and cursor on 115, one Shift-Alt-Up left the window on 95..135 with the
" cursor on 100, a line that had been on the screen the whole time.
"
" Note: Putting the window back afterwards fixes where it ENDS and not what is
" painted on the way. Between the ":" and the "gv" the window really is somewhere
" else -- measured, on 20..60 with the cursor on the first line of the range --
" and whatever paints in that instant shows it. Vim paints when something makes
" it, and GrooVim keeps a timer of its own up, polling the Caps Lock. That frame
" is the blink, and it is why it is only seen SOMETIMES.
"
" Note: "<Cmd>" runs the command without leaving the mode it was called in: the
" cursor does not move, so the window has nothing to come back from, and the
" selection is still there -- ":h map-cmd" says it in as many words, "Visual mode
" is preserved, so tricks with gv are not needed". It also needs no "<silent>",
" because no command line is ever opened! By Questor

" Note: Swap : and ; to make colon commands easier to type! By Questor
nnoremap  ;  :
nnoremap  :  ;
" Note: Important for the execution of certain commands in some functionalies! By Questor
let g:cmdLineCaller = ";"

nnoremap <silent> <expr> <A-S-Left> (g:GrooVim_GroovyMoveEnabled ? ":call GrooVim_GroovyMove(\"n\", \"l\", 0, 0)<cr>" : ":let g:onMoveScreen = 1<cr>")
nnoremap <silent> <expr> <A-S-Down> (g:GrooVim_GroovyMoveEnabled ? ":call GrooVim_GroovyMove(\"n\", \"d\", 0, 0)<cr>" : ":let g:onMoveScreen = 1<cr>")
nnoremap <silent> <expr> <A-S-Up> (g:GrooVim_GroovyMoveEnabled ? ":call GrooVim_GroovyMove(\"n\", \"u\", 0, 0)<cr>" : ":let g:onMoveScreen = 1<cr>")
nnoremap <silent> <expr> <A-S-Right> (g:GrooVim_GroovyMoveEnabled ? ":call GrooVim_GroovyMove(\"n\", \"r\", 0, 0)<cr>" : ":let g:onMoveScreen = 1<cr>")

" Note: The variable ":let g:onMoveScreen = 1<cr>" is setted in another opportunity
" for the visual mode! Questor
vnoremap <expr> <A-S-Left> (g:GrooVim_GroovyMoveEnabled ? "\<Cmd>call GrooVim_GroovyMove(\"v\", \"l\", 0, 0)\<cr>" : "")
vnoremap <expr> <A-S-Down> (g:GrooVim_GroovyMoveEnabled ? "\<Cmd>call GrooVim_GroovyMove(\"v\", \"d\", 0, 0)\<cr>" : "")
vnoremap <expr> <A-S-Up> (g:GrooVim_GroovyMoveEnabled ? "\<Cmd>call GrooVim_GroovyMove(\"v\", \"u\", 0, 0)\<cr>" : "")
vnoremap <expr> <A-S-Right> (g:GrooVim_GroovyMoveEnabled ? "\<Cmd>call GrooVim_GroovyMove(\"v\", \"r\", 0, 0)\<cr>" : "")

inoremap <silent> <expr> <A-S-Left> (g:GrooVim_GroovyMoveEnabled ? "<C-o>:call GrooVim_GroovyMove(\"i\", \"l\", 0, 0)<cr>" : "<C-o>:let g:onMoveScreen = 1<cr>")
inoremap <silent> <expr> <A-S-Down> (g:GrooVim_GroovyMoveEnabled ? "<C-r>=GrooVim_GroovyMoveMarkColumn()<cr><C-o>:call GrooVim_GroovyMove(\"i\", \"d\", 0, 0)<cr>" : "<C-o>:let g:onMoveScreen = 1<cr>")
inoremap <silent> <expr> <A-S-Up> (g:GrooVim_GroovyMoveEnabled ? "<C-r>=GrooVim_GroovyMoveMarkColumn()<cr><C-o>:call GrooVim_GroovyMove(\"i\", \"u\", 0, 0)<cr>" : "<C-o>:let g:onMoveScreen = 1<cr>")
inoremap <silent> <expr> <A-S-Right> (g:GrooVim_GroovyMoveEnabled ? "<C-o>:call GrooVim_GroovyMove(\"i\", \"r\", 0, 0)<cr>" : "<C-o>:let g:onMoveScreen = 1<cr>")

" Note: The page keys move by a PAGE -- the last number, 2 -- which is the
" window as it is at the moment they are pressed, and not fifteen lines! By
" Questor
nnoremap <silent> <PageDown> :call GrooVim_GroovyMove("n", "d", 1, 2)<cr>
nnoremap <silent> <PageUp> :call GrooVim_GroovyMove("n", "u", 1, 2)<cr>

vnoremap <PageDown> <Cmd>call GrooVim_GroovyMove("v", "d", 1, 2)<cr>
vnoremap <PageUp> <Cmd>call GrooVim_GroovyMove("v", "u", 1, 2)<cr>

inoremap <silent> <PageDown> <C-o>:call GrooVim_GroovyMove("i", "d", 1, 2)<cr>
inoremap <silent> <PageUp> <C-o>:call GrooVim_GroovyMove("i", "u", 1, 2)<cr>

nnoremap <silent> <C-A-Left> :call GrooVim_GroovyMove("n", "l", 0, 1)<cr>
nnoremap <silent> <C-A-Down> :call GrooVim_GroovyMove("n", "d", 0, 1)<cr>
nnoremap <silent> <C-A-Up> :call GrooVim_GroovyMove("n", "u", 0, 1)<cr>
nnoremap <silent> <C-A-Right> :call GrooVim_GroovyMove("n", "r", 0, 1)<cr>

vnoremap <C-A-Left> <Cmd>call GrooVim_GroovyMove("v", "l", 0, 1)<cr>
vnoremap <C-A-Down> <Cmd>call GrooVim_GroovyMove("v", "d", 0, 1)<cr>
vnoremap <C-A-Up> <Cmd>call GrooVim_GroovyMove("v", "u", 0, 1)<cr>
vnoremap <C-A-Right> <Cmd>call GrooVim_GroovyMove("v", "r", 0, 1)<cr>

" Note: The vertical ones, here and in the "Alt" with "Shift" ones above, take
" note of the column BEFORE the "<C-o>". Going to
" normal mode and coming back is what loses it -- by the time the function runs it
" is already gone -- and without it walking down through a SHORT line left the
" cursor at the end of that line instead of coming back to the column you started
" from! By Questor
inoremap <silent> <C-A-Left> <C-o>:call GrooVim_GroovyMove("i", "l", 0, 1)<cr>
inoremap <silent> <C-A-Down> <C-r>=GrooVim_GroovyMoveMarkColumn()<cr><C-o>:call GrooVim_GroovyMove("i", "d", 0, 1)<cr>
inoremap <silent> <C-A-Up> <C-r>=GrooVim_GroovyMoveMarkColumn()<cr><C-o>:call GrooVim_GroovyMove("i", "u", 0, 1)<cr>
inoremap <silent> <C-A-Right> <C-o>:call GrooVim_GroovyMove("i", "r", 1, 1)<cr>

" Note: Allows fluid cursor movement on the screen! By Questor
let g:onMoveScreen = 0
let g:GrooVim_GroovyMoveType = 0
let g:GrooVim_GroovyMoveEnabled = 1
" Note: Where the insert mode mappings leave the column to keep, taken while still
" in insert mode! By Questor
let g:GrooVim_GroovyMoveColumn = 0

" Note: Raised by those same mappings, and it says that the trip out of insert is
" ours: while it is up, the cursor is NOT painted with the colour of normal mode!
" By Questor
let g:GrooVim_CursorColorHoldInsert = 0
func! GrooVim_GroovyMoveMarkColumn() abort
  let g:GrooVim_GroovyMoveColumn = getcurpos()[4]

  " Note: And the cursor keeps the colour of insert mode for the whole trip. The
  " "<C-o>" that comes right after steps out of insert, and Vim paints the cursor
  " with the normal mode colour on the way out: on a long smooth movement it lasts
  " long enough to SEE it turn green, as if the mode had changed.
  "
  " Note: It has to be HERE, before the "<C-o>": from inside the movement it would
  " already be too late! By Questor
  let g:GrooVim_CursorColorHoldInsert = 1
  let &t_EI = "\<Esc>]12;" . g:cursorColorI . "\x7"

  return ""
endfunc

" Note: Gives the cursor back to the colours of each mode! By Questor
func! GrooVim_GroovyMoveColorsBack() abort
  if g:GrooVim_CursorColorHoldInsert == 1
    let g:GrooVim_CursorColorHoldInsert = 0
    let &t_EI = "\<Esc>]12;" . g:cursorColorNV . "\x7"
  endif
endfunc

" Note: Puts the column to keep back WITHOUT moving the cursor: the first three
" items of "cursor()" are the position as it is, virtual offset included, and only
" the fourth one changes. Moving the cursor here would drag it out of the areas
" without character, which is exactly what this function exists to travel over! By
" Questor
func! GrooVim_GroovyMoveKeepColumn(direction, columnToKeep) abort
  if (a:direction != "u" && a:direction != "d") || a:columnToKeep <= 0
    return
  endif
  let l:positionNow = getcurpos()
  call cursor([l:positionNow[1], l:positionNow[2], l:positionNow[3], a:columnToKeep])
endfunc

func! GrooVim_GroovyMove(mod, direction, blockSmoothness, GrooVim_GroovyMoveType) range abort

  " Note: A "finally", because this movement can be INTERRUPTED and usually is:
  " GrooVim itself says "Use Ctrl+C to stop!" while a smooth one is running. An
  " interrupt walks out of the function, and the line at the end that gives the
  " cursor back to the colours of each mode never ran! By Questor
  try

    let g:GrooVim_GroovyMoveEnabled = 0

    if a:blockSmoothness == 0 && g:GrooVim_GrooVimBarMsgEnabled == 0 && a:GrooVim_GroovyMoveType == 0
      call GrooVim_GrooVimBarMsg("Use Ctrl+C to stop!", 1)
    endif

    " Note: "curswant" is the column the cursor TRIES to keep across vertical moves.
    "
    " Note: In insert mode it comes from the mapping, which took it before "<C-o>":
    " here it would already be the column of the SHORT line. Everywhere else, taken
    " at the very top, because the "virtualedit" below disturbs it too.
    "
    " Note: The mapping leaves a zero behind once it is read, so a value that was
    " never marked -- or already used -- never moves anything! By Questor
    let l:columnToKeep = a:mod == "i" ? g:GrooVim_GroovyMoveColumn : getcurpos()[4]
    let g:GrooVim_GroovyMoveColumn = 0

    if &virtualedit == "onemore"
      set virtualedit=all
    endif

    " Note: The column to keep goes back BEFORE the movement, because it is what
    "<Up>" and "<Down>" aim at. Putting it back only afterwards fixed the number
    " and left the cursor one column short: the move had already happened with the
    " wrong aim! By Questor
    call GrooVim_GroovyMoveKeepColumn(a:direction, l:columnToKeep)

    let l:disableSmoothness = 0
    let l:disableHorizontalSmoothness = 0
    let l:horizontalSmoothnessFactor = 2
    let l:verticalSmoothnessFactor = 10

    " Note: How far a movement goes: a stretch (0), one step (1), or a PAGE (2).
    "
    " Note: A page is not a number written down here -- it is what the window is
    " showing at the moment the key is pressed. It used to be the fifteen lines
    " of the stretch, so the same key jumped past the screen on a small terminal
    " and left half of it unread on a big one, and resizing the window changed
    " nothing. What decides how much a page is, is the page.
    "
    " Note: Two lines short of the whole window, and that is not a rounding: the
    " lines that were at the bottom are at the top when you arrive, so the eye
    " has a foothold and nothing is read twice or missed. It is what the "Ctrl+F"
    " of Vim does, and what every editor that turns pages does.
    "
    " Note: "winheight(0)" is the window and not the terminal: with a split, or
    " with a panel of GrooVim open beside the text, a page is what THIS window
    " shows, which is the one you are reading! By Questor
    if a:GrooVim_GroovyMoveType == 0
      let l:horizontalMovementFactor = 20
      let l:verticalMovementFactor = 15
    elseif a:GrooVim_GroovyMoveType == 1
      let l:horizontalMovementFactor = 1
      let l:verticalMovementFactor = 1
    elseif a:GrooVim_GroovyMoveType == 2
      let l:horizontalMovementFactor = max([winwidth(0) - 2, 1])
      let l:verticalMovementFactor = max([winheight(0) - 2, 1])
    endif

    if a:mod == "n" || a:mod == "i"

      if a:direction == "l"
        for i in range(1, l:horizontalMovementFactor)
          if a:blockSmoothness == 0 && l:disableSmoothness == 0 && l:disableHorizontalSmoothness == 0
            exec "sleep " . l:horizontalSmoothnessFactor . "m"
          endif
          exec "norm \<Left>"
          if a:blockSmoothness == 0
            redraw
          endif
        endfor
      elseif a:direction == "d"
        for i in range(1, l:verticalMovementFactor)
          if a:blockSmoothness == 0 && l:disableSmoothness == 0
            exec "sleep " . l:verticalSmoothnessFactor . "m"
          endif
          exec "norm \<Down>"
          if a:blockSmoothness == 0
            redraw
          endif
        endfor
      elseif a:direction == "u"
        for i in range(1, l:verticalMovementFactor)
          if a:blockSmoothness == 0 && l:disableSmoothness == 0
            exec "sleep " . l:verticalSmoothnessFactor . "m"
          endif
          exec "norm \<Up>"
          if a:blockSmoothness == 0
            redraw
          endif
        endfor
      elseif a:direction == "r"
        for i in range(1, l:horizontalMovementFactor)
          if a:blockSmoothness == 0 && l:disableSmoothness == 0 && l:disableHorizontalSmoothness == 0
            exec "sleep " . l:horizontalSmoothnessFactor . "m"
          endif
          exec "norm \<Right>"
          if a:blockSmoothness == 0
            redraw
          endif
        endfor
      endif

    elseif a:mod == "v"

      if a:direction == "l"
        for i in range(1, l:horizontalMovementFactor)
          if a:blockSmoothness == 0 && l:disableSmoothness == 0 && l:disableHorizontalSmoothness == 0
            exec "sleep " . l:horizontalSmoothnessFactor . "m"
          endif
          exec "norm \<Left>"
          if a:blockSmoothness == 0
            redraw
          endif
        endfor
      elseif a:direction == "d"
        for i in range(1, l:verticalMovementFactor)
          if a:blockSmoothness == 0 && l:disableSmoothness == 0
            exec "sleep " . l:verticalSmoothnessFactor . "m"
          endif
          exec "norm \<Down>"
          if a:blockSmoothness == 0
            redraw
          endif
        endfor
      elseif a:direction == "u"
        for i in range(1, l:verticalMovementFactor)
          if a:blockSmoothness == 0 && l:disableSmoothness == 0
            exec "sleep " . l:verticalSmoothnessFactor . "m"
          endif
          exec "norm \<Up>"
          if a:blockSmoothness == 0
            redraw
          endif
        endfor
      elseif a:direction == "r"
        for i in range(1, l:horizontalMovementFactor)
          if a:blockSmoothness == 0 && l:disableSmoothness == 0 && l:disableHorizontalSmoothness == 0
            exec "sleep " . l:horizontalSmoothnessFactor . "m"
          endif
          exec "norm \<Right>"
          if a:blockSmoothness == 0
            redraw
          endif
        endfor
      endif

      " Note: Called straight from here, in visual mode, like every other branch
      " of this function.
      "
      " Note: It used to be written into a variable, and the movement ended with
      " an "<Esc>" so that "CursorHold" -- which only happens in normal mode --
      " would fire, run what was written there, and put the selection back with a
      " "gv". That is the whole of the second blink: leaving visual mode drops the
      " marking of EVERY selected line, Vim paints the screen without it, and the
      " "gv" paints it again. Measured on the screen itself, at the moment of the
      " "CursorHold" and before its "gv": the attribute painted on a selected line
      " was 0, the attribute of a line outside the selection.
      "
      " Note: The detour existed because the ":" of the old mapping had already
      " left visual mode anyway. Through "<Cmd>" the mode was never left, so there
      " is nothing to come back from! By Questor
      call GrooVim_GroovyMoveAdjuster(a:direction, a:blockSmoothness, l:disableSmoothness, l:verticalSmoothnessFactor)

    endif

    let g:onMoveScreen = 1

    " Note: "set virtualedit=onemore" if the area is already valid! By Questor
    "
    " Note: And ONLY then. Leaving "all" on while the cursor is over an area without
    " character is what lets it stay there: putting it back unconditionally dragged
    " the cursor onto the text at the end of every movement! By Questor
    if virtcol('.') <= virtcol('$')

      if &virtualedit == "all"
        set virtualedit=onemore
      endif

      if a:direction == "r" && a:mod != "v"
        call GrooVim_GroovyMoveAdjuster(a:direction, a:blockSmoothness, l:disableSmoothness, l:verticalSmoothnessFactor)
      endif

    endif

    " Note: The column the cursor tries to keep goes back, and ONLY it: the cursor
    " itself is left exactly where the movement put it, virtual space included.
    "
    " Note: Moving the cursor here was a mistake of mine: it dragged it back onto
    " the text and took away the whole point of this function, which is travelling
    " over areas WITHOUT character. The fourth item of "cursor()" is the column to
    " keep; the first three are the position, and they go back unchanged -- the
    " third one is the virtual offset, which is what holds the cursor out there.
    "
    " Note: And once more AFTER the block above, because coming out of
    " "virtualedit=all" snaps the cursor onto the text and resets the column. This
    " one is for the NEXT movement: it is what the mapping will read! By Questor
    call GrooVim_GroovyMoveKeepColumn(a:direction, l:columnToKeep)

    " Note: The trip is over, so the cursor goes back to answering to each mode! By
    " Questor
    call GrooVim_GroovyMoveColorsBack()

  finally
    " Note: The trip is over however it ended, so the cursor goes back to
    " answering to each mode! By Questor
    call GrooVim_GroovyMoveColorsBack()

    " Note: And it is painted by the mode we are actually in -- ON A TIMER, after
    " this function has returned.
    "
    " Note: Giving the colours back is not enough, because nothing repaints on
    " its own: a movement passes through normal mode on its way -- the mapping of
    " visual mode leaves it with a ":" and comes back, and "t_EI" fires whenever
    " insert is left -- and each of those paints the cursor green.
    "
    " Note: And painting HERE is not enough either. Traced, on a movement that
    " ends in visual mode: the paint from inside this function saw "mode()"
    " answer "n", because the mode has not settled while the mapping that called
    " us is still running. A timer of zero runs on the next pass of the main
    " loop, where what Vim answers is what you are actually in! By Questor
    if get(g:, "GrooVim_CursorColorEnabled", 0) && exists("*GrooVim_CursorColorSoon")
      call GrooVim_CursorColorSoon()
    endif
  endtry

endfunc

" Note: Adjusts the cursor position when this ends the movement ("GrooVim_GroovyMove()") over a tab char! By Questor
func! GrooVim_GroovyMoveAdjuster(direction, blockSmoothness, disableSmoothness, verticalSmoothnessFactor) range abort

  let l:lineNow = getline(".")
  let l:lineSplited = split(l:lineNow, '\zs')

  if len(l:lineSplited) >= 1 && len(l:lineSplited) > (col(".") - 1)

    if l:lineSplited[col(".") - 1] == " "

      if a:blockSmoothness == 0 && a:disableSmoothness == 0
        exec "sleep " . a:verticalSmoothnessFactor . "m"
      endif

      let l:cursorPosInsert = getpos(".")
      " ldur
      if a:direction == "l"
        call setpos('.', [l:cursorPosInsert[0], l:cursorPosInsert[1], l:cursorPosInsert[2], 0])
      elseif a:direction == "r"
        call setpos('.', [l:cursorPosInsert[0], l:cursorPosInsert[1], l:cursorPosInsert[2] + 1, 0])
      elseif a:direction == "d" || a:direction == "u"
        call setpos('.', [l:cursorPosInsert[0], l:cursorPosInsert[1], l:cursorPosInsert[2], 0])
      endif

      if a:blockSmoothness == 0
        redraw
      endif

      let g:onMoveScreen = 1

    endif

  endif

endfunc

nnoremap <silent> <A-End> :call GrooVim_SelWord("n", "r", 1)<cr>
nnoremap <silent> <A-Home> :call GrooVim_SelWord("n", "l", 1)<cr>
inoremap <silent> <A-End> <C-o>:call GrooVim_SelWord("i", "r", 1)<cr>
inoremap <silent> <A-Home> <C-o>:call GrooVim_SelWord("i", "l", 1)<cr>
nnoremap <silent> <script> <A-Left> :call GrooVim_SelWord("n", "l", 0)<cr>
inoremap <silent> <script> <A-Left> <C-o>:call GrooVim_SelWord("i", "l", 0)<cr>
vnoremap <A-Left> <Cmd>call GrooVim_SelWord("v", "l", 0)<cr>
nnoremap <silent> <script> <A-Right> :call GrooVim_SelWord("n", "r", 0)<cr>
inoremap <silent> <script> <A-Right> <C-o>:call GrooVim_SelWord("i", "r", 0)<cr>
vnoremap <A-Right> <Cmd>call GrooVim_SelWord("v", "r", 0)<cr>

" Note: Allows selection of words quickly (for copying or deletion)! By Questor
func! GrooVim_SelWord(mod, direction, fullMove) range abort

  let l:wordMove = ""
  let l:wordMoveInsert = ""

  if a:direction == "l"
    if a:fullMove == 0
      let l:wordMove = "b"
    elseif a:fullMove == 1
      let l:wordMove = "0"
    endif
    let l:wordMoveInsert = "\<Left>"
  elseif a:direction == "r"
    if a:fullMove == 0
      let l:wordMove = "e"
    elseif a:fullMove == 1
      let l:wordMove = "$\<Left>"
    endif
  endif

  " Note: No "gv" here: the mapping of visual mode comes through "<Cmd>" and the
  " selection was never lost! By Questor
  if a:mod == "v"
    exec "norm " . l:wordMove
  elseif a:mod == "i"
    if virtcol('.') == (virtcol('$') - 1)
      if a:direction == "r"
        exec "norm \<Esc>\<Down>0v" . l:wordMove
      else
        exec "norm \<Esc>v" . l:wordMove
      endif
    else
      exec "norm \<Esc>" . l:wordMoveInsert . "v" . l:wordMove
    endif
  elseif a:mod == "n"
    exec "norm v" . l:wordMove
  endif

endfunc

" Note: Allows go to the "real" end of the line in normal mode. Is an offshoot of "set virtualedit=onemore"! By Questor
nnoremap <silent> <End> $<Right>

nnoremap <silent> <A-DOWN> :call GrooVim_TabToReturn()<cr>
inoremap <silent> <A-DOWN> <C-O>:call GrooVim_TabToReturn()<cr>
vnoremap <silent> <A-DOWN> :<C-U>call GrooVim_TabToReturn()<cr>v

" Note: Return to last tab in use! By Questor
let g:lastTab = 1
autocmd! TabLeave * let g:lastTab = tabpagenr()

func! GrooVim_TabToReturn() abort
  if g:GrooVim_TabToReturnNumber == 0
    exe "tabn " . g:lastTab
  else
    if g:GrooVim_TabToReturnNumber == tabpagenr()
      exe "tabn " . g:lastTab
    else
      exe "tabn " . g:GrooVim_TabToReturnNumber
      " Note: "redraw" ensures the message display! By Questor
      redraw
      echo "Tab to return is ENabled to this tab!"
    endif
  endif
endfunc

" Note: Allows returning to a particular tab "forever"! By Questor
let g:GrooVim_TabToReturnNumber = 0
func! GrooVim_TabToReturnSet() abort
  if g:GrooVim_TabToReturnNumber == 0
    let g:GrooVim_TabToReturnNumber = tabpagenr()
    call GrooVim_GrooVimBarMsg("Tab to return was ENabled to this tab!", 4)
  else
    let g:GrooVim_TabToReturnNumber = 0
    call GrooVim_GrooVimBarMsg("Tab to return was DISabled!", 4)
  endif
endfunc

if g:enable_tcomment_vim
  nnoremap <silent> <A-Up> :exec "norm gcc"<cr>
  inoremap <silent> <A-Up> <C-o>:exec "norm gcc"<cr>
  vnoremap <A-Up> <Cmd>call GrooVim_VisualComment()<cr>
  " Note: Allows comment the current line in a simple and fast way! By Questor
  func! GrooVim_VisualComment() abort

    " Note: One line and many lines are NOT the same command, and the two
    " branches are not about the selection: over a selection inside a single
    " line, the "gc" of visual mode comments what is SELECTED and not the line.
    " Measured, selecting one character of "x = 3": the line came back
    " untouched. The "gcc" of normal mode is the one that takes the whole line.
    "
    " Note: Which end is which comes from "line(\"v\")", the other end of the
    " selection: the marks this used to ask about, "'<" and "'>", are of the
    " selection BEFORE this one while a selection is still up -- they were only
    " right because the ":" of the old mapping had already ended it! By Questor
    if line("v") == line(".")
      exec "norm \<Esc>"
      exec "norm gcc"
    else
      exec "norm gc"
    endif

  endfunc
endif

