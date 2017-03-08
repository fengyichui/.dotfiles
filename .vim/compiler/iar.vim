" Vim compiler file
" Compiler:         iar Compiler
" Maintainer:       liqiang
" Latest Revision:  2016-11-16

if exists("current_compiler")
  finish
endif
let current_compiler = "iar"

let s:cpo_save = &cpo
set cpo&vim

CompilerSet errorformat=
        \%f(%l)\ :\ %trror%m,
        \%f(%l)\ :\ %tarning%m

let &cpo = s:cpo_save
unlet s:cpo_save
