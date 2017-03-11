
:: Administrator run command line in PWD

@echo off

set tmp="%TEMP%\cmd_adm.tmp"
set hstart="%~dp0\hstart.exe"

if exist %tmp% goto CMD else goto HSTART

:HSTART
echo %CD%>%tmp%
%hstart% /RUNAS "%0"
exit

:CMD
set /p dir=<%tmp%
del /F %tmp%
cd "%dir%"
cmd

