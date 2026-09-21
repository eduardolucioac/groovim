"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
"HELP
"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" Note: To facilitate and avoid performance problems that text should always be
" the last! By Questor

" Note: Every shortcut of the F groups, in ONE place.
"
" Note: The help of "F9" is WRITTEN from this list, and so is the menu. It used
" to be two hundred lines of prose kept by hand beside the block of code that
" answers the keys, and the two drifted every time anything moved: keys that
" changed group and were still listed under the old one, a whole "<F5>" block
" that did not exist at all, messages sending you to letters that had been
" retired. One list, and the drift has nowhere left to happen.
"
" Note: "modes" is where the key answers -- "n" normal, "i" insert, "v" visual.
" It is not decoration: the case that checks this list against the code reads it,
" and writing it wrong is a failure! By Questor
let g:GrooVim_ShortcutGroups = [
 \ ["F2", "Editing, and what acts on the FILE itself", "Edit"],
 \ ["F3", "The editing you reach for most, and searching", "Search"],
 \ ["F4", "The installed plugins and what they do", "Plugins"],
 \ ["F5", "What acts on the EDITOR -- tabs, leaving -- and the settings", "Editor"]
 \ ]

let g:GrooVim_Shortcuts = [
 \ {"group": "F2", "key": "h", "modes": "niv", "run": ':left', "what": "Aligns to left"},
 \ {"group": "F2", "key": "k", "modes": "niv", "run": ':right', "what": "Aligns to right"},
 \ {"group": "F2", "key": "j", "modes": "niv", "run": ':center', "what": "Aligns to center"},
 \ {"group": "F2", "key": "up", "break": 1, "modes": "niv", "run": {"ni": 'call GrooVim_CaseOfTheWord("U")', "v": 'call GrooVim_ToUpperLower("Upper")'}, "what": "Changes to uppercase"},
 \ {"group": "F2", "key": "down", "modes": "niv", "run": {"ni": 'call GrooVim_CaseOfTheWord("u")', "v": 'call GrooVim_ToUpperLower("Lower")'}, "what": "Changes to lowercase"},
 \ {"group": "F2", "key": "t", "modes": "niv", "run": 'call GrooVim_ToTitleCase(l:mode)',
 \  "what": "Title Case: the first letter of every word up, the rest down",
 \  "notes": [
 \   "In normal and insert mode it is the word under the cursor; in visual mode, every word of the selection and nothing outside it. An apostrophe ENDS a word, so \"don't\" becomes \"Don'T\"",
 \   "The three of them leave the cursor where it was"
 \  ]},
 \ {"group": "F2", "key": "c", "break": 1, "modes": "niv", "run": 'call GrooVim_ClipSet(join(getline(1, "$"), "\n"))', "what": "Copy all text in the current buffer"},
 \ {"group": "F2", "key": "end", "modes": "niv", "run": 'exec "norm viw"', "what": "Selects the word under the cursor"},
 \ {"group": "F2", "key": "q", "break": 1, "modes": "niv", "run": 'call GrooVim_XenRec()',
 \  "what": "Start and stop recording a macro",
 \  "notes": [
 \   "The same F2->q does both: the first press starts the recording and says so, the second ends it. It used to take a key of its own",
 \   "What is recorded goes into the register |a| , and F2->w runs it. The F2->q that ends the recording is cut off the register, so playing it back does not start another one"
 \  ]},
 \ {"group": "F2", "key": "w", "modes": "niv", "run": 'call GrooVim_Operation("[macro]", "GrooVim_XenPlay", [0])', "what": "Run a macro"},
 \ {"group": "F2", "key": "e", "modes": "niv", "run": 'call GrooVim_Operation("[macro]", "GrooVim_XenPlay", [1])', "what": "Run a macro certain number of times or repeatedly until the last line"},
 \ {"group": "F2", "key": "p", "break": 1, "modes": "niv", "run": 'call GrooVim_Operation("[file name]", "GrooVim_GetFileNameAndPath", [])', "what": "Copies to the clipboard the name or path and name of the current buffer/file"},
 \ {"group": "F2", "key": "y", "modes": "niv", "run": 'call GrooVim_Operation("[save a copy]", "GrooVim_SaveACopy", [])', "what": "Save to disk and open in a new tab a copy of the current file"},
 \ {"group": "F3", "key": "a", "modes": "niv", "run": 'exec "norm ggVG$"', "what": "Select all text in the current buffer"},
 \ {"group": "F3", "key": "d", "modes": "niv", "run": {"n": 'call GrooVim_DuplicateLine()', "i": 'call GrooVim_DuplicateLine()', "v": 'call GrooVim_DuplicateSelection()'},
 \  "what": "Duplicates the current line/selection",
 \  "notes": [
 \   "If in the visual mode can not be replicated"
 \  ]},
 \ {"group": "F3", "key": "del", "modes": "ni", "run": 'call GrooVim_SelectRange(l:mode)', "what": "Selects an area"},
 \ {"group": "F3", "key": "v", "modes": "ni", "run": 'exec "norm gv"', "what": "Reselect area, the |gv| of Vim"},
 \ {"group": "F3", "key": "/", "break": 1, "modes": "niv", "run": {"nv": 'call feedkeys("\\z/")', "i": 'call feedkeys("\<Esc>\\z/i")'}, "what": "Removes search highlights"},
 \ {"group": "F3", "key": "m", "modes": "niv", "run": 'call GrooVim_MarkWord(l:mode)',
 \  "what": "Mark every occurrence of the word under the cursor",
 \  "notes": [
 \   "In visual mode it marks what is SELECTED. Pressing it again on the same word takes the marks down, and so does |</>| , which clears the search highlight as well",
 \   "It does not move the cursor and does not touch what <n> would find next: you can mark a name and go on searching for something else. It is the \"Style all occurrences of token\" of Notepad++"
 \  ]},
 \ {"group": "F3", "key": "f", "modes": "niv", "run": {"ni": 'call GrooVim_Operation("[search]", "GrooVim_SearchWithMyOptions", ["n"])', "v": 'call GrooVim_Operation("[search]", "GrooVim_SearchWithMyOptions", ["v"])'}, "what": "Opens for search"},
 \ {"group": "F3", "key": "h", "modes": "niv", "run": {"ni": 'call GrooVim_Operation("[replace]", "GrooVim_EntertainmentReplace", ["n"])', "v": 'call GrooVim_Operation("[replace]", "GrooVim_EntertainmentReplace", ["v"])'},
 \  "what": "Opens to replace",
 \  "notes": [
 \   "The replace begins at the CURSOR. WITH confirmation, having reached the end of the file it continues from the top if occurrences were left behind, and says so, the way Notepad++ does. Without confirmation it does only what it says, from the cursor down. Configure it with F5->c and then |[r]|"
 \  ]},
 \ {"group": "F3", "key": "end", "modes": "niv", "run": 'call GrooVim_SelectNSearch(1, l:mode)', "what": "Select and search the word under the cursor (case sensitive)"},
 \ {"group": "F4", "key": "n", "modes": "niv", "run": 'call GrooVim_ToggleNERDTreeTabs()',
 \  "what": "Opens/closes the *NERDTree*",
 \  "needs": {"switch": "enable_nerdtree_vim", "name": "the NERDTree plugin"}},
 \ {"group": "F4", "key": "b", "modes": "niv", "run": 'call GrooVim_BookmarkToggle()',
 \  "what": "Marks the line, or takes the mark off (*bookmark*)"},
 \ {"group": "F4", "key": "i", "modes": "niv", "run": 'call GrooVim_BookmarkAnnotate()',
 \  "what": "Writes a note on the marked line, or changes it (*bookmark*)"},
 \ {"group": "F4", "key": "l", "modes": "niv", "run": 'call GrooVim_BookmarkList()',
 \  "what": "Lists every marked line, to walk between them"},
 \ {"group": "F4", "key": "c", "break": 1, "modes": "niv", "run": 'call GrooVim_BookmarkClearAll()',
 \  "what": "Takes every mark off EVERY file, and asks first"},
 \ {"group": "F5", "key": "s", "modes": "niv", "run": 'call GrooVim_Save(l:mode)',
 \  "what": "Save to disk",
 \  "notes": [
 \   "In visual mode it writes the SELECTION to a file of its own"
 \  ]},
 \ {"group": "F5", "key": "e", "modes": "niv", "run": ':wa', "what": "Save every changed file"},
 \ {"group": "F5", "key": "n", "break": 1, "modes": "niv", "run": 'call GrooVim_TabNew()',
 \  "what": "Open a new tab",
 \  "notes": [
 \   "A document you have not saved yet is called |new|1| , |new|2| ... the way Notepad++ names them. It is a name on SCREEN only -- the buffer stays nameless, so saving it asks you where to put it instead of writing a file called \"new 1\" wherever you happen to be",
 \   "The new tab goes to the END of the tab line, and the number is the LOWEST one nobody is using: close |new|2| of |new|1|,|new|2|,|new|3| and the next one is |new|2| again"
 \  ]},
 \ {"group": "F5", "key": "t", "modes": "niv", "run": 'call GrooVim_TabToReturnSet()',
 \  "what": "Allows always returning to a particular tab using <Alt-Down>",
 \  "notes": [
 \   "The same key takes the mark off, from whatever tab you press it on. One tab holds it at a time, so moving it means turning it off and then on again on the tab you want"
 \  ]},
 \ {"group": "F5", "key": "q", "break": 1, "modes": "niv", "run": 'call GrooVim_CloseAsking("q")', "what": "Close the window"},
 \ {"group": "F5", "key": "w", "modes": "niv", "run": 'call GrooVim_TabClose()',
 \  "what": "Close the tab you are in",
 \  "notes": [
 \   "On the LAST tab Vim refuses to close it, so what closes is the document, leaving the empty one Notepad++ calls |new|1|"
 \  ]},
 \ {"group": "F5", "key": "o", "modes": "niv", "run": 'call GrooVim_CloseAsking("tabonly")', "what": "Close all other tabs"},
 \ {"group": "F5", "key": ".", "modes": "niv", "run": 'call GrooVim_TabCloseSide(1)', "what": "Close every tab to the RIGHT of this one"},
 \ {"group": "F5", "key": ",", "modes": "niv", "run": 'call GrooVim_TabCloseSide(-1)',
 \  "what": "Close every tab to the LEFT of this one",
 \  "notes": [
 \   "The keys of |<<>| and |<>>| without the Shift: the comma is to the left of the dot, which is the way each one closes"
 \  ]},
 \ {"group": "F5", "key": "a", "modes": "niv", "run": 'call GrooVim_CloseAsking("qa")',
 \  "what": "Close everything and leave",
 \  "notes": [
 \   "Every way of closing ASKS about unsaved text: save, throw away, or go back"
 \  ]},
 \ {"group": "F5", "key": "r", "break": 1, "modes": "niv", "run": {"i": 'call feedkeys("\<Esc>\\zvvi")', "nv": 'call feedkeys("\\zvv")'}, "what": "Reloads the file|.vimrc|in all tabs"},
 \ {"group": "F5", "key": "c", "modes": "niv", "run": 'call GrooVim_Configure()',
 \  "what": "Opens the settings -- ALL of them",
 \  "notes": [
 \   "It asks which of them first: |[i]ndent| , the width and what <Tab> puts; |[v]iew| , what is DRAWN and is not in the file, the language among it; |[f]ile| , the encoding and what ends a line IN the file you have open; |[s]earch| ; |[r]eplace| ; |[g]eneral| . Then it opens that screen",
 \   "The indent one is the \"Tab Settings\" of Notepad++, and the view one is its \"View, Show Symbol\"",
 \   "On every screen, leaving an answer EMPTY keeps the value shown as \"in use\". At the end a summary of what you chose is held on screen until you press <Enter>",
 \   "|[f]ile| is the only one with nothing to save: an encoding belongs to the DOCUMENT and not to GrooVim, so it applies to what is open and stops there",
 \   "There is one door and only one. Each screen used to have a key of its own, so the letters |f| , |h| and |i| of this group are free again"
 \  ]},
 \ {"group": "F5", "key": "[", "break": 1, "modes": "niv", "run": 'call GrooVim_SessionSaveByHand()', "what": "Saves the current session"},
 \ {"group": "F5", "key": "]", "modes": "niv", "run": 'call GrooVim_SessionLoadByHand()',
 \  "what": "Brings the last saved session back",
 \  "notes": [
 \   "The session saves itself when you leave and comes back when you open GrooVim with NO file, the way Notepad++ does. While that is on, |<[>| and |<]>| say so instead of pretending to work. Turn it off with F5->c"
 \  ]}
 \ ]

