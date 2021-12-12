#include-once
#include <Constants.au3>
#include <Date.au3>
#include <String.au3>

; #INDEX# =======================================================================================================================
; Title .........: SFTP
; AutoIt Version : 3.3.8.0++
; Language ......: English
; Description ...: Functions that assist with SFTP using psftp from PuTTY package.
; Author(s) .....: Lupo73
; Modified.......: NSC (2018-2019)
; Notes .........: Function names and parameters inspired by FTPEx.au3
; Exe(s) ........: psftp.exe
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $__gsLocalDir_SFTP, $__gsRemoteDir_SFTP
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_SFTP_Close
;_SFTP_Connect
;_SFTP_DirCreate
;_SFTP_DirDelete
;_SFTP_DirGetContents
;_SFTP_DirGetCurrent
;_SFTP_DirGetCurrentLocal
;_SFTP_DirPutContents
;_SFTP_DirSetCurrent
;_SFTP_DirSetCurrentLocal
;_SFTP_FileDelete
;_SFTP_FileExists
;_SFTP_FileGet
;_SFTP_FileGetInfo
;_SFTP_FileGetSize
;_SFTP_FileMove
;_SFTP_FilePut
;_SFTP_ListToArray
;_SFTP_ListToArrayEx ; <<<<<<<<<<< time not updated with timezone offset
;_SFTP_Open
;_SFTP_ProgressDownload ; <<<<<<<<<<< not complete
;_SFTP_ProgressUpload
; ===============================================================================================================================

; #INTERNAL_USE_ONLY#============================================================================================================
;__MonthToNumber
;__WinAPI_GetFullPathName
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _SFTP_Close
; Description ...: Closes the _SFTP_Open session.
; Syntax.........: _SFTP_Close ( $hSession )
; Parameters ....: $hSession - as returned by _SFTP_Open().
; Return values .: Success - 1
;                  Failure - 0, sets @error
;                  |1 - Fails to close the session
; Author ........: Lupo73, IgneusJotunn
; Modified.......:
; Remarks .......:
; Related .......: _SFTP_Open
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SFTP_Close($hSession)
    If ProcessExists($hSession) = 0 Then
        Return 1
    EndIf
    StdinWrite($hSession, "bye")

    ProcessClose($hSession)
    If @error Then
        Return SetError(1, 0, 0)
    EndIf

    Return 1
EndFunc   ;==>_SFTP_Close

; #FUNCTION# ====================================================================================================================
; Name...........: _SFTP_Connect
; Description ...: Connects to a SFTP server.
; Syntax.........: _SFTP_Connect ( $hSession, $sServerName [, $sUsername = "" [, $sPassword = "" [, $iServerPort = 0]]] )
; Parameters ....: $hSession - as returned by _SFTP_Open().
;                  $sServerName - Server name/ip.
;                  $sUsername - Optional, Username.
;                  $sPassword - Optional, Password.
;                  $iServerPort - Optional, Server port ( 0 is default (22) )
; Return values .: Success - Returns an identifier
;                  Failure - 0, sets @error
;                  |1 - The session is closed
;                  |2 - Access denied
;                  |3 - Other error
;                  |4 - timeout error on user login     ; NSC modified
;                  |5 - timeout error on password login ; NSC modified
; Author ........: Lupo73, trainer
; Modified.......: NSC
; Remarks .......:
; Related .......: _SFTP_Open
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SFTP_Connect($hSession, $sServerName, $sUsername = "", $sPassword = "", $iServerPort = 0)
    If ProcessExists($hSession) = 0 Then
        Return SetError(1, 0, 0)
    EndIf

    If $iServerPort = 0 Then
        $iServerPort = ""
    EndIf

    Local $sLine, $sStringSplit, $iWaitKeySaving = 0, $bSaveKey = True
    StdinWrite($hSession, 'open ' & $sServerName & ' ' & $iServerPort & @CRLF)
    Local $Ltimeout = 0         ; NSC modified 10ms * 1000 = 10.000 = 10 seconds timeout
    While 1

        $Ltimeout += 1 ; NSC modified
        $iWaitKeySaving += 1
        If $iWaitKeySaving >= 500 And $bSaveKey Then
            StdinWrite($hSession, 'y' & @CRLF)
            $bSaveKey = False
        EndIf
        $sLine = StdoutRead($hSession)
        If ProcessExists($hSession) = 0 Then
            Return SetError(1, 0, 0)
        ElseIf StringInStr($sLine, "psftp>") Then
            ExitLoop
        ElseIf StringInStr($sLine, "login as:") Then
            StdinWrite($hSession, $sUsername & @CRLF)

            While 1

                $sLine = StdoutRead($hSession)
                If ProcessExists($hSession) = 0 Then
                    Return SetError(1, 0, 0)
                ElseIf StringInStr($sLine, "psftp>") Then
                    ExitLoop 2
                ElseIf StringInStr($sLine, "password:") Then
                    StdinWrite($hSession, $sPassword & @CRLF)
                    ExitLoop 2
                EndIf
                Sleep(10)

            WEnd
        ElseIf $sLine <> "" Then
            Return SetError(3, 0, 0)
        EndIf
        Sleep(10)
        If $Ltimeout > 1000 Then    ; NSC modified
            Return SetError(4, 0, 0); NSC generic timeout
        EndIf
    WEnd

    If $sLine <> "psftp>" Then ; Connection With User And Password.
        $Ltimeout = 0         ; NSC modified 10ms * 1000 = 10.000 = 10 seconds timeout
        While 1
            $Ltimeout += 1     ; NSC modified
            $sLine = StdoutRead($hSession)
            If ProcessExists($hSession) = 0 Then
                Return SetError(1, 0, 0)
            ElseIf StringInStr($sLine, "psftp>") Then
                ExitLoop
            ElseIf StringInStr($sLine, "Access denied") Then
                Return SetError(2, 0, 0) ; The Password Is Required Again.
            EndIf
            Sleep(10)
            If $Ltimeout > 1000 Then        ; NSC modified
                Return SetError(5, 0, 0)    ; NSC pass not valid
            EndIf
        WEnd
    EndIf

    If StringInStr($sLine, "Remote working directory is") Then
        $sStringSplit = StringSplit($sLine, @CRLF)
        $__gsRemoteDir_SFTP = StringTrimLeft($sStringSplit[1], 28)
    EndIf
    If $__gsRemoteDir_SFTP = 0 Then
        $__gsRemoteDir_SFTP = _SFTP_DirGetCurrent($hSession)
    EndIf

    Return $hSession
EndFunc   ;==>_SFTP_Connect

