" auto_mkdir2.vim: Automatically create directories
"
" http://code.arp242.net/auto_mkdir2.vim
"
" See the bottom of this file for copyright & license information.


"##########################################################
" Initialize some stuff
scriptencoding utf-8
if exists('g:loaded_auto_mkdir2') | finish | endif
let g:loaded_auto_mkdir2 = 1
let s:save_cpo = &cpo
set cpo&vim


"##########################################################
" Options
if !exists('g:auto_mkdir2_confirm')
	let g:auto_mkdir2_confirm = 1
endif


"##########################################################
" Commands
command! -nargs=* -complete=dir MkdirP call s:mkdir_p(<q-args>, 1)

augroup auto_mkdir2
	autocmd!
	autocmd BufWritePre * call s:mkdir_p(expand("<amatch>:p:h"), 0)
augroup end


"##########################################################
" Functions

function! s:mkdir_p(path, never_ask) abort
	let l:dir = expand(a:path)
	if l:dir == ""
		let l:dir = expand('%:p:h')
	endif

	if isdirectory(l:dir)
		return
	endif

	if filereadable(l:dir)
		echoerr '`' . l:dir . "' exists and isn't a directory"
		return
	endif

	if g:auto_mkdir2_confirm
		echohl Question
		echon 'Create directory `' . a:path . "' [y/N]? "
		echohl None

		" TODO: When using :wq or ZZ I need to press <CR> here after y?
		let response = nr2char(getchar())
	else
		let l:response = 'y'
	endif

    if l:response ==? "y"
		call mkdir(iconv(l:dir, &encoding, &termencoding), 'p')
    endif
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo


" The MIT License (MIT)
"
" Copyright © 2015-2016 Martin Tournoij
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to
" deal in the Software without restriction, including without limitation the
" rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
" sell copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" The software is provided "as is", without warranty of any kind, express or
" implied, including but not limited to the warranties of merchantability,
" fitness for a particular purpose and noninfringement. In no event shall the
" authors or copyright holders be liable for any claim, damages or other
" liability, whether in an action of contract, tort or otherwise, arising
" from, out of or in connection with the software or the use or other dealings
" in the software.
