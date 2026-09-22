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

  " ---- and the panel has colours, because what is in it has shape
  call GT_Ok("the panel is painted", !empty(filter(split(execute("syntax list"), "\n"),
    \ 'v:val =~ "GrooVimPanel"')),
    \ "   (a heading, a file name, the rules, the numbers and the arrow)")
  call GT_Ok("  and a note is painted in the yellow of its sign",
    \ GT_FunctionText("GrooVim_BookmarkPanelSetup") =~ "GrooVimPanelNote", "")
  call GT_Ok("  the heading takes the colour of the rules around it",
    \ synIDattr(synIDtrans(hlID("GrooVimBookmarkTitle")), "fg", "cterm")
    \   ==# synIDattr(synIDtrans(hlID("GrooVimPanelRule")), "fg", "cterm"),
    \ "   (a heading IS a rule with a name in the middle of it)")
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
  call delete(g:GT_FILE)
  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