; #FUNCTION# ====================================================================================================================
; Name...........: _SFTP_DirCreate
; Description ...: Makes a Directory on a SFTP server.
; Syntax.........: _SFTP_DirCreate ( $hConnection, $sRemoteDir )
; Parameters ....: $hConnection - as returned by _SFTP_Connect().
;                  $sRemoteDir - The remote Directory to create.
; Return values .: Success - 1
;                  Failure - 0, sets @error
;                  |1 - The connection is closed
;                  |2 - Creation probably failed because the Directory already exists
;                  |3 - Other error
; Author ........: Lupo73
; Modified.......:
; Remarks .......:
; Related .......: _SFTP_Connect
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SFTP_DirCreate($hConnection, $sRemoteDir)
    If ProcessExists($hConnection) = 0 Then
        Return SetError(1, 0, 0)
    EndIf

    Local $sLine
    StdinWrite($hConnection, 'mkdir "' & $sRemoteDir & '"' & @CRLF)
    While 1
        $sLine = StdoutRead($hConnection)
        If ProcessExists($hConnection) = 0 Then
            Return SetError(1, 0, 0)
        ElseIf StringInStr($sLine, $sRemoteDir & ": OK") Then
            ExitLoop
        ElseIf StringInStr($sLine, $sRemoteDir & ": failure") Then
            Return SetError(2, 0, 0)
        ElseIf $sLine <> "" Then
            Return SetError(3, 0, 0)
        EndIf
        Sleep(10)
    WEnd

    Return 1
EndFunc   ;==>_SFTP_DirCreate

; #FUNCTION# ====================================================================================================================
; Name...........: _SFTP_DirDelete
; Description ...: Deletes a Directory on a SFTP server.
; Syntax.........: _SFTP_DirDelete ( $hConnection, $sRemoteDir )
; Parameters ....: $hConnection - as returned by _SFTP_Connect().
;                  $sRemoteDir - The remote Directory to be deleted.
; Return values .: Success - 1
;                  Failure - 0, sets @error
;                  |1 - The connection is closed
;                  |2 - Directory not found
;                  |3 - Directory probably contains not removable files
;                  |4 - Failed listing Directory
;                  |5 - Other error
; Author ........: Lupo73
; Modified.......:
; Remarks .......:
; Related .......: _SFTP_Connect, _SFTP_FileDelete, _SFTP_ListToArrayEx
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SFTP_DirDelete($hConnection, $sRemoteDir)
    If ProcessExists($hConnection) = 0 Then
        Return SetError(1, 0, 0)
    EndIf

    Local $aFileList = _SFTP_ListToArrayEx($hConnection, $sRemoteDir)
    If @error Then
        Return SetError(4, 0, 0)
    EndIf
    If $aFileList[0][0] > 0 Then
        For $A = 1 To $aFileList[0][0]
            If StringLeft($aFileList[$A][2], 1) <> "d" Then
                _SFTP_FileDelete($hConnection, $sRemoteDir & "/" & $aFileList[$A][0])
            Else
                _SFTP_DirDelete($hConnection, $sRemoteDir & "/" & $aFileList[$A][0])
            EndIf
            If @error Then
                Return SetError(5, 0, 0)
            EndIf
        Next
    EndIf

    Local $sLine
    StdinWrite($hConnection, 'rmdir "' & $sRemoteDir & '"' & @CRLF)
    While 1
        $sLine = StdoutRead($hConnection)
        If ProcessExists($hConnection) = 0 Then
            Return SetError(1, 0, 0)
        ElseIf StringInStr($sLine, $sRemoteDir & ": OK") Then
            ExitLoop
        ElseIf StringInStr($sLine, "no such file or directory") Then
            Return SetError(2, 0, 0)
        ElseIf StringInStr($sLine, $sRemoteDir & ": failure") Then
            Return SetError(3, 0, 0)
        ElseIf $sLine <> "" Then
            Return SetError(5, 0, 0)
        EndIf
        Sleep(10)
    WEnd

    Return 1
EndFunc   ;==>_SFTP_DirDelete

; #FUNCTION# ====================================================================================================================
; Name...........: _SFTP_DirGetContents
; Description ...: Get a folder from a SFTP server.
; Syntax.........: _SFTP_DirGetContents ( $hConnection, $sRemoteFolder [, $sLocalFolder = "" [, $fFailIfExists = False [, $fRecursiveGet = 1]]] )
; Parameters ....: $hConnection - as returned by _SFTP_Connect().
;                  $sRemoteFolder - The remote folder i.e. "/website/home".
;                  $sLocalFolder - Optional, The local folder (or use the source name if not defined) i.e. "c:\temp".
;                  $fFailIfExists - Optional, True: do not overwrite existing (default = False)
;                  $fRecursiveGet - Optional, Recurse through sub-dirs: 0 = Non recursive, 1 = Recursive (default)
; Return values .: Success - 1
;                  Failure - 0, sets @error
;                  |1 - The connection is closed
;                  |2 - Local folder exists and $fFailIfExists = True
;                  |3 - Remote folder not found
;                  |4 - Other error
; Author ........: Lupo73
; Modified.......:
; Remarks .......:
; Related .......: _SFTP_Connect
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SFTP_DirGetContents($hConnection, $sRemoteFolder, $sLocalFolder = "", $fFailIfExists = False, $fRecursiveGet = 1)
    If ProcessExists($hConnection) = 0 Then
        Return SetError(1, 0, 0)
    EndIf

    If $sLocalFolder <> "" Then
        $sLocalFolder = __WinAPI_GetFullPathName($sLocalFolder)
        If FileExists($sLocalFolder) Then
            If $fFailIfExists Then
                Return SetError(2, 0, 0)
            EndIf
        EndIf
        $sLocalFolder = ' "' & $sLocalFolder & '"'
    EndIf

    Local $sLine
    If $fRecursiveGet Then
        $sLine = '-r '
    EndIf
    StdinWrite($hConnection, 'get ' & $sLine & '-- "' & $sRemoteFolder & '"' & $sLocalFolder & @CRLF)
    While 1
        $sLine = StdoutRead($hConnection)
        If ProcessExists($hConnection) = 0 Then
            Return SetError(1, 0, 0)
        ElseIf StringInStr($sLine, "psftp>") Then
            ExitLoop
        ElseIf StringInStr($sLine, "=> local:") Then
            ContinueLoop
        ElseIf StringInStr($sLine, "no such file or directory") Then
            Return SetError(3, 0, 0)
        ElseIf $sLine <> "" Then
            Return SetError(4, 0, 0)
        EndIf
        Sleep(10)
    WEnd

    Return 1
EndFunc   ;==>_SFTP_DirGetContents

; #FUNCTION# ====================================================================================================================
; Name...........: _SFTP_DirGetCurrent
; Description ...: Get current remote Directory of a SFTP connection.
; Syntax.........: _SFTP_DirGetCurrent ( $hConnection )
; Parameters ....: $hConnection - as returned by _SFTP_Connect().
; Return values .: Success - Remote Directory
;                  Failure - 0, sets @error
;                  |1 - The connection is closed
;                  |2 - Other error
; Author ........: Lupo73
; Modified.......:
; Remarks .......:
; Related .......: _SFTP_Connect
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SFTP_DirGetCurrent($hConnection)
    If ProcessExists($hConnection) = 0 Then
        Return SetError(1, 0, 0)
    EndIf

    If $__gsRemoteDir_SFTP <> 0 Then
        Return $__gsRemoteDir_SFTP
    EndIf

    Local $sLine
    StdinWrite($hConnection, 'pwd' & @CRLF)
    While 1
        $sLine = StdoutRead($hConnection)
        If ProcessExists($hConnection) = 0 Then
            Return SetError(1, 0, 0)
        ElseIf StringInStr($sLine, "Remote directory is") Then
            ExitLoop
        ElseIf $sLine <> "" Then
            Return SetError(2, 0, 0)
        EndIf
        Sleep(10)
    WEnd

    Return StringTrimLeft($sLine, 20)
