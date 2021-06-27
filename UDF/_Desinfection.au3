#cs

Copyright 2019-2020 Bastien Rouches

This file is part of "Boîte A Outils"

    Boîte A Outils is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Boîte A Outils is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Boîte A Outils.  If not, see <https://www.gnu.org/licenses/>.
#ce

Func _ListeProgrammes()

	Local $act_key, $act_name, $system_component
	Local $count, $tab = 1, $all_keys[0]

	Local $keys[2]
	$keys[0] = "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
	$keys[1] = "HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall"

	If(@OSArch = "X64") Then
		ReDim $keys[4]
		$keys[2] = "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
		$keys[3] = "HKLM64\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
	EndIf

	For $key in $keys
		$count = 1
		While 1
			$act_key = RegEnumKey ($key, $count)
			;MsgBox(0,"",$key & "\" & $act_key)

			If @error <> 0 then ExitLoop
			$act_name = RegRead ($key & "\" & $act_key, "DisplayName")
			$system_component = RegRead ($key & "\" & $act_key, "SystemComponent")
			$act_name = StringReplace ($act_name, " (remove only)", "")
			;MsgBox(0,"",$act_name)
			If $act_name <> "" And $system_component <> "1" Then
				ReDim $all_keys[$tab]
				$all_keys[$tab-1] = $act_name
				$tab = $tab + 1
			EndIf
			$count = $count + 1
		WEnd

	Next
	$all_keys = _ArrayUnique($all_keys, 0, 0, 0, 0)
	_ArraySort($all_keys)
	Return $all_keys

EndFunc

Func _Nettoyage()

	_ChangerEtatBouton($iIDAction, "Patienter")
	Local $eGet, $t = 0, $sProgDes
	Local $hGUImaj = GUICreate("Réglages des paramètres de nettoyage", 400, 130)

	Local $iIDPrivazer = GUICtrlCreateCheckbox("Nettoyer avec Privazer", 10, 10)
	Local $iIDUninstall = GUICtrlCreateCheckbox("Désinstaller les logiciels manuellement", 10, 30)
	Local $iIDdldes = GUICtrlCreateCheckbox("Télécharger les logiciels pour la désinfection", 10, 50)
	Local $iIDFreesp = GUICtrlCreateCheckbox("Compresser WinSXS (si espace disque faible)", 10, 70)

	GUICtrlSetState($iIDPrivazer, $GUI_CHECKED)
	GUICtrlSetState($iIDUninstall, $GUI_CHECKED)
	GUICtrlSetState($iIDdldes, $GUI_CHECKED)


	If @OSVersion = "WIN_7" Or @OSVersion = "WIN_VISTA" Or @OSVersion = "WIN_XP" Then
		GUICtrlSetState($iIDFreesp, $GUI_DISABLE)
	EndIf

	Local $iIDButtonDemarrer = GUICtrlCreateButton("Démarrer", 100, 100, 90, 25, $BS_DEFPUSHBUTTON)
	Local $iIDButtonAnnuler = GUICtrlCreateButton("Annuler", 210, 100, 90, 25)


	GUISetState(@SW_SHOW)
	$eGet = GUIGetMsg()


	While $eGet <> $GUI_EVENT_CLOSE And $eGet <> $iIDButtonAnnuler And $eGet <> $iIDButtonDemarrer
		$eGet = GUIGetMsg()
	WEnd

	If($eGet = $iIDButtonDemarrer) Then

		If _FichierCacheExist("Desinfection") = 0 Then
			_FichierCache("Desinfection", $iIDAction)
			FileWriteLine($hFichierRapport, "Nettoyage de l'ordinateur")
		EndIf

		If GUICtrlRead($iIDPrivazer) = $GUI_CHECKED Then
			$iIDPrivazer = 1
		Else
			$iIDPrivazer = 0
		EndIf

		If GUICtrlRead($iIDUninstall) = $GUI_CHECKED Then
			$iIDUninstall = 1
		Else
			$iIDUninstall = 0
		EndIf

		If GUICtrlRead($iIDdldes) = $GUI_CHECKED Then
			$iIDdldes = 1
		Else
			$iIDdldes = 0
		EndIf

		If GUICtrlRead($iIDFreesp) = $GUI_CHECKED Then
			$iIDFreesp = 1
		Else
			$iIDFreesp = 0
		EndIf

		GUIDelete()

		Local $iPIDclean, $iPIDdes
		$iFreeSpace = DriveSpaceFree(@HomeDrive & "\") / 1024

		If $iIDFreesp = 0 And $iIDdldes = 0 And $iIDUninstall = 0 And $iIDPrivazer = 0 Then
			$iPIDclean = Run(@ComSpec & ' /C cleanmgr.exe /LOWDISK /D ' & @HomeDrive, "", @SW_HIDE)
		Else
			If $iIDPrivazer = 1 Then
				If MapExists($aMenu, "Privazer") Then
					If(_Telecharger("Privazer", ($aMenu["Privazer"])[2])) Then
						$iPIDclean = _Executer("Privazer")
					EndIf
				Else
					_Attention("Privazer n'existe pas dans les liens")
				EndIf
			EndIf

			If $iIDUninstall = 1 Then

				If($sNomDesinstalleur <> "") Then
					If MapExists($aMenu, $sNomDesinstalleur) Then
						If(_Telecharger($sNomDesinstalleur, ($aMenu[$sNomDesinstalleur])[2])) Then
							$iPIDdes = _Executer($sNomDesinstalleur)
						EndIf
					Else
						_Attention($sNomDesinstalleur & " n'existe pas dans les liens")
					EndIf
				Else
					$iPIDdes = ShellExecute("appwiz.cpl")
				EndIf
			EndIf

			if $iIDFreesp = 1 Then
				RunWait(@ComSpec & ' /C Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase')
				RunWait(@ComSpec & ' /C sc stop msiserver & sc stop TrustedInstaller & sc config msiserver start= disabled & sc config TrustedInstaller start= disabled & icacls "%WINDIR%\WinSxS" /save "%WINDIR%\WinSxS_NTFS.acl" /t & takeown /f "%WINDIR%\WinSxS" /r & icacls "%WINDIR%\WinSxS" /grant "%USERDOMAIN%\%USERNAME%":(F) /t & compact /s:"%WINDIR%\WinSxS" /c /a /i * & icacls "%WINDIR%\WinSxS" /setowner "NT SERVICE\TrustedInstaller" /t & icacls "%WINDIR%" /restore "%WINDIR%\WinSxS_NTFS.acl" & sc config msiserver start= demand & sc config TrustedInstaller start= demand')
			EndIf

			If $iIDdldes = 1 Then
				; Téléchargement des programmes de désinfection en arrière plan
				Local $sPd
				For $sPd In $aButtonDes
					If MapExists($aMenu, $sPd) Then
						_Telecharger($sPd, ($aMenu[$sPd])[2])
					EndIf
				Next
			EndIf

			ProcessWaitClose($iPIDdes)
			Local $aListeApSupp = _ListeProgrammes()

			For $sProgAvSupp in $aListeAvSupp
				If _ArraySearch($aListeApSupp, $sProgAvSupp) = -1 Then
					$t = $t + 1
					$sProgDes &= " - " & $sProgAvSupp & @CRLF
				EndIf
			Next
			If $t > 0 Then
				FileWriteLine($hFichierRapport, " " & $t & " programme(s) désinstallé(s) : ")
				FileWrite($hFichierRapport, $sProgDes)
				FileWriteLine($hFichierRapport, "")
			EndIf

			ProcessWaitClose($iPIDclean)

			$iFreeSpace = Round((DriveSpaceFree(@HomeDrive & "\") / 1024) - $iFreeSpace, 2)

			If($iFreeSpace > 1) Then
				FileWriteLine($hFichierRapport, " Espace libéré : " & $iFreeSpace & " Go")
				FileWriteLine($hFichierRapport, "")
			EndIf

			_UpdEdit($iIDEditRapport, $hFichierRapport)

			_ChangerEtatBouton($iIDAction, "Activer")
		EndIf
	Else
		GUIDelete()
		_ChangerEtatBouton($iIDAction, "Desactiver")

	EndIf

EndFunc

Func _NettoyageProg($aButtonDes)
	Local $sNomProgDes = $aButtonDes[$iIDAction]
	Local $iPidret

	If IsString($sNomProgDes) And MapExists($aMenu, $sNomProgDes) Then
		_ChangerEtatBouton($iIDAction, "Patienter")
		If(_Telecharger($sNomProgDes, ($aMenu[$sNomProgDes])[2])) Then
			$iPidret = _Executer($sNomProgDes)
			If $iPidret = 0 Then
				_ChangerEtatBouton($iIDAction, "Desactiver")
			ElseIf(_FichierCacheExist($sNomProgDes) = 0) Then
				$iPidt[$sNomProgDes & "n"] = $iPidret
				FileWriteLine($hFichierRapport, " Exécution de " & $sNomProgDes)
				_UpdEdit($iIDEditRapport, $hFichierRapport)
				_FichierCache($sNomProgDes, $iIDAction)
				_ChangerEtatBouton($iIDAction, "Activer")
			Else
				_ChangerEtatBouton($iIDAction, "Activer")
			EndIf

		EndIf
	ElseIf(FileExists($sScriptDir & "\Cache\Download\" & $aButtonDes[$iIDAction + 1] & ".bat")) Then
		RunWait(@ComSpec & ' /c "' & $aButtonDes[$iIDAction + 1] & '.bat uninstall"', $sScriptDir & "\Cache\Download\", @SW_HIDE)
		FileDelete($sScriptDir & "\Cache\Download\" & $aButtonDes[$iIDAction + 1] & ".bat")
	Else
		If FileExists($sScriptDir & "\Outils\" & $aButtonDes[$iIDAction + 1] & "\" & $aButtonDes[$iIDAction + 1] & ".bat") = 0 Then
			_Attention($sNomProgDes & " n'existe pas dans les liens")
		Else
			_Attention('Ce bouton sert à désinstaller "' & $aButtonDes[$iIDAction + 1] & '" après un redémarrage de l' & "'" & 'ordinateur ou un arrêt intempestif de bao')
		EndIf
	EndIf
EndFunc

Func _ResetBrowser()
	_FichierCache("ResetBrowser", $iIDAction)
	_ChangerEtatBouton($iIDAction, "Patienter")
;~ 	If(FileExists($sScriptDir & "\Outils\ResetBrowser.exe")) Then
;~ 			FileWriteLine($hFichierRapport, " Nettoyage des navigateurs Internet")
;~ 			Run($sScriptDir & "\Outils\ResetBrowser.exe")
;~ 			_UpdEdit($iIDEditRapport, $hFichierRapport)
;~ 	Else
;~ 		_Attention("ResetBrowser.exe n'est pas dans le dossier Outils, Téléchagez le")
;~ 		ShellExecute("https://www.comment-supprimer.com/telecharger/resetbrowser/")
;~ 	EndIf
	; Nettoyage des navigateurs

	_BrowserClose()

	GUICtrlSetData($statusbar, " Nettoyage d'Internet Explorer")
	RunWait("RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255")
	FileWriteLine($hFichierRapport, "  Internet Explorer nettoyé")

	If (FileExists(@LocalAppDataDir & "\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\")) Then
		GUICtrlSetData($statusbar, " Nettoyage de Microsoft Edge")

		Local $aEdge = _FileListToArray(@LocalAppDataDir & "\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC", "#!*", 2)

		If(IsArray($aEdge)) Then
			For $i = 1 To $aEdge[0]
				DirRemove(@LocalAppDataDir & "\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\" & $aEdge[$i], 1)
			Next
		EndIf

		FileWriteLine($hFichierRapport, "  Microsoft Edge nettoyé")
	EndIf

	If (FileExists(@LocalAppDataDir & "\Google\Chrome\User Data\Default\")) Then
		GUICtrlSetData($statusbar, " Nettoyage de Google Chrome")

		DirRemove(@LocalAppDataDir & "\Google\Chrome\User Data\Default\Cache\", 1)
		FileDelete(@LocalAppDataDir & "\Google\Chrome\User Data\Default\*History*")

		ShellExecuteWait("chrome", '--profile-directory="Default" chrome://settings/resetProfileSettings')

		Local $aProfils = _FileListToArrayRec(@LocalAppDataDir & "\Google\Chrome\User Data\", "Profile *")
		If $aProfils <> "" Then
			For $i=1 To $aProfils[0]
				DirRemove(@LocalAppDataDir & "\Google\Chrome\User Data\" & $aProfils[$i] & "Cache\", 1)
				FileDelete(@LocalAppDataDir & "\Google\Chrome\User Data\" & $aProfils[$i] & "*History*")
				ShellExecuteWait("chrome", '--profile-directory="'& StringTrimRight($aProfils[$i], 1) &'" chrome://settings/resetProfileSettings')
			Next
		EndIf

		FileWriteLine($hFichierRapport, "  Google Chrome nettoyé")
	EndIf


	If (FileExists(@LocalAppDataDir & "\Mozilla\Firefox\Profiles\")) Then
		GUICtrlSetData($statusbar, " Nettoyage de Mozilla Firefox")

		Local $aProfil = _FileListToArray(@LocalAppDataDir & "\Mozilla\Firefox\Profiles", "*", 2)
		If DirRemove(@LocalAppDataDir & "\Mozilla\Firefox\Profiles\", 1) = 0 Then
			_Attention('Le dossier "' & @LocalAppDataDir & "\Mozilla\Firefox\Profiles\" & '" n''a pas pu être supprimé')
		EndIf
		For $i = 1 To $aProfil[0]
			If FileExists(@AppDataDir & "\Mozilla\Firefox\Profiles\" & $aProfil[$i] & "\") Then
				; fichiers à supprimer
				;FileDelete(@AppDataDir & "\Mozilla\Firefox\Profiles\" & $aProfil[$i] & "\places.sqlite")
			EndIf
		Next

		ShellExecuteWait("firefox", '-safe-mode')
		ProcessWaitClose("firefox.exe")
		FileWriteLine($hFichierRapport, "  Mozilla Firefox nettoyé")
	EndIf

	FileWriteLine($hFichierRapport, "")
	GUICtrlSetData($statusbar, "")
	_UpdEdit($iIDEditRapport, $hFichierRapport)
	_ChangerEtatBouton($iIDAction, "Activer")
EndFunc

Func _BrowserClose()
    Local $aList = 0
    Local $aProcesses = StringSplit('iexplore.exe|chrome.exe|firefox.exe|MicrosoftEdge.exe', '|', $STR_NOCOUNT) ; Multiple processes
    For $i = 0 To UBound($aProcesses) - 1
        $aList = ProcessList($aProcesses[$i])
        If $aList[0][0] > 0 Then ; An array is returned and @error is NEVER set, so lets check the count.
;~         _ArrayDisplay($aList)
            Local $bIsProcessClosed = False ; Declare a variable to hold a boolean.
            For $j = 1 To $aList[0][0]
                $bIsProcessClosed = ProcessClose($aList[$j][1]) ; In AutoIt 0 or 1 can be considered boolean too. It's like a bit in SQL or in C, where 1 and 0 means true or false.
                If Not $bIsProcessClosed Then ConsoleWrite('CLOSE ERROR PID: ' & $aList[$j][1] & @CRLF)
            Next
        EndIf
    Next
EndFunc   ;==>_BrowserClose