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

Func _CompleterRapport()
	_ChangerEtatBouton($iIDAction, "Patienter")

	FileClose($hFichierRapport)
	ShellExecuteWait($sDossierRapport & "\Rapport intervention.txt")
	$hFichierRapport = FileOpen($sDossierRapport & "\Rapport intervention.txt", 1)
	_UpdEdit($iIDEditRapport, $hFichierRapport)
	;Local $rc = _INetSmtpMailCom($aEnvoi[2][1], "I² - Rapport Intervention", $aEnvoi[1][1], $aEnvoi[1][1], "Rapport de " & $sNom, $corps, "", "", "", "Normal", $aEnvoi[5][1], $sMdp, $aEnvoi[3][1], $aEnvoi[4][1])
	_ChangerEtatBouton($iIDAction, "Activer")

EndFunc

Func _EnvoiFTP($sFichier, $sDossier)
	Local $sFTPAdresse = IniRead($sConfig, "FTP", "Adresse", "")
	Local $sFTPUser = IniRead($sConfig, "FTP", "Utilisateur", "")
	Local $sFTPPort = IniRead($sConfig, "FTP", "Port", "21")
	Local $bRetour = 0

	If($sFTPAdresse <> "" And $sFTPUser <> "" And $sDossier <> "") Then
		Local $sMdp, $bSVGMdp = 0, $iIdFTP

		If(FileExists($sScriptDir & '\Cache\Pwd\ftp.sha')) Then
			$sMdp = BinaryToString(_Crypt_DecryptData(FileReadLine($sScriptDir & '\Cache\Pwd\ftp.sha'), $sFTPUser, $CALG_AES_256))
		Else
			Local $hGUIFTP = GUICreate("Envoi sur FTP", 400, 105)
			GUICtrlCreateLabel('Saisissez le mot de passe FTP (' & $sFTPUser & '@' & $sFTPAdresse & ') :',10, 15)
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
			GUICtrlSetData($statusbar, " Envoi FTP")
			GUICtrlSetData($statusbarprogress, 20)
			Local $Err, $sFTP_Message
			Local $hOpen = _FTP_Open('FTP')

			GUICtrlSetData($statusbarprogress, 50)

			Local $hConn = _FTP_Connect($hOpen, $sFTPAdresse, $sFTPUser, $sMdp, 0, $sFTPPort)

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

				GUICtrlSetData($statusbarprogress, 75)

				If(StringRight($sFichier, 3) = "txt" Or StringRight($sFichier, 3) = "php") Then
					_FTP_FilePut($hConn, $sFichier, $sDossier, $INTERNET_FLAG_TRANSFER_ASCII)
				Else
					_FTP_FilePut($hConn, $sFichier, $sDossier)
				EndIf
				GUICtrlSetData($statusbarprogress, 100)
			EndIf
			Local $iFtpc = _FTP_Close($hConn)
			Local $iFtpo = _FTP_Close($hOpen)
			GUICtrlSetData($statusbar, "")
			GUICtrlSetData($statusbarprogress, 0)

		EndIf
	EndIf
	Return $bRetour
EndFunc