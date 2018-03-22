" Vim compiler file
" Compiler:         Keil Compiler
" Maintainer:       liqiang
" Latest Revision:  2016-11-16

if exists("current_compiler")
  finish
endif
let current_compiler = "bash"

let s:cpo_save = &cpo
set cpo&vim

CompilerSet errorformat=%f:\ line\ %l:\ %m

let &cpo = s:cpo_save
unlet s:cpo_save
