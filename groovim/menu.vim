" Note: The menu, written out of the same list the help is.
"
" Note: A BAR across the top with the four groups on it, and under the one you
" are on, what it holds -- the shape of the menu of Notepad++ and of the
" "vim-quickui" plugin. Left and Right walk the bar, Up and Down the list, Enter
" picks and Esc leaves. Pressing the F key of a section jumps straight to it,
" which is the same key that runs its shortcuts. The mouse works everywhere: a
" click on the bar opens a section, a click on a line runs it.
"
" Note: Two popups and not one: the bar stays put while the list under it is
" thrown away and built again at every step sideways.
"
" Note: Choosing an entry PRESSES THE KEYS. Nothing here knows what any shortcut
" does, only which two keys to send, so the menu can never do something different
" from the keyboard -- and the shortcut shown on the right of every line is the
" one it will press.
let g:GrooVim_MenuEntries = []
let s:menuBar = 0
let s:menuDrop = 0
let s:menuSection = 0
let s:menuLine = 1

" Note: Raised while a step sideways throws the old list away.
"
" Note: Closing a popup makes Vim call its callback, and a list closed to make
" room for the next one answers "-1" -- which is the very same answer as leaving
" the menu with Esc. Without this flag, walking sideways would take the bar down
" with it.
let s:menuSwitching = 0

" Note: What the terminal was told about showing the cursor, kept while the menu
" is up.
let s:menuCursorWas = ""

" Note: The colours of the menu. Four and not one: the menu itself, the line you
" are on, the keys on the right, and the rules between blocks.
"
" Note: LIGHT, and dark under it -- a menu of a conventional editor stands out
" from the document, it does not blend into it. That is how Notepad++ draws its
" own, and it is where these values come from.
"
" Note: Measured, every pair of them: near black on near white is 13.3 to 1, and
" the blue of the keys against the same white, and the white of the chosen line
" against that blue, are 5.7 to 1. Nothing here is under the 4.5 that counts as
" readable.
"
" Note: In a terminal of 256 colours "#005faf" IS the colour numbered 25, exactly
" and not nearly; the other two land on the nearest greys there are.
"
" Note: "PopupSelected" is the name VIM reads for the line you are on inside a
" popup -- there is no per popup option for it.
if &t_Co >= 256 || has("gui_running")
  highlight GrooVimMenu ctermbg=255 ctermfg=235 guibg=#eff0f1 guifg=#232629
  highlight GrooVimMenuKey ctermbg=255 ctermfg=25 guibg=#eff0f1 guifg=#005faf
  highlight GrooVimMenuRule ctermbg=255 ctermfg=235 guibg=#eff0f1 guifg=#232629
  highlight PopupSelected ctermbg=25 ctermfg=255 cterm=bold
   \ guibg=#005faf guifg=#eff0f1 gui=bold
else
  highlight GrooVimMenu ctermbg=white ctermfg=black
  highlight GrooVimMenuKey ctermbg=white ctermfg=blue
  highlight GrooVimMenuRule ctermbg=white ctermfg=black
  highlight PopupSelected ctermbg=blue ctermfg=white cterm=bold
endif

" Note: Whether the key that was pressed is the key of this shortcut.
"
" Note: "getchar()" hands over a NUMBER for a plain key and a STRING for a named
" one, which is why the two are asked about differently. It is the same split the
" list itself carries: "h" against "up".
func! GrooVim_ShortcutIsKey(pressed, key) abort

  let l:named = {"up": "\<Up>", "down": "\<Down>", "end": "\<End>",
   \ "del": "\<Del>", "left": "\<Left>", "right": "\<Right>",
   \ "home": "\<Home>", "insert": "\<Insert>"}

  if has_key(l:named, a:key)
    return ("" . a:pressed . "") ==# l:named[a:key]
  endif

  return ("" . a:pressed . "") ==# ("" . char2nr(a:key) . "")
endfunc

" Note: Is this shortcut something this GrooVim can actually do?
"
" Note: A shortcut whose work belongs to a plugin only exists when the plugin
" does. The entry says which switch answers for it, and everything that reads
" the list -- the menu, the help of F9 and the dispatch -- asks here first.
"
" Note: This is what a machine with no plugins taught: the entry for the
" NERDTree was written down with no condition on it, while the function behind
" it lives inside "if g:enable_nerdtree_vim". Pressing F4->n there did not say
" the plugin was missing, it said "E117: Unknown function".
func! GrooVim_ShortcutAvailable(one) abort
  return !has_key(a:one, "needs") || get(g:, a:one.needs.switch, 0)
