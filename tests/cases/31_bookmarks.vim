" Marked lines: the sign in the margin, the note, the walk and the list.
"
" This was a plugin until it was not. What it does is the "Search -> Bookmark" of
" Notepad++, and what made it come inside is the sign API: that plugin places its
" signs the old way, with "file=" and no GROUP, and the signs of a file went down
" every time another window took the focus -- measured with ":sign place", every
" mark gone while the list had it and every one back on returning. A group is per
" buffer and belongs to whoever named it.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

let g:GT_FILE = "/tmp/GrooVim_bookmarks_case.sh"
let g:GT_GROUP = "GrooVim_Bookmarks"

func! GT_Signs()
  let l:placed = sign_getplaced(bufnr(g:GT_FILE), {"group": g:GT_GROUP})
  return empty(l:placed) ? [] : sort(map(copy(l:placed[0].signs), 'v:val.lnum'), "n")
endfunc

func! GT_Lines()
  return sort(map(copy(get(g:GrooVim_Bookmarks, g:GT_FILE, [])), 'v:val.line'), "n")
endfunc

func! GT_Body()
  call writefile(["um", "dois", "tres", "quatro", "cinco", "seis"], g:GT_FILE)
  let g:GrooVim_Bookmarks = {}
  exec "edit! " . g:GT_FILE

  " ---- marking
  call cursor(2, 1)
  call GT_Press("\<F4>b")
  call cursor(5, 1)
  call GT_Press("\<F4>b")
  call GT_Ok("F4 b marks the line", GT_Lines() ==# [2, 5], "   " . string(GT_Lines()))
  call GT_Ok("  and a sign is drawn on each", GT_Signs() ==# [2, 5], "   " . string(GT_Signs()))
  call GT_Ok("  in a group of our own, so nobody else's signs are touched",
    \ GT_FunctionText("GrooVim_BookmarksPlace") =~ "s:group", "")

  call cursor(2, 1)
  call GT_Press("\<F4>b")
  call GT_Ok("and pressing it again takes the mark off", GT_Lines() ==# [5],
    \ "   " . string(GT_Lines()))
  call GT_Ok("  with its sign", GT_Signs() ==# [5], "   " . string(GT_Signs()))

  " ---- the sign is the truth about WHERE
  "
  " Insert a line above a mark and Vim moves the sign with the text; the number
  " written down does not move by itself. Everything that reads the marks asks
  " the signs first.
  call cursor(1, 1)
  call append(0, "uma linha nova no topo")
  call GrooVim_BookmarksRefresh(g:GT_FILE)
  call GT_Ok("a line put in above moves the mark with the text", GT_Lines() ==# [6],
    \ "   " . string(GT_Lines()) . "   (it was on 5)")
  undo

  " ---- walking
  call cursor(1, 1)
  call GrooVim_BookmarksRefresh(g:GT_FILE)
  call cursor(2, 1)
  call GT_Press("\<F4>b")
  call GT_Ok("setup: two marks again", GT_Lines() ==# [2, 5], "   " . string(GT_Lines()))

  call cursor(1, 1)
  call feedkeys("m", "x")
  call GT_Ok("m walks to the next mark", line(".") == 2, "   (line " . line(".") . ")")
  call feedkeys("m", "x")
  call GT_Ok("  and to the one after it", line(".") == 5, "   (line " . line(".") . ")")
  call feedkeys("m", "x")
  call GT_Ok("  and round the end of the file", line(".") == 2,
    \ "   (line " . line(".") . ", the way a search goes round)")
  call feedkeys("M", "x")
  call GT_Ok("M walks the other way", line(".") == 5, "   (line " . line(".") . ")")

  call GT_Ok("and the m of Vim is what they took",
    \ maparg("m", "n") =~ "GrooVim_BookmarkWalk" && exists(":mark") == 2,
    \ "   (\":mark a\" still writes one from the command line)")

  " ---- the note
  call cursor(5, 1)
  call feedkeys("\<F4>i", "t")
  call timer_start(400, {t -> feedkeys("olhar isto\<CR>", "t")})
  call GT_When('!empty(filter(copy(GrooVim_BookmarksOf(g:GT_FILE)), "v:val.note !=# \"\""))',
    \ "GT_AfterNote")
endfunc

func! GT_AfterNote()
  let l:one = GrooVim_BookmarkAt(g:GT_FILE, 5)
  call GT_Ok("F4 i writes a note on the line", get(l:one, "note", "") ==# "olhar isto",
    \ "   [" . get(l:one, "note", "") . "]")

  let l:placed = sign_getplaced(bufnr(g:GT_FILE), {"group": g:GT_GROUP, "lnum": 5})
  call GT_Ok("  and the sign says the line carries one",
    \ !empty(l:placed) && l:placed[0].signs[0].name ==# "GrooVim_BookmarkNote",
    \ "   [" . (empty(l:placed) ? "" : l:placed[0].signs[0].name) . "]")

  " ---- every sign one cell wide
  "
  " The margin is two cells and Vim puts a space after the sign, so a sign of two
  " cells leaves the text of that one line shifted against every other. Measured
  " on the sign the plugin shipped for a note, "☰": strwidth says 2.
  call GT_Ok("the sign of a mark is one cell wide", strwidth(g:GrooVim_BookmarkSign) == 1,
    \ "   [" . g:GrooVim_BookmarkSign . "]")
  call GT_Ok("  and so is the sign of a note", strwidth(g:GrooVim_BookmarkNoteSign) == 1,
    \ "   [" . g:GrooVim_BookmarkNoteSign . "]")
  call GT_Ok("the margin does not come and go", &signcolumn ==# "yes",
    \ "   (with \"auto\" the whole text slides two columns when a sign appears)")
  call GT_Ok("  and it is not a grey band",
    \ synIDattr(synIDtrans(hlID("SignColumn")), "bg", "cterm") ==# "", "")

  " ---- the list, built the way the occurrence list of F3 is built
  "
  " The same panel, the same shape and the same keys, because a list of places in
  " your files is a list of places in your files. It was a quickfix window
  " before, which writes on its bar the COMMAND that filled it, knows nothing
  " about separating one file from another and puts no mark on the line you came
  " from.
  call GrooVim_BookmarkList()
  call GT_Ok("the list is a panel of GrooVim, not a quickfix window",
    \ bufname("%") =~ "GrooVim_BookmarksList" && &buftype ==# "nofile",
    \ "   [" . bufname("%") . "] buftype [" . &buftype . "]")
  call GT_Ok("  and it is set up like the occurrence list",
    \ GT_FunctionText("GrooVim_BookmarkPanelSetup") =~ "GrooVim_PanelSetup",
    \ "   (one place says what a panel of GrooVim is)")

  let g:GT_PANEL = getline(1, "$")
  call GT_Ok("  with a heading of its own", g:GT_PANEL[0] =~ "\\[ Bookmarks \\]",
    \ "   [" . g:GT_PANEL[0][0:60] . "]")
  call GT_Ok("  the file named under it", g:GT_PANEL[1] ==# g:GT_FILE,
    \ "   [" . g:GT_PANEL[1] . "]")
  call GT_Ok("  and a line for each mark, numbered", g:GT_PANEL[3] =~ '^|2|' &&
    \ g:GT_PANEL[4] =~ '^|5|', "   " . string(g:GT_PANEL[3:4]))
  call GT_Ok("a note comes WITH the line it is on",
    \ g:GT_PANEL[4] =~ 'cinco \[i: olhar isto\]',
    \ "   [" . g:GT_PANEL[4] . "]   (a note with no line leaves you reading a note)")
  call GT_Ok("and the bar says what is in the list",
    \ GrooVim_BookmarkPanelBar() ==# "Bookmarks (2 marks in 1 file)",
    \ "   [" . GrooVim_BookmarkPanelBar() . "]")

  call GT_Ok("  and the marks are STILL on the file", GT_Signs() ==# [2, 5],
    \ "   " . string(GT_Signs()) . "   (the plugin left none while the list had the focus)")

  call cursor(4, 1)
  call feedkeys("\<Enter>", "x")
  call GT_Ok("Enter on a line of the list opens it",
    \ expand("%:p") ==# g:GT_FILE && line(".") == 2,
    \ "   (" . expand("%:t") . " line " . line(".") . ")")
  call GrooVim_PanelFocus("GrooVim_BookmarksList", 0)
  call GT_Ok("  and the list keeps an arrow on the line you came from",
    \ getline(4) =~ '^->|2|', "   [" . getline(4) . "]")
  call GT_Ok("  and a double click inside it does what Enter does",
    \ maparg("<2-LeftMouse>", "n") =~ "BookmarkNavigate",
    \ "   [" . maparg("<2-LeftMouse>", "n") . "]")

  " ---- what is kept on disk
  call GrooVim_BookmarksSave()
  call GT_Ok("the marks are written down", filereadable(GrooVim_BookmarksFile()),
    \ "   [" . GrooVim_BookmarksFile() . "]")
  let l:read = json_decode(join(readfile(GrooVim_BookmarksFile()), ""))
  call GT_Ok("  as JSON, and not as a script to be SOURCED",
    \ type(l:read) == type({}) && has_key(l:read, g:GT_FILE),
    \ "   (a file of state that is sourced can run anything)")
  call GT_Ok("  with the line and the note of each one",
    \ map(copy(l:read[g:GT_FILE]), 'v:val.line') ==# [2, 5] &&
    \ !empty(filter(map(copy(l:read[g:GT_FILE]), 'v:val.note'), 'v:val ==# "olhar isto"')),
    \ "   " . string(l:read[g:GT_FILE]))

  " and read back
  let g:GrooVim_Bookmarks = {}
  call GrooVim_BookmarksLoad()
  call GT_Ok("and they come back when they are read again", GT_Lines() ==# [2, 5],
    \ "   " . string(GT_Lines()))

  " ---- and the same key takes the list away again
  "
  " A key that opens a list and does nothing the second time leaves you hunting
  " for another one to close it. Asked for again it was FILLING the list it had
  " already built -- work nobody asked for, and work that SPOKE: "4 fewer lines",
  " "5 more lines", "--No lines in buffer--" over the bar, from the very commands
  " that empty the buffer and fill it.
  call GrooVim_PanelFocus("GrooVim_BookmarksList", 0)
  call GT_Ok("setup: the list is open", bufname("%") =~ "GrooVim_BookmarksList", "")
  call GrooVim_BookmarkList()
  call GT_Ok("the same key takes the list away",
    \ empty(filter(range(1, winnr("$")),
    \   'bufname(winbufnr(v:val)) =~ "GrooVim_BookmarksList"')),
    \ "   (" . winnr("$") . " windows left)")
  call GT_Ok("  and the cursor goes back to the file",
    \ expand("%:p") ==# g:GT_FILE, "   [" . expand("%:t") . "]")
  call GrooVim_BookmarkList()
  call GT_Ok("  and again brings it back",
    \ bufname("%") =~ "GrooVim_BookmarksList", "   [" . bufname("%") . "]")
  call GT_Ok("and filling it says nothing over the bar",
    \ GT_FunctionText("GrooVim_BookmarkPanelFill") =~ "silent",
    \ "   (emptying a buffer and filling it again speaks)")

  " ---- and the panel has colours, because what is in it has shape
  call GT_Ok("the panel is painted", !empty(filter(split(execute("syntax list"), "\n"),
    \ 'v:val =~ "GrooVimPanel"')),
    \ "   (a heading, a file name, the rules, the numbers and the arrow)")
  call GT_Ok("  and a note is painted in the yellow of its sign",
    \ GT_FunctionText("GrooVim_BookmarkPanelSetup") =~ "GrooVimPanelNote", "")
  " ---- and each panel wears a colour of its own
  "
  " The heading and the rules carry it: the list of the search in yellow, this
  " one in green. Two panels of the same shape, told apart before you read a word
  " of either. The heading and the rules MATCH inside each one, because a heading
  " is a rule with a name in the middle of it.
  call GT_Ok("  the heading takes the colour of the rules around it",
    \ synIDattr(synIDtrans(hlID("GrooVimPanelBookmarkTitle")), "fg", "cterm")
    \   ==# synIDattr(synIDtrans(hlID("GrooVimPanelBookmarkRule")), "fg", "cterm"),
    \ "   (a heading IS a rule with a name in the middle of it)")
  call GT_Ok("  and the two panels are NOT the same colour",
    \ synIDattr(synIDtrans(hlID("GrooVimPanelBookmarkRule")), "fg", "cterm")
    \   !=# synIDattr(synIDtrans(hlID("GrooVimPanelSearchRule")), "fg", "cterm"),
    \ "   (marks " . synIDattr(synIDtrans(hlID("GrooVimPanelBookmarkRule")), "fg", "cterm") .
    \ ", search " . synIDattr(synIDtrans(hlID("GrooVimPanelSearchRule")), "fg", "cterm") . ")")
  call GT_Ok("  and what is the same in both is named for the PART",
    \ synIDattr(synIDtrans(hlID("GrooVimPanelFile")), "fg", "cterm") !=# "" &&
    \ synIDattr(synIDtrans(hlID("GrooVimPanelWhere")), "fg", "cterm") !=# "",
    \ "   (a file name is a file name and a line number is a line number)")
  call GT_Ok("  and the arrow is yellow letters with nothing behind them",
    \ synIDattr(synIDtrans(hlID("GrooVimPanelHere")), "bg", "cterm") ==# "",
    \ "   (\"Todo\" is yellow the other way round, and a band shouts)")

  " ---- and the vertical edge does not belong in a list
  "
  " It marks where a line of text gets too long, which means nothing in a window
  " that holds no text of yours.
  call GT_Ok("no vertical edge over the list", &colorcolumn ==# "",
    \ "   [colorcolumn=" . &colorcolumn . "]")
  call GT_Ok("  and the panel is what takes it off itself",
    \ GT_FunctionText("GrooVim_PanelSetup") =~ "colorcolumn",
    \ "   (the rule that draws it runs before the buffer is a panel at all)")
  exec "edit! " . g:GT_FILE
  call GT_Ok("  and it is still there over a file", &colorcolumn ==# string(g:GrooVim_EdgeColumn),
    \ "   [colorcolumn=" . &colorcolumn . "]")

  " ---- what is written on a line is SHOWN when you stand on it
  "
  " A note you cannot read without opening a list is half a note. The "i" in the
  " margin says there is something written; the balloon says what.
  call cursor(1, 1)
  call timer_start(150, {t -> feedkeys("j", "t")})
  call timer_start(400, "GT_NoteBalloonAway")
endfunc

func! GT_NoteBalloonAway(t)
  call GT_Ok("no balloon on a line with nothing written on it",
    \ len(popup_list()) == 0, "   (line " . line(".") . ")")
  call timer_start(150, {t -> [cursor(4, 1), feedkeys("j", "t")]})
  call timer_start(400, "GT_NoteBalloonUp")
endfunc

func! GT_NoteBalloonUp(t)
  let l:up = popup_list()
  call GT_Ok("standing on the marked line shows what is written on it",
    \ len(l:up) == 1 &&
    \ join(getbufline(winbufnr(l:up[0]), 1, "$")) =~ "olhar isto",
    \ "   (line " . line(".") . ", " . len(l:up) . " balloon)")
  call timer_start(150, {t -> feedkeys("j", "t")})
  call timer_start(400, "GT_NoteBalloonGone")
endfunc

func! GT_NoteBalloonGone(t)
  call GT_Ok("  and it goes when you walk away", len(popup_list()) == 0,
    \ "   (line " . line(".") . ")")

  " ---- and the note follows the mark when the mark moves
  "
  " A mark moves with its line: Vim carries the sign along when text is put in
  " above it. The line written down is only right once the signs are ASKED, and
  " the balloon was not asking -- so it came up where the mark HAD been, on a
  " line with nothing on it, and stayed quiet on the line where the mark really
  " was. Measured on a file of twenty lines: a note made on line 10, three
  " lines typed above it, and the balloon still offered on 10 while the mark
  " itself was on 13.
  let g:GT_MARK_WAS = GrooVim_BookmarksOf(g:GT_FILE)[0].line
  call cursor(1, 1)
  call append(0, ["uma", "duas", "tres"])
  call GT_Ok("text put in above a mark moves the mark",
    \ GrooVim_BookmarkAtRefreshed(g:GT_FILE, g:GT_MARK_WAS + 3),
    \ "   (line " . g:GT_MARK_WAS . " -> " . (g:GT_MARK_WAS + 3) . ")")
  call GT_Ok("  and asking where it is is what the balloon does now",
    \ GT_FunctionText("GrooVim_BookmarkNoteShow") =~ "BookmarksRefresh",
    \ "   (measured through a real terminal: the note offered on the line the\n" .
    \ "    mark had been on, and not on the line it had moved to)")
  silent! undo

  call GT_Dock()
endfunc

" Is there a mark on this line, with the signs asked first? -- which is the
" whole question the balloon gets wrong when it does not ask.
func! GrooVim_BookmarkAtRefreshed(file, line)
  call GrooVim_BookmarksRefresh(a:file)
  return !empty(GrooVim_BookmarkAt(a:file, a:line))
endfunc

" ---- the list is a DOCK, not a window of one tab
"
" It is asked for once and belongs to every tab, including the ones opened after
" -- which is what the "Search results" of Notepad++ does, and what the
" occurrence list of F3 does when it is told to.
func! GT_ListsPerTab()
  let l:where = []
  for l:tab in range(1, tabpagenr("$"))
    for l:buffer in tabpagebuflist(l:tab)
      if bufname(l:buffer) =~ "GrooVim_BookmarksList"
        call add(l:where, l:tab)
      endif
    endfor
  endfor
  return l:where
endfunc

func! GT_Dock()
  exec "edit! " . g:GT_FILE
  if g:GrooVim_BookmarkListOpen
    call GrooVim_BookmarkList()
  endif
  exec "tabnew " . g:GT_FILE
  tabfirst
  call GT_Ok("setup: two tabs and no list", empty(GT_ListsPerTab()) &&
    \ tabpagenr("$") == 2, "   (" . tabpagenr("$") . " tabs)")

  call GrooVim_BookmarkList()
  call GT_Ok("the list asked for in one tab is in every tab",
    \ len(GT_ListsPerTab()) == tabpagenr("$"),
    \ "   (tabs with a list: " . string(GT_ListsPerTab()) . " of " . tabpagenr("$") . ")")
  call GT_Ok("  and the cursor goes into it, because you asked to read it",
    \ bufname("%") =~ "GrooVim_BookmarksList", "   [" . bufname("%") . "]")
  call GT_Ok("  each tab with a list OF ITS OWN",
    \ len(uniq(sort(map(copy(GT_ListsPerTab()), 'v:val')))) == tabpagenr("$"),
    \ "   (one buffer shared would show the arrow of one tab in all of them)")

  exec "tabnew " . g:GT_FILE
  call GT_When('len(GT_ListsPerTab()) == tabpagenr("$")', "GT_DockNewTab")
endfunc

func! GT_DockNewTab()
  call GT_Ok("a tab opened AFTER gets it as it arrives",
    \ len(GT_ListsPerTab()) == tabpagenr("$"),
    \ "   (tabs with a list: " . string(GT_ListsPerTab()) . " of " . tabpagenr("$") . ")")

  call GrooVim_BookmarkList()
  call GT_Ok("and taking it away takes it from every tab", empty(GT_ListsPerTab()),
    \ "   (" . tabpagenr("$") . " tabs, none with a list)")

  " ---- and what the list must not do to the cursor
  call GrooVim_BookmarkList()
  call GrooVim_PutOnEditWindow()
  let l:was = bufname("%")
  call GrooVim_BookmarkListSync()
  call GT_Ok("the sync leaves you where it found you", bufname("%") ==# l:was,
    \ "   [" . bufname("%") . "]   (it runs on a timer, at moments nobody chose)")

  " ---- marking with the list open shows up in it
  exec "edit! " . g:GT_FILE
  call cursor(3, 1)
  call GrooVim_BookmarkToggle()
  call GT_Ok("a mark made with the list open is in the list",
    \ !empty(filter(GT_PanelLines(), 'v:val =~ "^|3|"')),
    \ "   " . string(GT_PanelLines()))
  call GT_Ok("  and the cursor did not move to the list to do it",
    \ expand("%:p") ==# g:GT_FILE, "   [" . expand("%:t") . "]")
  call cursor(3, 1)
  call GrooVim_BookmarkToggle()
  call GT_Ok("  and taking it off takes it out of the list",
    \ empty(filter(GT_PanelLines(), 'v:val =~ "^|3|"')),
    \ "   " . string(GT_PanelLines()))

  " ---- and "Del" in the list takes the mark of that line off
  "
  " Which is what the key means in a list everywhere else. On the file itself
  " the key that marks is the key that unmarks -- F4->b -- and inside the list
  " there is no file under the cursor to press it on.
  " Marked if it is not marked already: the key is a toggle, and the case above
  " may have left one of these lines with a mark on it -- pressing it blindly
  " would take that one OFF and set up the opposite of what is wanted.
  exec "edit! " . g:GT_FILE
  for s:line in [2, 5]
    call cursor(s:line, 1)
    if empty(GrooVim_BookmarkAt(g:GT_FILE, s:line))
      call GrooVim_BookmarkToggle()
    endif
  endfor
  call GT_Ok("setup: two marks, and both in the list",
    \ len(filter(GT_PanelLines(), 'v:val =~ "^|[25]|"')) == 2,
    \ "   " . string(GT_PanelLines()))

  call GrooVim_PanelFocus("GrooVim_BookmarksList", 0)
  call GT_Ok("the list has Del on its own buffer",
    \ get(maparg("<Del>", "n", 0, 1), "buffer", 0) == 1 &&
    \ maparg("<Del>", "n") =~ "BookmarkListDelete", "   [" . maparg("<Del>", "n") . "]")

  call cursor(4, 1)
  call GT_Ok("  setup: the cursor is on the first mark of the file",
    \ getline(".") =~ "^|2|", "   [" . getline(".") . "]")
  call GrooVim_BookmarkListDelete()
  call GT_Ok("Del takes that mark off",
    \ empty(filter(copy(GrooVim_BookmarksOf(g:GT_FILE)), 'v:val.line == 2')),
    \ "   " . string(map(copy(GrooVim_BookmarksOf(g:GT_FILE)), 'v:val.line')))
  call GT_Ok("  and out of the list, which is built again from what is left",
    \ empty(filter(GT_PanelLines(), 'v:val =~ "^|2|"')) &&
    \ !empty(filter(GT_PanelLines(), 'v:val =~ "^|5|"')),
    \ "   " . string(GT_PanelLines()))
  call GT_Ok("  and off the file as well, sign and all",
    \ empty(filter(GT_SignsHere(), 'v:val == 2')),
    \ "   " . string(GT_SignsHere()) .
    \ "   (a mark is a line in a list AND a sign in the file)")
  call GrooVim_PanelFocus("GrooVim_BookmarksList", 0)
  call GT_Ok("  and the cursor stays on the line, which is the mark below",
    \ getline(".") =~ "^|5|", "   [" . getline(".") . "]" .
    \ "   (the way a list of anything behaves when a line goes out of it)")

  " ---- a heading is not a mark
  call cursor(1, 1)
  let g:GrooVim_GrooVimBarMsgValue = ""
  call GrooVim_BookmarkListDelete()
  call GT_Ok("Del on a heading takes nothing off, and says so",
    \ !empty(GrooVim_BookmarksOf(g:GT_FILE)) &&
    \ g:GrooVim_GrooVimBarMsgValue =~ "not a mark",
    \ "   [" . trim(g:GrooVim_GrooVimBarMsgValue) . "]")

  " ---- and a panel is not a file, so it cannot be marked
  call GrooVim_PanelFocus("GrooVim_BookmarksList", 0)
  let g:GrooVim_GrooVimBarMsgValue = ""
  call cursor(1, 1)
  call GrooVim_BookmarkToggle()
  call GT_Ok("a panel cannot be marked",
    \ !has_key(g:GrooVim_Bookmarks, expand("%:p")) &&
    \ g:GrooVim_GrooVimBarMsgValue =~ "cannot be marked",
    \ "   [" . trim(g:GrooVim_GrooVimBarMsgValue) . "]")
  call GT_Ok("  and it is \"buftype\" that tells them apart",
    \ GT_FunctionText("GrooVim_BookmarksFileHere") =~ "buftype",
    \ "   (\"GrooVim_BookmarksList1\" is a name, so asking for a name is not enough)")

  call GrooVim_BookmarkList()
  tabonly!
  call delete(g:GT_FILE)
  call GT_Done()
endfunc

" The lines of the file that carry a mark of the sign group, read from the file
" itself and not from what GrooVim believes.
func! GT_SignsHere()
  let l:back = win_getid()
  call GrooVim_PanelFocus(g:GT_FILE, 1)
  let l:placed = sign_getplaced(bufnr("%"), {"group": "GrooVim_Bookmarks"})
  call win_gotoid(l:back)
  return map(copy(get(l:placed[0], "signs", [])), 'v:val.lnum')
endfunc

func! GT_PanelLines()
  let l:back = win_getid()
  call GrooVim_PanelFocus("GrooVim_BookmarksList", 0)
  let l:lines = filter(getline(1, "$"), 'v:val =~ "^|"')
  call win_gotoid(l:back)
  return l:lines
endfunc

call GT_AfterStartup("GT_Body")
