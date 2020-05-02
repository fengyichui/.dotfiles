var WshShell = new ActiveXObject("WScript.Shell");

WshShell.CurrentDirectory = "..\\..\\..";
CygwinNew = "\"" + WshShell.CurrentDirectory + "\\.bin\\windows\\hstart.exe\" /NOCONSOLE \"" +
            "\"" + WshShell.CurrentDirectory + "\\..\\..\\..\\bin\\bash.exe\" " +
            "\"" + WshShell.CurrentDirectory + "\\.bin\\windows\\new\" "
CygwinMintty = "\"" + WshShell.CurrentDirectory + "\\..\\..\\..\\bin\\mintty.exe\""

WshShell.RegWrite("HKCU\\Software\\Classes\\Directory\\shell\\open-cygwin\\", "Open Cygwin Here", "REG_SZ");
WshShell.RegWrite("HKCU\\Software\\Classes\\Directory\\shell\\open-cygwin\\Icon", CygwinMintty, "REG_SZ");
WshShell.RegWrite("HKCU\\Software\\Classes\\Directory\\shell\\open-cygwin\\command\\", CygwinNew + "\"", "REG_SZ");

WshShell.RegWrite("HKCU\\Software\\Classes\\Directory\\Background\\shell\\open-cygwin\\", "Open Cygwin Here", "REG_SZ");
WshShell.RegWrite("HKCU\\Software\\Classes\\Directory\\Background\\shell\\open-cygwin\\Icon", CygwinMintty, "REG_SZ");
WshShell.RegWrite("HKCU\\Software\\Classes\\Directory\\Background\\shell\\open-cygwin\\command\\", CygwinNew + "\"", "REG_SZ");

