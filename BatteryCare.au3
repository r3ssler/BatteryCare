; BatteryCare™ 1.0
; A simple program to:
;- Show status battery 
;- Turn on/off the laptop's Battery Saver mode.
;- Disable/Open unnecessary apps to save battery.
;- Delete ALL temporary data on a single computer, recursively.
;- Optimize Ram
;- Create file "Log.txt" before run PC Cleaner.

; ==== SYSTEM VARIABLES ======================================================
#RequireAdmin
#NoTrayIcon 
#include <StaticConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <WinAPIGdi.au3>
#include <WinAPISys.au3>
#include <_Msgbox.au3>
#include <Array.au3>
_AddFont()
_Verif_PROG() ; Make sure program is started only once

; ==== PROGRAM VARIABLES =====================================================
Const $filelog = "Log.txt"
$WIN = "\Windows"; Most common folder for windows
$WINNT = "\WinNT"; Windows NT
$DAS = "\Documents and Settings"; Base of all user data
$LS_Temp = "\Local Settings\Temp"; All those pesky temp files
$LS_TIF = "\Local Settings\Temporary Internet Files\Content.IE5"; All that crappy IE stuff
$Temp = "\Temp"; Simple temporary folder (usually within Windows)
$Systemprofile = "\system32\config\systemprofile"; Nicely hidden junk ...
$All = "\*.*"; All files within
$S = "\"; Backslash
Dim $Drives[26]; Array containing all drive letters and data
$Drive_AMOUNT = _Find_DRIVES() ; Get list of drives on system

#Region ------- Control effect functions -----------
Func _GUI_FadeOut($GUI, $speed = 5)
	For $i = 255 to 0 Step -$speed
		WinSetTrans($GUI,'', $i)
		Sleep(5)
	Next
EndFunc
Func _GUI_FadeIn($GUI, $speed = 5)
	For $i = 0 to 255 Step $speed
		WinSetTrans($GUI,'', $i)
		Sleep(5)
	Next
EndFunc

Func _AddFont()
	FileInstall('fontawesome.ttf',@TempDir&'\fontawesome.ttf',1) ; load font
	if @error Then
		_MsgBox(32, 'Warning', "Sorry!" & @CRLF & "The font could not be loaded. Please run this tool as Administrator")
		Return False
	EndIf
	_WinAPI_AddFontResourceEx(@TempDir&'\fontawesome.ttf', $FR_PRIVATE) ; load font
EndFunc

#EndRegion ------- Control effect functions -----------

; ==== CREATE GUI========== ==========================================================
$GUIMAIN = GUICreate("BatteryCare ™" ,246, 255, 552, 200,-1, $WS_EX_TOOLWINDOW)
GUICtrlSetFont(-1, 11, 350, 0, "Segoe UI")
GUISetBkColor(0xFFFFFF, $GUIMAIN)
WinSetTrans($GUIMAIN,'',0)
_GUI_FadeIn($GUIMAIN)
$switch = GUICtrlCreateButton("On", 150, 134, 45, 25)
GUICtrlSetFont(-1, 9, 350, 0, "Segoe UI")
$PCCleaner = GUICtrlCreateButton("Run", 150, 160, 45, 25)
GUICtrlSetFont(-1, 9, 350, 0, "Segoe UI")
$OptimizeRam = GUICtrlCreateButton("Run", 150, 186, 45, 25)
GUICtrlSetFont(-1, 9, 350, 0, "Segoe UI")
GUICtrlCreateLabel('AC power:', 35, 14, 90, 14+10)
GUICtrlSetFont(-1, 10, 350, 0, "Segoe UI")
GUICtrlCreateLabel('Status:', 35, 34, 70, 14+10)
GUICtrlSetFont(-1, 10, 350, 0, "Segoe UI")
GUICtrlCreateLabel('Charge:', 35, 54, 90, 14+10)
GUICtrlSetFont(-1, 10, 350, 0, "Segoe UI")
GUICtrlCreateLabel('Time remaining:', 35, 74, 120, 14+10)
GUICtrlSetFont(-1, 10, 350, 0, "Segoe UI")
GUICtrlCreateGroup("Function", 37, 105, 175, 120)
GUICtrlSetFont(-1, 10, 350, 0, "Segoe UI")
GUICtrlCreateLabel('Battery Saver:', 57, 136, 80, 20)
GUICtrlSetFont(-1, 10, 350, 0, "Segoe UI")
GUICtrlCreateLabel('PC Cleaner:', 57, 162, 75, 25)
GUICtrlSetFont(-1, 10, 350, 0, "Segoe UI")
GUICtrlCreateLabel('Optimize Ram:', 57, 188, 90, 25)
GUICtrlSetFont(-1, 10, 350, 0, "Segoe UI")

