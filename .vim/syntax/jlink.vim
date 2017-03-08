" Vim syntax file
" Language:	jlink
" Maintainer:	liqiang
" Last Change:
"

" quit when a syntax file was already loaded.
if exists("b:current_syntax")
  finish
endif

" We need nocompatible mode in order to continue lines with backslashes.
" Original setting will be restored.
let s:cpo_save = &cpo
set cpo&vim

syn case ignore
syn keyword jlinkCommand f h g Sleep s st hwinfo mem mem8 mem16 mem32 w1 w2 w4 erase wm is ms mr q qc r rx RSetType Regs wreg moe SetBP SetWP ClrBP ClrWP VCatch loadfile loadbin savebin verifybin SetPC le be log unlock term ReadAP ReadDP WriteAP WriteDP SWDSelect SWDReadAP SWDReadDP SWDWriteAP SWDWriteDP Device ExpDevList PowerTrace
syn keyword jlinkCommand rce wce
syn keyword jlinkCommand Ice ri wi
syn keyword jlinkCommand TClear TSetSize TSetFormat TSR TStart TStop
syn keyword jlinkCommand SWOSpeed SWOStart SWOStop SWOStat SWORead SWOShow SWOFlush SWOView
syn keyword jlinkCommand PERConf PERStart PERStop PERStat PERRead PERShow
syn keyword jlinkCommand fwrite fread fshow fdelete fsize flist SecureArea
syn keyword jlinkCommand TestHaltGo TestStep TestCSpeed TestWSpeed TestRSpeed TestNWSpeed TestNRSpeed
syn keyword jlinkCommand Config speed i wjc wjd RTAP wjraw rt
syn keyword jlinkCommand c00 c tck0 tck1 t0 t1 trst0 trst1 r0 r1
syn keyword jlinkCommand usb ip
syn keyword jlinkCommand si power wconf rconf license ipaddr gwaddr dnsaddr conf ecp calibrate selemu ShowEmuList
syn keyword jlinkKeyword auto adaptive
syn region  jlinkComment start="//" end="$"
syn region  jlinkComment start="/\*" end="\*/" fold
syn match   jlinkNumber  "\<\(0x\)\?\x\{1,8}\>"
syn match   jlinkFile    "\S\+\.\(bin\|hex\|\|mot\|srec\)\>"
syn case match

hi def link jlinkCommand Function
hi def link jlinkComment Comment
hi def link jlinkNumber Number
hi def link jlinkFile Label
hi def link jlinkKeyword Keyword

let b:current_syntax = "jlink"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim:set sw=2 sts=2 ts=8 noet:
