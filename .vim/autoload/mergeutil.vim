let s:isWin = (has('win32') || has('win64'))
let s:devnull = s:isWin ? 'nul' : '/dev/null'
let s:cmp = s:isWin ? 'fc' : 'cmp'

function! mergeutil#threeway() abort
  " Vim is called with the following arguments:
  " argv[0] = common ancestor
  " argv[1] = theirs
  " argv[2] = mine
  " argv[3] = output file
  let args = argv()[0:3]
  " Ensure we have absolute path names
  call map(args, 'fnamemodify(v:val, ":p")')
  let [ancestor, theirs, mine, output] = args

  let [merged, mergedMine, mergedTheirs] = s:triviallyMerged(ancestor, theirs, mine)
  if merged
    " Update the output file and go on our merry way
    if s:isWin
      exe printf('silent !copy /y %s %s',
            \ shellescape(mergedMine, 1),
            \ shellescape(output, 1))
    else
      exe printf('silent !cp %s %s',
            \ shellescape(mergedMine, 1),
            \ shellescape(output, 1))
    endif
    call delete(mergedMine)
    qall
  endif

  if s:isWin
    autocmd VimEnter * simalt ~x
  endif
  autocmd VimEnter * wincmd =
  autocmd VimEnter * redraw!

  " Organize windows and let the user merge

  " Desired view is three windows showing the two partially merged files
  " and the output file in a 3-way diff.  Determine whether the view is
  "
  " mm | my               mm|
  " -------       or      --| o
  "    o                  my|
  "
  " based on whether Vim has more vertical space or horizontal

  exe printf('args %s %s %s',
        \ fnameescape(mergedMine),
        \ fnameescape(mergedTheirs),
        \ fnameescape(output))
  vert all
  if &columns > &lines
    " Move to the output file window
    3wincmd w
    " Wide window, so move output file down
    wincmd J
  else
    " Move to mergedTheirs window
    2wincmd w
    " Move it down
    wincmd J
    " Move to output window
    2wincmd w
    " Move it right
    wincmd L
  endif

  " Populate output file with original "mine" file
  lockmarks %delete _
  exe 'lockmarks read '. fnameescape(mine)
  lockmarks 1delete _
  windo diffthis
endfunction

function! s:triviallyMerged(ancestor, theirs, mine) abort
  let merged = 0
  if executable('diff3')
    let tmp_mine_dir   = tempname()."/mine/"
    let tmp_theirs_dir = tempname()."/theirs/"
    call mkdir(tmp_mine_dir, "p")
    call mkdir(tmp_theirs_dir, "p")
    let tmp_mine   = tmp_mine_dir.split(a:mine,'/\|\\')[-1]
    let tmp_theirs = tmp_theirs_dir.split(a:theirs,'/\|\\')[-1]
    try
      exe printf('silent !diff3 --easy-only --merge %s %s %s > %s',
            \ shellescape(a:theirs, 1),
            \ shellescape(a:ancestor, 1),
            \ shellescape(a:mine, 1),
            \ shellescape(tmp_theirs, 1))
      if v:shell_error == 2
        throw 'failed diff'
      endif

      exe printf('silent !diff3 --easy-only --merge %s %s %s > %s',
            \ shellescape(a:mine, 1),
            \ shellescape(a:ancestor, 1),
            \ shellescape(a:theirs, 1),
            \ shellescape(tmp_mine, 1))
      if v:shell_error == 2
        throw 'failed diff'
      endif

      exe printf('silent !%s %s %s > %s',
            \ s:cmp,
            \ shellescape(tmp_mine, 1),
            \ shellescape(tmp_theirs, 1),
            \ s:devnull)
      if v:shell_error == 0
        let merged = 1
      endif
    finally
      if merged
        call delete(tmp_theirs)
      endif
    endtry
  endif
  return [merged, tmp_mine, tmp_theirs]
endfunction
