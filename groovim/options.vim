" Note: Select and search with a double click and z key otherwise select the
" word under cursor! By Questor
func! GrooVim_SelectNSearch(type, mode) range abort
  if expand('%:t') =~ "GrooVim_SearchGuyResults"
    call GrooVim_SearchGuyNavigate()
  else
    " Note: Set "hlsearch" if is off! By Questor
    if !&hlsearch
      " Note: Highlight search results! By Questor
      set hlsearch
    endif

    set noignorecase
    let l:initialPos = getpos(".")
    if a:type == 0
      exec "sleep 250m"
      let l:enableSearch = getchar(0)
      if l:enableSearch == "122"
        let l:pathern = GrooVim_EscapeSubstituteValueToSearch(expand("<cword>"))
        call feedkeys("/" . l:pathern . "\<cr>\<Esc>" . g:cmdLineCaller . "call setpos(\".\", [" . l:initialPos[0] . ", " . l:initialPos[1] . ", " . l:initialPos[2] . ", " . l:initialPos[3] . "])|redraw!\<cr>")
      else
        call feedkeys("viw")
      endif
    elseif a:type == 1
      let l:pathern = GrooVim_EscapeSubstituteValueToSearch(expand("<cword>"))
      call feedkeys("\<Esc>/" . l:pathern . "\<cr>\<Esc>" . g:cmdLineCaller . "call setpos(\".\", [" . l:initialPos[0] . ", " . l:initialPos[1] . ", " . l:initialPos[2] . ", " . l:initialPos[3] . "])|redraw!\<cr>")
      if a:mode == "i"
        call feedkeys("\<Esc>i")
      else
        " Note: This workaround is to prevent the cursor to moves to the next occurrence when press <Up> or <Down> key! By Questor
        call feedkeys("\<Esc>i\<Esc>")
      endif
    endif

  endif
endfunc

" Note: Select a range based on first and last positions! By Questor
let g:lastCursorPos = [0,0]
let g:GrooVim_SelectRangeInitialize = 1
func! GrooVim_SelectRange(mod) range abort

  let l:selDirection = "nothing"
  if g:GrooVim_SelectRangeInitialize == 0 && a:mod == "i"
    let l:cursorPosInsert = getpos(".")
    if g:lastCursorPos[1] < l:cursorPosInsert[1]
      let l:selDirection = "lessMoreLine"
    elseif g:lastCursorPos[1] > l:cursorPosInsert[1]
      let l:selDirection = "moreLessLine"
    elseif g:lastCursorPos[1] == l:cursorPosInsert[1]
      if g:lastCursorPos[2] < l:cursorPosInsert[2]
        let l:selDirection = "lessMoreCol"
      elseif g:lastCursorPos[2] > l:cursorPosInsert[2]
        let l:selDirection = "moreLessCol"
      endif
    endif
  endif

  if g:GrooVim_SelectRangeInitialize == 1
    let g:lastCursorPos = getpos(".")
    let g:GrooVim_SelectRangeInitialize = 0
    echomsg "Beginning of the range selected!"
  elseif g:GrooVim_SelectRangeInitialize == 0
    let l:cursorPos = getpos(".")
    call setpos('.', g:lastCursorPos)
    if (l:selDirection == "moreLessLine" || l:selDirection == "moreLessCol") && a:mod == "i"
      exec "norm \<Left>"
    endif
    exec "norm v"
    call setpos('.', l:cursorPos)
    if (l:selDirection == "lessMoreLine" || l:selDirection == "lessMoreCol") && a:mod == "i"
      exec "norm \<Left>"
    endif
    let g:GrooVim_SelectRangeInitialize = 1
    echomsg "Range selected!"
  endif

endfunc

