" A simple syntax highlighting, simply alternate colors between two
" adjacent columns

let s:cpo_save = &cpo
set cpo&vim

if exists("b:current_syntax")
    finish
endif

let s:col = '\%([^,"]*,\|[^\t"]*\t\)'

syn region CSVString start=+L\="+ skip=+""\|\\$+ excludenl end=+"+

" Has a problem with the last line!
exe 'syn match CSVDelimiter /' . s:col . '/ms=e,me=e contained'

exe 'syn match CSVColumn1 nextgroup=CSVColumn2 /' . s:col . '/ contains=CSVDelimiter'
exe 'syn match CSVColumn2 nextgroup=CSVColumn3 /' . s:col . '/ contains=CSVDelimiter'
exe 'syn match CSVColumn3 nextgroup=CSVColumn4 /' . s:col . '/ contains=CSVDelimiter'
exe 'syn match CSVColumn4 nextgroup=CSVColumn5 /' . s:col . '/ contains=CSVDelimiter'
exe 'syn match CSVColumn5 nextgroup=CSVColumn6 /' . s:col . '/ contains=CSVDelimiter'
exe 'syn match CSVColumn6 nextgroup=CSVColumn7 /' . s:col . '/ contains=CSVDelimiter'
exe 'syn match CSVColumn7 nextgroup=CSVColumn0 /' . s:col . '/ contains=CSVDelimiter'
exe 'syn match CSVColumn0 nextgroup=CSVColumn1 /' . s:col . '/ contains=CSVDelimiter'

" Not really needed
syn case ignore

hi def link CSVDelimiter Ignore
hi def link CSVString Todo

hi def link CSVColumn0 Keyword
hi def link CSVColumn1 Function
hi def link CSVColumn2 DefinedName
hi def link CSVColumn3 GlobalConstant
hi def link CSVColumn4 Title
hi def link CSVColumn5 Special
hi def link CSVColumn6 MoreMsg
hi def link CSVColumn7 WarningMsg

" Set the syntax variable {{{2
let b:current_syntax="csv"

let &cpo = s:cpo_save
unlet s:cpo_save
