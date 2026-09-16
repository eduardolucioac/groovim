" Each F key is a group with a meaning, and the shortcuts inside it obey.
"
"   F2  editing, and what acts on the FILE itself
"   F3  the editing you reach for most, and searching
"   F4  the installed plugins
"   F5  what acts on the EDITOR -- tabs, leaving -- and the settings
"
" There used to be three hundred lines of "if the key is this, do that" beside
" the list the help is written from, and every shortcut lived in both. They
" drifted: keys that moved group went on answering under the old one, and the
" help named letters that had been retired. Now the list is the only place, and
" what this case guards is that the list itself holds together.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

func! GT_Of(group)
  return filter(copy(g:GrooVim_Shortcuts), 'v:val.group ==# "' . a:group . '"')
endfunc

func! GT_Body()
  let l:path = $GROOVIM_TEST_VIMRC
  let l:source = GT_SourceLines()
  call GT_Ok("we can read the source of GrooVim", filereadable(l:path), "   [" . l:path . "]")
  call GT_Ok("  and the parts it loads", len(l:source) > 5000,
    \ "   (" . len(glob(fnamemodify(l:path, ":h") . "/parts/*.vim", 0, 1)) . " parts, " .
    \ len(l:source) . " lines in all)")

  " ---- the list, and the four groups
  call GT_Ok("the list of shortcuts is there",
    \ exists("g:GrooVim_Shortcuts") && len(g:GrooVim_Shortcuts) > 20,
    \ "   (" . len(g:GrooVim_Shortcuts) . " shortcuts)")
  call GT_Ok("the four groups are there, each with a heading and a label",
    \ len(g:GrooVim_ShortcutGroups) == 4 &&
    \ len(filter(copy(g:GrooVim_ShortcutGroups), 'len(v:val) == 3')) == 4,
    \ "   " . string(map(copy(g:GrooVim_ShortcutGroups), 'v:val[0] . " " . v:val[2]')))
  call GT_Ok("and every shortcut belongs to one of them",
    \ empty(filter(copy(g:GrooVim_Shortcuts),
    \ 'index(map(copy(g:GrooVim_ShortcutGroups), "v:val[0]"), v:val.group) < 0')), "")

  " ---- every entry is complete
  let l:short = []
  for l:one in g:GrooVim_Shortcuts
    for l:field in ["group", "key", "modes", "run", "what"]
      if !has_key(l:one, l:field)
        call add(l:short, get(l:one, "group", "?") . "->" . get(l:one, "key", "?") . " has no " . l:field)
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
      let l:signature = l:one.group . "|" . l:one.key . "|" . l:mode
      if has_key(l:seen, l:signature) | call add(l:twice, l:signature) | endif
      let l:seen[l:signature] = 1
    endfor
  endfor
  call GT_Ok("no key answers twice in the same group and mode", empty(l:twice),
    \ "   " . (empty(l:twice) ? "(" . len(l:seen) . " key and mode pairs)" : string(l:twice)))

  " ---- and every mode a shortcut claims really has something to run
  "
  " "run" is one line, or a handful keyed by the modes each belongs to. A
  " shortcut that says it answers in visual and whose run has nothing for visual
  " does nothing at all when you press it there, and says nothing about it.
  let l:uncovered = []
  for l:one in g:GrooVim_Shortcuts
    if type(l:one.run) != type({}) | continue | endif
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
  for l:one in g:GrooVim_Shortcuts
    if !GrooVim_ShortcutIsKey(strchars(l:one.key) == 1 ? char2nr(l:one.key) :
      \ eval('"\<' . toupper(l:one.key[0]) . l:one.key[1:] . '>"'), l:one.key)
      call add(l:strange, l:one.group . "->" . l:one.key)
    endif
  endfor
  call GT_Ok("the dispatch recognises every key of the list", empty(l:strange),
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

  " ---- the index says what is in each part, and says it about ALL of them
  "
  " A map that goes stale is worse than no map. Every file in "parts" has to be
  " named in the ".vimrc", and every name in the ".vimrc" has to be a file.
  let l:index = join(readfile(l:path), "\n")
  let l:onDisk = map(glob(fnamemodify(l:path, ":h") . "/parts/*.vim", 0, 1), 'fnamemodify(v:val, ":t")')
  let l:unlisted = filter(copy(l:onDisk), 'stridx(l:index, v:val) < 0')
  call GT_Ok("the index names every part there is", empty(l:unlisted),
    \ "   " . (empty(l:unlisted) ? "(" . len(l:onDisk) . " parts)" : string(l:unlisted)))
  let l:named = []
  for l:line in readfile(l:path)
    let l:hit = matchstr(l:line, 'parts/\zs[0-9]\+-\w\+\.vim')
    if l:hit != "" && index(l:named, l:hit) < 0 | call add(l:named, l:hit) | endif
  endfor
  call GT_Ok("  and names nothing that is not there",
    \ empty(filter(copy(l:named), 'index(l:onDisk, v:val) < 0')),
    \ "   " . string(filter(copy(l:named), 'index(l:onDisk, v:val) < 0')))

  " ---- GrooVim knows where its own .vimrc is
  call GT_Ok("GrooVim knows its own .vimrc", filereadable(g:GrooVim_Vimrc),
    \ "   [" . g:GrooVim_Vimrc . "]")
  call GT_Ok("  and it is the one being run",
    \ simplify(fnamemodify(g:GrooVim_Vimrc, ":p")) ==# simplify(fnamemodify(l:path, ":p")), "")
  call GT_Ok("the mapping that opens it carries the path, not the variable",
    \ maparg("\\zv", "n") !~ "MYVIMRC" && maparg("\\zv", "n") =~ "tabedit", "")
  call GT_Ok("neither goes through a function of its own",
    \ maparg("\\zvv", "n") !~ "call ",
    \ "   (sourcing redefines every function, and Vim refuses one that is RUNNING: E127)")

  " ---- the debugger of 2014 is gone
  call GT_Ok("no debugger left in the source",
    \ !exists("*GrooVim_ToggleDbg") && !exists("g:enable_debugger_vim"), "")
  call GT_Ok("F4 answers for the tree alone",
    \ map(GT_Of("F4"), 'v:val.key') ==# ["n"], "   " . string(map(GT_Of("F4"), 'v:val.key')))

  " ---- doing it and setting it up: same letter, one group apart
  call GT_Ok("F3 runs the search and the replace",
    \ !empty(filter(GT_Of("F3"), 'v:val.key ==# "f"')) &&
    \ !empty(filter(GT_Of("F3"), 'v:val.key ==# "h"')), "")
  call GT_Ok("F5 sets them up, on the SAME letters",
    \ !empty(filter(GT_Of("F5"), 'v:val.key ==# "f"')) &&
    \ !empty(filter(GT_Of("F5"), 'v:val.key ==# "h"')), "")

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

  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