Global $g_aidLabel[4]
For $i = 0 To 3
        $g_aidLabel[$i] = GUICtrlCreateLabel('Unknown', 160, 14 + 20 * $i, 60, 14+10)
		GUICtrlSetFont(-1, 10, 350, 0, "Segoe UI")
Next
GUISetState(@SW_SHOW)

AdlibRegister('_BatteryStatus', 1000)

While 1
        Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			_exit()
			ExitLoop
		Case $switch
            _BatterySaver()	
		Case $PCCleaner
			_Readfilelog()
			_Writefilelog()
		Case	$OptimizeRAM
			_OptimizeRAM()
        EndSwitch
	WEnd
	
; ==== MAIN LOOP =============================================================
Func _PCCleaner_Log()  ; When running for the first time
	_MsgBox(48, 'PC Cleaner ™', 'Select "Clean up system files" ->Tick all to clean up garbage' & @CRLF &"(See pictures in the folder manual - Helper\User Manual)")
; Go through with all drives on system
For $i = 1 To $Drive_AMOUNT
; Clear out Temp in main drive folder
    If FileExists($Drives[$i] & $Temp) Then
        _Zap_FOLDER($Drives[$i] & $Temp)
    EndIf
    
; Clear out Temp within Windows folder
    If FileExists($Drives[$i] & $WIN & $Temp) Then; Temp in main drive folder
        _Zap_FOLDER($Drives[$i] & $WIN & $Temp)
    EndIf
    
; Clear out (hidden) temp within SystemcProfile folder
    If FileExists($Drives[$i] & $WIN & $Systemprofile & $LS_Temp) Then; Temp in main drive folder
        _Zap_FOLDER($Drives[$i] & $WIN & $Systemprofile & $LS_Temp)
    EndIf
    
; Clear out (hidden) IE files within SystemcProfile folder
    If FileExists($Drives[$i] & $WIN & $Systemprofile & $LS_TIF) Then; Temp in main drive folder
        _Zap_FOLDER($Drives[$i] & $WIN & $Systemprofile & $LS_TIF)
    EndIf
    
; Clear out Temp within WinNT folder
    If FileExists($Drives[$i] & $WINNT & $Temp) Then; Temp in main drive folder
        _Zap_FOLDER($Drives[$i] & $WINNT & $Temp)
    EndIf
    
; Clear out (hidden) temp within SystemcProfile folder
    If FileExists($Drives[$i] & $WINNT & $Systemprofile & $LS_Temp) Then; Temp in main drive folder
        _Zap_FOLDER($Drives[$i] & $WINNT & $Systemprofile & $LS_Temp)
    EndIf
    
; Clear out (hidden) IE files within SystemcProfile folder
    If FileExists($Drives[$i] & $WINNT & $Systemprofile & $LS_TIF) Then; Temp in main drive folder
        _Zap_FOLDER($Drives[$i] & $WINNT & $Systemprofile & $LS_TIF)
    EndIf
    
; Empty the recycle bin just in case ...
    FileRecycleEmpty($Drives[$i])
    
; Search and destroy within Documents and Settings
    If FileExists($Drives[$i] & $DAS) Then; Documents and Settings on this drive
        
        $FFF_DAS = FileFindFirstFile($Drives[$i] & $DAS & $All); Start off search
        If $FFF_DAS <> - 1 Then; Follow through if more than 0 elements found
            While 1
                $Next_DAS = FileFindNextFile($FFF_DAS); Get the folder's name
                If @error Then ExitLoop; Whoops, finished
                If $Next_DAS <> "." And $Next_DAS <> ".." Then
                    If FileExists($Drives[$i] & $DAS & $S & $Next_DAS & $LS_Temp) Then; If there are any temp files
                        _Zap_FOLDER($Drives[$i] & $DAS & $S & $Next_DAS & $LS_Temp)
                    EndIf
                    If FileExists($Drives[$i] & $DAS & $S & $Next_DAS & $LS_TIF) Then; If there is any IE files
                        _Zap_FOLDER($Drives[$i] & $DAS & $S & $Next_DAS & $LS_TIF)
                    EndIf
                EndIf
            WEnd
            FileClose($FFF_DAS); Tidyup and close search
        EndIf
    EndIf
