GrooVim - Vi IMproved'n'GrooVIed!
=============

<img border="0" alt="GrooVim Doc" src="http://imageshack.com/a/img829/4064/meg6.png" height="15%" width="15%"/>GrooVim Doc

Writing in several places at once -- **F2 n** takes whole lines, **F2 m** takes
places of their own:

![Writing in several places at once](demos/01_multi_caret.gif)

There are more of them below and all of them in [`demos/`](demos/README.md).

**NOTE:** They are made by a script and not recorded by hand -- change the editor, run
`./tools/make-demos.sh`, and they say what it says now. ☺️

What is GrooVim?
-----

**Note:** If you want to start using GrooVim immediately go to section: <a href="#installGrooVim">**"I do not want to know anything about GrooVim and want to start using it now and with all the features!"**</a>.

GrooVim is an extensive script -- a `.vimrc` and the parts it loads -- that
remodels Vim into a simpler, more intuitive and more productive editor. What it
is after:

 * Usable right away by whoever comes from an editor or an IDE;
 * A real interface -- a menu, screens that ask, panels, a bar that answers;
 * Vim as a general purpose editor, for people who do not live in the terminal;
 * Free software (GNU GPL v3.0 or later), open and community-supported;
 * At home where only a terminal exists: a server, an SSH, a machine with no desktop.

Before you start with the GrooVim!
-----

IMPORTANT_I! If you do not know how Vim works, open a terminal, run __vimtutor__ and do the exercises -- 25 to 30 minutes. GrooVim does not replace the Vim underneath it, it sits on top, so knowing the Vim in its basics is what lets you use this one well -- and contribute to it.

