var WshShell = new ActiveXObject("WScript.Shell");

WshShell.CurrentDirectory = "..\\..\\..";
CygwinNew = "\"" + WshShell.CurrentDirectory + "\\.bin\\windows\\hstart.exe\" /NOCONSOLE \"" +
            "\"" + WshShell.CurrentDirectory + "\\..\\..\\..\\bin\\bash.exe\" " +
            "\"" + WshShell.CurrentDirectory + "\\.bin\\new\" "
CygwinMintty = "\"" + WshShell.CurrentDirectory + "\\..\\..\\..\\bin\\mintty.exe\""

WshShell.RegWrite("HKCU\\Software\\Classes\\*\\shell\\vim-in-cygwin\\" , "Edit with &Vim in Cygwin", "REG_SZ");
WshShell.RegWrite("HKCU\\Software\\Classes\\*\\shell\\vim-in-cygwin\\icon" , CygwinMintty, "REG_SZ");
WshShell.RegWrite("HKCU\\Software\\Classes\\*\\shell\\vim-in-cygwin\\command\\" , CygwinNew + "-s -n exec vim $(cygpath \"%1\")" + "\"", "REG_SZ");

WshShell.RegWrite("HKCU\\Software\\Classes\\*\\shell\\vim-in-cygwin-binary\\" , "Edit with &Vim (Binary) in Cygwin", "REG_SZ");
WshShell.RegWrite("HKCU\\Software\\Classes\\*\\shell\\vim-in-cygwin-binary\\icon" , CygwinMintty, "REG_SZ");
WshShell.RegWrite("HKCU\\Software\\Classes\\*\\shell\\vim-in-cygwin-binary\\command\\" , CygwinNew + "-s -n exec vim -b $(cygpath \"%1\")" + "\"", "REG_SZ");

