" ============================================================================
" File:        lq.vim
" Description: my script
" Author:      liqiang
" Licence:     Vim licence
" Version:     1.0
" Note:
" ============================================================================

if exists("g:loaded_lq_autoload")
    finish
endif
let g:loaded_lq_autoload = 1

" Quickfix make conv
function! lq#QfMakeConv()
    let qflist = getqflist()
    let title = getqflist({'title': 1})
    for i in qflist
"        let i.text = iconv(i.text, "cp936", &enc)
        let i.text = substitute(i.text, "\r$", "", "")
    endfor
    call setqflist(qflist, 'r')
    call setqflist([], 'r', title)
endfunction

" Command line used in function
function! lq#CmdLine(cmd, cursor_left_num)

"    " new vim version (8.0.1000+) not support this way:
"    exe "menu liqiang.cmdline :" . a:cmd . repeat("<left>", a:cursor_left_num)
"    emenu liqiang.cmdline
"    unmenu liqiang.cmdline

    " Prompt command line
    call inputsave()
    let l:cmd_result = input(":", a:cmd . repeat("\<left>", a:cursor_left_num), "history")
    call inputrestore()
    if l:cmd_result != ""
        " Add to history
        call histadd(":", l:cmd_result)
        " Execute it
        exe l:cmd_result
    endif
endfunction

" grep automatically, use 'ag'
" NOTE: grep option and params must be use "" and not '', window version gvim not support ''
function! lq#GrepAuto(pattern, path, ignorecase)
    if a:ignorecase
        let l:opt = '-i'
    else
        let l:opt = '-s'
    endif
    if a:path == ''
        if &filetype == 'c' || &filetype == 'cpp' || &filetype == 'asm'
            let l:files = '(?i:.*\.([ch](pp)?\|cc\|s)$)'
        elseif &filetype == 'make'
            let l:files = '(?i:makefile\|.*\.ma?k$)'
        else
            let ext = expand("%:e")
            if ext == ''
                let l:files = ''
            else
                let l:files = '(?i:.*\.' . ext . '$)'
            endif
        endif
        call lq#CmdLine("grep " . l:opt . ' -G "' . l:files . '" "' . a:pattern . '"', 1)
    else
        call lq#CmdLine("grep " . l:opt . ' "' . a:pattern . '" ' . a:path, strlen(a:path)+2)
    endif
endfunction

" Replace all automatically, use 'args','argdo','%s'
function! lq#ReplaceAllAuto(pattern)
    if &filetype == 'c' || &filetype == 'cpp'
        let l:files = '**/*.c **/*.cpp **/*.h'
    elseif &filetype == 'make'
        let l:files = '**/*makefile **/*.mk **/*.mak'
    else
        let l:files = '**/*.' . expand("%:e")
    endif
    " replace it
    call lq#CmdLine('args ' . l:files . ' \| argdo %s/' . a:pattern . '//gec', 4)
endfunction

" Get Visual Select Text
function! lq#GetVisualSelectText(...) range
    if a:0 == 0
        let op = 'remove_return'
    else
        let op = a:1
    endif
    let txt = ''
    try
        let v_save = @v
        normal! gv"vy
        if op == 'remove_return'
            let txt = substitute(@v, "\n", " ", "g")
        elseif op == 'split_return'
            let txt = split(@v, "\n")
        else
            let txt =  @v
        endif
    finally
        let @v = v_save
    endtry
    return txt

" Following way may error when Block-Virsual Mode selecting EMPTY-LINE
"    let [lnum1, col1] = getpos("'<")[1:2]
"    let [lnum2, col2] = getpos("'>")[1:2]
"    let lines = getline(lnum1, lnum2)
"    let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
"    let lines[0] = lines[0][col1 - 1:]
"    return join(lines, "\n")
endfunction

