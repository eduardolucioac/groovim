" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
" HELP
" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" The help of F9 and the About of the "?" section, and the ONE list they are
" written from: every shortcut of GrooVim, its keys, the modes it works in and
" what it does. The menu of F10 and the README are written from that same list,
" so a shortcut is described once and never twice.
"
" The text of the help itself comes LAST in the file, after everything that
" reads the list: it is the biggest thing GrooVim carries, and nothing in here
" waits on it.

" $$$$$$$$$$$$$$$$$$$$$$$

" Note: The sections of the menu of F10, which are what GrooVim DOES and not the
" four F keys -- the map of the editor, which is what the menu bar of Notepad++
" is. So the keys a conventional editor is pressed with, Ctrl+C, the arrows with
" their modifiers, "n" and "m", are on it too.
"
" A section does not say which F key it belongs to: it holds keys of every
" shape, and which F key goes with what is deducible from the lines under it --
" they carry the keys that do them, and nearly every line of "Edit" carries an
" F2.
"
" Written "an F2" and not with the arrow after it: a case of the battery reads
" every shortcut named anywhere in the source and refuses one that is not on the
" list -- and a sentence ABOUT the notation would be read as one more use of it.
let g:GrooVim_MenuSections = [
 \ ["File", "The file itself: saving it, opening another, leaving"],
 \ ["Edit", "Changing the text: the transfer area, undo, the indent, the case"],
 \ ["Select", "Taking hold of text: all of it, a block, a word, an area"],
 \ ["Search", "Finding and replacing, and the marks a search leaves"],
 \ ["Move", "Walking the text: the smooth movement, the pages, the brackets"],
 \ ["View", "What is beside the text: the tree, the marked lines, the tabs, the help"],
 \ ["Settings", "What GrooVim is: every setting, and reading it again"],
 \ ["?", "The help of GrooVim, the help of Vim, and what this is"]
 \ ]

