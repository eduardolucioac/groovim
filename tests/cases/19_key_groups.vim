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
  call GT_Ok("F3 g is the one that configures the search",
    \ index(l:groups["F3"].claimed, "g") >= 0 && index(l:groups["F3"].claimed, "d") >= 0,
    \ "   " . string(l:groups["F3"].claimed))

  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
