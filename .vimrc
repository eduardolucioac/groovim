" =D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D
" GrooVim =D - Vi IMproved'n'GrooVIed!
" GrooVim =D - Vi IMproved'n'GrooVIed!
" GrooVim =D - Vi IMproved'n'GrooVIed!
" =D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D=D

"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
"LICENSE (GNU General Public License v3.0 or later)
"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

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

" Note: The licence itself lives in the file "LICENSE", and what a source
" file carries is this: the notice the GPL asks you to attach, from
" "How to Apply These Terms to Your New Programs" at its end! By Questor

" Note: The version, and the ONE place it is written. The help of F9 used to
" carry a second copy of it, typed by hand, and that is how a number goes stale:
" nothing makes the two agree, and nobody reads the title of a help they wrote
" themselves! By Questor
let g:grooVimVersion = "v3.0.0b"
" Eduardo Lúcio
" 2014

"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
"TASK LIST/BUGS LIST
"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

" Note: Empty, and that is not an accident: every entry was read against the
" code, one by one, and answered.
"
" Note: Of the twenty nine there were -- twenty one here and eight more that the
" README carried alone -- twelve had already been built and nobody had crossed
" them off, five were built the day the list was read, two were defects and were
" fixed, and ten were looked at and decided against. What was left of the last
" ones on the day this became empty: a jump between brackets, which Vim does with
" "%" and only wanted a key, and a "save as" beside the "save a copy" that was
" already there.
"
" Note: A list that repeats the code goes stale in the dark. This one is for what
" the code does NOT say, and right now there is nothing of the kind! By Questor

"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
"MAIN
"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

"$$$$$$$$$$$$$$$$$$$$$$$$$$
"GENERAL BEHAVIOR
"$$$$$$$$$$$$$"

" Note: Use vim settings, rather then vi settings (much better!)! This must be
" first, because it changes other options as a side effect! By Questor
set nocompatible

" Note: GrooVim keeps a directory of its own, and does NOT share the one of the
" Vim of your system.
"
" Note: Reached through the "groovim" command, GrooVim has its own Vim and its
" own ".vimrc". Leaving "~/.vim" in the runtime path undid half of that: the
" plugins of GrooVim were being loaded by the Vim of the system as well --
" measured, plain "vim" was opening with NERDTree because GrooVim had installed
" it. Now each one has its own plugins, and neither sees the other's.
"
" Note: The shape of the path is the one Vim builds by itself, with "~/.vim"
" swapped for ours.
"
" Note: To keep it somewhere else, set "GROOVIM_HOME" in the environment:
"
"     GROOVIM_HOME=/opt/groovim-do-trabalho groovim file.txt
"
" and everything moves at once -- plugins, saved options, undo history, the
" clipboard file and the "viminfo". Two of those, side by side, are two GrooVim
" that know nothing of each other.
"
" The Vim GrooVim asks for, said once and here.
"
" 9.2 is what install.sh builds, and GrooVim is reached only through the
" "groovim" command, which runs that Vim -- so it is what GrooVim gets. The
" clipboard depends on what arrived in it: "v:clipproviders", "clipmethod",
" ":clipreset" and the "osc52" package that ships with it.
"
" Said here instead of guarding every use of them. Four "exists()" scattered
" through the clipboard were carrying a Vim this project refuses to run on, and
" one clear sentence is worth more than four silent degradations.
if v:version < 902
  echomsg "GrooVim: this is Vim " . (v:version / 100) . "." . (v:version % 100) .
   \ " and GrooVim asks for 9.2 -- the clipboard will not work. Run install.sh."
endif

" The encoding, and it has to be HERE: before a single part is read.
"
" Vim resolves a "\uXXXX" in a double-quoted string to the bytes of whatever
" 'encoding' is at the moment it reads the line, and it picks that from the
" locale when it starts. On a machine with no UTF-8 locale -- a headless
" server, a container, a sudo that strips LANG -- it starts in latin1, and the
" "\u250A" of the indent guide collapsed into a single byte. Vim then refused
" it: "E1512: Wrong character width for field leadmultispace", and the guides
" were silently gone. Worse, with no listchars of its own the window fell back
" to the default of Vim, which draws a "$" at the end of every line.
"
" It is set again, along with the file encodings, in the "usability" part. This
" is the one that has to come first.
set encoding=utf-8
set termencoding=utf-8

" Note: The environment and not only "g:GrooVim_Home", because with "-u" there is
" no file of yours running before this one: overriding the variable would mean
" typing "--cmd" on every call. It is the same shape as "GROOVIM_VIM" and
" "GROOVIM_VIMRC", which the "groovim" command already reads! By Questor
let g:GrooVim_Home = get(g:, "GrooVim_Home",
 \ $GROOVIM_HOME != "" ? expand($GROOVIM_HOME) : expand("~/.groovim"))

" Note: Where THIS file is, so that GrooVim can open and reload itself.
"
" Note: Not "$MYVIMRC": Vim only fills that in when it finds the vimrc on its
" own, and the "groovim" command hands it over with "-u <path>" -- so it comes
" out EMPTY, and ":tabedit $MYVIMRC" opened a new, empty file whose name was the
" four letters of the variable. Measured. "<sfile>" is the file being sourced,
" which is exactly this one, wherever it lives! By Questor
let g:GrooVim_Vimrc = get(g:, "GrooVim_Vimrc",
 \ expand("<sfile>:p") != "" ? expand("<sfile>:p") : $MYVIMRC)

