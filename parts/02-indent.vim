"$$$$$$$$$$$$$$$$$$$$$$$$$$
"FILE SYNTAX ASSOCIATIONS AND SPECIFIC CONFIGURATION
"$$$$$$$$$$$$$

" Note: General indent width! By Questor
let g:GrooVim_IndentWidth = get(g:, "GrooVim_IndentWidth", 2)

" Note: Indent width per file type, the same idea of the "Tab Settings" per
" language of Notepad++, using the file type of Vim as the key. ONE line is
" enough to add your own: >
"   let g:GrooVim_IndentWidthPerType = {"python": 4, "javascript": 2}
" <
" Note: Only what is listed here is touched! Vim already ships file type plugins
" that know what they are doing, and some of them are not a matter of taste:
" "make" needs a REAL tab on its recipe lines (it fails with "missing separator"
" otherwise) and "go" is written with tabs by gofmt. Configuring EVERY type here
" would run after those plugins and undo them! By Questor
let g:GrooVim_IndentWidthPerType = get(g:, "GrooVim_IndentWidthPerType", {"python": 4})

" Note: The char that draws the indentation guides. Use "" to turn them off! By Questor
let g:GrooVim_IndentGuideChar = get(g:, "GrooVim_IndentGuideChar", "\u250A")

" Note: The char to come back to when the guides are turned on again. Without it,
" turning them off and on would forget the char you had chosen and hand you the
" factory one! By Questor
let g:GrooVim_IndentGuideCharLast = get(g:, "GrooVim_IndentGuideCharLast",
 \ g:GrooVim_IndentGuideChar != "" ? g:GrooVim_IndentGuideChar : "\u250A")

" Note: Whether "Tab" puts spaces or a real tab -- the "Replace by space" of the
" Tab Settings of Notepad++! By Questor
let g:GrooVim_IndentExpandTab = get(g:, "GrooVim_IndentExpandTab", 1)

" Note: Size of a hard tabstop! By Questor
exec "set tabstop=" . g:GrooVim_IndentWidth

" Note: Size of an "indent"! By Questor
exec "set shiftwidth=" . g:GrooVim_IndentWidth

" Note: A combination of spaces and tabs are used to simulate tab stops at a width
" other than the (hard) tabstop! By Questor
exec "set softtabstop=" . g:GrooVim_IndentWidth

" Note: Set tabs to spaces! By Questor
let &expandtab = g:GrooVim_IndentExpandTab

" Note: Indenting REACHES the next stop instead of adding a width to whatever was
" already there, which is how Notepad++ walks its tab stops: a line with 2 columns
" and a width of 8 goes to 8, not to 10. Unindenting comes back the same way.
"
" Note: Without it, "Tab" over a line with 2 columns gave 2, 10, 18, 26, because
" ">>" adds "shiftwidth" to the indent in place. Native to Vim, one option! By
" Questor
set shiftround

" Note: Draws the indentation guides with "leadmultispace", which is native to
" Vim and replaces what a plugin used to do here.
"
" Note: The width is NOT remembered by us, it is read from the standard Vim
" options at the moment of drawing. That way the guide follows a modeline, a file
" type plugin or a ":set shiftwidth=" you type, instead of drifting away from the
" real indent. Falling back to "tabstop" is what keeps "make" right, since its
" file type plugin leaves "shiftwidth" at zero! By Questor
func! GrooVim_IndentGuideSet() abort

  let l:listchars = "trail:\uB7,nbsp:~"

  if g:GrooVim_IndentGuideChar != ""
    let l:width = &shiftwidth > 0 ? &shiftwidth : &tabstop
    if l:width > 1
      let l:listchars = l:listchars . ",leadmultispace:" . g:GrooVim_IndentGuideChar . repeat(" ", l:width - 1)
    endif
  endif

  " Note: Assigning the option instead of using ":set" avoids having to escape
  " the spaces with a backslash! By Questor
  " Note: "leadmultispace" is from Vim 9, and "listchars" is only window local on
  " a recent enough Vim, so both are attempted and neither is fatal! By Questor
  try
    let &l:listchars = l:listchars
  catch
    try
      let &listchars = l:listchars
    catch
    endtry
  endtry

endfunc