" Note: Where the options you chose to KEEP are written.
"
" Note: Under "GrooVim/" and not under "plugin/", where it used to live: Vim
" sources everything in "~/.vim/plugin" by itself, so the file was being run by
" the Vim of the system too. GrooVim is reached through the "groovim" command,
" and what it saves has to stay on its side of that line! By Questor
" Note: "g:GrooVim_OptsFile" is defined in the ".vimrc": the file is read there,
" before any part of GrooVim, so the path has to be known before this one
" runs! By Questor

" Note: What the screen you are on has changed, so the question at the end can
" write it all down if you say to keep it.
"
" Note: The options are applied as you answer, one by one, and only WRITTEN at
" the end -- so leaving a screen with "Ctrl-C" changes the session and nothing
" on disk! By Questor
let g:GrooVim_OptsPending = []

func! GrooVim_OptsBegin() abort
  let g:GrooVim_OptsPending = []
endfunc

" Note: The last question of every configuration screen.
"
" Note: The keeping was written in 2014, in the third argument of
" "GrooVim_OptsUpdate", and never called from anywhere -- which is why it had a
" defect in each of its three situations. Now it has a way in! By Questor
func! GrooVim_OptsEnd() abort

  let l:answer = GrooVim_GetOptions("Just [a]apply or [s]apply and save", ["a", "s"], "a", "")

  if l:answer ==# "s"
    for l:pair in g:GrooVim_OptsPending
      call GrooVim_OptsUpdate(l:pair[0], l:pair[1], 1)
    endfor
    call GrooVim_GrooVimBarMsg("Kept for the next time you open GrooVim!", 6)
  endif

  let g:GrooVim_OptsPending = []

endfunc

" Note: Updates an option if it already exists or insert it if not. It also creates the configuration file if it does not exist! By Questor
let g:optsTemp = []
func! GrooVim_OptsUpdate(valueToSearch, valueToReplace, persistently) abort

  let l:CoolAndVimOptsArrayUpdated = []

  let l:thisOptionDoesNotExistInTheConfiguration = 1

  if a:persistently == 0

    " Note: To update temporary options when necessary! By Questor
    for l:value in g:optsTemp
      if l:value =~ a:valueToSearch
        call add(l:CoolAndVimOptsArrayUpdated, a:valueToReplace)
        let l:thisOptionDoesNotExistInTheConfiguration = 0
      else
        call add(l:CoolAndVimOptsArrayUpdated, l:value)
      endif
    endfor

    let g:optsTemp = l:CoolAndVimOptsArrayUpdated

    if l:thisOptionDoesNotExistInTheConfiguration == 1
      call add(g:optsTemp, a:valueToReplace)
    endif

    " Note: Written down so the question at the end of the screen can keep it! By
    " Questor
    call add(g:GrooVim_OptsPending, [a:valueToSearch, a:valueToReplace])

    exec a:valueToReplace

  else

    " Note: Starts empty. Without this, a first save -- with the file not there
    " yet -- died on the "for" below with an "E121"! By Questor
    let l:CoolAndVimOptsArrayOriginal = []
    if filereadable(g:GrooVim_OptsFile)
      let l:CoolAndVimOptsArrayOriginal = readfile(g:GrooVim_OptsFile)
    endif

    let l:CoolAndVimOptsArrayUpdated = []
    for l:value in l:CoolAndVimOptsArrayOriginal
      if l:value =~ a:valueToSearch
        call add(l:CoolAndVimOptsArrayUpdated, a:valueToReplace)
        let l:thisOptionDoesNotExistInTheConfiguration = 0
        " Note: Just the new value. Gluing the search in front of it produced
        " "let g:x =let g:x = 1", which is an "E121" every time! By Questor
        exec a:valueToReplace
      else
        call add(l:CoolAndVimOptsArrayUpdated, l:value)
      endif
    endfor

    if l:thisOptionDoesNotExistInTheConfiguration == 1
      " Note: The option that was ASKED for, and not "l:value", which is whatever
      " the loop above happened to stop on -- an option that was not in the file
      " yet ended up duplicating the last line instead of being added! By Questor
      call add(l:CoolAndVimOptsArrayUpdated, a:valueToReplace)
    endif

    call mkdir(fnamemodify(g:GrooVim_OptsFile, ":h"), "p")
    call writefile(l:CoolAndVimOptsArrayUpdated, g:GrooVim_OptsFile)

  endif

