" Ctrl-Alt and Shift-Alt with the arrows.
"
" Two things at once, and they contradict each other unless you are careful: the
" cursor travels in a STRAIGHT LINE, always coming back to the column it left;
" and it may sit over an AREA WITH NO TEXT, which is the reason this function
" exists. What holds the second one is "virtualedit=all", on during the move.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

let g:GT_POS = []

func! GT_Sample(t)
  call add(g:GT_POS, {"line": line("."), "col": col("."), "virtcol": virtcol("."),
    \ "end": virtcol("$"), "want": getcurpos()[4], "ve": &virtualedit, "mode": mode()})
endfunc

func! GT_Show(p)
  return "   (line " . a:p.line . " col " . a:p.col . " virtcol " . a:p.virtcol .
    \ " end " . a:p.end . " want " . a:p.want . " ve=" . a:p.ve . ")"
endfunc

func! GT_Conclude(t)
  " the file: lines 5 and 7 have 25 characters, line 6 has 13
  let p = g:GT_POS

  call GT_Ok("start: line 5, column 24", p[0].line == 5 && p[0].col == 24, GT_Show(p[0]))
  call GT_Ok("went down to the short line", p[1].line == 6, GT_Show(p[1]))
  call GT_Ok("  and STAYED over an area with no text", p[1].virtcol == 24 && p[1].virtcol > p[1].end,
    \ GT_Show(p[1]) . "   (this is what virtualedit is for)")
  call GT_Ok("  with virtualedit on", p[1].ve ==# "all", GT_Show(p[1]))
  call GT_Ok("  and it did NOT go to the start of the line", p[1].col > 1, GT_Show(p[1]))
  call GT_Ok("down to the long one: back to 24", p[2].line == 7 && p[2].col == 24, GT_Show(p[2]))
  call GT_Ok("  with virtualedit given back", p[2].ve ==# "onemore", GT_Show(p[2]))
  call GT_Ok("up to the short one again", p[3].line == 6 && p[3].virtcol == 24, GT_Show(p[3]))
  call GT_Ok("up to the long one: back to 24", p[4].line == 5 && p[4].col == 24, GT_Show(p[4]))

  let straight = 1
  for step in p
    if step.want != 24 | let straight = 0 | endif
  endfor
  call GT_Ok("the column to keep never drifted", straight, "   (it used to go 24, 23, 22...)")

  let inInsert = 1
  for step in p
    if step.mode !=# "i" | let inInsert = 0 | endif
  endfor
  call GT_Ok("all of this in insert mode", inInsert, "")
  call GT_Ok("the text was not touched", getline(1, "$") ==# g:GT_TEXT, "")

  " ---- and now Shift-Alt, the long move
  "
  " The block above ends INSIDE insert mode, so the "<Esc>" comes first: without
  " it the "i" that follows would be typed into the file as text.
  let g:GT_POS = []
  call feedkeys("\<Esc>", "t")
  call timer_start(100,  {t -> [cursor(1, 20), feedkeys("i", "t")]})
  call timer_start(200,  "GT_Sample")
  call timer_start(300,  {t -> feedkeys("\<A-S-Down>", "t")})
  call timer_start(1200, "GT_Sample")
  call timer_start(1300, {t -> feedkeys("\<A-S-Up>", "t")})
  call timer_start(2200, "GT_Sample")
  call timer_start(2300, {t -> feedkeys("\<A-S-Down>", "t")})
  call timer_start(3200, "GT_Sample")
  call timer_start(3300, {t -> feedkeys("\<A-S-Up>", "t")})
  call timer_start(4200, "GT_Sample")
  call timer_start(4500, "GT_ConcludeLong")
endfunc

func! GT_ConcludeLong(t)
  let p = g:GT_POS

  call GT_Ok("Shift-Alt: started on column 20", p[0].col == 20, GT_Show(p[0]))
  call GT_Ok("Shift-Alt: went down to the last line", p[1].line == 8, GT_Show(p[1]))
  call GT_Ok("  and sat over an area with no text", p[1].virtcol == 20 && p[1].virtcol > p[1].end,
    \ GT_Show(p[1]))
  call GT_Ok("Shift-Alt: going up, back to column 20", p[2].line == 1 && p[2].col == 20,
    \ GT_Show(p[2]) . "   (this is where it used to drift: 20, 19, 18...)")

  let straight = 1
  for step in p
    if step.virtcol != 20 | let straight = 0 | endif
  endfor
  call GT_Ok("Shift-Alt: four trips with no drift", straight,
    \ "   (columns " . join(map(copy(p), 'v:val.virtcol'), ", ") . ")")
  call GT_Ok("Shift-Alt: the text was not touched", getline(1, "$") ==# g:GT_TEXT, "")

  " ---- and in BLOCK mode, the other "(PRIORITY)" of 2014
  let g:GT_POS = []
  call feedkeys("\<Esc>", "t")
  call timer_start(100,  {t -> [cursor(5, 24), GT_Press("\<F2>b")]})
  call timer_start(300,  "GT_Sample")
  call timer_start(400,  {t -> feedkeys("\<C-A-Down>", "t")})
  call timer_start(700,  "GT_Sample")
  call timer_start(800,  {t -> feedkeys("\<C-A-Down>", "t")})
  call timer_start(1100, "GT_Sample")
  call timer_start(1400, "GT_ConcludeBlock")
endfunc

func! GT_Body()
  exec "edit " . g:GT_FIX . "/irregular.py"
  let g:GT_TEXT = getline(1, "$")
  call cursor(5, 24)
  call feedkeys("i", "t")
  " Real time is needed between the keys: the "<C-o>" steps out of insert and
  " back, and feedkeys(..., "x") would end insert mode halfway.
  call timer_start(200,  "GT_Sample")
  call timer_start(300,  {t -> feedkeys("\<C-A-Down>", "t")})
  call timer_start(600,  "GT_Sample")
  call timer_start(700,  {t -> feedkeys("\<C-A-Down>", "t")})
  call timer_start(1000, "GT_Sample")
  call timer_start(1100, {t -> feedkeys("\<C-A-Up>", "t")})
  call timer_start(1400, "GT_Sample")
  call timer_start(1500, {t -> feedkeys("\<C-A-Up>", "t")})
  call timer_start(1800, "GT_Sample")
  call timer_start(2000, "GT_Conclude")
endfunc

func! GT_ConcludeBlock(t)
  let p = g:GT_POS
  call GT_Ok("block: F2 b entered visual block", p[0].mode ==# "\<C-v>",
    \ "   (mode [" . strtrans(p[0].mode) . "])   (it used to be Ctrl-b, which now walks brackets)")
  call GT_Ok("block: went down to the short line", p[1].line == 6, GT_Show(p[1]))
  call GT_Ok("block: sat over an area with no text", p[1].virtcol == 24 && p[1].virtcol > p[1].end, GT_Show(p[1]))
  call GT_Ok("block: down to the long one, column 24", p[2].line == 7 && p[2].col == 24, GT_Show(p[2]))
  call GT_Ok("block: still in visual block", p[2].mode ==# "\<C-v>", "   (mode [" . strtrans(p[2].mode) . "])")
  call GT_Ok("block: the text was not touched", getline(1, "$") ==# g:GT_TEXT, "")
  call GT_ColourChecks()
  call GT_ViewBody()
endfunc

" ---- the cursor colour, and the flag that used to outlive an interrupt
"
" GroovyMove raises a flag while it travels out of insert mode, so that the
" cursor keeps the colour of insert for the whole trip instead of flashing the
" one of normal mode on the way out. The trip can be INTERRUPTED -- GrooVim says
" "Use Ctrl+C to stop!" while a smooth one runs -- and an interrupt walked out of
" the function before the line that lowers it. The flag stayed up, and everything
" after it was painted green: visual mode included, which is blue.
func! GT_ColourChecks()
  call GT_Ok("the movement gives the colours back in a \"finally\"",
    \ GT_FunctionText("GrooVim_GroovyMove") =~ "finally",
    \ "   (an interrupt walks out of a function; a finally still runs)")
  call GT_Ok("  and that is what lowers the flag",
    \ GT_FunctionText("GrooVim_GroovyMove") =~ 'finally\_.\{-}GroovyMoveColorsBack', "")

  " And the second half: even with the flag standing, a mode that can be SEEN
  " wins. The colour itself cannot be checked -- it is sent to the TERMINAL with
  " "echoraw", and a case cannot read a terminal -- so what is checked is the
  " decision that chooses it.
  call GT_Ok("the flag never wins over a mode that can be seen",
    \ GT_FunctionText("GrooVim_CursorColorForMode")
    \   =~ 'CursorColorHoldInsert == 1 && !l:visual',
    \ "   (with the flag standing and the mode visual, visual wins)")
  call GT_Ok("  and visual is asked about before the flag is",
    \ match(GT_FunctionText("GrooVim_CursorColorForMode"), "l:visual =")
    \ < match(GT_FunctionText("GrooVim_CursorColorForMode"), "CursorColorHoldInsert"), "")
  call GT_Ok("and the movement PAINTS by the mode it ends in",
    \ GT_FunctionText("GrooVim_GroovyMove") =~ "CursorColorSoon",
    \ "   (giving the colours back is not painting: nothing repaints on its own)")
  call GT_Ok("  when the mode has SETTLED, and not on the way",
    \ GT_FunctionText("GrooVim_CursorColorSoon") =~ 'timer_start(0',
    \ "   (traced: from inside the function, \"mode()\" answered \"n\" on a movement that ended in visual)")
  call GT_Ok("the three colours are three different ones",
    \ len(uniq(sort([g:cursorColorNV, g:cursorColorI, g:cursorColorV]))) == 3,
    \ "   (normal [" . g:cursorColorNV . "] insert [" . g:cursorColorI .
    \ "] visual [" . g:cursorColorV . "])")
endfunc


" ---- the window, and the cursor it is supposed to follow
"
" A movement in visual mode goes through the ":" of the mapping, and typing ":"
" in visual mode puts the cursor on the FIRST line of the range (":h v_:"). The
" window goes there with it. The "gv" that puts the selection back then jumps to
" the other end, and a jump of more than a screen makes Vim CENTRE the line it
" lands on -- so the window ends up somewhere the user never asked for, on a
" movement whose cursor never left the screen.
"
" Measured, before the fix: window on 80..120, cursor on 115, the selection
" starting on 40. One Shift-Alt-Up took the cursor to 100 -- a line that was on
" the screen all along -- and left the window on 95..135.
"
" Putting the window back afterwards fixes where it ENDS and not what is
" painted on the way: between the ":" and the "gv" the window really is on
" 20..60, and whatever paints in that instant shows it. The key goes through
" "<Cmd>" now, which never opens a command line, so that position never exists.
"
" The rule these checks hold is the one that was asked for: the window is still
" when the cursor is on it, and follows when the cursor leaves.
let g:GT_VIEWS = {}

func! GT_ViewSample(what)
  let g:GT_VIEWS[a:what] = {"line": line("."), "top": line("w0"),
    \ "bottom": line("w$"), "mode": mode()}
endfunc

func! GT_ViewShow(what)
  let p = g:GT_VIEWS[a:what]
  return "   (window " . p.top . ".." . p.bottom . ", cursor " . p.line . ")"
endfunc

func! GT_ViewBody()
  " The block above ends INSIDE visual block mode, and it stays there now that
  " the movement no longer leaves the mode to finish. Without this the "v" below
  " lands on a selection that is already up and the anchor is not where this
  " block thinks it is.
  call feedkeys("\<Esc>", "x")
  let g:GT_KEPT_LINES = &lines
  " A window tall enough for the cursor to travel 15 lines inside it: a pty with
  " no terminal behind it falls back to 24, and there the movement would leave
  " the screen no matter what the code does.
  set lines=43
  enew!
  call setline(1, map(range(1, 300), '"linha " . v:val'))
  call cursor(40, 1)
  call feedkeys("v", "t")
  call timer_start(100, {t -> [cursor(115, 1), winrestview({"topline": 80}),
    \ GT_ViewSample("in"), feedkeys("\<A-S-Up>", "t")]})
  call GT_When('line(".") == 100', "GT_ViewOut")
endfunc

func! GT_ViewOut()
  call GT_ViewSample("in-end")

  " And now the other half: the same key with the cursor near the top, where it
  " DOES leave the screen and the window has to come along.
  call feedkeys("\<Esc>", "t")
  call timer_start(100, {t -> [cursor(40, 1), feedkeys("v", "t")]})
  call timer_start(250, {t -> [cursor(85, 1), winrestview({"topline": 80}),
    \ GT_ViewSample("out"), feedkeys("\<A-S-Up>", "t")]})
  call GT_When('line(".") == 70', "GT_ViewAgain")
endfunc

" ---- and the same key AGAIN, without leaving the selection
"
" A movement puts itself out of reach while it runs, so that holding the key down
" gives ONE trip and not the ten that would be queued, and it is put back on its
" feet when Vim goes idle with nothing waiting. That used to be reached by
" LEAVING visual mode, which is what made the marking flash. Staying in it and
" changing nothing else left the second press of the key doing nothing at all --
" measured: three presses, and the cursor moved once. "SafeState" is the event
" for that moment, and it fires in visual mode too.
func! GT_ViewAgain()
  call GT_ViewSample("out-end")
  call feedkeys("\<A-S-Up>", "t")
  call GT_When('line(".") == 55', "GT_ViewConclude")
endfunc

func! GT_ViewConclude()
  call GT_ViewSample("out-end2")
  let a = g:GT_VIEWS

  call GT_Ok("setup: the cursor is on the screen, the far end is not",
    \ a["in"].top == 80 && a["in"].line == 115 && a["in"].line <= a["in"].bottom,
    \ GT_ViewShow("in") . "   (the selection starts on 40)")
  call GT_Ok("a movement that stays on the screen does not scroll it",
    \ a["in-end"].top == a["in"].top,
    \ GT_ViewShow("in-end") . "   (it used to come back centred, on 95..135)")
  call GT_Ok("  and the cursor did travel", a["in-end"].line == 100, GT_ViewShow("in-end"))
  call GT_Ok("  and it is still on the screen",
    \ a["in-end"].line >= a["in-end"].top && a["in-end"].line <= a["in-end"].bottom, "")

  call GT_Ok("setup: and now the cursor near the top", a["out"].top == 80 && a["out"].line == 85,
    \ GT_ViewShow("out"))
  call GT_Ok("a movement that leaves the screen DOES scroll it",
    \ a["out-end"].top < a["out"].top, GT_ViewShow("out-end"))
  call GT_Ok("  by the least it can", a["out-end"].top == a["out-end"].line,
    \ GT_ViewShow("out-end") . "   (the cursor on the first line, and not a line further)")
  call GT_Ok("and the key never opens a command line at all",
    \ maparg("<A-S-Up>", "v") =~ "<Cmd>",
    \ "   (a \":\" in visual mode moves the cursor to the first line of the range)")
  call GT_Ok("  so the selection is still up when the function runs",
    \ maparg("<A-S-Up>", "v") !~ "gv" && GT_FunctionText("GrooVim_GroovyMove") !~ 'exec "norm gv"',
    \ "   (\":h map-cmd\": \"Visual mode is preserved, so tricks with gv are not needed\")")

  call GT_Ok("the same key AGAIN moves again, with the selection never dropped",
    \ a["out-end2"].line == 55 && a["out-end2"].mode ==# "v",
    \ "   (line " . a["out-end2"].line . ", mode [" . strtrans(a["out-end2"].mode) .
    \ "])   (it used to need an \"<Esc>\" to be put back on its feet)")

  " ---- and the marking of the selection, which used to flash off and on
  "
  " The movement in visual mode ended with an "<Esc>" so that "CursorHold" --
  " which only happens in normal mode -- would fire and run the adjuster, and a
  " "gv" put the selection back afterwards. Leaving visual mode drops the marking
  " of EVERY selected line: Vim paints the screen without it and the "gv" paints
  " it again. Measured on the screen itself, at the "CursorHold" and before its
  " "gv", the attribute painted on a selected line was 0 -- the attribute of a
  " line OUTSIDE the selection. Counted on what the terminal received, one
  " Shift-Alt-Down painted a selected line four times; it paints it once now.
  "
  " The code and not the screen, because a case cannot watch a repaint: what is
  " checked is that the movement no longer leaves the mode, and that nothing is
  " left behind for "CursorHold" to do.
  call GT_Ok("the movement never leaves visual mode to finish",
    \ GT_FunctionText("GrooVim_GroovyMove") !~ 'exec "norm .\\\\<Esc>"',
    \ "   (leaving it drops the marking of every selected line)")
  call GT_Ok("  and nothing is left for CursorHold to run",
    \ !exists("g:cursorHoldVisual") && !exists("g:cursorHoldVisualExec"),
    \ "   (the adjuster is called straight from the movement, in visual mode)")

  " ---- and the wheel of the mouse, which travels the same road
  "
  " It does not scroll: it moves the cursor three lines and lets the window
  " follow. Through the ":<C-u>" it used to come in on, one notch UP moved the
  " cursor three lines up and the window fifteen lines DOWN -- measured, 80..120
  " became 95..135.
  call feedkeys("\<Esc>", "x")
  call cursor(40, 1)
  call feedkeys("v", "x")
  call cursor(115, 1)
  call winrestview({"topline": 80})
  let l:top = line("w0")
  call feedkeys("\<ScrollWheelUp>", "x")
  call GT_Ok("the wheel of visual mode does not throw the window either",
    \ line("w0") == l:top,
    \ "   (window " . line("w0") . ".." . line("w$") . ", and it was " . l:top . "..)")
  call GT_Ok("  and it did move the cursor", line(".") == 112,
    \ "   (line " . line(".") . ", three above the 115 it was on)")
  call GT_Ok("  with the selection still up", mode() ==# "v",
    \ "   (mode [" . strtrans(mode()) . "])")

  " ---- and what the mapping of a selection must NOT ask about
  "
  " With the key coming through "<Cmd>" the selection is still up, and while it
  " is up the marks "'<" and "'>" are of the PREVIOUS one. The other end of the
  " selection you are in is "line(\"v\")". Commenting told one line from many by
  " those marks, and it was only right because the ":" of the old mapping had
  " already ended the selection.
  "
  " The two branches are not decoration: measured, over a selection inside a
  " single line the "gc" of visual mode comments what is SELECTED and leaves the
  " line as it was. tcomment is not installed for the battery, so what is checked
  " here is the decision -- the commenting itself was measured by hand, on this
  " machine, with the plugin really there.
  if exists("*GrooVim_VisualComment")
    let l:text = GT_FunctionText("GrooVim_VisualComment")
    " The code and not a mention of it: the note above these lines names both
    " "gcc" and "'<", and a check that reads the body of a function reads its
    " comments too -- it passed over a function with the branches taken out.
    call GT_Ok("commenting asks the selection it is IN which end is which",
      \ l:text =~ 'line("v") == line(".")' && l:text !~ "getpos(\"'<\")",
      \ "   (while a selection is up, \"'<\" is of the one before it)")
    call GT_Ok("  and one line is still not the same as many",
      \ l:text =~ 'exec "norm gcc"' && l:text =~ "else",
      \ "   (over one line, the \"gc\" of visual mode comments the SELECTION)")
  else
    call GT_Note("tcomment is not here, so its checks did not run")
  endif

  " ---- a page is the window, and the window is the terminal
  "
  " It was fifteen lines, written down: the same key jumped past the screen on a
  " small terminal and left a third of it unread on a big one, and making the
  " window bigger changed nothing. What decides how much a page is, is the page.
  enew!
  call setline(1, map(range(1, 300), '"linha " . v:val'))
  for s:high in [24, 40]
    let &lines = s:high
    call cursor(1, 1)
    let s:page = winheight(0) - 2
    call GT_Press("\<PageDown>")
    call GT_Ok("on a terminal of " . s:high . " lines, a page is " . s:page,
      \ line(".") == 1 + s:page,
      \ "   (window " . winheight(0) . " lines, cursor 1 -> " . line(".") . ")")
    let s:was = line(".")
    call GT_Press("\<PageUp>")
    call GT_Ok("  and back up is the same page",
      \ line(".") == s:was - s:page, "   (" . s:was . " -> " . line(".") . ")")
  endfor

  " ---- and the FIRST press turns the page, not the second
  "
  " From the top line, a page down is still on the screen: the cursor walked to
  " the bottom of it and the text stayed where it was, so it took a second press
  " to start scrolling. A page key turns the window in every editor there is.
  call cursor(1, 1)
  call GT_Ok("setup: at the top of the file and of the screen",
    \ line("w0") == 1 && winline() == 1, "")
  call GT_Press("\<PageDown>")
  call GT_Ok("one press and the window has turned",
    \ line("w0") == 1 + s:page, "   (top line 1 -> " . line("w0") . ")")
  call GT_Ok("  with the cursor on the row of the screen it left",
    \ winline() == 1, "   (row " . winline() . ")")

  " From the middle of the screen, the row is kept just the same.
  call cursor(1, 1)
  normal! zt
  call cursor(10, 1)
  let s:row = winline()
  call GT_Press("\<PageDown>")
  call GT_Ok("from the middle of the screen, the row is kept",
    \ winline() == s:row, "   (row " . s:row . " -> " . winline() . ")")
  call GT_Ok("  and the window moved by what the CURSOR moved",
    \ line("w0") == 1 + s:page, "   (top line " . line("w0") . ")")

  " At the end of the file the cursor stops early, and the window stops with it.
  call cursor(line("$") - 5, 1)
  normal! zz
  let s:top = line("w0")
  let s:row = winline()
  call GT_Press("\<PageDown>")
  call GT_Ok("at the end of the file the cursor stops on the last line",
    \ line(".") == line("$"), "   (line " . line(".") . " of " . line("$") . ")")
  call GT_Ok("  and the window stopped with it, by the same five lines",
    \ line("w0") == s:top + 5 && winline() == s:row,
    \ "   (top " . s:top . " -> " . line("w0") . ", row " . winline() . ")")

  " And a movement that is not a page leaves the window where it is, which is
  " what the smooth one was made to do.
  call cursor(1, 1)
  normal! zt
  call GT_Press("\<C-A-Down>")
  call GT_Ok("a single step does not drag the screen about",
    \ line("w0") == 1, "   (top line " . line("w0") . ")")
  call GT_Ok("and it is read at the moment the key is pressed",
    \ GT_FunctionText("GrooVim_GroovyMove") =~ "winheight(0)",
    \ "   (not written down, and not read once at startup)")
  call GT_Ok("  two lines short of the whole window",
    \ GT_FunctionText("GrooVim_GroovyMove") =~ "winheight(0) - 2",
    \ "   (the lines that were at the bottom are at the top when you arrive)")

  " ---- moving lines, one or many
  "
  " The plugin that moves them asks TWO things: which modifier moves a LINE and,
  " separately, which one moves a SELECTION. Only the first was ever given, so a
  " selection went on waiting for "Alt+j" and "Alt+k", which nobody here
  " presses. Measured: with two lines selected, Ctrl+J and Ctrl+K left the file
  " exactly as it was, while the same keys moved a single line.
  if exists("g:enable_move_vim") && g:enable_move_vim
    call GT_Ok("the same key moves a line and moves a selection",
      \ g:move_key_modifier ==# g:move_key_modifier_visualmode,
      \ "   (line [" . g:move_key_modifier . "] selection [" .
      \ g:move_key_modifier_visualmode . "])   (the number of lines is not\n" .
      \ "    the user's problem: it is one idea)")
    call GT_Ok("  and the list promises exactly that",
      \ !empty(filter(copy(g:GrooVim_Shortcuts),
      \   'get(v:val, "keys", "") ==# "<C-k>" && v:val.what =~ "selection"')),
      \ "   (\"Moves the line, or the selection, up\")")

    " The keys themselves are pressed through a real terminal, where the plugin
    " really is: here its directory is empty, which is enough for the settings
    " to be written and not for a key to do anything. Measured there, with two
    " lines selected: Ctrl+J left ["um", "quatro", "dois", "tres", "cinco"], and
    " three lines with Ctrl+K twice walked to the top of the file.
    call GT_Ok("  and pressing them is measured where the plugin really is",
      \ maparg("<C-j>", "x") ==# "" || maparg("<C-j>", "x") =~ "MoveBlock",
      \ "   [" . maparg("<C-j>", "x") . "]")
  else
    call GT_Note("vim-move is not here, so its checks did not run")
  endif

  let &lines = g:GT_KEPT_LINES
  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
