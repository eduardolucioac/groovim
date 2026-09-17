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

  let l:answer = GrooVim_GetOptions("Just apply or apply and save", ["a", "s"], "a", "")

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
    let g:search_Direction = GrooVim_GetOptions("Search forward/backward", ["f","b"], "f", g:search_Direction)
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

  " Note: On or off, and not the char itself: the char is what an EMPTY answer
  " would be, and empty already means "keep what is there" in every question of
  " GrooVim. Set "g:GrooVim_IndentGuideChar" by hand for another char! By Questor
  let l:guides = GrooVim_GetOptions("Draw the indent guides",
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
  call GrooVim_OptsUpdate("let g:GrooVim_IndentGuideChar =",
   \ "let g:GrooVim_IndentGuideChar = " . string(l:char), 0)
  call GrooVim_IndentGuideSet()

  call GrooVim_OptsEnd()

endfunc

func! GrooVim_ConfigureGeneral() range abort

  call GrooVim_OptsBegin()

  let g:GrooVim_SessionAuto = GrooVim_GetOptions("Save and restore the session by itself",
   \ [0,1], 1, g:GrooVim_SessionAuto)
  call GrooVim_OptsUpdate("let g:GrooVim_SessionAuto =",
   \ "let g:GrooVim_SessionAuto = " . g:GrooVim_SessionAuto, 0)

  " Note: Two answers and not three. There IS a third state -- "g:osc52_force_avail
  " = 0" makes Vim ask the terminal with a DA1 query and use OSC 52 only if the
  " answer advertises "52" -- and it is a real thing, not another way of saying
  " off. It is not asked here because of WHO answers that query: in practice the
  " xterm family and almost nothing else. On every other terminal "ask" behaves
  " exactly like "no", and a third answer that usually does what another one does
  " is worse than not having it.
  "
  " Note: It is still there for whoever wants it, one line in your own
  " configuration, and it is written down where it lives (the "behaviour" part)!
  " By Questor
  let g:GrooVim_EnableOSC52 = GrooVim_GetOptions(
   \ "Let a copy leave through the terminal (OSC 52, this is what crosses SSH)",
   \ [0,1], 1, g:GrooVim_EnableOSC52)
  call GrooVim_OptsUpdate("let g:GrooVim_EnableOSC52 =",
   \ "let g:GrooVim_EnableOSC52 = " . g:GrooVim_EnableOSC52, 0)
  call GrooVim_OSC52Apply()

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

