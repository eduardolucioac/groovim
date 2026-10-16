" Where GrooVim IS, and where this run writes what it leaves behind.
"
" Normally the same directory -- there is only one of you. Under "sudo" it is
" not: the code, the plugins and the settings go on coming from the one
" installation, which is the point of having one, but a session written by root
" into that directory would be owned by root, and its owner could not write it
" again.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

func! GT_Body()

  " ---- with nobody else involved, the two are one
  call GT_Ok("the installation and the traces are the same place by default",
    \ g:GrooVim_State ==# g:GrooVim_Home,
    \ "   [" . g:GrooVim_Home . "]")

  " ---- what belongs to the INSTALLATION, and is read
  call GT_Ok("the code and the plugins come from the installation",
    \ split(&runtimepath, ",")[0] ==# g:GrooVim_Home,
    \ "   [" . split(&runtimepath, ",")[0] . "]")
  call GT_Ok("and so do the saved options, which are configuration",
    \ stridx(g:GrooVim_OptsFile, g:GrooVim_Home) == 0,
    \ "   [" . g:GrooVim_OptsFile . "]")
  call GT_Ok("and the place a clipboard tool may be dropped by hand",
    \ stridx(g:GrooVim_ClipBinDir, g:GrooVim_Home) == 0,
    \ "   [" . g:GrooVim_ClipBinDir . "]")

  " ---- what this RUN writes, and must not land in somebody else's directory
  for l:pair in [["the session", g:GrooVim_SessionFile],
    \ ["the undo", g:GrooVim_UndoDir],
    \ ["the viminfo", &viminfofile],
    \ ["the clipboard file", g:GrooVim_ClipFile]]
    call GT_Ok(l:pair[0] . " is written where the traces go",
      \ stridx(l:pair[1], g:GrooVim_State) == 0, "   [" . l:pair[1] . "]")
  endfor

  " ---- and the two really can be told apart
  "
  " This is what the "groovim" command does for anyone who is not the user
  " GrooVim was installed for.
  call GT_Ok("GROOVIM_STATE is what pulls the two apart",
    \ GT_SourceLines()->join("\n") =~ "GROOVIM_STATE",
    \ "   (the .vimrc reads it)")
  call GT_Ok("  and the command sets it for whoever is not the owner",
    \ filereadable(expand("~/.local/bin/groovim"))
    \ ? join(readfile(expand("~/.local/bin/groovim")), "\n") =~ "GROOVIM_STATE"
    \ : 1,
    \ "   " . (filereadable(expand("~/.local/bin/groovim")) ? "" : "(not installed here)"))

  " ---- and the battery travels with what it tests
  "
  " The tests are ABOUT the installation: they run on the Vim it built, and the
  " ".vimrc" they read by default is the one beside them -- which, once they are
  " installed, is the installed one. Whoever installed GrooVim can ask it whether
  " it works without going back for the project.
  if !GT_Project()
    call GT_NotTheProject("the installer taking the battery along")
  else
    let l:installer = fnamemodify($GROOVIM_TEST_VIMRC, ":h") . "/install.sh"
    let l:text = join(readfile(l:installer), "\n")
    call GT_Ok("the installer takes the battery along",
      \ l:text =~ 'cp -r "$from/tests" "$to/tests"',
      \ "   (so " . g:GrooVim_Home . "/tests/run.sh is there after installing)")
    call GT_Ok("  and leaves no results of another machine in it",
      \ l:text =~ 'rm -rf "$to/tests/results"',
      \ "   (green answers nobody produced here are worse than none)")
    call GT_Ok("  and says so when it ends",
      \ l:text =~ "Check it with:", "")

    " ---- and the plugins go in on a RELEASE, not on a default branch
    "
    " A "git pull" was what used to be here, and it would walk a plugin into its
    " next major on its own -- the one place a plugin changes the commands
    " GrooVim drives it by. The series is pinned and the newest release inside it
    " is taken, which is the rule the Vim itself is built by.
    call GT_Ok("the installer pins the plugins to a release series",
      \ l:text =~ "newest_release()" &&
      \ l:text =~ 'clone .*--branch "\$tag"',
      \ "   (a fix arrives on its own, a new major does not)")
    call GT_Ok("  and every plugin on the list carries its series",
      \ len(filter(readfile(l:installer),
      \   'v:val =~ "^[a-z][a-z_-]*|https://.*|[v0-9][0-9.]*|"')) == 3,
      \ "   (name|where it comes from|the series|what it is for)")
    call GT_Ok("  and one already there is put ON that release",
      \ l:text =~ "at_release()" && l:text =~ "refs/tags/" &&
      \ l:text =~ "checkout",
      \ "   (a shallow clone has no tags, so it is fetched by name first)")

    " ---- and the command knows how to hand a file to a GrooVim already open
    call GT_Ok("the command has the flag that hands a file over",
      \ l:text =~ "-j|--jrinst" && l:text =~ "JUST_REUSE",
      \ "   (groovim -j file.txt, \"just reuse an instance\")")
    call GT_Ok("  and it writes into the mailbox of the OLDEST one alive",
      \ l:text =~ "sort -n" && l:text =~ 'kill -0 "\\$pid"',
      \ "   (the name carries the time it opened and the process it is)")
    call GT_Ok("  and sweeps the mailbox of one that is gone",
      \ l:text =~ 'rm -f "\\$GROOVIM_STATE/inbox/\\$name"',
      \ "   (a GrooVim that was killed had no chance to take its own down)")
    call GT_Ok("  and with none open it opens the file itself",
      \ l:text =~ "there is no GrooVim open to hand it to",
      \ "   (and says so, instead of swallowing the file)")
    " ---- and it puts GrooVim in the MENU of a desktop
    "
    " One file and two icons, in the directories of the user: KDE Plasma, GNOME,
    " Xfce, Cinnamon, MATE and every other desktop that follows the
    " freedesktop.org specification read the same ones, which is the whole point
    " of the specification.
    call GT_Ok("the installer writes a menu entry",
      \ l:text =~ "groovim.desktop" && l:text =~ "Terminal=true" &&
      \ l:text =~ "Icon=groovim",
      \ "   (Terminal=true is what opens it in a terminal of its own)")
    call GT_Ok("  with ONE main category, so it is in the menu once",
      \ l:text =~ "Categories=Utility;TextEditor;",
      \ "   (a second main one puts GrooVim in the menu twice)")
    call GT_Ok("  and the icons where an icon theme looks",
      \ l:text =~ "scalable/apps/groovim.svg" &&
      \ l:text =~ "256x256/apps/groovim.png",
      \ "   (the SVG for whoever draws it at any size, the PNG for the rest)")
    call GT_Ok("  and only where there IS a desktop",
      \ l:text =~ "have_desktop()" && l:text =~ "XDG_CURRENT_DESKTOP" &&
      \ l:text =~ "xsessions",
      \ "   (a session running says so; one only INSTALLED leaves its files)")
    call GT_Ok("  and the path of the command is written out whole",
      \ l:text =~ 'Exec=\$BINDIR/groovim' && l:text =~ 'TryExec=\$BINDIR/groovim',
      \ "   (a session is started long before a shell of yours reads a PATH)")

    " ---- and it takes GrooVim out again
    call GT_Ok("the installer can take GrooVim out",
      \ l:text =~ "uninstall_groovim()" && l:text =~ "--uninstall",
      \ "   (the command, the Vim it built, the menu entry and the icons)")
    call GT_Ok("  and what you WROTE is asked about, not assumed",
      \ l:text =~ "What you wrote" && l:text =~ "Take that as well?" &&
      \ l:text =~ "--purge",
      \ "   (the options, the session, the marked lines, the plugins)")
    call GT_Ok("  and a link of somebody else is left where it is",
      \ l:text =~ "points somewhere else. Left where it is" &&
      \ l:text =~ "readlink",
      \ "   (another GrooVim under another prefix, or one put there by hand)")

    " ---- and the command behaves like a command: many files, and a list on
    " the standard input
    "
    " "find ./ -name '*.log' | groovim" is how a search hands its answer to an
    " editor, and it is the shape every tool of this kind takes.
    call GT_Ok("a list of file names on the standard input is read",
      \ l:text =~ "TEXT_FROM_STDIN" && l:text =~ 'read -r name' &&
      \ l:text =~ "exec < /dev/tty",
      \ "   (and the terminal is handed back to Vim, which the pipe had taken)")
    call GT_Ok("  with NULs when asked, which is what grep -Z writes",
      \ l:text =~ "-0|--stdin0" && l:text =~ 'read -r -d ""',
      \ "   (the only form that survives a name with a line break in it)")
    call GT_Ok("  and a lone \"-\" is still Vim's own",
      \ l:text =~ 'TEXT_FROM_STDIN=1',
      \ "   (read the TEXT from there, and then nothing is taken as a list)")
    call GT_Ok("and more than one file opens one TAB for each",
      \ l:text =~ 'ARGS=("-p"' && l:text =~ "arrange",
      \ "   (Vim opens them as buffers and shows the first)")
    call GT_Ok("  unless you said -p, -o or -O yourself",
      \ l:text =~ "-p\\*|-o\\*|-O\\*",
      \ "   (somebody who names an arrangement means it)")
    call GT_Ok("  and the menu entry hands them to the GrooVim already open",
      \ l:text =~ "Exec=\\$BINDIR/groovim --jrinst %F",
      \ "   (several at a time, which is what %F passes)")

    call GT_Ok("  and its --help answers for the flags of GrooVim too",
      \ l:text =~ "GrooVim adds:" && l:text =~ '"\\$GROOVIM_VIM" --help',
      \ "   (Vim knows nothing of them, so Vim alone could not answer)")
  endif

  " ---- the mailbox this GrooVim listens on
  "
  " "groovim -j file" opens the file in a GrooVim that is ALREADY running. Vim
  " has a way of its own for this, "--remote-tab", and it rides on X11 -- so it
  " is there on a desktop and gone on an SSH, in a container and on a machine
  " with no desktop, which is where GrooVim is at home. This asks for nothing
  " but a directory both sides can write in.
  call GT_Ok("this GrooVim has a mailbox of its own",
    \ filereadable(GrooVim_InboxMine()) &&
    \ GrooVim_InboxMine() =~ "/inbox/[0-9]\\+\\." . getpid() . "$",
    \ "   [" . fnamemodify(GrooVim_InboxMine(), ":t") .
    \ "]   (the time it opened, and the process it is)")
  call GT_Ok("  and it starts empty",
    \ getfsize(GrooVim_InboxMine()) == 0, "   (nothing to open yet)")

  " Note: Nothing is opened while a QUESTION is on the screen: a tab opening
  " under a prompt would take the keys it was waiting for.
  let g:GT_HANDED = g:GT_OUT . "/entregue.txt"
  call writefile(["uma linha entregue"], g:GT_HANDED)
  let g:GrooVim_Busy = 1
  call writefile([g:GT_HANDED], GrooVim_InboxMine())
  call GT_When("1", "GT_WhileBusy")
