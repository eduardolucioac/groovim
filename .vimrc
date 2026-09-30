" =D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D
" GrooVim =D - Vi IMproved'n'GrooVIed!
" GrooVim =D - Vi IMproved'n'GrooVIed!
" GrooVim =D - Vi IMproved'n'GrooVIed!
" =D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D

" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
" LICENSE (GNU General Public License v3.0 or later)
" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" GrooVim — a Vim of its own, remodelled for a simpler, smarter experience.
"
" Copyright (C) 2014-2026 Eduardo Lucio Amorim Costa
"
" This program is free software: you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation, either version 3 of the License, or
" (at your option) any later version.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program.  If not, see <https://www.gnu.org/licenses/>.
"
" Eduardo Lúcio
" 2014

" Note: The licence itself lives in the file "LICENSE", and what a source
" file carries is this: the notice the GPL asks you to attach, from
" "How to Apply These Terms to Your New Programs" at its end.

" Note: The version, and the ONE place it is written.
let g:grooVimVersion = "v3.0.0b"

" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
" TASK LIST/BUGS LIST
" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" <EMPTY>

" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
" MAIN
" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
" WHAT HAS TO BE SET BEFORE ANYTHING ELSE
" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" Note: These two are here and not in the part about how Vim behaves, which is
" where they would belong by subject: what decides it is WHEN they have to run,
" and both have to run before anything at all -- before the parts, and before
" the lines of this file that come after them.

" Note: Use vim settings, rather then vi settings - much better. This must be
" first, because it changes other options as a side effect.
set nocompatible

" Note: GrooVim keeps a directory of its own, and does NOT share the one of the
" Vim of your system.
"
" Reached through the "groovim" command, GrooVim has its own Vim and its
" own ".vimrc" and its own plugins.
"
" The shape of the path is the one Vim builds by itself, with "~/.vim"
" swapped for ours.
"
" To keep it somewhere else, set "GROOVIM_HOME" in the environment:
"
"     GROOVIM_HOME=/opt/groovim-do-trabalho groovim file.txt
"
" and everything moves at once -- plugins, saved options, undo history, the
" clipboard file and the "viminfo". Two of those, side by side, are two GrooVim
" that know nothing of each other.
"
" The Vim GrooVim asks for, said once and here.

" Note: Vim 9.2 version is what "install.sh" builds, and GrooVim is reached
" only through the "groovim" command, which runs that Vim -- so it is what
" GrooVim gets.
"
" The clipboard depends on what arrived in it: "v:clipproviders", "clipmethod",
" ":clipreset" and the "osc52" package that ships with it.

" Note: The encoding, and it has to be HERE: before a single part is read.
"
" Vim resolves a "\uXXXX" in a double-quoted string to the bytes of whatever
" 'encoding' is at the moment it reads the line, and it picks that from the
" locale when it starts. On a machine with no UTF-8 locale -- a headless
" server, a container, a sudo that strips LANG -- it starts in latin1, and the
" "\u250A" of the indent guide collapsed into a single byte. Vim then refused
" it: "E1512: Wrong character width for field leadmultispace", and the guides
" were silently gone. Worse, with no listchars of its own the window fell back
" to the default of Vim, which draws a "$" at the end of every line.

" It is set again, along with the file encodings, in the "usability" part. This
" is the one that has to come first.
set encoding=utf-8
set termencoding=utf-8

" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
" WHERE GrooVim LIVES, AND THE PARTS IT LOADS
" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" Note: The environment and not only "g:GrooVim_Home", because with "-u" there
" is no file of yours running before this one: overriding the variable would
" mean typing "--cmd" on every call. It is the same shape as "GROOVIM_VIM" and
" "GROOVIM_VIMRC", which the "groovim" command already reads.
let g:GrooVim_Home = get(g:, "GrooVim_Home",
 \ $GROOVIM_HOME != "" ? expand($GROOVIM_HOME) : expand("~/.groovim"))

" Vim 8 and later load everything under "pack/*/start" on their own, so NO
" plugin manager is needed. For GrooVim that is "~/.groovim/pack/*/start", set
" above: its plugins are its own, and not the ones of the Vim of your system.

"  Note: Where THIS file is, so that GrooVim can open and reload itself.
"
" Not "$MYVIMRC": Vim only fills that in when it finds the vimrc on its own,
" and the "groovim" command hands it over with "-u <path>" -- so it comes out
" EMPTY. "<sfile>" is the file being sourced, which is exactly this one,
" wherever it lives.
let g:GrooVim_Vimrc = get(g:, "GrooVim_Vimrc",
 \ expand("<sfile>:p") != "" ? expand("<sfile>:p") : $MYVIMRC)