" Note: And where THIS RUN writes what it leaves behind: the session, the undo,
" the viminfo, the clipboard file. Normally the same place -- there is only one
" of you.
"
" Note: Under "sudo" it is not. The code, the plugins and the settings go on
" coming from the GrooVim that was installed, which is the whole point of having
" one installation. What must NOT come from there is what gets WRITTEN: root
" writing a session into your directory leaves it owned by root, and the next
" time you opened GrooVim as yourself you could not write it any more.
"
" Note: The "groovim" command sets "GROOVIM_STATE" when whoever is running is not
" whoever installed! By Questor
let g:GrooVim_State = get(g:, "GrooVim_State",
 \ $GROOVIM_STATE != "" ? expand($GROOVIM_STATE) : g:GrooVim_Home)

" Where the answers you chose to KEEP are written down. Defined here and not in
" the "options" part, because the file is READ before any part of GrooVim runs,
" so the path has to exist before them. It lives with the code and not with the
" state: it is a choice, not something this run leaves behind.
let g:GrooVim_OptsFile = get(g:, "GrooVim_OptsFile", g:GrooVim_Home . "/opts.vim")

for s:GrooVim_Dir in [g:GrooVim_Home, g:GrooVim_State]
  if !isdirectory(s:GrooVim_Dir)
    call mkdir(s:GrooVim_Dir, "p")
  endif
endfor

let &runtimepath = g:GrooVim_Home . "," . $VIM . "/vimfiles," . $VIMRUNTIME .
 \ "," . $VIM . "/vimfiles/after," . g:GrooVim_Home . "/after"
let &packpath = &runtimepath

" Note: And a "viminfo" of its own, so the marks, the registers and the history
" of one do not land on the other! By Questor
if exists("+viminfofile")
  let &viminfofile = g:GrooVim_State . "/viminfo"
endif

" Note: Force reloading *after* the plugins loaded! Trying avoid override! By Questor
filetype plugin indent on

" Note: Vim 8 and later load everything under "pack/*/start" on their own, so NO
" plugin manager is needed. For GrooVim that is "~/.groovim/pack/*/start", set
" above: its plugins are its own, and not the ones of the Vim of your system. Pathogen is still honoured for whoever
" already uses it, but it is not required anymore: this used to be an
" unconditional call that raised "E117" twice on a machine without Pathogen,
" which broke the "all in one" objective of GrooVim. Note that "exists()" does
" NOT source an autoload script, so we look for the file itself! By Questor
if globpath(&runtimepath, "autoload/pathogen.vim") != ""
  execute pathogen#infect()
  execute pathogen#helptags()
endif

" Note: Enable mouse! By Questor
set mouse=a


" Note: And the rest of GrooVim, which lives beside this file.
"
" Note: One file of six thousand lines was one file too many. What loads here is
" the SAME code in the SAME order, cut into parts named for what they hold. Put
" back together the parts ARE the file that was here, line for line, and that is
" checked and not hoped for.
"
" Note: And the rest of GrooVim, which lives beside this file.
"
" Note: Six thousand lines in one file was one file too many. The parts hold the
" SAME code in the SAME order, each named for what it keeps.
"
" Note: Named here one by one, and NOT gathered with a wildcard. A list you can
" read is the map of GrooVim: it says what there is and what each one is for, and
" it says it in the order they load -- which matters, because "runtimepath" has
" to be set before anything reads it, the plugins have to be looked for before
" the keys that ask whether they are there, and the colours have to be named
" before "syntax on" wants them. A wildcard would have needed numbers glued to
" the front of every name to keep that order, and a second list somewhere else to
" say what they were for.
"
" Note: Beside THIS file and not beside your working directory: "g:GrooVim_Vimrc"
" is where GrooVim was loaded from, so the parts are found wherever the project
" happens to sit! By Questor
let s:GrooVim_Parts = [
 \ ["behaviour",   "how Vim behaves: the options that are not about a key"],
 \ ["indent",      "the indent width, per file type, and the guides"],
 \ ["plugins",     "which plugins are there, and how hard Vim works"],
 \ ["movement",    "moving the cursor and the text: GroovyMove, word selection"],
 \ ["state",       "what GrooVim knows about itself: messages, Caps Lock, the bar"],
 \ ["editing",     "the keys that edit: undo, delete, Tab, entering visual mode"],
 \ ["options",     "the questions the configuration screens ask, and the answers"],
 \ ["search",      "searching, and the highlight that follows it"],
 \ ["occurrences", "the occurrence list: the panel of Notepad++"],
 \ ["bookmarks",   "marked lines, the notes on them and the walk between"],
 \ ["replace",     "replacing, with and without confirmation"],
 \ ["session",     "the session, and every way of closing"],
 \ ["shortcuts",   "the F keys: CommandZ, and the list every shortcut is written in"],
 \ ["menu",        "the menu of F10"],
 \ ["tabs",        "the tab line, the names of what is open, the help window"],
 \ ["macro",       "macros, saving a copy, and the case of a word"],
 \ ["appearance",  "colours, the cursor, the status bar"],
 \ ["usability",   "small comforts, and the encoding"],
 \ ["help",        "the help of F9, written out of the list of shortcuts"],
 \ ]

" The options you chose to KEEP, read BEFORE a single part of GrooVim.
"
" They used to be read at the end of the last part, so that they would win over
" the defaults. That works for an option consulted while you type -- whether the
" session saves itself is asked at the moment it saves -- and not for one
" consulted as GrooVim LOADS -- and the clipboard of the first part of eighteen
" is decided there, so a kept answer would have arrived thirteen parts too late
" and done nothing, with nothing said about it.
"
" Read first, it wins over every default instead, because each of them is
" written as "get(g:, "name", default)" -- a value already there is kept. Seven
" of them were plain assignments until this moved, and would have been run over.
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
