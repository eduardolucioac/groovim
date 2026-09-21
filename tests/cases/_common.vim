" Prelude shared by every case.
"
" A case starts with:
"   exec "source " . expand("<sfile>:p:h") . "/_common.vim"
"   call GT_Name(expand("<sfile>:t:r"))
" and ends with:
"   call GT_Done()
"
" The name comes from the FILE itself, never written by hand: renaming a case and
" forgetting the string inside it made 13 cases run, write under a name nobody
" was looking for, and be reported as "did not reach the end" -- a quiet way of
" losing coverage.

let g:GT_BASE = expand("<sfile>:p:h:h")
let g:GT_FIX = $GROOVIM_TEST_FIXTURES != "" ? $GROOVIM_TEST_FIXTURES : g:GT_BASE . "/fixtures"
let g:GT_OUT = $GROOVIM_TEST_OUT != "" ? $GROOVIM_TEST_OUT : g:GT_BASE . "/results"
let g:GT_NAME = "unnamed"
let g:GT_LINES = []

" A terminal as wide as the one GrooVim is used on.
"
" Without this a case runs in the 80 columns a pty falls back to with no terminal
" behind it, and that is not a neutral choice: a prompt wider than the screen
" wraps, the message area overflows, and the hit-enter Vim raises for that EATS
" the first key fed to it. Questions were being shortened to fit a width nobody
" reads them at.
set columns=200

func! GT_Name(name)
  let g:GT_NAME = a:name
  let g:GT_LINES = []
endfunc

" Writes after every check, and not only at the end.
"
" A case that dies halfway used to leave an empty file, and a test with no output
" cannot be told apart from a test that never ran. Line by line, what passed
" stays on record and the exact point of the stop shows up.
func! GT_Write()
  call writefile(g:GT_LINES, g:GT_OUT . "/" . g:GT_NAME . ".txt")
endfunc

func! GT_Ok(description, condition, extra)
  call add(g:GT_LINES, printf("  %-50s %s%s", a:description, (a:condition ? "ok" : "FAILED"), a:extra))
  call GT_Write()
endfunc

" A note that is not a check: it says where the case went through.
func! GT_Note(text)
  call add(g:GT_LINES, "  .. " . a:text)
  call GT_Write()
endfunc

func! GT_Done()
  call add(g:GT_LINES, "END")
  call GT_Write()
  qa!
endfunc

" Marks the end BEFORE a step that is meant to make Vim itself quit.
"
" Without it the runner would report "did not reach the end" exactly when the
" case ended as it should. If Vim does NOT quit, whatever comes next is written
" after the END and the failure still shows.
func! GT_DoneHere()
  call add(g:GT_LINES, "END")
  call GT_Write()
endfunc

" Runs the body of the case AFTER Vim has started.
"
" "vim -S case.vim" sources the script during startup, and some events do not
" happen there. "OptionSet" is one: a ":set shiftwidth=8" written straight into
" the case fires nothing, while the same command typed by hand does. A case that
" depends on it would measure the opposite of what really happens.
"
" Use: put the body in a function and call
"   call GT_AfterStartup("FunctionName")
" as the last line of the file.
func! GT_AfterStartup(functionName)
  call timer_start(50, {t -> call(a:functionName, [])})
endfunc

" Waits for a condition to become true and only THEN goes on.
"
" Marking the steps with fixed times produces an unstable case. "feedkeys" with
" "t" only queues the keys, and Vim processes them when it returns to the main
" loop -- a timer that fires before that samples early and the case fails with
" nothing wrong in the product. Measured: the same case passing and failing in
" consecutive runs.
"
" Use:
"   call GT_When('reg_recording() != ""', "NextStep")
"
" Gives up after "g:GT_WAIT_LIMIT" tries and calls the next step anyway -- a case
" that hangs is worse than one that fails.
let g:GT_WAIT_LIMIT = 60

func! GT_When(condition, nextStep)
  call GT_WhenTry(a:condition, a:nextStep, 0)
endfunc

func! GT_WhenTry(condition, nextStep, try)
  if eval(a:condition) || a:try >= g:GT_WAIT_LIMIT
    call call(a:nextStep, [])
    return
  endif
  call timer_start(50, {t -> GT_WhenTry(a:condition, a:nextStep, a:try + 1)})