endfunc

" Note: Configures the search and/or replace depending on the parameters passed! By Questor
" Note: The one door into the settings. It asks WHICH of them and then opens
" that screen, which is what a conventional editor does: one "Settings", and the
" topics inside it.
"
" Note: Each screen used to have a key of its own -- four entries in the list, in
" the help, in the menu and in the README, for four things that are the same
" thing. Now there is one, and three letters of the F5 group came back.
"
" Note: Written without naming those keys, because a case reads every "FX->x" in
" the source and refuses one that no longer exists -- which is exactly what they
" no longer do! By Questor
func! GrooVim_Configure() range abort

  " Note: No default and no value in force, so no answer is assumed: an empty one
  " is not valid and the question simply asks again, which is what every other
  " question of GrooVim does when there is nothing to fall back on! By Questor
  let l:which = GrooVim_GetOptions(
   \ "Configure: [i]ndent, [v]iew, [f]ile, [s]earch, [r]eplace or [g]eneral",
   \ ["i", "v", "f", "s", "r", "g"], "", "")

  if l:which ==# "i"
    call GrooVim_Operation("[configuration] [indent]", "GrooVim_ConfigureIndent", [])
  elseif l:which ==# "v"
    call GrooVim_Operation("[configuration] [view]", "GrooVim_ConfigureView", [])
  elseif l:which ==# "f"
    call GrooVim_Operation("[configuration] [file]", "GrooVim_ConfigureFile", [])
  elseif l:which ==# "s"
    call GrooVim_Operation("[configuration] [search]", "GrooVim_ConfigureSearchReplace", ["search"])
  elseif l:which ==# "r"
    call GrooVim_Operation("[configuration] [replace]", "GrooVim_ConfigureSearchReplace", ["replace"])
  elseif l:which ==# "g"
    call GrooVim_Operation("[configuration] [general]", "GrooVim_ConfigureGeneral", [])
  endif

endfunc