Next

;Commands cmd
$cmd = 'cleanmgr /sageset'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'del /f /s /q %systemdrive%\*.tmp'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'del /f /s /q %systemdrive%\*._mp'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'del /f /s /q %systemdrive%\*.log del /f /s /q %systemdrive%\*.gid'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'del /f /s /q %systemdrive%\*.chk'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'del /f /s /q %systemdrive%\*.old del /f /s /q %systemdrive%\recycled\*.*'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'del /f /s /q %windir%\*.bak'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'del /f /s /q %windir%\prefetch\*.* rd /s /q %windir%\temp & md %windir%\temp'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'del /f /q %userprofile%\cookies\*.*'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'del /f /q %userprofile%\recent\*.*'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'del /f /s /q “%userprofile%\Local Settings\Temporary Internet Files\*.*” '
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'del /f /s /q “%userprofile%\Local Settings\Temp\*.*”'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'rmdir /s /q Recent'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'rmdir /s /q %temp%'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'cleanmgr /sagerun'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )

; Exit
_MsgBox(48, 'BatteryCare ™', "Your computer has been cleaned up!                 "& @CRLF &"")

EndFunc

;....................................................................................................................................................................

;The purpose is to delete cleanmgr /sageset

Func _PCCleaner()  ; After running for the first time
	
; Go through with all drives on system
For $i = 1 To $Drive_AMOUNT
; Clear out Temp in main drive folder
    If FileExists($Drives[$i] & $Temp) Then
        _Zap_FOLDER($Drives[$i] & $Temp)
    EndIf
    
; Clear out Temp within Windows folder
    If FileExists($Drives[$i] & $WIN & $Temp) Then; Temp in main drive folder
        _Zap_FOLDER($Drives[$i] & $WIN & $Temp)
    EndIf
    
; Clear out (hidden) temp within SystemcProfile folder
    If FileExists($Drives[$i] & $WIN & $Systemprofile & $LS_Temp) Then; Temp in main drive folder
        _Zap_FOLDER($Drives[$i] & $WIN & $Systemprofile & $LS_Temp)
    EndIf
    
; Clear out (hidden) IE files within SystemcProfile folder
    If FileExists($Drives[$i] & $WIN & $Systemprofile & $LS_TIF) Then; Temp in main drive folder
        _Zap_FOLDER($Drives[$i] & $WIN & $Systemprofile & $LS_TIF)
    EndIf
    
; Clear out Temp within WinNT folder
    If FileExists($Drives[$i] & $WINNT & $Temp) Then; Temp in main drive folder
        _Zap_FOLDER($Drives[$i] & $WINNT & $Temp)
    EndIf
    
; Clear out (hidden) temp within SystemcProfile folder
    If FileExists($Drives[$i] & $WINNT & $Systemprofile & $LS_Temp) Then; Temp in main drive folder
        _Zap_FOLDER($Drives[$i] & $WINNT & $Systemprofile & $LS_Temp)
    EndIf
    
; Clear out (hidden) IE files within SystemcProfile folder
    If FileExists($Drives[$i] & $WINNT & $Systemprofile & $LS_TIF) Then; Temp in main drive folder
        _Zap_FOLDER($Drives[$i] & $WINNT & $Systemprofile & $LS_TIF)
    EndIf
    
; Empty the recycle bin just in case ...
    FileRecycleEmpty($Drives[$i])
    
