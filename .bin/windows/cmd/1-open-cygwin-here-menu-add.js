var WshShell = new ActiveXObject("WScript.Shell");

WshShell.CurrentDirectory = "..\\..";

WshShell.RegWrite("HKCU\\Software\\Classes\\Directory\\shell\\open-cygwin\\", "Open Cygwin Here", "REG_SZ");
WshShell.RegWrite("HKCU\\Software\\Classes\\Directory\\shell\\open-cygwin\\Icon", WshShell.CurrentDirectory + "\\..\\..\\..\\bin\\mintty.exe", "REG_SZ");
WshShell.RegWrite("HKCU\\Software\\Classes\\Directory\\shell\\open-cygwin\\command\\",
    WshShell.CurrentDirectory + "\\.bin\\windows\\hstart.exe" + " /NOCONSOLE \"cmd /c set HOME=&set CHERE_INVOKING=1&" + WshShell.CurrentDirectory + "\\..\\..\\..\\bin\\mintty.exe" + " -\"", "REG_SZ");

WshShell.RegWrite("HKCU\\Software\\Classes\\Directory\\Background\\shell\\open-cygwin\\", "Open Cygwin Here", "REG_SZ");
WshShell.RegWrite("HKCU\\Software\\Classes\\Directory\\Background\\shell\\open-cygwin\\Icon", WshShell.CurrentDirectory + "\\..\\..\\..\\bin\\mintty.exe", "REG_SZ");
WshShell.RegWrite("HKCU\\Software\\Classes\\Directory\\Background\\shell\\open-cygwin\\command\\",
    WshShell.CurrentDirectory + "\\.bin\\windows\\hstart.exe" + " /NOCONSOLE \"cmd /c set HOME=&set CHERE_INVOKING=1&" + WshShell.CurrentDirectory + "\\..\\..\\..\\bin\\mintty.exe" + " -\"", "REG_SZ");


