" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
" DEBUGGING (WHEN SOMETHING DOES NOT FIRE)
" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" The tools for finding OUT, which is not the same work as editing: the one that
" reports what a key really delivers, and the one that stops the code where it
" runs so that you can look at it.

" $$$$$$$$$$$$$$$$$$$$$$$

" Note: What a key really delivers, which is the only way to settle an argument
" about a shortcut that does not fire.
"
" A terminal sends an arrow, an F key or a keypad key as a sequence of bytes,
" and two keys that LOOK the same can arrive as different keys -- the shortcuts
" of GrooVim compare what "getchar()" hands over, so that is what this prints.
com! GrooVimKey call GrooVim_KeyReport()

func! GrooVim_KeyReport() abort

  echo "GrooVim: press the key you want to look at..."
  let l:key = getchar()
  redraw

  " Note: A plain key comes back as a NUMBER and a special one as a String,
  " which is why the shortcuts compare against "\<Up>" and against "116" alike.
  let l:asText = type(l:key) == type(0) ? nr2char(l:key) : l:key
  let l:known = ""
  for l:name in ["Up", "Down", "Left", "Right", "Home", "End", "Del", "Insert",
   \ "PageUp", "PageDown", "Tab", "Esc", "CR", "Space", "BS",
   \ "kHome", "kEnd", "kPageUp", "kPageDown", "kPlus", "kMinus", "kEnter",
   \ "kMultiply", "kDivide", "kPoint", "k0", "k1", "k2", "k3", "k4",
   \ "k5", "k6", "k7", "k8", "k9",
   \ "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12"]

    " Note: "try", because a name Vim does not know is an ERROR and not a
    " mismatch -- one wrong entry in the list above would take the whole report
    " down with it.
    try
      if l:asText ==# eval('"\<' . l:name . '>"')
        let l:known = "<" . l:name . ">"
        break
      endif
    catch
    endtry

  endfor

  echomsg "GrooVim sees: " . string(l:key) .
   \ "   as text: " . strtrans(l:asText) .
   \ "   which is: " . (l:known != "" ? l:known :
   \   (type(l:key) == type(0) ? "the character \"" . nr2char(l:key) . "\"" : "a key GrooVim has no name for"))

endfunc

" Note: A stop, for when reading the code is not enough and you have to watch it
" run. Call it from a line and GrooVim stands there, saying what you told it to
" say, until you press "0".
"
" It is for whoever is WRITING GrooVim and not for whoever is using it, which is
" why there is no key and no command for it: it goes in the line you are
" doubting, and it comes out with the doubt.
func! GrooVim_PauseExecution(msg) abort
  echo "msg: \"" . a:msg . "\""
  while getchar() != 48
    exec "sleep 1000m"
  endwhile
endfunc

