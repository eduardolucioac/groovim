" Na lista, nada que mudaria o texto pode fazer nada -- nem produzir um "E21".
" O que lê, move ou copia continua.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

exec "edit " . g:GT_FIX . "/a.txt"
call GT_BuildSearch("ALVO", 1, ["0", "0", "0", "1," . g:GT_FIX . "/a.txt,2,24", "1," . g:GT_FIX . "/a.txt,4,23"])
call GrooVim_SearchGuySync()
call GT_Ok("a lista abriu", GT_GoToList(), "   " . GT_Layout())

let g:GT_ANTES = getline(1, "$")

" ---- modo normal: aperta de verdade e olha se sobrou erro
let g:GT_ERROS = []
for k in ["\<S-Up>", "i", "I", "a", "A", "o", "O", "x", "X", "d", "D", "p", "P", "r", "R", "u", "U", "J", "~", "\<Del>", "\<BS>", "\<C-V>"]
  call cursor(4, 3)
  let v:errmsg = ""
  call feedkeys(k . "\<Esc>", "x")
  if v:errmsg != "" | call add(g:GT_ERROS, strtrans(k) . "=" . v:errmsg) | endif
endfor
call GT_Ok("modo normal: nenhuma tecla da erro", empty(g:GT_ERROS), "   " . string(g:GT_ERROS))

" ---- modo visual: o GrooVim da sentido de editor convencional a varias teclas
let g:GT_ERROS_V = []
for k in ["\<S-Up>", "x", "d", "s", "c", "p", "P", "r", "u", "U", "J", "~", "<", ">", "=", "\<Del>", "\<BS>", "\<CR>", "\<C-V>", "\<C-X>"]
  call cursor(4, 3)
  let v:errmsg = ""
  call feedkeys("v\<Right>\<Right>" . k . "\<Esc>", "x")
  if v:errmsg != "" | call add(g:GT_ERROS_V, strtrans(k) . "=" . v:errmsg) | endif
endfor
call GT_Ok("modo visual: nenhuma tecla da erro", empty(g:GT_ERROS_V), "   " . string(g:GT_ERROS_V))

call GT_Ok("a lista continua intacta", getline(1, "$") ==# g:GT_ANTES, "")
call GT_Ok("a lista continua nomodifiable", &modifiable == 0, "")

" ---- o que TEM que continuar funcionando
call cursor(4, 3)
call feedkeys("gg", "x")
call GT_Ok("gg vai para o topo", line(".") == 1, "   (linha " . line(".") . ")")
call feedkeys("G", "x")
call GT_Ok("G vai para o fim", line(".") == line("$"), "   (linha " . line(".") . " de " . line("$") . ")")
call cursor(4, 1)
let @a = ""
call feedkeys("v$\"ay", "x")
call GT_Ok("y copia a linha selecionada", @a != "", "   [" . @a . "]")
call cursor(3, 1)
call feedkeys("\<Down>", "x")
call GT_Ok("as setas navegam", line(".") == 4, "   (linha " . line(".") . ")")
let v:errmsg = ""
call feedkeys("\<PageDown>", "x")
call GT_Ok("PageDown (GroovyMove) sem erro", v:errmsg == "", "   [" . v:errmsg . "]   (e movimento do cursor, nao edicao)")

" ---- fora da lista nada disso vale
wincmd p
call GT_Ok("fora: Shift-Up volta a entrar em insert", maparg("<S-Up>", "n") ==# "i", "   [" . maparg("<S-Up>", "n") . "]")
call GT_Ok("fora: x apaga normalmente", maparg("x", "n") != "<Nop>", "")
call GT_Ok("fora: Del apaga normalmente", maparg("<Del>", "n") =~ "NormalDel", "   [" . maparg("<Del>", "n") . "]")
call GT_Ok("fora: Backspace apaga normalmente", maparg("<BS>", "n") =~ "NormalBackspace", "")

call GT_Done()
