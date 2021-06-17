var WshShell = new ActiveXObject("WScript.Shell");

LOCALAPPDATA = WshShell.ExpandEnvironmentStrings("%LOCALAPPDATA%");
APPDATA      = WshShell.ExpandEnvironmentStrings("%APPDATA%")

WslIcon      = LOCALAPPDATA + "\\wsltty\\wsl.ico"
WslVimCmd    = LOCALAPPDATA + "\\wsltty\\bin\\mintty.exe --WSL --configdir=" + APPDATA + "\\wsltty --exec bash -c \"vim \\\"$(wslpath '%1')\\\"\""
WslVimBinCmd = LOCALAPPDATA + "\\wsltty\\bin\\mintty.exe --WSL --configdir=" + APPDATA + "\\wsltty --exec bash -c \"vim -b \\\"$(wslpath '%1')\\\"\""

WshShell.RegWrite("HKCU\\Software\\Classes\\*\\shell\\vim-in-wsl\\", "Edit with &Vim in WSL", "REG_SZ");
WshShell.RegWrite("HKCU\\Software\\Classes\\*\\shell\\vim-in-wsl\\icon", WslIcon, "REG_SZ");
WshShell.RegWrite("HKCU\\Software\\Classes\\*\\shell\\vim-in-wsl\\command\\", WslVimCmd, "REG_SZ");

WshShell.RegWrite("HKCU\\Software\\Classes\\*\\shell\\vim-in-wsl-binary\\", "Edit with &Vim (Binary) in WSL", "REG_SZ");
WshShell.RegWrite("HKCU\\Software\\Classes\\*\\shell\\vim-in-wsl-binary\\icon", WslIcon, "REG_SZ");
WshShell.RegWrite("HKCU\\Software\\Classes\\*\\shell\\vim-in-wsl-binary\\command\\", WslVimBinCmd, "REG_SZ");

