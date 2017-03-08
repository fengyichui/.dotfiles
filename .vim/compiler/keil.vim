" Vim compiler file
" Compiler:         Keil Compiler
" Maintainer:       liqiang
" Latest Revision:  2016-11-16

if exists("current_compiler")
  finish
endif
let current_compiler = "keil"

let s:cpo_save = &cpo
set cpo&vim

CompilerSet errorformat=
        \%DEntering\ directory:\ %f,%XLeaving\ directory,
        \%f(%l):\ %trror:\ %m,
        \%f(%l):\ %tarning:\ %m,
        \%f:\ %trror:\ %m,
        \%f:\ %tarning:\ %m

let &cpo = s:cpo_save
unlet s:cpo_save
