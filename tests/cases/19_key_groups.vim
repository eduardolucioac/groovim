" Every F key is a group with a meaning, and the keys inside it obey.
"
"   F2  editing, and what acts on the FILE itself
"   F3  the editing you reach for most, and searching
"   F4  the installed plugins
"   F5  what acts on the EDITOR -- tabs, leaving -- and the settings
"
" This case reads the source of GrooVim and checks the bookkeeping: no letter
" answering twice in the same group, and the "Used keys" note saying what is
" really there. Both had already drifted -- a second ":w" left behind in F3 after
" saving moved to F5, and the note of F4 naming keys the block does not handle.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

" The letter a key code stands for, as the "Used keys" notes write it.
func! GT_KeyName(code)
  if a:code =~ '^\d\+$'
    return nr2char(str2nr(a:code))
  endif
  return tolower(matchstr(a:code, '<\zs\w\+\ze>'))
endfunc

" Reads the CommandZ of GrooVim and returns, per group, the list of
" [key, mode condition] it answers to and the keys its note claims.
func! GT_ReadGroups(path)
  let l:groups = {}
  let l:group = ""
  for l:line in readfile(a:path)
    let l:which = matchstr(l:line, 'GrooVim_CommandZFCallerNow == "\zsF\d\ze"')
    if l:which != ""
      let l:group = l:which
      let l:groups[l:group] = {"handled": [], "claimed": []}
      continue
    endif
    if l:group == "" | continue | endif
    let l:note = matchstr(l:line, 'Used keys for ' . l:group . ': \zs[^!]*\ze!')
    if l:note != ""
      let l:groups[l:group].claimed = split(l:note)
      continue
    endif
    let l:code = matchstr(l:line, 'g:GrooVim_CommandZChar == "\zs[^"]\+\ze"')
    if l:code != ""
      let l:mode = matchstr(l:line, 'a:modType [=!]= "\w"')
      call add(l:groups[l:group].handled, [GT_KeyName(l:code), l:mode])
    endif
  endfor
  return l:groups
endfunc

