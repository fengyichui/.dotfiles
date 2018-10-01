" ============================================================================
" File:        terminal.vim
" Description: terminal shape
" Author:      liqiang
" Licence:     Vim licence
" Version:     1.0
" Note:
" ============================================================================

if has('gui_running')
    finish
endif

if exists('g:loaded_terminal') && g:loaded_terminal
    finish
endif
let g:loaded_terminal = 1


" Fixkey_setKey() and Fixkey_setNewKey() fork from: https://github.com/drmikehenry/vim-fixkey
function! Fixkey_setKey(key, keyCode)
    execute "set " . a:key . "=" . a:keyCode
endfunction

function! Fixkey_mapKey(key, value)
    execute "map  " . a:key . " " . a:value
    execute "map! " . a:key . " " . a:value
endfunction

let g:Fixkey_numSpareKeys = 50
let g:Fixkey_spareKeysUsed = 0

" Allocate a new key, set it to use the passed-in keyCode, then map it to
" the passed-in key.
" New keys are taken from <F13> through <F37> and <S-F13> through <S-F37>,
" for a total of 50 keys.
" <F13>,<F14> used for focus
function! Fixkey_setNewKey(key, keyCode)
    if g:Fixkey_spareKeysUsed >= g:Fixkey_numSpareKeys
        echohl WarningMsg
        echomsg "Unable to map " . a:key . ": ran out of spare keys"
        echohl None
        return
    endif
    let fn = g:Fixkey_spareKeysUsed
    let half = g:Fixkey_numSpareKeys / 2
    let shift = ""
    if fn >= half
        let fn -= half
        let shift = "S-"
    endif
    let newKey = "<" . shift . "F" . (15 + fn) . ">"
    call Fixkey_setKey(newKey, a:keyCode)
    call Fixkey_mapKey(newKey, a:key)
    let g:Fixkey_spareKeysUsed += 1
endfunction

" key fix
function! s:key_fix()
    " Get the keycode
    "   :iunmap <c-v>
    "   <ctrl-v><something-key> (insert mode)
    "
    " Get terminfo:
    "   $ infocmp

    """""""
    " ALT "
    """""""
    " leaving out problematic characters: 'O', double quote, pipe and '['
    let ascii_nums = [33] + range(35, 61) + range(63, 78) + range(80, 90) + range(94, 123) + [125, 126]
    let printable_characters = map(ascii_nums, 'nr2char(v:val)')
    for char in printable_characters
        call Fixkey_setKey("<M-".char.">", "\e".char)
    endfor

    """"""""
    " CTRL "
    """"""""
    " for <ctrl-enter> in mintty
    call Fixkey_setNewKey("<C-CR>", "")
endfunction

" fix alt/ctrl key
call s:key_fix()

" xterm cursor
" 1 or 0 -> blinking block
" 3 -> blinking underscore
" 4 -> solid underscore
" 5 -> blinking vertical bar
" 6 -> solid vertical bar
let s:cursor_normal  = "\e[1 q" " blinking block
let s:cursor_insert  = "\e[5 q" " blinking vertical bar
let s:cursor_replace = "\e[3 q" " blinking underscore

" tmux and xterm check
if !exists('$TMUX')
    if &term =~ 'xterm'
        let &t_ti = s:cursor_normal . &t_ti
        let &t_SI = s:cursor_insert . &t_SI
        let &t_SR = s:cursor_replace . &t_SR
        let &t_EI = s:cursor_normal . &t_EI
        let &t_te = &t_te
    endif
    finish
endif

" tmux key fix
function! s:tmux_key_fix()
    """"""""
    " CTRL "
    """"""""
    " for CTRL-F12 (only for TERM=tmux_256color)
"    exe 'set <F36>=[24;5~'
"    map <F36> <C-F12>
"    map! <F36> <C-F12>

    """""""""
    " SHIFT "
    """""""""
    " for SHIFT-F12 (only for TERM=tmux_256color)
"    exe 'set <S-F12>=[24;2~'

    """""""
    " ALT "
    """""""
    " ALT-[F1-F12] (RVCT, TMUX)