; Search and destroy within Documents and Settings
    If FileExists($Drives[$i] & $DAS) Then; Documents and Settings on this drive
        
        $FFF_DAS = FileFindFirstFile($Drives[$i] & $DAS & $All); Start off search
        If $FFF_DAS <> - 1 Then; Follow through if more than 0 elements found
            While 1
                $Next_DAS = FileFindNextFile($FFF_DAS); Get the folder's name
                If @error Then ExitLoop; Whoops, finished
                If $Next_DAS <> "." And $Next_DAS <> ".." Then
                    If FileExists($Drives[$i] & $DAS & $S & $Next_DAS & $LS_Temp) Then; If there are any temp files
                        _Zap_FOLDER($Drives[$i] & $DAS & $S & $Next_DAS & $LS_Temp)
                    EndIf
                    If FileExists($Drives[$i] & $DAS & $S & $Next_DAS & $LS_TIF) Then; If there is any IE files
                        _Zap_FOLDER($Drives[$i] & $DAS & $S & $Next_DAS & $LS_TIF)
                    EndIf
                EndIf
            WEnd
            FileClose($FFF_DAS); Tidyup and close search
        EndIf
    EndIf
Next

;Commands cmd
$cmd = 'del /f /s /q %systemdrive%\*.tmp'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'del /f /s /q %systemdrive%\*._mp'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'del /f /s /q %systemdrive%\*.log del /f /s /q %systemdrive%\*.gid'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'del /f /s /q %systemdrive%\*.chk'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'del /f /s /q %systemdrive%\*.old del /f /s /q %systemdrive%\recycled\*.*'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'del /f /s /q %windir%\*.bak'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'del /f /s /q %windir%\prefetch\*.* rd /s /q %windir%\temp & md %windir%\temp'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'del /f /q %userprofile%\cookies\*.*'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'del /f /q %userprofile%\recent\*.*'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'del /f /s /q “%userprofile%\Local Settings\Temporary Internet Files\*.*” '
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'del /f /s /q “%userprofile%\Local Settings\Temp\*.*”'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'rmdir /s /q Recent'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'rmdir /s /q %temp%'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )
$cmd = 'cleanmgr /sagerun'
RunWait(@ComSpec & " /c " & $CMD, "", @SW_HIDE  )

; Exit
_MsgBox(48, 'BatteryCare ™', "Your computer has been cleaned up!                 "& @CRLF &"")

EndFunc


; ==== FUNCTIONS =============================================================
Func _BatteryStatus()
        Local $aData = _WinAPI_GetSystemPowerStatus()
        If @error Then Return

        If BitAND($aData[1], 128) Then
                $aData[0] = 'Not present'
                For $i = 1 To 3
                        $aData[$i] = 'Unknown'
                Next
        Else
                Switch $aData[0]
                        Case 0
                                $aData[0] = 'Offline'
                        Case 1
                                $aData[0] = 'Online'
                        Case Else
                                $aData[0] = 'Unknown'
                EndSwitch
                Switch $aData[2]
                        Case 0 To 100
                                $aData[2] &= '%'
                        Case Else
                                $aData[2] = 'Unknown'
                EndSwitch
                Switch $aData[3]
                        Case -1
                                $aData[3] = 'Unknown'
                        Case Else
                                Local $H, $M
                                $H = ($aData[3] - Mod($aData[3], 3600)) / 3600
                                $M = ($aData[3] - Mod($aData[3], 60)) / 60 - $H * 60
                                $aData[3] = StringFormat($H & ':%02d', $M)
                EndSwitch
                If BitAND($aData[1], 8) Then
                        $aData[1] = 'Charging'
                Else
                        Switch BitAND($aData[1], 0xF)
                                Case 1
                                        $aData[1] = 'High'
                                Case 2
                                        $aData[1] = 'Low'
                                Case 4
                                        $aData[1] = 'Critical'
                                Case Else
                                        $aData[1] = 'Unknown'
                        EndSwitch
                EndIf
        EndIf
        For $i = 0 To 3
                GUICtrlSetData($g_aidLabel[$i], $aData[$i])
        Next
	EndFunc   ;==>_BatteryStatus

;....................................................................................................................................................................

