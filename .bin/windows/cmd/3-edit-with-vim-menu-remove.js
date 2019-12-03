var WshShell = new ActiveXObject("WScript.Shell");

WshShell.RegDelete("HKCU\\Software\\Classes\\*\\shell\\vim-in-cygwin\\command\\");
WshShell.RegDelete("HKCU\\Software\\Classes\\*\\shell\\vim-in-cygwin\\");

WshShell.RegDelete("HKCU\\Software\\Classes\\*\\shell\\vim-in-cygwin-binary\\command\\");
WshShell.RegDelete("HKCU\\Software\\Classes\\*\\shell\\vim-in-cygwin-binary\\");

