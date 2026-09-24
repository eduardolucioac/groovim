" Writing in several places at once: the multiple carets of Notepad++.
"
" Two keys and one machinery. F2->n takes whole LINES, which is the
" "Shift+Alt+arrows" of Notepad++: the line you start on is the anchor, the
" arrows move the other end, and the carets are the lines between the two.
" F2->m takes one place at a time, which is its "Ctrl+click": mark as many as
" you like, walk between them however you walk, and then type.
"
" What Vim has instead is the visual BLOCK, and it is not this: you cannot type
" into it -- an "I" or an "A" is asked for first, and the other lines only
" change when you press "Esc". Measured, entering the block and typing "XYZ":
" the "X" ran as the "x" of Vim and took a character off each line.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

" The carets are written by a timer, which runs when Vim is waiting -- so a case
" that types and looks at once looks too early.
func! GT_Settle()
  sleep 60m
endfunc

" A whole session in ONE press, because insert mode does not survive between
" two: a fed key runs and returns, insert ends with it, and ending insert is
" what puts the carets down. With the keys in one run -- the F key, its letter,
" the arrows, the text and the "Esc" -- it is the same journey a hand makes.
"
" What cannot be looked at from inside such a run is what the carets were in the
" MIDDLE of it; that is asked of the functions themselves, further down.

" A buffer with these lines in it and NOTHING to undo: the lines being put there
" is a change like any other, and an undo that walks past the text under test
" empties the buffer and every check after it reads "".
func! GT_Fresh(lines)
  enew!
  call setline(1, a:lines)
  let l:levels = &undolevels
  set undolevels=-1
  exec "normal! a \<BS>\<Esc>"
  let &undolevels = l:levels
  call cursor(1, 1)
endfunc

