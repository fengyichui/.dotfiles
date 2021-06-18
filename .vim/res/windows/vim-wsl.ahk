#NoTrayIcon
#NoEnv

; Read ini file {{{1
shell = "bash"
mintty_options =

; Prepare mintty_base and wslbridge2_base {{{1
SplitPath, A_ScriptName, , , , exe_name
EnvGet, localappdata, LOCALAPPDATA
EnvGet, appdata, APPDATA
;icon_path = "%A_ScriptDir%\%exe_name%.ico"
icon_path = %A_ScriptFullPath%
mintty_base = "%localappdata%\wsltty\bin\mintty" --WSL --configdir "%appdata%\wsltty" --icon "%icon_path%"

; Run as run-wsl-file or any editor {{{1
if (exe_name == "run-wsl-file") {
    arg = %1%

    if (arg == "") {
        MsgBox, Open .sh/.py/.pl/... with %exe_name%.exe to run it in WSL.
        ExitApp
    }

    SplitPath, arg, filename, dir
    SetWorkingDir, %dir%

    Run, %mintty_base% %mintty_options% --title "%arg%" --exec %shell% -c ./"%filename%"
    ExitApp
} else {
    ; editor
    argc = %0%
    filepath := ""
    filename := ""
    options := ""

    if (argc > 0) {
        filepath := %argc%

        Loop, % argc - 1 {
            options .= " " %A_Index%
        }

        SplitPath, filepath, filename, dir
        SetWorkingDir, %dir%

        if (InStr(filename, " ")) {
            filename = "%filename%"
        }
    }

    Run, %mintty_base% %mintty_options% --title "[*%exe_name%] %filepath%" --exec "%exe_name%" %options% %filename%
    Loop, 5 {
        WinActivate, %filepath%
        if (WinActive(filepath)) {
            break
        }

        Sleep, 50
    }

    ExitApp
}

