" Note: "Esc" answers AT ONCE.
"
" Note: A terminal sends an arrow or an F key as a run of bytes that begins with
" the very same "Esc", so Vim waits to see whether more is coming -- and with no
" "ttimeoutlen" set it waits "timeoutlen", a whole second. Pressing Esc showed
" "^[" in the corner and nothing happened until the second was up. This is the
" wait for the REST OF A KEY, which a keyboard sends in one go; it is not the
" wait for the second key of a shortcut, which is a hand travelling and has its
" own patience in "g:GrooVim_CommandZWait".
"
" Note: 150 and not less, measured by feeding an arrow one byte at a time: at 50
" the key falls apart as soon as its bytes arrive 80ms apart, at 100 it goes at
" 120ms, at 150 it holds. A keyboard sends the whole run in one go, but a slow
" link does not -- and 150ms of waiting for an Esc is nothing beside the second
" it was! By Questor
set ttimeout
set ttimeoutlen=150

" Note: The "transfer area" (clipboard) is reached through a cascade, so that
" GrooVim depends on NO external package and works with no graphical session at
" all (think of a headless server reached by SSH)! By Questor
"
"   1. The native clipboard, when Vim was built with a working "+clipboard";
"   2. "OSC 52", an escape sequence that carries the clipboard THROUGH the
"      terminal itself. It needs no X11, no Wayland and no desktop, it crosses
"      SSH, and Vim 9.2 already ships the "osc52" package (nothing to install);
"   3. A file shared between Vim instances, which always works, even on a bare
"      tty with a terminal that speaks nothing;
"   4. The unnamed register, our last resort.

" Note: Two variables answer two DIFFERENT questions about OSC 52, and reading
" them as one is what makes the whole thing confusing:
"
"   g:GrooVim_EnableOSC52   -- the POLICY.    Do we want OSC 52 at all?
"   g:osc52_force_avail     -- the DETECTION. How is the terminal judged able?
"
" Note: The first is what F5->c asks, because it is the only one that is about
" what YOU want. The second is about how a capability is established, which is
" not a preference, and it lives below! By Questor

" Note: The policy. Set to 0 and OSC 52 never enters the cascade! By Questor
let g:GrooVim_EnableOSC52 = get(g:, "GrooVim_EnableOSC52", 1)

" Note: An OSC 52 PASTE makes Vim block waiting for an answer that many
" terminals never send (Ctrl-C cancels it). Copy is what we really want here, so
" paste stays off unless you know your terminal answers! By Questor
let g:osc52_disable_paste = get(g:, "osc52_disable_paste", 1)

" Note: Should OSC 52 be tried at all? The honest answer is that we cannot know
" whether this terminal does it, and that asking was the wrong question.
"
" Note: This used to be a list of terminals that identify themselves in their own
" environment -- "$KONSOLE_VERSION", "$VTE_VERSION", "$TERM_PROGRAM" and the
" rest. A list like that is never finished. VTE alone covers GNOME, XFCE, MATE
" and Terminator, but COSMIC is not VTE, and whatever is written next will not be
" there either: every one of them answered "no" by default. And a "no" here is
" SILENT -- the copy never arrives and nothing on screen says why.
"
" Note: The two mistakes are not the same size. Sending the sequence to a
" terminal that does not know it costs nothing, because an unknown OSC is
" swallowed. NOT sending it to one that does costs the copy. So the default is to
" try, and the question is only whether there is a terminal to try on.
"
" Note: It is also the LAST method: "clipmethod" is "wayland,x11,groovim,osc52",
" so a machine with a clipboard of its own, or a tool to call, never reaches it.
" Turn it off with "let g:GrooVim_EnableOSC52 = 0", or decide it yourself with
" "let g:osc52_force_avail = 0/1"! By Questor
func! GrooVim_TerminalDoesOSC52() abort

  " Note: Under a GUI there is no terminal for the sequence to reach! By Questor
  if has("gui_running")
    return 0
  endif

  " Note: A terminal that says it can do nothing is taken at its word. Only
  " "dumb" is tested: Vim refuses to set "term" to an empty string at all
  " ("E529"), so there is no such case to guard against! By Questor
  if &term ==# "dumb"
    return 0
  endif

  return 1
endfunc

" Note: The DETECTION. Not whether to use OSC 52 -- that is the policy above --
" but how the terminal is judged able to do it. Two ways, and only two:
"
"   1  assume it can       (the default)
"   0  ask it with a DA1 query, and believe only an answer advertising "52"
"
" Note: Assuming is the default because of terminals that DO OSC 52 without ever
" announcing it, and Konsole is one of them: asked with DA1 it says nothing about
" 52, so a Vim that asks concludes there is no support and a copy never leaves
" the machine -- on a terminal where it works perfectly well.
"
" Note: The query itself. The package calls SendDA1() as it starts, and inside it
" is "if !has('gui_running') && !get(g:, 'osc52_force_avail', 0)". So the call
" happens and the sequence is NOT sent while this is 1: with our default, Vim
" never actually consults the terminal.
"
" Note: This is not on the F5->c screen on purpose. The screen asks what you
" WANT; how a capability is established is not a preference, and offering it as a
" third answer beside yes and no would mix the two questions into one. One line
" of your own configuration, for whoever wants the strict reading:
"
"   let g:osc52_force_avail = 0
"
" Note: Written here, after the question above can be asked, and not up with
" "g:GrooVim_EnableOSC52": a "let" at the top of the file would run before the
" function it calls exists ("E117")! By Questor
let g:osc52_force_avail = get(g:, "osc52_force_avail", GrooVim_TerminalDoesOSC52())

" Note: Puts OSC 52 into the cascade, or takes it out. A function and not a
" block that runs once, because the general settings screen turns this on and
" off while GrooVim is RUNNING, and an answer that only took effect after a
" restart would be a lie. Called once as GrooVim loads, and again on every
" change! By Questor
func! GrooVim_OSC52Apply() abort

  if !exists("v:clipproviders") || !exists("+clipmethod")
    return
  endif

  if !g:GrooVim_EnableOSC52
    if &clipmethod =~ "osc52"
      let &clipmethod = join(filter(split(&clipmethod, ","), 'v:val !=# "osc52"'), ",")
    endif
    " Note: The register is worked out once and remembered, so it has to be
    " forgotten here or the next copy still goes where it used to! By Questor
    let g:GrooVim_ClipRegCache = ""
    silent! clipreset
    return
  endif

  try
    packadd osc52
    if &clipmethod !~ "osc52"
      set clipmethod+=osc52
    endif
    let g:GrooVim_ClipRegCache = ""
    " Note: Makes Vim pick a clipmethod again now that the provider exists! By Questor
    silent! clipreset
  catch
  endtry

endfunc
call GrooVim_OSC52Apply()

" Note: A clipboard provider backed by an external tool, used ONLY when the tool
" is ALREADY installed. This is what makes PASTE from another application work:
" OSC 52 carries a copy out through the terminal, but reading back would require
" the terminal to ANSWER a query, and almost none of them do it (on purpose: a
" remote program could steal your clipboard), so Vim would just block waiting.
"
" Nothing here is a requirement of GrooVim. With no tool around, this provider
" reports itself unavailable and the cascade simply goes on to OSC 52! By Questor
let g:GrooVim_ClipTools = get(g:, "GrooVim_ClipTools", [
      \ {"copy": ["wl-copy", "--type", "text/plain"],
      \  "paste": ["wl-paste", "--no-newline", "--type", "text/plain"]},
      \ {"copy": ["xclip", "-selection", "clipboard"],
      \  "paste": ["xclip", "-selection", "clipboard", "-o"]},
      \ {"copy": ["xsel", "--clipboard", "--input"],
      \  "paste": ["xsel", "--clipboard", "--output"]},
      \ ])

" Note: A directory of YOUR own where a clipboard tool can be dropped by hand,
" for a machine where you cannot (or would rather not) use the package manager.
" What is found here wins over "$PATH".
"
" GrooVim ships NO binary and never will: a Linux executable is not portable
" between machines (it is built for one architecture and linked against one
" libc, and "wl-copy" also needs libwayland-client at run time), so carrying one
" is your call and your responsibility. Note as well that on a headless server
" there is no compositor for "wl-copy" to talk to: there the answer is OSC 52,
" which already crosses SSH by itself! By Questor
let g:GrooVim_ClipBinDir = get(g:, "GrooVim_ClipBinDir", g:GrooVim_Home . "/bin")

" Note: The first tool that is actually there wins, and a hand placed one comes
" before the one from "$PATH"! By Questor
" Note: Jobs are required: see GrooVim_ClipToolCopy() for why a "system()" call
" would freeze Vim on every copy. Without them we simply do not offer this
" provider and the cascade goes on to OSC 52! By Questor
func! GrooVim_ClipToolFind() abort
  if !exists("*job_start")
    return {}
  endif
  for l:dir in [g:GrooVim_ClipBinDir, ""]
    for l:tool in g:GrooVim_ClipTools
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
" Note: So what we wrote is remembered and served until the tool catches up. The
" window is short and closes as soon as a read agrees with what we wrote, or at
" the latest after "g:GrooVim_ClipCacheMs"! By Questor
let g:GrooVim_ClipCacheMs = get(g:, "GrooVim_ClipCacheMs", 300)
let g:GrooVim_ClipCache = ""
let g:GrooVim_ClipCachePending = 0

func! GrooVim_ClipCacheClear(...) abort
  let g:GrooVim_ClipCachePending = 0
endfunc

" Note: A trailing line break is what tells a LINEWISE copy from a charwise one!
" By Questor
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
  " whole lines instead of a truncated one! By Questor
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
  " Note: A job writes the text and walks away. "out_io"/"err_io" as null keep no
  " pipe open, and "stoponexit" empty is what lets the tool outlive Vim: with the
  " default Vim would kill it on exit and your copy would vanish from the
  " clipboard exactly when you left the editor! By Questor
  " Note: The command goes as a LIST, so there is no shell and nothing to quote! By Questor
  " Note: Remembered BEFORE the job starts, so a read that happens in the very
  " next instruction already finds it! By Questor
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
    " Note: The tool failed, but what we wrote is still the truth! By Questor
    if g:GrooVim_ClipCachePending
      return GrooVim_ClipToText(g:GrooVim_ClipCache)
    endif
    return ["v", []]
  endif

  " Note: While our write has not landed, what we wrote is what should be read.
  " Comparing without the trailing line break because the tool may add or strip
  " one of its own! By Questor
  if g:GrooVim_ClipCachePending
    if substitute(l:out, "\n$", "", "") ==# substitute(g:GrooVim_ClipCache, "\n$", "", "")
      let g:GrooVim_ClipCachePending = 0
    else
      return GrooVim_ClipToText(g:GrooVim_ClipCache)
    endif
  endif

  " Note: Returning an empty type would let Vim guess, and it guesses LINEWISE,
  " which pastes the text on a line of its own instead of where the cursor is! By Questor
  return GrooVim_ClipToText(l:out)
endfunc

" Note: Set to 0 to ignore any installed clipboard tool! By Questor
let g:GrooVim_EnableClipTool = get(g:, "GrooVim_EnableClipTool", 1)

if g:GrooVim_EnableClipTool
  if exists("v:clipproviders") && exists("+clipmethod")
    let g:GrooVim_ClipTool = GrooVim_ClipToolFind()
    if !empty(g:GrooVim_ClipTool) && &clipmethod !~ "groovim"
      let v:clipproviders["groovim"] = {
            \ "available": function("GrooVim_ClipToolAvailable"),
            \ "copy":  {"+": function("GrooVim_ClipToolCopy"),
            \           "*": function("GrooVim_ClipToolCopy")},
            \ "paste": {"+": function("GrooVim_ClipToolPaste"),
            \           "*": function("GrooVim_ClipToolPaste")},
            \ }
      " Note: Placed BEFORE "osc52" (it does both directions) but AFTER the
      " native methods, which are faster when the Vim build has them! By Questor
      if &clipmethod =~ "osc52"
        let &clipmethod = substitute(&clipmethod, "osc52", "groovim,osc52", "")
      else
        set clipmethod+=groovim
      endif
      silent! clipreset
    endif
  endif
endif

" Note: Where the file based "transfer area" lives. The directory is created
" with 0700 because a clipboard tends to carry private things! By Questor
let g:GrooVim_ClipFile = g:GrooVim_State . "/clipboard"

" Note: Which register answers as clipboard RIGHT NOW. This is not decided once
" at startup because the OSC 52 provider is detected asynchronously (Vim asks
" the terminal and waits for the answer), so it may only become available after
" the ".vimrc" was read! By Questor
" Note: Careful: "getreg()" does NOT fail on a Vim with no clipboard, it just
" warns (W24) and answers empty. Only "setreg()" raises E354. So availability is
" asked to Vim itself, never probed by writing! By Questor
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
  " every copy to the wrong selection! By Questor
  if exists("v:clipmethod") && v:clipmethod != "" && v:clipmethod != "none"
        \ && exists("v:clipproviders") && has_key(v:clipproviders, v:clipmethod)
    let g:GrooVim_ClipRegCache = "+"
    return g:GrooVim_ClipRegCache
  endif

  if has("clipboard_working")
    let g:GrooVim_ClipRegCache = has("unnamedplus") ? "+" : "*"
    return g:GrooVim_ClipRegCache
  endif
  " Note: Not cached on purpose, so a provider that shows up later is used! By Questor
  return "\""
endfunc

" Note: Avoids compatibility issues when copying to an external application! By Questor
"
" Note: This is what makes a plain "y" reach the clipboard. It must follow
" GrooVim_ClipReg() and NOT has("clipboard_working"): on a Vim built without
" "+clipboard" but with the OSC 52 provider active, "clipboard_working" and
" "unnamedplus" both answer 0, "clipboard" was left empty, and so every yank
" stopped at the unnamed register and nothing was ever sent to the terminal!
" By Questor
func! GrooVim_ClipSyncOption() abort
  let l:reg = GrooVim_ClipReg()
  try
    if l:reg == "+"
      set clipboard=unnamedplus
    elseif l:reg == "*"
      set clipboard=unnamed
    endif
  catch
  endtry
endfunc

" Note: Re-checks the clipboard once the terminal had time to answer! By Questor
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
" register at all. It also lets two Vim instances share a copy! By Questor
func! GrooVim_ClipFileSet(value) abort
  try
    let l:dir = fnamemodify(g:GrooVim_ClipFile, ":h")
    if !isdirectory(l:dir)
      call mkdir(l:dir, "p", 0700)
    endif
    call writefile(split(a:value, "\n", 1), g:GrooVim_ClipFile)
    " Note: A clipboard carries private things, so keep it readable only by its
    " owner! By Questor
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

" Note: Read the "transfer area"! By Questor
func! GrooVim_ClipGet() abort
  let l:reg = GrooVim_ClipReg()
  if l:reg != "\""
    try
      return getreg(l:reg)
    catch
      " Note: It was announced but did not answer. Forget it and go down the
      " cascade! By Questor
      let g:GrooVim_ClipRegCache = ""
    endtry
  endif
  let l:fromFile = GrooVim_ClipFileGet()
  if l:fromFile != ""
    return l:fromFile
  endif
  return getreg("\"")
endfunc

" Note: Write to the "transfer area"! By Questor
func! GrooVim_ClipSet(value) abort
  let l:reg = GrooVim_ClipReg()
  if l:reg != "\""
    try
      call setreg(l:reg, a:value)
      return
    catch
      let g:GrooVim_ClipRegCache = ""
    endtry
  endif
  " Note: No clipboard register: the unnamed one plus the file, so another Vim
  " instance can pick it up! By Questor
  call setreg("\"", a:value)
  call GrooVim_ClipFileSet(a:value)
endfunc

" Note: Don't create swap files! By Questor
set noswapfile

" Note: Solve read only problem! Some files opens as read only! By Questor
set ma

" Note: When reload ".vimrc" the last search is " highlighted again! By Questor
" set hlsearch

" Note: Allows an "extra" column at the end of the lines (You want this!)! By Questor
set virtualedit=onemore

"$$$$$$$$$$$$$$$$$$$$$$$$$$

