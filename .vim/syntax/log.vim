" Vim syntax file
" Language:           (Web) log file syntax highlighting.
" Author:             @n3wjack
" Version:            1.0
" Project Repository: https://github.com/n3wjack/logsyntax.vim
" Vim Script Page:    http://www.vim.org/scripts/script.php?script_id=

" IIS logs
syntax match iis_ip /\d\{1,3}\.\d\{1,3}\.\d\{1,3}\.\d\{1,3}/
highlight link iis_ip Keyword

syntax match iis_date /\d\{2}\/\d\{2}\/\d\{2}/
highlight link iis_date Function

syntax match iis_hour /\d\{1,2}:\d\{1,2}:\d\{1,2}/
highlight link iis_hour Function

" NCSA common logs
syntax keyword verbs GET POST HEAD PUT DELETE TRACE OPTIONS CONNECT PATCH contained
highlight link verbs Statement

syntax region request start=/"/ end=/"/ contains=verbs
highlight link request Type

syntax match bracketdate /\d\{2}\/\a\{3}\/\d\{4}:\d\{2}:\d\{2}:\d\{2} [+-]\d\{4}/  
highlight link bracketdate Function

" IISW3C log
syntax keyword iisw3c_verbs GET POST HEAD PUT DELETE TRACE OPTIONS CONNECT PATCH 
highlight link iisw3c_verbs Statement

syntax match iisw3c_comment /#.*/
highlight link iisw3c_comment Comment

syntax match iisw3c_date /\d\{4}-\d\{2}-\d\{2} \d\{2}:\d\{2}:\d\{2}/
highlight link iisw3c_date Function

syntax match iisw3c_referer /http.\{-} /
highlight link iisw3c_referer Type

syntax match iisw3c_request / \/.\{-} /
highlight link iisw3c_request PreProc

" General/application log files
syntax keyword applogging_level_debug DEBUG
syntax keyword applogging_level_info INFO
syntax keyword applogging_level_warning WARN WARNING
syntax keyword applogging_level_error ERR ERROR

highlight link applogging_level_debug Comment
highlight link applogging_level_info String
highlight link applogging_level_warning Statement
highlight link applogging_level_error Error

syntax match applogging_datewithmilliseconds /\d\{4}-\d\{2}-\d\{2} \d\{2}:\d\{2}:\d\{2},\d\{3}/
highlight link applogging_datewithmilliseconds Function

