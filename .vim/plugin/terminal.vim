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
    exec "set <F24>=\e[O"
    exec "set <F25>=\e[I"

    nnoremap <silent> <F24> :silent doautocmd FocusLost %<CR>
    nnoremap <silent> <F25> :silent doautocmd FocusGained %<CR>

    onoremap <silent> <F24> <Esc>:silent doautocmd FocusLost %<CR>
    onoremap <silent> <F25> <Esc>:silent doautocmd FocusGained %<CR>

    vnoremap <silent> <F24> <Esc>:silent doautocmd FocusLost %<CR>gv
    vnoremap <silent> <F25> <Esc>:silent doautocmd FocusGained %<CR>gv

    inoremap <silent> <F24> <C-O>:silent doautocmd FocusLost %<CR>
    inoremap <silent> <F25> <C-O>:silent doautocmd FocusGained %<CR>

    cnoremap <silent> <F24> <C-\>e<SID>do_autocmd('FocusLost')<CR>
    cnoremap <silent> <F25> <C-\>e<SID>do_autocmd('FocusGained')<CR>
endfunction

let s:tmux_is_running = 0

" FocusGaine
function! s:tmux_focus_gained()
    if s:tmux_is_running
        if mode() == 'n'
            " FIXME:
            " sleep 100m
            silent! execute '!echo -ne ' . shellescape(s:tmux_cursor_normal, 0)
        endif
    endif
    let s:tmux_is_running = 1
endfunction

" FocusLosted
function! s:tmux_focus_losted()
    silent! execute '!echo -ne ' . shellescape(s:tmux_cursor_insert, 0)
endfunction

" Fix tmux issue
call <SID>tmux_fix()

" When '&term' changes values for '<F24>', '<F25>', '&t_ti' and '&t_te' are
" reset. Below autocmd restores values for those options.
autocmd TermChanged * call <SID>tmux_fix()

" restore vim 'autoread' functionality
autocmd FocusGained * call s:tmux_focus_gained()
autocmd FocusLost   * call s:tmux_focus_losted()

