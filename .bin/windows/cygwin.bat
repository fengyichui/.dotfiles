@echo off

:: Avoid the wrong home directory
set HOME=

C:
chdir C:\cygwin\bin

bash --login -i
::mintty -

