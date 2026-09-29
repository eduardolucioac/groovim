" In the list, nothing that would change the text may do anything -- not even
" produce an "E21". What reads, moves or copies goes on working.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

exec "edit " . g:GT_FIX . "/a.txt"
call GT_BuildSearch("TARGET", 1, ["0", "0", "0", "1," . g:GT_FIX . "/a.txt,2,21", "1," . g:GT_FIX . "/a.txt,4,22"])
call GrooVim_SearchGuySync()
call GT_Ok("the list opened", GT_GoToList(), "   " . GT_Layout())

let g:GT_BEFORE = getline(1, "$")

" ---- normal mode: press them for real and see whether an error is left behind
let g:GT_ERRORS = []
for k in ["\<S-Up>", "i", "I", "a", "A", "o", "O", "x", "X", "d", "D", "p", "P", "r", "R", "u", "U", "J", "~", "\<Del>", "\<BS>", "\<C-V>"]
  call cursor(4, 3)
  let v:errmsg = ""
  call feedkeys(k . "\<Esc>", "x")
  if v:errmsg != "" | call add(g:GT_ERRORS, strtrans(k) . "=" . v:errmsg) | endif
endfor
call GT_Ok("normal mode: no key raises an error", empty(g:GT_ERRORS), "   " . string(g:GT_ERRORS))

" ---- visual mode: GrooVim gives a conventional editor meaning to several keys
let g:GT_ERRORS_V = []
for k in ["\<S-Up>", "x", "d", "s", "c", "p", "P", "r", "u", "U", "J", "~", "<", ">", "=", "\<Del>", "\<BS>", "\<CR>", "\<C-V>", "\<C-X>"]
  call cursor(4, 3)
  let v:errmsg = ""
  call feedkeys("v\<Right>\<Right>" . k . "\<Esc>", "x")
  if v:errmsg != "" | call add(g:GT_ERRORS_V, strtrans(k) . "=" . v:errmsg) | endif
endfor
call GT_Ok("visual mode: no key raises an error", empty(g:GT_ERRORS_V), "   " . string(g:GT_ERRORS_V))

call GT_Ok("the list is untouched", getline(1, "$") ==# g:GT_BEFORE, "")
call GT_Ok("the list is still nomodifiable", &modifiable == 0, "")

" ---- what MUST go on working
call cursor(4, 3)
call feedkeys("gg", "x")
call GT_Ok("gg goes to the top", line(".") == 1, "   (line " . line(".") . ")")
call feedkeys("G", "x")
call GT_Ok("G goes to the end", line(".") == line("$"), "   (line " . line(".") . " of " . line("$") . ")")
call cursor(4, 1)
let @a = ""
call feedkeys("v$\"ay", "x")
call GT_Ok("y copies the selected line", @a != "", "   [" . @a . "]")
call cursor(3, 1)
call feedkeys("\<Down>", "x")
call GT_Ok("the arrows move around", line(".") == 4, "   (line " . line(".") . ")")
let v:errmsg = ""
call feedkeys("\<PageDown>", "x")
call GT_Ok("PageDown (GroovyMove) with no error", v:errmsg == "", "   [" . v:errmsg . "]   (it moves the cursor, it does not edit)")

" ---- outside the list none of this holds
wincmd p
call GT_Ok("outside: Shift-Up goes back to entering insert", maparg("<S-Up>", "n") ==# "i", "   [" . maparg("<S-Up>", "n") . "]")
call GT_Ok("outside: x deletes as usual", maparg("x", "n") != "<Nop>", "")
call GT_Ok("outside: Del deletes as usual", maparg("<Del>", "n") =~ "NormalDel", "   [" . maparg("<Del>", "n") . "]")
call GT_Ok("outside: Backspace deletes as usual", maparg("<BS>", "n") =~ "NormalBackspace", "")

" ---- the help of the word under the cursor, on a Vim file, is Vim's own
"
" GrooVim used to bind "F1" to ":help <cword>" in this buffer, and it was the one
" mapping that never reached the list of shortcuts. What it did, Vim already does
" with "K" and does better: the file type plugin for "vim" sets "keywordprg", and
" it knows a command from an option from a function. This is the check that says
" why the mapping could go: GrooVim leaves both of them alone.
exec "edit " . g:GT_FIX . "/um.vim"
call GT_Ok("on a .vim file, K asks Vim for the word under the cursor",
  \ &keywordprg =~ "Vim" && maparg("K", "n") ==# "",
  \ "   [keywordprg=" . &keywordprg . "]   (and K is not remapped)")
call GT_Ok("  and F1 is Vim's own again",
  \ maparg("<F1>", "n") ==# "" && maparg("<F1>", "i") ==# "",
  \ "   [" . maparg("<F1>", "n") . "]")

call GT_Done()
