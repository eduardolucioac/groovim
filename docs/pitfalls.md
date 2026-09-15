# The automated battery of GrooVim

Tests that run on their own, so what already works does not break. They go
alongside `_TESTE_GROOVIM/00_ROTEIRO.md`, which is the manual test — this one
checks the behaviour from the inside; the manual one checks what you see.

## Running it

```bash
./tests/run.sh                    # uses ./.vimrc
./tests/run.sh ~/.vimrc           # tests what is installed
./tests/run.sh '' 03_panel        # a single case
```

It exits with `0` only if every case reaches its end and no check fails. The
whole battery takes about **24 seconds**.

A case that hangs is caught: the runner kills it after 90 seconds and says
`the case did not reach its end`. To shorten that wait:
`GROOVIM_TEST_TIMEOUT=15 ./tests/run.sh`.

To run the battery inside the Vim that GrooVim builds for itself, instead of the
one of the system: `GROOVIM_TEST_VIM=~/.local/share/groovim/bin/vim ./tests/run.sh`.

## The cases

| case | what it covers |
|---|---|
| `01_replace` | the occurrence counter, `gdefault`, the wrap with confirmation, cursor and scrolling coming back, `Ctrl-C`/`Ctrl-X`, `cmdheight` |
| `02_tabs_replace` | replacing across several tabs, the cursor of **each** tab kept, the two meanings of `TabDo` |
| `03_panel` | the list as a read-only buffer (`nofile`, `wipe`, unlisted), the bar of Notepad++, `Enter` navigating and `Del` not |
| `04_keys` | no editing key does anything in the list, in normal **and** in visual; `y`, the arrows, `gg`, `G` and `PageDown` still work |
| `05_navigation` | `Enter` lands in the right place; links pointing at a tab that is gone, a tab holding another file, a file already open, a path with a comma |
| `06_tab_lifecycle` | `:q` closes the **tab** (both windows), the buffer of the list dies with it, reopening brings the list back |
| `07_tabline` | the label of a tab is always a document of yours, the count ignores the accessories, the `+` for modified |
| `08_list_survives` | with the last file closed the list stays; reopening from it; leaving through `:q` |
| `09_options` | the text of the prompt built out of the options, and the validation of the answers |
| `10_guides` | the width of the indent guide following `shiftwidth`/`tabstop`, and where the guides land on screen |
| `11_movement` | `Ctrl-Alt` and `Shift-Alt` with the arrows walking in a straight line, even across short lines |
| `12_saved_options` | keeping an option for the next session, and the "just apply" |
| `13_file` | the `F5` group (save, close) and the macro that stops with the same keys |
| `14_session` | the automatic session, and the commands by hand saying so when it is on |
| `15_apply_or_save` | the last question of the screens: just apply, or apply and save |
| `16_session_filetype` | a file coming back from the session comes back as itself: filetype, syntax, width and guides |
| `17_tab_commands` | carrying a tab along the tab line, closing every tab on one side, and closing the last one |
| `18_undo_select` | undo and redo on Ctrl-u/Ctrl-r in the three modes, and selecting the whole buffer |
| `19_key_groups` | each F key is a group with a meaning: no letter answering twice, the list the help is written from holding exactly the keys the code answers and in the right modes, and every shortcut a message names really existing |
| `20_indent_screen` | the indent settings as a screen: width, spaces or a real tab, the guides, and keeping it all |
| `21_title_case` | Title Case in the three modes, and a copy that does not demand a writable buffer |
| `22_new_names` | a document you have not saved yet is called "new 1", on screen only |
| `23_menu` | the F10 menu: its two levels, the lines built from the shortcut list, and choosing an entry pressing its keys |

Every case writes into `results/<name>.txt`, **line by line**, and ends with
`END` — the runner demands that mark. A case that ends by making Vim itself quit
calls `GT_DoneHere()` before the step that leaves.

## Seeing the screen

For any question of **layout** — where the prompt landed, whether a blank line
was left over, what the tab shows, whether the bar changed — looking at the state
from the inside does not answer it. Use:

```bash
./tests/screen.sh my_script.vim [file]
```

The script schedules keys and ends by quitting:

```vim
call timer_start(400,  {-> feedkeys("\<F3>f", "t")})
call timer_start(900,  {-> feedkeys("TARGET\<CR>", "t")})
call timer_start(2400, {-> execute("qa!")})
```

`screen.py` rebuilds the screen out of what Vim sent to the terminal.

**Careful:** Vim redraws only what changed, so the rebuild can mix the new
drawing with leftovers of the old one. When the question is *which column is
such a character in*, use `screenchar(line, column)` from inside Vim itself — it
is the screen Vim sees, with nothing in between. The case `10_guides` does that.

## Traps that cost dearly

Each of these has already produced a wrong diagnosis. They are written down so
they do not happen twice.

**A command inside an autocmd fires no autocmds of its own.** Not unless the
autocmd says `++nested`. It is not a trap of the battery, it is a trap of the
product: GrooVim loads the session from a `VimEnter`, and without `++nested` the
`:edit` written in the session opened every file with no `BufRead` — no filetype
detection, no syntax, no indent rules, no guides. The same file named on the
command line opened right, which is what makes it look like a session defect
when it is not. `16_session_filetype` holds the line.

