" Vim color file
" Maintainer:   Jonathan Filip, liqiang modify
"
" 20160927 modify by liqiang
"
" GUI / 256 color terminal
"

set background=dark
hi clear
if exists("syntax_on")
    syntax reset
endif
let g:colors_name="lucius_qli"

" Base color
" ----------
hi Normal           guifg=#e4e4e4           guibg=#1b1d1e
hi Normal           ctermfg=254             ctermbg=234

" Comment Group
" -------------
" any comment
hi Comment          guifg=#808080                                   gui=italic
hi Comment          ctermfg=243                                     cterm=italic

" Constant Group
" --------------
" any constant
hi Constant         guifg=#50d6de                                   gui=none
hi Constant         ctermfg=80                                      cterm=none
" strings
hi String           guifg=#8ad6f2                                   gui=none
hi String           ctermfg=117                                     cterm=none
" character constant
hi Character        guifg=#8ad6f2                                   gui=none
hi Character        ctermfg=117                                     cterm=none
" numbers decimal/hex
hi Number           guifg=#50d6de                                   gui=none
hi Number           ctermfg=80                                      cterm=none
" true, false
hi Boolean          guifg=#50d6de                                   gui=none
hi Boolean          ctermfg=80                                      cterm=none
" float
hi Float            guifg=#50d6de                                   gui=none
hi Float            ctermfg=80                                      cterm=none

" Identifier Group
" ----------------
" any variable name
hi Identifier       guifg=#fcb666                                   gui=none
hi Identifier       ctermfg=215                                     cterm=none
" function, method, class
hi Function         guifg=#fcb666                                   gui=none
hi Function         ctermfg=215                                     cterm=none

" Statement Group
" ---------------
" any statement
hi Statement        guifg=#bae682                                   gui=none
hi Statement        ctermfg=150                                     cterm=none
" if, then, else
hi Conditional      guifg=#bae682                                   gui=none
hi Conditional      ctermfg=150                                     cterm=none
" try, catch, throw, raise
hi Exception        guifg=#bae682                                   gui=none
hi Exception        ctermfg=150                                     cterm=none
" for, while, do
hi Repeat           guifg=#bae682                                   gui=none
hi Repeat           ctermfg=150                                     cterm=none
" case, default
hi Label            guifg=#bae682                                   gui=none
hi Label            ctermfg=150                                     cterm=none
" sizeof, +, *
hi Operator         guifg=#bae682                                   gui=none
hi Operator         ctermfg=150                                     cterm=none
" any other keyword
hi Keyword          guifg=#bae682                                   gui=none
hi Keyword          ctermfg=150                                     cterm=none

" Preprocessor Group
" ------------------
" generic preprocessor
hi PreProc          guifg=#efefaf                                   gui=none
hi PreProc          ctermfg=229                                     cterm=none
" #include
hi Include          guifg=#efefaf                                   gui=none
hi Include          ctermfg=229                                     cterm=none
" #define
hi Define           guifg=#efefaf                                   gui=none
hi Define           ctermfg=229                                     cterm=none
" same as define
hi Macro            guifg=#efefaf                                   gui=none
hi Macro            ctermfg=229                                     cterm=none
" #if, #else, #endif
hi PreCondit        guifg=#efefaf                                   gui=none
hi PreCondit        ctermfg=229                                     cterm=none

" Type Group
" ----------
" int, long, char
hi Type             guifg=#93e690                                   gui=italic
hi Type             ctermfg=114                                     cterm=italic
" static, register, volative
hi StorageClass     guifg=#93e690                                   gui=none
hi StorageClass     ctermfg=114                                     cterm=none
" struct, union, enum
hi Structure        guifg=#93e690                                   gui=italic
hi Structure        ctermfg=114                                     cterm=italic
" typedef
hi Typedef          guifg=#93e690                                   gui=none
hi Typedef          ctermfg=114                                     cterm=none