" Note: Every shortcut of the F groups, in ONE place.
"
" The help of "F9" is WRITTEN from this list, and so is the menu. It used to be
" two hundred lines of prose kept by hand beside the block of code that answers
" the keys, and the two drifted every time anything moved: keys that changed
" group and were still listed under the old one, a whole "<F5>" block that did
" not exist at all, messages sending you to letters that had been retired. One
" list, and the drift has nowhere left to happen.
"
" "modes" is where the key answers -- "n" normal, "i" insert, "v" visual. It is
" not decoration: the case that checks this list against the code reads it, and
" writing it wrong is a failure.
let g:GrooVim_Shortcuts = [
 \
"\ ---- File
 \ {"where": "File", "group": "F2", "key": "p", "break": 1, "modes": "niv", "run": 'call GrooVim_Operation("[file name]", "GrooVim_GetFileNameAndPath", [])', "menu": "Copy file name or path", "what": "Copies to the clipboard the name or path and name of the current buffer/file"},
 \ {"where": "File", "group": "F2", "key": " ", "modes": "niv", "run": 'call GrooVim_PathTip(l:mode)',
 \  "menu": "Where this file is",
 \  "what": "Says the WHOLE path of the file you are on, in a balloon",
 \  "notes": [
 \   "The bar at the bottom shows as much of the path as can be read and this says all of it. The balloon goes down on the cursor moving or on |<Esc>| , and nothing it covers is lost -- you go on typing with it up",
 \   "It stands in the MIDDLE of the screen, in every mode: where the file IS has nothing to do with the line you are on, and over that line it would be in the way of the text",
 \   "From VISUAL mode what you had selected is still selected afterwards"
 \  ]},
 \ {"where": "File", "group": "F2", "key": "y", "modes": "niv", "run": 'call GrooVim_Operation("[save a copy]", "GrooVim_SaveACopy", [])',
 \  "menu": "Save a copy as...", "what": "Writes a copy of this file to disk",
 \  "notes": [
 \   "And leaves you where you were: a copy is made to HAVE it, and what you are editing is what you were editing. |F5->a| is the other one -- it saves under another name and goes on editing THAT one"
 \  ]},
 \ {"where": "File", "group": "F5", "key": "s", "modes": "niv", "keepsel": 1, "run": 'call GrooVim_Save()',
 \  "menu": "Save", "what": "Save to disk",
 \  "notes": [
 \   "A document with no name yet is asked where to go, the way |F5->a| asks"
 \  ]},
 \ {"where": "File", "group": "F5", "key": "e", "modes": "niv", "run": ':wa', "menu": "Save all", "what": "Save every changed file"},
 \ {"where": "File", "group": "F5", "key": "a", "modes": "niv", "run": 'call GrooVim_Operation("[save as]", "GrooVim_SaveAs", [])',
 \  "menu": "Save as...", "what": "Saves under another name and goes on editing THAT one",
 \  "notes": [
 \   "Beside |F5->s| , which saves, and |F5->e| , which saves every changed file. The COPY is |F2->y| : that one writes the file and leaves you where you were",
 \   "One question, and the name of the file you are on comes written in it: a NAME lands in the folder you are in, which the question names, and a name with a PATH in front of it lands where the path says. <Tab> completes paths",
 \   "A file that is already there is asked about before it is written over, and a no asks for the name again"
 \  ]},
 \ {"where": "File", "group": "F5", "key": "p", "break": 1, "modes": "niv", "run": 'call GrooVim_Operation("[open]", "GrooVim_FileOpen", [])',
 \  "menu": "Open...", "what": "Opens a file by name, in a tab of its own",
 \  "notes": [
 \   "The same question |F5->a| asks: a NAME lands in the folder you are in, which the question names, and a name with a PATH in front of it lands where the path says. <Tab> completes paths",
 \   "A file that is NOT there is asked about instead of being opened -- Vim opens a document under any name you type and says nothing, so a path with one letter wrong came up as an empty tab wearing the name of the file you meant. Yes starts it anyway",
 \   "The tab is born at the END of the line, and a file already open is not opened twice: you land on the tab that has it",
 \   "And on the empty |new|1| GrooVim opens with -- one tab, no name, nothing typed in it -- the file opens IN it instead of in a second tab beside a page nobody wrote in. It is what Notepad++ (inspiration) does, and what the tree, a file DROPPED on the window and a file handed over with |--jrinst| do here"
 \  ]},
 \ {"where": "File", "group": "F5", "key": "n", "modes": "niv", "run": 'call GrooVim_TabNew()',
 \  "menu": "New tab", "what": "Open a new tab",
 \  "notes": [
 \   "A document you have not saved yet is called |new|1| , |new|2| ... It is a name on SCREEN only -- the buffer stays nameless, so saving it asks you where to put it instead of writing a file called \"new 1\" wherever you happen to be",
 \   "The new tab goes to the END of the tab line, and the number is the LOWEST one nobody is using: close |new|2| of |new|1|,|new|2|,|new|3| and the next one is |new|2| again"
 \  ]},
 \ {"where": "File", "group": "F5", "key": "q", "break": 1, "modes": "niv", "run": 'call GrooVim_CloseAsking("q")', "menu": "Close window", "what": "Close the window"},
 \ {"where": "File", "group": "F5", "key": "w", "modes": "niv", "run": 'call GrooVim_TabClose()',
 \  "menu": "Close", "what": "Close the tab you are in",
 \  "notes": [
 \   "On the LAST tab Vim refuses to close it, so what closes is the document, leaving an empty |new|1| behind",
 \   "Changes you would lose are asked about, by every way of closing: |Save|\"teste.txt\"| , yes or no, and |<Esc>| closes nothing. A document never saved is asked WHERE to put it next, the way |F5->a| asks"
 \  ]},
 \ {"where": "File", "group": "F5", "key": "o", "modes": "niv", "run": 'call GrooVim_CloseAsking("tabonly")', "menu": "Close all but this one", "what": "Close all other tabs"},
 \ {"where": "File", "group": "F5", "key": ".", "modes": "niv", "run": 'call GrooVim_TabCloseSide(1)', "menu": "Close all to the right", "what": "Close every tab to the RIGHT of this one"},
 \ {"where": "File", "group": "F5", "key": ",", "modes": "niv", "run": 'call GrooVim_TabCloseSide(-1)',
 \  "menu": "Close all to the left", "what": "Close every tab to the LEFT of this one",
 \  "notes": [
 \   "The keys of |<<>| and |<>>| without the Shift: the comma is to the left of the dot, which is the way each one closes"
 \  ]},
 \ {"where": "File", "group": "F5", "key": "x", "modes": "niv", "run": 'call GrooVim_CloseAsking("qa")',
 \  "menu": "Exit", "what": "Close everything and leave",
 \  "notes": [
 \   "Closing the WHOLE editor does not ask: what you have not saved is COPIED and comes back on the next start, the way the |x| of the window of Notepad++ answers. The document comes back marked as not saved -- the |+| on the bar and in the tab line -- and the file on disk is not touched",
 \   "Closing a TAB is another thing and goes on asking -- save, throw away, or go back -- because there you are throwing one document away on purpose",
 \   "And you come back to the TAB you were on, whichever one it was: the index says which document was in front, and the session carries the tabs",
 \   "The copies live in|~/.groovim/unsaved| and are written on a clock as well as on the way out, which is what answers a CRASH -- the session is written on that same clock, so the tabs come back from a crash too. Measured with the editor killed outright: the text, the tabs and the one in front, all back. Turn the whole thing off with |let|g:GrooVim_UnsavedAuto|=|0|"
 \  ]},
 \ {"where": "File", "group": "F5", "key": "[", "break": 1, "modes": "niv", "run": 'call GrooVim_SessionSaveByHand()', "menu": "Save session", "what": "Saves the current session"},
 \ {"where": "File", "group": "F5", "key": "]", "modes": "niv", "run": 'call GrooVim_SessionLoadByHand()',
 \  "menu": "Load session", "what": "Brings the last saved session back",
 \  "notes": [
 \   "The session saves itself when you leave -- and every few seconds while you work, which is what makes the tabs survive a crash. It comes back when you open GrooVim with NO file. While that is on, |<[>| and |<]>| say so instead of pretending to work. Turn it off with F5->c"
 \  ]},
 \
"\ ---- Edit
 \ {"where": "Edit", "group": "F2", "key": "o", "break": 1, "modes": "niv",
 \  "run": {"v": 'call GrooVim_SortLines()',
 \          "ni": 'call GrooVim_GrooVimBarMsg("Select the lines you want in order first!", 5)'},
 \  "menu": "Put the lines in order",
 \  "what": "Sorts the lines you have selected",
 \  "notes": [
 \   "Asked on F5->c and then |[t]| : case |[s]|ensitive or |[i]|nsensitive, |[a]|scending or |[d]|escending, and whether only the UNIQUE lines come out -- which they do unless you say otherwise",
 \   "By a FIELD and not by the whole line: select a BLOCK with F2->b over the column the field begins at, then press this. Ordering |xx-3| , |yy-1| , |zz-2| from the fourth column gives |yy-1| , |zz-2| , |xx-3|",
 \   "The RESULT comes back selected, with the cursor on the end of its last line, ready for one more thing to be done to the whole of it"
 \  ]},
 \ {"where": "Edit", "group": "F2", "key": "h", "modes": "niv", "keepsel": 1, "run": ':left', "menu": "Align left", "what": "Aligns to left"},
 \ {"where": "Edit", "group": "F2", "key": "k", "modes": "niv", "keepsel": 1, "run": ':right', "menu": "Align right", "what": "Aligns to right"},
 \ {"where": "Edit", "group": "F2", "key": "j", "modes": "niv", "keepsel": 1, "run": ':center', "menu": "Align centre", "what": "Aligns to center"},
 \ {"where": "Edit", "group": "F2", "key": "up", "break": 1, "modes": "niv", "keepsel": 1, "run": {"ni": 'call GrooVim_CaseOfTheWord("U")', "v": 'call GrooVim_ToUpperLower("Upper")'}, "menu": "UPPERCASE", "what": "Changes to uppercase"},
 \ {"where": "Edit", "group": "F2", "key": "down", "modes": "niv", "keepsel": 1, "run": {"ni": 'call GrooVim_CaseOfTheWord("u")', "v": 'call GrooVim_ToUpperLower("Lower")'}, "menu": "lowercase", "what": "Changes to lowercase"},
 \ {"where": "Edit", "group": "F2", "key": "t", "modes": "niv", "keepsel": 1, "run": 'call GrooVim_ToTitleCase(l:mode)',
 \  "menu": "Title Case", "what": "Title Case: the first letter of every word up, the rest down",
 \  "notes": [
 \   "In normal and insert mode it is the word under the cursor; in visual mode, every word of the selection and nothing outside it. An apostrophe ENDS a word, so \"don't\" becomes \"Don'T\"",
 \   "The three of them leave the cursor where it was"
 \  ]},
 \ {"where": "Edit", "group": "F2", "key": "c", "break": 1, "modes": "niv", "run": 'call GrooVim_ClipSet(join(getline(1, "$"), "\n"))', "menu": "Copy the whole file", "what": "Copy all text in the current buffer"},
 \ {"where": "Edit", "group": "F2", "key": "q", "break": 1, "modes": "niv", "run": 'call GrooVim_XenRec()',
 \  "menu": "Record macro (start/stop)", "what": "Start and stop recording a macro",
 \  "notes": [
 \   "The same F2->q does both: the first press starts the recording and says so, the second ends it. It used to take a key of its own",
 \   "What is recorded goes into the register |a| , and F2->w runs it. The F2->q that ends the recording is cut off the register, so playing it back does not start another one"
 \  ]},
 \ {"where": "Edit", "group": "F2", "key": "w", "modes": "niv", "run": 'call GrooVim_Operation("[macro]", "GrooVim_XenPlay", [0])', "menu": "Play macro", "what": "Run a macro"},
 \ {"where": "Edit", "group": "F2", "key": "e", "modes": "niv", "run": 'call GrooVim_Operation("[macro]", "GrooVim_XenPlay", [1])', "menu": "Play macro many times...", "what": "Run a macro certain number of times or repeatedly until the last line"},
 \ {"where": "Edit", "group": "F3", "key": "l", "break": 1, "modes": "niv", "run": 'call GrooVim_SuppressLine(l:mode)',
 \  "menu": "Delete line", "what": "Takes the line away, without touching the transfer area"},
 \ {"where": "Edit", "group": "F3", "key": "d", "modes": "niv", "run": {"n": 'call GrooVim_DuplicateLine()', "i": 'call GrooVim_DuplicateLine()', "v": 'call GrooVim_DuplicateSelection()'},
 \  "menu": "Duplicate line", "what": "Duplicates the current line/selection",
 \  "notes": [
 \   "If in the visual mode can not be replicated"
 \  ]},
 \
 \ {"where": "Edit", "keys": "<C-c>", "break": 1, "modes": "v",
 \  "menu": "Copy", "what": "Copies what is selected, and leaves the cursor where it was"},
 \ {"where": "Edit", "keys": "<C-x>", "modes": "v",
 \  "menu": "Cut", "what": "Cuts what is selected"},
 \ {"where": "Edit", "keys": "<C-v>", "modes": "niv",
 \  "menu": "Paste", "what": "Pastes what is in the transfer area"},
 \ {"where": "Edit", "keys": "<C-u>", "break": 1, "modes": "niv",
 \  "menu": "Undo", "what": "Undoes the last change"},
 \ {"where": "Edit", "keys": "<C-r>", "modes": "niv",
 \  "menu": "Redo", "what": "Does again what was undone"},
 \ {"where": "Edit", "group": "F2", "key": "n", "break": 1, "modes": "ni",
 \  "run": 'call GrooVim_MultiColumnStart()',
 \  "menu": "Write on several lines",
 \  "what": "Writes on several lines at once: it goes straight into insert, and the arrows take in the lines above and below",
 \  "notes": [
 \   "The line you started on is the anchor and does not move: |Down| and |Up| move the OTHER end, so three down and one up leaves two lines taken",
 \   "Everything else happens in every caret, each one where IT is: what you type, the |Enter| that cuts its own line, the |Tab| that fills to the next stop of its own column, the |Del| , the |Backspace| -- and |End| , which is the end of each line, on lines of any length",
 \   "A line too short to reach the column takes the text at ITS end, so no line is left out",
 \   "|Esc| ends it"
 \  ]},
 \ {"where": "Edit", "group": "F2", "key": "m", "modes": "ni",
 \  "run": 'call GrooVim_MultiPoint()',
 \  "menu": "Write in several places",
 \  "what": "Marks one more place to write in, and opens for writing at once: walk to the next place and press it again, or just type",
 \  "notes": [
 \   "Beside |F2->n| , which takes whole lines. This one is for places that have nothing to do with each other",
 \   "While you are still CHOOSING nothing is written and the carets are ORANGE, the colour of typing: the plain arrows walk you to the next place and leave them where they are",
 \   "|Esc| sets the places and turns them YELLOW: from there everything you do happens in all of them -- what you type, the |Enter| , the |Del| , the |Tab| , the |Backspace| -- and everything that moves moves EVERY caret, each one from where IT is",
 \   "|Esc| again ends it. One key for both, because it is the same thing said twice: done choosing, then done writing"
 \  ]},
 \ {"where": "Edit", "keys": "<S-Up>", "break": 1, "modes": "niv",
 \  "menu": "Insert mode, in and out",
 \  "what": "Goes into insert and comes out of it: from normal or from a selection it starts typing, and from insert it stops",
 \  "notes": [
 \   "The pair of |Shift+Down| : one walks towards typing, the other towards selecting, and either walks back"
 \  ]},
 \ {"where": "Edit", "keys": "<S-Down>", "modes": "niv",
 \  "menu": "Selection mode, in and out",
 \  "what": "Goes into the selection and comes out of it: from normal or from insert it starts selecting, and from a selection it stops"},
 \ {"where": "Edit", "keys": "<A-Up>", "break": 1, "modes": "niv",
 \  "menu": "Comment/uncomment", "what": "Comments the line, or the selection, and uncomments it",
 \  "needs": {"switch": "enable_tcomment_vim", "name": "the tcomment plugin"}},
 \ {"where": "Edit", "keys": "<C-k>", "break": 1, "modes": "niv",
 \  "menu": "Move a line or selection up",
 \  "what": "Moves a line up, or every line of the selection",
 \  "needs": {"switch": "enable_move_vim", "name": "the vim-move plugin"}},
 \ {"where": "Edit", "keys": "<C-j>", "modes": "niv",
 \  "menu": "Move a line or selection down",
 \  "what": "Moves a line down, or every line of the selection",
 \  "needs": {"switch": "enable_move_vim", "name": "the vim-move plugin"}},
 \
"\ ---- Select
 \ {"where": "Select", "group": "F2", "key": "b", "modes": "niv", "run": 'call GrooVim_SetVisualBlock() | exec "normal! \<C-v>"',
 \  "menu": "Column (block) select", "what": "Selects a BLOCK: a rectangle of the text, corner to corner"},
 \ {"where": "Select", "group": "F3", "key": "a", "modes": "niv", "run": 'exec "norm ggVG$"', "menu": "Select all", "what": "Select all text in the current buffer"},
 \
 \ {"where": "Select", "keys": "<A-Left>", "break": 1, "modes": "niv",
 \  "menu": "Select word left", "what": "Selects the word to the left"},
 \ {"where": "Select", "keys": "<A-Right>", "modes": "niv",
 \  "menu": "Select word right", "what": "Selects the word to the right"},
 \ {"where": "Select", "keys": "<A-Home>", "modes": "ni",
 \  "menu": "Select to start of line", "what": "Selects back to the start of the line"},
 \ {"where": "Select", "keys": "<A-End>", "modes": "ni",
 \  "menu": "Select to end of line", "what": "Selects on to the end of the line"},
 \
"\ ---- Search
 \ {"where": "Search", "group": "F3", "key": "/", "break": 1, "modes": "niv", "keepsel": 1, "run": {"nv": 'call feedkeys("\\z/")', "i": 'call feedkeys("\<Esc>\\z/i")'},
 \  "menu": "Clear highlights", "what": "Takes every highlight off the text",
 \  "notes": [
 \   "The search highlight AND the marks of |F3->m| : taking the highlighting off is one idea to a reader and not two, and having to remember which key clears which half would be a poor way of saying so"
 \  ]},
 \ {"where": "Search", "group": "F3", "key": "m", "modes": "niv", "run": 'call GrooVim_MarkWord()',
 \  "menu": "Mark all occurrences", "what": "Mark every occurrence of the word under the cursor",
 \  "notes": [
 \   "It is the WORD the cursor is ON, and a selection changes nothing. A cursor over a space marks nothing: the word NEXT to it is not the word it is on. Pressing it again on the same word takes the marks down, and so does |</>|",
 \   "It does not move the cursor and does not touch what <n> would find next: you can mark a name and go on searching for something else"
 \  ]},
 \ {"where": "Search", "group": "F3", "key": "f", "modes": "niv", "run": {"ni": 'call GrooVim_Operation("[search]", "GrooVim_SearchWithMyOptions", ["n"])', "v": 'call GrooVim_Operation("[search]", "GrooVim_SearchWithMyOptions", ["v"])'},
 \  "menu": "Find...", "what": "Opens for search",
 \  "notes": [
 \   "The word under the cursor, or what is selected, comes OFFERED: an empty answer takes the offer",
 \   "Without the list it GOES to the first match and |n| walks from there; what is not there is said on the bar. With the list it is the list that you walk, so the cursor stays where it was",
 \   "The search BEFORE this one stops being painted the moment this opens -- Vim keeps the last pattern between sessions, so a word searched for yesterday was lit up before you typed a letter"
 \  ]},
 \ {"where": "Search", "group": "F3", "key": "h", "modes": "niv", "run": {"ni": 'call GrooVim_Operation("[replace]", "GrooVim_EntertainmentReplace", ["n"])', "v": 'call GrooVim_Operation("[replace]", "GrooVim_EntertainmentReplace", ["v"])'},
 \  "menu": "Replace...", "what": "Opens to replace",
 \  "notes": [
 \   "The replace begins at the CURSOR. WITH confirmation, having reached the end of the file it continues from the top if occurrences were left behind, and says so. Without confirmation it does only what it says, from the cursor down. Configure it with F5->c and then |[r]|"
 \  ]},
 \
 \ {"where": "Search", "keys": "n", "break": 1, "modes": "n",
 \  "menu": "Find next", "what": "Goes to the next of what was searched for"},
 \ {"where": "Search", "keys": "N", "modes": "n",
 \  "menu": "Find previous", "what": "Goes to the one before it"},
 \
"\ ---- Move
 \ {"where": "Move", "keys": "<A-S-Up>", "modes": "niv",
 \  "menu": "Smooth move up", "what": "Walks up, smoothly, and takes the selection along"},
 \ {"where": "Move", "keys": "<A-S-Down>", "modes": "niv",
 \  "menu": "Smooth move down", "what": "Walks down the same way"},
 \ {"where": "Move", "keys": "<A-S-Left>", "modes": "niv",
 \  "menu": "Smooth move left", "what": "Walks left the same way"},
 \ {"where": "Move", "keys": "<A-S-Right>", "modes": "niv",
 \  "menu": "Smooth move right", "what": "Walks right the same way"},
 \ {"where": "Move", "keys": "<C-A-Up>", "break": 1, "modes": "niv",
 \  "menu": "Step up, over gaps", "what": "One step up, over areas with no text"},
 \ {"where": "Move", "keys": "<C-A-Down>", "modes": "niv",
 \  "menu": "Step down, over gaps", "what": "One step down, the same"},
 \ {"where": "Move", "keys": "<C-A-Left>", "modes": "niv",
 \  "menu": "Step left, over gaps", "what": "One step left, the same"},
 \ {"where": "Move", "keys": "<C-A-Right>", "modes": "niv",
 \  "menu": "Step right, over gaps", "what": "One step right, the same"},
 \ {"where": "Move", "keys": "<C-Left>", "break": 1, "modes": "niv",
 \  "menu": "Word left", "what": "A word back"},
 \ {"where": "Move", "keys": "<C-Right>", "modes": "niv",
 \  "menu": "Word right", "what": "A word forward"},
 \ {"where": "Move", "keys": "<C-b>", "break": 1, "modes": "niv",
 \  "menu": "Go to matching bracket", "what": "From one bracket to the one that closes it, and back"},
 \ {"where": "Move", "keys": "<A-i>", "press": "<F18>", "break": 1, "modes": "niv",
 \  "menu": "Back to where you came from",
 \  "what": "To the place you were before the jump, and the one before that",
 \  "notes": [
 \   "A JUMP and not a step: what a search, a |G| , an occurrence of the list or opening another file left behind. Walking with the arrows leaves nothing to come back to, which is what you want -- it is the |jumplist| of Vim",
 \   "It is kept per WINDOW, so each window remembers its own way back"
 \  ]},
 \ {"where": "Move", "keys": "<A-o>", "press": "<F19>", "modes": "niv",
 \  "menu": "Forward again",
 \  "what": "Undoes the going back, up to where you first pressed it"},
 \
"\ ---- View
 \ {"where": "View", "group": "F4", "key": "n", "modes": "niv", "run": 'call GrooVim_ToggleNERDTreeTabs()',
 \  "notes": [
 \   "Asked for once, the tree is in EVERY tab, including the ones opened afterwards: it is a dock, like the search list and the list of marked lines. Pressing it again takes it from every tab",
 \   "In the tree, |Enter| opens the file in a TAB OF ITS OWN and leaves the one you were reading where it was. A file already open is jumped to instead of opened again, and a folder simply unfolds",
 \   "On the empty |new|1| GrooVim opens with, the file opens IN it instead of in a tab beside it -- the same rule |F5->p| , a file dropped on the window and |--jrinst| go by",
 \   "A DOUBLE CLICK does exactly what |Enter| does -- one click unfolds a folder, two open a file. They are two doors to the same thing, and the mouse used to go through the other one: it put the file in the window you came from, over the one you were reading"
 \  ],
 \  "menu": "File tree", "what": "Opens/closes the *file tree*",
 \  "needs": {"switch": "enable_nerdtree_vim", "name": "the NERDTree plugin"}},
 \ {"where": "View", "group": "F4", "key": "b", "break": 1, "modes": "niv", "run": 'call GrooVim_BookmarkToggle()',
 \  "menu": "Toggle bookmark", "what": "Marks the line, or takes the mark off (*bookmark*)"},
 \ {"where": "View", "group": "F4", "key": "i", "modes": "niv", "run": 'call GrooVim_BookmarkAnnotate()',
 \  "menu": "Note on the bookmark...", "what": "Writes a note on the marked line, or changes it (*bookmark*)"},
 \ {"where": "View", "group": "F4", "key": "l", "modes": "niv", "run": 'call GrooVim_BookmarkList()',
 \  "menu": "Bookmark list", "what": "Lists every marked line, or takes the list away",
 \  "notes": [
 \   "In the list, |Enter| or a double click takes you to the line, and |Del| takes that mark off -- which is what the key means in a list everywhere else"
 \  ]},
 \ {"where": "View", "group": "F4", "key": "c", "modes": "niv", "run": 'call GrooVim_BookmarkClearAll()',
 \  "menu": "Clear all bookmarks", "what": "Takes every mark off EVERY file, and asks first"},
 \
 \ {"where": "View", "keys": "m", "break": 1, "modes": "n",
 \  "menu": "Next bookmark", "what": "To the next marked line"},
 \ {"where": "View", "keys": "M", "modes": "n",
 \  "menu": "Previous bookmark", "what": "To the marked line before it"},
 \ {"where": "View", "keys": "<C-Up>", "break": 1, "modes": "niv",
 \  "menu": "Next tab", "what": "The next tab"},
 \ {"where": "View", "keys": "<C-Down>", "modes": "niv",
 \  "menu": "Previous tab", "what": "The tab before it"},
 \ {"where": "View", "keys": "<C-S-Up>", "modes": "niv",
 \  "menu": "Move tab right", "what": "Moves this tab one place to the right"},
 \ {"where": "View", "keys": "<C-S-Down>", "modes": "niv",
 \  "menu": "Move tab left", "what": "Moves it one place to the left"},
 \ {"where": "View", "group": "F5", "key": "t", "modes": "niv", "run": 'call GrooVim_TabToReturnSet()',
 \  "menu": "Pin this tab", "what": "Allows always returning to a particular tab using <Alt-Down>",
 \  "notes": [
 \   "The pinned tab wears a mark on the tab line, so which one it is can be seen at any moment without pressing anything. The mark is |g:GrooVim_TabPinMark| , and |\"\"| takes it off",
 \   "Pressed ON the pinned tab it unpins; pressed anywhere else it moves the pin there. One tab at a time, because \"take me back\" has to mean one place",
 \   "The pin lives IN the tab and not in its number: carrying the tab along the line with |Ctrl+Shift+Up| takes the pin with it"
 \  ]},
 \ {"where": "View", "keys": "<A-Down>", "modes": "niv",
 \  "menu": "Back to the pinned tab", "what": "Back to the tab set with F5->t",
 \  "notes": [
 \   "Pressed ON the pinned tab it does the opposite: back to the tab you came from. With no tab pinned it is always that -- the last one you were on"
 \  ]},
 \ {"where": "View", "keys": "<A-,>", "press": "<F16>", "break": 1, "modes": "niv",
 \  "menu": "Window back",
 \  "what": "To the window before this one, going round",
 \  "notes": [
 \   "It was |Ctrl+W| , which only ever went one way. And the |Ctrl+W| of Vim is back to being what it is everywhere else: the key every window command begins with"
 \  ]},
 \ {"where": "View", "keys": "<A-.>", "press": "<F17>", "modes": "niv",
 \  "menu": "Window forward",
 \  "what": "To the next window, going round"},
 \ {"where": "View", "keys": "<F10>", "break": 1, "modes": "niv",
 \  "menu": "Menu", "what": "Opens this menu"},
 \
"\ ---- Settings
 \ {"where": "Settings", "group": "F5", "key": "r", "break": 1, "modes": "niv", "run": {"i": 'call feedkeys("\<Esc>\\zvvi")', "nv": 'call feedkeys("\\zvv")'}, "menu": "Reload GrooVim", "what": "Reloads the file|.vimrc|in all tabs"},
 \ {"where": "Settings", "group": "F5", "key": "c", "modes": "niv", "run": 'call GrooVim_Configure()',
 \  "menu": "Settings...", "what": "Opens the settings -- ALL of them",
 \  "notes": [
 \   "It asks which of them first: |[i]ndent| , the width and what <Tab> puts; |[v]iew| , what is DRAWN and is not in the file, the language among it; |[f]ile| , the encoding and what ends a line IN the file you have open; |[s]earch| ; |[r]eplace| ; |[g]eneral| . Then it opens that screen",
 \   "|[i]| asks the width of the indent and whether <Tab> puts spaces; |[v]| asks what the screen SHOWS -- the guides, the symbols, the long-line mark, the word wrap",
 \   "On every screen, leaving an answer EMPTY keeps the value shown as \"in use\". At the end a summary of what you chose is held on screen until you press <Enter>",
 \   "|[f]ile| is the only one with nothing to save: an encoding belongs to the DOCUMENT and not to GrooVim, so it applies to what is open and stops there",
 \   "There is one door and only one. Each screen used to have a key of its own, so the letters |f| , |h| and |i| of this group are free again"
 \  ]},
 \
"\ ---- ?
 \ {"where": "?", "keys": "<F9>", "modes": "n",
 \  "menu": "GrooVim help", "what": "Opens the help of GrooVim, and closes it"},
 \ {"where": "?", "keys": "<F1>", "modes": "ni",
 \  "menu": "Vim help", "what": "Opens the help of Vim itself",
 \  "notes": [
 \   "It is the <F1> of Vim and nothing of GrooVim: no mapping of ours stands in front of it. On a Vim file, |K| over a word opens the help OF THAT WORD, which is what the |keywordprg| of Vim is for",
 \   "In visual mode it does nothing -- measured, and it is Vim: |<Help>| is not a visual mode command"
 \  ]},
 \ {"where": "?", "group": "F5", "key": "/", "break": 1, "modes": "niv", "run": 'call GrooVim_About()',
 \  "menu": "About GrooVim", "what": "What GrooVim is: the version, the licence, and the Vim underneath",
 \  "notes": [
 \   "It is a DIALOGUE, and every dialogue of GrooVim is answered the same way: |<Left>| and |<Right>| walk the buttons, |<Enter>| presses the blue one, the letter beside a label presses that one, and the mouse clicks any of them",
 \   "|c| copies what a dialogue says -- this one and every other -- which is why there is no button for it",
 \   "An address in a dialogue is a link: click it and it opens where you open a page. With no desktop, which is every GrooVim reached over SSH, the address goes to the clipboard instead, and the clipboard travels through the terminal to the machine you are sitting at",
 \   "The same |F5->/| closes it, and so does the way out on it"
 \  ]}
 \ ]