EndFunc   ;==>_SFTP_DirGetCurrent

; #FUNCTION# ====================================================================================================================
; Name...........: _SFTP_DirGetCurrentLocal
; Description ...: Get current local Directory of a SFTP connection.
; Syntax.........: _SFTP_DirGetCurrentLocal ( $hConnection )
; Parameters ....: $hConnection - as returned by _SFTP_Connect().
; Return values .: Success - Local Directory
;                  Failure - 0, sets @error
;                  |1 - The connection is closed
;                  |2 - Other error
; Author ........: Lupo73
; Modified.......:
; Remarks .......:
; Related .......: _SFTP_Connect
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SFTP_DirGetCurrentLocal($hConnection)
    If ProcessExists($hConnection) = 0 Then
        Return SetError(1, 0, 0)
    EndIf

    If $__gsLocalDir_SFTP <> 0 Then
        Return $__gsLocalDir_SFTP
    EndIf

    Local $sLine
    StdinWrite($hConnection, 'lpwd' & @CRLF)
    While 1
        $sLine = StdoutRead($hConnection)
        If ProcessExists($hConnection) = 0 Then
            Return SetError(1, 0, 0)
        ElseIf StringInStr($sLine, "Current local directory is") Then
            ExitLoop
        ElseIf $sLine <> "" Then
            Return SetError(2, 0, 0)
        EndIf
        Sleep(10)
    WEnd

    Return StringTrimLeft($sLine, 27)
EndFunc   ;==>_SFTP_DirGetCurrentLocal

; #FUNCTION# ====================================================================================================================
; Name...........: _SFTP_DirPutContents
; Description ...: Puts a folder on a SFTP server. Recursively if selected.
; Syntax.........: _SFTP_DirPutContents ( $hConnection, $sLocalFolder [, $sRemoteFolder = "" [, $fRecursivePut = 1]]] )
; Parameters ....: $hConnection - as returned by _SFTP_Connect().
;                  $sLocalFolder - The local folder i.e. "c:\temp".
;                  $sRemoteFolder - Optional, The remote folder (or use the source name if not defined) i.e. "/website/home".
;                  $fRecursivePut - Optional, Recurse through sub-dirs: 0 = Non recursive, 1 = Recursive (default)
; Return values .: Success - 1
;                  Failure - 0, sets @error
;                  |1 - The connection is closed
;                  |2 - Local folder does not exists
;                  |3 - Remote folder cannot be created
;                  |4 - Other error
; Author ........: Lupo73
; Modified.......:
; Remarks .......:
; Related .......: _SFTP_Connect
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SFTP_DirPutContents($hConnection, $sLocalFolder, $sRemoteFolder = "", $fRecursivePut = 1)
    If ProcessExists($hConnection) = 0 Then
        Return SetError(1, 0, 0)
    EndIf

    If $sRemoteFolder <> "" Then
        $sRemoteFolder = ' "' & $sRemoteFolder & '"'
    EndIf

    Local $sLine
    If $fRecursivePut Then
        $sLine = '-r '
    EndIf
    StdinWrite($hConnection, 'put ' & $sLine & '-- "' & $sLocalFolder & '"' & $sRemoteFolder & @CRLF)
    While 1
        $sLine = StdoutRead($hConnection)
        If ProcessExists($hConnection) = 0 Then
            Return SetError(1, 0, 0)
        ElseIf StringInStr($sLine, "psftp>") Then
            ExitLoop
        ElseIf StringInStr($sLine, "=> remote:") Then
            ContinueLoop
        ElseIf StringInStr($sLine, "unable to open") Then
            Return SetError(2, 0, 0)
        ElseIf StringInStr($sLine, "Cannot create directory") Then
            Return SetError(3, 0, 0)
        ElseIf $sLine <> "" Then
            Return SetError(4, 0, 0)
        EndIf
        Sleep(10)
    WEnd

    Return 1
EndFunc   ;==>_SFTP_DirPutContents

; #FUNCTION# ====================================================================================================================
; Name...........: _SFTP_DirSetCurrent
; Description ...: Set current remote Directory of a SFTP connection.
; Syntax.........: _SFTP_DirSetCurrent ( $hConnection [, $sRemoteDir = ""] )
; Parameters ....: $hConnection - as returned by _SFTP_Connect().
;                  $sRemoteDir - Optional, The remote Directory (or use the original Directory if not defined) i.e. "/website/home".
; Return values .: Success - Remote Directory ; note by NSC: Success - string starting with "Remote directory is now "& $\theremotedir
;                  Failure - 0, sets @error
;                  |1 - The connection is closed
;                  |2 - Directory not found
;                  |3 - Other error
; Author ........: Lupo73
; Modified.......:
; Remarks .......:
; Related .......: _SFTP_Connect
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SFTP_DirSetCurrent($hConnection, $sRemoteDir = "")
    If ProcessExists($hConnection) = 0 Then
        Return SetError(1, 0, 0)
    EndIf

    Local $sLine
    StdinWrite($hConnection, 'cd "' & $sRemoteDir & '"' & @CRLF)
    While 1
        $sLine = StdoutRead($hConnection)

        If ProcessExists($hConnection) = 0 Then
            Return SetError(1, 0, 0)
        ElseIf StringInStr($sLine, "Remote directory is now") Then
            ExitLoop
        ElseIf StringInStr($sLine, "no such file or directory") Then
            Return SetError(2, 0, 0)
        ElseIf $sLine <> "" Then
            Return SetError(3, 0, 0)
        EndIf
        Sleep(10)
    WEnd
    ;gollog("debug in include: " & $sLine) ; debug NSC
    $__gsRemoteDir_SFTP = StringTrimLeft($sLine, 24)

    Return $__gsRemoteDir_SFTP
EndFunc   ;==>_SFTP_DirSetCurrent