" Special Group
" -------------
" any special symbol
hi Special          guifg=#cfafcf                                   gui=none
hi Special          ctermfg=182                                     cterm=none
" special character in a constant
hi SpecialChar      guifg=#cfafcf                                   gui=none
hi SpecialChar      ctermfg=182                                     cterm=none
" things you can CTRL-]
hi Tag              guifg=#cfafcf                                   gui=none
hi Tag              ctermfg=182                                     cterm=none
" character that needs attention
hi Delimiter        guifg=#cfafcf                                   gui=none
hi Delimiter        ctermfg=182                                     cterm=none
" special things inside a comment
hi SpecialComment   guifg=#cfafcf                                   gui=none
hi SpecialComment   ctermfg=182                                     cterm=none
" debugging statements
hi Debug            guifg=#cfafcf           guibg=NONE              gui=none
hi Debug            ctermfg=182             ctermbg=NONE            cterm=none

" Underlined Group
" ----------------
" text that stands out, html links
hi Underlined       guifg=fg                                        gui=underline
hi Underlined       ctermfg=fg                                      cterm=underline

" Ignore Group
" ------------
" left blank, hidden
hi Ignore           guifg=#808080
hi Ignore           ctermfg=243

" Error Group
" -----------
" any erroneous construct
hi Error            guifg=#ff8787           guibg=#870000           gui=none
hi Error            ctermfg=160             ctermbg=NONE            cterm=none

" Todo Group
" ----------
" todo, fixme, note, xxx
hi Todo             guifg=#deee33           guibg=NONE              gui=underline
hi Todo             ctermfg=190             ctermbg=NONE            cterm=underline

" Spelling
" --------
" word not recognized
hi SpellBad         guisp=#ee0000                                   gui=undercurl
hi SpellBad                                 ctermbg=9               cterm=undercurl
" word not capitalized
hi SpellCap         guisp=#eeee00                                   gui=undercurl
hi SpellCap                                 ctermbg=12              cterm=undercurl
" rare word
hi SpellRare        guisp=#ffa500                                   gui=undercurl
hi SpellRare                                ctermbg=13              cterm=undercurl
" wrong spelling for selected region
hi SpellLocal       guisp=#ffa500                                   gui=undercurl
hi SpellLocal                               ctermbg=14              cterm=undercurl

" Cursor
" ------
" character under the cursor
hi Cursor           guifg=bg                guibg=#8ac6f2
hi Cursor           ctermfg=bg              ctermbg=117
" like cursor, but used when in IME mode
hi CursorIM         guifg=bg                guibg=#96cdcd
hi CursorIM         ctermfg=bg              ctermbg=116
" cursor column
hi CursorColumn                             guibg=#3d3d4d
hi CursorColumn     cterm=NONE              ctermbg=236
" cursor line/row
hi CursorLine                               guibg=#3d3d4d
hi CursorLine       cterm=NONE              ctermbg=236

