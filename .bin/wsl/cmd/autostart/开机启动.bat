
schtasks.exe /create /sc onlogon /TN "WslAutoStart" /TR "%~dp0start.vbs" /RL HIGHEST /F

pause

