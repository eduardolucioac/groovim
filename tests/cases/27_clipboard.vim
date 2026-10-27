" How a copy leaves this machine.
"
" GrooVim promises to work on a headless server reached by SSH, and there the
" only way out is OSC 52: an escape sequence the TERMINAL turns into a clipboard
" entry. No X, no Wayland, no tool to call.
"
" What this case guards is the question that decides whether it is used at all.
" Getting it wrong is silent: a copy simply never arrives, and nothing on screen
" says why.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

" Asks the question with a given terminal and a given environment, and puts both
" back afterwards, so one answer cannot decide the next.
func! GT_Asking(term, ...)
  let l:vars = a:0 > 0 ? a:1 : {}
  let l:keptTerm = &term
  let l:kept = {}
  for l:name in ["SSH_TTY", "SSH_CONNECTION", "KONSOLE_VERSION", "TMUX",
    \ "TERM_PROGRAM", "VTE_VERSION", "KITTY_WINDOW_ID"]
    let l:kept[l:name] = eval("$" . l:name)
    exec "let $" . l:name . " = ''"
  endfor
  for [l:name, l:value] in items(l:vars)
    exec "let $" . l:name . " = '" . l:value . "'"
  endfor

  let &term = a:term
  let l:answer = GrooVim_TerminalDoesOSC52()

  let &term = l:keptTerm
  for [l:name, l:value] in items(l:kept)
    exec "let $" . l:name . " = '" . l:value . "'"
  endfor
  return l:answer
endfunc

" Vim refuses an empty "term" outright, which is why the code does not look for
" one. Proved here rather than assumed, because it is the reason a branch is
" missing.
func! GT_TermRefusesEmpty()
  let l:kept = &term
  try
    let &term = ""
    let &term = l:kept
    return 0
  catch /E529/
    return 1
  catch
    let &term = l:kept
    return 0
  endtry
endfunc

" ---- there is a terminal, so it is tried
"
" This used to be a list of terminals that name themselves in their own
" environment: $KONSOLE_VERSION, $VTE_VERSION, $TERM_PROGRAM. A list like that is
" never finished -- VTE alone covers GNOME, XFCE, MATE and Terminator, but COSMIC
" is not VTE and whatever is written next will not be there either. Every one of
" them answered "no" by default, and here a "no" is silent.
"
" The two mistakes are not the same size: the sequence costs nothing when it is
" not understood, and costs the copy when it is not sent.
for s:term in ["xterm-256color", "xterm", "linux", "foot", "screen-256color",
  \ "rxvt-unicode-256color", "alacritty", "contour", "st-256color",
  \ "xfce4-terminal", "cosmic-term", "terminal-nobody-has-written-yet"]
  call GT_Ok("[" . s:term . "] is a terminal, so we try", GT_Asking(s:term) == 1, "")
endfor

" ---- and this is the check that refuses a list
call GT_Ok("with NOTHING in the environment, we still try",
  \ GT_Asking("xterm-256color", {}) == 1,
  \ "   (no KONSOLE_VERSION, no VTE_VERSION, no TERM_PROGRAM, no TMUX, no SSH)")
call GT_Ok("  and a terminal nobody has heard of is not worse off",
  \ GT_Asking("something-new", {}) == GT_Asking("xterm-256color", {"KONSOLE_VERSION": "260801"}),
  \ "   (the answer cannot depend on being on a list)")

" ---- what there is no point in trying
call GT_Ok("a dumb terminal is taken at its word", GT_Asking("dumb") == 0, "")
call GT_Ok("  and there is no emptier case to guard",
  \ GT_TermRefusesEmpty() == 1,
  \ "   (Vim answers E529 to an empty \"term\", so the code does not test for one)")

" ---- the register a copy goes to
call GT_Ok("the register is one Vim knows",
  \ index(["+", "*", "\""], GrooVim_ClipReg()) >= 0,
  \ "   [" . GrooVim_ClipReg() . "]   (clipmethod " .
  \ (exists("v:clipmethod") ? v:clipmethod : "-") . ")")

