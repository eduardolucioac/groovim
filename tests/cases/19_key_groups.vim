" The list of shortcuts is the only place a shortcut lives, and this is what
" guards that the list itself holds together.
"
" An entry is of one of two shapes: an F key, which carries "group" and "key"
" and the line to "run", or a key pressed straight -- Ctrl+C, Alt+Shift+Up, "n"
" -- which carries "keys" and is mapped elsewhere, the list only saying it is
" there. Both carry "where", the section of the menu they show under.
"
" There used to be three hundred lines of "if the key is this, do that" beside
" the list the help is written from, and every shortcut lived in both. They
" drifted: keys that moved group went on answering under the old one, and the
" help named letters that had been retired. Now the list is the only place, and
" what this case guards is that the list itself holds together.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

" Note: Only the F key entries have a "group": the ones pressed straight do not
" belong to any F key, so the key has to be ASKED for and not read! By Questor
func! GT_Of(group)
  return filter(copy(g:GrooVim_Shortcuts),
    \ 'get(v:val, "group", "") ==# "' . a:group . '"')
endfunc

func! GT_FKeys()
  return filter(copy(g:GrooVim_Shortcuts), 'has_key(v:val, "group")')
endfunc

func! GT_Body()
  let l:path = $GROOVIM_TEST_VIMRC
  let l:source = GT_SourceLines()
  call GT_Ok("we can read the source of GrooVim", filereadable(l:path), "   [" . l:path . "]")
  call GT_Ok("  and the parts it loads", len(l:source) > 5000,
    \ "   (" . len(glob(fnamemodify(l:path, ":h") . "/groovim/*.vim", 0, 1)) . " parts, " .
    \ len(l:source) . " lines in all)")

  " ---- the list, and the four groups
  call GT_Ok("the list of shortcuts is there",
    \ exists("g:GrooVim_Shortcuts") && len(g:GrooVim_Shortcuts) > 20,
    \ "   (" . len(g:GrooVim_Shortcuts) . " shortcuts)")
  " The sections are what the menu is divided into, and they are not the F keys
  " any more: a section holds keys of every shape, so that the menu shows what
  " GrooVim does and not what the four F keys do.
  call GT_Ok("the sections are there, each with a name and a description",
    \ len(g:GrooVim_MenuSections) >= 5 &&
    \ len(filter(copy(g:GrooVim_MenuSections), 'len(v:val) == 2')) ==
    \   len(g:GrooVim_MenuSections),
    \ "   " . string(map(copy(g:GrooVim_MenuSections), 'v:val[0]')))
  call GT_Ok("and every shortcut belongs to one of them",
    \ empty(filter(copy(g:GrooVim_Shortcuts),
    \ 'index(map(copy(g:GrooVim_MenuSections), "v:val[0]"), v:val.where) < 0')),
    \ "   " . string(filter(map(copy(g:GrooVim_Shortcuts), 'v:val.where'),
    \   'index(map(copy(g:GrooVim_MenuSections), "v:val[0]"), v:val) < 0')))
  call GT_Ok("  and no section is a heading over nothing",
    \ empty(filter(map(copy(g:GrooVim_MenuSections), 'v:val[0]'),
    \   'empty(filter(copy(g:GrooVim_Shortcuts), "v:val.where ==# " . string(v:val)))')),
    \ "   (every one of them has shortcuts under it)")
  call GT_Ok("and the keys pressed straight are on the list too",
    \ len(filter(copy(g:GrooVim_Shortcuts), 'has_key(v:val, "keys")')) > 20,
    \ "   (" . len(GT_FKeys()) . " under an F key, " .
    \ len(filter(copy(g:GrooVim_Shortcuts), 'has_key(v:val, "keys")')) . " pressed straight)")

  " ---- every entry is complete
  let l:short = []
  for l:one in g:GrooVim_Shortcuts
    let l:fields = has_key(l:one, "keys") ? ["where", "keys", "modes", "what"]
     \ : ["where", "group", "key", "modes", "run", "what"]
    for l:field in l:fields
      if !has_key(l:one, l:field)
        call add(l:short, get(l:one, "keys",
         \ get(l:one, "group", "?") . "->" . get(l:one, "key", "?")) .
         \ " has no " . l:field)
      endif
    endfor
  endfor
  call GT_Ok("every shortcut says what it is and what it does", empty(l:short),
    \ "   " . (empty(l:short) ? "(" . len(g:GrooVim_Shortcuts) . " of them)" : string(l:short)))

  " ---- no two of them answer the same key in the same mode
  "
  " The dispatch takes the FIRST that matches and stops, so a second one on the
  " same key and mode would simply never run -- silently.
  let l:twice = []
  let l:seen = {}
  for l:one in g:GrooVim_Shortcuts
    for l:mode in ["n", "i", "v"]
      if stridx(l:one.modes, l:mode) < 0 | continue | endif
      let l:signature = has_key(l:one, "keys") ? l:one.keys . "|" . l:mode
       \ : l:one.group . "|" . l:one.key . "|" . l:mode
      if has_key(l:seen, l:signature) | call add(l:twice, l:signature) | endif
      let l:seen[l:signature] = 1
    endfor
  endfor
  call GT_Ok("no key answers twice in the same section and mode", empty(l:twice),
    \ "   " . (empty(l:twice) ? "(" . len(l:seen) . " key and mode pairs)" : string(l:twice)))

  " ---- and every mode a shortcut claims really has something to run
  "
  " "run" is one line, or a handful keyed by the modes each belongs to. A
  " shortcut that says it answers in visual and whose run has nothing for visual
  " does nothing at all when you press it there, and says nothing about it.
  let l:uncovered = []
  for l:one in g:GrooVim_Shortcuts
    if !has_key(l:one, "run") || type(l:one.run) != type({}) | continue | endif
    for l:mode in ["n", "i", "v"]
      if stridx(l:one.modes, l:mode) < 0 | continue | endif
      let l:found = 0
      for l:where in keys(l:one.run)
        if stridx(l:where, l:mode) >= 0 | let l:found = 1 | endif
      endfor
      if !l:found
        call add(l:uncovered, l:one.group . "->" . l:one.key . " claims " . l:mode)
      endif
    endfor
  endfor
  call GT_Ok("every mode a shortcut claims has something to run", empty(l:uncovered),
    \ "   " . (empty(l:uncovered) ? "" : string(l:uncovered)))

  " ---- the keys are ones the dispatch can recognise
  let l:strange = []
  for l:one in GT_FKeys()
    if !GrooVim_ShortcutIsKey(strchars(l:one.key) == 1 ? char2nr(l:one.key) :
      \ eval('"\<' . toupper(l:one.key[0]) . l:one.key[1:] . '>"'), l:one.key)
      call add(l:strange, l:one.group . "->" . l:one.key)
    endif
  endfor
  call GT_Ok("the dispatch recognises every key of the F groups", empty(l:strange),
    \ "   " . (empty(l:strange) ? "" : string(l:strange)))

  " ---- what the messages send you to has to exist
  let l:named = []
  let l:wrong = []
  for l:line in l:source
    if l:line =~ 'F[2-5]\\\=[">] and then \\\=["<]'
      call add(l:wrong, "old notation: " . trim(l:line)[0:55])
    endif
    let l:at = 0
    while 1
      let l:at = match(l:line, 'F[2-5]->', l:at)
      if l:at < 0 | break | endif
      let l:shortcut = strpart(l:line, l:at, 5)
      let l:at = l:at + 4
      if len(l:shortcut) < 5 | continue | endif
      if index(l:named, l:shortcut) < 0 | call add(l:named, l:shortcut) | endif
      let l:which = strpart(l:shortcut, 0, 2)
      let l:key = tolower(strpart(l:shortcut, 4, 1))
      if empty(filter(GT_Of(l:which), 'v:val.key ==# "' . escape(l:key, '\"') . '"'))
        call add(l:wrong, l:shortcut . " -- no such key in " . l:which)
      endif
    endwhile
  endfor
  call GT_Ok("every shortcut a message names really exists", empty(l:wrong),
    \ empty(l:wrong) ? "   " . string(sort(copy(l:named))) : "   " . string(l:wrong))
  call GT_Ok("  and there are some to check", len(l:named) >= 8, "   (" . len(l:named) . ")")

  " ---- the .vimrc names the parts one by one, and the list IS the map
  "
  " Named and not gathered with a wildcard: the list says what there is, what
  " each one is for, and in which order they load. A part missing from it does
  " not load at all, so this is not about documentation going stale -- it is
  " about code that is there and never runs.
  let l:index = join(readfile(l:path), "\n")
  let l:onDisk = map(glob(fnamemodify(l:path, ":h") . "/groovim/*.vim", 0, 1), 'fnamemodify(v:val, ":t:r")')
  let l:named = []
  for l:line in readfile(l:path)
    let l:hit = matchstr(l:line, '^ \\ \["\zs\w\+\ze",')
    if l:hit != "" | call add(l:named, l:hit) | endif
  endfor
  call GT_Ok("the .vimrc names every part there is",
    \ empty(filter(copy(l:onDisk), 'index(l:named, v:val) < 0')),
    \ "   " . (empty(filter(copy(l:onDisk), 'index(l:named, v:val) < 0'))
    \ ? "(" . len(l:onDisk) . " parts)" : string(filter(copy(l:onDisk), 'index(l:named, v:val) < 0'))))
  call GT_Ok("  and names nothing that is not there",
    \ empty(filter(copy(l:named), 'index(l:onDisk, v:val) < 0')),
    \ "   " . string(filter(copy(l:named), 'index(l:onDisk, v:val) < 0')))
  call GT_Ok("  and says what each one is for",
    \ len(filter(readfile(l:path), 'v:val =~ "^ .\\{-} \\[\"\\w\\+\", *\""')) == len(l:onDisk),
    \ "   (" . len(l:named) . " named, " . len(l:onDisk) . " on disk)")
  call GT_Ok("and no part carries a number glued to its name",
    \ empty(filter(copy(l:onDisk), 'v:val =~ "^[0-9]"')),
    \ "   (the order is in the list, not in the file names)")

  " ---- and the README says what the list says
  "
  " The README kept its own copy of every shortcut and drifted the furthest of
  " all of them: it still listed a layout of three groups, with no F5 at all, and
  " the same letter three times over in one of them. It is written from the list
  " now, and this refuses to pass while the two disagree.
  let l:readme = fnamemodify(l:path, ":h") . "/README.md"
  call GT_Ok("there is a README to check", filereadable(l:readme), "   [" . l:readme . "]")
  if filereadable(l:readme)
    let l:lines = readfile(l:readme)
    let l:from = match(l:lines, "shortcuts: written by")
    let l:to = match(l:lines, "shortcuts: end")
    call GT_Ok("  with a block written from the list",
      \ l:from >= 0 && l:to > l:from, "   (lines " . l:from . ".." . l:to . ")")
    if l:from >= 0 && l:to > l:from
      let l:inFile = l:lines[l:from + 1 : l:to - 1]
      let l:fromList = GrooVim_ShortcutsMarkdown()
      call GT_Ok("  and it says exactly what the list says",
        \ l:inFile ==# l:fromList,
        \ l:inFile ==# l:fromList ? "   (" . len(l:inFile) . " lines)"
        \ : "   (" . len(l:inFile) . " lines in the file, " . len(l:fromList) .
        \ " from the list -- run ./tools/sync-readme.sh)")
    endif
  endif

  " ---- GrooVim knows where its own .vimrc is
  call GT_Ok("GrooVim knows its own .vimrc", filereadable(g:GrooVim_Vimrc),
    \ "   [" . g:GrooVim_Vimrc . "]")
  call GT_Ok("  and it is the one being run",
    \ simplify(fnamemodify(g:GrooVim_Vimrc, ":p")) ==# simplify(fnamemodify(l:path, ":p")), "")
  call GT_Ok("the mapping that reloads it carries the path, not the variable",
    \ maparg("\\zvv", "n") !~ "MYVIMRC" && maparg("\\zvv", "n") =~ "source", "")
  call GT_Ok("and it does not go through a function of its own",
    \ maparg("\\zvv", "n") !~ "call ",
    \ "   (sourcing redefines every function, and Vim refuses one that is RUNNING: E127)")

  " ---- the debugger of 2014 is gone
  call GT_Ok("no debugger left in the source",
    \ !exists("*GrooVim_ToggleDbg") && !exists("g:enable_debugger_vim"), "")
  " F4 is where what OPENS something lives: the tree, and the bookmarks -- lines
  " you mark and then walk between, which is the "Search -> Bookmark" of
  " Notepad++. Every one of them belongs to a plugin, and every one says so.
  call GT_Ok("F4 is the tree and the bookmarks",
    \ map(GT_Of("F4"), 'v:val.key') ==# ["n", "b", "i", "l", "c"],
    \ "   " . string(map(GT_Of("F4"), 'v:val.key')))
  call GT_Ok("  and the one that needs a plugin says so",
    \ len(filter(copy(GT_Of("F4")), 'has_key(v:val, "needs")')) == 1,
    \ "   (the tree; the marks are GrooVim's own code)")

  " ---- where F4 shows, and what its first entry is called
  "
  " Its section was "Plugins" and then "Utils", which said where the code came
  " from instead of what the keys do. It shows under "View" now, beside the tabs
  " and the help -- what is BESIDE the text, which is what the tree and the list
  " of marked lines are.
  call GT_Ok("F4 shows under the section of what is beside the text",
    \ empty(filter(GT_Of("F4"), 'v:val.where !=# "View"')),
    \ "   " . string(map(GT_Of("F4"), 'v:val.key . " " . v:val.where')))
  call GT_Ok("  and the tree by what it is, not by the plugin that draws it",
    \ filter(copy(GT_Of("F4")), 'v:val.key ==# "n"')[0].what =~ "file tree", "")
  call GT_Ok("and the menu divides the tree from the marks",
    \ get(filter(copy(GT_Of("F4")), 'v:val.key ==# "b"')[0], "break", 0) == 1 &&
    \ get(filter(copy(GT_Of("F4")), 'v:val.key ==# "c"')[0], "break", 0) == 0,
    \ "   (the rule comes BEFORE the first mark, not after the last)")

  " The marks have a case of their own now: they are GrooVim's own code and not
  " a plugin any more, so what belongs here is only where their keys live.
  call GT_Ok("and the marks are not a plugin any more",
    \ empty(filter(copy(GT_Of("F4")), 'v:val.key !=# "n" && has_key(v:val, "needs")')),
    \ "   (only the tree still asks for one)")

  " ---- a shortcut whose work belongs to a plugin says so
  "
  " This is the whole of what went wrong on a machine with no plugins: the entry
  " for the tree was written with no condition on it, while the function behind
  " it lives inside "if g:enable_nerdtree_vim". F4->n there did not say the
  " plugin was missing. It said "E117: Unknown function".
  let l:tree = GT_Of("F4")[0]
  call GT_Ok("the tree's shortcut says which plugin it needs",
    \ has_key(l:tree, "needs") && has_key(l:tree.needs, "switch") &&
    \ has_key(l:tree.needs, "name"), "   " . string(get(l:tree, "needs", {})))

  " ---- and every shortcut on offer calls something that is really there
  "
  " The general form of the same defect: an entry may only name functions this
  " Vim has. It is the check that would have caught it here, instead of leaving
  " it for somebody else's machine to find.
  let l:gone = []
  for l:one in g:GrooVim_Shortcuts
    if !GrooVim_ShortcutAvailable(l:one) || !has_key(l:one, "run") | continue | endif
    let l:runs = type(l:one.run) == type({}) ? values(l:one.run) : [l:one.run]
    for l:line in l:runs
      let l:at = 0
      while 1
        let l:name = matchstr(l:line, 'GrooVim_\w\+\ze(', l:at)
        if l:name ==# "" | break | endif
        let l:at = match(l:line, 'GrooVim_\w\+\ze(', l:at) + len(l:name)
        if !exists("*" . l:name)
          call add(l:gone, GrooVim_ShortcutShown(l:one) . " calls " . l:name)
        endif
      endwhile
    endfor
  endfor
  call GT_Ok("every shortcut on offer calls a function that exists", empty(l:gone),
    \ "   " . (empty(l:gone) ? "(all of them)" : string(l:gone)))

  " ---- with the plugin off, the shortcut goes quiet instead of breaking
  call GT_Ok("setup: the battery runs with the tree on", g:enable_nerdtree_vim == 1,
    \ "   (run.sh puts a pack directory in the throwaway GROOVIM_HOME)")
  call GT_Ok("  so the section it shows under is on offer",
    \ index(map(copy(GrooVim_MenuSectionsHere()), 'v:val[0]'), "View") >= 0,
    \ "   " . string(map(copy(GrooVim_MenuSectionsHere()), 'v:val[0]')))
  call GT_Ok("  and F9 writes it down",
    \ stridx(GrooVim_ShortcutsHelp(), "file tree") >= 0,
    \ "   (the tree is named by what it IS: the plugin that draws it is an\n" .
    \ "    answer to \"with what\", and nobody asked)")

  let g:enable_nerdtree_vim = 0
  call GT_Ok("with the plugin off, the shortcut is not on offer",
    \ !GrooVim_ShortcutAvailable(l:tree), "")
  call GT_Ok("  F9 does not write down what cannot be done",
    \ stridx(GrooVim_ShortcutsHelp(), "NERDTree") < 0, "")
  " The section goes when its LAST shortcut goes. "View" also holds the marks,
  " the tabs and the help, so what is checked is the tree leaving the menu and
  " not the section emptying.
  call GT_Ok("  and the tree is no longer on offer under it",
    \ empty(filter(copy(GrooVim_MenuOf("View", 1)[0]),
    \   'get(v:val, "group", "") ==# "F4" && v:val.key ==# "n"')),
    \ "   (a heading over nothing is what this guards against)")
  call GT_Ok("  while the marks under it stay, being nobody's plugin",
    \ len(filter(copy(GrooVim_MenuOf("View", 1)[0]),
    \   'get(v:val, "group", "") ==# "F4"')) == 4,
    \ "   (b, i, l and c)")

  let g:GrooVim_GrooVimBarMsgValue = ""
  call GT_Press("\<F4>n")
  call GT_Ok("  pressing it says WHICH plugin is missing",
    \ g:GrooVim_GrooVimBarMsgValue =~ "NERDTree" &&
    \ g:GrooVim_GrooVimBarMsgValue =~ "not installed",
    \ "   [" . g:GrooVim_GrooVimBarMsgValue . "]   (it used to be E117)")

  " ---- and the README goes on naming it, because it describes the PROJECT
  call GT_Ok("  the README still lists it, plugin or no plugin",
    \ !empty(filter(copy(GrooVim_ShortcutsMarkdown()), 'v:val =~ "file tree"')),
    \ "   (F9 is this machine; the README is the project)")

  let g:enable_nerdtree_vim = 1
  call GT_Ok("back on, and it is on offer again", GrooVim_ShortcutAvailable(l:tree) &&
    \ index(map(copy(GrooVim_MenuSectionsHere()), 'v:val[0]'), "View") >= 0, "")

  " ---- one door into the settings, and only one
  "
  " Each screen used to have a key of its own -- one for the search, one for the
  " replace, one for the indent, one for the general -- four entries in the list,
  " in the help, in the menu and in the README, for four things that are the same
  " thing. F5->c asks WHICH and opens it.
  call GT_Ok("F3 still runs the search and the replace",
    \ !empty(filter(GT_Of("F3"), 'v:val.key ==# "f"')) &&
    \ !empty(filter(GT_Of("F3"), 'v:val.key ==# "h"')), "")
  " The type is asked first: "run" is one line of VimScript, or a dictionary of
  " them keyed by mode, and "=~" against a dictionary throws.
  call GT_Ok("F5 has one key for every setting there is",
    \ len(filter(GT_Of("F5"),
    \   'type(v:val.run) == type("") && v:val.run =~ "GrooVim_Configure()"')) == 1,
    \ "   (F5->c)")
  call GT_Ok("  and it is a door, not a screen",
    \ exists("*GrooVim_Configure"), "")
  for s:gone in ["f", "h", "i"]
    call GT_Ok("  the letter " . s:gone . " of F5 is free again",
      \ empty(filter(GT_Of("F5"), 'v:val.key ==# "' . s:gone . '"')), "")
  endfor
  call GT_Ok("  and the four screens are all still reachable",
    \ exists("*GrooVim_ConfigureIndent") && exists("*GrooVim_ConfigureSearchReplace")
    \ && exists("*GrooVim_ConfigureGeneral"),
    \ "   (indent, search, replace, general)")

  " ---- and the keys really do what the list says
  tabonly!
  exec "edit " . g:GT_FIX . "/a.txt"
  call GT_Ok("setup: one tab", tabpagenr("$") == 1, "")
  call GT_Press("\<F5>n")
  call GT_Ok("F5 n opens a new tab", tabpagenr("$") == 2, "   (tabs " . tabpagenr("$") . ")")
  tabonly!
  call GT_Press("\<F3>n")
  call GT_Ok("F3 n does not open a tab any more", tabpagenr("$") == 1, "   (tabs " . tabpagenr("$") . ")")

  let l:file = g:GT_OUT . "/f3_s_must_not_save.txt"
  call delete(l:file)
  exec "edit " . l:file
  call setline(1, "not to be written by F3")
  call GT_Press("\<F3>s")
  call GT_Ok("F3 s no longer writes to disk", !filereadable(l:file),
    \ "   (it was a second :w, left over when saving moved to F5)")
  call GT_Press("\<F5>s")
  call GT_Ok("  and F5 s does write", filereadable(l:file), "")
  call delete(l:file)

  " ---- what came up from F2 to F3
  exec "edit! " . g:GT_FIX . "/a.txt"
  call cursor(2, 1)
  let l:before = line("$")
  call GT_Press("\<F3>d")
  call GT_Ok("F3 d duplicates the line", line("$") == l:before + 1 &&
    \ getline(2) ==# getline(3), "   [" . getline(2) . "]")
  call GT_Press("\<F2>d")
  call GT_Ok("F2 d does not duplicate any more", line("$") == l:before + 1,
    \ "   (" . line("$") . " lines)")

  " ---- "do that again", and whose "that" it is
  "
  " Each F key remembers the last command IT ran. There used to be ONE memory for
  " all four, plus a clock: measured with real keys, "F3 d" and then "F2 c" and
  " then F3 alone did nothing at all, because the F2 had taken the only slot
  " there was, and a slot belonging to another key was thrown away.
  "
  " The clock is gone too. It decided whether the same key pressed twice repeated
  " AT ONCE or went through the whole wait first, and it could never be met: it
  " ran from the first press, which itself spent 400ms before looking for the
  " second key, so it always read 402 to 404ms against a limit of 400.
  enew!
  call setline(1, ["um", "dois", "tres"])
  call cursor(1, 1)
  call GT_Press("\<F3>d")
  call GT_Ok("setup: F3 d duplicated the line", line("$") == 4, "   " . string(getline(1, "$")))
  call GT_Press("\<F2>c")
  call GT_Ok("setup: and F2 c ran in between", GrooVim_ClipGet() =~ "dois",
    \ "   (it copies the whole buffer)")
  " The key ALONE is called and not pressed. "feedkeys(..., \"x\")" runs the keys
  " and then, when the typeahead empties while Vim is waiting for a character,
  " hands it an <Esc> so that a script cannot hang -- measured: the F key read 27
  " as its second key and remembered THAT. With real keys through a real terminal
  " it repeats; the harness is what cannot press nothing.
  call GrooVim_CommandZ("F3", "n")
  call GT_Ok("F3 alone repeats what F3 did, not what F2 did", line("$") == 5,
    \ "   " . string(getline(1, "$")) . "   (one memory each)")
  call GT_Ok("  and F2 kept its own", g:GrooVim_CommandZChars["F2"] != "" &&
    \ g:GrooVim_CommandZChars["F3"] != "" &&
    \ g:GrooVim_CommandZChars["F2"] != g:GrooVim_CommandZChars["F3"],
    \ "   (F2 [" . g:GrooVim_CommandZChars["F2"] . "] F3 [" . g:GrooVim_CommandZChars["F3"] . "])")

  " Pressed twice, it repeats without waiting for a key that is not coming.
  call GT_Press("\<F3>\<F3>")
  call GT_Ok("the same key twice repeats as well", line("$") == 6,
    \ "   (" . line("$") . " lines)")

  " And another F key is not a second key: it is another shortcut starting, and
  " it used to be swallowed here.
  let l:lines = line("$")
  call GT_Press("\<F3>\<F2>c")
  call GT_Ok("another F key after F3 runs as ITSELF", line("$") == l:lines,
    \ "   (" . line("$") . " lines, and F3 did not repeat)")

  call GT_Ok("and the F keys have ONE number left",
    \ exists("g:GrooVim_CommandZWait") && !exists("g:GrooVim_CommandZSettle")
    \   && !exists("g:GrooVim_CommandZRepeat"),
    \ "   (how long it waits for the second key: " . g:GrooVim_CommandZWait . "ms)")

  " ---- and what the duplicate must NOT do
  "
  " It used to open a line and paste into it -- "yyo<Esc>p" -- and OPENING a line
  " under a comment makes Vim write the comment leader on it. That is the "o" of
  " "formatoptions", which for a Vim file is "croql": duplicating the line
  " " uma nota" gave "" uma nota", with the quote doubled. It depended on the file
  " type, because the leader does. "p" puts a whole line under this one on its
  " own, and there was never any need to open one first.
  "
  " And where you were is where you stay: "p" leaves the cursor on the COPY.
  enew!
  setlocal filetype=vim
  call setline(1, ['" uma nota do vim', '" outra'])
  call cursor(1, 9)
  call GT_Press("\<F3>d")
  call GT_Ok("duplicating a comment does not double its leader",
    \ getline(2) ==# getline(1),
    \ "   [" . getline(2) . "]   (it came back as \"\"" . " uma nota do vim\")")
  call GT_Ok("  and the cursor did not move", [line("."), col(".")] ==# [1, 9],
    \ "   (line " . line(".") . " column " . col(".") . ", and it was 1 and 9)")

  " The same for a selection, which is the other half of the same key.
  enew!
  setlocal filetype=vim
  call setline(1, ['" um', '" dois', '" tres'])
  call cursor(1, 2)
  call feedkeys("V", "x")
  call cursor(2, 2)
  call GT_Press("\<F3>d")
  call GT_Ok("duplicating a selection copies it under itself",
    \ getline(1, "$") ==# ['" um', '" dois', '" um', '" dois', '" tres'],
    \ "   " . string(getline(1, "$")))
  call GT_Ok("  and the cursor did not move either",
    \ [line("."), col(".")] ==# [2, 2],
    \ "   (line " . line(".") . " column " . col(".") . ", and it was 2 and 2)")

  " ---- the version, in one place
  "
  " The help of F9 used to carry a second copy of it, typed by hand, and that is
  " how a number goes stale: nothing makes the two agree, and nobody reads the
  " title of a help they wrote.
  call GT_Ok("there is a version", g:grooVimVersion =~ '^v\d\+\.\d\+\.\d',
    \ "   [" . g:grooVimVersion . "]")
  call GT_Ok("  and the help of F9 shows THAT one",
    \ stridx(g:GrooVimHelp, g:grooVimVersion[1:]) >= 0,
    \ "   (read from the variable, not typed again)")
  call GT_Ok("  and the bar too",
    \ stridx(GrooVim_GrooVimBar(), g:grooVimVersion) >= 0
    \ || stridx(execute("echo GrooVim_GrooVimBar()"), "grooVimVersion") >= 0, "")
  call GT_Ok("no other file writes a version by hand",
    \ empty(filter(GT_SourceLines(),
    \   'v:val =~ "[0-9]\\.[0-9]\\.[0-9]b" && v:val !~ "grooVimVersion"')),
    \ "   " . string(filter(GT_SourceLines(),
    \   'v:val =~ "[0-9]\\.[0-9]\\.[0-9]b" && v:val !~ "grooVimVersion"')))

  " ---- the licence, in one place and said the same way everywhere
  "
  " The .vimrc used to carry the whole of Apache 2.0 in comments: 211 lines of
  " licence before the first line of GrooVim. The GNU one is 674, so this is not
  " a road to go down again -- the licence lives in the file every project keeps
  " it in, and the source carries the notice the GPL asks you to attach.
  let l:here = fnamemodify(l:path, ":h")
  let l:licence = l:here . "/LICENSE"
  call GT_Ok("there is a LICENSE", filereadable(l:licence), "   [" . l:licence . "]")
  if filereadable(l:licence)
    let l:text = readfile(l:licence)
    call GT_Ok("  and it is the GNU GPL, version 3",
      \ l:text[0] =~ "GNU GENERAL PUBLIC LICENSE" && l:text[1] =~ "Version 3",
      \ "   [" . trim(l:text[0]) . " " . trim(l:text[1]) . "]")
    call GT_Ok("  whole, to its last section",
      \ !empty(filter(copy(l:text), 'v:val =~ "How to Apply These Terms"')),
      \ "   (" . len(l:text) . " lines)")
  endif

  let l:vimrc = readfile(l:path)
  call GT_Ok("the .vimrc carries the notice, not the licence",
    \ !empty(filter(copy(l:vimrc), 'v:val =~ "GNU General Public License as published by"'))
    \ && !empty(filter(copy(l:vimrc), 'v:val =~ "any later version"')),
    \ "   (\"or later\": the notice of the GPL itself)")
  call GT_Ok("  and it is short",
    \ len(filter(copy(l:vimrc), 'v:val =~ "^\" "')) < 400,
    \ "   (211 lines of licence used to come before the first line of GrooVim)")

  call GT_Ok("nothing anywhere still says Apache",
    \ empty(filter(GT_SourceLines() + l:vimrc, 'v:val =~? "apache"')),
    \ "   (one licence, said the same way in every place that names it)")

  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
