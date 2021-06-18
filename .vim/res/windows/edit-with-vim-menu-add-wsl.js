var WshShell = new ActiveXObject("WScript.Shell");

LOCALAPPDATA = WshShell.ExpandEnvironmentStrings("%LOCALAPPDATA%");

WslVimIcon   = "\"" + LOCALAPPDATA + "\\wsltty\\vim.ico\""
WslVimCmd    = "\"" + LOCALAPPDATA + "\\wsltty\\vim.exe\"    \"%1\""
WslVimBinCmd = "\"" + LOCALAPPDATA + "\\wsltty\\vim.exe\" -b \"%1\""

WshShell.RegWrite("HKCU\\Software\\Classes\\*\\shell\\vim-in-wsl\\", "Edit with &Vim in WSL", "REG_SZ");
WshShell.RegWrite("HKCU\\Software\\Classes\\*\\shell\\vim-in-wsl\\icon", WslVimIcon, "REG_SZ");
WshShell.RegWrite("HKCU\\Software\\Classes\\*\\shell\\vim-in-wsl\\command\\", WslVimCmd, "REG_SZ");

WshShell.RegWrite("HKCU\\Software\\Classes\\*\\shell\\vim-in-wsl-binary\\", "Edit with &Vim (Binary) in WSL", "REG_SZ");
WshShell.RegWrite("HKCU\\Software\\Classes\\*\\shell\\vim-in-wsl-binary\\icon", WslVimIcon, "REG_SZ");
WshShell.RegWrite("HKCU\\Software\\Classes\\*\\shell\\vim-in-wsl-binary\\command\\", WslVimBinCmd, "REG_SZ");