func! GT_Body()

  " ---- the two keys are on the list, in the section about changing text
  for s:pair in [["n", "several lines"], ["m", "several places"]]
    let s:one = filter(copy(g:GrooVim_Shortcuts),
      \ 'get(v:val, "group", "") ==# "F2" && get(v:val, "key", "") ==# "' . s:pair[0] . '"')
    call GT_Ok("F2->" . s:pair[0] . " writes in " . s:pair[1],
      \ len(s:one) == 1 && s:one[0].where ==# "Edit" &&
      \ s:one[0].menu =~ s:pair[1], "   " . string(map(copy(s:one), 'v:val.menu')))
  endfor
  call GT_Ok("and the column asks for insert itself",
    \ GT_FunctionText("GrooVim_MultiColumnStart") =~ "startinsert",
    \ "   (in Notepad++ you hold the keys and type: there is no \"i\" to press,\n" .
    \ "    and asking for one would be the block of Vim again. Measured with a\n" .
    \ "    real F2 through a real terminal: the mode went to insert by itself)")

  " ---- a column of lines, typed in one go
  call GT_Fresh(["um alfa fim", "dois beta fim", "tres gama fim",
    \ "quatro delta fim", "zz"])
  call GT_Press("\<F2>n\<Down>\<Down>>>\<Esc>")
  call GT_Ok("what you type goes to every line the arrows took in",
    \ getline(1) ==# ">>um alfa fim" && getline(2) ==# ">>dois beta fim" &&
    \ getline(3) ==# ">>tres gama fim" && getline(4) ==# "quatro delta fim",
    \ "   " . string(getline(1, 4)))
  call GT_Ok("  and a single undo takes back every one of them",
    \ GT_Undo() ==# "um alfa fim" && getline(3) ==# "tres gama fim",
    \ "   " . string(getline(1, 3)) .
    \ "   (one change: the other lines were written inside the same insert)")

  " ---- the text and the "Esc" arriving together lose nothing
  call cursor(1, 1)
  call GT_Press("\<F2>n\<Down>RAPIDO\<Esc>")
  call GT_Ok("text and Esc in one burst lose nothing",
    \ getline(1) ==# "RAPIDOum alfa fim" && getline(2) ==# "RAPIDOdois beta fim",
    \ "   " . string(getline(1, 2)) .
    \ "   (the queue is emptied by a timer, and a timer runs when Vim waits:\n" .
    \ "    an Esc pressed at once arrives BEFORE the wait does)")
  call GT_Ok("  and what does it is written where the end is",
    \ GT_FunctionText("GrooVim_MultiEnd") =~ "MultiFlush", "")
  call GT_Undo()

  " ---- the backspace takes one off every line
  call cursor(1, 1)
  call GT_Press("\<F2>n\<Down>XY\<BS>Z\<Esc>")
  call GT_Ok("the backspace takes one off every line as well",
    \ getline(1) ==# "XZum alfa fim" && getline(2) ==# "XZdois beta fim",
    \ "   " . string(getline(1, 2)) .
    \ "   (nothing types it, so \"InsertCharPre\" never hears it: it has a\n" .
    \ "    mapping of its own)")
  call GT_Undo()

  " ---- the keys that are not characters act in every caret too
  "
  " "InsertCharPre" hears the letters and nothing else: measured, typing a Tab,
  " an Enter and a Del with the event watching, and only the letter after them
  " was heard. They have to be told one by one, or they do their work in the one
  " place the real cursor is and nowhere else -- which is what they did.
  call GT_Fresh(["aaaa bbbb", "cccc dddd", "eeee ffff"])
  call cursor(1, 6)
  call GT_Press("\<F2>n\<Down>\<Down>\<Del>\<Esc>")
  call GT_Ok("Del takes a character off every caret",
    \ getline(1) ==# "aaaa bbb" && getline(2) ==# "cccc ddd" &&
    \ getline(3) ==# "eeee fff", "   " . string(getline(1, 3)))
  call GT_Undo()

  call cursor(1, 6)
  call GT_Press("\<F2>n\<Down>\<Down>\<Tab>\<Esc>")
  call GT_Ok("Tab fills to the next stop of each caret's OWN column",
    \ getline(1) ==# "aaaa  bbbb" && getline(3) ==# "eeee  ffff",
    \ "   " . string(getline(1, 3)))
  call GT_Undo()

  call cursor(1, 6)
  call GT_Press("\<F2>n\<Down>\<Down>\<CR>\<Esc>")
  call GT_Ok("Enter cuts every caret's own line",
    \ getline(1, 6) == ["aaaa ", "bbbb", "cccc ", "dddd", "eeee ", "ffff"],
    \ "   " . string(getline(1, 6)) .
    \ "   (and the carets below a cut go down with it, or the next key lands\n" .
    \ "    a line short)")
  call GT_Undo()

  " ---- and at the ends of a line those two keys JOIN lines
  "
  " A backspace in the first column and a Del at the end do not take a character
  " away: they take the line break away. That moves every line below, and every
  " caret with them -- including the one the cursor is standing on, which is
  " skipped everywhere else because Vim does its work: there Vim does the work
  " on the TEXT and not on the caret. Measured before it was: typing after a
  " backspace in the first column put a third letter on a line with no caret.
  call GT_Fresh(["aaa", "bbb", "ccc", "ddd", "eee"])
  call cursor(2, 1)
  call GT_Press("\<F2>n\<Down>\<Down>\<BS>\<Esc>")
  call GT_Ok("a backspace in the first column joins with the line above",
    \ getline(1, 3) == ["aaabbbcccddd", "eee", ""] ||
    \ getline(1, 2) == ["aaabbbcccddd", "eee"],
    \ "   " . string(getline(1, 3)))
  call GT_Undo()

  call cursor(1, 3)
  call GT_Press("\<F2>n\<Down>\<End>\<Del>Z\<Esc>")
  call GT_Ok("a Del at the end joins with the line below, and what is typed\n" .
    \ "   lands where the carets really are",
    \ getline(1) ==# "aaaZbbbZccc" && getline(2) ==# "ddd",
    \ "   " . string(getline(1, 3)) .
    \ "   (two joins, and a Z at each of the two seams)")
  call GT_Undo()

  call GT_Fresh(["aaa", "bbb", "ccc"])
  call cursor(1, 1)
  call GT_Press("\<F2>n\<Down>\<BS>Z\<Esc>")
  call GT_Ok("in the first line of all there is nothing to join",
    \ getline(1) ==# "ZaaaZbbb" && getline(2) ==# "ccc",
    \ "   " . string(getline(1, 2)) .
    \ "   (the caret below joined; the one at the top only wrote)")
  call GT_Undo()

  " ---- an Enter and a backspace leave the file exactly as it was
  "
  " The two are each other's opposite, so pressing them in turn has to come back
  " to the same text -- and it is the hardest thing in here to get right,
  " because both move LINES and every caret is a line number. Measured wrong
  " twice: once the caret the cursor stands on stayed where it was and the
  " backspace joined the wrong two lines; once the real cursor was left a line
  " short, because a caret ABOVE it had cut a line and nobody told it.
  call GT_Fresh(["aaa bbb", "ccc ddd", "eee fff"])
  call cursor(1, 5)
  call GT_Press("\<F2>n\<Down>\<Down>\<CR>\<BS>\<CR>\<BS>\<CR>\<BS>\<Esc>")
  call GT_Ok("three Enters and three backspaces leave the file as it was",
    \ getline(1, 3) == ["aaa bbb", "ccc ddd", "eee fff"] && line("$") == 3,
    \ "   " . string(getline(1, "$")))

  call GT_Fresh(["aaa bbb", "ccc ddd", "eee fff"])
  call cursor(1, 5)
  call GT_Press("\<F2>m\<Down>\<Down>\<F2>m\<Esc>\<CR>\<BS>\<CR>\<BS>\<Esc>")
  call GT_Ok("  and the same in places that have nothing to do with each other",
    \ getline(1, 3) == ["aaa bbb", "ccc ddd", "eee fff"] && line("$") == 3,
    \ "   " . string(getline(1, "$")))

  " ---- a line too short takes the text at its own end
  call GT_Fresh(["um alfa fim", "dois beta fim", "tres gama fim",
    \ "quatro delta fim", "zz"])
  call cursor(4, 8)
  call GT_Press("\<F2>n\<Down><>\<Esc>")
  call GT_Ok("a line too short to reach the column takes it at ITS end",
    \ getline(4) ==# "quatro <>delta fim" && getline(5) ==# "zz<>",
    \ "   " . string(getline(4, 5)) . "   (no line is left out)")
  call GT_Undo()

  " ---- the anchor stays where it started, and the arrows move the other end
  "
  " Asked of the functions, because this is the MIDDLE of a run of typing and a
  " fed key cannot be stopped there.
  call GT_Fresh(["um alfa fim", "dois beta fim", "tres gama fim",
    \ "quatro delta fim", "zz"])
  call cursor(2, 1)
  call GrooVim_MultiColumnStart()
  call GT_Ok("the anchor is the line you started on",
    \ GrooVim_MultiState().anchor[0] == 2 && empty(g:GrooVim_MultiPoints),
    \ "   " . string(GrooVim_MultiState().anchor) .
    \ "   (and no caret yet: only the cursor)")
  call GrooVim_MultiFar(1)
  call GrooVim_MultiFar(1)
  call GT_Ok("  two down takes in the two lines below",
    \ map(copy(g:GrooVim_MultiPoints), 'v:val[0]') == [3, 4],
    \ "   " . string(g:GrooVim_MultiPoints))
  call GrooVim_MultiFar(-1)
  call GT_Ok("  and one up gives one back",
    \ map(copy(g:GrooVim_MultiPoints), 'v:val[0]') == [3],
    \ "   " . string(g:GrooVim_MultiPoints) .
    \ "   (the anchor does not move: the other end does)")
  call GrooVim_MultiFar(-1)
  call GrooVim_MultiFar(-1)
  call GT_Ok("  and past the anchor it takes the line ABOVE",
    \ map(copy(g:GrooVim_MultiPoints), 'v:val[0]') == [1],
    \ "   " . string(g:GrooVim_MultiPoints) .
    \ "   (one key grows it and shrinks it, which is how Notepad++ behaves)")
  call GT_Ok("  and the carets are painted on the character they sit on",
    \ !empty(filter(getmatches(), 'v:val.group ==# "GrooVimMultiCaret"')),
    \ "   (a terminal has ONE cursor: the others are a colour)")
  " ---- and the keys are GIVEN BACK, not thrown away
  call GT_Ok("  the word keys of GrooVim are taken while it is up",
    \ maparg("<C-Right>", "i") =~ "MultiMove" && maparg("<C-Left>", "i") =~ "MultiMove",
    \ "   [" . maparg("<C-Right>", "i") . "]")
  call GrooVim_MultiClear()
  call GT_Ok("  and given back exactly as they were",
    \ maparg("<C-Right>", "i") =~ "C-O" && maparg("<C-Left>", "i") =~ "C-O",
    \ "   [" . maparg("<C-Right>", "i") . "]" .
    \ "   (an \"iunmap\" would not restore them: it would DELETE them, and\n" .
    \ "    the word keys would be gone for the rest of the session)")
  " The column above asked for insert and nothing typed it away: a "startinsert"
  " waits for its moment, and its moment would be the very next key -- which is
  " the F2 below, landing in insert mode, where "F2->m" does not live.
  stopinsert
  call GT_Ok("  and taken off when it ends",
    \ empty(filter(getmatches(), 'v:val.group ==# "GrooVimMultiCaret"')) &&
    \ maparg("<Down>", "i") ==# "" && maparg("<Esc>", "n") ==# "",
    \ "   (the arrows are the arrows of everybody again)")

  " ---- every caret moves, each one from where IT is
  "
  " This is the whole point of carets instead of a column: "End" is the end of
  " each line and not a column number, and "word right" is each line's own next
  " word. The motion is run AT each caret, which is how vim-visual-multi does it
  " too: put the cursor there, run it, see where it landed.
  call GT_Fresh(["um alfa fim", "linha bem mais comprida", "zz"])
  call GT_Press("\<F2>n\<Down>\<Down>\<End>;\<Esc>")
  call GT_Ok("End takes every caret to the end of ITS line",
    \ getline(1) ==# "um alfa fim;" && getline(2) ==# "linha bem mais comprida;" &&
    \ getline(3) ==# "zz;", "   " . string(getline(1, 3)) .
    \ "   (three lines of three lengths, and a \";\" on each)")
  call GT_Undo()

  call GT_Fresh(["aa bbbbbbbb cc fim", "x yy zzzzzzzzzzz fim", "abcdefg h i fim"])
  call GT_Press("\<F2>n\<Down>\<Down>\<C-Right>\<C-Right>[x]\<Esc>")
  call GT_Ok("two words forward is each line's OWN two words",
    \ getline(1) ==# "aa bbbbbbbb[x] cc fim" &&
    \ getline(2) ==# "x yy zzzzzzzzzzz[x] fim" &&
    \ getline(3) ==# "abcdefg h[x] i fim", "   " . string(getline(1, 3)))
  call GT_Undo()

  call GT_Press("\<F2>n\<Down>\<Down>\<Home>>\<Right>\<Right>|\<Esc>")
  call GT_Ok("Home and the plain arrows move every caret too",
    \ getline(1) ==# ">aa| bbbbbbbb cc fim" && getline(3) ==# ">ab|cdefg h i fim",
    \ "   " . string(getline(1, 3)))
  call GT_Undo()

  " ---- places that have nothing to do with each other
  "
  " This one opens for writing as well, and that is what the arrows are FOR
  " here: in the column they grow the block, and here they are how you get to
  " the next place. So the whole session is one run of keys -- mark, walk, mark,
  " type, end -- with no normal mode in the middle of it.
  call GT_Fresh(["um alfa fim", "dois beta fim", "tres gama fim"])
  call GT_Press("\<F2>m\<Esc>AQUI-\<Esc>")
  call GT_Ok("F2 m marks a place and opens for writing at once",
    \ getline(1) ==# "AQUI-um alfa fim", "   " . string(getline(1, 3)) .
    \ "   (in Notepad++ you click and type: there is no \"i\" in between)")
  call GT_Ok("  and it says so where the key is written",
    \ GT_FunctionText("GrooVim_MultiPoint") =~ "startinsert", "")
  call GT_Undo()

  call GT_Press("\<F2>m\<Down>\<Down>\<F2>m\<Esc>MAIS-\<Esc>")
  call GT_Ok("marked, walked and marked again: both places take the text",
    \ getline(1) ==# "MAIS-um alfa fim" && getline(3) ==# "MAIS-tres gama fim" &&
    \ getline(2) ==# "dois beta fim", "   " . string(getline(1, 3)))
  call GT_Ok("  and the F key in the middle did not end it",
    \ getline(1) =~ "MAIS-",
    \ "   (it arrives through a \"<C-o>\", which fires \"InsertLeave\" on its\n" .
    \ "    way -- and twenty six keys of GrooVim are written that way)")
  call GT_Ok("  which is why the end is asked for AFTERWARDS",
    \ GT_FunctionText("GrooVim_MultiEndedReally") =~ "mode(1)",
    \ "   (and with the LONG mode: inside a \"<C-o>\" the short one says \"n\")")
  call GT_Undo()

  " ---- walking to the next place does not drag the carets
  "
  " Here the plain arrows are not the block and not a movement of everybody:
  " they are how you get to the next place. Arrows that dragged the carets
  " already marked would take the chosen places away while you looked for the
  " next one -- and the column of the walk is carried by hand, because coming
  " into insert this way leaves Vim's own at one: measured, marking at line 1
  " column 4 and pressing Down landed on line 2 column 1.
  call GT_Fresh(["aaaa bbbb", "zz", "cccc dddd"])
  call cursor(1, 7)
  call GT_Press("\<F2>m\<Down>\<Down>\<F2>m\<Esc>#\<Esc>")
  call GT_Ok("the walk keeps its column, even over a short line",
    \ getline(1) ==# "aaaa b#bbb" && getline(3) ==# "cccc d#ddd" &&
    \ getline(2) ==# "zz", "   " . string(getline(1, 3)))
  call GT_Undo()

  " ---- but the keys with a modifier move every caret, here too
  call GT_Fresh(["aa bbbb cc", "dd e ffff", "gg hhhhhh ii"])
  call GT_Press("\<F2>m\<Down>\<Down>\<F2>m\<Esc>\<C-Right><\<End>>\<Esc>")
  call GT_Ok("Ctrl+Right and End move every place, each at its own",
    \ getline(1) ==# "aa< bbbb cc>" && getline(3) ==# "gg< hhhhhh ii>" &&
    \ getline(2) ==# "dd e ffff", "   " . string(getline(1, 3)))
  call GT_Undo()

  " ---- nothing is written while the places are being chosen
  "
  " Writing with one caret in a run that is about to have five is writing in one
  " place and meaning five: the column of every place still to be chosen would
  " already be wrong.
  call GT_Fresh(["aaaa bbbb", "cccc dddd"])
  call GT_Press("\<F2>mNAO\<Esc>SIM\<Esc>")
  call GT_Ok("what is typed while choosing is swallowed",
    \ getline(1) ==# "SIMaaaa bbbb",
    \ "   " . string(getline(1, 2)) .
    \ "   (\"NAO\" was typed before the Esc and \"SIM\" after it)")
  call GT_Undo()

  " ---- and the carets say which moment it is, by colour
  "
  " The typeahead is emptied first: an "Esc" left over from the block above
  " arrives AFTER the next function is called, and this one is asking what the
  " state is between one key and the next -- with an Esc still travelling, the
  " places were already sealed before the question.
  call feedkeys("", "x")
  call GrooVim_MultiClear()
  stopinsert
  call GT_Fresh(["aaaa bbbb", "cccc dddd"])
  call GrooVim_MultiPoint()
  call GT_Ok("while choosing, the carets are green",
    \ !empty(filter(getmatches(), 'v:val.group ==# "GrooVimMultiChoosing"')),
    \ "   " . string(map(getmatches(), 'v:val.group')))
  call GrooVim_MultiSeal()
  call GT_Ok("  and the cursor of the terminal wears that colour too",
    \ GT_FunctionText("GrooVim_MultiCursorColour") =~ "cursorColorI",
    \ "   (what is drawn on the last place marked is not a caret at all: it is\n" .
    \ "    the cursor of the terminal, and it has to be one of them to look\n" .
    \ "    like one. Measured through a real terminal, the colours it was sent:\n" .
    \ "    orange while choosing, \"#f6d32d\" on the Esc that sets the places,\n" .
    \ "    and green again when it ended)")
  call GT_Ok("  and it is the orange of the cursor that starts it",
    \ synIDattr(synIDtrans(hlID("GrooVimMultiChoosing")), "bg", "gui") ==# "#ff8700",
    \ "   (" . synIDattr(synIDtrans(hlID("GrooVimMultiChoosing")), "bg", "gui") . ")")
  call GT_Ok("  and once they are set, yellow",
    \ !empty(filter(getmatches(), 'v:val.group ==# "GrooVimMultiCaret"')) &&
    \ empty(filter(getmatches(), 'v:val.group ==# "GrooVimMultiChoosing"')),
    \ "   " . string(map(getmatches(), 'v:val.group')) .
    \ "   (the answer to \"can I write now?\", given without a word)")
  call GT_Ok("  and the cursor of the terminal turns with them",
    \ GrooVim_MultiCursorColour() ==# g:GrooVim_MultiCursorSet,
    \ "   [" . GrooVim_MultiCursorColour() . "]")
  call GrooVim_MultiClear()
  stopinsert

  " ---- the first Esc SETS the places; the second one ends
  "
  " Choosing where the carets go and moving them are two moments, and the key
  " between them is the same word said twice: done choosing, then done writing.
  " While you choose, the plain arrows are your walk; once the places are set,
  " they move every caret.
  call GT_Fresh(["aa bb cc dd", "ee ff gg hh", "ii jj kk ll", "mm nn oo pp"])
  call cursor(1, 4)
  call GT_Press("\<F2>m\<Down>\<Down>\<F2>m\<Esc>\<Down>X\<Esc>")
  call GT_Ok("after the first Esc the arrows move EVERY caret",
    \ getline(2) ==# "ee Xff gg hh" && getline(4) ==# "mm Xnn oo pp" &&
    \ getline(1) ==# "aa bb cc dd" && getline(3) ==# "ii jj kk ll",
    \ "   " . string(getline(1, 4)) .
    \ "   (both places walked one line down, and both took the X)")
  call GT_Ok("  and after they are set, Esc is Vim's own again",
    \ maparg("<Esc>", "i") ==# "",
    \ "   (which is what makes the second one end it: it leaves insert, and\n" .
    \ "    leaving insert is what puts the carets down. Measured through a real\n" .
    \ "    terminal: after the second Esc, what was typed went to the cursor\n" .
    \ "    and nowhere else)")
  call GrooVim_MultiClear()
  call GT_Undo()

  " ---- and once they are set, they are the places
  call GT_Fresh(["aa bb", "cc dd"])
  let g:GrooVim_GrooVimBarMsgValue = ""
  call GT_Press("\<F2>m\<Esc>\<F2>m")
  call GT_Ok("marking again after they are set says so instead",
    \ len(g:GrooVim_MultiPoints) == 1 &&
    \ g:GrooVim_GrooVimBarMsgValue =~ "places are set",
    \ "   [" . g:GrooVim_GrooVimBarMsgValue . "]")
  call GT_Press("\<Esc>")

  " ---- two carets on one line
  call GT_Fresh(["aaa bbb ccc", "segunda linha"])
  call GT_Press("\<F2>m" . repeat("\<Right>", 8) . "\<F2>m\<Esc>#\<Esc>")
  call GT_Ok("two carets on one line both take it",
    \ getline(1) ==# "#aaa bbb #ccc", "   [" . getline(1) . "]" .
    \ "   (writing in the first moves the second, or it falls one behind for\n" .
    \ "    every letter)")

  " ---- and Esc with nothing typed lets go of the places
  call GT_Fresh(["um", "dois", "tres"])
  call GT_Press("\<F2>m")
  call cursor(2, 1)
  call GT_Press("\<F2>m")
  call GT_Press("\<Esc>")
  call GT_Ok("Esc in normal mode lets the places go",
    \ empty(g:GrooVim_MultiPoints) && maparg("<Esc>", "n") ==# "",
    \ "   " . string(g:GrooVim_MultiPoints))
  call cursor(3, 1)
  call GT_Press("iSO-AQUI\<Esc>")
  call GT_Ok("  and what you type next goes where you are, and nowhere else",
    \ getline(1) ==# "um" && getline(2) ==# "dois" && getline(3) ==# "SO-AQUItres",
    \ "   " . string(getline(1, 3)))

  " ---- a buffer that refuses to change says so, and marks nothing
  call GT_Fresh(["nao me mude"])
  setlocal nomodifiable
  let g:GrooVim_GrooVimBarMsgValue = ""
  call GT_Press("\<F2>m")
  call GT_Ok("a buffer that cannot change says so instead of marking",
    \ empty(g:GrooVim_MultiPoints) && g:GrooVim_GrooVimBarMsgValue !=# "",
    \ "   [" . g:GrooVim_GrooVimBarMsgValue . "]")
  setlocal modifiable

  call GT_Done()
endfunc

" The undo, and the first line read back: it is done after every block above.
func! GT_Undo()
  silent! undo
  return getline(1)
endfunc

call GT_AfterStartup("GT_Body")