**Marking the steps with fixed times makes an unstable case.** `feedkeys` with
`"t"` only queues the keys, and Vim processes them when it gets back to the main
loop — a timer that fires before that samples too early, and the case fails with
nothing wrong in the product. Measured: the same case passing and failing on
consecutive runs. Use `GT_When('condition', "NextStep")`, which waits for the
condition to become true before going on.

**The automatic session contaminates the same way.** Every case opens Vim with no
file, which is exactly when GrooVim brings the session back — and it would be the
session of the previous case, with tabs, buffers and cursors already there and
wrong. The runner gives each CASE a throwaway `GROOVIM_HOME`, which isolates in
one go the session, the saved options, the undo and the `viminfo` of GrooVim.

One per run was not enough: it kept the cases out of the home of the user, but
not out of each other. Measured — a case passed alone and failed in the battery,
and the reason was the next trap.

**A key that acts where the cursor is needs the cursor placed.** `A` appends to
the line the cursor is ON; `x` deletes the character it is on. A case that writes
with `setline()` and then presses a key is measuring two different places unless
it says `cursor()` first. It reads as "insert mode does not work", which sends
you looking for a defect in the product that is not there.

**The `viminfo` contaminates everything.** Without `-i NONE`, Vim restores the
buffer list of the previous run — including a ghost occurrence list, which makes
the `bufexists()` of `Sync` give up on building the real one. Symptom: results
that change without the code changing. The runner already passes `-i NONE -n`.

**`normal!` does NOT go through the mappings — and sometimes that is precisely
what you meant to measure.** A test of `Tab` written as `normal! i<Tab>` measures
the native `Tab` of insert mode, which is the only one GrooVim does not remap:
the defect was in normal mode and the test passed. To exercise the key the way
the user presses it, use `feedkeys(key, "x")`.

**`:normal` without `!` goes through the mappings.** The list turns `d`, `i` and
`p` off with buffer mappings; a `norm ggdG` from inside it turns into something
else and Vim hangs waiting for a movement for the `>` operator. Inside the panel
it is always `norm!`.

**The `:confirm` dialog cannot be answered from a script.** It reads the key
straight from the terminal and never looks at what `feedkeys` queued — measured,
from a timer and from startup alike, and the case hangs until the timeout. So no
case may call anything that closes a modified buffer. What the battery checks is
that the closing goes through the asking route; the question itself is read on
screen, with `screen.sh`, where it says `Save changes to "..."?`.

**An error inside `feedkeys()` opens a "Press ENTER"** that waits for ever in a
script. That is what hung `05` before `@/` became part of the state that gets
built.

**Writing the result only at the end fools you.** A case that dies halfway left
the file empty, and a test with no output is indistinguishable from a test that
never ran. `GT_Ok()` writes on every check, and `GT_Done()` writes `END` — the
runner demands that mark.

**`feedkeys(..., "x")` does not enter macro recording.** Measured: recording with
`"x"`, the register comes out empty; with `"t"` and timers, out comes what was
typed. A macro case written with `"x"` measures the opposite of what happens when
you press the keys.

**`feedkeys(..., "x")` ends insert mode.** To measure something *during* insert,
send the keys with `"t"` and sample from a `timer_start` — `mode()` confirms
whether you really are there. That is why `11_movement` chains timers.

**`feedkeys` with `:` types into the buffer.** GrooVim remaps `:`. For commands,
use `execute("...")` inside the `timer_start`, not `feedkeys(":...")`. It has
already modified fixture files by accident.

**Calling `GrooVim_SearchGuy()` directly does not reproduce the path of `F3`.**
For the panel, the keys and the navigation, `GT_BuildSearch()` builds the state
by hand and is stable. What depends on the real path is checked on screen, with
`screen.sh`.

**`vim -S` reads the case during STARTUP, and not every event happens there.**
`OptionSet` is the example: a `:set shiftwidth=8` written straight into the case
fires nothing, while the same command typed by hand fires it. A case that depends
on this measures the opposite of what really happens. Put the body in a function
and call `GT_AfterStartup("NameOfTheFunction")`.

**`l:` does not exist outside a function.** In a case at the top level,
`for l:x in [...]` aborts the whole loop in silence — and a loop that does not run
produces no failure, it produces *absence*. Use a plain name.

**A string index counts bytes.** `guide[0]` on a character like `┊` gives back
half a character. Use `strcharpart()`.

**`=~` is case-insensitive here.** GrooVim sets `ignorecase`, so a check written
`getline(1) =~ "^O'Brien"` passes over the very text it was meant to reject —
`o'brien` matches. Use `==#` with the exact string, or `=~#`.

**Two F-key shortcuts in a row repeat instead of running.** Pressing the same F
key twice within `g:GrooVim_CommandZRepeat` means "do that again" in GrooVim, and
two `feedkeys()` calls from a case are milliseconds apart. Measured: a Title Case
that followed a lowercase left the word lowercase, and the case was accusing the
product of a defect that was in the test. Use `GT_Press()`, which clears the
moment first.

**`gdefault` inverts the `g` flag of `:s`.** GrooVim has it on, so a substitution
written `:s/.../.../g` replaces the FIRST match of each line and no more.
Measured: a Title Case over a selection changed only the first word. Turn it off
around the substitution and put it back, the way the occurrence counter does.

**Filtering the output hides a failure.** Run the whole runner and read the
summary.

## Fixtures

The cases run over a **copy** of `fixtures/`, made in `/tmp` on every run, with a
throwaway `GROOVIM_HOME` next to it. A case that changes a file in memory never
gets near the originals. `results/` is throwaway and is in the `.gitignore`.