; #FUNCTION# ====================================================================================================================
; Name...........: _SFTP_DirSetCurrentLocal
; Description ...: Set current local Directory of a SFTP connection.
; Syntax.........: _SFTP_DirSetCurrentLocal ( $hConnection, $sLocalDir )
; Parameters ....: $hConnection - as returned by _SFTP_Connect().
;                  $sLocalDir - The local Directory i.e. "c:\temp".
; Return values .: Success - Local Directory
;                  Failure - 0, sets @error
;                  |1 - The connection is closed
;                  |2 - Directory not found
;                  |3 - Other error
; Author ........: Lupo73
; Modified.......:
; Remarks .......:
; Related .......: _SFTP_Connect
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SFTP_DirSetCurrentLocal($hConnection, $sLocalDir)
    If ProcessExists($hConnection) = 0 Then
        Return SetError(1, 0, 0)
    EndIf

    Local $sLine
    StdinWrite($hConnection, 'lcd "' & $sLocalDir & '"' & @CRLF)
    While 1
        $sLine = StdoutRead($hConnection)
        If ProcessExists($hConnection) = 0 Then
            Return SetError(1, 0, 0)
        ElseIf StringInStr($sLine, "New local directory is") Then
            ExitLoop
        ElseIf StringInStr($sLine, "unable to") Then
            Return SetError(2, 0, 0)
        ElseIf $sLine <> "" Then
            Return SetError(3, 0, 0)
        EndIf
        Sleep(10)
    WEnd

    $__gsLocalDir_SFTP = StringTrimLeft($sLine, 23)

    Return $__gsLocalDir_SFTP
EndFunc   ;==>_SFTP_DirSetCurrentLocal

; #FUNCTION# ====================================================================================================================
; Name...........: _SFTP_FileDelete
; Description ...: Deletes a file on a SFTP server.
; Syntax.........: _SFTP_FileDelete ( $hConnection, $sRemoteFile )
; Parameters ....: $hConnection - as returned by _SFTP_Connect().
;                  $sRemoteFile - The remote file to be deleted.
; Return values .: Success - 1
;                  Failure - 0, sets @error
;                  |1 - The connection is closed
;                  |2 - File not found
;                  |3 - Other error
; Author ........: Lupo73
; Modified.......:
; Remarks .......:
; Related .......: _SFTP_Connect, _SFTP_DirDelete
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SFTP_FileDelete($hConnection, $sRemoteFile)
    If ProcessExists($hConnection) = 0 Then
        Return SetError(1, 0, 0)
    EndIf

    Local $sLine
    StdinWrite($hConnection, 'del "' & $sRemoteFile & '"' & @CRLF)
    While 1
        $sLine = StdoutRead($hConnection)
        If ProcessExists($hConnection) = 0 Then
            Return SetError(1, 0, 0)
        ElseIf StringInStr($sLine, $sRemoteFile & ": OK") Then
            ExitLoop
        ElseIf StringInStr($sLine, "no such file or directory") Then
            Return SetError(2, 0, 0)
        ElseIf $sLine <> "" Then
            Return SetError(3, 0, 0)
        EndIf
        Sleep(10)
    WEnd

    Return 1
EndFunc   ;==>_SFTP_FileDelete

; #FUNCTION# ====================================================================================================================
; Name...........: _SFTP_FileExists
; Description ...: Checks if a file or folder exists on a SFTP server.
; Syntax.........: _SFTP_FileExists ( $hConnection, $sRemoteFile )
; Parameters ....: $hConnection - as returned by _SFTP_Connect().
;                  $sRemoteFile - The remote file.
; Return values .: Success - 1
;                  Failure - 0, sets @error
;                  |1 - The connection is closed
;                  |2 - Directory not found
;                  |3 - Directory is empty
; Author ........: Lupo73
; Modified.......:
; Remarks .......:
; Related .......: _SFTP_Connect
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SFTP_FileExists($hConnection, $sRemoteFile)
    If ProcessExists($hConnection) = 0 Then
        Return SetError(1, 0, 0)
    EndIf

    Local $aStringSplit, $aFileList, $iExists = 0, $sRemoteDir = ""
    $aStringSplit = StringSplit($sRemoteFile, "/")
    If $aStringSplit[0] > 1 Then
        $sRemoteDir = StringTrimRight($sRemoteFile, StringLen($aStringSplit[$aStringSplit[0]]) + 1)
        $sRemoteFile = $aStringSplit[$aStringSplit[0]]
    EndIf
    $aFileList = _SFTP_ListToArray($hConnection, $sRemoteDir)
    If @error Then
        Return SetError(2, 0, 0)
    EndIf
    If $aFileList[0] = 0 Then
        Return SetError(3, 0, 0)
    EndIf

    For $A = 1 To $aFileList[0]
        If $sRemoteFile = $aFileList[$A] Then
            $iExists = 1
            ExitLoop
        EndIf
    Next

    Return $iExists
EndFunc   ;==>_SFTP_FileExists

; #FUNCTION# ====================================================================================================================
; Name...........: _SFTP_FileGet
; Description ...: Get a file from a SFTP server.
; Syntax.........: _SFTP_FileGet ( $hConnection, $sRemoteFile [, $sLocalFile = "" [, $fFailIfExists = False]] )
; Parameters ....: $hConnection - as returned by _SFTP_Connect().
;                  $sRemoteFile - The remote file.
;                  $sLocalFile - Optional, The local file (or use the source name if not defined).
;                  $fFailIfExists - Optional, True: do not overwrite existing (default = False)
; Return values .: Success - 1
;                  Failure - 0, sets @error
;                  |1 - The connection is closed
;                  |2 - Local file exists and $fFailIfExists = True
;                  |3 - Remote file not found
;                  |4 - Other error
; Author ........: Lupo73
; Modified.......:
; Remarks .......:
; Related .......: _SFTP_Connect
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SFTP_FileGet($hConnection, $sRemoteFile, $sLocalFile = "", $fFailIfExists = False)
    If ProcessExists($hConnection) = 0 Then
        Return SetError(1, 0, 0)
    EndIf

    If $sLocalFile <> "" Then
        $sLocalFile = __WinAPI_GetFullPathName($sLocalFile)
        If FileExists($sLocalFile) Then
            If $fFailIfExists Then
                Return SetError(2, 0, 0)
            EndIf
        EndIf
        $sLocalFile = ' "' & $sLocalFile & '"'
    EndIf

    Local $sLine
    StdinWrite($hConnection, 'get -- "' & $sRemoteFile & '"' & $sLocalFile & @CRLF)
    While 1
        $sLine = StdoutRead($hConnection)
        If ProcessExists($hConnection) = 0 Then
            Return SetError(1, 0, 0)
        ElseIf StringInStr($sLine, "psftp>") Then
            ExitLoop
        ElseIf StringInStr($sLine, "=> local:") Then
            ContinueLoop
        ElseIf StringInStr($sLine, "no such file or directory") Then
            Return SetError(3, 0, 0)
        ElseIf $sLine <> "" Then
            Return SetError(4, 0, 0)
        EndIf
        Sleep(10)
    WEnd

    Return 1
EndFunc   ;==>_SFTP_FileGet

