var WshShell = new ActiveXObject("WScript.Shell");

WshShell.RegDelete("HKCU\\Software\\Classes\\*\\shell\\vim-in-wsl\\command\\");
WshShell.RegDelete("HKCU\\Software\\Classes\\*\\shell\\vim-in-wsl\\");

WshShell.RegDelete("HKCU\\Software\\Classes\\*\\shell\\vim-in-wsl-binary\\command\\");
WshShell.RegDelete("HKCU\\Software\\Classes\\*\\shell\\vim-in-wsl-binary\\");

