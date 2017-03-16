
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
 " Copyright (C) 2013 All rights reserved.
 "
 " @file    : helptaglist.vim
 " @brief   :
 " @version : 1.0
 " @date    : 2013/4/21 3:05:37
 " @author  : lq
 "
 " @note    :
 "
 " @history :
 "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


let g:htList_is_open = 0

let s:HTList = {}

command! HTListToggle call s:HTList.Toggle()

function! s:HTList.Toggle()
    "nnoremap <buffer> d :call <SID>MBEDeleteBuffer()<CR>:<BS>

    let l:winNum = FindWindow('__Help_Tag_List__')

    if l:winNum != -1
        call s:HTList.Close()
    else
        call s:HTList.Open()
        wincmd p
    endif

endfunction

function s:HTList.AddToTag(tag)
    let g:strHTListMenu .= "   ".a:tag."\n"
    return ""
endfunction

function s:HTList.AddToTitle(title)
    let title = a:title
    let title = matchstr(title, '^\s*' . g:reHTListTitle . '\(\s\+\)\@=')
    let title = substitute(title, '\d\+$', '.', "")
    let title = substitute(title, '\d\|\s', '', "g")
    let space = ""
    let len = strlen(title) - 1
    for i in range(len)
        let space .= "| "
    endfor
    let space .= "|-"
    let title = substitute(a:title, '^\s\+', '', "g")
    let g:strHTListMenu .= "   ".space.title."\n"
    return ""
endfunction

function Jump_To_Tag()
    let strCurLine = getline('.')
    if strCurLine =~ '|-\d'
        let strCurLine = '^\s*' . matchstr(strCurLine, g:reHTListTitle . '\s')
        let strCurLine = substitute(strCurLine, '\.', '\\.', "g")
    else
        let strCurLine = substitute(strCurLine, '^\s*', '*', "")
        let strCurLine = substitute(strCurLine, '\s*$', '*', "")
    endif

    " debug
    echo strCurLine

    let iSaveWinNr = bufwinnr(g:strSaveWinName)
    execute iSaveWinNr . ' wincmd w'

    silent call search(strCurLine, 'w')
    normal! z.
endfunction

function s:HTList.Open()
    let g:strSaveWinName = bufname(".")

    exe 'silent! vertical 25 split __Help_Tag_List__'
    setlocal modifiable

    let g:reHTListTitle = '\d\+\.\(\d\+\|\d\+\(\.\d\+\)*\)\?'
    let g:strHTListMenu = ">> Title\n"
        let lstBufData = getbufline("#", 1, "$")
        for line in lstBufData
            call substitute(line, '^\s*' . g:reHTListTitle . '\s\+.*$', '\=s:HTList.AddToTitle(submatch(0))', '')
        endfor

    let g:strHTListMenu .= "\n>> Tags\n"
    let lstBufData = getbufline("#", 1, "$")
    for line in lstBufData
        call substitute(line, '\*\([^ \t*]\+\)\*', '\=s:HTList.AddToTag(submatch(1))', 'g')
    endfor

    put! = g:strHTListMenu

    normal gg

    "双击映射成跳转
    nnoremap <buffer> <silent> <2-LeftMouse> :call Jump_To_Tag()<CR>
    nnoremap <buffer> <silent> <ENTER> :call Jump_To_Tag()<CR>

    "语法高亮
    setlocal filetype=taglist
    syntax match HTLTagScape           '^>> .*'
    syntax match HTLTagHead            '^   [^|]\+.*'
    syntax match HTLTITLE              '^   \(| \)*|-\d\+\.\(\d\+\|\d\+\(\.\d\+\)*\)\?\s'
    highlight def link HTLNormal       Comment
    highlight def link HTLTagScape     Identifier
    highlight def link HTLTagHead      String
    highlight def link HTLTITLE        Keyword

    setlocal nomodifiable  "不可修改
    silent! setlocal buftype=nofile  "这个buff不是文件
    silent! setlocal bufhidden=delete "隐藏即删除
    setlocal noswapfile
    setlocal nonumber
    setlocal nobuflisted "不列如buf中
    setlocal nowrap "没有换行
endfunction

function s:HTList.Close()
    let l:winNum = FindWindow('__Help_Tag_List__')
    if l:winNum != -1
        exec l:winNum.' wincmd w'
        silent! close
        wincmd p
    endif
endfunction

function! FindWindow(bufName)
    " Try to find an existing window that contains
    " our buffer.
    let l:bufNum = bufnr(a:bufName)
    if l:bufNum != -1
        let l:winNum = bufwinnr(l:bufNum)
    else
        let l:winNum = -1
    endif
    return l:winNum
endfunction


