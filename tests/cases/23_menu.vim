" The menu: a bar across the top with the four groups, and under the one you are
" on, what it holds -- the shape of the menu of Notepad++ and of vim-quickui.
"
" Written out of the same list as the help of F9. Choosing an entry presses the
" keys of the shortcut, so the menu can never do something the keyboard would
" not -- and the keys it will press are written on the right of every line.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

" Which section is open, read from the entries the menu put up.
func! GT_MenuSection()
  return empty(g:GrooVim_MenuEntries) ? "" : g:GrooVim_MenuEntries[0].group
endfunc

func! GT_MenuDrop()
  for l:id in popup_list()
    if popup_getpos(l:id).height > 1
      return l:id
    endif
  endfor
  return 0
endfunc

func! GT_Body()
  call GT_Ok("this Vim has popup windows and text properties",
    \ has("popupwin") && exists("*prop_type_add"), "")
  call GT_Ok("F10 opens the menu in the three modes",
    \ maparg("<F10>", "n") =~ "GrooVim_Menu" && maparg("<F10>", "i") =~ "GrooVim_Menu" &&
    \ maparg("<F10>", "v") =~ "GrooVim_Menu", "   [" . maparg("<F10>", "n") . "]")

  " ---- the bar
  let [l:text, l:at] = GrooVim_MenuBarText()
  call GT_Ok("the bar names the four sections",
    \ l:text ==# " F2 Edit  F3 Search  F4 Plugins  F5 Editor ", "   [" . l:text . "]")
  call GT_Ok("and says where each one begins", len(l:at) == 4 && l:at[0][0] == 1 &&
    \ strpart(l:text, l:at[3][0] - 1, 3) ==# " F5", "   " . string(l:at))

  " ---- a line: what it does on the left, the keys on the right
  call GT_Ok("the shortcut is written the way the messages write it",
    \ GrooVim_ShortcutShown({"group": "F5", "key": "n"}) ==# "F5->n",
    \ "   [" . GrooVim_ShortcutShown({"group": "F5", "key": "n"}) . "]")
  call GT_Ok("a named key keeps its capital",
    \ GrooVim_ShortcutShown({"group": "F2", "key": "up"}) ==# "F2->Up", "")
  let l:line = GrooVim_MenuLine({"group": "F5", "key": "n", "what": "Open a new tab"}, 20)
  call GT_Ok("the line puts the keys on the right",
    \ l:line ==# "  Open a new tab" . repeat(" ", 10) . "F5->n  ",
    \ "   [" . l:line . "]")
  let l:tight = GrooVim_MenuLine({"group": "F5", "key": "n", "what": "Open a new tab"}, 10)
  call GT_Ok("a description too long for the room is cut, not the keys",
    \ l:tight =~ "…" && l:tight =~ "F5->n",
    \ "   [" . l:tight . "]   (losing the right side would lose the shortcut)")

  " ---- nothing carries the markup the help needs
  let l:littered = []
  for l:one in g:GrooVim_Shortcuts
    if GrooVim_MenuLine(l:one, 80) =~ '[|*]'
      call add(l:littered, l:one.group . "->" . l:one.key)
    endif
  endfor
  call GT_Ok("no line has help markup left in it", empty(l:littered),
    \ "   " . (empty(l:littered) ? "(" . len(g:GrooVim_Shortcuts) . " lines)" : string(l:littered)))

  " ---- the keys a shortcut is made of
  call GT_Ok("a letter: the F key and the letter",
    \ GrooVim_ShortcutKeys({"group": "F5", "key": "s"}) ==# "\<F5>s", "")
  call GT_Ok("a named key: the F key and the real key code",
    \ GrooVim_ShortcutKeys({"group": "F2", "key": "up"}) ==# "\<F2>\<Up>", "")

  " ---- opening it
  call GrooVim_Menu()
  call GT_Ok("two popups: the bar and the list", len(popup_list()) == 2,
    \ "   (" . len(popup_list()) . ")")
  let l:drop = GT_MenuDrop()
  let l:barPos = popup_getpos(popup_list()[0] == l:drop ? popup_list()[1] : popup_list()[0])
  call GT_Ok("the bar is on the first line", l:barPos.line == 1 && l:barPos.col == 1,
    \ "   (line " . l:barPos.line . " col " . l:barPos.col . ")")
  call GT_Ok("the list is right under it", popup_getpos(l:drop).line == 2,
    \ "   (line " . popup_getpos(l:drop).line . ")")
  call GT_Ok("it opens on the first section", GT_MenuSection() ==# "F2",
    \ "   [" . GT_MenuSection() . "]")
  call GT_Ok("with one line per key of that section, plus the border",
    \ popup_getpos(l:drop).height ==
    \ len(filter(copy(g:GrooVim_Shortcuts), 'v:val.group ==# "F2"')) + 2,
    \ "   (" . popup_getpos(l:drop).height . " lines)")

  " ---- Right and Left walk the bar, and it wraps round
  call GrooVim_MenuFilter(GT_MenuDrop(), "\<Right>")
  call GT_Ok("Right goes to the next section", GT_MenuSection() ==# "F3", "   [" . GT_MenuSection() . "]")
  call GT_Ok("  and the list moved under it",
    \ popup_getpos(GT_MenuDrop()).col == GrooVim_MenuBarText()[1][1][0],
    \ "   (col " . popup_getpos(GT_MenuDrop()).col . ")")
  call GrooVim_MenuFilter(GT_MenuDrop(), "\<Left>")
  call GT_Ok("Left comes back", GT_MenuSection() ==# "F2", "   [" . GT_MenuSection() . "]")
  call GrooVim_MenuFilter(GT_MenuDrop(), "\<Left>")
  call GT_Ok("and from the first, Left wraps to the last", GT_MenuSection() ==# "F5",
    \ "   [" . GT_MenuSection() . "]")
  call GrooVim_MenuFilter(GT_MenuDrop(), "\<Right>")
  call GT_Ok("from the last, Right wraps to the first", GT_MenuSection() ==# "F2",
    \ "   [" . GT_MenuSection() . "]")

  " ---- the F key of a section jumps straight to it
  call GrooVim_MenuFilter(GT_MenuDrop(), "\<F5>")
  call GT_Ok("F5 jumps to its own section", GT_MenuSection() ==# "F5",
    \ "   [" . GT_MenuSection() . "]   (the same key that runs its shortcuts)")

  " ---- and the list really is the one of that section
  let l:lines = getbufline(winbufnr(GT_MenuDrop()), 1, "$")
  call GT_Ok("its first line is the first key of the list",
    \ l:lines[0] =~ "Save to disk" && l:lines[0] =~ "F5->s", "   [" . trim(l:lines[0]) . "]")

  " ---- choosing an entry presses the keys
  "
  " Through the filter and not by calling the callback: it is Vim that closes the
  " popup and then calls it, and doing it by hand left the list open with the
  " keys going into IT instead of into the buffer.
  call GrooVim_MenuClose()
  tabonly!
  exec "edit " . g:GT_FIX . "/a.txt"
  call GT_Ok("setup: one tab", tabpagenr("$") == 1, "")
  call GrooVim_Menu()
  call GrooVim_MenuFilter(GT_MenuDrop(), "\<F5>")
  let l:which = 0
  for l:i in range(len(g:GrooVim_MenuEntries))
    if g:GrooVim_MenuEntries[l:i].key ==# "n"
      let l:which = l:i + 1
    endif
  endfor
  call GT_Ok("found \"open a new tab\" in the F5 section", l:which > 0, "   (line " . l:which . ")")
  for l:step in range(l:which - 1)
    call GrooVim_MenuFilter(GT_MenuDrop(), "\<Down>")
  endfor
  let g:GrooVim_CommandZMoment = 0
  call GrooVim_MenuFilter(GT_MenuDrop(), "\<CR>")
  call feedkeys("", "x")
  call GT_Ok("choosing it opened a tab, like pressing F5 and then n",
    \ tabpagenr("$") == 2, "   (tabs " . tabpagenr("$") . ")")
  call GT_Ok("  and the menu took itself down", empty(popup_list()),
    \ "   (" . len(popup_list()) . " popups)")

  " ---- Esc leaves, and takes the bar with it
  call GrooVim_Menu()
  let l:before = tabpagenr("$")
  call GT_Ok("setup: the menu is up", len(popup_list()) == 2, "   (" . len(popup_list()) . ")")
  call GrooVim_MenuFilter(GT_MenuDrop(), "\<Esc>")
  call GT_Ok("Esc closed the list AND the bar", empty(popup_list()),
    \ "   (" . len(popup_list()) . " popups)   (the bar used to stay behind)")
  call GT_Ok("  and nothing happened to the tabs", tabpagenr("$") == l:before,
    \ "   (tabs " . tabpagenr("$") . ")")

  " ---- and a step sideways does not take the bar down with it
  call GrooVim_Menu()
  call GrooVim_MenuFilter(GT_MenuDrop(), "\<Right>")
  call GT_Ok("walking sideways keeps the bar up", len(popup_list()) == 2,
    \ "   (" . len(popup_list()) . " popups)   (closing the old list answers -1 too)")
  call GrooVim_MenuClose()

  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
