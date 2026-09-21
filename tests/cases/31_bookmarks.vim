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

  " ---- the list, and the signs that must NOT go down while it has the focus
  call GrooVim_BookmarkList()
  call GT_Ok("the list opens as a quickfix window", &buftype ==# "quickfix",
    \ "   [" . &buftype . "]")
  call GT_Ok("  called by its name", get(w:, "quickfix_title", "") ==# "Bookmarks",
    \ "   [" . get(w:, "quickfix_title", "") . "]")
  call GT_Ok("  with a line for each mark, the note among them",
    \ len(getqflist()) == 2 &&
    \ !empty(filter(map(getqflist(), 'v:val.text'), 'v:val =~ "olhar isto"')),
    \ "   " . string(map(getqflist(), 'v:val.text')))
  call GT_Ok("  and the marks are STILL on the file", GT_Signs() ==# [2, 5],
    \ "   " . string(GT_Signs()) . "   (the plugin left none while the list had the focus)")

  call cursor(1, 1)
  call feedkeys("\<Enter>", "x")
  call GT_Ok("Enter on a line of the list opens it",
    \ expand("%:p") ==# g:GT_FILE && line(".") == 2,
    \ "   (" . expand("%:t") . " line " . line(".") . ")")

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

  call delete(g:GT_FILE)
  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
