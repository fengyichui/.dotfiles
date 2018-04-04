"
"  Vim Tail
"
"  Author:      Cosmin Popescu <cosminadrianpopescu at gmail dot com>
"               liqiang modify
"  Version:     1.00 (2016-10-06)
"  Requires:    Vim 7
"  License:     GPL
"
"  Description:
"
"  Small plugin to tail a modified file
"

if exists('g:loaded_tail')
    finish
endif
let g:loaded_tail = 1

let s:tail_echo_wait_table = ['', '.', '..', '...']

function! s:tail_update()
    let l:cur_win_id = win_getid()
    if l:cur_win_id!=s:tail_win_id
        call win_gotoid(s:tail_win_id)
    endif

    if line('$')==line(".") && mode()=='n'
        let l:tail_file_line_save = s:tail_file_line
        silent edit
        silent normal Gzb
        let s:tail_file_line = line('$')
        let l:append_lines = s:tail_file_line - l:tail_file_line_save
        if l:append_lines
            let s:tail_echo_string = "append " . string(append_lines) . " lines"
        endif
        echo s:tail_echo_string . s:tail_echo_wait_table[s:tail_echo_index]
        let s:tail_echo_index = (s:tail_echo_index + 1) % 4
    endif

    if l:cur_win_id!=s:tail_win_id
        call win_gotoid(l:cur_win_id)
    endif
endfunction

function! tail#tick(timer_id)
    if exists('s:tail_timer_id')
        call s:tail_update()
    endif
endfunction

function! tail#start()
    silent edit
    silent normal Gzb
    let s:tail_echo_string = ""
    let s:tail_echo_index = 0
    let s:tail_win_id = win_getid()
    let s:tail_file_line = line('$')
    let s:tail_timer_id = timer_start(1000, 'tail#tick', {'repeat': -1})
endfunction

function! tail#stop()
    if exists('s:tail_timer_id')
        call timer_stop(s:tail_timer_id)
    endif
endfunction

function! tail#toggle()
    if exists('s:tail_running')
        echohl Error | echo "tail stop!" | echohl None
        unlet s:tail_running
        call tail#stop()
    else
        setlocal wrap
        echohl Label | echo "tail start!" | echohl None
        let s:tail_running = 1
        call tail#start()
    endif
endfunction

command! -nargs=0 TailToggle call tail#toggle()