if exists("+clipmethod")
  call GT_Ok("osc52 is in the cascade", &clipmethod =~ "osc52",
    \ "   [" . &clipmethod . "]")
  call GT_Ok("  and it is the LAST of them", &clipmethod =~ "osc52$",
    \ "   [" . &clipmethod . "]   (a machine with a clipboard of its own, or a tool to call, never reaches it)")
endif

" ---- paste through OSC 52 stays off
"
" A paste asks the terminal and waits for an answer many never send, and Vim
" blocks until Ctrl-C. Copy is what crosses SSH; reading back is not worth
" hanging the editor for.
call GT_Ok("OSC 52 paste is off", get(g:, "osc52_disable_paste", 0) == 1, "")

" ---- a copy that cannot be confirmed keeps a local one as well
"
" A copy through OSC 52 goes out as an escape sequence and the terminal is never
" heard from again. The paste back is off, so the "+" register answers empty to
" everything on top of that. Measured on a machine with no clipboard of its own:
" "getreg('+')" came back empty while the file held the text, and GrooVim_ClipGet
" returned nothing at all.
"
" Without a real OSC 52 method in use here, what can be checked is the rule
" itself and that the two ends agree with it.
call GT_Ok("the assumed case has a name", exists("*GrooVim_ClipAssumed"), "")
call GT_Ok("  and it answers for the method in use",
  \ GrooVim_ClipAssumed() == (v:clipmethod ==# "osc52"),
  \ "   (clipmethod " . v:clipmethod . ")")
call GT_Ok("a copy keeps the file when it cannot be confirmed",
  \ !empty(filter(GT_SourceLines(),
  \   'v:val =~ "GrooVim_ClipAssumed()" && v:val =~ "^\\s*if"')),
  \ "   (asked in ClipSet and in ClipGet)")

" ---- the file itself: what a copy falls back to, and who can read it
call delete(g:GrooVim_ClipFile)
call GrooVim_ClipFileSet("um texto privado")
call GT_Ok("the file takes a copy", GrooVim_ClipFileGet() ==# "um texto privado",
  \ "   [" . g:GrooVim_ClipFile . "]")
call GT_Ok("  and only its owner can read it",
  \ getfperm(g:GrooVim_ClipFile) ==# "rw-------",
  \ "   (" . getfperm(g:GrooVim_ClipFile) . ")   (a clipboard carries private things)")
call delete(g:GrooVim_ClipFile)

" ---- GrooVim asks for Vim 9.2, and says so in one place
"
" It is the version install.sh builds, and GrooVim is reached only through the
" "groovim" command, which runs that Vim. The clipboard depends on what arrived
" in 9.2: v:clipproviders, clipmethod, :clipreset and the osc52 package. Four
" "exists()" used to guard those, carrying a Vim this project refuses to run on;
" one sentence in the .vimrc replaced them.
call GT_Ok("this Vim is 9.2 or newer", v:version >= 902,
  \ "   (" . (v:version / 100) . "." . (v:version % 100) . ")")
call GT_Ok("and the 9.2 things are simply there, unguarded",
  \ exists("v:clipproviders") && exists("+clipmethod") && exists("v:clipmethod"), "")
call GT_Ok("no exists() left carrying an older Vim",
  \ empty(filter(GT_SourceLines(),
  \   'v:val =~ "exists(\"v:clipproviders\")" || v:val =~ "exists(\"+clipmethod\")"')),
  \ "   (the .vimrc says it once instead)")
" ---- the option that makes a plain "y" reach the clipboard
"
" This is the whole of it: measured, with "clipboard" emptied by hand, a "yy"
" left the text in the unnamed register and "@+" came back empty; with it set,
" "@+" holds the line.
"
" And one branch is all it takes. There was a second one for the "*" register
" and a "try" around both, and neither can happen on the Vim this builds: read
" in "evalfunc.c", "clipboard_working" is true when the method is a provider or
" when the X or Wayland selection is available, and "unnamedplus" is true when
" X11 or the Wayland clipboard was compiled in and also when the method is a
" provider -- each of the two ways of reaching that line makes the other true,
" so the register is never "*". And the option always exists: Vim defines it
" whenever "+clipboard" OR "+eval" is there.
let g:GT_CB_WAS = &clipboard
set clipboard=
call GrooVim_ClipSyncOption()
call GT_Ok("the option is put back by the function that owns it",
  \ &clipboard =~ "unnamedplus", "   [" . &clipboard . "]")
call GT_Ok("  and on a Vim with no \"+clipboard\" it is the provider that answers",
  \ GT_FunctionText("GrooVim_ClipReg") =~ "clipproviders",
  \ "   (measured on a build made for it, \"-clipboard -wayland -X11\": GrooVim\n" .
  \ "    loaded with no error, \"v:clipmethod\" came out \"osc52\", a \"yy\" landed\n" .
  \ "    in the clipboard register, and \"clipboard_working\" answered 0 the\n" .
  \ "    whole time -- that answer lives inside \"#ifdef FEAT_CLIPBOARD\")")
call GT_Ok("  and it asks the cascade which register that is",
  \ GT_FunctionText("GrooVim_ClipSyncOption") =~ "GrooVim_ClipReg",
  \ "   (has(\"clipboard_working\") is true wherever anything at all answered,\n" .
  \ "    so it cannot tell WHICH register to write down)")
call GT_Ok("  in one branch, with no \"try\" around it",
  \ GT_FunctionText("GrooVim_ClipSyncOption") !~ "unnamed\\>" ||
  \ GT_FunctionText("GrooVim_ClipSyncOption") !~ "try",
  \ "   [" . substitute(GT_FunctionText("GrooVim_ClipSyncOption"), "\n", " ", "g") . "]")
call GT_Ok("and the register it answers is never \"*\"",
  \ GrooVim_ClipReg() !=# "*" &&
  \ GT_FunctionText("GrooVim_ClipReg") !~ 'unnamedplus") ?',
  \ "   [" . GrooVim_ClipReg() . "]   (the line that chose between the two is\n" .
  \ "    gone: it asked a question that cannot answer no where it was asked)")
let &clipboard = g:GT_CB_WAS

" ---- a tool is only a tool where it can work
"
" Being INSTALLED is not the same as being able to work: "wl-copy" without a
" compositor fails -- measured, it exits 1 saying the socket is not there. The
" question used to be only "is the binary there?", so on a machine where
" "wl-clipboard" happened to be installed the cascade stopped on a provider that
" could not copy anything, on the very session where the next one would have
" crossed an SSH by itself: measured, "v:clipmethod" coming out "groovim" with
" no WAYLAND_DISPLAY and no DISPLAY, and "osc52" once this was asked as well.
call GT_Ok("every tool of the list says which session it talks to",
  \ len(filter(copy(g:GrooVim_ClipTools), 'has_key(v:val, "needs")')) ==
  \   len(g:GrooVim_ClipTools),
  \ "   " . string(map(copy(g:GrooVim_ClipTools), 'v:val.copy[0] . " -> " . v:val.needs')))

let g:GT_TOOLS_WERE = copy(g:GrooVim_ClipTools)
let g:GrooVim_ClipTools = [{"copy": ["sh"], "paste": ["sh"],
  \ "needs": "GROOVIM_NO_SUCH_SESSION"}]
call GT_Ok("  and one whose session is not here is not chosen",
  \ empty(GrooVim_ClipToolFind()),
  \ "   (the binary is there -- \"sh\" -- and the session is not)")
let g:GrooVim_ClipTools = [{"copy": ["sh"], "paste": ["sh"]}]
call GT_Ok("  while one with no session written down is taken as it always was",
  \ !empty(GrooVim_ClipToolFind()),
  \ "   (a list of your own from before this is still a list)")
let g:GrooVim_ClipTools = g:GT_TOOLS_WERE

" And it is not asked again while you type.
"
" The Vim of GrooVim is the one install.sh builds, and the "groovim" command is
" the only way in -- so the number is decided at install time and there is
" nothing a running GrooVim could do about it anyway. It used to say so on
" startup, which is a message nobody can act on in the one place they cannot act
" on it. It is written where it can be read BEFORE installing instead.
call GT_Ok("nothing checks the version while you type",
  \ empty(filter(readfile($GROOVIM_TEST_VIMRC), 'v:val =~ "v:version < 902"')),
  \ "   (install.sh refuses to go on below it, and the README says so)")
if !GT_Project()
  call GT_NotTheProject("the README on the version")
else
  call GT_Ok("  and the README says which Vim GrooVim asks for",
    \ !empty(filter(readfile(fnamemodify($GROOVIM_TEST_VIMRC, ":h") . "/README.md"),
    \   'v:val =~ "asks for Vim 9.2 or newer"')), "")
endif

let g:GT_Install = fnamemodify($GROOVIM_TEST_VIMRC, ":h") . "/install.sh"
if filereadable(g:GT_Install)
  call GT_Ok("  and install.sh asks for the same number",
    \ !empty(filter(readfile(g:GT_Install), 'v:val =~ "^readonly MINIMUM_VERSION=902"')),
    \ "   (one number, two places, and they have to agree)")
endif

" ---- pasting goes through the clipboard of GrooVim, not through the register
"
" With OSC 52 in use the "+" register cannot be read back, and
" "clipboard=unnamedplus" makes a plain "P" read exactly that register: it
" answered "E353: Nothing in register +" with the text sitting in the file the
" whole time. Every paste key goes through GrooVim_ClipPaste now.
for s:pair in [["p", "n"], ["\<C-v>", "n"], ["\<C-v>", "i"], ["p", "v"], ["\<C-v>", "v"]]
  call GT_Ok("[" . s:pair[1] . "] " . strtrans(s:pair[0]) . " goes through GrooVim_ClipPaste",
    \ maparg(s:pair[0], s:pair[1]) =~ "GrooVim_ClipPaste",
    \ "   [" . maparg(s:pair[0], s:pair[1]) . "]")
endfor

" ---- and it really pastes
exec "edit! " . g:GT_OUT . "/paste_me.txt"
%delete _
call GrooVim_ClipSet("VEIO DA AREA")
call feedkeys("i\<C-v>\<Esc>", "x")
call GT_Ok("Ctrl-V pastes what was copied", getline(1) =~ "VEIO DA AREA",
  \ "   [" . getline(1) . "]")

" ---- and with nothing to paste it SAYS so instead of failing
%delete _
call delete(g:GrooVim_ClipFile)
call setreg("+", "")
call setreg("\"", "")
let g:GrooVim_GrooVimBarMsgValue = ""
call feedkeys("i\<C-v>\<Esc>", "x")
call GT_Ok("with nothing to paste it says so",
  \ g:GrooVim_GrooVimBarMsgValue =~? "nothing\\|Ctrl-Shift-V",
  \ "   [" . g:GrooVim_GrooVimBarMsgValue . "]   (it used to be E353)")
call GT_Ok("  and the message fits on one line",
  \ strchars(g:GrooVim_GrooVimBarMsgValue) <= 72,
  \ "   (" . strchars(g:GrooVim_GrooVimBarMsgValue) . " characters)   (a message that runs off the bar leaves only its tail)")
call GT_Ok("  and the document was not touched", getline(1) ==# "",
  \ "   [" . getline(1) . "]")

" ---- a paste lands where TYPING the same thing would land
"
" The yardstick is the paste of the terminal -- the Ctrl+Shift+V you are left
" with over an SSH -- which types the characters in. Measured through a real
" terminal, with bracketed paste against this: the same line and the same
" column, with and without a line break in what was pasted.
func! GT_Colou(valor, teclas)
  exec "enew!"
  call setline(1, "abc`def`,gh")
  call cursor(1, 5)
  call GrooVim_ClipSet(a:valor)
  call feedkeys(a:teclas, "x")
  return join(getline(1, "$"), " / ") . "  col=" . col(".") . " linha=" . line(".")
endfunc

let s:digitado = GT_Colou("XY", "iXY")
call GT_Ok("pasting lands where typing lands",
  \ GT_Colou("XY", "i\<C-v>") ==# s:digitado,
  \ "   [" . GT_Colou("XY", "i\<C-v>") . "] against [" . s:digitado . "]")

" A text that ends in a line break makes "setreg()" call the register LINEWISE,
" and a linewise paste opens a line of its OWN above the cursor instead of
" landing on it. Measured before it was said "v": "XY" came out alone on the line
" before, and what was under the cursor never moved.
let s:digitado = GT_Colou("XY\n", "iXY\<CR>")
call GT_Ok("  and so does one that ends in a line break",
  \ GT_Colou("XY\n", "i\<C-v>") ==# s:digitado,
  \ "   [" . GT_Colou("XY\n", "i\<C-v>") . "] against [" . s:digitado . "]")

call GT_Ok("  and the register is said CHARACTERWISE, not guessed",
  \ GT_FunctionText("GrooVim_PasteText") =~ 'setreg("z", l:text, "v")',
  \ "   (what ends in a line break would be guessed linewise)")

" ---- and the paste of the TERMINAL lands where this one lands
"
" Over SSH, and on any terminal whose clipboard Vim cannot read, Ctrl-Shift-V is
" the paste there is -- so the two have to put the text in the same place.
" Measured through a terminal, the cursor on the second quote of "grep -iFl \'\'":
" Ctrl-V left "\'google-chrome\'", the text where the cursor is, and the terminal
" left "\'\'google-chrome", one character further on. Vim pastes what arrives in
" normal mode like a "p", and "p" is "after the character you are on".
exec "enew!"
call setline(1, ["grep -iFl '' -- {}"])
call cursor(1, 12)
call GrooVim_ClipSet("google-chrome")
call GrooVim_ClipPaste("n")
call GT_Ok("the paste lands where the cursor IS, in normal mode too",
  \ getline(1) ==# "grep -iFl 'google-chrome' -- {}",
  \ "   [" . getline(1) . "]")
call GT_Ok("  and the cursor ends after what was pasted",
  \ col(".") == 25, "   (column " . col(".") . ")")

" A terminal says where a paste BEGINS and where it ENDS, and Vim gives those
" two moments a key of their own. The beginning can be answered; the END cannot
" -- Vim swallows it inside its own paste, and a mapping on it is never reached.
" Measured: the start fired, the end never did, and what came out of a paste
" begun in normal mode was INSERT mode, still typing. So the text is read here,
" key by key, and pasted by the one function that pastes.
call GT_Ok("and the paste of the terminal is answered in normal mode",
  \ maparg("<PasteStart>", "n") =~ "GrooVim_PasteFromTerminal",
  \ "   [" . maparg("<PasteStart>", "n") . "]")
call GT_Ok("  and nothing is mapped on it in INSERT mode",
  \ maparg("<PasteStart>", "i") ==# "",
  \ "   (there the cursor is BETWEEN characters: Vim already lands on it)")
call GT_Ok("  and it reads until the END key and pastes what it read",
  \ GT_FunctionText("GrooVim_PasteFromTerminal") =~ "getchar()" &&
  \ GT_FunctionText("GrooVim_PasteFromTerminal") =~ "PasteEnd" &&
  \ GT_FunctionText("GrooVim_PasteFromTerminal") =~ "GrooVim_PasteText",
  \ "   (the two doors into one room, so they cannot land apart)")
call GT_Ok("  and a line break inside it arrives as a carriage return",
  \ GT_FunctionText("GrooVim_PasteFromTerminal") =~ '"\\r" ? "\\n"',
  \ "   (which is how a terminal sends one)")

exec "enew!"
call setline(1, ["abc"])
call cursor(1, 3)
call GrooVim_PasteText("XY", "n")
call GT_Ok("  and both doors write through the same one",
  \ getline(1) ==# "abXYc",
  \ "   [" . getline(1) . "]   (GrooVim_PasteText, whoever called)")

" ---- and Ctrl+V reaches the COMMAND LINE, where every question is answered
"
" A path you have in your hand is the commonest answer there is, and it had to
" come in through the paste of the TERMINAL: <Ctrl-v> there is the "insert the
" next character literally" of Vim, which ate the <Enter> that came after it and
" left a ^M on the line, so the question never ended. <Ctrl-q> is the other name
" Vim gives that same function and is untouched.
call GT_Ok("Ctrl+V pastes into the command line too",
  \ maparg("<C-v>", "c") =~ "GrooVim_ClipLine",
  \ "   [" . maparg("<C-v>", "c") . "]")

call GrooVim_ClipSet("/tmp/um/caminho.txt\n")
call GT_Ok("  and the line break a pasted path carries is dropped",
  \ GrooVim_ClipLine() ==# "/tmp/um/caminho.txt",
  \ "   [" . strtrans(GrooVim_ClipLine()) . "]   (a command line has nowhere to put one)")

" And the same at the door every question goes through, for the paste of the
" terminal, which GrooVim never sees: it arrives as a ^@ at the end of the
" answer -- measured, and the file was then looked for under a name with a NUL
" in it.
call GT_Ok("  and so is the one the terminal's own paste leaves",
  \ GT_FunctionText("GrooVim_Ask") =~ "substitute(l:answer",
  \ "   (every question of GrooVim goes through that one door)")
call GT_Ok("  with the pattern in SINGLE quotes, which is not a taste",
  \ GT_FunctionText("GrooVim_Ask") =~ "'\\[.r.n\\].+\\$'" &&
  \ GT_FunctionText("GrooVim_ClipLine") =~ "'\\[.r.n\\].+\\$'",
  \ "   (between double ones \"\\+\" is just a plus, and it matched nothing)")

" ---- and a file DROPPED on the window comes in through that same door
"
" A terminal has no other way to say it: Konsole turns a drop into text -- each
" path through "KShell::quoteArg", and, in the words of its own source, "Each
" filename(including the last) should be followed by one space" -- and pastes
" it. Measured through a terminal before this: the path landed in the file as
" text, which is not what a hand that drags a file onto an editor is asking for.
"
" The space at the end is the password. A drop and a paste of the same path are
" the SAME BYTES, so what is left to tell them apart is that Konsole puts a
" space after every name and a hand that copies a path does not.
let s:um = g:GT_FIX . "/a.txt"
let s:dois = g:GT_FIX . "/b.txt"
call GT_Ok("a dropped path is read as a path",
  \ GrooVim_DropPaths(s:um . " ") ==# [s:um],
  \ "   " . string(GrooVim_DropPaths(s:um . " ")))
call GT_Ok("  and without the space at the end it is only text",
  \ GrooVim_DropPaths(s:um) ==# [],
  \ "   (a path you copied and pasted goes on being pasted)")
call GT_Ok("  and a name that is not THERE is only text as well",
  \ GrooVim_DropPaths(g:GT_FIX . "/nao-existe.txt ") ==# [],
  \ "   (every word has to be a file that can be read)")
call GT_Ok("  and a line break says it is not a drop",
  \ GrooVim_DropPaths(s:um . " \n") ==# [],
  \ "   (what a terminal drops is one line)")
call GT_Ok("  and two files come back as two",
  \ GrooVim_DropPaths(s:um . " " . s:dois . " ") ==# [s:um, s:dois],
  \ "   " . string(GrooVim_DropPaths(s:um . " " . s:dois . " ")))

" A name with a space in it arrives QUOTED, which is what KShell::quoteArg does
" with anything that is not a plain word -- and inside the quotes a quote of its
" own is written |'\''| .
call GT_Ok("  and a quoted name is ONE file and not two",
  \ GrooVim_DropWords("'/um/com espaco.txt' ") ==# ["/um/com espaco.txt"],
  \ "   " . string(GrooVim_DropWords("'/um/com espaco.txt' ")))
call GT_Ok("  and the quote inside a quoted name comes back",
  \ GrooVim_DropWords("'/um/com'\\''aspa.txt' ") ==# ["/um/com'aspa.txt"],
  \ "   " . string(GrooVim_DropWords("'/um/com'\\''aspa.txt' ")))
call GT_Ok("  and half a quoted name is no name at all",
  \ GrooVim_DropWords("'/um/sem fim ") ==# [],
  \ "   (a text that ends inside a quote did not come from a drop)")

call GT_Ok("and the door of the terminal's paste asks about it first",
  \ GT_FunctionText("GrooVim_PasteFromTerminal") =~ "GrooVim_DropPaths" &&
  \ GT_FunctionText("GrooVim_PasteFromTerminal") =~ "GrooVim_DropOpen",
  \ "   (and a no goes on to paste the text, which is what the n is for)")

" And the question itself, answered. One tab for each file, which is where the
" open files of GrooVim live -- and the default is yes, because a drop is a
" thing you did with your hand and not something that happened to you.
silent! tabonly!
exec "enew!"
call setline(1, "ja escrevi aqui")
let s:tabsWere = tabpagenr("$")
call feedkeys("y\<CR>", "t")
let s:took = GrooVim_DropOpen([s:um, s:dois])
call GT_Ok("a yes opens one tab for each file", s:took == 1 &&
  \ tabpagenr("$") == s:tabsWere + 2,
  \ "   (" . tabpagenr("$") . " tabs, from " . s:tabsWere . ")" .
  \ "   (something was typed on this page, so neither file covers it --\n" .
  \ "    the empty \"new 1\" has a block of its own further down)")
call GT_Ok("  and it says so on the bar",
  \ g:GrooVim_GrooVimBarMsgValue =~ "2 files are open",
  \ "   [" . trim(g:GrooVim_GrooVimBarMsgValue) . "]")

silent! tabonly!
exec "enew!"
let s:tabsWere = tabpagenr("$")
call feedkeys("n\<CR>", "t")
let s:took = GrooVim_DropOpen([s:um])
call GT_Ok("and a no opens nothing, so the text is pasted instead",
  \ s:took == 0 && tabpagenr("$") == s:tabsWere,
  \ "   (" . tabpagenr("$") . " tabs)")
silent! tabonly!

" ---- and the first file dropped takes the "new 1" that is already there
"
" One tab, one document, with no name, nothing typed in it: the page GrooVim
" hands you when it opens with no file. A second tab beside a page nobody wrote
" in is a tab too many, and Notepad++ (inspiration) does the same with a file
" dropped on an empty window.
silent! tabonly!
exec "enew!"
call GT_Ok("an empty \"new 1\" alone is a fresh page",
  \ GrooVim_FreshPageWindow() == winnr(),
  \ "   (window " . GrooVim_FreshPageWindow() . " of " . winnr("$") . ")")
call setline(1, "ja escrevi aqui")
call GT_Ok("  and a page with something typed in it is not",
  \ GrooVim_FreshPageWindow() == 0, "   (what you wrote is not to be covered)")
exec "enew!"
exec "edit! " . s:um
call GT_Ok("  and neither is a page with a FILE in it",
  \ GrooVim_FreshPageWindow() == 0, "   [" . fnamemodify(bufname("%"), ":t") . "]")
exec "enew!"
tabnew
call GT_Ok("  and neither is one tab out of two",
  \ GrooVim_FreshPageWindow() == 0, "   (" . tabpagenr("$") . " tabs)")

silent! tabonly!
exec "enew!"
call feedkeys("y\<CR>", "t")
call GrooVim_DropOpen([s:um])
call GT_Ok("a file dropped on it opens IN it, and not beside it",
  \ tabpagenr("$") == 1 && expand("%:t") ==# "a.txt",
  \ "   (" . tabpagenr("$") . " tabs, [" . expand("%:t") . "])")

silent! tabonly!
exec "enew!"
call feedkeys("y\<CR>", "t")
call GrooVim_DropOpen([s:um, s:dois])
call GT_Ok("  and of two dropped, the first takes it and the other opens beside",
  \ tabpagenr("$") == 2,
  \ "   (" . tabpagenr("$") . " tabs)   (one tab each, as asked)")
silent! tabonly!
exec "enew!"

call GT_Done()
