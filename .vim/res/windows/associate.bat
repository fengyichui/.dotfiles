::
:: @file associate.bat
:: @brief Auto associate file with application and icon
:: @date 2016/11/30
:: @author liqiang
::

@echo off

:: APP and ICON
::set app="C:\Program Files\Vim\vim82\gvim.exe" "%%1"
set app="%~dp0vim.exe" "%%1"
::set icon="%%SystemRoot%%\system32\imageres.dll,97"
set icon="%~dp0vimfile.ico,0"

:: print info
echo ---------------------------------------------
echo app: %app%
echo icon: %icon%
echo ---------------------------------------------

:: gvim default icon
reg add HKLM\SOFTWARE\Classes\Applications\gvim.exe\DefaultIcon /ve /d %icon% /f

:: Extension
set extensions=(c,cc,cpp,h,hpp, asm,s, java, bin,hex, map,dis,sct,symdefs, mk,mak, ini, log, md, vim, xml, diff,patch, sh, gdb, json)
:: Do Extension
for %%e in %extensions% do (
    ftype vim.%%e=%app%
    assoc .%%e=vim.%%e
    reg add HKCR\vim.%%e\DefaultIcon /ve /d %icon% /f
    echo ---------------------------------------------
)

:: No extension
ftype vim.noextension=%app%
assoc .=vim.noextension
reg add HKCR\vim.noextension\DefaultIcon /ve /d %icon% /f
echo ---------------------------------------------

:: txt file: special for shellnew
ftype txtfile=%app%
assoc .txt=txtfile
echo ---------------------------------------------

:: Pause
pause