func! GrooVim_ConfigureSearchReplace(typeOfConfig) range abort

  " Note: No header line here. The bar already says "[configuration] [search]" or
  " "[configuration] [replace]", and what an empty answer does is written in the
  " help (F9), so a line repeating it would only crowd the screen! By Questor

  call GrooVim_OptsBegin()

  let g:searchReplace_CaseSensitive = GrooVim_GetOptions("Case sensitive (SEARCH/REPLACE)", [0,1], 0, g:searchReplace_CaseSensitive)
  call GrooVim_OptsUpdate("let g:searchReplace_CaseSensitive =", "let g:searchReplace_CaseSensitive = " . g:searchReplace_CaseSensitive, 0)
  " Note: No "it is enabled/disabled" echo here: the prompt already shows the
  " value that was just chosen, and every extra line pushes the command area
  " around! By Questor
  if g:searchReplace_CaseSensitive == 1
    call GrooVim_OptsUpdate("set ignorecase", "set noignorecase", 0)
  else
    call GrooVim_OptsUpdate("set noignorecase", "set ignorecase", 0)
  endif

  let g:searchReplace_InAllOpened = GrooVim_GetOptions("In all tabs (SEARCH/REPLACE)", [0,1], 0, g:searchReplace_InAllOpened)
  call GrooVim_OptsUpdate("let g:searchReplace_InAllOpened =", "let g:searchReplace_InAllOpened = " . g:searchReplace_InAllOpened, 0)

  if a:typeOfConfig != "search"
    let g:configureGrooVim_EntertainmentReplace_Confirmation = GrooVim_GetOptions("Replace with confirmation", [0,1], 1, g:configureGrooVim_EntertainmentReplace_Confirmation)
    call GrooVim_OptsUpdate("let g:configureGrooVim_EntertainmentReplace_Confirmation =", "let g:configureGrooVim_EntertainmentReplace_Confirmation = " . g:configureGrooVim_EntertainmentReplace_Confirmation, 0)
    let g:configureGrooVim_EntertainmentReplace_AskTheValueToBeReplaced = GrooVim_GetOptions("Ask the value to be replaced", [0,1], 1, g:configureGrooVim_EntertainmentReplace_AskTheValueToBeReplaced)
    call GrooVim_OptsUpdate("let g:configureGrooVim_EntertainmentReplace_AskTheValueToBeReplaced =", "let g:configureGrooVim_EntertainmentReplace_AskTheValueToBeReplaced = " . g:configureGrooVim_EntertainmentReplace_AskTheValueToBeReplaced, 0)
    let g:configureGrooVim_EntertainmentReplace_FromCurrentPosition = GrooVim_GetOptions("Replace begin from current position", [0,1], 1, g:configureGrooVim_EntertainmentReplace_FromCurrentPosition)
    call GrooVim_OptsUpdate("let g:configureGrooVim_EntertainmentReplace_FromCurrentPosition =", "let g:configureGrooVim_EntertainmentReplace_FromCurrentPosition = " . g:configureGrooVim_EntertainmentReplace_FromCurrentPosition, 0)
  elseif a:typeOfConfig == "search"
    let g:search_Direction = GrooVim_GetOptions("Search [f]forward/[b]backward", ["f","b"], "f", g:search_Direction)
    call GrooVim_OptsUpdate("let g:search_Direction =", "let g:search_Direction = \"" . g:search_Direction . "\"", 0)
    " Note: Needed to reverse the search! By Questor
    if g:search_Direction == "b"
      let g:grooVimSearchFoward = 0
    elseif g:search_Direction == "f"
      let g:grooVimSearchFoward = 1
    endif
    let g:search_WithList = GrooVim_GetOptions("Search with list", [0,1], 0, g:search_WithList)
    call GrooVim_OptsUpdate("let g:search_WithList =", "let g:search_WithList = \"" . g:search_WithList . "\"", 0)
  endif

  call GrooVim_OptsEnd()

endfunc

" Note: The settings that are not about searching or replacing. The screen is the
" same shape as the other two: the questions come one after another, and the last
" one asks whether to keep what you chose! By Questor
" Note: The "Tab Settings" of Notepad++, as a screen of GrooVim.
"
" Note: A width here is THREE options of Vim at once -- "tabstop", "shiftwidth"
" and "softtabstop" -- and they only mean what you expect while they agree. The
" question asks ONCE and moves the three together! By Questor
func! GrooVim_ConfigureIndent() range abort

  call GrooVim_OptsBegin()

  let l:width = GrooVim_GetNumber("Indent width, in columns",
   \ g:GrooVim_IndentWidth, &shiftwidth)
  call GrooVim_OptsUpdate("let g:GrooVim_IndentWidth =",
   \ "let g:GrooVim_IndentWidth = " . l:width, 0)
  call GrooVim_IndentWidthApply(str2nr(l:width))

  let l:spaces = GrooVim_GetOptions("Tab puts spaces instead of a real tab",
   \ [0,1], 1, &expandtab)
  call GrooVim_OptsUpdate("let g:GrooVim_IndentExpandTab =",
   \ "let g:GrooVim_IndentExpandTab = " . l:spaces, 0)
  let &expandtab = g:GrooVim_IndentExpandTab

  " Note: The guides are not asked here any more. They are a SYMBOL drawn on the
  " screen, not a rule about what <Tab> does, and Notepad++ puts them where they
  " belong: View, Show Symbol -- which is the "[v]iew" screen! By Questor

  call GrooVim_OptsEnd()

endfunc

