GrooVim - Vi IMproved'n'GrooVIed!
=============

<img border="0" alt="GrooVim Doc" src="http://imageshack.com/a/img829/4064/meg6.png" height="15%" width="15%"/>GrooVim Doc

What is GrooVim?
-----

**Note:** If you want to start using GrooVim immediately go to section: <a href="#installGrooVim">**"I do not want to know anything about GrooVim and want to start using it now and with all the features!"**</a>.

The GrooVim is an extensive script -- a `.vimrc` and the parts it loads -- that modifies the behavior of Vim to facilitate your work and increase your productivity aim the following objectives:
 * Allow use with just a few instructions by a public accustomed to editors/IDEs default;
 * Facilitate and accelerate widely the use, being also a integrated "UI";
 * Preserving always that possible the default behavior of Vim;
 * Enhancing Vim project as a general purpose IDE;
 * Approach Vim of "standard" text editors in what is convenient and positive and modify Vim in its negative aspects;
 * Promote Vim as a better and faster alternative to market text editors and IDEs as well as a general-purpose editor;
 * Enhancing Vim project as a free alternative (this script is __Apache License - Version 2.0__), independent and community-supported initiative;
 * Encourage the use of shell Vim;
 * Working on its own, with no plugin needed for anything it does. Plugins are welcome and each one is found by itself, but nothing GrooVim promises rests on one;
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
 * GrooVim needs NO plugin manager: Vim 8 and later load plugins placed under `pack/*/start` by themselves. GrooVim looks in `~/.groovim`, a directory of its own, so its plugins are not the plugins of the Vim of your system. __Pathogen__ is still recognized if you already use it, but it is not required;
 * GrooVim detects which plugins are installed and enables the mapping of each one by itself. Nothing that is missing causes an error, so the script works alone. You can still force any of them with "let g:enable_tcomment_vim = 0/1", or ignore all at once with "let g:enable_all_plugins = 0". Note that "enabled"/"disabled" refers for the plugin functionality mapped to it;

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
    - Alt-Right/Alt-Left (normal mode/insert/visual) - Word selection to the right/left;
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
 * `g:GrooVim_IndentExpandTab` - 1 for spaces, 0 for a real tab;

The width, whether Tab puts spaces, and whether the guides are drawn are asked on
a screen of their own, with **F5 i**. It is the "Tab Settings" of Notepad++.

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
    - Alt-Down (normal mode/insert/visual) - Returns to the tab marked with F5 t;
    - Ctrl-Up/Ctrl-Down (normal mode/insert/visual) - Go to the next/previous tab;
    - Ctrl-Shift-Up/Ctrl-Shift-Down (normal mode/insert/visual) - Carry the current tab to the next/previous place in the tab line;

 * Marking

    - F3 m - Mark every occurrence of the word under the cursor, or of the selection. See the shortcuts below;

 * Comment lines

    - Alt-Up (normal mode/insert/visual) - Comment lines using tcomment.vim;

F'S Shortcuts (CommandZ)!
-----

The CommandZ is a kind of "super leader" that allows an extensive keys combination to create keyboard shortcuts for features in Vim. Works pressing **F2**, **F3**, **F4** or **F5** and then another key.

 * Features
 
  - Allows replication of the last command just by pressing the last F used. If in a given interval a new key combination is not informed the last command is repeated;
  - If F is hold down the command is replicated several times;
  - You have a whole second to press the second key. GrooVim waits for it instead of giving up, which matters on the long trips of the keyboard -- an F key at one corner and an arrow at the other. Change it with `let g:GrooVim_CommandZWait = 1500`;

