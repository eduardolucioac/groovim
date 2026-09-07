GrooVim - Vi IMproved'n'GrooVIed!
=============

<img border="0" alt="GrooVim Doc" src="http://imageshack.com/a/img829/4064/meg6.png" height="15%" width="15%"/>GrooVim Doc

What is GrooVim?
-----

**Note:** If you want to start using GrooVim immediately go to section: <a href="#installGrooVim">**"I do not want to know anything about GrooVim and want to start using it now and with all the features!"**</a>.

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

IMPORTANT_I! If you do not know how Vim works, please open a terminal, run __vimtutor__ and do the exercises (takes 25 to 30 minutes). IT IS VERY IMPORTANT TO KNOW THE DEFAULT VIM IN ITS BASIC, SO YOU CAN USE IT BETTER AND CONTRIBUTE WITH NEW FEATURES!

IMPORTANT_II! The Vim is a powerful general purpose text editor/IDE. Keep in mind that the GrooVim was made possible through its great API (script) and wide versatility!

IMPORTANT_III! Certain terminal emulators limits the possibility of Vim and GrooVim. Therefore, we recommend that for your "all day" Vim use a terminal that allows more possibilities and features!

 * The GrooVim was designed to work with a wide range of keyboard shortcuts. Eventually, such shortcuts may present conflicts with shortcuts from your OS. This is normal and if conflicts occurs we recommend that you modify the shortcuts of your OS, because the terminal environment does not allow a large number of combinations to form shortcuts;
 * To further facilitate your life and increase productivity we recommend you make a mapping in your terminal to navigate between tabs using Shift-Left/Shift-Right. These two keyboard shortcuts (Shift-Left/Shift-Right) are not mapped in GrooVim to that you use in the way mentioned;
    - Note: KDE desktop environment already works in that way with its terminal;
 * The GrooVim was designed to work with tabs;
 * The GrooVim was designed to work without constant use of 'virtualedit' ("set virtualedit=all") to facilitate cursor navigation "despising invalid areas" (or without character) when convenient;
 * The GrooVim was designed to work with the best plugins;
 * GrooVim needs NO plugin manager: Vim 8 and later load plugins placed under `~/.vim/pack/*/start` by themselves. __Pathogen__ is still recognized if you already use it, but it is not required;
 * GrooVim detects which plugins are installed and enables the mapping of each one by itself. Nothing that is missing causes an error, so the script works alone. You can still force any of them with "let g:enable_tcomment_vim = 0/1", or ignore all at once with "let g:enable_all_plugins = 0". Note that "enabled"/"disabled" refers for the plugin functionality mapped to it;
 * The debug plugin support ("F4" and then "d") is disabled by default ("let g:enable_debugger_vim = 0") because no debug plugin is installed by the instructions below;

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
    - Shift-Up (normal mode/insert/visual) - Enter or exit the insert mode;
    - Shift-Down (normal mode/insert/visual) - Enter or exit the visual mode;

 * Text selection:
    - Alt-Right/Alt-Left (normal mode/insert) - Word selection to the right/left;
    - Alt-End/Alt-Home (normal mode/insert) - Select text on the line until the end/beginning from the current point;

 * Conventional text editors commands:
    - Ctrl-c (visual mode) - Copy to clipboard;
    - Ctrl-v (normal mode/insert/visual) - Paste from clipboard;
        - Note: Copying out always works. To PASTE what another application copied you need a clipboard tool installed, or your terminal own paste (usually Ctrl-Shift-v). See <a href="#clipboard">**"About the clipboard"**</a>;
    - Ctrl-x (visual mode) - Cut to the clipboard;
    - Ctrl-u (normal mode/insert/visual) - Undo;
    - Ctrl-r (normal mode/insert/visual) - Redo;

 * Plugins:
    - move-vim; 
        - Ctrl-j/Ctrl-k (normal mode/insert/visual) - Move line or selection up/down;

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

Only the file types you list are touched. Vim already ships file type plugins that
know what they are doing, and some of them are not a matter of taste: **make** needs
a REAL tab on its recipe lines and **go** is written with tabs by gofmt. Those are
left alone.

The guides read the width from the standard Vim options when drawing, so they follow
a `modeline`, a file type plugin or a `:set shiftwidth=` you type.

Relevant changes in the default Vim behavior!
-----

 - Use Ctrl+b to enable visual block mode (not Ctrl+v);
 - When changes from visual mode to insert mode the cursor do not move;
 - Use the system clipboard whenever it can be reached, see <a href="#clipboard">**"About the clipboard"**</a>;
 - The "insert" (includes typed text) and "paste" from the same cursor position;

