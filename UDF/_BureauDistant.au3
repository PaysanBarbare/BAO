#cs

Copyright 2020 Bastien Rouches

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

Func _BureauDistant()

	Local $programFilesDir = RegRead("HKLM64\SOFTWARE\Microsoft\Windows\CurrentVersion", "ProgramFilesDir")
	Local $sAgent = IniRead($sConfig, "BureauDistant", "Agent", "https://www.dwservice.net/download/dwagent_x86.exe")
	Local $sMailBD = IniRead($sConfig, "BureauDistant", "Mail", "")

	If $sMailBD <> "" Then

		If StringLeft($sNom, 4) <> "Tech" And FileExists($programFilesDir & "\DWAgent\runtime\dwagent.exe") Then
			If(_FichierCacheExist("BureauDistant") = 1) Then
				_UninstallDWAgent()
				_ChangerEtatBouton($iIDAction, "Desactiver")
				_FichierCache("BureauDistant", "-1")
			Else
				_FichierCache("BureauDistant", "1")
				_ChangerEtatBouton($iIDAction, "Activer")
			EndIf
		Else
			If(StringLeft($sNom, 4) <> "Tech") Then
				_ChangerEtatBouton($iIDAction, "Patienter")
				If(_Telecharger("DWAgent", $sAgent)) Then
					Local $sMdp, $bSVGMdp = 0, $iIdDWS
					If(FileExists($sScriptDir & '\Cache\Pwd\dws.sha')) Then
						$sMdp = BinaryToString(_Crypt_DecryptData(FileReadLine($sScriptDir & '\Cache\Pwd\dws.sha'), $sMailBD, $CALG_AES_256))
					Else
						Local $hGUIDWS = GUICreate("Activation du bureau distant", 400, 105)
						GUICtrlCreateLabel('Saisissez le mot de passe DWService pour "' & $sMailBD & '" :',10, 15)
						Local $iPWD = GUICtrlCreateInput("", 10, 42, 200, 20, $ES_PASSWORD)
						Local $iMem = GUICtrlCreateCheckbox("Mémoriser le mot de passe ?", 220, 40)

						Local $iIDValider = GUICtrlCreateButton("Valider", 125, 70, 150, 25, $BS_DEFPUSHBUTTON)
						GUISetState(@SW_SHOW)

						While 1
							$iIdDWS= GUIGetMsg()
							Switch $iIdDWS

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

						If($bSVGMdp = 1) Then
							_Crypter("dws", $sMdp, $sMailBD)
						EndIf

						GUICtrlSetData($statusbar, " Installation de DWAgent")
						GUICtrlSetData($statusbarprogress, 20)
						ShellExecuteWait($sProgrun, '-silent user=' & $sMailBD & ' password=' & $sMdp & ' name="' & $sNom & '"')
						if @error <> 0 Then
							_Attention("Impossible d'installer DWAgent")
							GUICtrlSetData($statusbar, "")
							GUICtrlSetData($statusbarprogress, 0)
							_ChangerEtatBouton($iIDAction, "Desactiver")
						Else
							GUICtrlSetData($statusbarprogress, 100)
							Sleep(2000)
							GUICtrlSetData($statusbar, "")
							GUICtrlSetData($statusbarprogress, 0)
							_ChangerEtatBouton($iIDAction, "Activer")
							_FichierCache("BureauDistant", "1")
						EndIf
					Else
						_ChangerEtatBouton($iIDAction, "Desactiver")
					EndIf
				Else
				 _Attention('Echec du téléchargement de "DWAgent"')
				 _ChangerEtatBouton($iIDAction, "Desactiver")
				EndIf
			Else
			  ShellExecute("chrome", 'https://www.dwservice.net/fr/login.html')
			EndIf
		EndIf
	Else
		_Attention("L'adresse email de votre compte DWS doit être renseignée dans le fichier config.ini")
		_ChangerEtatBouton($iIDAction, "Desactiver")
	EndIf
EndFunc

Func _UninstallDWAgent()
	Local $programFilesDir = RegRead("HKLM64\SOFTWARE\Microsoft\Windows\CurrentVersion", "ProgramFilesDir")
	If FileExists($programFilesDir & "\DWAgent\runtime\dwagent.exe") Then
		Local $process = ProcessList("dwagent.exe")
			For $i = 1 To $process[0][0]
			ProcessClose($process[$i][1])
		Next
		FileCopy("C:\Program Files\DWAgent\native\dwaglnc.exe", @LocalAppDataDir & "\bao\tmp\", 9)
		Local $programFilesDir = RegRead("HKLM64\SOFTWARE\Microsoft\Windows\CurrentVersion", "ProgramFilesDir")
		ShellExecuteWait($programFilesDir & "\DWAgent\runtime\dwagent.exe", "-S -m installer uninstall", "", "", @SW_HIDE)
		ShellExecuteWait($programFilesDir & "\DWAgent\native\dwagsvc.exe", "removeAutoRun", "", "", @SW_HIDE)
		ShellExecuteWait($programFilesDir & "\DWAgent\native\dwagsvc.exe", "stopService", "", "", @SW_HIDE)
		ShellExecuteWait($programFilesDir & "\DWAgent\native\dwagsvc.exe", "deleteService", "", "", @SW_HIDE)
		ShellExecuteWait($programFilesDir & "\DWAgent\native\dwagsvc.exe", "removeShortcuts", "", "", @SW_HIDE)
		ShellExecuteWait(@LocalAppDataDir & "\bao\tmp\dwaglnc.exe", 'remove "' & $programFilesDir & '\DWAgent"', "", "", @SW_HIDE)
	EndIf
EndFunc