endfunc

func! GT_WhileBusy()
  call timer_start(900, {t -> GT_AfterBusy()})
endfunc

func! GT_AfterBusy()
  call GT_Ok("  and nothing is taken from it while a question is up",
    \ getfsize(GrooVim_InboxMine()) > 0 && expand("%:p") !=# g:GT_HANDED,
    \ "   (the file is not going anywhere: the next tick finds it still there)")

  let g:GrooVim_Busy = 0
  call GT_When('expand("%:p") ==# g:GT_HANDED', "GT_AfterInbox")
endfunc

func! GT_AfterInbox()
  call GT_Ok("a file written into the mailbox opens in a tab",
    \ expand("%:p") ==# g:GT_HANDED && getline(1) ==# "uma linha entregue",
    \ "   [" . expand("%:t") . "]   (and the bar says it was handed over)")
  call GT_Ok("  at the END of the tab line, like any other tab",
    \ tabpagenr() == tabpagenr("$"),
    \ "   (tab " . tabpagenr() . " of " . tabpagenr("$") . ")")
  call GT_Ok("  and the mailbox is empty again",
    \ getfsize(GrooVim_InboxMine()) == 0,
    \ "   (taken away and put back empty before a line of it was read)")
  call GT_Ok("  and it is taken down on the way out",
    \ !empty(filter(GT_SourceLines(),
    \   'v:val =~ "VimLeave .* delete(GrooVim_InboxMine())"')),
    \ "   (nobody hands a file to a GrooVim that is not there any more)")

  call delete(g:GT_HANDED)
  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