" Note: General tab conf! By Questor
" Note: "setlocal" and not "set": this runs per buffer, and setting it globally
" made opening one file change the indent width of every other open buffer! By Questor
func! GrooVim_IndentWidthHere(tabWidth) abort

  " Note: Size of a hard tabstop! By Questor
  exec "setlocal tabstop=" . a:tabWidth

  " Note: Size of an "indent"! By Questor
  exec "setlocal shiftwidth=" . a:tabWidth

  " Note: A combination of spaces and tabs are used to simulate tab stops at a width
  " other than the (hard) tabstop! By Questor
  exec "setlocal softtabstop=" . a:tabWidth

  call GrooVim_IndentGuideSet()

endfun

" Note: The one knob for the indent width of the buffer you are on.
"
" Note: In GrooVim a width is THREE Vim options at once -- "tabstop",
" "shiftwidth" and "softtabstop" -- and they only mean what you expect while they
" agree. Setting one of them by hand leaves the editor half changed: the guides
" follow the new width and the Tab key keeps the old one.
"
" Note: With the three together, tabbing lands ON the width and then on twice it,
" from wherever the line already was -- 2 becomes 8, 8 becomes 16 -- which is how
" Notepad++ walks its tab stops. With ":set shiftwidth=8" alone it would go on
" walking two by two! By Questor
" Note: What a key really delivers, which is the only way to settle an argument
" about a shortcut that does not fire.
"
" Note: A terminal sends an arrow, an F key or a keypad key as a sequence of
" bytes, and two keys that LOOK the same can arrive as different keys -- the
" shortcuts of GrooVim compare what "getchar()" hands over, so that is what this
" prints! By Questor
com! GrooVimKey call GrooVim_KeyReport()

func! GrooVim_KeyReport() abort

  echo "GrooVim: press the key you want to look at..."
  let l:key = getchar()
  redraw

  " Note: A plain key comes back as a NUMBER and a special one as a String, which
  " is why the shortcuts compare against "\<Up>" and against "116" alike! By
  " Questor
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
    " down with it! By Questor
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

com! -nargs=? GrooVimIndent call GrooVim_IndentWidth(<q-args>)

" Note: A width EVERYWHERE: the default that new buffers get, and the one you are
" on. "GrooVim_IndentWidthHere" alone is "setlocal", which is what the command above
" wants -- but a screen that says "indent width" and leaves the next file you
" open on the old one would be lying! By Questor
func! GrooVim_IndentWidthApply(width) abort
  exec "set tabstop=" . a:width
  exec "set shiftwidth=" . a:width
  exec "set softtabstop=" . a:width
  call GrooVim_IndentWidthHere(a:width)
endfunc

func! GrooVim_IndentWidth(width) abort

  if a:width == ""
    call GrooVim_GrooVimBarMsg("The indent is " . &shiftwidth .
     \ " columns wide here. Use \"GrooVimIndent 4\" to change it!", 5)
    return
  endif

  if !GrooVim_IsPositiveNumber(a:width)
    call GrooVim_GrooVimBarMsg("\"" . a:width . "\" is not a width! Use a whole number above zero!", 5)
    return
  endif

  call GrooVim_IndentWidthHere(str2nr(a:width))
  call GrooVim_GrooVimBarMsg("The indent is " . &shiftwidth . " columns wide now!", 5)

endfunc

" Note: Applies the per file type width, and ONLY for what is listed. The guides
" are refreshed on window entry because "listchars" is window local.
"
" Note: And on "OptionSet", so that typing ":set shiftwidth=8" by hand moves the
" guides right then. Without it the width was read only when you entered the
" window, and a changed "shiftwidth" left the guides drawn at the OLD spacing
" until you walked out and back in! By Questor
augroup GrooVim_Indent
  autocmd!
  autocmd FileType * if has_key(g:GrooVim_IndentWidthPerType, &filetype) |
        \ call GrooVim_IndentWidthHere(g:GrooVim_IndentWidthPerType[&filetype]) | endif
  autocmd BufWinEnter,WinEnter * call GrooVim_IndentGuideSet()
  autocmd OptionSet shiftwidth,tabstop call GrooVim_IndentGuideSet()
augroup end

"  * .inc

autocmd! BufReadPost *.inc set syntax=html | set filetype=html

"  * .gds

autocmd! BufReadPost *.gds set syntax=vb | set filetype=vb

"$$$$$$$$$$$$$$$$$$$$$$$$$$