" Note: The five encodings the Encoding menu of Notepad++ offers, as GrooVim
" asks them: the letter, then what Vim has to be told.
"
" Note: "utf-16le" and "utf-16" are the LE and BE of that menu, and both carry a
" BOM there -- a UTF-16 file without one cannot be told apart from bytes! By
" Questor
let g:GrooVim_Encodings = {
      \ "a": {"name": "ansi",          "fenc": "latin1",   "bom": 0},
      \ "u": {"name": "utf-8",         "fenc": "utf-8",    "bom": 0},
      \ "b": {"name": "utf-8 with BOM","fenc": "utf-8",    "bom": 1},
      \ "l": {"name": "utf-16 LE BOM", "fenc": "utf-16le", "bom": 1},
      \ "e": {"name": "utf-16 BE BOM", "fenc": "utf-16",   "bom": 1},
      \ }

let g:GrooVim_LineEndings = {
      \ "u": {"name": "Unix (LF)",     "ff": "unix"},
      \ "w": {"name": "Windows (CRLF)","ff": "dos"},
      \ "m": {"name": "Macintosh (CR)","ff": "mac"},
      \ }

" Note: Which of them this buffer is on, as the letter that answers for it! By
" Questor
func! GrooVim_EncodingNow() abort
  let l:enc = &fileencoding ==# "" ? &encoding : &fileencoding
  if l:enc =~? "^utf-16le" | return "l" | endif
  if l:enc =~? "^utf-16"   | return "e" | endif
  if l:enc =~? "^utf-8"    | return &bomb ? "b" : "u" | endif
  return "a"
endfunc

func! GrooVim_LineEndingNow() abort
  for [l:key, l:one] in items(g:GrooVim_LineEndings)
    if &fileformat ==# l:one.ff | return l:key | endif
  endfor
  return "u"
endfunc

" Note: The settings of the FILE that is open: the Encoding menu and the "EOL
" Conversion" of Notepad++.
"
" Note: This screen does NOT end with "apply or save", and it is the only one.
" What it sets belongs to the document and not to GrooVim -- keeping "utf-16"
" for the next time you open the editor would be keeping the wrong thing. So the
" summary is held by a pause of its own! By Questor
func! GrooVim_ConfigureFile() range abort

  let l:encodingNow = GrooVim_EncodingNow()
  let l:encoding = GrooVim_GetOptions(
   \ "Encoding: [a]nsi, [u]tf-8, utf-8 with [b]om, utf-16 [l]e, utf-16 b[e]",
   \ ["a", "u", "b", "l", "e"], "u", l:encodingNow)

  " Note: The two halves of that menu. Its top list READS the file again as the
  " encoding you picked -- the bytes are untouched and their meaning changes --
  " and its "Convert to" leaves the text alone and WRITES it as the new one! By
  " Questor
  let l:how = GrooVim_GetOptions(
   \ "Apply it by [r]eading the file again or by [c]onverting what is open",
   \ ["r", "c"], "c", "")

  let l:lineEnding = GrooVim_GetOptions(
   \ "Line ending: [u]nix LF, [w]indows CRLF, [m]acintosh CR",
   \ ["u", "w", "m"], "u", GrooVim_LineEndingNow())

  call GrooVim_FileSettingsApply(l:encoding, l:how, l:lineEnding)

  call input("Press <Enter>! ")
  echomsg "   "

endfunc

" Note: Apart from the asking, so that a case can put it through every
" combination without typing an answer! By Questor
func! GrooVim_FileSettingsApply(encoding, how, lineEnding) abort

  let l:enc = g:GrooVim_Encodings[a:encoding]
  let l:eol = g:GrooVim_LineEndings[a:lineEnding]

  if a:how ==# "r"
    " Note: Reading again throws away what is not written yet, so it is refused
    " while there is something to lose! By Questor
    if &modified
      call GrooVim_GrooVimBarMsg("Save first: reading again would lose your changes!", 6)
      return 0
    endif
    try
      exec "edit! ++enc=" . l:enc.fenc . " ++ff=" . l:eol.ff
      let &l:bomb = l:enc.bom
      call GrooVim_GrooVimBarMsg("Read again as " . l:enc.name . ", " . l:eol.name . "!", 5)
      return 1
    catch
      call GrooVim_GrooVimBarMsg("This Vim cannot read it as " . l:enc.name . "!", 6)
      return 0
    endtry
  endif

  let &l:fileencoding = l:enc.fenc
  let &l:bomb = l:enc.bom
  let &l:fileformat = l:eol.ff

  " Note: Marked as changed on purpose. Vim writes the new encoding at the next
  " write and not before, so a buffer that says it has nothing to write would
  " leave the setting looking applied and the file untouched! By Questor
  setlocal modified

  call GrooVim_GrooVimBarMsg("Will be written as " . l:enc.name . ", " .
   \ l:eol.name . " -- save to apply!", 6)
  return 1

