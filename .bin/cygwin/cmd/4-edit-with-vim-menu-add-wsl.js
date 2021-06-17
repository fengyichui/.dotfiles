var WshShell = new ActiveXObject("WScript.Shell");

LOCALAPPDATA = WshShell.ExpandEnvironmentStrings("%LOCALAPPDATA%");
APPDATA      = WshShell.ExpandEnvironmentStrings("%APPDATA%")

WslIcon      = "\"" + LOCALAPPDATA + "\\wsltty\\wsl.ico\""
WslVimCmd    = "\"" + LOCALAPPDATA + "\\wsltty\\bin\\mintty.exe\" --WSL --icon " + WslIcon + " --configdir=\"" + APPDATA + "\\wsltty\" --title \"[*VIM*] %1\"    --exec bash -c \"vim    \\\"$(wslpath \\\"$(echo -E '%1' | sed 's/\\\\\\\\/\\\\\\\\\\\\\\\\/g')\\\")\\\"\""
WslVimBinCmd = "\"" + LOCALAPPDATA + "\\wsltty\\bin\\mintty.exe\" --WSL --icon " + WslIcon + " --configdir=\"" + APPDATA + "\\wsltty\" --title \"[*VIM*] -b %1\" --exec bash -c \"vim -b \\\"$(wslpath \\\"$(echo -E '%1' | sed 's/\\\\\\\\/\\\\\\\\\\\\\\\\/g')\\\")\\\"\""

WshShell.RegWrite("HKCU\\Software\\Classes\\*\\shell\\vim-in-wsl\\", "Edit with &Vim in WSL", "REG_SZ");
WshShell.RegWrite("HKCU\\Software\\Classes\\*\\shell\\vim-in-wsl\\icon", WslIcon, "REG_SZ");
WshShell.RegWrite("HKCU\\Software\\Classes\\*\\shell\\vim-in-wsl\\command\\", WslVimCmd, "REG_SZ");

WshShell.RegWrite("HKCU\\Software\\Classes\\*\\shell\\vim-in-wsl-binary\\", "Edit with &Vim (Binary) in WSL", "REG_SZ");
WshShell.RegWrite("HKCU\\Software\\Classes\\*\\shell\\vim-in-wsl-binary\\icon", WslIcon, "REG_SZ");
WshShell.RegWrite("HKCU\\Software\\Classes\\*\\shell\\vim-in-wsl-binary\\command\\", WslVimBinCmd, "REG_SZ");