endfunc

" Note: The F groups that have anything left in them here. A group whose every
" shortcut belongs to a plugin that is not installed would otherwise be a
" heading over nothing in the help, and an empty menu to open.
func! GrooVim_MenuSectionsHere() abort
  let l:out = []
  for l:section in g:GrooVim_MenuSections
    for l:one in g:GrooVim_Shortcuts
      if l:one.where ==# l:section[0] && GrooVim_ShortcutAvailable(l:one)
        call add(l:out, l:section)
        break
      endif
    endfor
  endfor
  return l:out
endfunc

" Note: Runs what the shortcut says to run.
"
" Note: "run" is one line of VimScript, or a handful of them keyed by the modes
" each belongs to -- uppercase is one thing on a word and another on a selection.
" Inside them "l:mode" is the mode you are in, which is why it is a name and not
" an argument.
func! GrooVim_ShortcutRun(one, mode) abort

  let l:mode = a:mode

  if type(a:one.run) != type({})
    exec a:one.run
    return
  endif

  for l:where in keys(a:one.run)
    if stridx(l:where, a:mode) >= 0
      exec a:one.run[l:where]
      return
    endif
  endfor

endfunc

" Note: The two keys a shortcut is made of, ready to be pressed: the F key and
" then the letter -- or the real key code, for the ones that are not letters! By
" Questor
func! GrooVim_ShortcutKeys(one) abort

  " Note: A key of its own -- "<C-c>", "<A-S-Up>", "m" -- and not a pair of an F
  " key and a letter. Written the way Vim writes a key, so that what the menu
  " feeds is what the keyboard would have sent.
  if has_key(a:one, "keys")
    return a:one.keys =~ "^<" ? eval('"\' . a:one.keys . '"') : a:one.keys
  endif

  let l:named = {"up": "Up", "down": "Down", "end": "End", "del": "Del",
   \ "left": "Left", "right": "Right", "home": "Home", "insert": "Insert"}
  let l:second = has_key(l:named, a:one.key)
   \ ? eval('"\<' . l:named[a:one.key] . '>"') : a:one.key
  return eval('"\<' . a:one.group . '>"') . l:second

endfunc

" Note: How a shortcut is written for a human: "F5->n", the notation every
" message of GrooVim uses.
" Note: How a key is written where somebody reads it: "F2->c", "Ctrl+C",
" "Alt+Shift+Up", "m".
"
" Note: Built from the key itself and not written by hand beside it. A label
" typed into each entry is a second place for the same fact, and the day a key
" moves the label stays.
func! GrooVim_ShortcutShown(one) abort

  if has_key(a:one, "keys")
    if a:one.keys !~ "^<"
      return a:one.keys
    endif
    if a:one.keys ==# "<2-Leftmouse>"
      return "Double click"
    endif
    let l:text = substitute(a:one.keys, '^<\|>$', "", "g")
    let l:text = substitute(l:text, '^C-A-', "Ctrl+Alt+", "")
    let l:text = substitute(l:text, '^C-S-', "Ctrl+Shift+", "")
    let l:text = substitute(l:text, '^A-S-', "Alt+Shift+", "")
    let l:text = substitute(l:text, '^C-', "Ctrl+", "")
    let l:text = substitute(l:text, '^A-', "Alt+", "")
    let l:text = substitute(l:text, '^S-', "Shift+", "")
    " Note: A lone letter after a modifier is shown as a capital, the way every
    " keyboard is painted: "Ctrl+c" is read as "Ctrl" and then "c", which is not
    " a key anybody has.
    return substitute(l:text, '\(+\)\(\a\)$', '\1\u\2', "")
  endif

  let l:named = {"up": "Up", "down": "Down", "end": "End", "del": "Del"}
  return a:one.group . "->" . get(l:named, a:one.key, a:one.key)

endfunc

" Note: The same words without the marks the help syntax of Vim needs. A "|" and
" a "*" mean "highlight this" in a help file and mean nothing in a popup, where
" they would just be litter -- "Opens the file|.vimrc|" reads badly enough on a
" menu line.
"
" Note: The bars become a SPACE and not nothing: in the help they are what
" separates the word from the text around it, so dropping them would glue
" "file.vimrc" together.
func! GrooVim_ShortcutPlain(text) abort
  let l:plain = substitute(a:text, '[|*]', " ", "g")
  return trim(substitute(l:plain, '  \+', " ", "g"))
endfunc

" Note: One line of a section: what it does on the left, the keys that do it on
" the right, the way a menu of a conventional editor shows them.
"
" Note: "room" is how much the description may take. On a narrow terminal the
" line would otherwise run past the edge and it is the RIGHT side that is lost --
" which is the shortcut, the one thing a menu of a keyboard editor is for! By
" Questor
" Note: What a line of the menu READS. It is not the description: that one
" explains, and is what the help of F9 and the README are written from, while
" this one NAMES -- "Save as..." against "Saves under another name and goes on
" editing THAT one".
"
" Note: The two go together and neither is the other cut short: a menu of a
" conventional editor is a column of names, and the three dots at the end of one
" are the convention that says it will ask you something.
func! GrooVim_ShortcutMenu(one) abort
  return GrooVim_ShortcutPlain(get(a:one, "menu", a:one.what))
endfunc

func! GrooVim_MenuLine(one, room) abort
  let l:what = GrooVim_ShortcutMenu(a:one)
  if strchars(l:what) > a:room
    let l:what = strcharpart(l:what, 0, a:room - 1) . "…"
  endif
  return "  " . l:what . repeat(" ", a:room - strchars(l:what) + 4) .
   \ GrooVim_ShortcutShown(a:one) . "  "
endfunc

" Note: The shortcuts of one section, how much room the descriptions may take,
" and how wide the whole thing comes out.
func! GrooVim_MenuOf(group, startColumn) abort

  let l:entries = []
  let l:what = 0
  let l:keys = 0
  for l:one in g:GrooVim_Shortcuts
    if l:one.where ==# a:group && GrooVim_ShortcutAvailable(l:one)
      call add(l:entries, l:one)
      let l:what = max([l:what, strchars(GrooVim_ShortcutMenu(l:one))])
      let l:keys = max([l:keys, strchars(GrooVim_ShortcutShown(l:one))])
    endif
  endfor

  " Note: 2 borders, 2 in front, 4 between the two columns, 2 behind.
  let l:around = 10 + l:keys
  let l:room = min([l:what, &columns - a:startColumn - l:around + 1])
  return [l:entries, max([l:room, 10]), l:room + l:around]
endfunc

" Note: The bar, and where on it each section begins -- the popup needs the
" column to put itself under the right one, and the mouse needs it to know which
" one was clicked.
func! GrooVim_MenuBarText() abort
  let l:text = ""
  let l:at = []
  for l:group in GrooVim_MenuSectionsHere()
    " Note: The name of the section and nothing else. It used to be " F2 Edit ",
    " which taught that F2 was Edit -- and could, because a section WAS an F key.
    " A section holds keys of every shape now, and each line under it carries the
    " keys that do it.
    let l:piece = " " . l:group[0] . " "
    call add(l:at, [strchars(l:text) + 1, strchars(l:piece)])
    let l:text = l:text . l:piece
  endfor
  return [l:text, l:at]
endfunc

func! GrooVim_MenuPaintBar() abort
  let [l:text, l:at] = GrooVim_MenuBarText()
  let l:here = l:at[s:menuSection]
  call popup_settext(s:menuBar, [{"text": l:text,
   \ "props": [{"col": l:here[0], "length": l:here[1], "type": "GrooVimMenuOn"}]}])
endfunc

" Note: The names the colours are painted through. "prop_type_add" throws when
" the name is already there, which it is the second time you open the menu! By
" Questor
func! GrooVim_MenuColours() abort
  for l:pair in [["GrooVimMenuOn", "PopupSelected"],
   \ ["GrooVimMenuKey", "GrooVimMenuKey"], ["GrooVimMenuRule", "GrooVimMenuRule"]]
    try
      call prop_type_add(l:pair[0], {"highlight": l:pair[1]})
    catch
    endtry
  endfor
endfunc

func! GrooVim_Menu() abort

  if !has("popupwin") || !exists("*prop_type_add")
    call GrooVim_GrooVimBarMsg("This Vim has no popup windows! Use F9 for the help!", 6)
    return
  endif

  call GrooVim_MenuColours()
  call GrooVim_MenuClose()

  call GrooVim_MenuHideCursor()

  let [l:text, l:at] = GrooVim_MenuBarText()
  let s:menuBar = popup_create([l:text], {"line": 1, "col": 1,
   \ "highlight": "GrooVimMenu", "zindex": 100})

  let s:menuSection = 0
  call GrooVim_MenuOpen(0)

endfunc

" Note: The cursor of the terminal has no idea a popup is there and goes on
" blinking wherever it was in the file -- ON TOP of the menu, which is where you
" are NOT.
"
" Note: Vim hides the cursor before a redraw with "t_vi" and shows it again after
" with "t_ve". Emptying "t_ve" takes the showing away, so the next redraw hides it
" and nothing brings it back until the string is handed over again.
func! GrooVim_MenuHideCursor() abort
  if s:menuCursorWas ==# ""
    let s:menuCursorWas = &t_ve
    set t_ve=
    redraw
  endif
endfunc

" Note: "echoraw" writes the string to the TERMINAL, which is what actually
" brings the cursor back. Handing "t_ve" over again is only half of it: on the
" way out there is no redraw left to emit it, and GrooVim would give you your
" shell back with no cursor in it.
func! GrooVim_MenuShowCursor() abort
  if s:menuCursorWas !=# ""
    let &t_ve = s:menuCursorWas
    let s:menuCursorWas = ""
    if exists("*echoraw")
      call echoraw(&t_ve)
    endif
    redraw
  endif
endfunc

" Note: And whatever happens, the cursor goes back before GrooVim does.
"
" Note: Leaving with the menu still up handed the terminal back with the cursor
" HIDDEN -- measured, the last thing it was told was "hide" and nothing ever said
" otherwise. You would have got your shell prompt back with no cursor in it, and
" nothing to tell you why.
" Note: "VimLeavePre" and not "VimLeave": the cursor comes back through a redraw,
" and by "VimLeave" there is no drawing left to do -- measured, leaving with the
" menu up ended on "hide" while leaving without it ended on "show".
augroup GrooVim_MenuCursor
  autocmd!
  autocmd VimLeavePre * call GrooVim_MenuClose()
augroup END

" Note: Opens the section, wrapping round at either end the way a menu bar does.
func! GrooVim_MenuOpen(section) abort

  let l:groups = GrooVim_MenuSectionsHere()
  let l:count = len(l:groups)
  let s:menuSection = (a:section + l:count) % l:count
  let l:group = l:groups[s:menuSection]

  let [l:barText, l:at] = GrooVim_MenuBarText()
  let l:startColumn = l:at[s:menuSection][0]

  let [l:entries, l:room, l:width] = GrooVim_MenuOf(l:group[0], l:startColumn)

  " Note: Pulled left when it would hang off the edge of the screen, which is
  " what a menu bar does with its last section.
  let l:column = min([l:startColumn, max([1, &columns - l:width + 1])])

  " Note: The rules between blocks of items are LINES of the popup like any
  " other, so the list kept here has one place per line -- a rule included. A
  " line number is the only thing the mouse and the callback ever hand over, and
  " it has to land on the right shortcut.
  let g:GrooVim_MenuEntries = []
  let l:lines = []
  let l:widest = 0
  for l:one in l:entries
    if get(l:one, "break", 0) && !empty(l:lines)
      call add(g:GrooVim_MenuEntries, {"rule": 1})
      call add(l:lines, "")
    endif
    call add(g:GrooVim_MenuEntries, l:one)
    let l:line = GrooVim_MenuLine(l:one, l:room)
    let l:widest = max([l:widest, strchars(l:line)])
    call add(l:lines, l:line)
  endfor

  let l:painted = []
  for l:at2 in range(len(l:lines))
    if l:lines[l:at2] ==# ""
      call add(l:painted, {"text": repeat("─", l:widest),
       \ "props": [{"col": 1, "length": strlen(repeat("─", l:widest)),
       \ "type": "GrooVimMenuRule"}]})
      continue
    endif
    let l:shown = GrooVim_ShortcutShown(g:GrooVim_MenuEntries[l:at2])
    call add(l:painted, {"text": l:lines[l:at2], "props": [{
     \ "col": strchars(l:lines[l:at2]) - strchars(l:shown) - 1,
     \ "length": strchars(l:shown), "type": "GrooVimMenuKey"}]})
  endfor

  call GrooVim_MenuPaintBar()

  if s:menuDrop > 0
    let s:menuSwitching = 1
    call popup_close(s:menuDrop, -1)
    let s:menuSwitching = 0
  endif

  " Note: "popup_create" and not "popup_menu": the second one puts itself in the
  " MIDDLE of the screen and ignores where it was told to go -- measured, asked
  " for line 2 and it came out on line 5.
  let s:menuDrop = popup_create(l:painted, {
   \ "line": 2, "col": l:column, "pos": "topleft",
   \ "title": " " . l:group[0] . " ",
   \ "border": [], "padding": [0,0,0,0], "cursorline": 1,
   \ "highlight": "GrooVimMenu", "zindex": 101, "mapping": 0,
   \ "filter": "GrooVim_MenuFilter", "callback": "GrooVim_MenuEntryChosen"})

  let s:menuLine = 0
  call GrooVim_MenuStep(1)

  " Note: A step sideways throws a list away and puts a narrower one up, and Vim
  " redraws only what changed.
  redraw

endfunc

" Note: Moves down or up, STEPPING OVER the rules: they are lines of the popup
" but they are not choices.
func! GrooVim_MenuStep(step) abort

  let l:total = len(g:GrooVim_MenuEntries)
  if l:total == 0
    return
  endif

  let l:line = s:menuLine
  for l:tries in range(l:total)
    let l:line = l:line + a:step
    if l:line < 1
      let l:line = l:total
    elseif l:line > l:total
      let l:line = 1
    endif
    if !get(g:GrooVim_MenuEntries[l:line - 1], "rule", 0)
      break
    endif
  endfor

  let s:menuLine = l:line
  call win_execute(s:menuDrop, "call cursor(" . s:menuLine . ", 1)")

  " Note: And the list is scrolled to where the cursor went.
  "
  " Note: A popup does NOT follow its cursor the way a window does: moving it
  " with "win_execute" leaves what is shown exactly where it was. Measured, on a
  " screen of 24 lines with a section of 30 entries: thirty four steps down and
  " the first line shown was still the first line of the list -- everything past
  " the twenty third was out of reach, on a menu whose whole point is to show
  " what there is.
  "
  " Note: "core_height" and not "height": the border and the padding are not
  " lines of the list.
  let l:pos = popup_getpos(s:menuDrop)
  if !empty(l:pos)
    if s:menuLine < l:pos.firstline
      call popup_setoptions(s:menuDrop, {"firstline": s:menuLine})
    elseif s:menuLine >= l:pos.firstline + l:pos.core_height
      call popup_setoptions(s:menuDrop,
       \ {"firstline": s:menuLine - l:pos.core_height + 1})
    endif
  endif

endfunc

" Note: Left and Right walk the bar, an F key jumps to its own section, the mouse
" clicks where it likes, and the rest is what a menu does.
" Note: Which F key was pressed, if it was one.
func! GrooVim_MenuFKeyPressed(key) abort
  for l:fKey in ["F2", "F3", "F4", "F5"]
    if a:key ==# eval('"\<' . l:fKey . '>"')
      return l:fKey
    endif
  endfor
  return ""
endfunc

" Note: The section that F key has most of its shortcuts in -- counted and not
" written down, so that moving a shortcut from one section to another moves this
" with it.
func! GrooVim_MenuSectionOfFKey(fKey) abort
  let l:count = {}
  for l:one in g:GrooVim_Shortcuts
    if get(l:one, "group", "") !=# a:fKey || !GrooVim_ShortcutAvailable(l:one)
      continue
    endif
    let l:count[l:one.where] = get(l:count, l:one.where, 0) + 1
  endfor
  " Note: Walked in the order of the sections and not in the order of the keys of
  " a dictionary, which Vim does not promise -- a draw has to fall the same way
  " every time.
  let l:best = ""
  for l:where in map(copy(g:GrooVim_MenuSections), 'v:val[0]')
    if !has_key(l:count, l:where) | continue | endif
    if l:best ==# "" || l:count[l:where] > l:count[l:best]
      let l:best = l:where
    endif
  endfor
  return l:best
endfunc

func! GrooVim_MenuFilter(id, key) abort

  if a:key ==# "\<Left>"
    call GrooVim_MenuOpen(s:menuSection - 1)
    return 1
  endif
  if a:key ==# "\<Right>"
    call GrooVim_MenuOpen(s:menuSection + 1)
    return 1
  endif
  if a:key ==# "\<Down>" || a:key ==# "j"
    call GrooVim_MenuStep(1)
    return 1
  endif
  if a:key ==# "\<Up>" || a:key ==# "k"
    call GrooVim_MenuStep(-1)
    return 1
  endif
  if a:key ==# "\<CR>" || a:key ==# " "
    call popup_close(a:id, s:menuLine)
    return 1
  endif
  " Note: "F10" closes it as well as opens it. While the menu is up every key
  " comes HERE and the mapping never runs, so the toggle has to live in the
  " filter.
  if a:key ==# "\<Esc>" || a:key ==# "x" || a:key ==# "q" || a:key ==# "\<F10>"
    call popup_close(a:id, -1)
    return 1
  endif

  " Note: An F key opens the section where that F key mostly lives.
  "
  " Note: It used to open the section OF that key, and could, because a section
  " was an F key. Now a section holds keys of every shape and an F key is spread
  " over several of them -- so what is kept is the hand: F2 lands on "Edit", F3
  " on "Search", F4 on "View", F5 on "File", which is where each one has most of
  " its shortcuts and is what the four used to be called.
  let l:fKey = GrooVim_MenuFKeyPressed(a:key)
  if l:fKey !=# ""
    let l:where = GrooVim_MenuSectionOfFKey(l:fKey)
    let l:which = index(map(copy(GrooVim_MenuSectionsHere()), 'v:val[0]'), l:where)
    if l:which >= 0
      call GrooVim_MenuOpen(l:which)
      return 1
    endif
  endif

  " Note: The mouse. A click on the bar opens that section, a click on a line
  " runs it, and a click anywhere else leaves -- which is what clicking outside a
  " menu does in every editor.
  if a:key ==# "\<LeftMouse>"
    return GrooVim_MenuClicked(a:id)
  endif
  if a:key ==# "\<LeftRelease>" || a:key ==# "\<LeftDrag>"
    return 1
  endif

  return 1
endfunc

func! GrooVim_MenuClicked(id) abort

  let l:where = getmousepos()

  if l:where.winid == s:menuDrop
    if get(g:GrooVim_MenuEntries[l:where.line - 1], "rule", 0)
      return 1
    endif
    call popup_close(a:id, l:where.line)
    return 1
  endif

  if l:where.winid == s:menuBar
    let [l:text, l:at] = GrooVim_MenuBarText()
    let l:which = 0
    for l:one in l:at
      if l:where.wincol >= l:one[0] && l:where.wincol < l:one[0] + l:one[1]
        call GrooVim_MenuOpen(l:which)
        return 1
      endif
      let l:which = l:which + 1
    endfor
    return 1
  endif

  call popup_close(a:id, -1)
  return 1
endfunc

func! GrooVim_MenuClose() abort
  call GrooVim_MenuShowCursor()
  if s:menuDrop > 0
    let s:menuSwitching = 1
    call popup_close(s:menuDrop, -1)
    let s:menuSwitching = 0
    let s:menuDrop = 0
  endif
  if s:menuBar > 0
    call popup_close(s:menuBar)
    let s:menuBar = 0
  endif
endfunc

func! GrooVim_MenuEntryChosen(id, chosen) abort

  " Note: A step sideways closed the old list, and this is only its echo! By
  " Questor
  if s:menuSwitching
    return
  endif

  let s:menuDrop = 0

  " Note: Vim answers "-1" when the menu was left without choosing. The bar has
  " to come down too, or Esc would leave it sitting on the first line with
  " nothing under it.
  if a:chosen < 1 || a:chosen > len(g:GrooVim_MenuEntries)
     \ || get(g:GrooVim_MenuEntries[a:chosen - 1], "rule", 0)
    call GrooVim_MenuClose()
    return
  endif

  call GrooVim_MenuClose()

  " Note: "t" and not "x": the keys go into the typeahead and the CommandZ reads
  " them the way it reads yours. Running the command here would need this to know
  " what each shortcut does, which is the one thing a menu must not know! By
  " Questor
  call feedkeys(GrooVim_ShortcutKeys(g:GrooVim_MenuEntries[a:chosen - 1]), "t")

endfunc

nnoremap <silent> <script> <F10> :call GrooVim_Menu()<cr>
inoremap <silent> <script> <F10> <C-o>:call GrooVim_Menu()<cr>
vnoremap <silent> <script> <F10> :<C-u>call GrooVim_Menu()<cr>


