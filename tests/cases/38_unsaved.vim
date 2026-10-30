" The text you had NOT saved, kept across the way out -- and across a crash.
"
" What the session carries is which files were open; what you had typed into
" them it cannot carry, because ":mksession" writes down names and not text. So
" closing GrooVim with something unsaved used to be a question for every
" document, and a power cut was a loss.
"
" Notepad++ (inspiration) does not ask: it keeps a COPY of every document with
" text not yet on disk, and on the next start the document is back the way you
" left it, still marked as not saved. This is that, measured.
exec "source " . expand("<sfile>:p:h") . "/_common.vim"
call GT_Name(expand("<sfile>:t:r"))

" A document with a file of its own, written to disk and then changed.
func! GT_Dirty(path, text)
  call writefile(["o que estava no disco"], a:path)
  exec "edit! " . fnameescape(a:path)
  call setline(1, a:text)
  return bufnr("%")
endfunc

func! GT_Copies()
  return map(glob(g:GrooVim_UnsavedDir . "/*", 0, 1), 'fnamemodify(v:val, ":t")')
endfunc

func! GT_Body()

  call GT_Ok("setup: the copies are kept and have a place of their own",
    \ g:GrooVim_UnsavedAuto == 1 &&
    \ g:GrooVim_UnsavedDir =~ "/unsaved$",
    \ "   [" . g:GrooVim_UnsavedDir . "]")

  " ---- a document with text not on disk gets a copy
  tabonly! | enew!
  let g:GT_DIRTY = g:GT_OUT . "/nao_salvo.txt"
  let s:buffer = GT_Dirty(g:GT_DIRTY, ["o que eu digitei e nao salvei"])
  call GT_Ok("setup: the document has text that is not on disk",
    \ &modified == 1 && readfile(g:GT_DIRTY) ==# ["o que estava no disco"],
    \ "   (buffer [" . getline(1) . "], disk [" . readfile(g:GT_DIRTY)[0] . "])")

  call GT_Ok("writing the copies answers that every one was written",
    \ GrooVim_UnsavedWrite() == 1, "")
  let s:copy = GrooVim_UnsavedCopyOf(getpid(), s:buffer)
  call GT_Ok("  and the copy holds what the document holds",
    \ filereadable(s:copy) && readfile(s:copy) ==# ["o que eu digitei e nao salvei"],
    \ "   " . string(filereadable(s:copy) ? readfile(s:copy) : []))
  call GT_Ok("  and an index names it, with the FILE it belongs to",
    \ filereadable(GrooVim_UnsavedIndexOf(getpid())) &&
    \ !empty(filter(json_decode(join(readfile(GrooVim_UnsavedIndexOf(getpid())), "")),
    \   'v:val.path ==# g:GT_DIRTY && v:val.copy ==# s:copy')),
    \ "   (the name, the cursor, and the time the file had on disk)")
  call GT_Ok("  and the file on disk was not touched",
    \ readfile(g:GT_DIRTY) ==# ["o que estava no disco"],
    \ "   (a copy is a copy: nothing is written where you did not ask)")

  " ---- and saving the document takes its copy down
  silent write
  call GrooVim_UnsavedWrite()
  call GT_Ok("saving the document takes its copy down",
    \ !filereadable(s:copy),
    \ "   (what is in the directory is what is really waiting to come back)")
  call GT_Ok("  and the index goes with the last copy",
    \ !filereadable(GrooVim_UnsavedIndexOf(getpid())) ||
    \ empty(filter(json_decode(join(readfile(GrooVim_UnsavedIndexOf(getpid())), "")),
    \   'v:val.path ==# g:GT_DIRTY')),
    \ "   " . string(GT_Copies()))

  " ---- a document with NO file is copied too
  tabonly! | enew!
  call setline(1, ["documento que nunca foi salvo"])
  let s:nameless = bufnr("%")
  call GrooVim_UnsavedWrite()
  call GT_Ok("a document with no file is copied the same way",
    \ !empty(filter(json_decode(join(readfile(GrooVim_UnsavedIndexOf(getpid())), "")),
    \   'v:val.path ==# "" && v:val.name =~ "new "')),
    \ "   (its name is all there is of it, and it comes back as one)")
  silent! exec "bwipeout! " . s:nameless
  call GrooVim_UnsavedWrite()

  " ---- what a GrooVim that is GONE left behind comes back
  "
  " And only what a gone one left: the copies of an editor that is still
  " running beside this one are not taken. Which is which is asked of the
  " process itself.
  call GT_Ok("a process that is there is told from one that is not",
    \ GrooVim_ProcessAlive(1) == 1 && GrooVim_ProcessAlive(999999) == 0 &&
    \ GrooVim_ProcessAlive(0) == 0,
    \ "   (pid 1 is always there; 999999 is not)")

  tabonly! | enew!
  let g:GT_BACK = g:GT_OUT . "/voltou.txt"
  call writefile(["o que estava no disco"], g:GT_BACK)
  let s:dead = 999998
  let s:deadCopy = GrooVim_UnsavedCopyOf(s:dead, 7)
  let s:deadNameless = GrooVim_UnsavedCopyOf(s:dead, 8)
  call writefile(["texto que nao foi salvo"], s:deadCopy)
  call writefile(["um documento sem arquivo"], s:deadNameless)
  call writefile([json_encode([
    \ {"path": g:GT_BACK, "name": "", "copy": s:deadCopy,
    \  "line": 1, "col": 1, "disk": getftime(g:GT_BACK)},
    \ {"path": "", "name": "new 1", "copy": s:deadNameless,
    \  "line": 1, "col": 1, "disk": 0}])],
    \ GrooVim_UnsavedIndexOf(s:dead))

  " And one from a process that IS alive, which must be left exactly as it is.
  let s:aliveCopy = GrooVim_UnsavedCopyOf(1, 9)
  call writefile(["texto de outro GrooVim, ainda aberto"], s:aliveCopy)
  call writefile([json_encode([{"path": "", "name": "new 9",
    \ "copy": s:aliveCopy, "line": 1, "col": 1, "disk": 0}])],
    \ GrooVim_UnsavedIndexOf(1))

  let s:tabsWere = tabpagenr("$")
  call GrooVim_UnsavedRestore()

  call GT_Ok("the text left by a GrooVim that is gone comes BACK",
    \ !empty(filter(map(range(1, bufnr("$")), 'bufname(v:val)'),
    \   'v:val ==# g:GT_BACK')) &&
    \ getbufline(bufnr(g:GT_BACK), 1, "$") ==# ["texto que nao foi salvo"],
    \ "   " . string(getbufline(bufnr(g:GT_BACK), 1, "$")))
  call GT_Ok("  and it comes back MODIFIED, which is the whole point",
    \ getbufvar(bufnr(g:GT_BACK), "&modified") == 1,
    \ "   (the \"+\" on the bar and in the tab line, and closing that tab\n" .
    \ "    goes on asking about it)")
  call GT_Ok("  and the file on disk is still what it was",
    \ readfile(g:GT_BACK) ==# ["o que estava no disco"],
    \ "   (nothing is written where you did not ask)")
  call GT_Ok("  and a document with no file comes back as one",
    \ !empty(filter(map(range(1, bufnr("$")), 'v:val'),
    \   'bufname(v:val) ==# "" && buflisted(v:val) && bufloaded(v:val) &&' .
    \   ' getbufline(v:val, 1, "$") ==# ["um documento sem arquivo"]')),
    \ "   (it gets its \"new N\" like any other)")
  call GT_Ok("  and what it took is taken down, copies and index",
    \ !filereadable(s:deadCopy) && !filereadable(s:deadNameless) &&
    \ !filereadable(GrooVim_UnsavedIndexOf(s:dead)),
    \ "   " . string(GT_Copies()))
  call GT_Ok("  and what belongs to a GrooVim still running is LEFT alone",
    \ filereadable(s:aliveCopy) &&
    \ filereadable(GrooVim_UnsavedIndexOf(1)),
    \ "   (two editors open at once do not take each other's text)")

  call delete(s:aliveCopy)
  call delete(GrooVim_UnsavedIndexOf(1))

  " ---- and the way OUT does not ask any more
  call GT_Ok("closing the whole editor keeps the text instead of asking",
    \ GT_FunctionText("GrooVim_CloseAsking") =~ "GrooVim_UnsavedWrite" &&
    \ GT_FunctionText("GrooVim_CloseAsking") =~ "qa!",
    \ "   (the \"x\" of the window of Notepad++: what is not saved is copied\n" .
    \ "    and comes back on the next start)")
  call GT_Ok("  and only when the copies were really written",
    \ GT_FunctionText("GrooVim_CloseAsking") =~
    \   'a:command ==# "qa" && g:GrooVim_UnsavedAuto && GrooVim_UnsavedWrite()',
    \ "   (a copy that could not be written leaves the question where it was)")
  call GT_Ok("  and closing a TAB goes on asking, which is another thing",
    \ GT_FunctionText("GrooVim_TabClose") =~ "CloseSettle" &&
    \ GT_FunctionText("GrooVim_CloseAsking") =~ "CloseSettle",
    \ "   (there you are throwing one document away on purpose)")

  " ---- and the copies are written on a CLOCK, which is what answers a crash
  call GT_Ok("the copies are written on a clock as well",
    \ !empty(filter(GT_SourceLines(),
    \   'v:val =~ "timer_start(g:GrooVim_UnsavedEveryMs"')),
    \ "   (a hand that goes on typing never fires CursorHold, and a crash does\n" .
    \ "    not wait for a pause: measured with a kill -9, the text came back)")
  call GT_Ok("  and on the events a pause gives, and on the way out",
    \ !empty(filter(GT_SourceLines(),
    \   'v:val =~ "CursorHold,CursorHoldI,BufLeave,FocusLost,BufWritePost"')) &&
    \ !empty(filter(GT_SourceLines(),
    \   'v:val =~ "VimLeavePre \\* call GrooVim_UnsavedWrite"')),
    \ "")
  call GT_Ok("  and a document that is modified and no longer LOADED keeps its copy",
    \ GT_FunctionText("GrooVim_UnsavedWrite") =~ "bufloaded",
    \ "   (Vim unloads the buffers and fires VimLeavePre after: the last write\n" .
    \ "    of all found nothing to read and took the copies down -- measured,\n" .
    \ "    everything lost on the way out)")

  tabonly! | enew!
  call delete(g:GT_DIRTY)
  call delete(g:GT_BACK)
  call GT_Done()
endfunc

call GT_AfterStartup("GT_Body")