" Misc
" ----
" directory names and other special names in listings
hi Directory        guifg=#95e494                                   gui=none
hi Directory        ctermfg=114                                     cterm=none
" error messages on the command line
hi ErrorMsg         guifg=#ee0000           guibg=NONE              gui=none
hi ErrorMsg         ctermfg=196             ctermbg=NONE            cterm=none
" column separating vertically split windows
hi VertSplit        guifg=#444444           guibg=#444444           gui=none
hi VertSplit        ctermfg=238             ctermbg=238             cterm=none
" columns where signs are displayed (used in IDEs)
hi SignColumn       guifg=#A6E22E           guibg=#444444
hi SignColumn       ctermfg=118             ctermbg=238
" line numbers
hi LineNr           guifg=#767676           guibg=#444444
hi LineNr           ctermfg=243             ctermbg=238
hi CursorLineNr     guifg=#eeee00           guibg=#444444
hi CursorLineNr     ctermfg=11              ctermbg=238
" match parenthesis, brackets
hi MatchParen       guifg=#ffaa33           guibg=#3d3d4d           gui=bold
hi MatchParen       ctermfg=214             ctermbg=NONE            cterm=none
" text showing what mode you are in
hi MoreMsg          guifg=#2e8b57                                   gui=none
hi MoreMsg          ctermfg=29                                      cterm=none
" the '~' and '@' and showbreak, '>' double wide char doesn't fit on line
hi ModeMsg          guifg=#90ee90           guibg=NONE              gui=none
hi ModeMsg          ctermfg=120             ctermbg=NONE            cterm=none
" the 'more' prompt when output takes more than one line
hi NonText          guifg=#444444                                   gui=none
hi NonText          ctermfg=238                                     cterm=none
" the hit-enter prompt (show more output) and yes/no questions
hi Question         guifg=fg                                        gui=none
hi Question         ctermfg=fg                                      cterm=none
" meta and special keys used with map, unprintable characters
hi SpecialKey       guifg=#505050
hi SpecialKey       ctermfg=238
" titles for output from :set all, :autocmd, etc
hi Title            guifg=#3eb8e5                                   gui=none
hi Title            ctermfg=38                                      cterm=none
" warning messages
hi WarningMsg       guifg=#e5786d                                   gui=none
hi WarningMsg       ctermfg=173                                     cterm=none
" current match in the wildmenu completion
hi WildMenu         guifg=#000000           guibg=#cae682
hi WildMenu         ctermfg=16              ctermbg=186

" Diff
" ----
" added line
hi DiffAdd          guifg=#ffaa33           guibg=#3b1d1e              gui=italic
hi DiffAdd          ctermfg=214             ctermbg=52                 cterm=italic
" changed line
hi DiffChange       guifg=#ae81ff           guibg=#3b1d1e              gui=italic
hi DiffChange       ctermfg=135             ctermbg=52                 cterm=italic
" deleted line
hi DiffDelete       guifg=#ee0000           guibg=#3b1d1e              gui=italic
hi DiffDelete       ctermfg=196             ctermbg=52                 cterm=italic
" changed text within line
hi DiffText         guifg=#3eb8e5           guibg=#3b1d1e              gui=italic
hi DiffText         ctermfg=38              ctermbg=52                 cterm=italic

" Folds
" -----
" line used for closed folds
hi Folded           guifg=#a0a8b0           guibg=#444444           gui=none
hi Folded           ctermfg=145             ctermbg=238             cterm=none
" column on side used to indicated open and closed folds
hi FoldColumn       guifg=#66ffff           guibg=#444444           gui=none
hi FoldColumn       ctermfg=87              ctermbg=238             cterm=none

" Search
" ------
" highlight incremental search text; also highlight text replaced with :s///c
hi IncSearch        guifg=#66ffff                                   gui=reverse
hi IncSearch        ctermfg=87                                      cterm=reverse
" hlsearch (last search pattern), also used for quickfix
hi Search                                    guibg=#ffaa33          gui=none
hi Search                                    ctermbg=214            cterm=none

" Popup Menu
" ----------
" normal item in popup
hi Pmenu            guifg=#f6f3e8           guibg=#444444           gui=none
hi Pmenu            ctermfg=254             ctermbg=238             cterm=none
" selected item in popup
hi PmenuSel         guifg=#000000           guibg=#cae682           gui=none
hi PmenuSel         ctermfg=16              ctermbg=186             cterm=none
" scrollbar in popup
hi PMenuSbar                                guibg=#607b8b           gui=none
hi PMenuSbar                                ctermbg=66              cterm=none
" thumb of the scrollbar in the popup
hi PMenuThumb                               guibg=#aaaaaa           gui=none
hi PMenuThumb                               ctermbg=247             cterm=none

" Status Line
" -----------
" status line for current window
hi StatusLine       guifg=#c0c0c0           guibg=#660066           gui=none
hi StatusLine       ctermfg=7               ctermbg=53              cterm=none
" status line for non-current windows
hi StatusLineNC     guifg=#000000           guibg=#c0c0c0           gui=none
hi StatusLineNC     ctermfg=16               ctermbg=7               cterm=none
" User1
hi User1            guifg=#FFFFFF           guibg=#EE0000           gui=none
hi User1            ctermfg=15              ctermbg=9               cterm=none