" Visual Select
function! lq#VisualSelect(mode) range
    if a:mode =~ 'grep'
        let l:pattern = escape(lq#GetVisualSelectText(), "\\/.*$^~[]#%()'")
    else
        let l:pattern = escape(lq#GetVisualSelectText(), "\\/.*$^~[]")
    endif
    if a:mode == 'search'
        let @/ = l:pattern
    elseif a:mode == 'grep'
        call lq#GrepAuto(l:pattern, "", 1)
    elseif a:mode == 'grep-file'
        call lq#GrepAuto(l:pattern, "%", 1)
    elseif a:mode == 'replace'
        call lq#CmdLine("%s" . '/'. l:pattern . '//gc', 3)
    elseif a:mode == 'replace-all'
        call lq#ReplaceAllAuto(l:pattern)
    endif
endfunction

" Don't close window, when deleting a buffer
function! lq#BufcloseCloseIt()
    let l:currentBufNum = bufnr("%")
    let l:alternateBufNum = bufnr("#")
    if buflisted(l:alternateBufNum)
        buffer #
    else
        bnext
    endif
    if bufnr("%") == l:currentBufNum
        new
    endif
    if buflisted(l:currentBufNum)
        execute("bdelete! ".l:currentBufNum)
    endif
endfunction

"Toggle Line number
function! lq#LineNumberToggle()
    if(&relativenumber == 1)
        set norelativenumber
    else
        set relativenumber
    endif
endfunc

"Maximize window
function! lq#MaximizeWindow()
    if has('win32')
        simalt ~x
    else
        silent !wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz
    endif
endfunction

function! lq#MakeTags()
    if &filetype == 'help'
        :helptags .
    else
"        execute ':silent !ctags -R --c-kinds=+cdefgmnpstuv --c++-kinds=+cdefgmnpstuv --fields=+iaS --extra=+q .'
        execute ':silent !ctags -R --fields=+iaSszt --c-kinds=+p --c++-kinds=+p --extra=+q --totals .'
    endif
endfunction

function! lq#OpComment(op, nv)
    if a:nv ==# 'n' "normal mode
        let l:line = ''
    else "visual mode
        let begin_line = line("v")
        let end_line   = line(".")
        if(begin_line > end_line)
            let l:line = end_line . "," . begin_line
        elseif begin_line == end_line
            let l:line = begin_line
        else
            let l:line = begin_line . "," . end_line
        endif
    endif
    if a:op == 'add'
        if &filetype == 'c' || &filetype == 'cpp' || &filetype == 'java'
            execute l:line . 's/^/\/\//'
        elseif &filetype == 'vim'
            execute l:line . 's/^/"/'
        elseif &filetype == 'dosbatch'
            execute l:line . 's/^/::/'
        else
            execute l:line . 's/^/#/'
        endif
    elseif a:op == 'del'
        if &filetype == 'c' || &filetype == 'cpp' || &filetype == 'java'
            execute 'silent! ' . l:line . 's/\v^(\s*)\/\//\1/'
        elseif &filetype == 'vim'
            execute 'silent! ' . l:line . 's/\v^(\s*)"/\1/'
        elseif &filetype == 'dosbatch'
            execute 'silent! ' . l:line . 's/\v^(\s*)::/\1/'
        else
            execute 'silent! ' . l:line . 's/\v^(\s*)#/\1/'
        endif
    else
    endif
    match none
endfunction

function! lq#ColumnOp(...)
    if a:0 == 0
        return
    endif

    let args = a:1
    let args = substitute(args, '\\"', '<\\~liq=/>', 'g') "用 <\~liq=/> 替换 \"
    let lst_line   = matchlist(args, '\v-l\=([0-9.^$]*),\s*([0-9.^$]*)')
    let lst_column = matchlist(args, '\v-c\=([0-9.^$]*)')
    let lst_insert = matchlist(args, '\v-i\="([^"]*)"')
    let lst_offset = matchlist(args, '\v-o\=([+-/\*])(\d*)')
    let lst_format = matchlist(args, '\v-f\="([^"]*)"')

    if empty(lst_line) || empty(lst_column) || empty(lst_insert)
        echo 'Column operation parameter:'
        echo '    Must:     -l[ine]=1,25             => [n: number], [.: current], [1: first], [$: last] '
        echo '              -c[olumn]=8              => [n: number], [.: current], [0: begin], [$: end]'
        echo '              -i[nsert]="insert data"  => if want insert ", write \"; if -o is present, it is the 1st value'
        echo '    Optional: -o[ffset]=+1             => [+-*/]'
        echo '              -f[ormat]=" %02X "       => like the 1st parameter in printf(). if want insert ", write \"'
        echo 'Example:'
        echo '    column -l=1,$ -c=0 -i="0x40000000" -o=+16 -f="0x%08X "'
        echo 'by liqiang 2013-4-18 21:20:55'
        return
    else
        let l:line_begin = (lst_line[1]   =~ "[.^$]") ? line(lst_line[1]) : lst_line[1]
        let l:line_end   = (lst_line[2]   =~ "[.^$]") ? line(lst_line[2]) : lst_line[2]
        let l:column     = (lst_column[1] ==# '.'   ) ? col('.')          : lst_column[1]
        let l:insert     = substitute(lst_insert[1], '<\\\~liq=/>', '"', 'g')
    endif

    if empty(lst_offset)
        let l:op     = 'none'
        let l:offset = 'none'
    else
        let l:op     = lst_offset[1]
        let l:offset = lst_offset[2]
        if l:insert =~# '^[a-zA-Z]$'
            let l:bAsciiOp = 1
            let l:insert = char2nr(l:insert)
        else
            let l:bAsciiOp = 0
        endif
    endif

    if empty(lst_format)
        if l:op == 'none'
            let l:format = '%s'
        else
            if l:bAsciiOp == 1
                let l:format = '%c'
            else
                let l:format = '%d'
            endif
        endif
    else
        let l:format = substitute(lst_format[1], '<\\\~liq=/>', '"', 'g')
    endif

    "显示参数
    echo l:line_begin.','.l:line_end.' '.l:column.' '.l:insert.' '.l:op.' '.l:offset.' '.l:format

    "如果当前文件的最大行小于需要插入的行 则插入新行
    let max_line = line("$")
    if l:line_end > max_line
        for i in range(max_line, l:line_end)
            call append(i, "")
        endfor
    endif

    "realy work hard
    for i in range(l:line_begin, l:line_end)
        if l:column ==# '^'     "行首插入
            execute 'silent!' . i . 's/^/\=printf(l:format, l:insert)/'
        elseif l:column ==# '$' "行尾插入
            execute 'silent!' . i . 's/\s*$/\=printf(l:format, l:insert)/'
        else                    "当前位置插入
            "行宽度不够 则添加
            let line_len = strlen(getline(i))
            if(line_len < l:column)
                let add_space = ''
                for j in range(1, l:column-line_len)
                    let add_space .= ' '
                endfor
                execute 'silent!' . i . 's/$/\=printf("%s",add_space)/'
            endif
            "执行 execute 真好用 O(∩_∩)O
            execute 'silent!' . i . 's/\(^.\{' . l:column . '}\)\@<=/\=printf(l:format, l:insert)/'
        endif
        if l:op !=# 'none'
            execute 'let l:insert = l:insert ' . l:op . ' l:offset'
        endif
    endfor
endfunction

function! lq#MakeDoxygenComment()
    let l:MakeDoxygenComment_briefTag="@brief "
    let l:MakeDoxygenComment_paramTag="@param[in] "
    let l:MakeDoxygenComment_returnTag="@return "
    let l:MakeDoxygenComment_blockHeader=""
    let l:MakeDoxygenComment_blockFooter=""

    let l:firstLine = line(".")
    let l:startPos = -1
    let l:endPos   = -1
    let l:line     = ""
    for i in range(10) " 最大10行内获取函数数据
        let l:__line = getline(l:firstLine + i)
        let l:__line = substitute(l:__line, '//.*$', '', '')
        let l:__line = substitute(l:__line, '/\*.\{-}\*/', '', 'g')
        let l:line .= l:__line
        if l:startPos < 0
            let l:startPos=match(l:line, "(")
        endif
        if l:endPos < 0
            let l:endPos=match(l:line, ")")
        endif
        if l:startPos >= 0 && l:endPos >= 0
            break
        endif
        let l:endend = match(l:line, "{")
        if l:endend >= 0
            echo 'Can not find a valid function!'
            return
        endif
    endfor

    if l:startPos < 0 || l:endPos < 0
        echo 'Can not find a valid function!'
        return
    endif

    " return void
    let l:bVoidReturn = match(l:line, '\<void\>')
    if l:bVoidReturn >= 0 && l:bVoidReturn < l:startPos
        let l:bVoidReturn = 1
    else
        let l:bVoidReturn = 0
    endif

    " param void
    let l:bVoidParam = match(l:line, '(\s*void\s*)', l:startPos)
    if l:bVoidParam >= 0
        let l:bVoidParam = 1
    else
        let l:bVoidParam = 0
    endif

    mark d
    let l:funcDesc = expand("<cword>")
    let l:funcDesc = substitute(l:funcDesc, '\C\([A-Z][a-z]\)', '\=tolower("_" . submatch(1))', 'g') " AbcDefGhiJHL -> abc_def_ghiJHL
    let l:funcDesc = substitute(l:funcDesc, '\C\([A-Z]\+\)', {m -> '_' . m[1]}, 'g') " abc_def_ghiJKL -> abc_def_ghi_JHL
    let l:funcDesc = substitute(l:funcDesc, '_', ' ', 'g') " abc_def_ghi_JHL -> abc def ghi JHL
    let l:funcDesc = substitute(l:funcDesc, '\s\+', ' ', 'g')
    let l:funcDesc = substitute(l:funcDesc, '^ ', '', 'g')
    exec "normal! {"
    exec "normal! o/**" . l:MakeDoxygenComment_blockHeader ."\<cr>" . l:MakeDoxygenComment_briefTag . ' ' . l:funcDesc
    let l:synopsisLine=line(".")
    let l:synopsisCol=col(".")
    let l:nextParamLine=l:synopsisLine+2
    if l:bVoidReturn
        exec "normal! a\<cr>\<cr>\<cr>\<cr>\<bs>" . l:MakeDoxygenComment_blockFooter . "*/"
    else
        exec "normal! a\<cr>\<cr>\<cr>\<cr>\<cr>" . l:MakeDoxygenComment_returnTag . "\<cr>\<bs>" . l:MakeDoxygenComment_blockFooter . "*/"
    endif
    exec "normal! `d"

    let l:bFoundParam=0
    if !l:bVoidParam
        let l:identifierRegex='\i\+\([ \t\[\]]*[,)]\)\@='
        let l:matchIndex=match(l:line,l:identifierRegex,l:startPos)
        while (l:matchIndex >= 0)
            let l:bFoundParam=1
            let l:param=matchstr(l:line,l:identifierRegex,l:startPos)
            exec l:nextParamLine
            exec "normal! O" . l:MakeDoxygenComment_paramTag . l:param . "  "
            let l:nextParamLine=l:nextParamLine+1

            exec "normal! `d"
            let l:startPos=(l:matchIndex+strlen(l:param)+1)
            let l:matchIndex=match(l:line,l:identifierRegex,l:startPos)
        endwhile
    endif

    exec l:nextParamLine
    exec "normal! dj"
    if !l:bFoundParam
        if l:bVoidReturn
            exec "normal! k"
        endif
        exec "normal! dd"
    endif
    exec l:synopsisLine
    exec "normal! " . l:synopsisCol . "|"
    startinsert!
endfunction

function! lq#MakeDoxygenComments()
    normal! gg
    while 1
        normal! ]]
        if (expand("<cword>") != '{')
            break
        endif
        normal! {jf(hh
        call lq#MakeDoxygenComment()
        normal! ]]
    endwhile
endfunction

let g:__code_table = ['utf8', 'unicode', 'ansi', 'chinese', 'taiwan', 'japan', 'korea', 'ucs-2be', 'ucs-2le', 'ucs-4be', 'ucs-4le', 'utf-16be', 'utf-16le', 'utf-32be', 'utf-32le']

function! lq#ShowCodeHelp()
        echo 'Code parameter:'
        echo '       0:utf8*      1:unicode    2:ansi*'
        echo '       3:chinese*   4:taiwan     5:japan      6:korea'
        echo '       7:ucs-2be    8:ucs-2le    9:ucs-4be   10:ucs-4le'
        echo '      11:utf-16be  12:utf-16le* 13:utf-32be  14:utf-32le'
        echo ' '
        echo 'Code bit-width:'
        echo '      utf8   1-6 byte'
        echo '      utf16  >=2 byte'
        echo '      utf32  >=4 byte'
        echo '      ucs2   ==2 byte'
        echo '      ucs4   ==4 byte'
        echo ' '
endfunction

function! lq#CodeOp(...)
    if a:0 != 1
        call lq#ShowCodeHelp()
        echo ':help encoding-values<Enter>  by lq 2013/5/7 20:33:15'
        return
    endif

    if a:1 =~ '^\d\+$'
        let l:recode = g:__code_table[a:1]
    else
        let l:recode = a:1
    endif

    execute 'set fileencoding=' . l:recode
    echo printf("Set coding is %s", l:recode)
endfunction

function! lq#ReopenOp(...)
    if a:0 != 1
        call lq#ShowCodeHelp()
        echo 'if the param is "--", i will traverse all coding to encode the file'
        echo ' '
        echo ':help encoding-values<Enter>  by lq 2013-5-29 20:44:39'
        return
    endif

    if a:1 == '--'
        for i in range(len(g:__code_table))
            let l:recode = g:__code_table[i]
            execute 'set fileencodings=' . l:recode
            silent! e!
            redraw!
            let user_input = input('Reopen with ' . l:recode . ', continue (y/n): ')
            if(user_input !=? 'y')
                break
            endif
        endfor
        echo 'Finish!'
        return
    endif

    if a:1 =~ '^\d\+$'
        let l:recode = g:__code_table[a:1]
    else
        let l:recode = a:1
    endif

    execute 'set fileencodings=' . l:recode
    silent! e!
    echo printf("Reopen with %s", l:recode)
endfunction

function! lq#SmartPreProcCommenter()
    mark y
    let saved_wrapscan=&wrapscan
    set nowrapscan
    let elsecomment=""
    let endcomment=""
    try
        " Find the last #if in the buffer
        $?^\s*#if
        while 1
            " Build the comments for later use, based on current line
            let content=getline('.')
            let elsecomment=lq#BuildElseComment(content,elsecomment)
            let endcomment=lq#BuildEndComment(content,endcomment)
            " Change # into ## so we know we've already processed this one
            " and don't find it again
            s/^\s*\zs#/##
            " Find the next #else, #elif, #endif which must belong to this #if
            /^\s*#\(elif\|else\|endif\)
            let content=getline('.')
            if match(content,'^\s*#elif') != -1
                " For #elif, treat the same as #if, i.e. build new comments
                continue
            elseif match(content,'^\s*#else') != -1
                " For #else, add/replace the comment
                call setline('.',lq#ReplaceComment(content,elsecomment))
                s/^\s*\zs#/##
                " Find the #endif
                /^\s*#endif
            endif
            " We should be at the #endif now; add/replace the comment
            call setline('.',lq#ReplaceComment(getline('.'),endcomment))
            s/^\s*\zs#/##
            " Find the previous #if
            ?^\s*#if
        endwhile
    catch
        " Once we have an error (pattern not found, i.e. no more left)
        " Change all our ## markers back to #
        silent! %s/^\s*\zs##/#
    endtry

    let &wrapscan=saved_wrapscan
    normal `y
endfunc
let s:PreProcCommentMatcher = '#\a\+\s\+\zs.\{-}\ze\(\s*\/\*.\{-}\*\/\)\?\s*$'
function! lq#BuildElseComment(content, previous)
    let expression=escape(matchstr(a:content,s:PreProcCommentMatcher), '\~&')
    if match(a:content,'#ifdef') != -1
        return "/* NOT def ".expression." */"
    elseif match(a:content,'#ifndef') != -1
        return "/* def ".expression." */"
    elseif match(a:content,'#if') != -1
        return "/* NOT ".expression." */"
    elseif match(a:content,'#elif') != -1
        return substitute(a:previous,' \*/',', '.expression.' */','')
    else
        return ""
    endif
endfunc
function! lq#BuildEndComment(content, previous)
    let expression=escape(matchstr(a:content,s:PreProcCommentMatcher), '\~&')
    if match(a:content,'#ifdef') != -1
        return "/* def ".expression." */"
    elseif match(a:content,'#ifndef') != -1
        return "/* NOT def ".expression." */"
    elseif match(a:content,'#if') != -1
        return "/* ".expression." */"
    elseif match(a:content,'#elif') != -1
        return substitute(a:previous,' \*/',', '.expression.' */','')
    else
        return ""
    endif
endfunc
function! lq#ReplaceComment(content, comment)
    let existing=escape(matchstr(a:content,'#\a\+\s\+\zs.\{-}\s*$'), '\~&')
    if existing == ""
        return substitute(a:content,'^\s*#\a\+\zs.*'," ".a:comment,'')
    elseif existing != a:comment && match(existing,'XXX') == -1
        return a:content." /* XXX */"
    else
        return a:content
    endif
endfunc

" Sum
function! lq#SumNumbers(...) range
    " Work
    let l:sum = str2float("0.0")
    let l:txts = lq#GetVisualSelectText('split_return')
    for l:str in l:txts
        let l:pos = 0
        while 1
            let l:cur = matchstr(l:str, '0[xX][0-9a-fA-F]\+\|[-+]\?\d\+\(\.\d\+\)\?', l:pos)
            let l:pos = stridx(l:str, l:cur, l:pos)
            if l:cur == "" || l:pos == -1
                break
            endif
            let l:sum += eval(l:cur)
            let l:pos = l:pos + strlen(l:cur)
        endwhile
    endfor

    "Drop the fractional amount if it's zero
    "TODO: When scientific notation is supported, this will need to be changed
    if abs(l:sum) == trunc(abs(l:sum))
        let l:sum = float2nr(l:sum)
    endif

    let l:sum_int = float2nr(l:sum)
    let l:sum_hex = printf("0x%X", l:sum_int)
    if l:sum_int < 1024
        let l:sum_size = printf("%dB", l:sum_int)
    elseif l:sum_int < 1024*1024
        let l:sum_size = printf("%.1fKB", l:sum_int/1024.0)
    elseif l:sum_int < 1024*1024*1024
        let l:sum_size = printf("%.1fMB", l:sum_int/1024.0/1024.0)
    else
        let l:sum_size = printf("%.1fGB", l:sum_int/1024.0/1024.0/1024.0)
    endif

    "Show
    redraw
    echo "sum =" l:sum l:sum_size l:sum_hex

    "save the sum in the variable b:sum, and optionally
    "into the register specified by the user
    let b:sum = l:sum
    if a:0 == 1 && len(a:1) > 0
        execute "let @" . a:1 . " = printf('%g', b:sum)"
    endif
endfunction

" Run It
function! lq#RunIt()
    if &filetype == 'python'
        :!python %
    elseif &filetype == 'sh'
        :!bash %
    elseif &filetype == 'dosbatch' || &filetype == 'jlink'
        :!%
    else
        echohl Error | echo "Can't execute this kind of file!" | echohl None
    endif
endfunction

" Compile It
function! lq#CompileIt()
    if expand("%:e") == 'uvproj'
        Makekeil %
    elseif expand("%:e") == 'ewp'
        Makeiar %
    elseif exists("b:current_compiler") && b:current_compiler=='keil'
        Makekeil
    elseif exists("b:current_compiler") && b:current_compiler=='iar'
        Makeiar
    elseif &filetype == 'cpp' || &filetype == 'c' || &filetype == 'make'
        Makegcc
    elseif &filetype == 'sh'
        make
    else
        echohl Error | echo "Can't compile this kind of file!" | echohl None
    endif
endfunction

" Open scratch buffer with command:
" 1st:command 2nd:filetype 3rd:reentry 4th:afterexe
function! lq#Scratch(...) abort range
    " Parse the params
    if a:0 == 0
        let l:cmd       = ''
        let l:ft        = 'text'
        let l:reentry   = 0
        let l:afterexe  = 2
    elseif a:0 == 1
        let l:cmd       = a:1
        let l:ft        = 'text'
        let l:reentry   = 1
        let l:afterexe  = 2
    elseif a:0 == 2
        let l:cmd       = a:1
        let l:ft        = a:2
        let l:reentry   = 1
        let l:afterexe  = 2
    elseif a:0 == 3
        let l:cmd       = a:1
        let l:ft        = a:2
        let l:reentry   = a:3
        let l:afterexe  = 2
    else "if a:0 == 4
        let l:cmd       = a:1
        let l:ft        = a:2
        let l:reentry   = a:3
        let l:afterexe  = a:4
    endif
    " Read inside command
    if l:cmd != ''
        " Expand the % for curent file name
        let l:cmd = substitute(l:cmd, "%", escape(expand("%"), '\\'), "g")
        " Check the !
        let l:isshell = match(l:cmd, '^\s*!')==-1 ? 0 : 1
        " before or after execute the command
        if l:afterexe == 2
            " Sometimes before read the command will be error
            let l:afterexe = l:isshell
        endif
        if !l:afterexe
            " Before read the command
            redir => l:result
            silent execute l:cmd
            redir END
        endif
    endif
    " Reuse or create new buffer.
    if l:reentry && exists("t:rrbufnr") && bufwinnr(t:rrbufnr) > 0
        " Reuse buffer
        execute "keepjumps ".bufwinnr(t:rrbufnr)."wincmd W"
        normal ggdG
    else
        " Create a new scratch (temporary) buffer
        keepjumps silent! new
        setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomore
        nnoremap <buffer> q :q<cr>
        if l:reentry
            let t:rrbufnr=bufnr('%')
        endif
    endif
    " status line
    setlocal statusline=%0*\ %f
    if l:reentry
        let &l:statusline .= ' ' . l:cmd
    else
        let &l:statusline .= ' [^_^] ' . l:cmd
    endif
    setlocal statusline+=%<%=
    setlocal statusline+=%Bh
    setlocal statusline+=\ %{&fenc==\"\"?&enc:&fenc}
    setlocal statusline+=/%{&fileformat}
    setlocal statusline+=/%{&filetype==\"\"?\"?\":&filetype}
    setlocal statusline+=\ %c:%l/%L\ %P
    " filetype
    if l:ft == 'autodetect'
        if l:cmd =~ '\s\(--help\|-h\)\>' || l:cmd =~ '^!man\>'
            let l:ft = 'man'
        elseif l:cmd =~ '\<diff\>'
            let l:ft = 'diff'
        else
            let l:ft = 'text'
        endif
    endif
    let &filetype = l:ft
    " Put the excute result
    if l:cmd != ''
        if l:afterexe
            " After read the command
            if l:isshell
                silent execute 'read ' . l:cmd
            else
                redir => l:result
                silent execute l:cmd
                redir END
                silent put! =l:result
            endif
        else
            silent put! =l:result
        endif
        normal gg
    endif
endfunction

" Switch to VCS root, if there is one.
function! lq#SwitchVCSRoot() abort
    if &buftype =~# '\v(nofile|terminal)' || expand('%') =~# '^fugitive'
        return
    endif
    if !exists('s:cache')
        let s:cache = {}
    endif
    let dirs   = [ '.git', '.hg', '.svn' ]
    let curdir = resolve(expand('%:p:h'))
    if !isdirectory(curdir)
        echohl WarningMsg | echo 'No such directory: '. curdir | echohl NONE
        return
    endif
    if has_key(s:cache, curdir)
        execute 'cd' fnameescape(s:cache[curdir])
        return
    endif
    for dir in dirs
        let founddir = finddir(dir, curdir .';')
        if !empty(founddir)
            break
        endif
    endfor
    let dir = empty(founddir) ? curdir : resolve(fnamemodify(founddir, ':p:h:h'))
    let s:cache[curdir] = dir
    execute 'cd' fnameescape(dir)
endfunction

" Command It
function! lq#CommandIt()
    let l:lnum = line('.')
    let l:line = substitute(getline(l:lnum), '^\s*\(#\|//\|\*\|"\)\s*', '', '')
    if l:line != ''
        exe l:line
    endif
endfunction
function! lq#CommandItV() range
    let l:lnum = line("'<")
    let l:lend = line("'>")
    let l:lines = []
    while l:lnum <= l:lend
        let l:line = substitute(getline(l:lnum), '^\s\+', '', '')
        if l:line != '' && match(l:line, '^#')==-1
            let l:lines += [l:line]
        endif
        let l:lnum += 1
    endwhile
    for l:line in l:lines
        exe l:line
    endfor
endfunction

" Hex folder
function! lq#HexFoldexpr(lnum)
    let l      = getline(a:lnum+0)[10:]
    let l_next = getline(a:lnum+1)[10:]
    if l == l_next
        return 1 " fold start
    else
        let l_prev = getline(a:lnum-1)[10:]
        if l == l_prev
            return "<1" " fold end
        else
            return 0 " not fold
        endif
    endif
endfunction
function! lq#HexFoldtext()
    let foldedlinecount = v:foldend - v:foldstart + 1
    let line = getline(v:foldstart) . ' [' . foldedlinecount . '] '
    if line('$') == v:foldend
        let end  = getline(v:foldend)[:7]
        let line = line . '=>' . end . ' '
    end
    return line
endfunction
function! lq#HexFold()
    setlocal foldtext=lq#HexFoldtext()
    setlocal foldexpr=lq#HexFoldexpr(v:lnum)
    setlocal foldmethod=expr
endfunction

" binary buffer read post
function! lq#BinaryBufReadPost()
    " not record undo info
    let old_undolevels = &undolevels
    set undolevels=-1

    " read
    if exists("b:binary_little_endian")
        silent! exe '%!xxd -e'
        setlocal nomodifiable
        setlocal readonly
    else
        silent! exe '%!xxd'
    endif
    setlocal filetype=xxd
    setlocal noendofline    " Avoid invalid <0a>
    call lq#HexFold()

    " undo restore
    let &undolevels = old_undolevels
    unlet old_undolevels
endfunction

" Hex(binary) endian Toggle
function! lq#HexEndianToggle()
    if !&binary
        setlocal binary
        let b:binary_little_endian = 1
    endif
    if exists("b:binary_little_endian")
        setlocal modifiable
        setlocal noreadonly
        unlet b:binary_little_endian
    else
        let b:binary_little_endian = 1
    endif
    edit
endfunction

" Load coding plugin
function! lq#LoadCodingPlugin()
    Xhighlight
"    Xycm
    edit

    Xsignify
endfunction

" Show Lists
function! lq#ShowLists()
    if &ft == 'markdown'
        Toc
    else
        TagbarToggle
    endif
endfunction

" Document converter
function! lq#DocumentConverter(docfile, docfile_abs)
    setlocal nomodified
    let l:ext = fnamemodify(a:docfile, ":e")
    if has('win32')
        let l:txtfile  = a:docfile_abs . '.txt'
        let l:sdocfile = shellescape(a:docfile_abs, 0)
    else
        let l:txtfile  = a:docfile . '.txt'
        let l:sdocfile = shellescape(a:docfile, 0)
    endif
    let l:stxtfile = shellescape(l:txtfile, 0)
    if !filereadable(l:txtfile)
        let l:command = ''
        if l:ext == 'pdf'
            let l:command = 'pdftotext -enc UTF-8 -layout -nopgbrk ' . l:sdocfile . ' ' . l:stxtfile
        elseif l:ext == 'xls' || l:ext == 'xlsx' || l:ext == 'xlsm'
            if has('win32')
                let l:svbscript = shellescape(fnamemodify($MYVIMRC, ":p:h") . "/res/windows/xlstocsv.vbs", 0)
                let l:command = 'wscript ' . l:svbscript . ' ' . l:sdocfile . ' ' . l:stxtfile
            else
                echomsg "XLS converter is not support your OS !"
            endif
        elseif l:ext == 'doc' || l:ext == 'docx' || l:ext == 'docm'
            let l:command = 'pandoc -o ' . l:stxtfile . ' ' . l:sdocfile
        endif
        if l:command == ''
            echomsg "Not support file type [" . l:ext . "] !"
            return
        else
            echo "converting " . a:docfile . " ..."
            let l:output=system(l:command)
            if v:shell_error
                echomsg "command execute fail: " . l:command
                echomsg l:output
                return
            endif
        endif
    endif
    execute "edit " . l:txtfile
    if l:ext == 'xls' || l:ext == 'xlsx' || l:ext == 'xlsm'
        set filetype=csv
    endif
endfunction

" ARM gdb, need vim-8.1
function! lq#TermArmGdb()
    packadd termdebug
    let g:termdebugger = "arm-none-eabi-gdb"
    Termdebug
endfunction

" Open current directory
function! lq#OpenDir(is_cwd)
    if has('win32')
        let tool = 'explorer'
    else
        let tool = 'open'
    endif

    if a:is_cwd
        let path = getcwd()
    else
        let path = expand("%:p:h")
    endif

    execute ':silent !' . tool . ' "' . path . '"'
endfunction

" Append string to reg 'o'
let @o = "<leader>o: append data to reg 'o', <leader>O: show, :let @o='': clear\n\n"
function! lq#Append2RegO(string, addreturn)
    let @o .= a:string
    if a:addreturn
        let @o .= "\n"
    endif
endfunction