" Note: How a key is written on screen. A letter goes in plain angle brackets; a
" named key gets its capital back; punctuation is wrapped in bars, because the
" help syntax of Vim would otherwise eat a "/" or a "[" ! By Questor
func! GrooVim_ShortcutKeyShown(key) abort
  let l:named = {"up": "Up", "down": "Down", "end": "End", "del": "Del",
   \ "left": "Left", "right": "Right", "home": "Home", "insert": "Insert"}
  let l:name = get(l:named, a:key, a:key)
  if a:key =~ '^\w\+$'
    return "        <" . l:name . "> - "
  endif
  return "       |<" . l:name . ">|- "
endfunc

" Note: Which modes a key answers in, spelled the way the help spells it! By
" Questor
func! GrooVim_ShortcutModes(modes) abort
  let l:spelled = []
  for l:pair in [["n", "normal mode"], ["i", "insert"], ["v", "visual"]]
    if stridx(a:modes, l:pair[0]) >= 0
      call add(l:spelled, l:pair[1])
    endif
  endfor
  return "(" . join(l:spelled, "/") . ")"
endfunc

" Note: The same list, written as Markdown for the README.
"
" Note: The README used to keep its own copy of every shortcut, and it drifted
" the furthest of all of them: it still listed the layout of three groups, with
" no "F5" at all, and the same letter three times over in one of them. It is
" written from here now, and a case of the battery refuses to pass while the file
" and this disagree.
"
" Note: The marks the help syntax needs are taken out -- "|" is a link in a help
" file and a table in Markdown! By Questor
func! GrooVim_ShortcutsMarkdown() abort

  let l:out = []

  for l:group in g:GrooVim_ShortcutGroups
    call add(l:out, "")
    call add(l:out, " * **" . l:group[0] . "** and then... *(" .
     \ GrooVim_ShortcutPlain(l:group[1]) . ")*")
    call add(l:out, "")

    for l:one in g:GrooVim_Shortcuts
      if l:one.group !=# l:group[0]
        continue
      endif
      let l:named = {"up": "Up", "down": "Down", "end": "End", "del": "Del"}
      call add(l:out, "    - `" . get(l:named, l:one.key, l:one.key) . "` - " .
       \ GrooVim_ShortcutPlain(l:one.what) . " *" .
       \ GrooVim_ShortcutModes(l:one.modes) . "*;")
      for l:note in get(l:one, "notes", [])
        call add(l:out, "        - Note: " . GrooVim_ShortcutPlain(l:note) . ";")
      endfor
    endfor
  endfor

  call add(l:out, "")
  return l:out
endfunc

" Note: The F group sections of the help, written out of the list above! By
" Questor
func! GrooVim_ShortcutsHelp() abort

  let l:out = []

  " Note: What is written here is what THIS GrooVim can do: a shortcut whose
  " plugin is not installed is not on the list, and neither is a group left
  " empty by that. The README is the other way round -- see the Markdown above,
  " which writes every one of them, because it describes the project and not
  " one machine! By Questor
  for l:group in GrooVim_ShortcutGroupsHere()
    call add(l:out, "")
    call add(l:out, "    <" . l:group[0] . "> and then...")
    call add(l:out, "      Note: " . l:group[1] . ";")

    for l:one in g:GrooVim_Shortcuts
      if l:one.group !=# l:group[0] || !GrooVim_ShortcutAvailable(l:one)
        continue
      endif
      call add(l:out, GrooVim_ShortcutKeyShown(l:one.key) . l:one.what .
       \ " " . GrooVim_ShortcutModes(l:one.modes) . ";")
      for l:note in get(l:one, "notes", [])
        call add(l:out, "            Note: " . l:note . ";")
      endfor
    endfor
  endfor

  return join(l:out, "\n")
endfunc

"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

let g:GrooVimHelp = "*=D=D=D=D=D=D=D=D_HELP_FOR_GrooVim_=D=D=D=D=D=D=D=D*".
\"\n|GrooVim|=D|" . g:grooVimVersion . "|-|Vi|IMproved\'n\'GrooVIed!|".
\"\n Last change: 2026 September 19".
\"\n Eduardo L\u00facio Amorim Costa~".
\"\n*=D=D=D=D=D=D=D=D_HELP_FOR_GrooVim_=D=D=D=D=D=D=D=D*".
\"\n".
\"\n                   {+}".
\"\n                  {+++}".
\"\n                 {+++++}".
\"\n                {+++++++}".
\"\n               {+++++++++}".
\"\n             {+++++++++++++}".
\"\n          {+++++++++++++++++++}".
\"\n{+++++++++++++++++++++++++++++++++++++++}".
\"\n  {++++++++++++++GrooVim++++++++++++++}".
\"\n    {+++++++++++++++++++++++++++++++}".
\"\n      {+++++++++++++++++++++++++++}".
\"\n         {+++++++++++++++++++++}".
\"\n           {+++++++++++++++++}".
\"\n          {+++++++++++++++++++}".
\"\n         {+++++++++++++++++++++}".
\"\n        {+++++++++++++++++++++++}".
\"\n       {++++++++}       {++++++++}".
\"\n      {+++++}               {+++++}".
\"\n     {++}                       {++}".
\"\n".
\"\n|BETA|VERSION!|".
\"\n".
\"\n * What is GrooVim?~".
\"\n".
\"\n The|GrooVim|is an extensive script -- a|.vimrc|and the parts it loads -- that modifies the behavior of Vim to facilitate your work and increase your productivity aim the following objectives:".
\"\n*o*  Allow use with just a few instructions by a public accustomed to editors/IDEs default;".
\"\n*o*  Facilitate and accelerate widely the use, being also a integrated \"UI\";".
\"\n*o*  Preserving always that possible the default behavior of Vim;".
\"\n*o*  Enhancing Vim project as a general purpose IDE;".
\"\n*o*  Approach Vim of \"standard\" text editors in what is convenient and positive and modify Vim in its negative aspects;".
\"\n*o*  Promote Vim as a better and faster alternative to market text editors and IDEs as well as a general-purpose editor;".
\"\n*o*  Enhancing Vim project as a free alternative (GNU General Public License v3.0 or later), independent and community-supported initiative;".
\"\n*o*  Encourage the use of shell Vim;".
\"\n*o*  Working on its own, with no plugin needed for anything it does. Plugins are welcome and each one is found by itself, but nothing GrooVim promises rests on one;".
\"\n*o*  Being a script for all types of terminals;".
\"\n".
\"\n * Before you start with the GrooVim!~".
\"\n".
\"\n--------".
\"\n *IMPORTANT_I!* If you do not know how Vim works, please open a terminal, run|vimtutor|and do the exercises (takes 25 to 30 minutes). Then continue reading this document! IT IS VERY IMPORTANT TO KNOW THE DEFAULT VIM IN ITS BASIC, SO YOU CAN USE IT BETTER AND CONTRIBUTE WITH NEW FEATURES!".
\"\n *IMPORTANT_II!* The Vim is a powerful general purpose text editor/IDE. Keep in mind that the GrooVim was made possible through its great API (script) and wide versatility!".
\"\n *IMPORTANT_III!* Certain terminal emulators limits the possibility of Vim and GrooVim. Therefore, we recommend that for your \"all day\" Vim use a terminal that allows more possibilities and features!".
\"\n--------".
\"\n".
\"\n*o*  The GrooVim was designed to work with a wide range of keyboard shortcuts. Eventually, such shortcuts may present conflicts with shortcuts from your OS. This is normal and if conflicts occur we recommend that you modify the shortcuts of your OS, because the terminal environment does not allow a large number of combinations to form shortcuts;".
\"\n*o*  To further facilitate your life and increase productivity we recommend you make a mapping in your terminal to navigate between tabs using <Shift-Left>/<Shift-Right>. These two keyboard shortcuts (<Shift-Left>/<Shift-Right>) are not mapped in GrooVim to that you use in the way mentioned;".
\"\n   |-|Note: KDE desktop environment already works in that way with its terminal;".
\"\n*o*  The GrooVim was designed to work with tabs;".
\"\n*o*  The GrooVim was designed to work without constant use of \'virtualedit\' (\"virtualedit set=all\") to facilitate cursor navigation \"despising invalid areas\" (or without character) when convenient;".
\"\n*o*  The GrooVim was designed to work with the best plugins;".
\"\n   |-|We recommend install ALL the following plugins:".
\"\n      |-|*NERDTree*".
\"\n         |[https://github.com/preservim/nerdtree]|".
\"\n      |-|*tcomment*".
\"\n         |[https://github.com/tomtom/tcomment_vim]|".
\"\n      |-|*move*".
\"\n         |[https://github.com/matze/vim-move]|".
\"\n*o*  No plugin manager is needed: Vim 8 and later load whatever is under|~/.groovim/pack/*/start| by themselves. *Pathogen* is recognized if you already use it, and GrooVim enables the mapping of each plugin it finds, so nothing missing causes an error;".
\"\n*o*  Each plugin is DETECTED and its mapping enabled by itself. Force any of them with|let|g:enable_tcomment_vim|=|0/1| , or ignore all at once with|let|g:enable_all_plugins|=|0| ;".
\"\n".
\"\n * The GrooVim solves the following \"problems\"!!~".
\"\n".
\"\n*o*  <Ctrl-Left>/<Ctrl-Right> (normal mode/insert/visual) - Navigate by words in a conventional and practical way;".
\"\n*o*  <Tab> (normal mode/visual)- Indent in a conventional and practical way;".
\"\n*o*  <Enter> (normal mode/visual) - Use in a conventional and practical way;".
\"\n*o*  <Backspace> (normal mode/visual) - Use in a conventional and practical way;".
\"\n*o*  <Del> (normal mode/visual) - Use in a conventional and practical way;".
\"\n*o*  <Space> (normal mode/visual) - Use in a conventional and practical way;".
\"\n*o*  In the alternation between modes the cursor stays correctly positioned;".
\"\n*o*  Use default clipboard in a correct and conventional way (copy, cut and paste);".
\"\n*o* |Replace|, <x> (remove) and <d> (delete) preserving the clipboard;".
\"\n*o*  <PageDown>/<PageUp> - With navigation across the screen (invalid areas);".
\"\n*o*  <MouseScrollDown>/<MouseScrollUp> - With navigation across the screen (invalid areas);".
\"\n*o*  <MouseClick> (normal mode) - Across the screen (invalid areas);".
\"\n*o*  Just a <Ctrl-w> switches between windows;".
\"\n*o*  Etc...".
\"\n".
\"\n * Editor features!~".
\"\n".
\"\n*o*  Switching between modes:".
\"\n   |-|<Shift-Up> (normal mode/insert/visual) - Enter or exit the insert mode;".
\"\n   |-|<Shift-Down> (normal mode/insert/visual) - Enter or exit the visual mode;".
\"\n".
\"\n*o*  Text selection:".
\"\n   |-|<Alt-End>/<Alt-Home> (normal mode/insert) - Select text on the line until the end/beginning from the current point;".
\"\n".
\"\n*o*  Conventional text editors commands:".
\"\n   |-|<Ctrl-c> (visual mode) - Copy to clipboard;".
\"\n   |-|<Ctrl-v> (normal mode/insert/visual) - Paste from clipboard;".
\"\n   |-|<Ctrl-x> (visual mode) - Cut to the clipboard;".
\"\n   |-|<Ctrl-u> (normal mode/insert/visual) - Undo;".
\"\n   |-|<Ctrl-r> (normal mode/insert/visual) - Redo;".
\"\n".
\"\n*o*  Plugins:".
\"\n   |-|move-vim;|".
\"\n        <Ctrl-j>/<Ctrl-k> (normal mode/insert/visual) - Move line or selection up/down;".
\"\n".
\"\n * Relevant changes in the default Vim behavior!~".
\"\n".
\"\n   |-|Use |Ctrl+b| to enable visual block mode;".
\"\n   |-|When changes from |visual|mode| to |insert|mode|the cursor do not move;".
\"\n   |-|Use the system clipboard when it can be reached, see |Clipboard|below;".
\"\n   |-|The \"insert\" and \"paste\" from the same cursor position;".
\"\n".
\"\n * Indentation!~".
\"\n".
\"\n The indent is|2|columns wide and made of SPACES, and the guides that draw the levels come from|listchars| , native to Vim.".
\"\n".
\"\n The width and whether <Tab> puts spaces are asked with F5->c and then |[i]| . It is the \"Tab Settings\" of Notepad++, and like every other screen it ends asking whether to keep what you chose for the next time.".
\"\n".
\"\n Whether the guides are DRAWN is asked one screen over, with F5->c and then |[v]| , beside whether a space shows a dot and a tab an arrow. A guide is something painted on the screen and not a rule about what <Tab> does, which is why Notepad++ keeps it in \"View, Show Symbol\" and not in its tab settings.".
\"\n".
\"\n That screen also sets the LANGUAGE, which is what Vim calls the |filetype| : what decides the colours, the indenting and the comment character. It is the Language menu of Notepad++, and |none| is its \"None (Normal Text)\". GrooVim keeps NO list of its own -- <Tab> completes among the hundreds this Vim ships, which is the only list that can ever be right.".
\"\n".
\"\n It is asked THERE and not with the encoding because nothing about it is ever written to the disk: the encoding and what ends a line change the bytes in the file, and a language changes how the same bytes are READ. Which is also why choosing one leaves a clean buffer clean.".
\"\n".
\"\n On that screen it comes BELOW the question that keeps, and that is the answer to \"is my language kept too?\": it is not. It belongs to the buffer you are on, and keeping |python| for the next time you open GrooVim would put every file you open into python. The question that keeps closes the block it belongs to, and what follows it is not in that block.".
\"\n".
\"\n *THE FILE YOU HAVE OPEN*".
\"\n".
\"\n The encoding and what ends a line belong to the DOCUMENT, not to the editor, and they are asked with F5->c and then |[f]| . It is the Encoding menu and the \"EOL Conversion\" of Notepad++, in one screen:".
\"\n".
\"\n*o*  The encoding and what to do with it, in ONE answer of two letters. The encoding is |[a]nsi| , |[u]tf-8| , utf-8 with |[b]om| , utf-16 |[l]e| or utf-16 b|[e]| ; what to do with it is |[r]| , which reads the file AGAIN with that encoding -- the bytes do not move and their meaning changes, which is the top of that menu -- or |[c]| , which converts the file, its \"Convert to\": the text does not move and the bytes do. So |uc| is \"utf-8, by converting\";".
\"\n*o*  What ends a line: |[u]nix| LF, |[w]indows| CRLF, |[m]acintosh| CR;".
\"\n*o*  A |>| marks where a SECTION begins, and nothing else: a block of three lines carries it once, on its first, and a question that is a block on its own carries it too. What only explains may be as long as it likes, because it is a message -- a QUESTION wider than your terminal wraps, and Vim answers a wrapped prompt with a hit-enter that eats the key you meant for it;".
\"\n*o*  An EMPTY answer means \"leave THIS one alone\" and not \"leave the screen\": give it to the encoding and the line ending is still asked, give it to both and nothing happens at all. It is the default of both questions, so pressing <Enter> through the screen leaves the file as it found it, and what was done and what was not is on the bar afterwards;".
\"\n".
\"\n Reading again throws away what you have not written yet, so it is refused while there is something to lose. Converting marks the buffer as changed on purpose: Vim writes the new encoding at the next write and not before, and a buffer that claimed to have nothing to write would leave the setting looking applied with the file untouched.".
\"\n".
\"\n What the file is on right now is on the bar at the bottom, beside the encoding: |[utf-8,unix]| , with a |,B| when there is a BOM.".
\"\n".
\"\n".
\"\n A width is THREE Vim options at once -|tabstop| ,|shiftwidth| and|softtabstop| , and they only mean what you expect while they agree. To change the width of the buffer you are on, use the command that moves the three together: >".
\"\n     GrooVimIndent 4".
\"\n< Without an argument it tells you the width in force. Setting|shiftwidth| by hand instead leaves the editor half changed: the guides follow the new width and the Tab key keeps the old one.".
\"\n".
\"\n*o*  |g:GrooVim_IndentWidth| - the general width;".
\"\n*o*  |g:GrooVim_IndentWidthPerType| - the width per file type, the same idea of the \"Tab Settings\" per language of Notepad++. One line is enough: >".
\"\n     let g:GrooVim_IndentWidthPerType = {\"python\": 4, \"javascript\": 2}".
\"\n<".
\"\n*o*  |g:GrooVim_IndentGuideChar| - the char of the guide, or \"\" to turn the guides off. F5->c and then |[v]| turns them off and on, and hands back the char you chose;".
\"\n*o*  |g:GrooVim_IndentExpandTab| - 1 for spaces, 0 for a real tab;".
\"\n*o*  |g:GrooVim_ShowSpaceAndTab| - 1 draws a dot on every space and an arrow on every tab, which is \"Show Space and Tab\" of Notepad++. ON by default, which is where GrooVim parts from it: a space and a tab look the same and are not;".
\"\n*o*  |g:GrooVim_EdgeColumn| - the column the vertical line is drawn on, |79| by default, or 0 for no line. It is the \"Vertical Edge\" of Notepad++, and it is drawn on EVERY row -- a short line gets it too;".
\"\n*o*  |g:GrooVim_WordWrap| - 1 wraps a long line onto the next row instead of running it off the screen, which is \"Word wrap\" of Notepad++. OFF by default, asked on F5->c and then |[v]|, and it breaks at a SPACE and not in the middle of a word;".
\"\n".
\"\n Only the file types you list are touched. Vim already ships file type plugins that know what they are doing, and some of them are not a matter of taste: *make* needs a REAL tab on its recipe lines and *go* is written with tabs by gofmt. Those are left alone.".
\"\n".
\"\n The guides read the width from the standard Vim options when drawing, so they follow a|modeline| , a file type plugin or a|:set|shiftwidth=| you type.".
\"\n".
\"\n * Clipboard (the \"transfer area\")!~".
\"\n".
\"\n GrooVim reaches the clipboard through a CASCADE, and it requires nothing to be installed. It uses the first of these that answers:".
\"\n".
\"\n*o*  |1.| The native clipboard, when your Vim was built with a working |+clipboard| ;".
\"\n*o*  |2.| A clipboard TOOL (*wl-copy* / *wl-paste* , *xclip* or *xsel* ), used only if one is already there;".
\"\n*o*  |3.| *OSC*52* , an escape sequence that carries the clipboard THROUGH the terminal. It needs no X11, no Wayland and no desktop, and it crosses SSH, so a copy made on a remote server lands on the clipboard of the machine you are sitting at. Vim ships this one, there is nothing to install;".
\"\n*o*  |4.| A file in|~/.groovim/clipboard| , which always works and also lets two Vim instances share a copy;".
\"\n".
\"\n To see which one is in use:|:echo|v:clipmethod| and|:echo|GrooVim_ClipReg()| .".
\"\n".
\"\n *PASTING*FROM*ANOTHER*APPLICATION!* This is the one case that needs help. OSC 52 carries a copy OUT, but reading the clipboard BACK would require the terminal to ANSWER a query, and almost no terminal does that on purpose (a program running over SSH could steal your clipboard). So:".
\"\n".
\"\n*o*  With NO tool installed, <Ctrl-v> pastes what Vim itself copied. To bring in what another application copied, use your terminal own paste, usually <Ctrl-Shift-v> ;".
\"\n*o*  With a tool installed, <Ctrl-v> reaches the system clipboard too, and nothing has to be changed in your|.vimrc|:".
\"\n      |-|Wayland:|sudo|pacman|-S|wl-clipboard| or|sudo|apt|install|wl-clipboard| ;".
\"\n      |-|X11:|sudo|pacman|-S|xclip| or|sudo|apt|install|xclip| ;".
\"\n".
\"\n GrooVim looks for the tool inside|~/.groovim/bin| first (see|g:GrooVim_ClipBinDir| ) and then in your|$PATH| . That first directory is there so you can drop a tool BY HAND on a machine where you cannot use the package manager.".
\"\n".
\"\n *NO*BINARY*IS*SHIPPED*WITH*GrooVim,*ON*PURPOSE!* A Linux executable is not portable: it is built for one architecture, it is linked against one libc, and|wl-copy|also needs libwayland-client at run time. And on a headless server there is no compositor for it to talk to anyway, which is exactly the case OSC 52 already covers by itself.".
\"\n".
\"\n Knobs:|g:GrooVim_EnableClipTool| ,|g:GrooVim_ClipTools| ,|g:GrooVim_ClipBinDir| .".
\"\n".
\"\n * Script features!~".
\"\n".
\"\n*o*  Navigation".
\"\n".
\"\n   |-|<Shift-Alt-Arrows> (normal mode/insert/visual) - Smooth navigation across the screen with long movements (invalid areas);".
\"\n   |-|<Ctrl-Alt-Arrows> (normal mode/insert/visual) - Navigation with arrows across the screen (invalid areas) using shorts movements;".
\"\n   |-|<Alt-Down> (normal mode/insert/visual) - Returns to the previous tab;".
\"\n".
\"\n*o*  Word selection".
\"\n".
\"\n   |-|<Alt-Right>/<Alt-Left> (normal mode/insert/visual) - Word selection to the right/left;".
\"\n".
\"\n*o*  Tabs".
\"\n".
\"\n   |-|<Ctrl-Up>/<Ctrl-Down> (normal mode/insert/visual) - Go to the next/previous tab;".
\"\n   |-|<Ctrl-Shift-Up>/<Ctrl-Shift-Down> (normal mode/insert/visual) - Carry the current tab to the next/previous place in the tab line. At either end it stays put;".
\"\n".
\"\n*o*  Comment lines".
\"\n".
\"\n   |-|<Alt-Up> (normal mode/insert/visual) - Comment lines using *tcomment.vim* ;".
\"\n   |-||m| and |M| (normal mode) - Walk to the next marked line and to the one before. They take the |m| that sets a mark of Vim and the |M| that jumps to the middle of the screen: the bookmarks replace what marks were FOR, and|:mark|a|still writes one from the command line;".
\"\n".
\"\n * F\'S Shortcuts (CommandZ)!~".
\"\n".
\"\n  The |CommandZ| is a kind of \"super leader\" that allows an extensive keys combination to create keyboard shortcuts for features in Vim. Works pressing <F2>, <F3>, <F4> or <F5> keys and then another key.".
\"\n".
\"\n  You do not have to remember any of them: <F10> puts a BAR across the top with the four groups on it, and under the one you are on, what it holds. |<Left>| and |<Right>| walk the bar, |<Up>| and |<Down>| the list, <Enter> picks and <Esc> leaves -- and pressing the <F> key of a section jumps straight to it, which is the same key that runs its shortcuts.".
\"\n  The mouse works everywhere: a click on the bar opens a section, a click on a line runs it, a click outside leaves.".
\"\n  Every line shows the keys that do it, on the right. Choosing one PRESSES those keys, so the menu can never do anything the keyboard would not. The menu and the list below are written from the same place.".
\"\n".
\"\n  When one of them does not fire, |:GrooVimKey| says what the key really delivered: run it, press the key, and it prints what |getchar()| handed over. Two keys that look the same can arrive as different keys, and the second one of a shortcut has |400ms| to arrive -- see |g:GrooVim_CommandZWait| below.".
\"\n".
\"\n*o*  Features".
\"\n ".
\"\n |-|Every |F| key remembers the last command IT ran, and runs it again when you press it with no key after it. |F2| repeats what |F2| did and |F3| what |F3| did -- one memory each, so a command of another group can never come out of this one;".
\"\n |-|Pressing the same |F| key TWICE repeats at once, without waiting for a second key that is not coming. And if you hold it down the command is replicated several times;".
\"\n |-|You have |400ms| to press the second key, and it is the same |400ms| after which the |F| key repeats: the moment the window closes is the moment it repeats, there is no second wait. Raise it with|let|g:GrooVim_CommandZWait|=|1000|if a second key of yours arrives too late -- an |F| key at one corner of the keyboard and an arrow at the other is a long trip, and a key that misses the window runs the REPETITION instead;".
\"\n".
\ GrooVim_ShortcutsHelp() .
\"\n".
\"\n * What is missing, and what is being worked on~".
\"\n".
\"\n The list lives in the|README.md|of the project, beside the code. It moves too often to be worth keeping in two places, and a list of bugs that is out of date is worse than none.".
\"\n".
\"\n*=D=D=D=D=D=D=D=D_HELP_FOR_GrooVim_=D=D=D=D=D=D=D=D*".
\"\n"

" Note: To test the help use: "set wrap | set linebreak | set nolist | set textwidth=0 | set wrapḿargin=0 | set formatoptions+=l | set syntax=help"! By Questor

"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" =D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D

" Note: The options you chose to KEEP are read in the ".vimrc", BEFORE any part
" of GrooVim -- see "GrooVim_OptsFile" there. They used to be read here, at the
" very end, and that only worked for the ones consulted while you type! By
" Questor
