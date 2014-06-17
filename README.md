GrooVim - Vi IMproved'n'GrooVIed!
=============

<img border="0" alt="GrooVim Doc" src="http://imageshack.com/a/img829/4064/meg6.png" height="15%" width="15%">GrooVim Doc

What is GrooVim?
-----

The GrooVim is an extensive script (__it's a .vimrc__) that modifies the behavior of Vim to facilitate your work and increase your productivity aim the following objectives:
 * Allow use with just a few instructions by a public accustomed to editors/IDEs default;
 * Facilitate and accelerate widely the use, being also a integrated "UI";
 * Preserving always that possible the default behavior of Vim;
 * Enhancing Vim project as a general purpose IDE;
 * Approach Vim of "standard" text editors in what is convenient and positive and modify Vim in its negative aspects;
 * Promote Vim as a better and faster alternative to market text editors and IDEs as well as a general-purpose editor;
 * Enhancing Vim project as a free alternative (this script is __Apache License - Version 2.0__), independent and community-supported initiative;
 * Encourage the use of shell Vim;
 * Being a "all in one" package, ie, depend only on the contents of the file .vimrc to work (no plugin scenario);
 * Being a script for all types of terminals;

Before you start with the GrooVim!
-----

IMPORTANT_I! If you do not know how Vim works, please open a terminal, run __vimtutor__ and do the exercises (takes 25 to 30 minutes). Then continue reading this document! IT IS VERY IMPORTANT TO KNOW THE DEFAULT VIM IN ITS BASIC, SO YOU CAN USE IT BETTER AND CONTRIBUTE WITH NEW FEATURES!

IMPORTANT_II! The Vim is a powerful general purpose text editor/IDE. Keep in mind that the GrooVim was made possible through its great API (script) and wide versatility!

IMPORTANT_III! Certain terminal emulators limits the possibility of Vim and GrooVim. Therefore, we recommend that for your "all day" Vim use a terminal that allows more possibilities and features!

 * The GrooVim was designed to work with a wide range of keyboard shortcuts. Eventually, such shortcuts may present conflicts with shortcuts from your OS. This is normal and if conflicts occurs we recommend that you modify the shortcuts of your OS, because the terminal environment does not allow a large number of combinations to form shortcuts;
 * To further facilitate your life and increase productivity we recommend you make a mapping in your terminal to navigate between tabs using Shift-Left/Shift-Right. These two keyboard shortcuts (Shift-Left/Shift-Right) are not mapped in GrooVim to that you use in the way mentioned;
    - Note: KDE desktop environment already works in that way with its terminal;
 * The GrooVim was designed to work with tabs;
 * The GrooVim was designed to work without constant use of 'virtualedit' ("set virtualedit=all") to facilitate cursor navigation "despising invalid areas" (or without character) when convenient;
 * The GrooVim was designed to work with the best plugins;
    - We recommend install ALL the following plugins:
       - NERDTree
          https://github.com/scrooloose/nerdtree 
       - tcomment
          https://github.com/tomtom/tcomment_vim 
       - move
          https://github.com/matze/vim-move 
 * When using plugins __Pathogen__ plugin needs to be intalled (https://github.com/tpope/vim-pathogen);
 * By default GrooVim not have any enabled plugin (see "let g:enable_all_plugins = 0"). You can also enable the plugins individually;

The GrooVim solves the following "problems"!
-----

 * Ctrl-Left/Ctrl-Right (normal mode/insert/visual) - Navigate by words in a conventional and practical way;
 * Tab (normal mode/visual)- Indent in a conventional and practical way;
 * Enter (normal mode/visual) - Use in a conventional and practical way;
 * Backspace (normal mode/visual) - Use in a conventional and practical way;
 * Del (normal mode/visual) - Use in a conventional and practical way;
 * Space (normal mode/visual) - Use in a conventional and practical way;
 * In the alternation between modes the cursor stays correctly positioned;
 * Use default clipboard in a correct and conventional way (copy, cut and paste);
 * Replace , x (remove) and d (delete) preserving the clipboard;
 * PageDown/PageUp - With navigation across the screen (invalid areas);
 * MouseScrollDown/MouseScrollUp - With navigation across the screen (invalid areas);
 * MouseClick (normal mode) - Across the screen (invalid areas);
 * Just a Ctrl-w switches between windows;
 * And much more!

Some editor features!
-----

 * Switching between modes:
    - Alt-Up (normal mode/insert/visual) - Enter or exit the insert mode;
    - Alt-Down (normal mode/insert/visual) - Enter or exit the visual mode;

 * Text selection:
    - Alt-Right/Alt-Left (normal mode/insert) - Word selection to the right/left;
    - Alt-End/Alt-Home (normal mode/insert) - Select text on the line until the end/beginning from the current point;

 * Conventional text editors commands:
    - Ctrl-c (visual mode) - Copy to clipboard;
    - Ctrl-v (normal mode/insert/visual) - Paste from clipboard;
    - Ctrl-x (visual mode) - Cut to the clipboard;
    - Ctrl-u (normal mode/insert/visual) - Undo;
    - Ctrl-r (normal mode/insert/visual) - Redo;

 * Plugins:
    - move-vim; 
        - Ctrl-j/Ctrl-k (normal mode/insert/visual) - Move line or selection up/down;

Relevant changes in the default Vim behavior!
-----

 - Use Ctrl+b to enable visual block mode (not Ctrl+v);
 - When changes from visual mode to insert mode the cursor do not move;
 - Use default OS clipboard;
 - The "insert" (includes typed text) and "paste" from the same cursor position;

Script features!
-----

 * Navigation

    - Shift-Alt-Arrows (normal mode/insert/visual) - Smooth navigation across the screen with long movements (invalid areas);
    - Ctrl-Alt-Arrows (normal mode/insert/visual) - Navigation with arrows across the screen (invalid areas) using short movements;
    - Alt-Down (normal mode/insert/visual) - Returns to the previous tab;
    - Ctrl-Down/Ctrl-Up (normal mode/insert/visual) - Access tabs on left/right;

 * Word selection

    - Alt-Right/Alt-Left (normal mode/insert/visual) - Word selection to the right/left;
    - 2-leftmouse (normal mode/insert) - (Double click the mouse on a word then press z letter) All words with the same content will be highlighted;

 * Comment lines

    - Alt-Up (normal mode/insert/visual) - Comment lines using tcomment.vim;

F'S Shortcuts (CommandZ)!
-----

The  CommandZ  is a kind of "super leader" that allows an extensive keys combination to create keyboard shortcuts for features in Vim. Works pressing F2, F3 or F4 keys and then another key.

 * Features
 
  - Allows replication of the last command just by pressing the last F used. If in a given interval a new key combination is not informed the last command is repeated;
  - If F is hold down the command is replicated several times;

 * F2 and then...
    - Note: Preferably for editing commands;
       - h - Aligns to left (normal mode/insert/visual);
       - k - Aligns to right (normal mode/insert/visual);
       - j - Aligns to center (normal mode/insert/visual);
       - p - Changes to uppercase (normal mode/insert/visual);
       - n - Changes to lowercase (normal mode/insert/visual);
       - c - Copy all text in the current buffer (normal mode/insert/visual);
       - a - Select all text in the current buffer (normal mode/insert/visual);
       - d - Duplicates the current line/selection (normal mode/insert/visual);
              - Note: If in the visual mode can not be replicated;
       - q - Record a macro (normal mode/insert/visual);
       - w - Run a macro (normal mode/insert/visual);
       - e - Run a macro certain number of times or repeatedly until the last line (normal mode/insert/visual);
       - d - Selects the word under the cursor (normal mode/insert/visual);
       - l - Selects an area (normal mode/insert);

 * F3 and then...
    - Note: Preferably for commands that "traditionally" involve Ctrl in other editors;
       - n - Open a new tab (normal mode/insert/visual);
       - c - Close current tab (normal mode/insert/visual);
       - o - Close all other tabs (normal mode/insert/visual);
       - v - Opens the file .vimrc (normal mode/insert/visual);
       - r - Reloads the file .vimrc in all tabs (normal mode/insert/visual);
       - / - Removes search highlights (normal mode/insert/visual);
       - s - Save to disk (normal mode/insert/visual);
       - f - Opens to search (normal mode/insert/visual);
       - d - Opens to configure the search (normal mode/insert/visual);
       - j - Opens to replace (normal mode/insert/visual);
       - h - Opens to configure the replace (normal mode/insert/visual);
       - [ - Saves the current session (normal mode/insert/visual);
       - ] - Reloads the last saved session (normal mode/insert/visual);
       - p - Copies to the clipboard the name or path and name of the current buffer/file (normal mode/insert/visual);
       - t - Allows always returning to a particular tab using Alt-Down (normal mode/insert/visual);
       - d - Select and search (case sensitive) the word under the cursor (normal mode/insert/visual);
       - l - Reselect area (normal mode/insert/visual);
       - y - Save to disk and open in a new tab a copy of the current file (normal mode/insert/visual);

 * F4 and then...
    - Note: Preferably to trigger the installed plugins and their functionalities;
       - n - Opens/closes the NERDTree (normal mode/insert/visual);

If you liked it, consider helping the project!
-----

 * We need people to fix the "portuguenglish" in all documentation!
 * We need people to test!
 * Of course! We need people __to develop__ and __fix bugs__!

Task List/Bugs List!
-----

 * ToDo: On "copy file" ("GrooVim_SaveACopy()") functionality suggest a name to new file automatically! By Questor

 * Bug: The "F3+c" ("GrooVim_CommandZ()") functionality must be disabled for NerdTree (interface problems)! By Questor

 * ToDo: Provide the search "for whole word only" ("GrooVim_SearchWithMyOptions()")! By Questor

 * Bug: "GrooVim_GroovyMove()" not working (for *.py files) in insert/visual mode (loss "set virtualedit=all")! (PRIORITY) By Questor

 * ToDo: Create a configuration scheme according to the type of file. This scheme must be in the end of ".vimrc" to work properly! By Questor

 * ToDo: Using python scripts to substitute functions that use the terminal/shell to improve the operation and ease of maintenance! (EXAMINE THIS POSSIBILITY) By Questor

 * ToDo: The "GrooVim_GroovyMove()" do not work with "visual block mode"! (PRIORITY) By Questor

 * ToDo: Improve syntax and lexers (mainly for python)! By Questor

 * ToDo: Try a solution to "set expandtab" X "set listchars=tab:▒░,trail:·" problem! How we can "listchars" spaces as "tabs"? By Questor

 * ToDo: Create configurable settings for each distribution (extendable to help)! By Questor

 * ToDo: Create OS context shortcuts (second button click context) and use double-click to open any file! This can be done using a script that works according with user distro/UI! By Questor

 * Bug: "Enter" (carriage return) on normal mode fails for certain types of files ("GrooVim_NormalEnterOnNormalMode()")! By Questor

 * ToDo: Show cursor position (blink a "scope")! (NOT A PRIORITY) By Questor

 * ToDo: Improve the presentation of the tabs flaps. Using a similar idea to a scroll bar? (EXAMINE THIS POSSIBILITY) By Questor

 * ToDo: Allow all script features to work with "virtualedit=all"? (EXAMINE THIS POSSIBILITY/NOT A PRIORITY) By Questor

 * Bug: Treating problem of slowness with long lines! By Questor

 * ToDo: Create verification of operating system for commands (shell/"system()" calls) that depend on it! By Questor

 * ToDo: Create command that completely disables GrooVim. This command needs to write this option to disk to disable GrooVim at Vim startup (see "GrooVim_OptsUpdate()")! By Questor

 * ToDo: Review the commands that dependents of "learderkey" combinations ("GrooVim_CommandZ()")! (NOT A PRIORITY) By Questor

 * ToDo: Mark lines and navigate to these (bookmarks). Use "mark.vim"? By Questor

 * ToDo: Create "expand/collapse an area" ("" TEXT AREA {{{ }}}") features and shorcuts! By Questor

 * ToDo: Test GrooVim for multiple distributions! By Questor

Contact
-----

groovimdoc@gmail.com
