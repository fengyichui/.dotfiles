" Vim syntax file
" Language:     Keil scatter file
" Maintainer:   liqiang
" Last Change:  2016/11/29
" Revision:     1.0

if exists("b:current_syntax")
  finish
endif

syn case match
syn keyword scatterTodo             NOTE TODO XXX contained
syn case ignore

syn region  scatterComment          start=";" end="$" contains=scatterTodo
syn region  scatterCmdLine          start="#!" end="$"
syn keyword scatterFunction         ImageBase ImageLength ImageLimit AlignExpr LoadBase LoadLength LoadLimit defined GetPageSize SizeOfHeaders ScatterAssert
syn keyword scatterLoadAttribute    ABSOLUTE ALIGN NOCOMPRESS OVERLAY PI PROTECTED RELOC
syn keyword scatterExeAttribute     ABSOLUTE ALIGN ALIGNALL ANY_SIZE EMPTY FILL FIXED NOCOMPRESS OVERLAY PADVALUE PI SORTTYPE UNINIT ZEROPAD
syn match   scatterInputAttribute   "+\(RO-CODE\|RO-DATA\|RO\|RW-DATA\|RW-CODE\|RW\|XO\|ZI\|ENTRY\|CODE\|CONST\|TEXT\|DATA\|BSS\|FIRST\|LAST\)\>"
syn keyword scatterExpression       OR AND LAND LOR
syn region  scatterDefine           start="^\s*#define\>" end="$" contains=ALLBUT
syn match   scatterModule           "\(\S\+\.o\|\.ANY\)\>"
syn match   scattercNumber          "\<\d\+\>"
syn match   scattercNumber          "\<0x\x\+\>"


hi def link scatterTodo             Todo
hi def link scatterComment          Comment
hi def link scatterCmdLine          Label
hi def link scatterFunction         Function
hi def link scatterLoadAttribute    Statement
hi def link scatterExeAttribute     Statement
hi def link scatterInputAttribute   Statement
hi def link scatterExpression       Statement
hi def link scatterDefine           Macro
hi def link scatterModule           String
hi def link scattercNumber          Number

let b:current_syntax = "scatter"