Script features!
-----

 * Navigation

    - Shift-Alt-Arrows (normal mode/insert/visual) - Smooth navigation across the screen (including invalid areas) with long movements;
    - Ctrl-Alt-Arrows (normal mode/insert/visual) - Navigation with arrows across the screen (including invalid areas) using short movements;
    - Alt-Down (normal mode/insert/visual) - Returns to the previous tab;
    - Ctrl-Down/Ctrl-Up (normal mode/insert/visual) - Access tabs on left/right;

 * Word selection

    - Alt-Right/Alt-Left (normal mode/insert/visual) - Word selection to the right/left;
    - 2-leftmouse (normal mode/insert) - (Double click the mouse on a word then press z letter) All words with the same content will be highlighted;

 * Comment lines

    - Alt-Up (normal mode/insert/visual) - Comment lines using tcomment.vim;

F'S Shortcuts (CommandZ)!
-----

The CommandZ is a kind of "super leader" that allows an extensive keys combination to create keyboard shortcuts for features in Vim. Works pressing F2, F3 or F4 keys and then another key.

 * Features
 
  - Allows replication of the last command just by pressing the last F used. If in a given interval a new key combination is not informed the last command is repeated;
  - If F is hold down the command is replicated several times;

 * F2 and then...
    - Note: Preferably for editing commands;
       - h - Aligns to left (normal mode/insert/visual);
       - k - Aligns to right (normal mode/insert/visual);
       - j - Aligns to center (normal mode/insert/visual);
       - Up - Changes to uppercase (normal mode/insert/visual);
       - Down - Changes to lowercase (normal mode/insert/visual);
       - c - Copy all text in the current buffer (normal mode/insert/visual);
       - a - Select all text in the current buffer (normal mode/insert/visual);
       - d - Duplicates the current line/selection (normal mode/insert/visual);
              - Note: If in the visual mode can not be replicated;
       - q - Record a macro (normal mode/insert/visual);
       - w - Run a macro (normal mode/insert/visual);
       - e - Run a macro certain number of times or repeatedly until the last line (normal mode/insert/visual);
       - d - Selects the word under the cursor (normal mode/insert/visual);
       - Del - Selects an area (normal mode/insert);

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
       - h - Opens to replace (normal mode/insert/visual). The replace begins at the CURSOR; with confirmation it continues from the top of the file if occurrences were left behind, and says so;
       - j - Opens to configure the replace (normal mode/insert/visual);
       - [ - Saves the current session (normal mode/insert/visual);
       - ] - Reloads the last saved session (normal mode/insert/visual);
       - p - Copies to the clipboard the name or path and name of the current buffer/file (normal mode/insert/visual);
       - t - Allows always returning to a particular tab using Alt-Down (normal mode/insert/visual);
       - d - Select and search (case sensitive) the word under the cursor (normal mode/insert/visual);
       - Del - Reselect area (normal mode/insert/visual);
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

 * TODO: Open file passing path (use F's shortcut)! By Questor
 
 * TODO: "Power Search" open in vim from a vim shortcut the results off a "find" command! By Questor
 
 * TODO: In "visual mode" "End" key must go "have to go" one column less! By Questor
 
 * TODO: Create instalation scripts for RHEL, Debian and Arch or based on these! By Questor
 
 * TODO: Try to use wombat256 color scheme! By Questor
    https://raw.githubusercontent.com/Lucidyan/vpyde3/master/data/wombat256mod.vim

 * ToDo: On "copy file" ("GrooVim_SaveACopy()") functionality suggest a name to new file automatically! By Questor

 * Bug: The "F3+c" ("GrooVim_CommandZ()") functionality must be disabled for NerdTree (interface problems)! By Questor

 * ToDo: Provide the search "for whole word only" ("GrooVim_SearchWithMyOptions()")! By Questor

 * Bug: "GrooVim_GroovyMove()" not working (for *.py files) in insert/visual mode (loss "set virtualedit=all")! (PRIORITY) By Questor

 * ToDo: Create a shortcut to moving between matching braces! By Questor

 * ToDo: Create a configuration scheme according to the type of file. This scheme must be in the end of ".vimrc" to work properly! By Questor

 * ToDo: Using python scripts to substitute functions that use the terminal/shell to improve the operation and ease of maintenance! (EXAMINE THIS POSSIBILITY) By Questor

 * ToDo: The "GrooVim_GroovyMove()" do not work with "visual block mode"! (PRIORITY) By Questor

 * ToDo: Improve syntax and lexers (mainly for python)! By Questor

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

 * ToDo: Get the number of occurrences of a particular text (optional case sensitive)! By Questor

 * ToDo: Delete and close current file/Rename the current file and open it with the new name! (EXAMINE THIS POSSIBILITY/NOT A PRIORITY) By Questor

 * ToDo: Treat situations where "xset -q | grep "Caps Lock:   on"" command is not possible to check the state of capslock key! By Questor

 * ToDo: Create a feature to user choose between predefined syntax options... Example... Use 0 for "set syntax=html", Use one 1 to "set syntax=python"... and so on! By Questor

 * ToDo: When we do text replace in multiple tabs the GrooVim makes replacement of the first occurrence only on each tab! By Questor

 * ToDo: Create shortcuts for navigation in search results for maintaining Vim insert mode! By Questor

 * ToDo: Map the mouse wheel to scroll up or down the screen during the replace (use ^E and ^D)! By Questor

<a name="buildInstallVIM"></a>
How to install Vim!
-----

GrooVim needs **Vim 7.4 or newer**, and it is developed and tested against the
current Vim (9.x). Every distribution ships something recent enough today, so
building from source is no longer necessary:

[Arch/Manjaro/CachyOS]
```
sudo pacman -S vim
```
[RHEL/CentOS/Fedora]
```
sudo dnf install vim-enhanced
```
[Ubuntu/Debian]
```
sudo apt install vim
```

<a name="clipboard"></a>
### About the clipboard

Some distributions ship Vim built *without*
clipboard support. You can check yours with:

```
vim --version | grep -o '[+-]clipboard'
```

If it says `-clipboard`, **you do not need to do anything**: GrooVim falls back
by itself, in this order, to OSC 52 (which carries the clipboard through the
terminal itself, and works over SSH and on a machine with no graphical session
at all), then to a file shared between Vim instances, then to the unnamed
register. Nothing to install. If you would rather have the native clipboard,
install a Vim built with it (on Arch based systems that is the `gvim` package,
which provides the same `/usr/bin/vim`).

You can see which one is in use from inside Vim with:

```
:echo v:clipmethod
:echo GrooVim_ClipReg()
```

**Pasting from another application.** OSC 52 carries a copy *out* through the
terminal, but reading the clipboard *back* would require the terminal to answer
a query, and almost no terminal does that on purpose (a program running over
SSH could steal your clipboard). So `Ctrl-v` pastes what Vim itself copied, and
to bring in what another application copied you use your terminal's own paste,
which is `Ctrl-Shift-v` on most of them.

If you want `Ctrl-v` to reach the system clipboard as well, install a clipboard
tool and GrooVim picks it up by itself, with no change to your `.vimrc`:

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
sitting at.

<a name="installGrooVim"></a>
[Install GrooVim or...] I do not want to know anything about GrooVim and want to start using it now and with all the features!
-----

**GrooVim is a single file and needs nothing else.** No plugin manager, no
external package. Copy it and you are done:

```
git clone https://github.com/eduardolucioac/groovim.git ~/Downloads/groovim
cp ~/Downloads/groovim/.vimrc ~/.vimrc
```

That is the whole installation. Whatever plugin you do not have simply stays
quiet, exactly as the "all in one" objective promises.

- **Optional:** the plugins that GrooVim knows how to drive.

Vim 8 and later load anything under `~/.vim/pack/*/start` on their own, so
there is no plugin manager involved here either:

```
mkdir -p ~/.vim/pack/groovim/start
cd ~/.vim/pack/groovim/start
git clone https://github.com/preservim/nerdtree.git nerdtree
git clone https://github.com/tomtom/tcomment_vim.git tcomment_vim
git clone https://github.com/matze/vim-move.git vim-move
```

GrooVim detects each one and enables its mapping by itself. To force a plugin
off (or on), set its variable before GrooVim is sourced:

```
let g:enable_tcomment_vim = 0
let g:enable_all_plugins = 0    " ignore every plugin at once
```

**Note:** If you already use **Pathogen** and keep your plugins in
`~/.vim/bundle`, that keeps working: GrooVim looks in both places and calls
Pathogen only when it is actually installed.


Contact
-----

groovimdoc@gmail.com

Brazil-DF

<img border="0" alt="Brazil-DF" src="http://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Map_of_Brazil_with_flag.svg/180px-Map_of_Brazil_with_flag.svg.png" height="15%" width="15%"/>