<!-- shortcuts: written by tools/sync-readme.sh, do not edit by hand -->

 * **F2** and then... *(Editing, and what acts on the FILE itself)*

    - `h` - Aligns to left *(normal mode/insert/visual)*;
    - `k` - Aligns to right *(normal mode/insert/visual)*;
    - `j` - Aligns to center *(normal mode/insert/visual)*;
    - `Up` - Changes to uppercase *(normal mode/insert/visual)*;
    - `Down` - Changes to lowercase *(normal mode/insert/visual)*;
    - `t` - Title Case: the first letter of every word up, the rest down *(normal mode/insert/visual)*;
        - Note: In normal and insert mode it is the word under the cursor; in visual mode, every word of the selection and nothing outside it. An apostrophe ENDS a word, so "don't" becomes "Don'T";
        - Note: The three of them leave the cursor where it was;
    - `c` - Copy all text in the current buffer *(normal mode/insert/visual)*;
    - `End` - Selects the word under the cursor *(normal mode/insert/visual)*;
    - `q` - Start and stop recording a macro *(normal mode/insert/visual)*;
        - Note: The same F2->q does both: the first press starts the recording and says so, the second ends it. It used to take a key of its own;
        - Note: What is recorded goes into the register a , and F2->w runs it. The F2->q that ends the recording is cut off the register, so playing it back does not start another one;
    - `w` - Run a macro *(normal mode/insert/visual)*;
    - `e` - Run a macro certain number of times or repeatedly until the last line *(normal mode/insert/visual)*;
    - `p` - Copies to the clipboard the name or path and name of the current buffer/file *(normal mode/insert/visual)*;
    - `y` - Save to disk and open in a new tab a copy of the current file *(normal mode/insert/visual)*;

 * **F3** and then... *(The editing you reach for most, and searching)*

    - `a` - Select all text in the current buffer *(normal mode/insert/visual)*;
    - `d` - Duplicates the current line/selection *(normal mode/insert/visual)*;
        - Note: If in the visual mode can not be replicated;
    - `Del` - Selects an area *(normal mode/insert)*;
    - `v` - Reselect area, the gv of Vim *(normal mode/insert)*;
    - `/` - Removes search highlights *(normal mode/insert/visual)*;
    - `m` - Mark every occurrence of the word under the cursor *(normal mode/insert/visual)*;
        - Note: In visual mode it marks what is SELECTED. Pressing it again on the same word takes the marks down, and so does </> , which clears the search highlight as well;
        - Note: It does not move the cursor and does not touch what <n> would find next: you can mark a name and go on searching for something else. It is the "Style all occurrences of token" of Notepad++;
    - `f` - Opens for search *(normal mode/insert/visual)*;
    - `h` - Opens to replace *(normal mode/insert/visual)*;
        - Note: The replace begins at the CURSOR. WITH confirmation, having reached the end of the file it continues from the top if occurrences were left behind, and says so, the way Notepad++ does. Without confirmation it does only what it says, from the cursor down. Configure it with F5->h;
    - `End` - Select and search the word under the cursor (case sensitive) *(normal mode/insert/visual)*;

 * **F4** and then... *(The installed plugins and what they do)*

    - `n` - Opens/closes the NERDTree *(normal mode/insert/visual)*;

 * **F5** and then... *(What acts on the EDITOR -- tabs, leaving -- and the settings)*

    - `s` - Save to disk *(normal mode/insert/visual)*;
        - Note: In visual mode it writes the SELECTION to a file of its own;
    - `e` - Save every changed file *(normal mode/insert/visual)*;
    - `n` - Open a new tab *(normal mode/insert/visual)*;
        - Note: A document you have not saved yet is called new 1 , new 2 ... the way Notepad++ names them. It is a name on SCREEN only -- the buffer stays nameless, so saving it asks you where to put it instead of writing a file called "new 1" wherever you happen to be;
        - Note: The new tab goes to the END of the tab line, and the number is the LOWEST one nobody is using: close new 2 of new 1 , new 2 , new 3 and the next one is new 2 again;
    - `t` - Allows always returning to a particular tab using <Alt-Down> *(normal mode/insert/visual)*;
        - Note: The same key takes the mark off, from whatever tab you press it on. One tab holds it at a time, so moving it means turning it off and then on again on the tab you want;
    - `q` - Close the window *(normal mode/insert/visual)*;
    - `w` - Close the tab you are in *(normal mode/insert/visual)*;
        - Note: On the LAST tab Vim refuses to close it, so what closes is the document, leaving the empty one Notepad++ calls new 1;
    - `o` - Close all other tabs *(normal mode/insert/visual)*;
    - `.` - Close every tab to the RIGHT of this one *(normal mode/insert/visual)*;
    - `,` - Close every tab to the LEFT of this one *(normal mode/insert/visual)*;
        - Note: The keys of <<> and <>> without the Shift: the comma is to the left of the dot, which is the way each one closes;
    - `a` - Close everything and leave *(normal mode/insert/visual)*;
        - Note: Every way of closing ASKS about unsaved text: save, throw away, or go back;
    - `v` - Opens the file .vimrc *(normal mode/insert/visual)*;
    - `r` - Reloads the file .vimrc in all tabs *(normal mode/insert/visual)*;
    - `f` - Opens to configure the search *(normal mode/insert/visual)*;
    - `h` - Opens to configure the replace *(normal mode/insert/visual)*;
        - Note: The SAME letter that runs it, one group up: F3->f searches and F5->f sets the search up; F3->h replaces and F5->h sets the replace up;
        - Note: On these two screens, leaving an answer EMPTY keeps the value shown as "now". At the end a summary of what you chose is held on screen until you press <Enter>;
    - `i` - Opens the indent settings -- the "Tab Settings" of Notepad++ *(normal mode/insert/visual)*;
    - `c` - Opens the general settings *(normal mode/insert/visual)*;
    - `[` - Saves the current session *(normal mode/insert/visual)*;
    - `]` - Brings the last saved session back *(normal mode/insert/visual)*;
        - Note: The session saves itself when you leave and comes back when you open GrooVim with NO file, the way Notepad++ does. While that is on, <[> and <]> say so instead of pretending to work. Turn it off with F5->c;

<!-- shortcuts: end -->

You do not have to remember any of them: **F10** puts a bar across the top with
the four groups on it, and under the one you are on, what it holds. Left and
Right walk the bar, Up and Down the list, Enter picks and Esc leaves. The mouse
works everywhere. Every line shows the keys that do it, and choosing one presses
those keys -- so the menu can never do anything the keyboard would not.