IMPORTANT_II! Everything here was possible because of the Vim API. The editor you are using is Vim; what GrooVim adds is how it answers you.

 * The shortcuts may clash with the ones of YOUR system. A terminal cannot carry every combination, so when there is a clash it is easier to move the one of the system;
 * Three plugins are used when they are installed, and GrooVim works without any of them -- [NERDTree](https://github.com/preservim/nerdtree), the file tree; [tcomment](https://github.com/tomtom/tcomment_vim), which comments lines; [move](https://github.com/matze/vim-move), which moves a line or a selection;
 * No plugin manager is needed: Vim loads whatever is under `~/.groovim/pack/*/start` by itself. Each one is DETECTED, so what is missing simply stays quiet, and a shortcut that needs it says so instead of failing;
 * To force or to ignore one: `let g:enable_tcomment_vim = 0/1`, or all of them at once with `let g:enable_all_plugins = 0`.

The GrooVim solves the following "problems"!
-----

These do in GrooVim what they do in any editor:

 * **Ctrl-Left**/**Ctrl-Right** - a word at a time *(normal mode/insert/visual)*;
 * **Tab** - indents, and over a selection it indents every line of it *(normal mode/visual)*;
 * **Enter**, **Backspace**, **Del** and **Space** - where Vim gave them another meaning *(normal mode/visual)*;
 * **Ctrl-c** and **Ctrl-x** - copy and cut, through the system clipboard *(visual)*, and **Ctrl-v** pastes *(normal mode/insert/visual)*. A Del, an `x` or a replacement does **not** touch it: what you copied is still there after you delete something;
 * **Ctrl-u** and **Ctrl-r** - undo and redo *(normal mode/insert/visual)*;
 * **PageDown**/**PageUp**, the mouse wheel and a click - and they reach the places with no text on them: a short line, the gap after the end of one *(normal mode/insert/visual)*;
 * **Alt-.**/**Alt-,** - one key walks to the next/previous window, going round *(normal mode/insert/visual)*. Ctrl-w stays the key of Vim, which every window command begins with.

Some editor features!
-----

 * Switching between modes, with the cursor staying where and more...
    - Shift-Up (normal mode/insert/visual) - Enter or exit the insert mode;
    - Shift-Down (normal mode/insert/visual) - Enter or exit the visual mode;

![In and out of the modes](demos/07_modes.gif)

 * Text selection:
    - Alt-Right/Alt-Left (normal mode/insert/visual) - Word selection to the right/left;
    - Alt-End/Alt-Home (normal mode/insert) - Select text on the line until the end/beginning from the current point;
    - How much is selected is on the bar at the bottom while you hold it, the "Sel" of Notepad++, after the percentage: `[46,3]` is 46 **characters** -- not bytes, so an accented letter counts as one -- lying on 3 lines. Over `g:GrooVim_SelectionCountLimit` lines (2000) a `-` stands where the characters would be, because counting the characters of a selection that big is slower than the key that grows it; ?????? Para quê tantos detalhes técnicos. Focalize na funcionalidade. Não há necessidade de ficar citando o Notepad++.

 * Conventional text editors commands:
    - Ctrl-c (visual mode) - Copy to clipboard;
    - Ctrl-v (normal mode/insert/visual) - Paste from clipboard;
        - Note: Copying out always works. To PASTE what another application copied you need a clipboard tool installed, or your terminal own paste (usually Ctrl-Shift-v). See <a href="#clipboard">**"About the clipboard"**</a>;
    - Ctrl-x (visual mode) - Cut to the clipboard;
    - Ctrl-u (normal mode/insert/visual) - Undo;
    - Ctrl-r (normal mode/insert/visual) - Redo;

 * Plugins (when they are installed):
    - Ctrl-j/Ctrl-k (normal mode/insert/visual) - Move the line or the selection up/down (*move*);
    - Alt-Up (normal mode/insert/visual) - Comment the line or the selection, and uncomment it (*tcomment*);
    - F4 n - Open the file tree, the same one in every tab (*NERDTree*);

The questions GrooVim asks!
-----

Every screen and every question -- the search value, the settings, the name of a
file, the note of a mark -- is the command line of Vim: the arrows, the history,
Backspace and the completion with Tab are the ones you already know. ?????? Para quê esta quantidadede informação? A ideia é apresentar a funcionalidade como um dos diferenciais e não detalhes "tecnicos".

 * **Esc** gives the question up, at any point, and nothing is done. **Ctrl-c**
   does the same, and it is also what stops a long movement;
 * An empty answer is not the same as giving up: on most screens it means "leave
   this one alone", and the question says so when it does;
 * Every screen ends asking whether to KEEP what you chose for the next time.
   Saying no changes this session and nothing on disk.

**F5 c** opens the settings, and then one letter picks the screen: `[i]`ndent,
`[v]`iew, `[f]`ile, `[s]`earch, `[r]`eplace, `[t]`ools, `[g]`eneral.

The file you have open!
-----

The encoding and what ends a line belong to the **document**, not to the editor,
and both are asked on one screen -- **F5 c** and then `[f]`:

 * The encoding and what to do with it, in one answer of two letters. The
   encoding is `[a]nsi`, `[u]tf-8`, utf-8 with `[b]om`, utf-16 `[l]e` or utf-16
   b`[e]`; what to do with it is `[r]`, which **reads** the file again with that
   encoding -- the bytes do not move and their meaning changes -- or `[c]`,
   which **converts** it -- the text does not move and the bytes do. So `uc` is
   "utf-8, by converting";
 * What ends a line: `[u]nix` LF, `[w]indows` CRLF, `[m]acintosh` CR;
 * Reading again throws away what you have not written yet, so it is refused
   while there is something to lose.

What the file is on right now is on the bar at the bottom: `[utf-8,unix]`, with
a `,B` when there is a BOM.

The **language** -- what Vim calls the `filetype`, and what decides the colours,
the indenting and the comment character -- is asked one screen over, with
**F5 c** and then `[v]`. `none` leaves the file as plain text, and Tab completes
among the hundreds Vim ships.

Indentation!
-----

The indent is **2 columns wide and made of spaces**, and the guides that draw the
levels come from `listchars`, native to Vim.

 * `g:GrooVim_IndentWidth` - the general width;
 * `g:GrooVim_IndentWidthPerType` - the width per file type. One line is enough:

```
let g:GrooVim_IndentWidthPerType = {"python": 4, "javascript": 2}
```

 * `g:GrooVim_IndentGuideChar` - the char of the guide, or `""` to turn the guides off;
 * `g:GrooVim_IndentExpandTab` - 1 for spaces, 0 for a real tab;
 * `g:GrooVim_ShowSpaceAndTab` - 1 draws a dot on every space and an arrow on
   every tab. On by default: a space and a tab look the same and are not, and
   that is the kind of thing you want to see;
 * `g:GrooVim_EdgeColumn` - the column the vertical line is drawn on, `79` by
   default, or 0 for no line. It is drawn on every row, so a short line gets it
   too;
 * `g:GrooVim_WordWrap` - 1 wraps a long line onto the next row instead of running
   it off the screen, breaking at a space and not inside a word. It is the "Word
   wrap" of Notepad++, off by default. With it on, **Up** and **Down** walk the
   rows you see and not the lines of the file. It is about your DOCUMENTS: the
   panels and the help always wrap, whatever you set here, because a line of a
   list running off the screen is an answer you cannot read; ?????? Detalhes mais técnicos como configurações de variáveis devem ficar no HELP. A ideia principal do README e demonstrar as qualidades do GrooVim e dar uma idéia mais geral sobre o seu funcionamento.

The width and whether Tab puts spaces are asked with **F5 c** and then `[i]`, the
"Tab Settings" of Notepad++; what the screen SHOWS -- the guides, the symbols,
the vertical line, the word wrap -- is one screen over, with **F5 c** and then
`[v]`. To change only the buffer you are on, without leaving the keyboard:

```
GrooVimIndent 4 ?????? É difícil até entender do que se trata essa seção...
```

With no argument it tells you the width in force.

Only the file types you list are touched. Vim already ships file type plugins that
know what they are doing, and some of them are not a matter of taste: **make** needs
a REAL tab on its recipe lines and **go** is written with tabs by gofmt. Those are
left alone.

The guides read the width from the standard Vim options when drawing, so they follow
a `modeline`, a file type plugin or a `:set shiftwidth=` you type.

Relevant changes in the default Vim behavior! ?????? Apenas informe que o GrooVim facilita o processo de edição substancialmente modificando o comportamento do vim para um comportamento mais próximo e direto ao que os usuários estão acostumados e facilitando muitos processos de edição...
-----

 - Use F2 b to enable visual block mode (not Ctrl+v). Ctrl+b walks from one bracket to the one that closes it -- `(` to `)`, `[` to `]`, `{` to `}` -- and takes the selection with it in visual mode;
 - When changes from visual mode to insert mode the cursor do not move;
 - Use the system clipboard whenever it can be reached, see <a href="#clipboard">**"About the clipboard"**</a>;
 - The "insert" (includes typed text) and "paste" from the same cursor position;
 - Extensions Vim does not know are given a type: `.inc` opens as HTML and `.gds`
   as Visual Basic. The list is `g:GrooVim_SyntaxPerExtension`, and one line adds
   your own -- what you write there replaces the two, so keep the ones you want:

```
let g:GrooVim_SyntaxPerExtension = {"inc": "html", "gds": "vb", "ejs": "html"} ?????? Configuração que deveria estar no HELP.
```


Script features!
-----

 * Navigation

    - Shift-Alt-Arrows (normal mode/insert/visual) - Smooth navigation across the screen (including invalid areas) with long movements;
    - Ctrl-Alt-Arrows (normal mode/insert/visual) - Navigation with arrows across the screen (including invalid areas) using short movements;
    - Alt-i/Alt-o (normal mode/insert/visual) - Back to where you came FROM, and forward again: a search, a `G`, a line opened from the occurrence list, another file. Walking with the arrows leaves nothing to come back to, which is what you want; ?????? Não precisa de tantos detalhes técnicos...
    - Ctrl-Up/Ctrl-Down (normal mode/insert/visual) - Go to the next/previous tab;
    - Ctrl-Shift-Up/Ctrl-Shift-Down (normal mode/insert/visual) - Carry the current tab to the next/previous place in the tab line;
    - F5 t pins a tab and marks it on the line, and **Alt-Down** goes back to it from wherever you are *(normal mode/insert/visual)*;
    - The **path** of the file is on the bar, with your home as `~` and the middle taken out when it does not fit (`~/Data0/.../_GROOVIM/01.txt`). Vim has no status bar of two lines, so what does not fit is not written -- **F2 Space** says the whole of it, in a balloon;
    - A new tab is born at the **end** of the line, wherever you were when you asked for it: the order of the tabs is the order you opened them in. Vim puts it after the tab you are on;
    - A file already **open is not opened again**: the new tab gives way and you land on the tab that has it, the way every conventional editor does. It is `g:GrooVim_TabOnePerFile`, and it is caught at the birth of a tab -- walking buffers inside a tab of your own is untouched;
    - Two tabs with the **same file name** show the piece of the path that tells them apart: `a/help.vim` beside `b/help.vim`, and `b/.../help.vim` when what differs is further up. The name comes back alone as soon as the collision is gone;
    - With more tabs than the line is wide the tab line **scrolls**: the tab you are on is always drawn whole, and a `‹` or a `›` at the end says the line goes on that way. It is `g:GrooVim_TabMoreLeft` and `g:GrooVim_TabMoreRight`;

The smooth one glides instead of jumping, goes over the places where there is no
text -- a short line, the gap after the end of one -- and keeps the column it
started in:

![Walking smoothly](demos/06_smooth_move.gif)

 * Marking

    - F3 m - Mark every occurrence of the word under the cursor, or of the selection. See the shortcuts below;
    - F3 f - Find, offering the word under the cursor. With the list switched on -- **F5 c** and then `[s]` -- every line it is in comes up in a panel of its own, and Enter goes there:

![The occurrence list](demos/03_occurrences.gif)

 * Comment lines

    - Alt-Up *(normal mode/insert/visual)* - Comment the line or the selection, and uncomment it (*tcomment*);

 * Marked lines

    - F2 o *(normal mode/insert/visual)* - Put the **selected** lines in order. Asked on **F5 c** and then `[t]`: case `[s]`ensitive or `[i]`nsensitive, `[a]`scending or `[d]`escending, and whether only the **unique** lines come out -- which they do unless you say otherwise, so a line that repeats is dropped. To order by a **field** instead of by the whole line, select a block over the column the field begins at:

```
2026-03-11  Maria        V G    then F2 o  ->  in order of DATE
2024-07-02  Joao         12l F2 b 2j then F2 o  ->  in order of NAME,
2025-12-30  Ana          a block on the 13th column, where the names begin
```

    - m and M *(normal mode)* - Walk to the next marked line and to the one before. They take the `m` that sets a mark of Vim and the `M` that jumps to the middle of the screen: the bookmarks replace what marks were for, and `:mark a` still writes one from the command line; ?????? Lega cirtar a negação por n e N, caso não esteja citado em seção específica sobre busca.

**F4 b** marks the line and the mark shows in the margin, **F4 i** writes a note
on it, and **F4 l** lists every one of them:

![Marked lines](demos/05_bookmarks.gif)

F'S Shortcuts (CommandZ)!
-----

The CommandZ is a kind of "super leader" that allows an extensive keys combination to create keyboard shortcuts for features in Vim. Works pressing **F2**, **F3**, **F4** or **F5** and then another key. It is what gives GrooVim room for many shortcuts in a terminal, where the combinations a keyboard can send run out fast.

 * Features
 
  - Every F key remembers the last command IT ran, and runs it again when you press it with no key after it. F2 repeats what F2 did and F3 what F3 did -- one memory each, so a command of another group can never come out of this one;
  - Pressing the same F key twice repeats at once, without waiting for a second key that is not coming. And if you hold it down the command is replicated several times;
  - How long you have for the second key is `g:GrooVim_CommandZWait`, **one** setting, and 400ms is only what it comes set to. The moment that window closes is the moment the F key repeats -- there is no second wait;
  - A second key that arrives after the window is not thrown away: the F key has already repeated, and the key then runs as itself (a late `d` is the `d` of Vim, left waiting for what to delete). If yours keeps arriving late -- an F key at one corner of the keyboard and an arrow at the other is a long trip -- make the window longer with `let g:GrooVim_CommandZWait = 1000`; ?????? Não precisa de tantos detalhes...

<!-- shortcuts: written by tools/sync-readme.sh, do not edit by hand -->

 * **File** *(The file itself: saving it, opening another, leaving)*

    - `F2->p` - Copies to the clipboard the name or path and name of the current buffer/file *(normal mode/insert/visual)*;
    - `F2->Space` - Says the WHOLE path of the file you are on, in a balloon *(normal mode/insert/visual)*;
        - The bar at the bottom shows as much of the path as can be read and this says all of it. The balloon goes down on the cursor moving or on <Esc> , and nothing it covers is lost -- you go on typing with it up;
        - It stands in the MIDDLE of the screen, in every mode: where the file IS has nothing to do with the line you are on, and over that line it would be in the way of the text;
        - From VISUAL mode what you had selected is still selected afterwards;
    - `F2->y` - Save to disk and open in a new tab a copy of the current file *(normal mode/insert/visual)*;
    - `F5->s` - Save to disk *(normal mode/insert/visual)*;
        - In visual mode it writes the SELECTION to a file of its own;
    - `F5->e` - Save every changed file *(normal mode/insert/visual)*;
    - `F5->a` - Saves under another name and goes on editing THAT one *(normal mode/insert/visual)*;
        - Beside F5->s , which saves, and F5->e , which saves every changed file. The COPY is F2->y : that one writes the file and leaves you where you were;
    - `F5->n` - Open a new tab *(normal mode/insert/visual)*;
        - A document you have not saved yet is called new 1 , new 2 ... It is a name on SCREEN only -- the buffer stays nameless, so saving it asks you where to put it instead of writing a file called "new 1" wherever you happen to be;
        - The new tab goes to the END of the tab line, and the number is the LOWEST one nobody is using: close new 2 of new 1 , new 2 , new 3 and the next one is new 2 again;
    - `F5->q` - Close the window *(normal mode/insert/visual)*;
    - `F5->w` - Close the tab you are in *(normal mode/insert/visual)*;
        - On the LAST tab Vim refuses to close it, so what closes is the document, leaving an empty new 1 behind;
    - `F5->o` - Close all other tabs *(normal mode/insert/visual)*;
    - `F5->.` - Close every tab to the RIGHT of this one *(normal mode/insert/visual)*;
    - `F5->,` - Close every tab to the LEFT of this one *(normal mode/insert/visual)*;
        - The keys of <<> and <>> without the Shift: the comma is to the left of the dot, which is the way each one closes;
    - `F5->x` - Close everything and leave *(normal mode/insert/visual)*;
        - Every way of closing ASKS about unsaved text: save, throw away, or go back;
    - `F5->[` - Saves the current session *(normal mode/insert/visual)*;
    - `F5->]` - Brings the last saved session back *(normal mode/insert/visual)*;
        - The session saves itself when you leave and comes back when you open GrooVim with NO file. While that is on, <[> and <]> say so instead of pretending to work. Turn it off with F5->c;

 * **Edit** *(Changing the text: the transfer area, undo, the indent, the case)*

    - `F2->o` - Sorts the lines you have selected *(normal mode/insert/visual)*;
        - Asked on F5->c and then [t] : case [s] ensitive or [i] nsensitive, [a] scending or [d] escending, and whether only the UNIQUE lines come out -- which they do unless you say otherwise;
        - By a FIELD and not by the whole line: select a BLOCK with F2->b over the column the field begins at, then press this. Ordering xx-3 , yy-1 , zz-2 from the fourth column gives yy-1 , zz-2 , xx-3;
        - The selection is let go of afterwards: the lines moved, so the stretch you had marked no longer holds what you marked;
    - `F2->h` - Aligns to left *(normal mode/insert/visual)*;
    - `F2->k` - Aligns to right *(normal mode/insert/visual)*;
    - `F2->j` - Aligns to center *(normal mode/insert/visual)*;
    - `F2->Up` - Changes to uppercase *(normal mode/insert/visual)*;
    - `F2->Down` - Changes to lowercase *(normal mode/insert/visual)*;
    - `F2->t` - Title Case: the first letter of every word up, the rest down *(normal mode/insert/visual)*;
        - In normal and insert mode it is the word under the cursor; in visual mode, every word of the selection and nothing outside it. An apostrophe ENDS a word, so "don't" becomes "Don'T";
        - The three of them leave the cursor where it was;
    - `F2->c` - Copy all text in the current buffer *(normal mode/insert/visual)*;
    - `F2->q` - Start and stop recording a macro *(normal mode/insert/visual)*;
        - The same F2->q does both: the first press starts the recording and says so, the second ends it. It used to take a key of its own;
        - What is recorded goes into the register a , and F2->w runs it. The F2->q that ends the recording is cut off the register, so playing it back does not start another one;
    - `F2->w` - Run a macro *(normal mode/insert/visual)*;
    - `F2->e` - Run a macro certain number of times or repeatedly until the last line *(normal mode/insert/visual)*;
    - `F3->l` - Takes the line away, without touching the transfer area *(normal mode/insert/visual)*;
    - `F3->d` - Duplicates the current line/selection *(normal mode/insert/visual)*;
        - If in the visual mode can not be replicated;
    - `Ctrl+C` - Copies what is selected, and leaves the cursor where it was *(visual)*;
    - `Ctrl+X` - Cuts what is selected *(visual)*;
    - `Ctrl+V` - Pastes what is in the transfer area *(normal mode/insert/visual)*;
    - `Ctrl+U` - Undoes the last change *(normal mode/insert/visual)*;
    - `Ctrl+R` - Does again what was undone *(normal mode/insert/visual)*;
    - `F2->n` - Writes on several lines at once: it goes straight into insert, and the arrows take in the lines above and below *(normal mode)*;
        - The line you started on is the anchor and does not move: Down and Up move the OTHER end, so three down and one up leaves two lines taken;
        - Everything else happens in every caret, each one where IT is: what you type, the Enter that cuts its own line, the Tab that fills to the next stop of its own column, the Del , the Backspace -- and End , which is the end of each line, on lines of any length;
        - A line too short to reach the column takes the text at ITS end, so no line is left out;
        - Esc ends it;
    - `F2->m` - Marks one more place to write in, and opens for writing at once: walk to the next place and press it again, or just type *(normal mode/insert)*;
        - Beside F2->n , which takes whole lines. This one is for places that have nothing to do with each other;
        - While you are still CHOOSING nothing is written and the carets are ORANGE, the colour of typing: the plain arrows walk you to the next place and leave them where they are;
        - Esc sets the places and turns them YELLOW: from there everything you do happens in all of them -- what you type, the Enter , the Del , the Tab , the Backspace -- and everything that moves moves EVERY caret, each one from where IT is;
        - Esc again ends it. One key for both, because it is the same thing said twice: done choosing, then done writing;
    - `Shift+Up` - Goes into insert and comes out of it: from normal or from a selection it starts typing, and from insert it stops *(normal mode/insert/visual)*;
        - The pair of Shift+Down : one walks towards typing, the other towards selecting, and either walks back;
    - `Shift+Down` - Goes into the selection and comes out of it: from normal or from insert it starts selecting, and from a selection it stops *(normal mode/insert/visual)*;
    - `Alt+Up` - Comments the line, or the selection, and uncomments it *(normal mode/insert/visual)*;
    - `Ctrl+K` - Moves a line up, or every line of the selection *(normal mode/insert/visual)*;
    - `Ctrl+J` - Moves a line down, or every line of the selection *(normal mode/insert/visual)*;

 * **Select** *(Taking hold of text: all of it, a block, a word, an area)*

    - `F2->b` - Selects a BLOCK: a rectangle of the text, corner to corner *(normal mode/insert/visual)*;
    - `F3->a` - Select all text in the current buffer *(normal mode/insert/visual)*;
    - `Alt+Left` - Selects the word to the left *(normal mode/insert/visual)*;
    - `Alt+Right` - Selects the word to the right *(normal mode/insert/visual)*;
    - `Alt+Home` - Selects back to the start of the line *(normal mode/insert)*;
    - `Alt+End` - Selects on to the end of the line *(normal mode/insert)*;

 * **Search** *(Finding and replacing, and the marks a search leaves)*

    - `F3->/` - Removes search highlights *(normal mode/insert/visual)*;
    - `F3->m` - Mark every occurrence of the word under the cursor *(normal mode/insert/visual)*;
        - In visual mode it marks what is SELECTED. Pressing it again on the same word takes the marks down, and so does </> , which clears the search highlight as well;
        - It does not move the cursor and does not touch what <n> would find next: you can mark a name and go on searching for something else;
    - `F3->f` - Opens for search *(normal mode/insert/visual)*;
    - `F3->h` - Opens to replace *(normal mode/insert/visual)*;
        - The replace begins at the CURSOR. WITH confirmation, having reached the end of the file it continues from the top if occurrences were left behind, and says so. Without confirmation it does only what it says, from the cursor down. Configure it with F5->c and then [r];
    - `n` - Goes to the next of what was searched for *(normal mode)*;
    - `N` - Goes to the one before it *(normal mode)*;

 * **Move** *(Walking the text: the smooth movement, the pages, the brackets)*

    - `Alt+Shift+Up` - Walks up, smoothly, and takes the selection along *(normal mode/insert/visual)*;
    - `Alt+Shift+Down` - Walks down the same way *(normal mode/insert/visual)*;
    - `Alt+Shift+Left` - Walks left the same way *(normal mode/insert/visual)*;
    - `Alt+Shift+Right` - Walks right the same way *(normal mode/insert/visual)*;
    - `Ctrl+Alt+Up` - One step up, over areas with no text *(normal mode/insert/visual)*;
    - `Ctrl+Alt+Down` - One step down, the same *(normal mode/insert/visual)*;
    - `Ctrl+Alt+Left` - One step left, the same *(normal mode/insert/visual)*;
    - `Ctrl+Alt+Right` - One step right, the same *(normal mode/insert/visual)*;
    - `Ctrl+Left` - A word back *(normal mode/insert/visual)*;
    - `Ctrl+Right` - A word forward *(normal mode/insert/visual)*;
    - `Ctrl+B` - From one bracket to the one that closes it, and back *(normal mode/insert/visual)*;
    - `Alt+I` - To the place you were before the jump, and the one before that *(normal mode/insert/visual)*;
        - A JUMP and not a step: what a search, a G , an occurrence of the list or opening another file left behind. Walking with the arrows leaves nothing to come back to, which is what you want -- it is the jumplist of Vim;
        - It is kept per WINDOW, so each window remembers its own way back;
    - `Alt+O` - Undoes the going back, up to where you first pressed it *(normal mode/insert/visual)*;

 * **View** *(What is beside the text: the tree, the marked lines, the tabs, the help)*

    - `F4->n` - Opens/closes the file tree *(normal mode/insert/visual)*;
        - Asked for once, the tree is in EVERY tab, including the ones opened afterwards: it is a dock, like the search list and the list of marked lines. Pressing it again takes it from every tab;
        - In the tree, Enter opens the file in a TAB OF ITS OWN and leaves the one you were reading where it was. A file already open is jumped to instead of opened again, and a folder simply unfolds;
    - `F4->b` - Marks the line, or takes the mark off ( bookmark ) *(normal mode/insert/visual)*;
    - `F4->i` - Writes a note on the marked line, or changes it ( bookmark ) *(normal mode/insert/visual)*;
    - `F4->l` - Lists every marked line, or takes the list away *(normal mode/insert/visual)*;
        - In the list, Enter or a double click takes you to the line, and Del takes that mark off -- which is what the key means in a list everywhere else;
    - `F4->c` - Takes every mark off EVERY file, and asks first *(normal mode/insert/visual)*;
    - `m` - To the next marked line *(normal mode)*;
    - `M` - To the marked line before it *(normal mode)*;
    - `Ctrl+Up` - The next tab *(normal mode/insert/visual)*;
    - `Ctrl+Down` - The tab before it *(normal mode/insert/visual)*;
    - `Ctrl+Shift+Up` - Moves this tab one place to the right *(normal mode/insert/visual)*;
    - `Ctrl+Shift+Down` - Moves it one place to the left *(normal mode/insert/visual)*;
    - `F5->t` - Allows always returning to a particular tab using <Alt-Down> *(normal mode/insert/visual)*;
        - The pinned tab wears a mark on the tab line, so which one it is can be seen at any moment without pressing anything. The mark is g:GrooVim_TabPinMark , and "" takes it off;
        - Pressed ON the pinned tab it unpins; pressed anywhere else it moves the pin there. One tab at a time, because "take me back" has to mean one place;
        - The pin lives IN the tab and not in its number: carrying the tab along the line with Ctrl+Shift+Up takes the pin with it;
    - `Alt+Down` - Back to the tab set with F5->t *(normal mode/insert/visual)*;
        - Pressed ON the pinned tab it does the opposite: back to the tab you came from. With no tab pinned it is always that -- the last one you were on;
    - `Alt+,` - To the window before this one, going round *(normal mode/insert/visual)*;
        - It was Ctrl+W , which only ever went one way. And the Ctrl+W of Vim is back to being what it is everywhere else: the key every window command begins with;
    - `Alt+.` - To the next window, going round *(normal mode/insert/visual)*;
    - `F10` - Opens this menu *(normal mode/insert/visual)*;

 * **Settings** *(What GrooVim is: every setting, and reading it again)*

    - `F5->r` - Reloads the file .vimrc in all tabs *(normal mode/insert/visual)*;
    - `F5->c` - Opens the settings -- ALL of them *(normal mode/insert/visual)*;
        - It asks which of them first: [i]ndent , the width and what <Tab> puts; [v]iew , what is DRAWN and is not in the file, the language among it; [f]ile , the encoding and what ends a line IN the file you have open; [s]earch ; [r]eplace ; [g]eneral . Then it opens that screen;
        - [i] asks the width of the indent and whether <Tab> puts spaces; [v] asks what the screen SHOWS -- the guides, the symbols, the long-line mark, the word wrap;
        - On every screen, leaving an answer EMPTY keeps the value shown as "in use". At the end a summary of what you chose is held on screen until you press <Enter>;
        - [f]ile is the only one with nothing to save: an encoding belongs to the DOCUMENT and not to GrooVim, so it applies to what is open and stops there;
        - There is one door and only one. Each screen used to have a key of its own, so the letters f , h and i of this group are free again;

 * **?** *(The help of GrooVim, the help of Vim, and what this is)*

    - `F9` - Opens the help of GrooVim, and closes it *(normal mode)*;
    - `F1` - Opens the help of Vim itself *(normal mode/insert)*;
        - It is the <F1> of Vim and nothing of GrooVim: no mapping of ours stands in front of it. On a Vim file, K over a word opens the help OF THAT WORD, which is what the keywordprg of Vim is for;
        - In visual mode it does nothing -- measured, and it is Vim: <Help> is not a visual mode command;
    - `F5->/` - What GrooVim is: the version, the licence, and the Vim underneath *(normal mode/insert/visual)*;
        - It is a DIALOGUE, and every dialogue of GrooVim is answered the same way: <Left> and <Right> walk the buttons, <Enter> presses the blue one, the letter beside a label presses that one, and the mouse clicks any of them;
        - c copies what a dialogue says -- this one and every other -- which is why there is no button for it;
        - An address in a dialogue is a link: click it and it opens where you open a page. With no desktop, which is every GrooVim reached over SSH, the address goes to the clipboard instead, and the clipboard travels through the terminal to the machine you are sitting at;
        - The same F5->/ closes it, and so does the way out on it;

<!-- shortcuts: end -->

You do not have to remember any of them: **F10** puts a bar across the top with
the sections above on it, and under the one you are on, what it holds. Left and
Right walk the bar, Up and Down the list, Enter picks and Esc leaves, and an F
key jumps straight to the section that F key lives in. The mouse works
everywhere. Every line shows the keys that do it, and choosing one presses those
keys -- so the menu can never do anything the keyboard would not.

![The menu of F10](demos/02_menu.gif)

The windows that ask something look like this one, which is the About of the
"?" section. The arrows walk the buttons, Enter presses the blue one, the mouse
clicks them, `c` copies what the window says -- any window -- and an address in
it is a link:

![The About](demos/04_about.gif)

When one of them does not fire, `:GrooVimKey` says what the key really
delivered: run it, press the key, and it prints what `getchar()` handed over.

Is it working?
-----

GrooVim has a battery of tests that runs on its own, and it is not only for
whoever writes it: it is how you find out whether the GrooVim **on your machine**
does what this file says it does. ?????? Não precisa de tantos detalhes sobre os testes. Coloque mais as informações gerais e os detalhes para o HELP.

```
./tests/run.sh
```

It opens a real Vim for each case, presses real keys and reads what happened --
the occurrence list, the tabs, the replace, the session, the menu, the multiple
carets, the dialogues. **34 cases, over a thousand checks, about half a minute.**
It ends like this:

```
=== 34_dialog ===
   the About opens a dialogue                         ok   [ About GrooVim ]
   ...
-----------------------------------------------
checks: 1016   failures: 0   incomplete cases: 0
everything passed.
```

??????? Faltou citar o "linter" dos .vimrc e suas partes.

and it exits `0` only when that last line is there. A check that fails says
`FAILED` beside it, with what was read in brackets; every case also leaves its
run in `tests/results/<case>.txt` to be read afterwards.

`install.sh` takes the battery along, so after installing it is already there
and it already points at your installation: ?????? Não entendi bem o que isso quer dizer...

```
~/.groovim/tests/run.sh
```

From the project, the same three ways:

```
./tests/run.sh                      the GrooVim of this directory
./tests/run.sh ~/.groovim/.vimrc    the GrooVim that is INSTALLED, which is that file
./tests/run.sh '' 23_menu           one case, by name
```

Pointed at an installation, the few checks that read the **files of the
project** -- whether the README says what the list of shortcuts says, whether the
licence is whole, whether the task list is empty -- answer `not asked of an
installation` instead of failing over files that were never meant to be there.
Everything about behaviour is asked of both.

They write nothing into your GrooVim: each case runs in a GrooVim home of its
own, in a temporary directory that goes away with the run. The results of the
last one are left in `tests/results/`, beside them.

`docs/pitfalls.md` says what each case covers, and carries the traps that cost
the most to find.

There is a linter beside it, and a formatter for the notes in the source:

```
./tools/lint.py          says what is wrong
./tools/lint.py --fix    reflows the notes to 80 columns (85 is the limit)
```

Every part opens with the same header, and the linter and the battery both ask
for it: a banner with the name, what the file is **for** in plain prose, and a
shorter row of `$` closing it. The description carries no `Note:` -- a note
explains the code beside it, and this one explains the file: Não precisa desse nível detalhe. O "./tools/lint.py" já trata disso...

```vim
" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
" DEBUGGING (WHEN SOMETHING DOES NOT FIRE)
" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" The tools for finding OUT, which is not the same work as editing: the one that
" reports what a key really delivers, and the one that stops the code where it
" runs so that you can look at it.

" $$$$$$$$$$$$$$$$$$$$$$$
```

After changing the text of the help in `groovim/help.vim`, to see it without
restarting: `;source %`, then **F9** to close the help and **F9** again to build
it anew.

If you change a shortcut, run `./tools/sync-readme.sh` afterwards: the list of
shortcuts above is written from the same place the F9 help and the F10 menu are,
and the battery refuses to pass while this file disagrees with it.

If you liked it, consider helping the project!
-----

 * We need people to keep good documentation.
 * We need people to test.
 * Of course! We need people __to develop__ and __fix bugs__!

<a name="buildInstallVIM"></a>
How GrooVim is installed!
-----

One command, from a checkout of this repository:

```
./install.sh
groovim file.txt
```

It builds a Vim of its own, installs GrooVim into `~/.groovim`, and writes a
`groovim` command that reaches the two. Run it again whenever you like: it builds
the Vim only when the one it finds does not serve, so a second run costs nothing.

**The Vim of your system is not touched and is not used.** GrooVim is reached
through `groovim` and runs on the Vim this script builds; your `vim` stays
exactly as it was, with its own configuration and its own plugins. [Why a Vim of
its own](#ownVim).

### Editing files of the system

```
sudo groovim /etc/hosts
```

`sudo` replaces your `PATH` with the `secure_path` of the sudoers file, and a
directory of yours is not in it -- so `sudo groovim` answers "command not found"
until the command is reachable from a directory that IS. `install.sh` offers to
link it into `/usr/local/bin` for you, and you can always do it by hand:

```
sudo ln -s ~/.local/bin/groovim /usr/local/bin/groovim
```

Under `sudo`, GrooVim reads the one installation -- the same code, the same
plugins, the same saved options -- and writes what it leaves behind (the session,
the undo, the `viminfo`) into a directory of whoever is running, so nothing in
your home ends up owned by root.

<a name="clipboard"></a>
### About the clipboard ?????? Detalhes que deveriam estar no HELP....

**There is nothing to install.** On a machine with a graphical session, the Vim
`install.sh` builds talks to the clipboard itself — `+clipboard`, `+wayland`,
`+X11`, `+xterm_clipboard`. Building it is not what hands it those: the
features exist only when the machine that BUILT it had the headers of X11 or
the client library of Wayland, so on a headless server the same script produces
a Vim without them, says so at the end, and installs it anyway — because
GrooVim goes on working there.

That is what the cascade is for. GrooVim uses the first of these that answers:

1. **Wayland**, Vim talking to the compositor itself;
2. **X11**, the same way;
3. a clipboard **tool** (`wl-copy`/`wl-paste`, `xclip`, `xsel`), used only if
   one is already installed;
4. **OSC 52**, an escape sequence that carries the clipboard through the
   terminal — no X11, no Wayland, no desktop, and it crosses an SSH;
5. a file in `~/.groovim/clipboard`, which always works and lets two GrooVim
   instances share a copy.

You can see which one is in use from inside Vim with:

```
:echo v:clipmethod
:echo GrooVim_ClipReg()
```

#### When a clipboard tool is still worth installing

Vim's own Wayland method asks the compositor for the
`wlr-data-control-unstable-v1` or `ext-data-control-v1` protocol (`:h wayland`).
Most compositors offer one of them — KWin and the wlroots family do — and there
the tool is never reached: measured on KWin, `v:clipmethod` comes out `wayland`
and the `wl-copy` installed on that machine is never called.

To see whether yours offers it:

```
wayland-info | grep -E 'ext_data_control|zwlr_data_control'
```

Nothing there means Vim cannot reach the clipboard by itself. Copying still
leaves through OSC 52; **pasting from another application** is what stops
working, and a tool covers both:

```
sudo pacman -S wl-clipboard     # or: sudo apt install wl-clipboard
sudo pacman -S xclip            # X11
```

GrooVim uses it on its own once it is in your `PATH`, and `install.sh` says at
the end of the installation which of these cases you are in.

On a session with no compositor and no X — an SSH, a container — no tool works
either, and there OSC 52 is the answer. Pasting from another application is the
one thing it cannot do: use the paste of your terminal, usually
<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>V</kbd>.

<a name="ownVim"></a>
### A Vim of its own

`install.sh` builds a Vim for GrooVim alone and writes a `groovim` command
that runs it. This is the recommended way.

**GrooVim asks for Vim 9.2 or newer**, and that is what `install.sh` builds.
The clipboard uses what arrived in 9.2 — `v:clipproviders`, `clipmethod`,
`:clipreset` and the `osc52` package — so on an older Vim it is the clipboard
that stops working. Reached through the `groovim` command, GrooVim always runs
the Vim built for it, which is why nothing checks this number while you type:
it is decided at install time, and `install.sh` refuses to go on below it. ?????? Basta informar que o vim compatível é o 9.2, pois o vim depende de recursos dele...

The two do not mix:

| you type | you get |
|---|---|
| `groovim` | the Vim of GrooVim, with the `.vimrc` of GrooVim |
| `vim` | the Vim of your system, with your own configuration |

Nothing is installed over your `vim`, and GrooVim does not write into your
`~/.vimrc`.

The separation goes all the way down. GrooVim keeps its own directory,
`~/.groovim`, and that is where its plugins, its saved options, its undo
history and its `viminfo` live. Leaving `~/.vim` in the runtime path would have
undone half of it: the plugins of GrooVim would be loaded by the Vim of your
system as well -- plain `vim` opening with NERDTree because GrooVim had
installed it. ?????? Não entendi isso! Porque o vim de Sistema deveria poder abrir plugins do GrooVim (e do vim "dele"). Isto está errado! Os plugins do GrooVim pertencem só a ele!

| | `vim` | `groovim` |
|---|---|---|
| binary | the one of your distribution | `~/.local/share/groovim/bin/vim` |
| configuration | your `~/.vimrc` | the `.vimrc` of GrooVim |
| plugins | `~/.vim` | `~/.groovim` |
| `viminfo` | `~/.viminfo` | `~/.groovim/viminfo` |

That directory is not fixed. `GROOVIM_HOME` moves all of it at once:

```
GROOVIM_HOME=~/.groovim-work groovim file.txt
```

Plugins, saved options, undo history, the clipboard file and the `viminfo` all
follow. Two of those, side by side, are two GrooVim that know nothing of each
other -- one for work and one for home, with different plugins, on the same
machine.

To install:

```
./install.sh
```

It installs the build dependencies of your distribution (`pacman`, `apt-get`,
`apt`, `dnf` and `zypper` are known, and it asks before running anything as
root), fetches the newest Vim release, and configures it
with only the flags that release actually offers -- it asks `./configure
--help` instead of carrying a list that ages. ?????? Há risco de recursos necessários para o GrooVim falharem silenciosamente? E outra coisa... Não é o mais novo, é 'ultima revisão" do "9.2", correto?

Everything lands under `~/.local/share/groovim`, and `groovim` goes into
`~/.local/bin`. Then:

```
groovim file.txt
```

On the machine this was written on, the difference is the whole point of the
script: ?????? Por que se está falando de "vim do Sistema" se o usamos o nosso "próprio vim"? Não entendi o propósito disto aqui...

| | `v:clipmethod` | `has('clipboard')` |
|---|---|---|
| Vim of the distribution | `groovim` (the fallback above) | 0 |
| Vim built by the script | `wayland` | 1 |

The Vim it builds says so when it opens: ?????? Qual a necessidade destes detalhes?

```
                       GrooVim - Vi IMproved'n'GrooVIed!

                                version 9.2.1108
                            by Bram Moolenaar et al.
                  Modified by Questor the Elf (eduardolucioac)
                  Vim is open source and freely distributable
```

The first line is a one-line patch to `src/version.c`, because Vim has no flag
for it. The `Modified by` line is Vim's own `--with-modified-by`, and
`--modified-by NAME` puts your name there instead.

`./install.sh --help` lists where to put things, which `.vimrc` the
command should run, and how to build a specific version. ?????? Qual o sentido disto "which `.vimrc` the
command should run"? O GrooVim executa o seu .vimrc e suas partes. Isto é determinístico!

**Pasting from another application.** OSC 52 carries a copy *out* through the
terminal, but reading the clipboard *back* would require the terminal to answer
a query, and almost no terminal does that on purpose (a program running over
SSH could steal your clipboard). So `Ctrl-v` pastes what Vim itself copied, and
to bring in what another application copied you use your terminal's own paste,
which is `Ctrl-Shift-v` on most of them. ?????? Pelo que eu ví até então isso só é verdade (pelo menos em quase tosdos os casos) em um GrooVim executando em ssh. Parace ser informação desatualizada ou coisa assim...

If you want `Ctrl-v` to reach the system clipboard as well, install a clipboard
tool and GrooVim picks it up by itself, with no change to your `.vimrc`: ?????? Nem sempre isso vai ser necessário! Confirme isso!

```
sudo pacman -S wl-clipboard      # Wayland
sudo apt install wl-clipboard    # Wayland
sudo apt install xclip           # X11
```

GrooVim looks for `wl-copy`/`wl-paste`, then `xclip`, then `xsel`, first inside
`~/.vim/GrooVim/bin` (see `g:GrooVim_ClipBinDir`) and then in your `$PATH`. That
first directory exists so you can drop a tool by hand on a machine where you
cannot use the package manager.

**GrooVim ships no binary, on purpose.** A Linux executable is not portable: it
is built for one architecture (the Arch/CachyOS build of `wl-clipboard` is
`x86_64_v3` and needs AVX2), it is linked against one `libc`, and `wl-copy` also
needs `libwayland-client` at run time. And on a headless server there is no
compositor for it to talk to anyway: that is exactly the case OSC 52 already
covers, sending your copy across SSH to the clipboard of the machine you are
sitting at. ?????? Não há necessidade deste tipo de informação.

<a name="installGrooVim"></a>
[Install GrooVim or...] I do not want to know anything about GrooVim and want to start using it now and with all the features!
-----

```
git clone https://github.com/eduardolucioac/groovim.git
cd groovim
./install.sh
groovim file.txt
```

Tested on Debian, Ubuntu, Fedora, Rocky, Arch and openSUSE -- `./tests/distros.sh`
builds a throwaway machine of each and runs it. It needs `bash`, which every one
of them ships.

That is the whole installation. What it leaves on your machine:

| where | what |
|---|---|
| `~/.local/share/groovim` | the Vim it built, used by nothing else |
| `~/.groovim` | GrooVim itself, its plugins, its session, its saved options |
| `~/.local/bin/groovim` | the command that runs the one on the other |

The checkout is not needed afterwards -- everything is **copied**, so you can move
it or throw it away. To update, pull and run `./install.sh` again.

The three plugins GrooVim knows how to drive -- **NERDTree**, **tcomment_vim**
and **vim-move** -- go in with it, into `~/.groovim/pack/groovim/start`. Running
`./install.sh` again updates them. Use `--no-plugins` to leave them out: nothing
GrooVim promises rests on one, and a shortcut whose plugin is not there says
which one is missing instead of running. ?????? Creio que isto só faz sentido em um situação futura onde um plugin deixe de funcionar por alguma razão, de maneira que não podemos mais usa-lo. O GrooVim é realmente capaz de lidar com a ausência deles? Talvez seja o caso de travarmos a versão de cada plugin no "MAJOR.MINOR", dexando andar só o revision, se possível.

To put one in by hand, or to add one of your own, nothing else is needed -- Vim 8
and later load anything under `pack/*/start` on their own, so there is no plugin
manager involved here either: ?????? Essa informação é desnecessária se em algum lugar nesta documentação já informamos onde os plugins do GrooVim ficam.

```
mkdir -p ~/.groovim/pack/groovim/start
cd ~/.groovim/pack/groovim/start
git clone https://github.com/preservim/nerdtree.git nerdtree
```

GrooVim detects each one and enables its mapping by itself. To force a plugin
off (or on), set its variable before GrooVim is sourced: ?????? Cada plugin tem sua variável de ativação. Temos que dizer quais são, mas peso que estas são informações para estarem no HELP.

```
let g:enable_tcomment_vim = 0
let g:enable_all_plugins = 0    " ignore every plugin at once
```

Contact ?????? Substitua pelo "About" que temos em outros projetos nossos como o https://github.com/eduardolucioac/nppstub (README). Acrescente um "Table of Contents" conforme o exemplo do README citado.
-----

groovimdoc@gmail.com

Brazil-DF

<img border="0" alt="Brazil-DF" src="http://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Map_of_Brazil_with_flag.svg/180px-Map_of_Brazil_with_flag.svg.png" height="15%" width="15%"/>