func! GT_Body()
  let l:path = $GROOVIM_TEST_VIMRC
  call GT_Ok("we can read the source of GrooVim", filereadable(l:path), "   [" . l:path . "]")
  let l:groups = GT_ReadGroups(l:path)
  call GT_Ok("the four groups are there",
    \ sort(keys(l:groups)) ==# ["F2", "F3", "F4", "F5"], "   " . string(sort(keys(l:groups))))

  for l:name in ["F2", "F3", "F4", "F5"]
    let l:g = l:groups[l:name]

    " ---- no letter may answer twice for the same mode
    let l:twice = []
    let l:already = {}
    for l:entry in l:g.handled
      let l:signature = l:entry[0] . "|" . l:entry[1]
      if has_key(l:already, l:signature) | call add(l:twice, l:entry[0]) | endif
      let l:already[l:signature] = 1
    endfor
    call GT_Ok(l:name . ": no key answers twice", empty(l:twice),
      \ "   " . (empty(l:twice) ? "(" . len(l:g.handled) . " entries)" : string(l:twice)))

    " ---- and the note says exactly what is there
    let l:real = sort(uniq(sort(map(copy(l:g.handled), 'v:val[0]'))))
    let l:said = sort(copy(l:g.claimed))
    call GT_Ok(l:name . ": the \"Used keys\" note is right", l:real ==# l:said,
      \ "   note " . string(l:said) . (l:real ==# l:said ? "" : "   really " . string(l:real)))
  endfor

  " ---- and where the moved commands now live
  exec "edit " . g:GT_FIX . "/a.txt"
  call GT_Ok("setup: one tab", tabpagenr("$") == 1, "")
  call feedkeys("\<F5>n", "x")
  call GT_Ok("F5 n opens a new tab", tabpagenr("$") == 2, "   (tabs " . tabpagenr("$") . ")")
  tabonly!

  call feedkeys("\<F3>n", "x")
  call GT_Ok("F3 n does not open a tab any more", tabpagenr("$") == 1, "   (tabs " . tabpagenr("$") . ")")

  " ---- the save that was left behind in F3
  let l:file = g:GT_OUT . "/f3_s_must_not_save.txt"
  call delete(l:file)
  exec "edit " . l:file
  call setline(1, "not to be written by F3")
  call feedkeys("\<F3>s", "x")
  call GT_Ok("F3 s no longer writes to disk", !filereadable(l:file),
    \ "   (it was a second :w, left over when saving moved to F5)")
  call feedkeys("\<F5>s", "x")
  call GT_Ok("  and F5 s does write", filereadable(l:file), "")
  call delete(l:file)

  " ---- GrooVim knows where its own .vimrc is
  "
  " "$MYVIMRC" is empty when Vim is handed the file with "-u", which is how the
  " "groovim" command runs it -- and ":tabedit $MYVIMRC" then opened a new, empty
  " file NAMED after the variable.
  call GT_Ok("GrooVim knows its own .vimrc", filereadable(g:GrooVim_Vimrc),
    \ "   [" . g:GrooVim_Vimrc . "]")
  " simplify(): the runner says "tests/../.vimrc", which is the same file
  call GT_Ok("  and it is the one being run",
    \ simplify(fnamemodify(g:GrooVim_Vimrc, ":p")) ==# simplify(fnamemodify(l:path, ":p")),
    \ "   (-u said " . simplify(fnamemodify(l:path, ":p")) . ")")
  call GT_Ok("the mapping that opens it carries the path, not the variable",
    \ maparg("\\zv", "n") !~ "MYVIMRC" && maparg("\\zv", "n") =~ "tabedit",
    \ "   [" . maparg("\\zv", "n") . "]")
  call GT_Ok("and so does the one that reloads it",
    \ maparg("\\zvv", "n") !~ "MYVIMRC" && maparg("\\zvv", "n") =~ "source",
    \ "   [" . maparg("\\zvv", "n") . "]")
  call GT_Ok("neither goes through a function of its own",
    \ maparg("\\zvv", "n") !~ "call ",
    \ "   (sourcing redefines every function, and Vim refuses one that is RUNNING: E127)")

  tabonly!
  exec "edit " . g:GT_FIX . "/a.txt"
  call feedkeys("\<F5>v", "x")
  call GT_Ok("F5 v opened the real .vimrc", expand("%:p") ==# g:GrooVim_Vimrc && line("$") > 100,
    \ "   [" . expand("%:t") . "] " . line("$") . " lines")
  tabonly!

  " ---- the debugger of 2014 is gone
  call GT_Ok("no debugger left in the source",
    \ !exists("*GrooVim_ToggleDbg") && !exists("g:enable_debugger_vim"), "")
  call GT_Ok("F4 answers for the tree alone", l:groups["F4"].claimed ==# ["n"],
    \ "   " . string(l:groups["F4"].claimed))

  " ---- what came up from F2 to F3
  exec "edit " . g:GT_FIX . "/a.txt"
  call cursor(2, 1)
  let l:before = line("$")
  call feedkeys("\<F3>d", "x")
  call GT_Ok("F3 d duplicates the line", line("$") == l:before + 1 &&
    \ getline(2) ==# getline(3), "   [" . getline(2) . "] [" . getline(3) . "]")
  call feedkeys("\<F2>d", "x")
  call GT_Ok("F2 d does not duplicate any more", line("$") == l:before + 1,
    \ "   (" . line("$") . " lines)")

  " ---- and the letters the collisions forced
  call cursor(1, 1)
  call feedkeys("VG\<Esc>", "x")
  call GT_Ok("setup: a selection to come back to", line("'<") == 1 && line("'>") == line("$"), "")
  call cursor(2, 1)
  call feedkeys("\<F3>v\<Esc>", "x")
  call GT_Ok("F3 v reselects the area (the gv of Vim)",
    \ line("'<") == 1 && line("'>") == l:before + 1, "   (from " . line("'<") . " to " . line("'>") . ")")
  " ---- doing it and setting it up: same letter, one group apart
  call GT_Ok("F3 runs the search and the replace",
    \ index(l:groups["F3"].claimed, "f") >= 0 && index(l:groups["F3"].claimed, "h") >= 0,
    \ "   " . string(l:groups["F3"].claimed))
  call GT_Ok("F5 sets up the search and the replace, on the SAME letters",
    \ index(l:groups["F5"].claimed, "f") >= 0 && index(l:groups["F5"].claimed, "h") >= 0,
    \ "   " . string(l:groups["F5"].claimed))
  call GT_Ok("and F3 no longer holds either settings screen",
    \ index(l:groups["F3"].claimed, "g") < 0 && index(l:groups["F3"].claimed, "j") < 0, "")

  " ---- what the messages tell you to press has to exist
  "
  " A shortcut named in a message is written "F5->c". When a command changes
  " group or letter the message is easy to forget: the one that pointed at the
  " search settings still said "F3" and then "d" two moves after the fact. Here
  " every shortcut any message or help line names is looked up in the group that
  " really answers for it.
  "
  " It checks that the key EXISTS, not that it means the right thing: a message
  " pointing at a letter that is still in the group but now does something else
  " gets through. Only reading the message can catch that one.
  let l:named = []
  let l:wrong = []
  for l:line in readfile(l:path)
    " An F key closed by a quote or a ">", then " and then ", then another
    " quoted key -- the old way of writing a shortcut. Written this tightly so
    " that prose which merely says "and then" is left alone.
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
      let l:which = strpart(l:shortcut, 0, 2)
      let l:key = tolower(strpart(l:shortcut, 4, 1))
      if index(l:named, l:shortcut) < 0 | call add(l:named, l:shortcut) | endif
      if index(l:groups[l:which].claimed, l:key) < 0
        call add(l:wrong, l:shortcut . " -- no such key in " . l:which)
      endif
    endwhile
  endfor
  call GT_Ok("every shortcut a message names really exists", empty(l:wrong),
    \ empty(l:wrong) ? "   " . string(sort(copy(l:named))) : "   " . string(l:wrong))
  call GT_Ok("  and there are some to check", len(l:named) >= 8, "   (" . len(l:named) . ")")

  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