When one of them does not fire, `:GrooVimKey` says what the key really
delivered: run it, press the key, and it prints what `getchar()` handed over.

Is it working?
-----

GrooVim has a battery of tests that runs on its own:

```
./tests/run.sh
```

It opens a real Vim for each case, presses real keys and reads what happened --
the occurrence list, the tabs, the replace, the session, the menu. It exits `0`
only if every case reaches its end and no check fails, and it takes about half a
minute. `docs/pitfalls.md` says what each case covers, and carries the traps that
cost the most to find.

If you change a shortcut, run `./tools/sync-readme.sh` afterwards: the list of
shortcuts above is written from the same place the F9 help and the F10 menu are,
and the battery refuses to pass while this file disagrees with it.

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
 
 * TODO: Try to use wombat256 color scheme! By Questor
    https://raw.githubusercontent.com/Lucidyan/vpyde3/master/data/wombat256mod.vim

 * ToDo: On "copy file" ("GrooVim_SaveACopy()") functionality suggest a name to new file automatically! By Questor

 * ToDo: Provide the search "for whole word only" ("GrooVim_SearchWithMyOptions()")! By Questor

 * ToDo: Create a shortcut to moving between matching braces! By Questor

 * ToDo: Create a configuration scheme according to the type of file. This scheme must be in the end of ".vimrc" to work properly! By Questor

 * ToDo: Using python scripts to substitute functions that use the terminal/shell to improve the operation and ease of maintenance! (EXAMINE THIS POSSIBILITY) By Questor

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

 * ToDo: Mark LINES and navigate between them (bookmarks). Marking every occurrence of a WORD is done, with "F3 m"! By Questor

 * ToDo: Create "expand/collapse an area" ("" TEXT AREA {{{ }}}") features and shorcuts! By Questor

 * ToDo: Test GrooVim for multiple distributions! By Questor

 * ToDo: Delete and close current file/Rename the current file and open it with the new name! (EXAMINE THIS POSSIBILITY/NOT A PRIORITY) By Questor

 * ToDo: Treat situations where "xset -q | grep "Caps Lock:   on"" command is not possible to check the state of capslock key! By Questor

 * ToDo: Create a feature to user choose between predefined syntax options... Example... Use 0 for "set syntax=html", Use one 1 to "set syntax=python"... and so on! By Questor

 * ToDo: Create shortcuts for navigation in search results for maintaining Vim insert mode! By Questor

 * ToDo: Map the mouse wheel to scroll up or down the screen during the replace (use ^E and ^D)! By Questor

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
register. Nothing to install.

If you would rather have the real thing, see below.

You can see which one is in use from inside Vim with:

```
:echo v:clipmethod
:echo GrooVim_ClipReg()
```

<a name="ownVim"></a>
### A Vim of its own

`install.sh` builds a Vim for GrooVim alone and writes a `groovim` command
that runs it. This is the recommended way.

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
installed it.

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

It installs the build dependencies of your distribution (Arch, Debian, Fedora,
openSUSE, Alpine, Void and Gentoo families are known, and it asks before
running anything as root), fetches the newest Vim release, and configures it
with only the flags that release actually offers -- it asks `./configure
--help` instead of carrying a list that ages.

Everything lands under `~/.local/share/groovim`, and `groovim` goes into
`~/.local/bin`. Then:

```
groovim file.txt
```

On the machine this was written on, the difference is the whole point of the
script:

| | `v:clipmethod` | `has('clipboard')` |
|---|---|---|
| Vim of the distribution | `groovim` (the fallback above) | 0 |
| Vim built by the script | `wayland` | 1 |

The Vim it builds says so when it opens:

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
command should run, and how to build a specific version.

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

```
git clone https://github.com/eduardolucioac/groovim.git
cd groovim
./install.sh
groovim file.txt
```

Tested on Debian, Ubuntu, Fedora, Rocky, Arch, openSUSE and a CentOS 7 --
`./tests/distros.sh` builds a throwaway machine of each and runs it. It needs
`bash`, which every one of them ships.

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
which one is missing instead of running.

To put one in by hand, or to add one of your own, nothing else is needed -- Vim 8
and later load anything under `pack/*/start` on their own, so there is no plugin
manager involved here either:

```
mkdir -p ~/.groovim/pack/groovim/start
cd ~/.groovim/pack/groovim/start
git clone https://github.com/preservim/nerdtree.git nerdtree
```

GrooVim detects each one and enables its mapping by itself. To force a plugin
off (or on), set its variable before GrooVim is sourced:

```
let g:enable_tcomment_vim = 0
let g:enable_all_plugins = 0    " ignore every plugin at once
```

**Note:** If you already use **Pathogen** and keep your plugins in
`~/.groovim/bundle`, that keeps working: GrooVim looks in both places and calls
Pathogen only when it is actually installed.

Contact
-----

groovimdoc@gmail.com

Brazil-DF

<img border="0" alt="Brazil-DF" src="http://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Map_of_Brazil_with_flag.svg/180px-Map_of_Brazil_with_flag.svg.png" height="15%" width="15%"/>