" And where THIS RUN writes what it leaves behind: the session, the undo,
" the viminfo, the clipboard file. Normally the same place.
"
" Under "sudo" it is not. The code, the plugins and the settings go on coming
" from the GrooVim that was installed, which is the whole point of having one
" installation. What must NOT come from there is what gets WRITTEN: root
" writing a session into your directory leaves it owned by root, and the next
" time you opened GrooVim as yourself you could not write it any more.

" The "groovim" command sets "GROOVIM_STATE" when whoever is running is not
" whoever installed.
let g:GrooVim_State = get(g:, "GrooVim_State",
 \ $GROOVIM_STATE != "" ? expand($GROOVIM_STATE) : g:GrooVim_Home)

" Note: Where the answers you chose to KEEP are written down. Defined here and
" not in the "options" part, because the file is READ before any part of
" GrooVim runs, so the path has to exist before them. It lives with the code
" and not with the state: it is a choice, not something this run leaves behind.
let g:GrooVim_OptsFile = get(g:, "GrooVim_OptsFile", g:GrooVim_Home . "/opts.vim")

for s:GrooVim_Dir in [g:GrooVim_Home, g:GrooVim_State]
  if !isdirectory(s:GrooVim_Dir)
    call mkdir(s:GrooVim_Dir, "p")
  endif
endfor

let &runtimepath = g:GrooVim_Home . "," . $VIM . "/vimfiles," . $VIMRUNTIME .
 \ "," . $VIM . "/vimfiles/after," . g:GrooVim_Home . "/after"
let &packpath = &runtimepath

" And a "viminfo" of its own, so the marks, the registers and the history of
" one do not land on the other.
let &viminfofile = g:GrooVim_State . "/viminfo"

" Note: Here are the rest of GrooVim, which lives beside this file.
"
" A single, gigantic file hinders maintenance. What loads here is other parts
" of .vimrc in a fixed order, cut into parts named for what they hold.
"
" Named here as a list is the "map" of GrooVim: it says what there is and what
" each one is for, and it says it in the order they load -- which matters,
" because "runtimepath" has to be set before anything reads it, the plugins have
" to be looked for before the keys that ask whether they are there, the colours
" have to be named before "syntax on" wants them and so on...
"
" Beside THIS file and not beside your working directory: "g:GrooVim_Vimrc"
" is where GrooVim was loaded from, so the parts are found wherever the project
" happens to sit.
let s:GrooVim_Parts = [
 \ ["behaviour",   "how Vim behaves: the options that are not about a key"],
 \ ["indent",      "the indent width, per file type, and the guides"],
 \ ["plugins",     "which plugins are there, and how hard Vim works"],
 \ ["movement",    "moving the cursor and the text: GroovyMove, word selection"],
 \ ["state",       "what GrooVim knows about itself: messages, Caps Lock, the bar"],
 \ ["editing",     "the keys that edit: undo, delete, Tab, entering visual mode"],
 \ ["multiedit",   "writing in several places at once: the multiple carets"],
 \ ["options",     "the questions the configuration screens ask, and the answers"],
 \ ["search",      "searching, and the highlight that follows it"],
 \ ["occurrences", "the occurrence list: the panel of Notepad++"],
 \ ["bookmarks",   "marked lines, the notes on them and the walk between"],
 \ ["replace",     "replacing, with and without confirmation"],
 \ ["session",     "the session, and every way of closing"],
 \ ["shortcuts",   "the F keys: CommandZ, and the list every shortcut is written in"],
 \ ["menu",        "the menu of F10"],
 \ ["dialog",      "the windows that say something and wait: the About, and what comes after it"],
 \ ["tabs",        "the tab line, the names of what is open, the help window"],
 \ ["macro",       "macros, saving a copy, and the case of a word"],
 \ ["appearance",  "colours, the cursor, the status bar"],
 \ ["usability",   "small comforts, and the encoding"],
 \ ["help",        "the help of F9, written out of the list of shortcuts"],
 \ ]

" Note: The options you chose to KEEP, read BEFORE a single part of GrooVim.
"
" Read first, it wins over every default instead, because each of them is
" written as "get(g:, "name", default)" -- a value already there is kept.
if filereadable(g:GrooVim_OptsFile)
  exec "source " . fnameescape(g:GrooVim_OptsFile)
endif

let s:GrooVim_PartsDir = fnamemodify(g:GrooVim_Vimrc, ":h") . "/groovim"

for s:GrooVim_Part in s:GrooVim_Parts
  let s:GrooVim_File = s:GrooVim_PartsDir . "/" . s:GrooVim_Part[0] . ".vim"
  if filereadable(s:GrooVim_File)
    exec "source " . fnameescape(s:GrooVim_File)
  else
    echomsg "GrooVim: I cannot find the part \"" . s:GrooVim_Part[0] .
     \ "\" at " . s:GrooVim_File . "!"
  endif
endfor
