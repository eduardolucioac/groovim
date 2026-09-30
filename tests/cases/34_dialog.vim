" The dialogues: the window that says something and waits.
"
" The About is the first one, and what is checked here is the DIALOGUE through
" it: the buttons and the walking between them, the keys, the mouse, the link,
" the "c" that copies any of them, and the two ways out.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

func! GT_Dialog()
  return empty(popup_list()) ? 0 : popup_list()[0]
endfunc
func! GT_Text()
  let l:id = GT_Dialog()
  return l:id ? join(getbufline(winbufnr(l:id), 1, "$"), "\n") : ""
endfunc
" which button is the blue one, read from the property that paints it
func! GT_Chosen()
  let l:id = GT_Dialog()
  if !l:id | return "" | endif
  let l:line = len(getbufline(winbufnr(l:id), 1, "$"))
  let l:props = prop_list(l:line, {"bufnr": winbufnr(l:id)})
  if empty(l:props) | return "" | endif
  let l:text = getbufline(winbufnr(l:id), l:line)[0]
  return strpart(l:text, l:props[0].col - 1, l:props[0].length)
endfunc

func! GT_Body()

" ---- it opens, and it says what GrooVim is
call GrooVim_About()
call GT_Ok("the About opens a dialogue", GT_Dialog() > 0,
  \ "   [" . popup_getoptions(GT_Dialog()).title . "]")
call GT_Ok("  saying which GrooVim this is", GT_Text() =~ g:grooVimVersion,
  \ "   [" . g:grooVimVersion . "]")
call GT_Ok("  under what licence", GT_Text() =~ "General Public License", "")
call GT_Ok("  and which Vim is underneath, asked of Vim",
  \ GT_Text() =~ printf("%d\\.%d\\.%d", v:version / 100, v:version % 100,
  \   v:versionlong % 10000),
  \ "   (" . printf("%d.%d.%d", v:version / 100, v:version % 100, v:versionlong % 10000) . ")")

" ---- the buttons, and the blue one
call GT_Ok("with buttons under the text",
  \ GT_Text() =~ "Open page (p)" && GT_Text() =~ "Close (Esc)",
  \ "   [" . split(GT_Text(), "\n")[-1] . "]")
call GT_Ok("  and the way out is the one chosen", GT_Chosen() =~ "Close",
  \ "   [" . GT_Chosen() . "]   (Enter on a window just opened should undo nothing)")
call GrooVim_DialogFilter(GT_Dialog(), "\<Left>")
call GT_Ok("Left walks to the button before it", GT_Chosen() =~ "Open page",
  \ "   [" . GT_Chosen() . "]")
call GrooVim_DialogFilter(GT_Dialog(), "\<Right>")
call GT_Ok("  and Right comes back", GT_Chosen() =~ "Close", "   [" . GT_Chosen() . "]")
call GrooVim_DialogFilter(GT_Dialog(), "\<Tab>")
call GT_Ok("  Tab walks too, and wraps round", GT_Chosen() =~ "Open page",
  \ "   [" . GT_Chosen() . "]")
call GrooVim_DialogFilter(GT_Dialog(), "\<S-Tab>")
call GT_Ok("  and so does Shift-Tab, the other way", GT_Chosen() =~ "Close",
  \ "   [" . GT_Chosen() . "]")

" ---- what is NOT a way out
call GT_Ok("a key of Vim's own does not close it",
  \ GrooVim_DialogFilter(GT_Dialog(), "\x80\xfd`") == 1 && GT_Dialog() > 0,
  \ "   (they begin with 0x80 0xFD, and one of them used to shut it as it opened)")
call GT_Ok("  and neither does a key pressed by mistake",
  \ GrooVim_DialogFilter(GT_Dialog(), "z") == 1 && GT_Dialog() > 0, "")
call GT_Ok("  and half of the shortcut is not the shortcut",
  \ GrooVim_DialogFilter(GT_Dialog(), "\<F5>") == 1 && GT_Dialog() > 0,
  \ "   (the window waits for the other half)")
call GT_Ok("  so a key that is not it puts the window back to sleep",
  \ GrooVim_DialogFilter(GT_Dialog(), "k") == 1 && GT_Dialog() > 0, "")

" ---- "c" copies, on this dialogue and on every other
call GrooVim_ClipSet("")
call GrooVim_DialogFilter(GT_Dialog(), "c")
call GT_Ok("c copies what the dialogue says",
  \ GrooVim_ClipGet() =~ g:grooVimVersion && GrooVim_ClipGet() !~ "Close (Esc)",
  \ "   (the text, and not the buttons: they are a way of pressing this window)")
