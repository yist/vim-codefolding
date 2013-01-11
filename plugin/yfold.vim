function GetFirstLineWithChars()
  let line_num = 0
  let charline = matchstr(getline(v:foldstart), '.*[a-zA-Z]\+.*')
  while strlen(charline) == 0
    let line_num = line_num + 1
    let charline = matchstr(getline(v:foldstart + line_num), '.*[a-zA-Z]\+.*')
  endw
  return charline
endfunction

" Simple fold settings for G code style.
function GCodeFoldingSimple()
  setlocal foldtext=getline(v:foldstart)
  setlocal fdm=marker
  setlocal foldmarker={,}
endfunction

function YFolding()
  set foldtext=repeat('\ \ ',v:foldlevel-1).'[+]\ '.substitute(GetFirstLineWithChars(),'\\\/\\\/\\\|\\*\\\|\\*\\\|{{{\\d\\=','','g')
endfunction

function GCodeFolding()
  "let g:fdbg = 'FDBG '
  setlocal foldexpr=FoldByBracket(v:lnum)
  setlocal fdm=expr
  setlocal foldtext=FBBText()
endfunction
 
" Fold settings for G code style.
function! FoldByBracket(lnum)
  " Skip first line.
  if (a:lnum == 1)
    return 0
  end

  let l:prevline = getline(a:lnum - 1)
  let l:lchg = 0
  "if l:prevline =~ "^.*{\\(\\s*\[\[:punct:\]\].*\\|\\s*\\)$"
  if l:prevline =~ "^.*{\\(\\s*\/.*\\|\\s*\\)$"
    "let g:fdbg = g:fdbg . a:lnum . ':+ '
    " Skip commented-out line.
    if ! (l:prevline =~ "^\\s*\/\/.*$")
      let l:lchg = l:lchg + 1
    endif
  endif

  let l:curline = getline(a:lnum)
  if l:curline =~ "^\\s*}.*$"
    "let g:fdbg = g:fdbg . a:lnum . ':- '
    " Skip commented-out line.
    if ! (l:curline =~ "^\\s*\/\/.*$")
      let l:lchg = l:lchg - 1
    endif
  endif

  if l:lchg == 1
    return 'a1'
  elseif l:lchg == -1
    return 's1'
  endif
  return '='
endfunction

function FBBText()
  let l:fdlines = v:foldend - v:foldstart
  let l:line = getline(v:foldend)
  let l:fdtext = l:line . repeat(' ', 60 - len(l:line)) . "(" . l:fdlines . " Lines Folded)"
  return l:fdtext
endfunction
