#cs

Copyright 2019 Bastien Rouches

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

Func _EnvoiFTP($sFTPAdresse, $sFTPUser, $sFTPPort, $sFichier, $sDossier, $bRemove = 0)

	Local $bRetour = 0

	If($sFTPAdresse <> "" And $sFTPUser <> "" And $sDossier <> "") Then
		Local $sMdp, $bSVGMdp = 0, $iIdFTP

		If(FileExists(@ScriptDir & '\Cache\Pwd\ftp.sha')) Then
			$sMdp = BinaryToString(_Crypt_DecryptData(FileReadLine(@ScriptDir & '\Cache\Pwd\ftp.sha'), $sFTPUser, $CALG_AES_256))
		Else
			Local $hGUIFTP = GUICreate("Envoi sur FTP/SFTP", 400, 105)
			GUICtrlCreateLabel('Saisissez le mot de passe FTP/SFTP (' & $sFTPUser & '@' & $sFTPAdresse & ') :',10, 15)
			Local $iPWD = GUICtrlCreateInput("", 10, 42, 200, 20, $ES_PASSWORD)
			Local $iMem = GUICtrlCreateCheckbox("Mémoriser le mot de passe ?", 220, 40)

			Local $iIDValider = GUICtrlCreateButton("Valider", 125, 70, 150, 25, $BS_DEFPUSHBUTTON)
			GUISetState(@SW_SHOW)

			While 1
				$iIdFTP = GUIGetMsg()
				Switch $iIdFTP

					Case $GUI_EVENT_CLOSE
						ExitLoop

					Case $iIDValider
						If(GUICtrlRead($iPWD) <> "") Then
							$sMdp = GUICtrlRead($iPWD)
						EndIf

						If GUICtrlRead($iMem) = $GUI_CHECKED Then
							$bSVGMdp = 1
						EndIf
						ExitLoop
				EndSwitch
			WEnd

			GUIDelete()

		EndIf


		If $sMdp <> "" Then
			GUICtrlSetData($statusbar, " Envoi FTP/SFTP")
			GUICtrlSetData($statusbarprogress, 20)

			; Ajout de BAO dans le pare-feu Windows
			RunWait(@ComSpec & " /c " & 'netsh advfirewall firewall delete rule name = "BAO" dir = in', "", @SW_HIDE)
			RunWait(@ComSpec & " /c " & 'netsh advfirewall firewall add rule name = "BAO" dir = in action = allow program = "' & @AutoItExe & '" enable = yes', "", @SW_HIDE)

			GUICtrlSetData($statusbarprogress, 35)

			Local $sFTP_Message, $hOpen, $Err, $hConn

			if $sFTPProtocol = "sftp" then
				$hOpen = _SFTP_Open(@ScriptDir & '\Outils\psftp.exe','-noagent')
			Else
				$hOpen = _FTP_Open('FTP')
			EndIf

			GUICtrlSetData($statusbarprogress, 50)

			_FileWriteLog($hLog, 'Connexion au serveur FTP/SFTP')
			_UpdEdit($iIDEditLog, $hLog)

			if $sFTPProtocol = "sftp" then
				$hConn = _SFTP_Connect($hOpen, $sFTPAdresse, $sFTPUser, $sMdp, $sFTPPort)
				If @error Then
	;				|1 - The session is closed
	;               |2 - Access denied
	;               |3 - Other error
	;               |4 - timeout error on user login     ; NSC modified
	;               |5 - timeout error on password login ; NSC modified
					Switch @error
						Case 1
							$sFTP_Message = "Session terminée"
						Case 2
							$sFTP_Message = "Accés refusé"
						Case 3
							$sFTP_Message = "Autre erreur"
						Case 4
							$sFTP_Message = "Timeout sur login"
						Case 5
							$sFTP_Message = "Timeout sur mot de passe"
					EndSwitch
					_Attention('Connexion impossible au serveur FTP/SFTP : ' & @CRLF & @CRLF & $sFTP_Message)
					_FileWriteLog($hLog, 'Erreur : ' & $sFTP_Message)
					$bRetour = -1
				Else
					$bRetour = 1

					If($bSVGMdp = 1) Then
						_Crypter("ftp", $sMdp, $sFTPUser)
					EndIf

					GUICtrlSetData($statusbarprogress, 75)

					If($bRemove = 1) Then
						_SFTP_FileDelete($hConn, $sDossier)
					Else
						;If(StringRight($sFichier, 3) = "txt" Or StringRight($sFichier, 3) = "pax" Or StringRight($sFichier, 3) = "php") Then
						;	_SFTP_FilePut($hConn, $sFichier, $sDossier, $INTERNET_FLAG_TRANSFER_ASCII)
						;Else
							_SFTP_FilePut($hConn, $sFichier, $sDossier)
						;EndIf
					EndIf
					GUICtrlSetData($statusbarprogress, 100)
				EndIf
				;_SFTP_Close($hConn)
				_SFTP_Close($hOpen)
			Else
				$hConn = _FTP_Connect($hOpen, $sFTPAdresse, $sFTPUser, $sMdp, 0, $sFTPPort)
				If @error Then
					_FTP_GetLastResponseInfo($Err, $sFTP_Message)
					_Attention('Connexion impossible au serveur FTP : ' & @CRLF & @CRLF & $sFTP_Message)
					$bRetour = -1
				Else
					$bRetour = 1

					If($bSVGMdp = 1) Then
						_Crypter("ftp", $sMdp, $sFTPUser)
					EndIf

					GUICtrlSetData($statusbarprogress, 75)

					If($bRemove = 1) Then
						_FTP_FileDelete($hConn, $sDossier)
					Else
						If(StringRight($sFichier, 3) = "txt" Or StringRight($sFichier, 3) = "php") Then
							_FTP_FilePut($hConn, $sFichier, $sDossier, $INTERNET_FLAG_TRANSFER_ASCII)
						Else
							_FTP_FilePut($hConn, $sFichier, $sDossier)
						EndIf
					EndIf
					GUICtrlSetData($statusbarprogress, 100)
				EndIf
				_FTP_Close($hConn)
				_FTP_Close($hOpen)
			EndIf

			GUICtrlSetData($statusbar, "")
			GUICtrlSetData($statusbarprogress, 0)

		EndIf
	EndIf
	Return $bRetour