; #FUNCTION# ====================================================================================================================
; Name...........: _SFTP_FileGetInfo
; Description ...: Get info of a file or folder from a SFTP server.
; Syntax.........: _SFTP_FileGetInfo ( $hConnection, $sRemoteFile )
; Parameters ....: $hConnection - as returned by _SFTP_Connect().
;                  $sRemoteFile - The remote file.
; Return values .: Success - returns an Array containing file info.
;                  Failure - 0, sets @error
;                  |1 - The connection is closed
;                  |2 - Directory not found
;                  |3 - Directory is empty
;                  |4 - File not found
; Author ........: Lupo73
; Modified.......:
; Remarks .......: Array[0] Filename
;                  Array[1] Filesize
;                  Array[2] Permissions
;                  Array[3] File Modification datetime
;                  Array[4] Owner/Group
; Related .......: _SFTP_Connect, _SFTP_ListToArrayEx
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SFTP_FileGetInfo($hConnection, $sRemoteFile)
    If ProcessExists($hConnection) = 0 Then
        Return SetError(1, 0, 0)
    EndIf

    Local $aArray[5], $aStringSplit, $aFileList, $sRemoteDir = ""
    $aStringSplit = StringSplit($sRemoteFile, "/")
    If $aStringSplit[0] > 1 Then
        $sRemoteDir = StringTrimRight($sRemoteFile, StringLen($aStringSplit[$aStringSplit[0]]) + 1)
        $sRemoteFile = $aStringSplit[$aStringSplit[0]]
    EndIf
    $aFileList = _SFTP_ListToArrayEx($hConnection, $sRemoteDir)
    If @error Then
        Return SetError(2, 0, 0)
    EndIf
    If $aFileList[0][0] = 0 Then
        Return SetError(3, 0, 0)
    EndIf

    For $A = 1 To $aFileList[0][0]
        If $sRemoteFile = $aFileList[$A][0] Then
            For $B = 0 To 4
                $aArray[$B] = $aFileList[$A][$B]
            Next
            Return $aArray
        EndIf
    Next

    Return SetError(4, 0, 0)
EndFunc   ;==>_SFTP_FileGetInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _SFTP_FileGetSize
; Description ...: Get the filesize of a file from a SFTP server.
; Syntax.........: _SFTP_FileGetSize ( $hConnection, $sRemoteFile )
; Parameters ....: $hConnection - as returned by _SFTP_Connect().
;                  $sRemoteFile - The remote file.
; Return values .: Success - Filesize
;                  Failure - 0, sets @error
;                  |1 - The connection is closed
;                  |2 - Remote directory not found
;                  |3 - Remote directory is empty
; Author ........: Lupo73
; Modified.......:
; Remarks .......:
; Related .......: _SFTP_Connect, _SFTP_ListToArrayEx
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SFTP_FileGetSize($hConnection, $sRemoteFile)
    If ProcessExists($hConnection) = 0 Then
        Return SetError(1, 0, 0)
    EndIf

    Local $aStringSplit, $aFileList, $iSize = 0, $sRemoteDir = ""
    $aStringSplit = StringSplit($sRemoteFile, "/")
    If $aStringSplit[0] > 1 Then
        $sRemoteDir = StringTrimRight($sRemoteFile, StringLen($aStringSplit[$aStringSplit[0]]) + 1)
        $sRemoteFile = $aStringSplit[$aStringSplit[0]]
    EndIf
    $aFileList = _SFTP_ListToArrayEx($hConnection, $sRemoteDir, 2)
    If @error Then
        Return SetError(2, 0, 0)
    EndIf
    If $aFileList[0][0] = 0 Then
        Return SetError(3, 0, 0)
    EndIf

    For $A = 1 To $aFileList[0][0]
        If $sRemoteFile = $aFileList[$A][0] Then
            $iSize = $aFileList[$A][1]
            ExitLoop
        EndIf
    Next

    Return $iSize
EndFunc   ;==>_SFTP_FileGetSize

; #FUNCTION# ====================================================================================================================
; Name...........: _SFTP_FileMove
; Description ...: Move/Rename a file on a SFTP server.
; Syntax.........: _SFTP_FileMove ( $hConnection, $sSourceFile, $sDestinationFile )
; Parameters ....: $hConnection - as returned by _SFTP_Connect().
;                  $sSourceFile - The source file to move/rename.
;                  $sDestinationFile - The destination file to move/rename.
; Return values .: Success - 1
;                  Failure - 0, sets @error
;                  |1 - The connection is closed
;                  |2 - File not found
;                  |3 - Other error
; Author ........: Lupo73
; Modified.......:
; Remarks .......:
; Related .......: _SFTP_Connect
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SFTP_FileMove($hConnection, $sSourceFile, $sDestinationFile)
    If ProcessExists($hConnection) = 0 Then
        Return SetError(1, 0, 0)
    EndIf

    Local $sLine
    StdinWrite($hConnection, 'mv "' & $sSourceFile & '" "' & $sDestinationFile & '"' & @CRLF)
    While 1
        $sLine = StdoutRead($hConnection)
        If ProcessExists($hConnection) = 0 Then
            Return SetError(1, 0, 0)
        ElseIf StringInStr($sLine, "psftp>") Then
            ExitLoop
        ElseIf StringInStr($sLine, $sSourceFile & " -> ") Then
            ContinueLoop
        ElseIf StringInStr($sLine, "no such file or directory") Then
            Return SetError(2, 0, 0)
        ElseIf $sLine <> "" Then
            Return SetError(3, 0, 0)
        EndIf
        Sleep(10)
    WEnd

    Return 1
EndFunc   ;==>_SFTP_FileMove

; #FUNCTION# ====================================================================================================================
; Name...........: _SFTP_FilePut
; Description ...: Puts a file on a SFTP server.
; Syntax.........: _SFTP_FilePut ( $hConnection, $sLocalFile [, $sRemoteFile = ""] )
; Parameters ....: $hConnection - as returned by _SFTP_Connect().
;                  $sLocalFile - The local file i.e. "c:\temp".
;                  $sRemoteFile - Optional, The remote file (or use the source name if not defined) i.e. "/website/home".
;                  $fRecursivePut - Optional, Recurse through sub-dirs: 0 = Non recursive, 1 = Recursive (default)
; Return values .: Success - 1
;                  Failure - 0, sets @error
;                  |1 - The connection is closed
;                  |2 - Local file does not exists
;                  |3 - Other error
; Author ........: Lupo73
; Modified.......:
; Remarks .......:
; Related .......: _SFTP_Connect
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SFTP_FilePut($hConnection, $sLocalFile, $sRemoteFile = "")
    If ProcessExists($hConnection) = 0 Then
        Return SetError(1, 0, 0)
    EndIf

    Local $sLine
    If $sRemoteFile <> "" Then
        $sRemoteFile = ' "' & $sRemoteFile & '"'
    EndIf
    StdinWrite($hConnection, 'put -- "' & $sLocalFile & '"' & $sRemoteFile & @CRLF)
    While 1
        $sLine = StdoutRead($hConnection)
        If ProcessExists($hConnection) = 0 Then
            Return SetError(1, 0, 0)
        ElseIf StringInStr($sLine, "psftp>") Then
            ExitLoop
        ElseIf StringInStr($sLine, "=> remote:") Then
            ContinueLoop
        ElseIf StringInStr($sLine, "unable to open") Then
            Return SetError(2, 0, 0)
        ElseIf $sLine <> "" Then
            Return SetError(3, 0, 0)
        EndIf
        Sleep(10)
    WEnd

    Return 1
