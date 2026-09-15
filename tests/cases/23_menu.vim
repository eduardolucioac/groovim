" The menu, written out of the same list the help is.
"
" Two levels: the four groups, and then what is inside one. Choosing an entry
" presses the keys of the shortcut -- nothing in the menu knows what any of them
" does, so it can never do something different from the keyboard.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

func! GT_Body()
  call GT_Ok("this Vim has popup windows", has("popupwin"), "")
  call GT_Ok("F10 opens the menu in the three modes",
    \ maparg("<F10>", "n") =~ "GrooVim_Menu" && maparg("<F10>", "i") =~ "GrooVim_Menu" &&
    \ maparg("<F10>", "v") =~ "GrooVim_Menu", "   [" . maparg("<F10>", "n") . "]")

  " ---- the lines come from the list, and carry no help markup
  call GT_Ok("a plain letter reads as itself",
    \ GrooVim_MenuLine({"key": "s", "what": "Save to disk"}) ==# "  s      Save to disk",
    \ "   [" . GrooVim_MenuLine({"key": "s", "what": "Save to disk"}) . "]")
  call GT_Ok("a named key gets its capital back",
    \ GrooVim_MenuLine({"key": "up", "what": "Changes to uppercase"}) =~ "^  Up ",
    \ "   [" . GrooVim_MenuLine({"key": "up", "what": "Changes to uppercase"}) . "]")
  call GT_Ok("the bars of the help become a space",
    \ GrooVim_ShortcutPlain("Opens the file|.vimrc|") ==# "Opens the file .vimrc",
    \ "   [" . GrooVim_ShortcutPlain("Opens the file|.vimrc|") . "]")
  call GT_Ok("  and not nothing, which would glue the words",
    \ GrooVim_ShortcutPlain("Reloads the file|.vimrc|in all tabs")
    \ ==# "Reloads the file .vimrc in all tabs",
    \ "   [" . GrooVim_ShortcutPlain("Reloads the file|.vimrc|in all tabs") . "]")
  call GT_Ok("the stars go too",
    \ GrooVim_ShortcutPlain("Opens/closes the *NERDTree*") ==# "Opens/closes the NERDTree",
    \ "   [" . GrooVim_ShortcutPlain("Opens/closes the *NERDTree*") . "]")

  " ---- nothing in the menu carries markup any more
  let l:littered = []
  for l:one in g:GrooVim_Shortcuts
    if GrooVim_MenuLine(l:one) =~ '[|*]'
      call add(l:littered, l:one.group . "->" . l:one.key)
    endif
  endfor
  call GT_Ok("no menu line has help markup left in it", empty(l:littered),
    \ "   " . (empty(l:littered) ? "(" . len(g:GrooVim_Shortcuts) . " lines)" : string(l:littered)))

  " ---- the keys a shortcut is made of
  call GT_Ok("a letter: the F key and the letter",
    \ GrooVim_ShortcutKeys({"group": "F5", "key": "s"}) ==# "\<F5>s",
    \ "   [" . strtrans(GrooVim_ShortcutKeys({"group": "F5", "key": "s"})) . "]")
  call GT_Ok("a named key: the F key and the real key code",
    \ GrooVim_ShortcutKeys({"group": "F2", "key": "up"}) ==# "\<F2>\<Up>",
    \ "   [" . strtrans(GrooVim_ShortcutKeys({"group": "F2", "key": "up"})) . "]")
  call GT_Ok("punctuation too",
    \ GrooVim_ShortcutKeys({"group": "F5", "key": "."}) ==# "\<F5>.",
    \ "   [" . strtrans(GrooVim_ShortcutKeys({"group": "F5", "key": "."})) . "]")

  " ---- opening it, and the first level
  call GrooVim_Menu()
  call GT_Ok("F10 opened a popup", !empty(popup_list()), "   (" . len(popup_list()) . ")")
  let l:id = popup_list()[0]
  let l:lines = getbufline(winbufnr(l:id), 1, "$")
  call GT_Ok("the first level is the four groups", len(l:lines) == 4,
    \ "   " . string(map(copy(l:lines), 'trim(v:val)')))
  call GT_Ok("  and each line names its group and what it holds",
    \ l:lines[0] =~ "F2" && l:lines[0] =~ "FILE" && l:lines[3] =~ "F5", "")
  call popup_close(l:id)

  " ---- choosing a group opens the second level
  call GrooVim_MenuGroupChosen(0, 4)
  call GT_Ok("choosing F5 opened its menu", !empty(popup_list()), "")
  let l:id = popup_list()[0]
  let l:lines = getbufline(winbufnr(l:id), 1, "$")
  call GT_Ok("with one line per key of the group",
    \ len(l:lines) == len(g:GrooVim_MenuEntries) &&
    \ len(l:lines) == len(filter(copy(g:GrooVim_Shortcuts), 'v:val.group ==# "F5"')),
    \ "   (" . len(l:lines) . " lines)")
  call GT_Ok("  starting with the first key of the list", l:lines[0] =~ "Save to disk", "   [" . trim(l:lines[0]) . "]")
  call popup_close(l:id)

  " ---- and choosing an entry presses the keys
  tabonly!
  exec "edit " . g:GT_FIX . "/a.txt"
  call GT_Ok("setup: one tab", tabpagenr("$") == 1, "")
  call GrooVim_MenuGroupChosen(0, 4)
  call popup_close(popup_list()[0])
  let l:which = 0
  for l:i in range(len(g:GrooVim_MenuEntries))
    if g:GrooVim_MenuEntries[l:i].key ==# "n"
      let l:which = l:i + 1
    endif
  endfor
  call GT_Ok("found \"open a new tab\" in the F5 menu", l:which > 0, "   (line " . l:which . ")")
  let g:GrooVim_CommandZMoment = 0
  call GrooVim_MenuEntryChosen(0, l:which)
  call feedkeys("", "x")
  call GT_Ok("choosing it opened a tab, like pressing F5 and then n",
    \ tabpagenr("$") == 2, "   (tabs " . tabpagenr("$") . ")")

  " ---- leaving without choosing does nothing
  let l:before = tabpagenr("$")
  call GrooVim_MenuGroupChosen(0, -1)
  call GrooVim_MenuEntryChosen(0, -1)
  call GT_Ok("leaving the menu does nothing at all", tabpagenr("$") == l:before,
    \ "   (tabs " . tabpagenr("$") . ")")

  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
