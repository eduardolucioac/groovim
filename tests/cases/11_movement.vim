" Ctrl-Alt e Shift-Alt com as setas.
"
" Duas coisas ao mesmo tempo, e elas se contradizem se a gente nao tomar cuidado:
" o cursor anda em LINHA RETA, voltando sempre a coluna de onde saiu; e ele pode
" ficar sobre AREA SEM TEXTO, que e a razao de existir desta funcao. Quem segura
" a segunda e o "virtualedit=all", ligado durante o movimento.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Nome(expand("<sfile>:t:r"))

let g:GT_POS = []

func! GT_Anota(t)
  call add(g:GT_POS, {"linha": line("."), "col": col("."), "virtcol": virtcol("."),
    \ "fim": virtcol("$"), "want": getcurpos()[4], "ve": &virtualedit, "modo": mode()})
endfunc

func! GT_Mostra(p)
  return "   (linha " . a:p.linha . " col " . a:p.col . " virtcol " . a:p.virtcol .
    \ " fim " . a:p.fim . " want " . a:p.want . " ve=" . a:p.ve . ")"
endfunc

func! GT_Conclui(t)
  " o arquivo: linha 5 e 7 tem 25 caracteres, a 6 tem 13
  let p = g:GT_POS

  call GT_Ok("comeco: linha 5, coluna 24", p[0].linha == 5 && p[0].col == 24, GT_Mostra(p[0]))
  call GT_Ok("desceu para a linha curta", p[1].linha == 6, GT_Mostra(p[1]))
  call GT_Ok("  e FICOU sobre area sem texto", p[1].virtcol == 24 && p[1].virtcol > p[1].fim,
    \ GT_Mostra(p[1]) . "   (e para isto que serve o virtualedit)")
  call GT_Ok("  com virtualedit ligado", p[1].ve ==# "all", GT_Mostra(p[1]))
  call GT_Ok("  e NAO foi para o comeco da linha", p[1].col > 1, GT_Mostra(p[1]))
  call GT_Ok("desceu para a longa: voltou a 24", p[2].linha == 7 && p[2].col == 24, GT_Mostra(p[2]))
  call GT_Ok("  com virtualedit devolvido", p[2].ve ==# "onemore", GT_Mostra(p[2]))
  call GT_Ok("subiu para a curta de novo", p[3].linha == 6 && p[3].virtcol == 24, GT_Mostra(p[3]))
  call GT_Ok("subiu para a longa: voltou a 24", p[4].linha == 5 && p[4].col == 24, GT_Mostra(p[4]))

  let semDesvio = 1
  for passo in p
    if passo.want != 24 | let semDesvio = 0 | endif
  endfor
  call GT_Ok("a coluna a manter nunca recuou", semDesvio, "   (era o 24, 23, 22...)")

  let emInsert = 1
  for passo in p
    if passo.modo !=# "i" | let emInsert = 0 | endif
  endfor
  call GT_Ok("tudo isso em modo insert", emInsert, "")
  call GT_Ok("o texto nao foi tocado", getline(1, "$") ==# g:GT_TEXTO, "")

  " ---- e agora o Shift-Alt, o movimento longo
  "
  " O bloco acima termina DENTRO do modo insert, entao o "<Esc>" vem primeiro:
  " sem ele o "i" seguinte seria digitado como texto no arquivo.
  let g:GT_POS = []
  call feedkeys("\<Esc>", "t")
  call timer_start(100,  {t -> [cursor(1, 20), feedkeys("i", "t")]})
  call timer_start(200,  "GT_Anota")
  call timer_start(300,  {t -> feedkeys("\<A-S-Down>", "t")})
  call timer_start(1200, "GT_Anota")
  call timer_start(1300, {t -> feedkeys("\<A-S-Up>", "t")})
  call timer_start(2200, "GT_Anota")
  call timer_start(2300, {t -> feedkeys("\<A-S-Down>", "t")})
  call timer_start(3200, "GT_Anota")
  call timer_start(3300, {t -> feedkeys("\<A-S-Up>", "t")})
  call timer_start(4200, "GT_Anota")
  call timer_start(4500, "GT_ConcluiLongo")
endfunc

func! GT_ConcluiLongo(t)
  let p = g:GT_POS

  call GT_Ok("Shift-Alt: comecou na coluna 20", p[0].col == 20, GT_Mostra(p[0]))
  call GT_Ok("Shift-Alt: desceu para a ultima linha", p[1].linha == 8, GT_Mostra(p[1]))
  call GT_Ok("  e ficou sobre area sem texto", p[1].virtcol == 20 && p[1].virtcol > p[1].fim,
    \ GT_Mostra(p[1]))
  call GT_Ok("Shift-Alt: subindo, voltou a coluna 20", p[2].linha == 1 && p[2].col == 20,
    \ GT_Mostra(p[2]) . "   (era aqui que recuava: 20, 19, 18...)")

  let semDesvio = 1
  for passo in p
    if passo.virtcol != 20 | let semDesvio = 0 | endif
  endfor
  call GT_Ok("Shift-Alt: quatro viagens sem recuar", semDesvio,
    \ "   (colunas " . join(map(copy(p), 'v:val.virtcol'), ", ") . ")")
  call GT_Ok("Shift-Alt: o texto nao foi tocado", getline(1, "$") ==# g:GT_TEXTO, "")

  " ---- e em modo BLOCO, o outro "(PRIORITY)" de 2014
  let g:GT_POS = []
  call feedkeys("\<Esc>", "t")
  call timer_start(100,  {t -> [cursor(5, 24), feedkeys("\<C-b>", "t")]})
  call timer_start(300,  "GT_Anota")
  call timer_start(400,  {t -> feedkeys("\<C-A-Down>", "t")})
  call timer_start(700,  "GT_Anota")
  call timer_start(800,  {t -> feedkeys("\<C-A-Down>", "t")})
  call timer_start(1100, "GT_Anota")
  call timer_start(1400, "GT_ConcluiBloco")
endfunc

func! GT_Corpo()
  exec "edit " . g:GT_FIX . "/irregular.py"
  let g:GT_TEXTO = getline(1, "$")
  call cursor(5, 24)
  call feedkeys("i", "t")
  " Precisa de tempo real entre as teclas: o "<C-o>" sai e volta do modo insert, e
  " feedkeys(..., "x") encerraria o insert no meio do caminho.
  call timer_start(200,  "GT_Anota")
  call timer_start(300,  {t -> feedkeys("\<C-A-Down>", "t")})
  call timer_start(600,  "GT_Anota")
  call timer_start(700,  {t -> feedkeys("\<C-A-Down>", "t")})
  call timer_start(1000, "GT_Anota")
  call timer_start(1100, {t -> feedkeys("\<C-A-Up>", "t")})
  call timer_start(1400, "GT_Anota")
  call timer_start(1500, {t -> feedkeys("\<C-A-Up>", "t")})
  call timer_start(1800, "GT_Anota")
  call timer_start(2000, "GT_Conclui")
endfunc

func! GT_ConcluiBloco(t)
  let p = g:GT_POS
  call GT_Ok("bloco: Ctrl-b entrou em visual block", p[0].modo ==# "\<C-v>", "   (modo [" . strtrans(p[0].modo) . "])")
  call GT_Ok("bloco: desceu para a linha curta", p[1].linha == 6, GT_Mostra(p[1]))
  call GT_Ok("bloco: ficou sobre area sem texto", p[1].virtcol == 24 && p[1].virtcol > p[1].fim, GT_Mostra(p[1]))
  call GT_Ok("bloco: desceu para a longa, coluna 24", p[2].linha == 7 && p[2].col == 24, GT_Mostra(p[2]))
  call GT_Ok("bloco: continua em visual block", p[2].modo ==# "\<C-v>", "   (modo [" . strtrans(p[2].modo) . "])")
  call GT_Ok("bloco: o texto nao foi tocado", getline(1, "$") ==# g:GT_TEXTO, "")
  call GT_Fim()
endfunc

call GT_DepoisDoArranque("GT_Corpo")