EndFunc

Func _RecupFTP($sFTPAdresse, $sFTPUser, $sFTPPort, $sFTPDossier)

	Local $bRetour = 0

	If($sFTPAdresse <> "" And $sFTPUser <> "" And $sFTPDossier <> "") Then

		If(_FichierCacheExist("FTPRecup") = 0) Then
			_FichierCache("FTPRecup", 1)
		EndIf

		If(_FichierCache("FTPRecup") <> _NowDate()) Then

			$sSplashTxt = $sSplashTxt & @LF & "Récupération des rapports sur le FTP/SFTP"
			ControlSetText("Initialisation de BAO", "", "Static1", $sSplashTxt)

			Local $sMdp, $bSVGMdp = 0, $iIdFTP

			If(FileExists(@ScriptDir & '\Cache\Pwd\ftp.sha')) Then
				$sMdp = BinaryToString(_Crypt_DecryptData(FileReadLine(@ScriptDir & '\Cache\Pwd\ftp.sha'), $sFTPUser, $CALG_AES_256))
			Else
				Local $hGUIFTP = GUICreate("Récupération FTP/SFTP", 400, 105)
				GUICtrlCreateLabel('Saisissez le mot de passe FTP/SFTP (' & $sFTPUser & '@' & $sFTPAdresse & ') :',10, 15)
				Local $iPWD = GUICtrlCreateInput("", 10, 42, 200, 20, $ES_PASSWORD)
				Local $iMem = GUICtrlCreateCheckbox("Mémoriser le mot de passe ?", 220, 40)

				Local $iIDValider = GUICtrlCreateButton("Valider", 125, 70, 150, 25, $BS_DEFPUSHBUTTON)
				GUISetState(@SW_SHOW)

				While 1
					$iIdFTP = GUIGetMsg()
					Switch $iIdFTP

						Case $GUI_EVENT_CLOSE
							ExitLoop

						Case $iIDValider
							If(GUICtrlRead($iPWD) <> "") Then
								$sMdp = GUICtrlRead($iPWD)
							EndIf

							If GUICtrlRead($iMem) = $GUI_CHECKED Then
								$bSVGMdp = 1
							EndIf
							ExitLoop
					EndSwitch
				WEnd

				GUIDelete()

			EndIf


			If $sMdp <> "" Then

				; Ajout de BAO dans le pare-feu Windows
				RunWait(@ComSpec & " /c " & 'netsh advfirewall firewall delete rule name = "BAO" dir = in', "", @SW_HIDE)
				RunWait(@ComSpec & " /c " & 'netsh advfirewall firewall add rule name = "BAO" dir = in action = allow program = "' & @AutoItExe & '" enable = yes', "", @SW_HIDE)

				Local $sFTP_Message, $hOpen, $Err, $hConn, $hOpen, $hConn

				if $sFTPProtocol = "sftp" then
					$hOpen = _SFTP_Open(@ScriptDir & '\Outils\psftp.exe','-noagent')
					$hConn = _SFTP_Connect($hOpen, $sFTPAdresse, $sFTPUser, $sMdp, $sFTPPort)

					If @error Then
		;				|1 - The session is closed
		;               |2 - Access denied
		;               |3 - Other error
		;               |4 - timeout error on user login     ; NSC modified
		;               |5 - timeout error on password login ; NSC modified
						Switch @error
							Case 1
								$sFTP_Message = "Session terminée"
							Case 2
								$sFTP_Message = "Accés refusé"
							Case 3
								$sFTP_Message = "Autre erreur"
							Case 4
								$sFTP_Message = "Timeout sur login"
							Case 5
								$sFTP_Message = "Timeout sur mot de passe"
						EndSwitch
						_Attention('Connexion impossible au serveur FTP/SFTP : ' & @CRLF & @CRLF & $sFTP_Message)
						_FileWriteLog($hLog, 'Erreur : ' & $sFTP_Message)
						$bRetour = -1
					Else
						$bRetour = 1

						If($bSVGMdp = 1) Then
							_Crypter("ftp", $sMdp, $sFTPUser)
						EndIf

						_SFTP_DirSetCurrent($hConn, $sFTPDossier)
						If @error Then
							_FileWriteLog($hLog, 'Erreur de récupération des fichiers sur le FTP: ' & @error)
						Else

							Local $sDocY, $sDocM
							Local $aFile = _SFTP_ListToArray($hConn, "", 2)

							If($aFile[0] <> 0) Then

								$sSplashTxt = $sSplashTxt & @LF & "  " & $aFile[0] & " rapport(s) à récupérer"
								ControlSetText("Initialisation de BAO", "", "Static1", $sSplashTxt)
								_ArrayDelete($aFile, 0)
								Sleep(2000)

								For $sFTPFile in $aFile
									$sDocY = StringLeft($sFTPFile, 4)
									$sDocM = StringMid($sFTPFile, 5, 2)
									If DirCreate(@ScriptDir & "\Rapports\" & $sDocY & "-" & $sDocM) = 0 Then
										_Attention("Impossible de créer le dossier '" & @ScriptDir & "\Rapports\" & $sDocY & "-" & $sDocM & "'")
									Else
										If _SFTP_FileGet($hConn, $sFTPFile, @ScriptDir & "\Rapports\" & $sDocY & "-" & $sDocM & "\" & $sFTPFile) = 1 Then
											_FileWriteLog($hLog, 'Recupération de "' & $sFTPFile & '": OK')
											_SFTP_FileDelete($hConn, $sFTPFile)
										Else
											_FileWriteLog($hLog, 'Recupération de "' & $sFTPFile & '": Echec')
											_Attention("Impossible de récupérer '" & $sFTPFile & "' sur le FTP/SFTP")
										EndIf
									EndIf
								Next
							EndIf

							_FichierCache("FTPRecup", _NowDate())
						EndIf
					EndIf

					;_SFTP_Close($hConn)
					_SFTP_Close($hOpen)
				Else
					$hOpen = _FTP_Open('FTP')
					$hConn = _FTP_Connect($hOpen, $sFTPAdresse, $sFTPUser, $sMdp, 0, $sFTPPort)

					If @error Then
						Local $Err, $sFTP_Message
						_FTP_GetLastResponseInfo($Err, $sFTP_Message)
						_Attention('Connexion impossible au serveur FTP : ' & @CRLF & @CRLF & $sFTP_Message)
						$bRetour = -1
					Else
						$bRetour = 1

						If($bSVGMdp = 1) Then
							_Crypter("ftp", $sMdp, $sFTPUser)
						EndIf

						_FTP_DirSetCurrent($hConn, $sFTPDossier)

						Local $sDocY, $sDocM
						Local $aFile = _FTP_ListToArray($hConn, 2)

						If($aFile[0] <> 0) Then

							$sSplashTxt = $sSplashTxt & @LF & "  " & $aFile[0] & " rapport(s) à récupérer"
							SplashTextOn("", $sSplashTxt, $iSplashWidth, $iSplashHeigh, $iSplashX, $iSplashY, $iSplashOpt, "", $iSplashFontSize)
							_ArrayDelete($aFile, 0)

							For $sFTPFile in $aFile
								$sDocY = StringLeft($sFTPFile, 4)
								$sDocM = StringMid($sFTPFile, 5, 2)
								If DirCreate(@ScriptDir & "\Rapports\" & $sDocY & "-" & $sDocM) = 0 Then
									_Attention("Impossible de créer le dossier '" & @ScriptDir & "\Rapports\" & $sDocY & "-" & $sDocM & "'")
								Else
									If _FTP_FileGet($hConn, $sFTPFile, @ScriptDir & "\Rapports\" & $sDocY & "-" & $sDocM & "\" & $sFTPFile) = 1 Then
										_FTP_FileDelete($hConn, $sFTPFile)
									Else
										_Attention("Impossible de récupérer '" & $sFTPFile & "' sur le FTP")
									EndIf
								EndIf
							Next
						EndIf

						_FichierCache("FTPRecup", _NowDate())
					EndIf

					_FTP_Close($hConn)
					_FTP_Close($hOpen)
				EndIf
			EndIf
		EndIf
	EndIf

	Return $bRetour

EndFunc