EndFunc   ;==>_SFTP_FilePut

; #FUNCTION# ====================================================================================================================
; Name...........: _SFTP_ListToArray
; Description ...: Get names of files/folders into defined remote directory.
; Syntax.........: _SFTP_ListToArray ( $hConnection [, $sRemoteDir = "" [, $ReturnType = 0]] )
; Parameters ....: $hConnection - as returned by _SFTP_Connect().
;                  $sRemoteDir - Optional, The remote Directory (or use current remote Directory if not defined).
;                  $ReturnType - Optional, 0 = Both Files and Folders (default), 1 = Folders, 2 = Files.
; Return values .: Success - returns an Array containing the names. Array[0] contain the number of found entries.
;                  Failure - Array[0] = 0, sets @error
;                  |1 - The connection is closed
;                  |2 - Remote directory not found
;                  |3 - Error splitting the list of files
;                  |4 - Wrong ReturnType value
;                  |5 - Other error
; Author ........: Lupo73, TCR
; Modified.......:
; Remarks .......:
; Related .......: _SFTP_Connect
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SFTP_ListToArray($hConnection, $sRemoteDir = "", $ReturnType = 0)
    Local $aArray[1] = [0]
    If ProcessExists($hConnection) = 0 Then
        Return SetError(1, 0, $aArray)
    EndIf
    If $ReturnType < 0 Or $ReturnType > 2 Then
        Return SetError(4, 0, $aArray)
    EndIf

    Local $sLine, $aStringSplit, $aSubStringSplit
    If $sRemoteDir <> "" Then
        $sRemoteDir = ' "' & $sRemoteDir & '"'
    EndIf
    StdinWrite($hConnection, 'ls' & $sRemoteDir & @CRLF)
    While 1
        $sLine &= StdoutRead($hConnection)
        If ProcessExists($hConnection) = 0 Then
            Return SetError(1, 0, $aArray)
        ElseIf StringInStr($sLine, "Unable to open") Then
            Return SetError(2, 0, $aArray)
        ElseIf StringInStr($sLine, "Multiple-level wildcards") Or StringInStr($sLine, ": canonify: ") Then
            Return SetError(5, 0, $aArray)
        ElseIf StringInStr($sLine, "psftp>") Then
            ExitLoop
        EndIf
        Sleep(10)
    WEnd

    $aStringSplit = StringSplit(StringStripCR($sLine), @LF)
    If IsArray($aStringSplit) = 0 Then
        Return SetError(3, 0, $aArray)
    EndIf
    ReDim $aArray[$aStringSplit[0] + 1]

    For $A = 1 To $aStringSplit[0]
        If ($ReturnType = 1 And StringLeft($aStringSplit[$A], 1) <> "d") Or ($ReturnType = 2 And StringLeft($aStringSplit[$A], 1) <> "-") Then
            ContinueLoop
        EndIf
        $aSubStringSplit = _StringExplode(StringStripWS($aStringSplit[$A], 7), " ", 8)
        If UBound($aSubStringSplit) < 9 Then
            ContinueLoop
        EndIf
        $aArray[0] += 1
        $aArray[$aArray[0]] = $aSubStringSplit[8]
    Next
    ReDim $aArray[$aArray[0] + 1]

    Return $aArray
EndFunc   ;==>_SFTP_ListToArray

; #FUNCTION# ====================================================================================================================
; Name...........: _SFTP_ListToArrayEx
; Description ...: Get names, sizes, attributes and times of files/folders into defined remote directory.
; Syntax.........: _SFTP_ListToArrayEx ( $hConnection [, $sRemoteDir = "" [, $ReturnType = 0 [, $fTimeFormat = 1]]] )
; Parameters ....: $hConnection - as returned by _SFTP_Connect().
;                  $sRemoteDir - Optional, The remote Directory (or use current remote Directory if not defined).
;                  $ReturnType - Optional, 0 = Both Files and Folders (default), 1 = Folders, 2 = Files.
;                  $fTimeFormat - Optional, type on the date strings: 1 = YYYY/MM/DD[ HH:MM] (default), 0 = MM/DD/YYYY[ HH:MM].
; Return values .: Success - returns a 2D Array, see remarks.
;                  Failure - Array[0][0] = 0, sets @error
;                  |1 - The connection is closed
;                  |2 - Remote directory not found
;                  |3 - Error splitting the list of files
;                  |4 - Wrong ReturnType value
;                  |5 - Other error
; Author ........: Lupo73, TCR
; Modified.......:
; Remarks .......: Array[0][0] = number of found entries
;                  Array[x][0] Filename
;                  Array[x][1] Filesize
;                  Array[x][2] Permissions
;                  Array[x][3] File Modification datetime
;                  Array[x][4] Owner/Group
; Related .......: _SFTP_Connect
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SFTP_ListToArrayEx($hConnection, $sRemoteDir = "", $ReturnType = 0, $fTimeFormat = 1)
    Local $aArray[1][5]
    $aArray[0][0] = 0
    If ProcessExists($hConnection) = 0 Then
        Return SetError(1, 0, $aArray)
    EndIf
    If $ReturnType < 0 Or $ReturnType > 2 Then
        Return SetError(4, 0, $aArray)
    EndIf

    Local $sLine, $sTime, $aStringSplit, $aSubStringSplit
    If $sRemoteDir <> "" Then
        $sRemoteDir = ' "' & $sRemoteDir & '"'
    EndIf
    StdinWrite($hConnection, 'ls' & $sRemoteDir & @CRLF)
    While 1
        $sLine &= StdoutRead($hConnection)
        If ProcessExists($hConnection) = 0 Then
            Return SetError(1, 0, $aArray)
        ElseIf StringInStr($sLine, "Unable to open") Then
            Return SetError(2, 0, $aArray)
        ElseIf StringInStr($sLine, "Multiple-level wildcards") Or StringInStr($sLine, ": canonify:") Then
            Return SetError(5, 0, $aArray)
        ElseIf StringInStr($sLine, "psftp>") Then
            ExitLoop
        EndIf
        Sleep(10)
    WEnd

    $aStringSplit = StringSplit(StringStripCR($sLine), @LF)
    If IsArray($aStringSplit) = 0 Then
        Return SetError(3, 0, $aArray)
    EndIf
    ReDim $aArray[$aStringSplit[0] + 1][5]

    For $A = 1 To $aStringSplit[0]
        If ($ReturnType = 1 And StringLeft($aStringSplit[$A], 1) <> "d") Or ($ReturnType = 2 And StringLeft($aStringSplit[$A], 1) <> "-") Then
            ContinueLoop
        EndIf
        $aSubStringSplit = _StringExplode(StringStripWS($aStringSplit[$A], 7), " ", 8)
        If UBound($aSubStringSplit) < 9 Then
            ContinueLoop
        EndIf
        $aArray[0][0] += 1
        $aArray[$aArray[0][0]][0] = $aSubStringSplit[8]
        $aArray[$aArray[0][0]][1] = 0
        If StringLeft($aSubStringSplit[0], 1) <> "d" Then ; Is A File.
            $aArray[$aArray[0][0]][1] = $aSubStringSplit[4]
        EndIf
        $aArray[$aArray[0][0]][2] = $aSubStringSplit[0]
        $sTime = ""
        $aSubStringSplit[6] = StringRight("0" & $aSubStringSplit[6], 2)
        If StringInStr($aSubStringSplit[7], ":") Then ; Is A Time.
            $sTime = " " & $aSubStringSplit[7]
            $aSubStringSplit[7] = @YEAR
            If _DateDiff('n', $aSubStringSplit[7] & "/" & __MonthToNumber($aSubStringSplit[5]) & "/" & $aSubStringSplit[6] & $sTime, _NowCalc()) < 0 Then
                $aSubStringSplit[7] -= 1
            EndIf
        EndIf
        If $fTimeFormat = 1 Then
            $aArray[$aArray[0][0]][3] = $aSubStringSplit[7] & "/" & __MonthToNumber($aSubStringSplit[5]) & "/" & $aSubStringSplit[6] & $sTime
        Else
            $aArray[$aArray[0][0]][3] = __MonthToNumber($aSubStringSplit[5]) & "/" & $aSubStringSplit[6] & "/" & $aSubStringSplit[7] & $sTime
        EndIf
        ; <<<<<<<<<<<<<<<<<<<<<<<<<<< it may needs to update time based on timezone offset
        $aArray[$aArray[0][0]][4] = $aSubStringSplit[2] & " " & $aSubStringSplit[3]
    Next
    ReDim $aArray[$aArray[0][0] + 1][5]

    Return $aArray
