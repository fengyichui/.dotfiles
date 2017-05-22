' XLS_to_CSV.vbs
'
' Converts an Excel workbook to a comma-separated text file.  Requires Microsoft Excel.
' Usage:
'  WScript XLS_to_CSV.vbs <input file> <output file>

Option Explicit

' MsoAutomationSecurity
Const msoAutomationSecurityForceDisable = 3
' OpenTextFile iomode
Const ForReading = 1
Const ForAppending = 8
' XlFileFormat
Const xlCSV = 6 ' Comma-separated values
' XlSheetVisibility
Const xlSheetVisible = -1

Dim App, AutoSec, Doc, FileSys
Set FileSys = CreateObject("Scripting.FileSystemObject")
If FileSys.FileExists(WScript.Arguments(1)) Then
	FileSys.DeleteFile WScript.Arguments(1)
End If
Set App = CreateObject("Excel.Application")

 On Error Resume Next

App.DisplayAlerts = False
AutoSec = App.AutomationSecurity
App.AutomationSecurity = msoAutomationSecurityForceDisable
Err.Clear

Dim I, J, SheetName, TgtFile, TmpFile, TmpFilenames()
Set Doc = App.Workbooks.Open(WScript.Arguments(0), False, True)
If Err = 0 Then
	I = 0
	For J = 1 To Doc.Sheets.Count
		If Doc.Sheets(J).Visible = xlSheetVisible Then
			I = I + 1
		End If
	Next
	ReDim TmpFilenames(I - 1)
	Set TgtFile = FileSys.OpenTextFile(WScript.Arguments(1), ForAppending, True)
	I = 0
	For J = 1 To Doc.Sheets.Count
		If Doc.Sheets(J).Visible = xlSheetVisible Then
			SheetName = Doc.Sheets(J).Name
			TgtFile.WriteLine """SHEET " & SheetName & """"
			Doc.Sheets(J).Activate
			TmpFilenames(I) = FileSys.GetSpecialFolder(2) & "\" & FileSys.GetTempName
			Doc.SaveAs TmpFilenames(I), xlCSV
			Set TmpFile = FileSys.OpenTextFile(TmpFilenames(I), ForReading)
			TgtFile.Write TmpFile.ReadAll
			TmpFile.Close
			If I <> UBound(TmpFilenames) Then
				TgtFile.WriteLine
			End If
			Doc.Sheets(J).Name = SheetName
			I = I + 1
		End If
	Next
	TgtFile.Close
	Doc.Close False
End If

App.AutomationSecurity = AutoSec
App.Quit

For I = 0 To UBound(TmpFilenames)
	If FileSys.FileExists(TmpFilenames(I)) Then
		FileSys.DeleteFile TmpFilenames(I)
	End If
Next