Func _BatterySaver()
    $readButton = _GUICtrlButton_GetText($switch)
    If $readButton = "On" Then
		RunWait(@ComSpec & " /c TurnON.bat", @ScriptDir, @SW_HIDE)
		Sleep(500)
		_MsgBox(48, 'BatteryCare ™', 'Battery Saver is turned ON!                       '& @CRLF &"",3)
        GUICtrlSetPos($switch, 150, 134, 45, 25)
        _GUICtrlButton_SetText($switch, "Off")
    Else
		RunWait(@ComSpec & " /c TurnOFF.bat", @ScriptDir, @SW_HIDE)
		Sleep(500)
		_MsgBox(48, 'BatteryCare ™', 'Battery Saver is turned OFF!                      '& @CRLF &"",3)
        GUICtrlSetPos($switch, 150, 134, 45, 25)
        _GUICtrlButton_SetText($switch, "On")
    EndIf
EndFunc ;==>Battery Saver

;....................................................................................................................................................................

Func _OptimizeRAM()
	For $i = 0 to 32768 ; step 4
	Local $handle = DllCall('kernel32.dll', 'handle', 'OpenProcess', 'dword', 0x1F0FFF, 'bool', 0, 'dword', $i)
	If Not @error Then
		$handle = $handle[0]
		DllCall('kernel32.dll', 'bool', 'SetProcessWorkingSetSizeEx', 'handle', $handle, 'int', -1, 'int', -1, 'dword', 0x1)
		DllCall('psapi.dll', 'bool', 'EmptyWorkingSet', 'handle', $handle)
		DllCall('kernel32.dll', 'bool', 'CloseHandle', 'handle', $handle)
	EndIf
Next
	_MsgBox(48, 'BatteryCare ™', "Your computer's ram has been optimized!"& @CRLF &"",3)
EndFunc	;==>Optimize Ram

;....................................................................................................................................................................

Func _Verif_PROG()
    $g_szVersion = "BatteryCare ™"; Name this program
    If WinExists($g_szVersion) Then Exit; Already there!
    AutoItWinSetTitle($g_szVersion)
EndFunc  ;==>Verif_PROG

;....................................................................................................................................................................

Func _Find_DRIVES()
    $Drives = DriveGetDrive( "FIXED"); Get all hard drives
    If Not @error Then
        Return $Drives[0]; Returns the # of drives found
    Else
		_MsgBox(16, 'PC Cleaner ™', 'Error!                                            '& @CRLF & 'No harddrives available!',3); Whoops?
        Exit
    EndIf
EndFunc  ;==>Find_DRIVES

;....................................................................................................................................................................

Func _Zap_FOLDER($Var1)
; $Var1 = Folder who's content will be flushed
    
    FileSetAttrib($Var1 & $All, "-RASHNOT", 1); Remove all attributes
    
    FileDelete($Var1 & $All); Start by erasing all files
; Let's make this simple - whatever is left is probably a folder
    
    $Var2 = FileFindFirstFile($Var1 & $All); Start off search
    If $Var2 = -1 Then; It's an empty folder ...
        FileClose($Var2); Tidyup and close search
        Return; No more files
    EndIf
    
; Ok then delete all folders ...
    While 1
        $Var3 = FileFindNextFile($Var2); Find first folder
        If @error Then ExitLoop; We passed last folder
        If $Var3 <> "." And $Var3 <> ".." Then
            DirRemove($Var1 & "\" & $Var3, 1); And now erase that folder
        EndIf
    WEnd; Until such a time as all folders are deleted
    FileClose($Var2); Tidyup and close search
    
EndFunc  ;==>Zap_FOLDER

;....................................................................................................................................................................

Func _Readfilelog()
	$sfilepathf = $filelog
	Local $hfileopen = FileOpen($sfilepathf, $fo_read)
	If $hfileopen = -1 Then
		Return ""
	EndIf
	Local $sfileread = FileRead($hfileopen)
    If $sfileread = "OK" Then 
		_PCCleaner()
	Else
		_PCCleaner_Log()	
	EndIf
	FileClose($hfileopen)
EndFunc
;==> Read file log

Func _Writefilelog()
	FileWrite($filelog, "")
	FileDelete($filelog)
	FileWrite($filelog, "OK")
EndFunc
;==> Create file log

;....................................................................................................................................................................

Func _exit()
	 _MsgBox(16, 'BatteryCare ™', 'Thank you for using!                              '& @CRLF & 'See ya <3',3)
	Exit
EndFunc	;==> Exit