EndFunc   ;==>_SFTP_ListToArrayEx

; #FUNCTION# ====================================================================================================================
; Name...........: _SFTP_Open
; Description ...: Opens a SFTP session.
; Syntax.........: _SFTP_Open ( [$sPath = 'psftp.exe'],$sParam )
; Parameters ....: $sPath  - Optional, The local path of the psftp executable i.e. "c:\temp\psftp.exe".
;                  $sParam - Optional, used for PSFTP startup options
; Return values .: Success - Handle to internet session to be used in _SFTP_Connect().
;                  Failure - 0, sets @error
;                  |1 - The connection is closed
;                  |2 - Other error
; Author ........: Lupo73, trainer
; Modified.......: NSC
; Remarks .......: added $sParam, was fixed to "-load null", you can put "-noagent" to force user/psw auth, bypassing  the key request
; Related .......: _SFTP_Connect, _SFTP_Close
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SFTP_Open($sPath = 'psftp.exe', $sParam = "-load null")
    If $sParam <> "" then $sParam = " " & $sParam
    Local $hSession = Run($sPath & " " & $sParam, "", @SW_HIDE, $STDIN_CHILD + $STDOUT_CHILD)
    If @error Then
        Return SetError(1, 0, 0)
    EndIf

    Local $sLine
    While 1
        $sLine = StdoutRead($hSession)
        If ProcessExists($hSession) = 0 Then
            Return SetError(1, 0, 0)
        ElseIf StringInStr($sLine, "psftp>") Then
            ExitLoop
        ElseIf $sLine <> "" Then
            Return SetError(2, 0, 0)
        EndIf
        Sleep(10)
    WEnd

    $__gsLocalDir_SFTP = _SFTP_DirGetCurrentLocal($hSession)

    Return $hSession
EndFunc   ;==>_SFTP_Open

; #FUNCTION# ====================================================================================================================
; Name...........: _SFTP_ProgressDownload
; Description ...: Downloads a file and shows a Progress window or by Calling a User defined Function.
; Syntax.........: _SFTP_ProgressDownload ( $hConnection, $sRemoteFile [, $sLocalFile = "" [, $fFailIfExists = False [, $fRecursiveGet = 1 [, $FunctionToCall = ""]]]] )
; Parameters ....: $hConnection - as returned by _SFTP_Connect().
;                  $sRemoteFile - The remote file.
;                  $sLocalFile - Optional, The local file (or use the source name if not defined).
;                  $fFailIfExists - Optional, True: do not overwrite existing (default = False)
;                  $fRecursiveGet - Optional, Recurse through sub-dirs: 0 = Non recursive, 1 = Recursive (default)
;                  $FunctionToCall - Optional, A function which can update a ProgressBar and react on UserInput like Click on Abort or Close App.
; Return values .: Success - 1
;                  Failure - 0, sets @error
;                  |1 - The connection is closed
;                  |2 - Local folder exists and $fFailIfExists = True
;                  |3 - Remote folder not found
;                  |4 - Download aborted by PercentageFunc and Return of Called Function
;                  |5 - Other error
; Author ........: Lupo73
; Modified.......:
; Remarks .......:
; Related .......: _SFTP_Connect, _SFTP_ProgressUpload, _SFTP_FileGetSize
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SFTP_ProgressDownload($hConnection, $sRemoteFile, $sLocalFile = "", $fFailIfExists = False, $fRecursiveGet = 1, $FunctionToCall = "")
    If ProcessExists($hConnection) = 0 Then
        Return SetError(1, 0, 0)
    EndIf

    If $sLocalFile <> "" Then
        $sLocalFile = __WinAPI_GetFullPathName($sLocalFile)
        If FileExists($sLocalFile) Then
            If $fFailIfExists Then
                Return SetError(2, 0, 0)
            EndIf
        EndIf
        $sLocalFile = ' "' & $sLocalFile & '"'
    EndIf
    If $FunctionToCall = "" Then
        ProgressOn("SFTP Download", "Downloading " & $sRemoteFile)
    EndIf
    Local $iSize = _SFTP_FileGetSize($hConnection, $sRemoteFile) ; <<<<<<<<<<<<<<<<<<<<<< 0 for folders
    Local $sLine, $iInitialBytes, $iReadBytes, $iError, $iPercent
    If $fRecursiveGet Then
        $sLine = '-r '
    EndIf

    StdinWrite($hConnection, 'get ' & $sLine & '-- "' & $sRemoteFile & '"' & $sLocalFile & @CRLF)
    $iReadBytes = ProcessGetStats($hConnection, 1) ; <<<<<<<<<<<<<<<<<<<<<<<< it may needs to load from another stat
;~     $iInitialBytes = $iReadBytes[3]

    While 1
        $sLine = StdoutRead($hConnection)
        If ProcessExists($hConnection) = 0 Then
            $iError = 1
            ExitLoop
        ElseIf StringInStr($sLine, "psftp>") Then
            ExitLoop
        ElseIf StringInStr($sLine, "=> local:") Then
            ContinueLoop
        ElseIf StringInStr($sLine, "no such file or directory") Then
            $iError = 3
            ExitLoop
        ElseIf $sLine <> "" Then
            $iError = 5
            ExitLoop
        EndIf

        $iReadBytes = ProcessGetStats($hConnection, 1)
        $iPercent = Int(($iReadBytes[4] / $iSize) * 100) ;<<< !!!! $iSize = 0 for folders !!!! >>>>

        If $FunctionToCall = "" Then
            ProgressSet($iPercent) ;(($iReadBytes[3] - $iInitialBytes) / $iSize * 100)
        Else