call GT_Ok("  and it stays up", GT_Dialog() > 0, "")

" ---- the address is a link, and the button beside it opens it
let g:GT_LINKS = GrooVim_DialogLinks("see " . g:GrooVim_Url . " for more")
call GT_Ok("an address in the text is found as a link",
  \ len(g:GT_LINKS) == 1 && g:GT_LINKS[0][2] ==# g:GrooVim_Url,
  \ "   " . string(g:GT_LINKS))
call GT_Ok("  and it is drawn as one",
  \ !empty(filter(prop_list(8, {"bufnr": winbufnr(GT_Dialog())}),
  \   'v:val.type ==# "GrooVimDialogLink"')),
  \ "   (the line with the address carries the link property)")
call GT_Ok("  with the underline a link has always had",
  \ synIDattr(synIDtrans(hlID("GrooVimDialogLink")), "underline") ==# "1", "")

" ---- and a click on it goes the same road the button goes
"
" Which matters for the half of the world with no desktop to open a page on --
" every GrooVim reached over SSH. That road ends on the clipboard instead, and a
" link that opened addresses by itself would not have it.
call GT_Ok("the link and the button take the same road",
  \ GT_FunctionText("GrooVim_DialogClicked") =~ "GrooVim_DialogPage" &&
  \ GT_FunctionText("GrooVim_About") =~ "GrooVim_DialogPage",
  \ "   (GrooVim_DialogPage, which is where the clipboard fallback lives)")
call GT_Ok("  and that road knows it may have nowhere to open one",
  \ GT_FunctionText("GrooVim_DialogPage") =~ "DISPLAY" &&
  \ GT_FunctionText("GrooVim_DialogPage") =~ "GrooVim_ClipSet",
  \ "   (no desktop: the address goes to the clipboard, and it travels through the terminal)")

" ---- the two ways out
call GrooVim_DialogFilter(GT_Dialog(), "\<Esc>")
call GT_Ok("Esc closes it", GT_Dialog() == 0, "   (" . len(popup_list()) . " popups)")
call GT_Ok("  and the cursor of the terminal comes back with it", &t_ve !=# "",
  \ "   [" . strtrans(&t_ve) . "]   (it is hidden while a dialogue is up)")

call GrooVim_About()
call GrooVim_DialogFilter(GT_Dialog(), "\<F5>")
call GT_Ok("the shortcut pressed again closes it",
  \ GrooVim_DialogFilter(GT_Dialog(), "/") == 1 && GT_Dialog() == 0,
  \ "   (F5->/ both ways, the way F9 works with the help)")

call GrooVim_About()
call GrooVim_DialogFilter(GT_Dialog(), "\<CR>")
call GT_Ok("Enter presses the button that is blue", GT_Dialog() == 0,
  \ "   (and the blue one is the way out)")

" ---- the mouse presses them too
"
" The WAY OUT is the one clicked here, and that is not laziness: pressing "Open
" page" really opens the page. It was clicked once while this case was being
" written and a browser came up on the machine running the battery, which is not
" something a test may do.
call GrooVim_About()
let g:GT_ID = GT_Dialog()
let g:GT_AT = GrooVim_DialogButtons()[1]
let g:GT_WHERE = popup_getpos(g:GT_ID)
" the row of buttons is the last line of the window, and "core_line"/"core_col"
" are where the TEXT of a popup starts: the border and the padding are already
" taken into account in them
let g:GT_ROW = g:GT_WHERE.core_line + len(GrooVim_AboutLines()) + 1
call test_setmouse(g:GT_ROW, g:GT_WHERE.core_col + g:GT_AT[1][0])
call GrooVim_DialogFilter(g:GT_ID, "\<LeftMouse>")
call GT_Ok("a click on a button presses it", GT_Dialog() == 0,
  \ "   (the way out was clicked, and the window went down with it)")

" ---- and a click on nothing is nothing
call GrooVim_About()
let g:GT_ID = GT_Dialog()
let g:GT_WHERE = popup_getpos(g:GT_ID)
call test_setmouse(g:GT_WHERE.core_line, g:GT_WHERE.core_col)
call GrooVim_DialogFilter(g:GT_ID, "\<LeftMouse>")
call GT_Ok("  and a click on the text does nothing at all", GT_Dialog() > 0,
  \ "   (a dialogue goes down by its ways out, not by being clicked beside them)")
call GrooVim_DialogClose()

call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
