" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
" GENERAL BEHAVIOR
" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" Note: The file type of what you open, and what Vim reads because of it: the
" syntax of the language, the indent rules of the language, and the plugin of
" the language.
"
" Note: It was written in the ".vimrc", under the section about where GrooVim
" lives and which parts it loads, and it is neither of those: it is how Vim
" behaves, which is this file. It stays FIRST among the parts, because this is
" the first one the ".vimrc" reads and the parts that set an indent or a syntax
" come after it.
"
" Note: The line that carried it said "after the plugins loaded", and that has
" not been true for as long as GrooVim has had its own Vim: packages under
" "pack/*/start" are loaded when the ".vimrc" has been read to its end, so
" anything written IN it runs before them, wherever in it that is.
filetype plugin indent on

" Note: The mouse: clicking, selecting and the wheel, in every mode.
set mouse=a

" Note: "Esc" answers AT ONCE.
"
" A terminal sends an arrow or an F key as a run of bytes that begins with the
" very same "Esc", so Vim waits to see whether more is coming -- and with no
" "ttimeoutlen" set it waits "timeoutlen", a whole second. Pressing Esc showed
" "^[" in the corner and nothing happened until the second was up. This is the
" wait for the REST OF A KEY, which a keyboard sends in one go; it is not the
" wait for the second key of a shortcut, which is a hand travelling and has its
" own patience in "g:GrooVim_CommandZWait".
"
" This wait is also how long the cursor sits in the WRONG column every time you
" leave insert mode. Vim steps one column left on the way out, paints it, and
" only when the wait is over does it finish the key and run what GrooVim hangs
" on "InsertLeave", which puts the column back.
"
" And the other side of the same number, measured by feeding an arrow one byte
" at a time: the key falls apart when its bytes arrive further apart than this.
" A keyboard sends the whole run in one go and a link is what can tear it
" -- and a torn arrow in insert mode does not move the cursor, it TYPES "[B"
" into the file.
"
" 50, which is where those two meet: half the jump of a tenth of a second
" that could be seen, against a tearing that asks for a link so slow that the
" bytes of ONE key arrive twenty of these apart. If an arrow ever writes letters
" over a bad line, this is the one number to raise.
set ttimeout
set ttimeoutlen=50

" Note: The "transfer area" (clipboard) is reached through a cascade, so that
" GrooVim depends on NO external package and works with no graphical session at
" all (think of a headless server reached by SSH).
"
"   1. The native clipboard, as Vim was built with a working "+clipboard";
"   2. "OSC 52", an escape sequence that carries the clipboard THROUGH the
"      terminal itself. It needs no X11, no Wayland and no desktop, it crosses
"      SSH, and Vim 9.2 already ships the "osc52" package (nothing to install);
"   3. A file shared between Vim instances, which always works, even on a bare
"      tty with a terminal that speaks nothing;
"   4. The unnamed register, our last resort.

" There is nothing to configure about OSC 52, and getting to that took a long
" argument. It is the LAST method of the cascade, so reaching it means
" Wayland, X11 and every tool have already failed -- and from there every knob
" could only SUBTRACT:
"
"   turning it off      leaves the file of GrooVim and nothing going out
"   asking the terminal leaves "clipmethod=none" whenever it does not answer,
"                       which is most terminals, so: nothing at all
"
" Neither has a case where it leaves anyone better off, so neither is offered.
" GrooVim assumes OSC 52 and keeps its own copy in a file beside it -- see
" "GrooVim_ClipAssumed".
"
" An OSC 52 PASTE makes Vim block waiting for an answer that many terminals
" never send (Ctrl-C cancels it). Copy is what we really want here, so paste
" stays off unless you know your terminal answers.
let g:osc52_disable_paste = get(g:, "osc52_disable_paste", 1)

" Note: Should OSC 52 be tried at all? The honest answer is that we cannot know
" whether this terminal does it, and that asking was the wrong question.
"
" The two mistakes are not the same size. Sending the sequence to a terminal
" that does not know it costs nothing, because an unknown OSC is swallowed. NOT
" sending it to one that does costs the copy. So the default is to try, and the
" question is only whether there is a terminal to try on.
"
" It is also the LAST method: "clipmethod" is "wayland,x11,groovim,osc52", so a
" machine with a clipboard of its own, or a tool to call, never reaches it. And
" there is no switch to turn it off, because there was never a situation in
" which turning it off left anyone better off.
func! GrooVim_TerminalDoesOSC52() abort

  " Note: Under a GUI there is no terminal for the sequence to reach.
  if has("gui_running")
    return 0
  endif

  " Note: A terminal that says it can do nothing is taken at its word. Only
  " "dumb" is tested: Vim refuses to set "term" to an empty string at all
  " ("E529"), so there is no such case to guard against.
  if &term ==# "dumb"
    return 0
  endif

  return 1
endfunc

" Note: NOT a setting of GrooVim. It belongs to the "osc52" package that ships
" with Vim, and the name is the package's: it reads "force available", which
" describes the 1 and not the choice. Read it as "do not check".
"
" GrooVim sets it to 1, and that is a decision and not a preference, because 0
" is unusable here. With 0 the package sends a DA1 query and believes only an
" answer advertising "52" -- and the terminals that do OSC 52 WITHOUT ever
" announcing it are most of them, Konsole included. So a Vim that checks
" concludes there is no support on a terminal where it works perfectly well,
" and the copy never leaves the machine. Checking, here, is a worse answer than
" not checking.
"
" The query itself, from the package: SendDA1() is called as it starts, and
" inside it is "if !has('gui_running') && !get(g:, 'osc52_force_avail', 0)". The
" call happens and the sequence is NOT sent while this is 1 -- with our value,
" Vim never consults the terminal at all.
"
" Written here, after the function it calls, and not at the top of the file: a
" "let" up there would run before that function exists ("E117").
let g:osc52_force_avail = get(g:, "osc52_force_avail", GrooVim_TerminalDoesOSC52())

" Note: OSC 52 into the cascade, at the end of it. This was a function for a
" while, so that a question on the settings screen could turn it off and on
" again without a restart. The question is gone and so is the off: what is left
" runs once, as GrooVim loads.
try
  packadd osc52
  if &clipmethod !~ "osc52"
    set clipmethod+=osc52
  endif

  " Note: Makes Vim pick a clipmethod again now that the provider exists.
  silent! clipreset

catch
endtry

" Note: A clipboard provider backed by an external tool, used ONLY when the tool
" is ALREADY installed. This is what makes PASTE from another application work:
" OSC 52 carries a copy out through the terminal, but reading back would require
" the terminal to ANSWER a query, and almost none of them do it (on purpose: a
" remote program could steal your clipboard), so Vim would just block waiting.
"
" Nothing here is a requirement of GrooVim. With no tool around, this provider
" reports itself unavailable and the cascade simply goes on to OSC 52.
" Note: "needs" is the session the tool talks to, and being INSTALLED is not the
" same as being able to work: "wl-copy" without a compositor fails -- measured,
" it exits 1 saying the socket is not there. Without this the cascade stopped on
" a provider that cannot copy anything, on the very machine where the next one
" (OSC 52) would have crossed the SSH by itself: measured, "v:clipmethod" coming
" out "groovim" with no WAYLAND_DISPLAY and no DISPLAY, because "wl-clipboard"
" happened to be installed there.
let g:GrooVim_ClipTools = get(g:, "GrooVim_ClipTools", [
      \ {"copy": ["wl-copy", "--type", "text/plain"],
      \  "paste": ["wl-paste", "--no-newline", "--type", "text/plain"],
      \  "needs": "WAYLAND_DISPLAY"},
      \ {"copy": ["xclip", "-selection", "clipboard"],
      \  "paste": ["xclip", "-selection", "clipboard", "-o"],
      \  "needs": "DISPLAY"},
      \ {"copy": ["xsel", "--clipboard", "--input"],
      \  "paste": ["xsel", "--clipboard", "--output"],
      \  "needs": "DISPLAY"},
      \ ])

" Note: A directory of YOUR own where a clipboard tool can be dropped by hand,
" for a machine where you cannot (or would rather not) use the package manager.
" What is found here wins over "$PATH".
"
" The first tool that is actually there wins, and a hand placed one comes
" before the one from "$PATH".
"
" GrooVim ships NO binary and never will: a Linux executable is not portable
" between machines (it is built for one architecture and linked against one
" libc, and "wl-copy" also needs libwayland-client at run time), so carrying one
" is your call and your responsibility. Note as well that on a headless server
" there is no compositor for "wl-copy" to talk to: there the answer is OSC 52,
" which already crosses SSH by itself.
let g:GrooVim_ClipBinDir = get(g:, "GrooVim_ClipBinDir", g:GrooVim_Home . "/bin")

" Note: Jobs are required: see GrooVim_ClipToolCopy() for why a "system()" call
" would freeze Vim on every copy. Without them we simply do not offer this
" provider and the cascade goes on to OSC 52.
func! GrooVim_ClipToolFind() abort
  if !exists("*job_start")
    return {}
  endif
  for l:dir in [g:GrooVim_ClipBinDir, ""]
    for l:tool in g:GrooVim_ClipTools
      " Note: A tool of a session that is not here is not a tool. A list of your
      " own with no "needs" written in it is taken as it always was.
      let l:needs = get(l:tool, "needs", "")
      if l:needs !=# "" && empty(eval("$" . l:needs))
        continue
      endif

      let l:copy = copy(l:tool["copy"])
      let l:paste = copy(l:tool["paste"])
      if l:dir != ""
        let l:copy[0] = l:dir . "/" . l:copy[0]
        let l:paste[0] = l:dir . "/" . l:paste[0]
      endif
      if executable(l:copy[0]) && executable(l:paste[0])
        return {"copy": l:copy, "paste": l:paste}
      endif
    endfor
  endfor
  return {}
endfunc

let g:GrooVim_ClipTool = {}

" Note: The tool takes the clipboard ASYNCHRONOUSLY, so right after a copy the
" system clipboard can still report the PREVIOUS content. That matters because
" GrooVim itself copies and then reads the value straight back: duplicating a
" line or a selection, and searching or replacing what is selected. Without this
" they would silently use whatever was in the clipboard BEFORE.
"
" So what we wrote is remembered and served until the tool catches up. The
" window is short and closes as soon as a read agrees with what we wrote, or at
" the latest after "g:GrooVim_ClipCacheMs".
let g:GrooVim_ClipCacheMs = get(g:, "GrooVim_ClipCacheMs", 300)
let g:GrooVim_ClipCache = ""
let g:GrooVim_ClipCachePending = 0

func! GrooVim_ClipCacheClear(...) abort
  let g:GrooVim_ClipCachePending = 0
endfunc

" Note: A trailing line break is what tells a LINEWISE copy from a charwise one.
func! GrooVim_ClipToText(text) abort
  if a:text =~ "\n$"
    return ["V", split(a:text, "\n", 1)[0:-2]]
  endif
  return ["v", split(a:text, "\n", 1)]
endfunc

func! GrooVim_ClipToolAvailable() abort
  return !empty(g:GrooVim_ClipTool)
endfunc

func! GrooVim_ClipToolCopy(reg, type, lines) abort
  if empty(g:GrooVim_ClipTool)
    return
  endif

  let l:text = join(a:lines, "\n")

  " Note: A LINEWISE copy ends with a line break, so other applications receive
  " whole lines instead of a truncated one.
  if a:type ==# "V"
    let l:text = l:text . "\n"
  endif

  " Note: This CANNOT be a "system()" call! These tools do not copy and leave:
  " on Wayland and on X11 the clipboard belongs to the process that offered it,
  " so "wl-copy" (and "xclip", and "xsel") forks and KEEPS RUNNING to serve the
  " data to whoever asks for it, exiting only when another application takes the
  " clipboard over. The child inherits the pipes, "system()" waits for them to
  " close, and Vim would sit frozen after every copy until you copied something
  " somewhere else.
  "
  " A job writes the text and walks away. "out_io"/"err_io" as null keep no pipe
  " open, and "stoponexit" empty is what lets the tool outlive Vim: with the
  " default Vim would kill it on exit and your copy would vanish from the
  "clipboard exactly when you left the editor.
  " The command goes as a LIST, so there is no shell and nothing to quote.
  " Remembered BEFORE the job starts, so a read that happens in the very
  " next instruction already finds it.
  let g:GrooVim_ClipCache = l:text
  let g:GrooVim_ClipCachePending = 1
  if exists("*timer_start")
    call timer_start(g:GrooVim_ClipCacheMs, "GrooVim_ClipCacheClear")
  endif

  try
    let l:job = job_start(g:GrooVim_ClipTool["copy"], {
          \ "in_io": "pipe",
          \ "out_io": "null",
          \ "err_io": "null",
          \ "stoponexit": ""
          \ })
    let l:channel = job_getchannel(l:job)
    call ch_sendraw(l:channel, l:text)
    call ch_close_in(l:channel)
  catch
  endtry

endfunc

func! GrooVim_ClipToolPaste(reg) abort
  if empty(g:GrooVim_ClipTool)
    return ["c", []]
  endif
  let l:out = system(g:GrooVim_ClipTool["paste"])
  if v:shell_error != 0

    " Note: The tool failed, but what we wrote is still the truth.
    if g:GrooVim_ClipCachePending
      return GrooVim_ClipToText(g:GrooVim_ClipCache)
    endif

    return ["v", []]
  endif

  " Note: While our write has not landed, what we wrote is what should be read.
  " Comparing without the trailing line break because the tool may add or strip
  " one of its own.
  if g:GrooVim_ClipCachePending
    if substitute(l:out, "\n$", "", "") ==# substitute(g:GrooVim_ClipCache, "\n$", "", "")
      let g:GrooVim_ClipCachePending = 0
    else
      return GrooVim_ClipToText(g:GrooVim_ClipCache)
    endif
  endif

  " Note: Returning an empty type would let Vim guess, and it guesses LINEWISE,
  " which pastes the text on a line of its own instead of where the cursor is.
  return GrooVim_ClipToText(l:out)
endfunc

" Note: Set to 0 to ignore any installed clipboard tool.
let g:GrooVim_EnableClipTool = get(g:, "GrooVim_EnableClipTool", 1)

if g:GrooVim_EnableClipTool
  let g:GrooVim_ClipTool = GrooVim_ClipToolFind()
  if !empty(g:GrooVim_ClipTool) && &clipmethod !~ "groovim"
    let v:clipproviders["groovim"] = {
          \ "available": function("GrooVim_ClipToolAvailable"),
          \ "copy":  {"+": function("GrooVim_ClipToolCopy"),
          \           "*": function("GrooVim_ClipToolCopy")},
          \ "paste": {"+": function("GrooVim_ClipToolPaste"),
          \           "*": function("GrooVim_ClipToolPaste")},
          \ }

    " Note: Placed BEFORE "osc52" (it does both directions) but AFTER the native
    " methods, which are faster when the Vim build has them.
    if &clipmethod =~ "osc52"
      let &clipmethod = substitute(&clipmethod, "osc52", "groovim,osc52", "")
    else
      set clipmethod+=groovim
    endif

    silent! clipreset
  endif
endif

" Note: Where the file based "transfer area" lives. The directory is created
" with 0700 because a clipboard tends to carry private things.
let g:GrooVim_ClipFile = g:GrooVim_State . "/clipboard"

" Note: Which register answers as clipboard RIGHT NOW. This is not decided once
" at startup because the OSC 52 provider is detected asynchronously (Vim asks
" the terminal and waits for the answer), so it may only become available after
" the ".vimrc" was read.
" Careful: "getreg()" does NOT fail on a Vim with no clipboard, it just warns
" (W24) and answers empty. Only "setreg()" raises E354. So availability is
" asked to Vim itself, never probed by writing.
let g:GrooVim_ClipRegCache = ""
func! GrooVim_ClipReg() abort
  if g:GrooVim_ClipRegCache != ""
    return g:GrooVim_ClipRegCache
  endif

  " Note: A clipboard provider (OSC 52) exposes BOTH registers even on a Vim
  " built without "+clipboard", and there "+" is the one we want: the provider
  " sends "OSC 52;c" for "+", which is the real clipboard, and "OSC 52;p" for
  " "*", which is the primary selection (the middle click one). Asking
  " has("unnamedplus") here would answer 0 on such a build and quietly send
  " every copy to the wrong selection.
  if v:clipmethod != "" && v:clipmethod != "none"
        \ && has_key(v:clipproviders, v:clipmethod)
    let g:GrooVim_ClipRegCache = "+"
    return g:GrooVim_ClipRegCache
  endif

  " Note: Not a leftover for an older Vim -- it answers where "clipmethod" is
  " IGNORED. From the manual of the option: under a GUI, or on a system with
  " neither Wayland nor X11, "v:clipmethod" is set to "none" while the clipboard
  " itself works perfectly well. The branch above cannot fire there, and this
  " one is what finds the register.
  "
  " Note: And the register is "+", never "*". It was asked with
  " has("unnamedplus"), which cannot answer no where this branch answers yes --
  " read in the source of the Vim this builds, "evalfunc.c": both live inside the
  " same "#ifdef FEAT_CLIPBOARD", "clipboard_working" is true when the method is
  " a provider or when the X or Wayland selection is available, and "unnamedplus"
  " is true when X11 or the Wayland clipboard was compiled in, and also when the
  " method is a provider. Each of the two ways of reaching this line makes the
  " other one true.
  "
  " Note: And on a Vim built without "+clipboard" this line is not reached at
  " all: measured on a build made for it, "clipboard_working" answers 0 there --
  " the whole answer is inside that "#ifdef" -- and the branch above, the
  " provider one, is what hands back "+".
  if has("clipboard_working")
    let g:GrooVim_ClipRegCache = "+"
    return g:GrooVim_ClipRegCache
  endif

  " Note: Not cached on purpose, so a provider that shows up later is used.
  return "\""

endfunc

" Note: Pastes what the CLIPBOARD OF GROOVIM has, and not what the "+" register
" has. They are the same thing until OSC 52 is the method in use.
"
" There the register cannot be read back -- the paste side of OSC 52 is off
" because it waits for an answer many terminals never send and hangs Vim until
" Ctrl-C -- so it is always empty. And with "clipboard=unnamedplus" a plain "P"
" reads exactly that register: "E353: Nothing in register +", with the text
" sitting in the file of GrooVim the whole time. Measured on a machine reached by
" SSH, where Ctrl-Shift-V worked (that is the terminal typing, not Vim pasting)
" and Ctrl-V did not.
"
" Through the "z" register and never the unnamed one: with
" "clipboard=unnamedplus", writing the unnamed register writes "+" as well, which
" would send an OSC 52 COPY on every paste.
func! GrooVim_ClipPaste(mode) abort

  if !GrooVim_CanChange() | return | endif

  let l:text = GrooVim_ClipGet()
  if l:text ==# ""

    " Note: When OSC 52 is the method, empty has a REASON worth saying. A copy
    " made anywhere else -- on the machine you are sitting at, in another
    " program -- cannot be read from here: reading it back would mean asking the
    " terminal and waiting for an answer many never send. What does work is the
    " paste of the terminal itself, which types the text in as if you had.
    " Short on purpose. The first try ran off the bar and only its tail
    " was left on screen, which is worse than saying less.
    if GrooVim_ClipAssumed()
      call GrooVim_GrooVimBarMsg("From outside, use Ctrl-Shift-V!", 6)
    else
      call GrooVim_GrooVimBarMsg("There is nothing to paste!", 4)
    endif
    return
  endif

  let l:kept = getreg("z")
  let l:keptType = getregtype("z")

  try
    call setreg("z", l:text)
    if a:mode ==# "v"

      " Note: "gv" because getting here left visual mode, and "_d so that what
      " is replaced does not land in a register.
      silent! exec "normal! gv\"_d\"zP`]"

    else
      silent! exec "normal! \"zP`]"
    endif

    " Note: The same "<Right>" the mappings used to end with, and guarded: past
    " the last column there is nowhere to go.
    if col(".") < col("$")
      normal! l
    endif

  finally
    call setreg("z", l:kept, l:keptType)
  endtry

endfunc

" Note: This is what makes a plain "y" reach the clipboard, and it is the whole
" of it: measured, with the option emptied by hand, a "yy" left the text in the
" unnamed register and "@+" came back empty; with it set, "@+" holds the line.
"
" What it asks is which register the CASCADE ended up on, which is what
" GrooVim_ClipReg() answers. Not has("clipboard_working"), which cannot tell
" WHICH register to write down and does not even answer the same way twice:
" measured on a Vim built with "+clipboard" it says yes wherever the cascade
" found anything, a provider included; measured on one built WITHOUT it -- a
" real build, made for this, "-clipboard -wayland -X11" -- it says NO while OSC
" 52 was carrying every copy out, because the whole of that answer lives inside
" "#ifdef FEAT_CLIPBOARD".
"
" One branch and no "try". There was a second one for "*" and a "catch" around
" both, and neither can happen on the Vim this builds: the register is
" never "*" (see GrooVim_ClipReg above), and the option always exists, because
" Vim defines it whenever "+clipboard" OR "+eval" is there -- read in
" "optiondefs.h" and "vim.h", "HAVE_CLIPMETHOD" -- and with a provider present
" "unnamedplus" is an allowed value even on a Vim built without "+clipboard",
" which its own manual says in as many words.
func! GrooVim_ClipSyncOption() abort
  if GrooVim_ClipReg() == "+"
    set clipboard=unnamedplus
  endif
endfunc

" Note: Re-checks the clipboard once the terminal had time to answer.
func! GrooVim_ClipRefresh() abort
  let g:GrooVim_ClipRegCache = ""
  call GrooVim_ClipSyncOption()
endfunc

call GrooVim_ClipSyncOption()

augroup GrooVim_Clipboard
  autocmd!
  autocmd VimEnter * call GrooVim_ClipRefresh()
augroup end

" Note: The file based "transfer area", used when there is no clipboard
" register at all. It also lets two Vim instances share a copy.
func! GrooVim_ClipFileSet(value) abort
  try
    let l:dir = fnamemodify(g:GrooVim_ClipFile, ":h")
    if !isdirectory(l:dir)
      call mkdir(l:dir, "p", 0700)
    endif
    call writefile(split(a:value, "\n", 1), g:GrooVim_ClipFile)
    " Note: A clipboard carries private things, so keep it readable only by its
    " owner.
    if exists("*setfperm")
      call setfperm(g:GrooVim_ClipFile, "rw-------")
    endif
  catch
  endtry
endfunc

func! GrooVim_ClipFileGet() abort
  try
    if filereadable(g:GrooVim_ClipFile)
      return join(readfile(g:GrooVim_ClipFile), "\n")
    endif
  catch
  endtry
  return ""
endfunc

" Note: Read the "transfer area".
func! GrooVim_ClipGet() abort
  let l:reg = GrooVim_ClipReg()

  " Note: Asked FIRST when the method is the assumed one, because there the
  " register answers empty to everything and the file is the only real source.
  " Measured: with "osc52" in use, "getreg('+')" came back empty while the file
  " held the text.
  if GrooVim_ClipAssumed()
    let l:assumedFile = GrooVim_ClipFileGet()
    if l:assumedFile != ""
      return l:assumedFile
    endif
  endif

  if l:reg != "\""
    try
      return getreg(l:reg)
    catch

      " Note: It was announced but did not answer. Forget it and go down the
      " cascade.
      let g:GrooVim_ClipRegCache = ""

    endtry
  endif
  let l:fromFile = GrooVim_ClipFileGet()
  if l:fromFile != ""
    return l:fromFile
  endif
  return getreg("\"")
endfunc

" Note: Write to the "transfer area". Is the clipboard in use one that can only
" be ASSUMED?
"
" A copy through OSC 52 goes out as an escape sequence and the terminal is
" never heard from again -- there is no way to know it arrived. And the paste
" back is off (it waits for an answer many terminals never send and hangs Vim
" until Ctrl-C), so the "+" register answers EMPTY to everything on top of that.
"
" So when that is the method, the file of GrooVim is kept as well: the copy
" still leaves through the terminal AND stays readable on this machine. That is
" what makes OSC 52 never worse than no OSC 52, and it is why there is no
" question about it on any screen -- it used to be one, and the only reason it
" had an answer worth giving was this gap.
func! GrooVim_ClipAssumed() abort
  return v:clipmethod ==# "osc52"
        \ && get(g:, "osc52_disable_paste", 1)
endfunc

" Note: Copies what is selected and leaves the cursor WHERE IT WAS.
"
" A plain "y" in visual mode drops the cursor at the START of what was
" selected, which is of Vim and of nothing else: in a conventional editor you
" copy and go on from where you are. The position is taken before the yank and
" put back after it.
"
" The yank itself is still a yank -- "gvy" and not a string handed to
" setreg -- because that is what keeps a linewise selection linewise and a block
" a block. What is added is the file of GrooVim, and only when the method in use
" is one whose success cannot be known: see GrooVim_ClipAssumed.
func! GrooVim_CopyHere() abort

  " Note: The whole VIEW and not only the cursor. A yank over a selection that
  " runs off the screen scrolls the window to its start, and putting the cursor
  " back afterwards does not bring the window with it -- the text jumped under
  " it. "winsaveview" holds where the window is looking as well as where the
  " cursor is.
  "
  " And it is taken HERE and trusted, because the mapping comes through
  " "<Cmd>": the selection is still up, the cursor has not been moved, and the
  " window is the one being looked at.
  "
  " Through the ":<C-u>" this used to come in on, none of the three was
  " true. Leaving visual mode with ":" drops the cursor on the first line of the
  " range -- measured: column 8 while selecting, column 5 by the time the
  " function ran -- and takes the window along, so the selection had to be put
  " back with a "gv" before anything could be read. And a "gv" that lands more
  " than a screen away makes Vim CENTRE what it lands on, which moved the window
  " on a copy that moves nothing.
  let l:view = winsaveview()

  normal! y

  if GrooVim_ClipAssumed()
    call GrooVim_ClipFileSet(getreg(GrooVim_ClipReg()))
  endif

  call winrestview(l:view)

  " Note: And back to typing, which is what a conventional editor leaves you able
  " to do after a copy. Only where typing is POSSIBLE: on a buffer you cannot
  " change -- the help, the occurrence list -- it answered "E21: Cannot make
  " changes, 'modifiable' is off" over a command that changes nothing.
  "
  " And only when Vim is not already on its way back to insert. The yank above
  " ends the selection, and a selection that was STARTED from insert mode -- a
  " mouse drag, a "<C-o>" -- sends Vim back to insert the moment it ends. Here,
  " after the yank, "mode(1)" tells the two apart: "n" when nobody is waiting,
  " "niI" when insert is. Measured on a plain Vim with nothing but "mouse=a", so
  " it is how Vim works and not something of GrooVim.
  if &modifiable && mode(1) !~# "^ni"
    startinsert
  endif
endfunc

func! GrooVim_ClipSet(value) abort
  let l:reg = GrooVim_ClipReg()
  if l:reg != "\""
    try
      call setreg(l:reg, a:value)
      if GrooVim_ClipAssumed()
        call GrooVim_ClipFileSet(a:value)
      endif
      return
    catch
      let g:GrooVim_ClipRegCache = ""
    endtry
  endif

  " Note: No clipboard register: the unnamed one plus the file, so another Vim
  " instance can pick it up.
  call setreg("\"", a:value)

  call GrooVim_ClipFileSet(a:value)
endfunc

" Note: Don't create swap files.
set noswapfile

" Note: Solve read only problem! Some files opens as read only.
set ma

" Note: When reload ".vimrc" the last search is " highlighted again.
" set hlsearch

" Note: Allows an "extra" column at the end of the lines (You want this!).
set virtualedit=onemore