endfunc

" Note: What Notepad++ calls View, Show Symbol: what is DRAWN on the screen that
" is not in the file. Two things for now, the two that menu has checked in the
" screenshot this came from! By Questor
func! GrooVim_ConfigureView() range abort

  call GrooVim_OptsBegin()

  let l:symbols = GrooVim_GetOptions("Show space and tab",
   \ [0,1], 1, g:GrooVim_ShowSpaceAndTab)
  let g:GrooVim_ShowSpaceAndTab = l:symbols
  call GrooVim_OptsUpdate("let g:GrooVim_ShowSpaceAndTab =",
   \ "let g:GrooVim_ShowSpaceAndTab = " . g:GrooVim_ShowSpaceAndTab, 0)

  " Note: On or off, and not the char itself: the char is what an EMPTY answer
  " would be, and empty already means "keep what is there" in every question of
  " GrooVim. Set "g:GrooVim_IndentGuideChar" by hand for another char! By Questor
  let l:guides = GrooVim_GetOptions("Show indent guide",
   \ [0,1], 1, g:GrooVim_IndentGuideChar != "" ? 1 : 0)
  if l:guides == 0
    if g:GrooVim_IndentGuideChar != ""
      let g:GrooVim_IndentGuideCharLast = g:GrooVim_IndentGuideChar
    endif
    let l:char = ""
  else
    let l:char = g:GrooVim_IndentGuideChar != ""
     \ ? g:GrooVim_IndentGuideChar : g:GrooVim_IndentGuideCharLast
  endif
  let g:GrooVim_IndentGuideChar = l:char
  call GrooVim_OptsUpdate("let g:GrooVim_IndentGuideChar =",
   \ "let g:GrooVim_IndentGuideChar = " . string(l:char), 0)

  call GrooVim_SymbolsSet()

  call GrooVim_OptsEnd()

endfunc

func! GrooVim_ConfigureGeneral() range abort

  call GrooVim_OptsBegin()

  let g:GrooVim_SessionAuto = GrooVim_GetOptions("Save and restore the session by itself",
   \ [0,1], 1, g:GrooVim_SessionAuto)
  call GrooVim_OptsUpdate("let g:GrooVim_SessionAuto =",
   \ "let g:GrooVim_SessionAuto = " . g:GrooVim_SessionAuto, 0)

  " Note: There is no question here about the clipboard, and working out why took
  " an hour of arguing with someone who was right.
  "
  " Note: OSC 52 is the LAST method of the cascade. If it is reached, everything
  " else has already failed -- so turning it off cannot leave you better off, it
  " leaves you with nothing. The only reason the question ever had an answer
  " worth giving was a gap: with OSC 52 on, the copy went out through the
  " terminal and GrooVim stopped keeping its own copy in a file, so on a terminal
  " that ignores the sequence you lost both.
  "
  " Note: The gap is closed -- see "GrooVim_ClipAssumed" in the "behaviour" part,
  " which keeps the file whenever the method is one that cannot be confirmed. On
  " goes back to being never worse than off, and a question nobody can answer
  " wrongly is a question not worth asking! By Questor

  call GrooVim_OptsEnd()

endfunc