;~          If Call($FunctionToCall, ($iReadBytes[3] - $iInitialBytes) / $iSize * 100) <= 0 Then
            If Call($FunctionToCall, $iPercent) <= 0 Then
                ProcessClose($hConnection)
                $iError = 4
                ExitLoop
            EndIf
        EndIf
        Sleep(10)
    WEnd

    If $FunctionToCall = "" Then
        ProgressOff()
    EndIf

    If $iError Then
        Return SetError($iError, 0, 0)
    EndIf

    Return 1
EndFunc   ;==>_SFTP_ProgressDownload


; #FUNCTION# ====================================================================================================================
; Name...........: _SFTP_ProgressUpload
; Description ...: Uploads a file and shows a Progress window or by Calling a User defined Function.
; Syntax.........: _SFTP_ProgressUpload ( $hConnection, $sLocalFile [, $sRemoteFile = "" [, $fRecursivePut = 1 [, $FunctionToCall = ""]]] )
; Parameters ....: $hConnection - as returned by _SFTP_Connect().
;                  $sLocalFile - The local file.
;                  $sRemoteFile - Optional, The remote file (or use the source name if not defined).
;                  $fRecursivePut - Optional, Recurse through sub-dirs: 0 = Non recursive, 1 = Recursive (default)
;                  $FunctionToCall - Optional, A function which can update a ProgressBar and react on UserInput like Click on Abort or Close App.
; Return values .: Success - 1
;                  Failure - 0, sets @error
;                  |1 - The connection is closed
;                  |2 - Remote folder not found
;                  |3 - Cannot create directory
;                  |4 - Download aborted by PercentageFunc and Return of Called Function
;                  |5 - Other error
; Author ........: Lupo73
; Modified.......:
; Remarks .......:
; Related .......: _SFTP_Connect, _SFTP_ProgressDownload
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SFTP_ProgressUpload($hConnection, $sLocalFile, $sRemoteFile = "", $fRecursivePut = 1, $FunctionToCall = "")
    If ProcessExists($hConnection) = 0 Then
        Return SetError(1, 0, 0)
    EndIf

    If $sRemoteFile <> "" Then
        $sRemoteFile = ' "' & $sRemoteFile & '"'
    EndIf
    If $FunctionToCall = "" Then
        ProgressOn("SFTP Upload", "Uploading " & $sLocalFile)
    EndIf
    Local $iSize
    If StringInStr(FileGetAttrib($sLocalFile), "D") Then
        $iSize = DirGetSize($sLocalFile)
    Else
        $iSize = FileGetSize($sLocalFile)
    EndIf

    Local $sLine, $iInitialBytes, $iReadBytes, $iError
    If $fRecursivePut Then
        $sLine = '-r '
    EndIf
    StdinWrite($hConnection, 'put ' & $sLine & '-- "' & $sLocalFile & '"' & $sRemoteFile & @CRLF)
    $iReadBytes = ProcessGetStats($hConnection, 1)
    $iInitialBytes = $iReadBytes[3]
    While 1
        $sLine = StdoutRead($hConnection)
        If ProcessExists($hConnection) = 0 Then
            $iError = 1
            ExitLoop
        ElseIf StringInStr($sLine, "psftp>") Then
            ExitLoop
        ElseIf StringInStr($sLine, "=> remote:") Then
            ContinueLoop
        ElseIf StringInStr($sLine, "unable to open") Then
            $iError = 2
            ExitLoop
        ElseIf StringInStr($sLine, "Cannot create directory") Then
            $iError = 3
            ExitLoop
        ElseIf $sLine <> "" Then
            $iError = 5
            ExitLoop
        EndIf

        $iReadBytes = ProcessGetStats($hConnection, 1)
        If $FunctionToCall = "" Then
            ProgressSet(($iReadBytes[3] - $iInitialBytes) / $iSize * 100)
        Else
            If Call($FunctionToCall, ($iReadBytes[3] - $iInitialBytes) / $iSize * 100) <= 0 Then
                ProcessClose($hConnection)
                $iError = 4
                ExitLoop
            EndIf
        EndIf
        Sleep(10)
    WEnd

    If $FunctionToCall = "" Then
        ProgressOff()
    EndIf

    If $iError Then
        Return SetError($iError, 0, 0)
    EndIf
    Return 1
EndFunc   ;==>_SFTP_ProgressUpload

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __MonthToNumber
; Description ...: Converts the name of the Month into the month number.
; Syntax.........: __MonthToNumber ( $sMonth )
; Parameters ....:
; Return values .:
; Author ........:
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __MonthToNumber($sMonth)
    Switch $sMonth
        Case 'Jan'
            $sMonth = '01'
        Case 'Feb'
            $sMonth = '02'
        Case 'Mar'
            $sMonth = '03'
        Case 'Apr'
            $sMonth = '04'
        Case 'May'
            $sMonth = '05'
        Case 'Jun'
            $sMonth = '06'
        Case 'Jul'
            $sMonth = '07'
        Case 'Aug'
            $sMonth = '08'
        Case 'Sep'
            $sMonth = '09'
        Case 'Oct'
            $sMonth = '10'
        Case 'Nov'
            $sMonth = '11'
        Case 'Dec'
            $sMonth = '12'
        Case Else
            Return SetError(1, 0, "00")
    EndSwitch
    Return $sMonth
EndFunc   ;==>__MonthToNumber

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __WinAPI_GetFullPathName
; Description....: Retrieves the full path and file name of the specified file.
; Syntax.........: __WinAPI_GetFullPathName ( $sFile )
; Parameters.....: $sFile   - The name of the file.
; Return values..: Success  - The drive and path.
;                  Failure  - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied (WinAPIEx.au3)
; Modified.......:
; Remarks........: The _WinAPI_GetFullPathName() merges the name of the current drive and directory with a specified file name to
;                  determine the full path and file name of a specified file. This function does not verify that the resulting
;                  path and file name are valid, or that they see an existing file on the associated volume.
; Related........:
; Link...........: @@MsdnLink@@ GetFullPathName
; Example........: Yes
; ===============================================================================================================================
Func __WinAPI_GetFullPathName($sFile)

    Local $Ret = DllCall('kernel32.dll', 'dword', 'GetFullPathNameW', 'wstr', $sFile, 'dword', 4096, 'wstr', '', 'ptr', 0)

    If (@error) Or (Not $Ret[0]) Then
        Return SetError(1, 0, '')
    EndIf
    Return $Ret[3]
EndFunc   ;==>__WinAPI_GetFullPathName