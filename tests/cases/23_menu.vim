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

" Which line of the list the cursor is on. A popup is a window of its own, so it
" has to be asked from the inside.
func! GT_MenuAt()
  call win_execute(GT_MenuDrop(), 'let g:GT_MENU_AT = line(".")')
  return g:GT_MENU_AT
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
  call GT_Ok("with one line per key of that section, its rules and the border",
    \ popup_getpos(l:drop).height == len(g:GrooVim_MenuEntries) + 2,
    \ "   (" . popup_getpos(l:drop).height . " lines)")

  " ---- the rules between blocks
  let l:rules = len(filter(copy(g:GrooVim_MenuEntries), 'get(v:val, "rule", 0)'))
  call GT_Ok("the section is broken into blocks by rules", l:rules > 0,
    \ "   (" . l:rules . " rules)")
  let l:drawn = getbufline(winbufnr(l:drop), 1, "$")
  call GT_Ok("  and a rule is a line of its own, not an entry",
    \ l:drawn[3] =~ "^─\\+$" && get(g:GrooVim_MenuEntries[3], "rule", 0),
    \ "   [" . l:drawn[3][0:20] . "]")
  call GT_Ok("  no rule is the first line", !get(g:GrooVim_MenuEntries[0], "rule", 0),
    \ "   (a menu does not open with a line across it)")

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
  " A rule between blocks has no key of its own, so anything that walks this list
  " has to ask before it reads.
  let l:which = 0
  for l:i in range(len(g:GrooVim_MenuEntries))
    if get(g:GrooVim_MenuEntries[l:i], "key", "") ==# "n"
      let l:which = l:i + 1
    endif
  endfor
  call GT_Ok("found \"open a new tab\" in the F5 section", l:which > 0, "   (line " . l:which . ")")

  " Down one at a time until the cursor is on it -- counting the steps would be
  " wrong, because Down STEPS OVER the rules.
  let l:tries = 0
  while GT_MenuAt() != l:which && l:tries < 40
    call GrooVim_MenuFilter(GT_MenuDrop(), "\<Down>")
    let l:tries = l:tries + 1
  endwhile
  call GT_Ok("Down walked to it, stepping over the rules", GT_MenuAt() == l:which,
    \ "   (line " . GT_MenuAt() . " of " . l:which . " in " . l:tries . " steps)")
  call GrooVim_MenuFilter(GT_MenuDrop(), "\<CR>")
  call feedkeys("", "x")
  call GT_Ok("choosing it opened a tab, like pressing F5 and then n",
    \ tabpagenr("$") == 2, "   (tabs " . tabpagenr("$") . ")")
  call GT_Ok("  and the menu took itself down", empty(popup_list()),
    \ "   (" . len(popup_list()) . " popups)")

  " ---- the mouse
  "
  " "test_setmouse" is what lets a case click: it puts the mouse where it says,
  " and "getmousepos()" -- which is what the menu reads -- answers from there.
  call GrooVim_Menu()
  call GT_Ok("setup: the menu is up on F2", GT_MenuSection() ==# "F2", "")

  let [l:text, l:at] = GrooVim_MenuBarText()
  call test_setmouse(1, l:at[2][0] + 2)
  call GrooVim_MenuFilter(GT_MenuDrop(), "\<LeftMouse>")
  call GT_Ok("a click on the bar opens that section", GT_MenuSection() ==# "F4",
    \ "   [" . GT_MenuSection() . "]   (clicked column " . (l:at[2][0] + 2) . ", where F4 is)")

  call test_setmouse(1, l:at[3][0] + 2)
  call GrooVim_MenuFilter(GT_MenuDrop(), "\<LeftMouse>")
  call GT_Ok("  and another click, another section", GT_MenuSection() ==# "F5",
    \ "   [" . GT_MenuSection() . "]")

  " a click on a rule chooses nothing and leaves the menu up
  let l:rule = 0
  for l:i in range(len(g:GrooVim_MenuEntries))
    if get(g:GrooVim_MenuEntries[l:i], "rule", 0) && l:rule == 0
      let l:rule = l:i + 1
    endif
  endfor
  call test_setmouse(popup_getpos(GT_MenuDrop()).core_line + l:rule - 1,
    \ popup_getpos(GT_MenuDrop()).core_col + 2)
  call GrooVim_MenuFilter(GT_MenuDrop(), "\<LeftMouse>")
  call GT_Ok("a click on a rule does nothing", len(popup_list()) == 2,
    \ "   (" . len(popup_list()) . " popups)   (a line across is not a choice)")

  " and a click on an entry runs it
  tabonly!
  let l:which = 0
  for l:i in range(len(g:GrooVim_MenuEntries))
    if get(g:GrooVim_MenuEntries[l:i], "key", "") ==# "n"
      let l:which = l:i + 1
    endif
  endfor
  call test_setmouse(popup_getpos(GT_MenuDrop()).core_line + l:which - 1,
    \ popup_getpos(GT_MenuDrop()).core_col + 2)
  call GrooVim_MenuFilter(GT_MenuDrop(), "\<LeftMouse>")
  call feedkeys("", "x")
  call GT_Ok("a click on a line runs it", tabpagenr("$") == 2,
    \ "   (tabs " . tabpagenr("$") . ")")
  call GT_Ok("  and the menu took itself down", empty(popup_list()), "")

  " ---- the cursor of the terminal gets out of the way
  "
  " It has no idea a popup is there and goes on blinking wherever it was in the
  " file -- on top of the menu, which is where you are NOT. Vim shows it again
  " after every redraw through "t_ve"; emptying that takes the showing away.
  call GT_Ok("setup: the terminal has a cursor to hide", &t_ve !=# "",
    \ "   [" . strtrans(&t_ve) . "]")
  call GrooVim_Menu()
  call GT_Ok("with the menu up, nothing shows the cursor again", &t_ve ==# "",
    \ "   [" . strtrans(&t_ve) . "]")
  call GrooVim_MenuClose()
  call GT_Ok("and closing it hands the cursor back", &t_ve !=# "",
    \ "   [" . strtrans(&t_ve) . "]")
  call GT_Ok("leaving GrooVim hands it back too",
    \ execute("autocmd GrooVim_MenuCursor VimLeavePre") =~ "GrooVim_MenuClose",
    \ "   (or your shell would come back with no cursor in it)")

  " ---- F10 closes it as well as opens it
  "
  " While the menu is up every key goes to the filter and the mapping never runs,
  " so the toggle has to be handled there.
  call GrooVim_Menu()
  call GT_Ok("setup: the menu is up", len(popup_list()) == 2, "   (" . len(popup_list()) . ")")
  call GrooVim_MenuFilter(GT_MenuDrop(), "\<F10>")
  call GT_Ok("F10 again closes it", empty(popup_list()), "   (" . len(popup_list()) . " popups)")

  " ---- Esc does not wait for a whole second
  "
  " A terminal sends an arrow or an F key beginning with the very same "Esc", so
  " Vim waits to see whether more is coming. With no "ttimeoutlen" set that wait
  " is "timeoutlen" -- a second, with "^[" sitting in the corner.
  call GT_Ok("the wait for the rest of a key is short", &ttimeout && &ttimeoutlen <= 200,
    \ "   (ttimeout=" . &ttimeout . " ttimeoutlen=" . &ttimeoutlen . ")")
  call GT_Ok("  and it is not the wait for the second key of a shortcut",
    \ g:GrooVim_CommandZWait >= 1000,
    \ "   (" . g:GrooVim_CommandZWait . "ms, a hand travelling)")

  " ---- the colours
  call GT_Ok("the menu is light and the text on it is dark",
    \ synIDattr(synIDtrans(hlID("GrooVimMenu")), "bg", "gui") ==# "#eff0f1" &&
    \ synIDattr(synIDtrans(hlID("GrooVimMenu")), "fg", "gui") ==# "#232629",
    \ "   (" . synIDattr(synIDtrans(hlID("GrooVimMenu")), "fg", "gui") . " on " .
    \ synIDattr(synIDtrans(hlID("GrooVimMenu")), "bg", "gui") . ")")
  call GT_Ok("the keys are the blue one",
    \ synIDattr(synIDtrans(hlID("GrooVimMenuKey")), "fg", "gui") ==# "#005faf",
    \ "   (" . synIDattr(synIDtrans(hlID("GrooVimMenuKey")), "fg", "gui") . ")")
  call GT_Ok("the chosen line turns the two around",
    \ synIDattr(synIDtrans(hlID("PopupSelected")), "bg", "gui") ==# "#005faf" &&
    \ synIDattr(synIDtrans(hlID("PopupSelected")), "fg", "gui") ==# "#eff0f1",
    \ "   (" . synIDattr(synIDtrans(hlID("PopupSelected")), "fg", "gui") . " on " .
    \ synIDattr(synIDtrans(hlID("PopupSelected")), "bg", "gui") . ")")
  call GT_Ok("and in a terminal the blue is the colour numbered 25, exactly",
    \ synIDattr(synIDtrans(hlID("GrooVimMenuKey")), "fg", "cterm") ==# "25", "")
  call GT_Ok("the menu is painted apart from the document",
    \ synIDattr(synIDtrans(hlID("GrooVimMenu")), "bg") !=# "" &&
    \ synIDattr(synIDtrans(hlID("GrooVimMenuKey")), "fg") !=#
    \ synIDattr(synIDtrans(hlID("GrooVimMenu")), "fg"),
    \ "   (menu bg " . synIDattr(synIDtrans(hlID("GrooVimMenu")), "bg") .
    \ ", keys fg " . synIDattr(synIDtrans(hlID("GrooVimMenuKey")), "fg") . ")")
  call GT_Ok("the line you are on is the blue one",
    \ synIDattr(synIDtrans(hlID("PopupSelected")), "bg") !=#
    \ synIDattr(synIDtrans(hlID("GrooVimMenu")), "bg"),
    \ "   (selected bg " . synIDattr(synIDtrans(hlID("PopupSelected")), "bg") . ")")

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