" Note: How a key is written on screen. A letter goes in plain angle brackets; a
" named key gets its capital back; punctuation is wrapped in bars, because the
" help syntax of Vim would otherwise eat a "/" or a "[" .
"
" Written by the same function the MENU writes with, so that a key is spelled
" one way in GrooVim: "F2->c" where it is an F key, "Ctrl+C" where it is a key
" of its own.
"
" The bars around it are what the help syntax of Vim highlights with, and they
" only go on where the word would not be picked out otherwise.
func! GrooVim_ShortcutKeyShown(one) abort
  let l:name = GrooVim_ShortcutShown(a:one)
  if l:name =~ '^\w\+$'
    return "        <" . l:name . "> - "
  endif
  return "       |" . l:name . "|- "
endfunc

" Note: Which modes a key answers in, spelled the way the help spells it.
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
" The README used to keep its own copy of every shortcut, and it drifted the
" furthest of all of them: it still listed the layout of three groups, with no
" "F5" at all, and the same letter three times over in one of them. It is
" written from here now, and a case of the battery refuses to pass while the
" file and this disagree.
"
" The marks the help syntax needs are taken out -- "|" is a link in a help file
" and a table in Markdown.
func! GrooVim_ShortcutsMarkdown() abort

  let l:out = []

  for l:group in g:GrooVim_MenuSections
    call add(l:out, "")
    call add(l:out, " * **" . l:group[0] . "** *(" .
     \ GrooVim_ShortcutPlain(l:group[1]) . ")*")
    call add(l:out, "")

    for l:one in g:GrooVim_Shortcuts
      if l:one.where !=# l:group[0]
        continue
      endif
      call add(l:out, "    - `" . GrooVim_ShortcutShown(l:one) . "` - " .
       \ GrooVim_ShortcutPlain(l:one.what) . " *" .
       \ GrooVim_ShortcutModes(l:one.modes) . "*;")
      for l:note in get(l:one, "notes", [])
        call add(l:out, "        - " . GrooVim_ShortcutPlain(l:note) . ";")
      endfor
    endfor
  endfor

  call add(l:out, "")
  return l:out
endfunc

" Note: The F group sections of the help, written out of the list above.
func! GrooVim_ShortcutsHelp() abort

  let l:out = []

  " Note: What is written here is what THIS GrooVim can do: a shortcut whose
  " plugin is not installed is not on the list, and neither is a group left
  " empty by that. The README is the other way round -- see the Markdown above,
  " which writes every one of them, because it describes the project and not one
  " machine.
  for l:group in GrooVim_MenuSectionsHere()
    call add(l:out, "")
    call add(l:out, "    *" . l:group[0] . "*")
    call add(l:out, "      " . l:group[1] . ";")

    for l:one in g:GrooVim_Shortcuts
      if l:one.where !=# l:group[0] || !GrooVim_ShortcutAvailable(l:one)
        continue
      endif
      call add(l:out, GrooVim_ShortcutKeyShown(l:one) . l:one.what .
       \ " " . GrooVim_ShortcutModes(l:one.modes) . ";")
      " Note: What hangs under a shortcut is a line ABOUT it and not a note in
      " the sense the source uses the word. Written as the sub-items they are,
      " with the dash the rest of this text uses.
      for l:note in get(l:one, "notes", [])
        call add(l:out, "            |-|" . l:note . ";")
      endfor
    endfor
  endfor

  return join(l:out, "\n")
endfunc

" Note: Where the project lives. A variable and not a line written inside the
" text, because the About shows it, the clipboard takes it and the browser is
" handed it -- three uses, one address.
let g:GrooVim_Url = get(g:, "GrooVim_Url", "https://github.com/eduardolucioac/groovim")

" Note: What GrooVim is, in the shape the "?" menu of Notepad++ ends with: the
" name, the version, whose it is, under what licence, and where it lives.
"
" The version of Vim is asked of Vim and not written here. "v:version" is the
" release -- 902 is 9.2 -- and the last four digits of "v:versionlong" are the
" patch, which is the number that actually moves.
func! GrooVim_AboutLines() abort
  return [
   \ "GrooVim =D " . g:grooVimVersion . " -- Vi IMproved'n'GrooVIed!",
   \ "",
   \ "A Vim of its own, remodelled for a simpler, smarter experience.",
   \ "It runs on Vim " . printf("%d.%d.%d", v:version / 100, v:version % 100,
   \   v:versionlong % 10000) . ".",
   \ "",
   \ "Copyright (C) 2014-2026 Eduardo Lucio Amorim Costa",
   \ "GNU General Public License v3.0 or later",
   \ g:GrooVim_Url,
   \ "",
   \ "F9 opens the help of GrooVim, F1 the help of Vim."]
endfunc

" Note: The About is a dialogue and nothing else: the text above, a button that
" opens the page and a way out. Everything a dialogue can do -- the arrows, the
" Enter, the mouse, the "c" that copies, the link -- it can do because it is
" one, and not because it is the About.
"
" Opening it while it is up closes it, which is what F9 does with the help. The
" two keys of the shortcut are also given to the dialogue, so pressing it again
" over the window closes it as well: while a dialogue is up, it is the only
" thing reading keys, and the CommandZ never sees them.
"
" The key of the way out is written "Esc" because that is what the button says.
" The Esc itself is answered by the dialogue before any button is looked at, so
" what this writes is the label and not a key anybody has to match.
func! GrooVim_About() abort

  if GrooVim_DialogUp()
    call GrooVim_DialogClose()
    return
  endif

  call GrooVim_Dialog({
   \ "title": " About GrooVim ",
   \ "lines": GrooVim_AboutLines(),
   \ "shortcut": ["\<F5>", "/"],
   \ "buttons": [
   \  {"label": "Open page", "key": "p",
   \   "run": "GrooVim_DialogPage", "args": [g:GrooVim_Url]},
   \  {"label": "Close", "key": "Esc", "close": 1}]})

endfunc

" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
" THE TEXT OF THE HELP
" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" Note: Prose, written in the markup of a help file of Vim: a "|" on each side
" of a word highlights it, a "~" ends a heading, and ">" and "<" open and close
" an example. The window that shows it is put in the state that renders that
" markup by "GrooVim_ToogleGrooVimHelp()", in the tabs part.
"
" To look at it by hand while writing it, put the buffer you are on in the same
" state: >
"   setlocal wrap linebreak nolist textwidth=0 wrapmargin=0 formatoptions+=l
"   setlocal syntax=help
" <
let g:GrooVimHelp = "*=D=D=D=D=D=D=D=D_HELP_FOR_GrooVim_=D=D=D=D=D=D=D=D*".
\"\n|GrooVim|=D|" . g:grooVimVersion . "|-|Vi|IMproved'n'GrooVIed!|".
\"\n Eduardo Lúcio Amorim Costa~".
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
\"\n\"This work is about freedom.".
\"\n - End of message\"".
\"\n".
\"\n|BETA|VERSION!|".
\"\n".
\"\n * What GrooVim is~".
\"\n".
\"\n A Vim remodelled to be used as a simpler, more intuitive and more productive editor: keyboard shortcuts that MEAN what they mean everywhere else, plus a good many cool ones of its own, the mouse working, a menu, and much more. And nothing of Vim is taken away from you.".
\"\n".
\"\n What it is after:".
\"\n".
\"\n*o*  Usable right away by whoever comes from an editor or an IDE;".
\"\n*o*  A real interface -- a menu, screens that ask, panels, a bar that answers;".
\"\n*o*  Vim as a general purpose editor, for people who do not live in the terminal;".
\"\n*o*  Free software (GNU GPL v3.0 or later), open and community-supported;".
\"\n*o*  At home where only a terminal exists: a server, an SSH, a machine with no desktop.".
\"\n".
\"\n * Before you start~".
\"\n".
\"\n--------".
\"\n *IMPORTANT_I!* If you do not know how Vim works, open a terminal, run|vimtutor|and do the exercises -- 25 to 30 minutes. GrooVim does not replace the Vim underneath it, it sits on top.".
\"\n *IMPORTANT_II!* Everything here was possible because of the Vim API. The editor you are using is Vim; what GrooVim adds is how it answers you.".
\"\n--------".
\"\n".
\"\n*o*  The shortcuts may clash with the ones of YOUR system. A terminal cannot carry every combination, so when there is a clash it is easier to move the one of the system;".
\"\n*o*  Three plugins are used when they are installed, and GrooVim works without any of them:".
\"\n   |-||NERDTree| , the file tree:|[https://github.com/preservim/nerdtree]|".
\"\n   |-||tcomment| , which comments lines:|[https://github.com/tomtom/tcomment_vim]|".
\"\n   |-||move| , which moves a line or a selection:|[https://github.com/matze/vim-move]|".
\"\n*o*  No plugin manager is needed: Vim loads whatever is under|~/.groovim/pack/*/start| by itself. Each one is DETECTED, so what is missing simply stays quiet, and a shortcut that needs it says so instead of failing;".
\"\n*o*  To force or to ignore one:|let|g:enable_tcomment_vim|=|0/1| , or all of them at once with|let|g:enable_all_plugins|=|0/1| .".
\"\n".
\"\n * The keys you (maybe) already know~".
\"\n".
\"\n These do in GrooVim what they (maybe) do in any editor:".
\"\n".
\"\n*o*  <Ctrl-Left>/<Ctrl-Right> - a word at a time (normal mode/insert/visual);".
\"\n*o*  <Tab> - indents, and over a selection every line of it (normal mode/visual);".
\"\n*o*  <Enter> , <Backspace> , <Del> and <Space> - where Vim gave them another meaning (normal mode/visual);".
\"\n*o*  <Ctrl-c> and <Ctrl-x> - copy and cut, through the system clipboard (visual), and <Ctrl-v> pastes (normal mode/insert/visual). A <Del> , an <x> or a replacement does NOT touch it: what you copied is still there after you delete something;".
\"\n*o*  <Ctrl-u> and <Ctrl-r> - undo and redo (normal mode/insert/visual);".
\"\n*o*  <PageDown>/<PageUp> , the mouse wheel and a click - and they reach the places with no text on them (normal mode/insert/visual);".
\"\n*o*  <Alt-.>/<Alt-,> - ONE key walks to the next/previous window, going round (normal mode/insert/visual). <Ctrl-w> stays the key of Vim, which every window command begins with;".
\"\n*o*  <Shift-Up>/<Shift-Down> - in and out of insert mode, in and out of visual mode (normal mode/insert/visual). The cursor does not move when the mode changes;".
\"\n*o*  Extensions Vim does not know are given a type: an |.inc| opens as HTML and a |.gds| as Visual Basic. The list is |g:GrooVim_SyntaxPerExtension| , and one line adds your own.".
\"\n".
\"\n * The questions GrooVim asks~".
\"\n".
\"\n Every screen and every question -- the search value, the settings, the name of a file, the note of a mark -- is the command line of Vim: the arrows, the history, |<BS>| and the completion with <Tab> are the ones you already know.".
\"\n".
\"\n*o*  <Esc> gives the question up, at any point, and nothing is done. <Ctrl-c> does the same, and it is also what stops a long movement;".
\"\n*o*  <Ctrl-v> pastes into the question, the way it pastes into the text: a path you have in your hand is the commonest answer there is. The line break it carries is dropped -- a question has nowhere to put one -- and <Ctrl-q> is still the \"next character, literally\" of Vim;".
\"\n*o*  The paste of your TERMINAL (usually <Ctrl-Shift-v>) puts the text in the SAME place, in the text as well as in a question: over SSH that paste is the one there is, and the two cannot land apart;".
\"\n*o*  An EMPTY answer is not the same as giving up: on most screens it means \"leave this one alone\", and the question says so when it does;".
\"\n*o*  Every screen ends asking whether to KEEP what you chose for the next time. Saying no changes this session and nothing on the disk.".
\"\n".
\"\n F5->c opens the settings, and one letter picks the screen: |[i]|ndent , |[v]|iew , |[f]|ile , |[s]|earch , |[r]|eplace , |[t]|ools , |[g]|eneral .".
\"\n".
\"\n * Moving and selecting~".
\"\n".
\"\n*o*  <Shift-Alt-Arrows> - the smooth movement: it glides a long stretch, goes over the places where there is no text and keeps the column it started in (normal mode/insert/visual);".
\"\n*o*  <Ctrl-Alt-Arrows> - the same, one short step at a time (normal mode/insert/visual);".
\"\n*o*  <Alt-Right>/<Alt-Left> - take the word to the right/left (normal mode/insert/visual);".
\"\n*o*  <Alt-End>/<Alt-Home> - take the rest of the line, from where you are (normal mode/insert);".
\"\n*o*  <Alt-i>/<Alt-o> - BACK to where you came from, and forward again (normal mode/insert/visual): a search, a |G| , a line opened from the occurrence list, another file. Walking with the arrows leaves nothing to come back to, which is what you want;".
\"\n*o*  <Ctrl-b> - from one bracket to the one that closes it, and it takes the selection with it (normal mode/insert/visual);".
\"\n*o*  |m| and |M| - to the next marked line and to the one before (normal mode);".
\"\n*o*  F2->o - puts the SELECTED lines in order (normal mode/insert/visual). Asked on F5->c and then |[t]| : case |[s]|ensitive or |[i]|nsensitive, |[a]|scending or |[d]|escending, and whether only the UNIQUE lines come out -- which they do unless you say otherwise, so a line that repeats is dropped;".
\"\n   |-|By a FIELD and not by the whole line, select a BLOCK over the column the field begins at. With |2026-03-11  Maria| , |2024-07-02  Joao| and |2025-12-30  Ana| : |V| |G| and F2->o puts them in order of DATE, and <12l> F2->b <2j> and F2->o -- a block on the thirteenth column, where the names begin -- puts them in order of NAME, each date coming along with its own.".
\"\n".
\"\n * Your tabs~".
\"\n".
\"\n*o*  <Ctrl-Up>/<Ctrl-Down> - the next tab, the one before (normal mode/insert/visual);".
\"\n*o*  <Ctrl-Shift-Up>/<Ctrl-Shift-Down> - carry the tab you are on to the next place in the line (normal mode/insert/visual). At either end it stays put;".
\"\n*o*  F5->t pins a tab and marks it on the line; <Alt-Down> goes back to it from wherever you are, and pressing it there goes back to where you called it from;".
\"\n*o*  With more tabs than the line is wide it SCROLLS: the tab you are on is drawn whole, and a |‹| or a |›| at the end says the line goes on that way;".
\"\n*o*  Two tabs with the same file NAME show enough of the path to be told apart, |a/help.vim| beside |b/help.vim| ;".
\"\n*o*  A new tab is born at the END of the line, wherever you were when you asked for it: the order of the tabs is the order you opened them in;".
\"\n*o*  A file already open is not opened again: you land on the tab that has it;".
\"\n*o*  A file handed from OUTSIDE opens a tab too: |groovim|-j|file| , typed in another terminal, puts it in the GrooVim already open instead of starting a second one -- \"just reuse an instance\", and several files at a time. The oldest one open takes them, and with none open that command opens them itself. It asks for no X and no desktop, so it works over SSH, and it is what the menu entry of your desktop uses;".
\"\n*o*  And that GrooVim is brought TO THE FRONT, the way the icon of a graphical program brings its window: the window belongs to the TERMINAL, so what is raised is the window of the nearest ancestor that has one. KDE answers on D-Bus (which is what makes it work on Wayland), sway takes a window by the process in it, on X11 |xdotool| or |wmctrl| do it when one of them is there, and GNOME answers through the |Window|Calls| extension, which the installer offers to put in on a GNOME session -- GNOME Shell itself offers nothing for this. Where none answers the file still opens here; only the window stays where it is;".
\"\n*o*  The command opens one TAB for each file it is given, and reads a LIST of names arriving on its input -- |find|./|-name|'*.log'||||groovim| . A lone |-| is Vim's own: read the text from there. |groovim|--help| says the rest.".
\"\n".
\"\n * The bar at the bottom~".
\"\n".
\"\n From left to right: the path of the file, the encoding and what ends a line, the file type, the line and column, how much of the file is above you, and how much is selected while you hold a selection.".
\"\n".
\"\n*o*  The PATH is written to fit the room there is, and F2->Space says the WHOLE of it;".
\"\n*o*  |[utf-8,unix]| is what the file is on right now, with a |,B| when there is a BOM;".
\"\n*o*  |[46,3]| is the selection: 46 CHARACTERS -- not bytes, so an accented letter counts as one -- lying on 3 lines;".
\"\n*o*  Messages of GrooVim come up there too, after the |Powered|by| , and go away by themselves.".
\"\n".
\"\n * The file you have open~".
\"\n".
\"\n The encoding and what ends a line belong to the DOCUMENT and not to the editor. Both are asked on one screen, with F5->c and then |[f]| :".
\"\n".
\"\n*o*  The encoding and what to do with it, in ONE answer of two letters. The encoding is |[a]nsi| , |[u]tf-8| , utf-8 with |[b]om| , utf-16 |[l]e| or utf-16 b|[e]| ; what to do with it is |[r]| , which READS the file again with that encoding -- the bytes do not move and their meaning changes -- or |[c]| , which CONVERTS the file -- the text does not move and the bytes do. So |uc| is \"utf-8, by converting\";".
\"\n*o*  What ends a line: |[u]nix| LF, |[w]indows| CRLF, |[m]acintosh| CR;".
\"\n*o*  An EMPTY answer leaves THAT question alone and goes on to the next, so pressing <Enter> through the screen leaves the file as it found it. What was done and what was not is said on the bar afterwards;".
\"\n*o*  Reading again throws away what you have not written yet, so it is refused while there is something to lose;".
\"\n*o*  A file DELETED from the disk while it is open asks whether to keep it here. Yes brings the document back as one with changes in it, so one save puts the file on disk again; no lets it go with the file, and the tab closes.".
\"\n".
\"\n The LANGUAGE -- what Vim calls the |filetype| , and what decides the colours, the indenting and the comment character -- is asked one screen over, with F5->c and then |[v]| . |none| leaves the file as plain text, and <Tab> completes among the hundreds Vim ships.".
\"\n".
\"\n * Indentation~".
\"\n".
\"\n The indent is |2| columns wide and made of SPACES, and the guides that draw the levels are native to Vim.".
\"\n".
\"\n*o*  F5->c and then |[i]| asks the width and whether <Tab> puts spaces. It is the \"Tab Settings\", and like every screen it ends asking whether to keep what you chose for the next time;".
\"\n*o*  F5->c and then |[v]| asks what the screen SHOWS: the guides, a dot on every space, an arrow on every tab, the vertical line that marks a long line, and the word wrap. The word wrap is about your DOCUMENTS -- the panels and the help always wrap, because a line of a list running off the screen is an answer you cannot read;".
\"\n*o*  To change only the buffer you are on, without leaving the keyboard: >".
\"\n     GrooVimIndent 4".
\"\n<  With no argument it tells you the width in force;".
\"\n*o*  Only the file types you choose are touched. Vim already ships file type plugins that know what they are doing, and some of them are not a matter of taste -- *make* needs a REAL tab on its recipe lines.".
\"\n".
\"\n Every setting of this has a name of its own -- see |The|settings|with|a|name|of|their|own| , further down.".
\"\n".
\"\n * The clipboard~".
\"\n".
\"\n GrooVim reaches the clipboard through a CASCADE and needs nothing installed. The first of these that answers is the one used:".
\"\n".
\"\n*o*  |1.| *Wayland* , with Vim talking to the compositor ITSELF;".
\"\n*o*  |2.| *X11* , the same way;".
\"\n*o*  |3.| A clipboard TOOL (*wl-copy* , *xclip* or *xsel* ), if one is already there;".
\"\n*o*  |4.| *OSC*52* , an escape sequence that carries the clipboard THROUGH the terminal. It needs no desktop and it crosses SSH, so a copy made on a remote server lands on the machine in front of you;".
\"\n*o*  |5.| A file in|~/.groovim/clipboard| , which always works and lets two GrooVim share a copy.".
\"\n".
\"\n To see which one is in use:|:echo|v:clipmethod| and|:echo|GrooVim_ClipReg()| .".
\"\n".
\"\n *PASTING*FROM*ANOTHER*APPLICATION!* Copying OUT always works. Reading the clipboard BACK is the one case that may need help, because OSC 52 would need the terminal to ANSWER a query and almost none do:".
\"\n".
\"\n*o*  On Wayland or X11 the case does not arise: Vim reads the clipboard itself;".
\"\n*o*  Where neither answers, <Ctrl-v> pastes what GrooVim itself copied, and the paste of your terminal -- usually <Ctrl-Shift-v> -- brings in what another application copied;".
\"\n*o*  Installing a tool brings <Ctrl-v> back to the system clipboard, with nothing to change in your configuration: |sudo|pacman|-S|wl-clipboard| or |sudo|apt|install|xclip| .".
\"\n".
\"\n *DRAGGING*A*FILE*ONTO*GrooVim!* A terminal has no way of saying \"a file was dropped here\": what it does is PASTE the path, which is what Konsole does -- every name followed by one space. GrooVim reads that and asks |\"x\"|was|dropped|here.|Open|it|[y[default]/n]?| . A yes opens one TAB for each file dropped, and a file already open is jumped to instead of opened twice; a no pastes the text, because pasting a path INTO a file is a thing people do all day:".
\"\n".
\"\n*o*  The FIRST file takes the page that is already there when that page is the empty |new|1| GrooVim opens with -- one tab, no name, nothing typed in it -- and the others get a tab each. A page with something written in it is never covered;".
\"\n*o*  The space at the END is what tells the two apart. A drop and a paste of the same path are the same bytes, and Konsole puts a space after every name while a hand that copies a path does not;".
\"\n*o*  In Konsole it works as it comes. The setting is in the profile, under |Mouse| : |Disable|drag|&|drop|menu|for|files|&|URLs| . With that menu ON, a drop asks Copy/Move/Link first and only |Paste|Location| reaches GrooVim -- and Copy and Move really do copy and move the file;".
\"\n*o*  In NORMAL mode, which is where the paste of the terminal is GrooVim's to answer. In insert mode Vim takes it in itself and the path is typed in, as it always was;".
\"\n*o*  A FOLDER dropped goes on pasting its path: a folder in a tab of its own would be a tab with nothing to read in it.".
\"\n".
\"\n *NO*BINARY*IS*SHIPPED*WITH*GrooVim,*ON*PURPOSE!* A Linux executable is built for one architecture and linked against one libc; what works on the machine it was built on is exactly what cannot be promised anywhere else. GrooVim looks for the tool in|~/.groovim/bin| first and then in your|$PATH| , so you can drop one there by hand where a package manager is not an option.".
\"\n".
\"\n * The settings with a name of their own~".
\"\n".
\"\n Every screen of F5->c writes what you choose into|~/.groovim/opts.vim| , and the same things have a NAME you can write into a configuration of your own. These are the ones worth knowing:".
\"\n".
\"\n*o*  The INDENT: |g:GrooVim_IndentWidth| (2 columns), |g:GrooVim_IndentWidthPerType| (a width per file type, |{\"python\":|4}| ), |g:GrooVim_IndentExpandTab| (1 for spaces, 0 for a real tab) and |g:GrooVim_IndentGuideChar| ( |\"\"| turns the guides off);".
\"\n*o*  What is DRAWN: |g:GrooVim_ShowSpaceAndTab| (a dot on every space and an arrow on every tab), |g:GrooVim_EdgeColumn| (79, the column of the long line mark, 0 for none) and |g:GrooVim_WordWrap| ;".
\"\n*o*  The TABS: |g:GrooVim_TabOnePerFile| (a file already open is not opened again), |g:GrooVim_TabPinMark| (the mark the pinned tab wears) and |g:GrooVim_TabMoreLeft| , |g:GrooVim_TabMoreRight| (what the tab line ends with when it scrolls);".
\"\n*o*  The F keys: |g:GrooVim_CommandZWait| , how long you have for the second key;".
\"\n*o*  The SELECTION count on the bar: |g:GrooVim_SelectionCountLimit| (2000 lines). Over that a |-| stands where the characters would be, because counting the characters of a selection that big is slower than the key that grows it;".
\"\n*o*  The SORT: |g:GrooVim_SortCase| , |g:GrooVim_SortOrder| and |g:GrooVim_SortUnique| , which are what F5->c and then |[t]| asks;".
\"\n*o*  The file TYPES Vim does not know: |g:GrooVim_SyntaxPerExtension| , and what you write there replaces the list, so keep the ones you want: >".
\"\n     let g:GrooVim_SyntaxPerExtension = {\"inc\": \"html\", \"gds\": \"vb\", \"ejs\": \"html\"}".
\"\n<".
\"\n*o*  The SESSION that comes back by itself: |g:GrooVim_SessionAuto| ;".
\"\n*o*  The text you have NOT saved, kept across the way out and across a crash: |g:GrooVim_UnsavedAuto| , with |g:GrooVim_UnsavedEveryMs| (5000) saying how often the copies are written and |g:GrooVim_UnsavedDir| where they live;".
\"\n*o*  The MAILBOX a file handed from outside arrives in: |g:GrooVim_InboxDir| and |g:GrooVim_InboxPollMs| , how often it is looked at (400ms);".
\"\n*o*  The PLUGINS: |g:enable_nerdtree_vim| , |g:enable_tcomment_vim| and |g:enable_move_vim| -- |0| ignores one and |1| forces it -- or |let|g:enable_all_plugins|=|0| for every one at once;".
\"\n*o*  Where GrooVim keeps ITSELF: |GROOVIM_HOME| , of the environment, moves the whole of it -- the plugins, the saved options, the undo, the session, the viminfo: >".
\"\n     GROOVIM_HOME=~/.groovim-work groovim file.txt".
\"\n<  Two of those side by side are two GrooVim that know nothing of each other, on one machine.".
\"\n".
\"\n * The F keys (CommandZ)~".
\"\n".
\"\n |CommandZ| is a kind of \"super leader\": <F2>, <F3>, <F4> or <F5> and then one more key. It is what gives GrooVim room for many shortcuts in a terminal, where the combinations a keyboard can send run out fast.".
\"\n".
\"\n You do not have to remember any of them. <F10> puts a BAR across the top with the sections on it, and under the one you are on, what it holds. |<Left>| and |<Right>| walk the bar, |<Up>| and |<Down>| the list, <Enter> picks and <Esc> leaves -- and pressing an |F| key jumps to the section where that key mostly lives. The mouse works everywhere.".
\"\n".
\"\n Every line of the menu shows the keys that do it. Choosing one PRESSES those keys, so the menu can never do something the keyboard would not.".
\"\n".
\"\n*o*  A shortcut is the |F| key and then ONE more key. How long you have for the second one is |g:GrooVim_CommandZWait| (|400ms| by default);".
\"\n*o*  Press the |F| key and nothing else, and when that time is up it REPEATS the last command that key ran. Each one remembers its own: |F2| repeats what |F2| did, |F3| what |F3| did;".
\"\n*o*  Press the same |F| key TWICE and it repeats at once, with no waiting. Hold it down and it goes on repeating;".
\"\n*o*  A second key that is NOT a shortcut of that group does nothing, and it does not become what the |F| key repeats either: pressing |F2| and then an arrow leaves |F2| alone still doing the last command that WORKED;".
\"\n*o*  A second key that arrives after that time is not thrown away. The |F| key has already repeated by then, and the key runs as ITSELF: a late |d| is the |d| of Vim, left waiting for what to delete;".
\"\n*o*  So if your second key keeps arriving late, make the window LONGER -- |let|g:GrooVim_CommandZWait|=|1000| , say. The longer you make it, the longer the |F| key alone takes to repeat, which is the price of the same one number;".
\"\n*o*  When a shortcut seems not to answer, |:GrooVimKey| tells you what the key really DELIVERED: run it, press the key, and read what it prints. Two keys that look the same on a keyboard can reach Vim as different keys, and this is the only way to tell them apart.".
\"\n".
\ GrooVim_ShortcutsHelp() .
\"\n".
\"\n * What is missing, and what is being worked on~".
\"\n".
\"\n It is a BETA, and what is open is open where the code is:|" . g:GrooVim_Url . "| . The |README.md| of the project tells what GrooVim can do, and this help tells how it does it.".
\"\n".
\"\n*=D=D=D=D=D=D=D=D_HELP_FOR_GrooVim_=D=D=D=D=D=D=D=D*"