"    call Fixkey_setNewKey("<M-F1>",  "\e\e[11~")
"    call Fixkey_setNewKey("<M-F2>",  "\e\e[12~")
"    call Fixkey_setNewKey("<M-F3>",  "\e\e[13~")
"    call Fixkey_setNewKey("<M-F4>",  "\e\e[14~")
"    call Fixkey_setNewKey("<M-F5>",  "\e\e[15~")
"    call Fixkey_setNewKey("<M-F6>",  "\e\e[17~")
"    call Fixkey_setNewKey("<M-F7>",  "\e\e[18~")
"    call Fixkey_setNewKey("<M-F8>",  "\e\e[19~")
"    call Fixkey_setNewKey("<M-F9>",  "\e\e[20~")
"    call Fixkey_setNewKey("<M-F10>", "\e\e[21~")
    call Fixkey_setNewKey("<M-F11>", "\e\e[23~")
    call Fixkey_setNewKey("<M-F12>", "\e\e[24~")
endfunction

" fix key
call s:tmux_key_fix()

" Wrap for tmux
function! s:tmux_wrap(s) " {{{
    " To escape a sequence through tmux:
    "
    " * Wrap it in these sequences.
    " * Any <Esc> characters inside it must be doubled.
    let tmux_start = "\ePtmux;"
    let tmux_end   = "\e\\"

    return tmux_start . substitute(a:s, "\e", "\e\e", 'g') . tmux_end
endfunction " }}}

" Screen, Focus(TMUX: set -sg focus-events on)
let s:save_screen = "\e[?1049h"
let s:restore_screen = "\e[?1049l"
let s:enable_focus_reporting = "\e[?1004h"
let s:disable_focus_reporting = "\e[?1004l"

" Tmux cursor shape
let s:tmux_cursor_normal  = s:tmux_wrap(s:cursor_normal)
let s:tmux_cursor_insert  = s:tmux_wrap(s:cursor_insert)
let s:tmux_cursor_replace = s:tmux_wrap(s:cursor_replace)

function s:do_autocmd(event)
    let cmd = getcmdline()
    let pos = getcmdpos()
    exec 'silent doautocmd ' . a:event . ' %'
    call setcmdpos(pos)
    return cmd
endfunction

" This function copied and adapted from https://github.com/sjl/vitality.vim
" If you want to try to understand what is going on, look into comments from
" that plugin.
function! s:tmux_fix()
    " This escape sequence is escaped to get through Tmux without being "eaten"
    let escaped_enable_focus_reporting = s:tmux_wrap(s:enable_focus_reporting) . s:enable_focus_reporting

    " Vim termcap
    let &t_SI = s:tmux_cursor_insert . &t_SI
    let &t_SR = s:tmux_cursor_replace . &t_SR
    let &t_EI = s:tmux_cursor_normal . &t_EI
    let &t_ti = s:tmux_cursor_normal . escaped_enable_focus_reporting . s:save_screen . &t_ti
    let &t_te = s:disable_focus_reporting . s:restore_screen . &t_te

    " When Tmux 'focus-events' option is on, Tmux will send <Esc>[O when the
    " window loses focus and <Esc>[I when it gains focus.
    exec "set <F13>=\e[O"
    exec "set <F14>=\e[I"

    nnoremap <silent> <F13> :silent doautocmd FocusLost %<CR>
    nnoremap <silent> <F14> :silent doautocmd FocusGained %<CR>

    onoremap <silent> <F13> <Esc>:silent doautocmd FocusLost %<CR>
    onoremap <silent> <F14> <Esc>:silent doautocmd FocusGained %<CR>

    vnoremap <silent> <F13> <Esc>:silent doautocmd FocusLost %<CR>gv
    vnoremap <silent> <F14> <Esc>:silent doautocmd FocusGained %<CR>gv

    inoremap <silent> <F13> <C-O>:silent doautocmd FocusLost %<CR>
    inoremap <silent> <F14> <C-O>:silent doautocmd FocusGained %<CR>

    cnoremap <silent> <F13> <C-\>e<SID>do_autocmd('FocusLost')<CR>
    cnoremap <silent> <F14> <C-\>e<SID>do_autocmd('FocusGained')<CR>
endfunction

" FocusGaine
let s:tmux_is_running = 0
let s:tmux_vim_focus_losting_lock = '/tmp/tmux_vim_focus_losting'
function! s:tmux_focus_gained()
    if s:tmux_is_running
        " When gain focus, vim can't handle normal-mode cursor sharp
        if mode() == 'n'
            " Check locking
            let timeout = 100
            while timeout > 0
                " delay 10ms to wait losting-lock file create
                sleep 10m
                if empty(glob(s:tmux_vim_focus_losting_lock))
                    break
                endif
                let timeout -= 1
            endwhile
            if timeout == 0
                call delete(s:tmux_vim_focus_losting_lock)
                echoerr "Force to delete 'tmux_vim_focus_losting_lock' file!"
            endif
            " force cursor to normal mode
            silent! execute '!echo -ne ' . shellescape(s:tmux_cursor_normal, 0)
        endif
    endif
    let s:tmux_is_running = 1
endfunction

" FocusLosted
function! s:tmux_focus_losted()
    " Lock
    call writefile([], s:tmux_vim_focus_losting_lock)
    " When lost focus, vim can't handle terminal-default cursor sharp. So force cursor to insert mode
    silent! execute '!echo -ne ' . shellescape(s:tmux_cursor_insert, 0)
    " Unlock
    call delete(s:tmux_vim_focus_losting_lock)
endfunction

" Fix tmux issue
call <SID>tmux_fix()

" When '&term' changes values for '<F13>', '<F14>', '&t_ti' and '&t_te' are
" reset. Below autocmd restores values for those options.
autocmd TermChanged * call <SID>tmux_fix()

" restore vim 'autoread' functionality
autocmd FocusGained * call s:tmux_focus_gained()
autocmd FocusLost   * call s:tmux_focus_losted()