" Tab Lines
" ---------
" tab pages line, not active tab page label
hi TabLine          guifg=#626262           guibg=#c0c0c0          gui=italic
hi TabLine          ctermfg=241             ctermbg=7              cterm=italic
" tab pages line, active tab page label
hi TabLineSel       guifg=#000000           guibg=#c0c0c0          gui=bold
hi TabLineSel       ctermfg=16              ctermbg=7              cterm=bold
" tab pages line, where there are no labels
hi TabLineFill                              guibg=#c0c0c0
hi TabLineFill                              ctermbg=7

" Visual
" ------
" visual mode selection
hi Visual           guifg=NONE              guibg=#005f87
hi Visual           ctermfg=NONE            ctermbg=60
" visual mode selection when vim is 'not owning the selection' (x11 only)
hi VisualNOS        guifg=fg                                        gui=underline
hi VisualNOS        ctermfg=fg                                      cterm=underline

" For TagHightlight, liqiang+
" ---------------------------
hi Class            guifg=#93e690 ctermfg=114   gui=italic cterm=italic
hi Union            guifg=#93e690 ctermfg=114   gui=italic cterm=italic
hi DefinedName      guifg=#ae81ff ctermfg=135   gui=none cterm=none
hi Enumerator       guifg=#50d6de ctermfg=80    gui=none cterm=none
hi EnumerationName  guifg=#50d6de ctermfg=80    gui=none cterm=none
hi EnumerationValue guifg=#50d6de ctermfg=80    gui=none cterm=none
hi Member           guifg=fg      ctermfg=fg    gui=italic cterm=italic
hi GlobalConstant   guifg=#bbbb00 ctermfg=142   gui=none cterm=none
hi GlobalVariable   guifg=#bbbb00 ctermfg=142   gui=none cterm=none
hi LocalVariable    guifg=fg      ctermfg=fg    gui=none cterm=none

" SignifySign, liqiang+
" ---------------------
hi SignifySignAdd    guifg=#ffaa33 ctermfg=214  guibg=#444444 ctermbg=238   gui=none cterm=none
hi SignifySignDelete guifg=#ee0000 ctermfg=196  guibg=#444444 ctermbg=238   gui=none cterm=none
hi SignifySignChange guifg=#eeee00 ctermfg=11   guibg=#444444 ctermbg=238   gui=none cterm=none

" YouCompleteMe
" -------------
hi YcmErrorSign     guifg=#ee0000 ctermfg=196   guibg=#444444 ctermbg=238   gui=none cterm=none
hi YcmWarningSign   guifg=#eeee00 ctermfg=11    guibg=#444444 ctermbg=238   gui=none cterm=none

" Doxygen, liqiang+
" -----------------
hi  DoxygenOutstandX            guifg=#a0a0a0 ctermfg=247   gui=none cterm=none
hi  DoxygenCommonX              guifg=#808080 ctermfg=243   gui=italic cterm=italic
hi  DoxygenNormalX              guifg=#808080 ctermfg=243   gui=none cterm=none
hi  DoxygenItalicX              guifg=#808080 ctermfg=243   gui=italic cterm=italic
hi  DoxygenBoldX                guifg=#808080 ctermfg=243   gui=bold cterm=bold
hi  DoxygenUnderlineX           guifg=#808080 ctermfg=243   gui=underline cterm=underline
hi  DoxygenBoldItalicX          guifg=#808080 ctermfg=243   gui=italic,bold cterm=italic,bold
hi  DoxygenBoldUnderlineX       guifg=#808080 ctermfg=243   gui=underline,bold cterm=underline,bold
hi  DoxygenUnderlineItalicX     guifg=#808080 ctermfg=243   gui=underline,italic cterm=underline,italic
hi  DoxygenBoldUnderlineItalicX guifg=#808080 ctermfg=243   gui=bold,underline,italic cterm=bold,underline,italic