endfunc

" Presses an F-key shortcut.
"
" There used to be a clock here to defeat: pressing the same F key twice within
" "g:GrooVim_CommandZRepeat" meant "repeat the last command", and two feedkeys()
" calls in a row from a case are milliseconds apart -- so the second shortcut
" silently repeated the first. Measured: a Title Case that followed a lowercase
" left the word lowercase, and the case was accusing the product of a defect that
" was in the test.
"
" Nothing is timed any more. A shortcut repeats when its OWN key is pressed with
" no key after it, which a case does on purpose or not at all.
func! GT_Press(keys)
  call feedkeys(a:keys, "x")
endfunc

" Every line of GrooVim: the ".vimrc" and the parts it loads.
"
" GrooVim is a directory now, not a file. A case that reads the source and stops
" at the ".vimrc" reads the loader and nothing else -- 374 lines out of six
" thousand -- and every check it makes comes back empty and PASSES, which is the
" worst way for a check to be wrong.
" The body of a function, as TEXT.
"
" ":function" prints it through the display, so with "list" on and a "space:" in
" "listchars" every space comes back as the character that draws it -- measured:
" "setlocal.noma.nomodified", with the dots being the symbol for a space, and the
" indentation coming back as guide characters. The option is turned off around
" the capture so that the text is the text.
func! GT_FunctionText(name)
  let l:kept = &l:list
  try
    setlocal nolist
    return execute("function " . a:name)
  finally
    let &l:list = l:kept
  endtry
endfunc

func! GT_SourceLines()
  let l:lines = readfile($GROOVIM_TEST_VIMRC)
  for l:part in sort(glob(fnamemodify($GROOVIM_TEST_VIMRC, ":h") . "/groovim/*.vim", 0, 1))
    let l:lines = l:lines + readfile(l:part)
  endfor
  return l:lines
endfunc

" ---- helpers used by more than one case ----

" How many occurrence-list windows there are in the current tab.
func! GT_PanelsInTab()
  let l:total = 0
  for l:window in range(1, winnr("$"))
    if bufname(winbufnr(l:window)) =~ "GrooVim_SearchGuyResults"
      let l:total = l:total + 1
    endif
  endfor
  return l:total
endfunc

" The layout of every tab, as "[a.txt+list][b.txt+list]". It is what makes a
" wrongly built tab readable in the failure line.
func! GT_Layout()
  let l:text = ""
  for l:tab in range(1, tabpagenr("$"))
    let l:text = l:text . "[" .
      \ join(map(tabpagebuflist(l:tab), 'fnamemodify(bufname(v:val), ":t")'), "+") . "]"
  endfor
  return l:text
endfunc

" Goes to the list window of the current tab. Returns 1 when it got there.
func! GT_GoToList()
  return GrooVim_PanelFocus("GrooVim_SearchGuyResults", 0)
endfunc

" Builds the state a search with list would leave, without relying on the keys.
"
" Calling GrooVim_SearchGuy() straight from a script does not reproduce the real
" path (the one that goes through F3) and the result varies. For what these cases
" check -- the panel, the keys, the navigation -- state built by hand is stable
" and enough. What depends on the real path is checked on the screen, with
" screen.sh.
func! GT_BuildSearch(value, files, occurrences)
  " The search register is part of the state a search leaves behind. Without it
  " the "norm n" at the end of navigation fails, and an error inside a command
  " fired by feedkeys() opens a "Press ENTER" that hangs the case until timeout.
  let @/ = a:value
  let g:GrooVim_SearchGuyValue = a:value
  let g:GrooVim_SearchGuyFilesSearched = a:files
  let g:GrooVim_SearchGuyEnabled = 1
  let g:search_WithList = 1
  let g:searchReplace_InAllOpened = 1
  let g:matchedLinesGlobalNavArray = a:occurrences
  let l:body = []
  for l:entry in a:occurrences
    call add(l:body, l:entry == "0" ? "-----" : "line of " . l:entry)
  endfor
  let g:matchedLinesGlobal = join(l:body, "\n")
endfunc
