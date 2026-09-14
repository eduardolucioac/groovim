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
  call timer_start(100,  {t -> [cursor(5, 24), feedkeys("\<C-b>", "t")]})
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
  call GT_Ok("block: Ctrl-b entered visual block", p[0].mode ==# "\<C-v>", "   (mode [" . strtrans(p[0].mode) . "])")
  call GT_Ok("block: went down to the short line", p[1].line == 6, GT_Show(p[1]))
  call GT_Ok("block: sat over an area with no text", p[1].virtcol == 24 && p[1].virtcol > p[1].end, GT_Show(p[1]))
  call GT_Ok("block: down to the long one, column 24", p[2].line == 7 && p[2].col == 24, GT_Show(p[2]))
  call GT_Ok("block: still in visual block", p[2].mode ==# "\<C-v>", "   (mode [" . strtrans(p[2].mode) . "])")
  call GT_Ok("block: the text was not touched", getline(1, "$") ==# g:GT_TEXT, "")
  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