" Note: Get and validate a givem option! By Questor
" Note: Asks until the answer passes the test, ALWAYS with the same question.
" Repeating the very same line is what tells you the answer did not take, and it
" is how every question of GrooVim behaves.
"
" Note: "IsValid" takes the answer and says whether it serves. A closure carries
" whatever else the test needs! By Questor
func! GrooVim_AskUntilValid(prompt, IsValid) abort
  while 1
    let l:answer = input(a:prompt)
    if call(a:IsValid, [l:answer])
      return l:answer
    endif
  endwhile
endfunc

" Note: Asks a question that only takes certain answers, and keeps asking until it
" gets one of them. An empty answer keeps what is in force.
"
" Note: The prompt is BUILT here, from what the function already receives. Every
" call site used to spell out "[0[default]/1][now: \"0\"]? " by hand, in eight
" places, and a change to the list of options would not reach the text. Now it
" cannot drift.
"
" Note: An empty "currentValue" is a question with nothing in force -- the one
" that asks what to get from a file name is like that. No "now" is shown and an
" empty answer takes the factory default! By Questor
" Note: The prompt of a question whose answer is a NUMBER and not one of a list.
" Same shape as the one above, so the screens read alike! By Questor
func! GrooVim_NumberToPrompt(factoryDefault, currentValue) abort

  let l:prompt = "[a number, " . a:factoryDefault . "[default]]"
  if ("" . a:currentValue . "") != ""
    let l:prompt = l:prompt . "[now: \"" . a:currentValue . "\"]"
  endif

  return l:prompt . "? "
endfunc

" Note: Asks for a number the way "GrooVim_GetOptions" asks for an option: empty
" keeps what is in force, anything that is not a width asks again, and the
" message at the end is what makes the answers STACK into a summary -- see the
" long note in "GrooVim_GetOptions"! By Questor
func! GrooVim_GetNumber(question, factoryDefault, currentValue) abort

  let l:inForce = ("" . a:currentValue . "") != "" ? a:currentValue : a:factoryDefault
  let l:prompt = a:question . " " .
   \ GrooVim_NumberToPrompt(a:factoryDefault, a:currentValue)

  let l:answer = GrooVim_AskUntilValid(l:prompt,
   \ {answer -> answer ==# "" ? 1 : GrooVim_IsPositiveNumber(answer)})

  if l:answer ==# ""
    let l:answer = l:inForce
  endif

  echomsg "   "

  return l:answer
endfunc

" Note: How a question is written, and it is one rule with two halves:
"
"   A yes or a no is [0,1].    "Case sensitive (SEARCH/REPLACE)"
"   A choice is LETTERS.       "Get [f]filename or [p]filename and path"
"
" Note: The letter is the first one of the word it stands for, written in front
" of that word, so the answer is read off the question itself: "[f]forward",
" "[b]backward", "[a]apply", "[s]apply and save".
"
" Note: Numbers for a choice is what this is here to stop. "Get [0]filename or
" [1]filename and path" made the reader carry an arbitrary pairing in their head
" for as long as the question was on screen, and there is nothing about a 0 that
" means "filename". A 0 and a 1 mean something on their own -- no and yes -- and
" that is the only thing they should ever be asked to mean! By Questor
func! GrooVim_GetOptions(question, possibleOptions, factoryDefault, currentValue) abort

  let l:inForce = ("" . a:currentValue . "") != "" ? a:currentValue : a:factoryDefault
  let l:prompt = a:question . " " .
   \ GrooVim_OptionsToPrompt(a:possibleOptions, a:factoryDefault, a:currentValue)

  let l:optionReturn = GrooVim_AskUntilValid(l:prompt,
   \ {answer -> GrooVim_ValidateOptions(answer, a:possibleOptions, l:inForce)})

  if ("" . l:optionReturn . "") == ""
    let l:optionReturn = l:inForce
  endif

  " Note: Shows the value the question ended up with, right after the answer.
  "
  " Note: This is not decoration. Being a MESSAGE, and not merely the leftover of
  " "input()", is what makes the answered questions STACK on the screen instead
  " of each one wiping the previous, which is how the configuration builds itself
  " into a summary and ends at the "Press ENTER" prompt. Measured on the terminal:
  " with nothing echoed, the line is erased and nothing accumulates.
  "
  " Note: What was TYPED, or "[empty]" when nothing was. It also has to be non
  " empty, or the line is erased just the same.
  "
  " Note: Spaces and nothing else. What was answered is already on the line,
  " printed by "input()" itself, so there is nothing to add: this exists only to
  " BE a message. An empty string would not do, the line would be erased! By Questor
  "
  " Note: And being here, inside the asker itself, every question of GrooVim gets
  " this for free, with no per-option sentence to write! By Questor
  echomsg "   "

  return l:optionReturn
endfunc

" Note: The bracket part of the prompt: the options, which of them is the factory
" default, and the value in force. In list order, so what you see follows what the
" caller declared! By Questor
func! GrooVim_OptionsToPrompt(possibleOptions, factoryDefault, currentValue) abort

  let l:parts = []
  for l:option in a:possibleOptions
    if ("" . l:option . "") == ("" . a:factoryDefault . "")
      call add(l:parts, l:option . "[default]")
    else
      call add(l:parts, l:option)
    endif
  endfor

  let l:prompt = "[" . join(l:parts, "/") . "]"
  if ("" . a:currentValue . "") != ""
    let l:prompt = l:prompt . "[now: \"" . a:currentValue . "\"]"
  endif

  return l:prompt . "? "
endfunc

" Note: What the macro takes as "how many times": the "x" that runs to the
" last/first line, or a whole number above zero.
"
" Note: The digits are checked with a pattern and not with "str2nr()". Vim reads
" "3abc" as 3, so the old test took it for a valid three! By Questor
func! GrooVim_IsRepetitionCount(answer) abort
  if a:answer ==# "x"
    return 1
  endif
  return GrooVim_IsPositiveNumber(a:answer)
endfunc

" Note: A whole number above zero, and nothing else.
"
" Note: Checked with a pattern and not with "str2nr()". Vim reads "3abc" as 3, so
" a test made of "str2nr()" alone takes it for a valid three! By Questor
func! GrooVim_IsPositiveNumber(answer) abort
  return a:answer =~ '^\d\+$' && str2nr(a:answer) > 0
endfunc

" Note: Check if a given option is valid! By Questor
func! GrooVim_ValidateOptions(optionNow, possibleOptions, defaultOption) abort

  " Note: An empty answer means "keep what is in force", so it is valid exactly
  " when there IS something in force. Checked BEFORE the loop: it never depended
  " on the options, and inside the loop it also made an EMPTY list of options
  " reject an empty answer for ever, with no way out of the question! By Questor
  if a:optionNow == ""
    return ("" . a:defaultOption . "") != ""
  endif

  for l:value in a:possibleOptions
    " Note: "("" . l:value . "")" -> To force string compare! By Questor
    if ("" . l:value . "") == a:optionNow
      return 1
    endif
  endfor

  return 0
endfunc

" Note: Highlight matches when jumping to next! This rewires n and N to do
" the highlighing the match in red! By Questor
nnoremap <silent> <expr> n ":call GrooVim_HLNext(\"\", \"\", \"\", 0)<cr>" . (v:searchforward ? (g:grooVimSearchFoward ? 'n' : 'N') : (g:grooVimSearchFoward ? 'N' : 'n')) . ":call GrooVim_HLNext(\"f\", 0.4, \"1\", 1)<cr>"
nnoremap <silent> <expr> N ":call GrooVim_HLNext(\"\", \"\", \"\", 0)<cr>" . (v:searchforward ? (g:grooVimSearchFoward ? 'N' : 'n') : (g:grooVimSearchFoward ? 'n' : 'N')) . ":call GrooVim_HLNext(\"b\", 0.4, \"0\", 1)<cr>"

