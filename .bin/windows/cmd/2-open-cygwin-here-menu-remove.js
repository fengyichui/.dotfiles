var WshShell = new ActiveXObject("WScript.Shell");

WshShell.RegDelete("HKCU\\Software\\Classes\\Directory\\shell\\open-cygwin\\command\\");
WshShell.RegDelete("HKCU\\Software\\Classes\\Directory\\shell\\open-cygwin\\");

WshShell.RegDelete("HKCU\\Software\\Classes\\Directory\\Background\\shell\\open-cygwin\\command\\");
WshShell.RegDelete("HKCU\\Software\\Classes\\Directory\\Background\\shell\\open-cygwin\\");
