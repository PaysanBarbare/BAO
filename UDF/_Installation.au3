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

Func _InstallationAutomatique()

	_ChangerEtatBouton($iIDAction, "Patienter")

	Local $sListeSoftsInternet = IniRead($sConfig, "Installation", "1", "Internet GoogleChrome Firefox Opera Safari Thunderbird")
	Local $sListeSoftsBureautique = IniRead($sConfig, "Installation", "2", "Bureautique OpenOffice LibreOffice-fresh")
	Local $sListeSoftsMultimedia = IniRead($sConfig, "Installation", "3", "Multimedia K-LiteCodecPackFull Skype VLC Paint.net GoogleEarth GoogleEarthPro iTunes")
	Local $sListeSoftsDivers = IniRead($sConfig, "Installation", "4", "Divers 7Zip AdobeReader CCleaner CDBurnerXP Defraggler ImgBurn JavaRuntime TeamViewer")

	Local $aListeSoftsInternet = StringSplit($sListeSoftsInternet, " ")
	Local $aListeSoftsBureautique = StringSplit($sListeSoftsBureautique, " ")
	Local $aListeSoftsMultimedia = StringSplit($sListeSoftsMultimedia, " ")
	Local $aListeSoftsDivers = StringSplit($sListeSoftsDivers, " ")

	Local $sGroupe1 = $aListeSoftsInternet[1]
	$aListeSoftsInternet[0] = _ArrayDelete($aListeSoftsInternet, 1) - 1
	Local $sGroupe2 = $aListeSoftsBureautique[1]
	$aListeSoftsBureautique[0] = _ArrayDelete($aListeSoftsBureautique, 1) - 1
	Local $sGroupe3 = $aListeSoftsMultimedia[1]
	$aListeSoftsMultimedia[0] = _ArrayDelete($aListeSoftsMultimedia, 1) - 1
	Local $sGroupe4 = $aListeSoftsDivers[1]
	$aListeSoftsDivers[0] = _ArrayDelete($aListeSoftsDivers, 1) - 1

	Local $sListeSoftsDefaut = IniRead($sConfig, "Installation", "Defaut", "GoogleChrome LibreOffice-fresh K-LiteCodecPackFull 7Zip")
	Local $aListeSoftsDefaut = StringSplit($sListeSoftsDefaut, " ", 2)
	Local $aSofts = $aListeSoftsDefaut

	Local $idCheckboxInternet[$aListeSoftsInternet[0]]
	Local $idCheckboxBureautique[$aListeSoftsBureautique[0]]
	Local $idCheckboxMultimedia[$aListeSoftsMultimedia[0]]
	Local $idCheckboxDivers[$aListeSoftsDivers[0]]

	Local $iHauteurCadre1 = $aListeSoftsInternet[0] * 25 + 30
	If $aListeSoftsInternet[0] < $aListeSoftsBureautique[0] Then
		$iHauteurCadre1 = $aListeSoftsBureautique[0] * 25 + 30
	EndIf

	Local $iHauteurCadre2 = $aListeSoftsMultimedia[0] * 25 + 30
	If $aListeSoftsMultimedia[0] < $aListeSoftsDivers[0] Then
		$iHauteurCadre2 = $aListeSoftsDivers[0] * 25 + 30
	EndIf

	Local $hGUIInst = GUICreate("Sélection des programmes à installer", 400,$iHauteurCadre1 + $iHauteurCadre2 + 130)

	GUICtrlCreateGroup($sGroupe1, 10, 10, 180, $iHauteurCadre1)
	For $p = 1 To $aListeSoftsInternet[0]
		$idCheckboxInternet[$p-1] = GUICtrlCreateCheckbox($aListeSoftsInternet[$p], 20, 25 * ($p - 1) + 30)
		If(_ArraySearch($aListeSoftsDefaut, $aListeSoftsInternet[$p]) <> -1) Then
			GUICtrlSetState (-1, 1)
		EndIf
	Next

	GUICtrlCreateGroup($sGroupe2, 210, 10, 180, $iHauteurCadre1)
	For $p = 1 To $aListeSoftsBureautique[0]
		$idCheckboxBureautique[$p-1] = GUICtrlCreateCheckbox($aListeSoftsBureautique[$p], 220, 25 * ($p - 1) + 30)
		If(_ArraySearch($aListeSoftsDefaut, $aListeSoftsBureautique[$p]) <> -1) Then
			GUICtrlSetState (-1, 1)
		EndIf
	Next

	GUICtrlCreateGroup($sGroupe3, 10,$iHauteurCadre1 + 30 , 180, $iHauteurCadre2)
	For $p = 1 To $aListeSoftsMultimedia[0]
		$idCheckboxMultimedia[$p-1] = GUICtrlCreateCheckbox($aListeSoftsMultimedia[$p], 20, $iHauteurCadre1 + 25 * ($p - 1) + 50)
		If(_ArraySearch($aListeSoftsDefaut, $aListeSoftsMultimedia[$p]) <> -1) Then
			GUICtrlSetState (-1, 1)
		EndIf
	Next

	GUICtrlCreateGroup($sGroupe4, 210, $iHauteurCadre1 + 30 , 180, $iHauteurCadre2)
	For $p = 1 To $aListeSoftsDivers[0]
		$idCheckboxDivers[$p-1] = GUICtrlCreateCheckbox($aListeSoftsDivers[$p], 220, $iHauteurCadre1 + 25 * ($p - 1) + 50)
		If(_ArraySearch($aListeSoftsDefaut, $aListeSoftsDivers[$p]) <> -1) Then
			GUICtrlSetState (-1, 1)
		EndIf
	Next

	GUICtrlCreateLabel("Sélectionner", 15, $iHauteurCadre1 + $iHauteurCadre2 + 45)
	Local $iIDButtonSelectionner = GUICtrlCreateButton("Tous", 90, $iHauteurCadre1 + $iHauteurCadre2 + 40, 70, 25)
	Local $iIDButtonDeselectionner = GUICtrlCreateButton("Aucun", 165, $iHauteurCadre1 + $iHauteurCadre2 + 40, 70, 25)
	Local $iIDButtonDefaut = GUICtrlCreateButton("Par défaut", 240, $iHauteurCadre1 + $iHauteurCadre2 + 40, 70, 25)
	$p = $p+1
;~ 	Local $iIDCache = GUICtrlCreateCheckbox("Utiliser le cache ? (Décochez pour installer Firefox)", 20, $iHauteurCadre1 + $iHauteurCadre2 + 70)
;~ 	GUICtrlSetState (-1, 1)
;~ 	If(StringInStr(@ScriptDir, "\\") = 0) Then ;UNC
;~ 		GUICtrlSetState($iIDCache, 32)
;~ 	EndIf
	Local $iIDButtonInstaller = GUICtrlCreateButton("Installer", 125, $iHauteurCadre1 + $iHauteurCadre2 + 100, 150, 25, $BS_DEFPUSHBUTTON)

	 ; Boucle jusqu'à ce que l'utilisateur quitte.

	GUISetState(@SW_SHOW)

	Local $idMsgInst = GUIGetMsg()
	Local $idtab

	While ($idMsgInst <> $GUI_EVENT_CLOSE) And ($idMsgInst <> $iIDButtonInstaller)

		If $idMsgInst = $iIDButtonSelectionner Then
			Local $aTemp[]
			For $icheck In $idCheckboxInternet
				GUICtrlSetState($icheck, $GUI_CHECKED)
				_ArrayAdd($aTemp, GUICtrlRead($icheck, 1))
			Next
			For $icheck In $idCheckboxBureautique
				GUICtrlSetState($icheck, $GUI_CHECKED)
				_ArrayAdd($aTemp, GUICtrlRead($icheck, 1))
			Next
			For $icheck In $idCheckboxMultimedia
				GUICtrlSetState($icheck, $GUI_CHECKED)
				_ArrayAdd($aTemp, GUICtrlRead($icheck, 1))
			Next
			For $icheck In $idCheckboxDivers
				GUICtrlSetState($icheck, $GUI_CHECKED)
				_ArrayAdd($aTemp, GUICtrlRead($icheck, 1))
			Next
			$aSofts = $aTemp
		ElseIf $idMsgInst = $iIDButtonDeselectionner Then
			Local $aSofts[0]
			For $icheck In $idCheckboxInternet
				GUICtrlSetState($icheck, $GUI_UNCHECKED)
			Next
			For $icheck In $idCheckboxBureautique
				GUICtrlSetState($icheck, $GUI_UNCHECKED)
			Next
			For $icheck In $idCheckboxMultimedia
				GUICtrlSetState($icheck, $GUI_UNCHECKED)
			Next
			For $icheck In $idCheckboxDivers
				GUICtrlSetState($icheck, $GUI_UNCHECKED)
			Next
		ElseIf $idMsgInst = $iIDButtonDefaut Then
			Local $aSofts[0]
			For $icheck In $idCheckboxInternet
				If(_ArraySearch($aListeSoftsDefaut, GUICtrlRead($icheck, 1)) <> -1) Then
					GUICtrlSetState ($icheck, $GUI_CHECKED)
					_ArrayAdd($aSofts, GUICtrlRead($icheck, 1))
				Else
					GUICtrlSetState ($icheck, $GUI_UNCHECKED)
				EndIf
			Next
			For $icheck In $idCheckboxBureautique
				If(_ArraySearch($aListeSoftsDefaut, GUICtrlRead($icheck, 1)) <> -1) Then
					GUICtrlSetState ($icheck, $GUI_CHECKED)
					_ArrayAdd($aSofts, GUICtrlRead($icheck, 1))
				Else
					GUICtrlSetState ($icheck, $GUI_UNCHECKED)
				EndIf
			Next
			For $icheck In $idCheckboxMultimedia
				If(_ArraySearch($aListeSoftsDefaut, GUICtrlRead($icheck, 1)) <> -1) Then
					GUICtrlSetState ($icheck, $GUI_CHECKED)
					_ArrayAdd($aSofts, GUICtrlRead($icheck, 1))
				Else
					GUICtrlSetState ($icheck, $GUI_UNCHECKED)
				EndIf
			Next
			For $icheck In $idCheckboxDivers
				If(_ArraySearch($aListeSoftsDefaut, GUICtrlRead($icheck, 1)) <> -1) Then
					GUICtrlSetState ($icheck, $GUI_CHECKED)
					_ArrayAdd($aSofts, GUICtrlRead($icheck, 1))
				Else
					GUICtrlSetState ($icheck, $GUI_UNCHECKED)
				EndIf
			Next
		ElseIf(_ArraySearch($idCheckboxInternet, $idMsgInst) <> -1 Or _ArraySearch($idCheckboxBureautique, $idMsgInst) <> -1 Or _ArraySearch($idCheckboxMultimedia, $idMsgInst) <> -1 Or _ArraySearch($idCheckboxDivers, $idMsgInst) <> -1) Then
			If(GUICtrlRead($idMsgInst) = $GUI_CHECKED) Then
				_ArrayAdd($aSofts, GUICtrlRead($idMsgInst, 1))
			Else
				$idtab = _ArraySearch($aSofts, GUICtrlRead($idMsgInst, 1))
				_ArrayDelete($aSofts, $idtab)
			EndIf
		EndIf
		$idMsgInst = GUIGetMsg()
	WEnd

;~ 	If GUICtrlRead($iIDCache) = $GUI_CHECKED Then
;~ 		$iIDCache = 1
;~ 	Else
;~ 		$iIDCache = 0
;~ 	EndIf

	; Supprime l'interface graphique précédente et tous ses contrôles.

	GUIDelete($hGUIInst)

	If($idMsgInst = $iIDButtonInstaller And UBound($aSofts) > 0) Then

		;$sListeSofts = _ArrayToString($aListeSofts, " ")
		If FileExists( @AppDataCommonDir & "\chocolatey\choco.exe") = 0 Then
			GUICtrlSetData($statusbar, " Préparation de l'installation")
			GUICtrlSetData($statusbarprogress, 5)
			Local $sEnvVar = EnvGet("PATH")

			EnvSet("PATH", $sEnvVar & ";" & @AppDataCommonDir & "\Chocolatey\bin")
			EnvUpdate()
			RunWait(@ComSpec & ' /c ' & '@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command " [System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString(''https://chocolatey.org/install.ps1''))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"', "", @SW_HIDE)

			GUICtrlSetData($statusbarprogress, 10)

			If FileExists( @AppDataCommonDir & "\chocolatey\choco.exe") = 0 Then
				ClipPut(@ComSpec & ' /c ' & '@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command " [System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString(''https://chocolatey.org/install.ps1''))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"')
				_Attention("PowerShell n'est pas installé ou Chocolatey n'a pu s'installer. Fin de l'éxécution")
				GUICtrlSetData($statusbar, "")
				GUICtrlSetData($statusbarprogress, 0)
				_ChangerEtatBouton($iIDAction, "Desactiver")
			Else
				_FichierCache("Installation", 1)
				FileWriteLine($hFichierRapport, "Installation de logiciels : ")
			EndIf
		Else
			_FichierCache("Installation", 1)
		EndIf

		If(_FichierCacheExist("Installation") = 1) Then

;~ 			If $iIDCache = 1 Then
				RunWait( @ComSpec & ' /c ' & 'choco config set cacheLocation "' & @ScriptDir & '\Cache\Choco"', "", @SW_HIDE)
;~ 			Else
;~ 				RunWait( @ComSpec & ' /c ' & 'choco config unset cacheLocation', "", @SW_HIDE)
;~ 			EndIf

			_InstallationEnCours($aSofts)

			GUICtrlSetData($statusbar, "")
			GUICtrlSetData($statusbarprogress, 0)
			_ChangerEtatBouton($iIDAction, "Activer")
			FileWriteLine($hFichierRapport, "")
			_UpdEdit($iIDEditRapport, $hFichierRapport)
		EndIf
	Else
		If(_FichierCacheExist("Installation") = 1) Then
			_ChangerEtatBouton($iIDAction, "Activer")
		Else
			_ChangerEtatBouton($iIDAction, "Desactiver")
		EndIf
	EndIf
EndFunc

Func _InstallationEnCours($aSofts)

	For $po = 0 To (UBound($aSofts) - 1)

		Local $hID, $sPC = "Indéterminé", $sNomFichier = @ScriptDir & "\Cache\InstallationEnCours\" & $aSofts[$po] & ".txt"

		If FileExists($sNomFichier) Then

			$hID = FileOpen($sNomFichier)
			If $hID = -1 Then
				_Attention("Impossible d'ouvrir " & $sNomFichier)
			Else
				$sPC = FileReadLine($hID, 1)
				FileClose($hID)
			EndIf
			GUICtrlSetData($statusbar, " Installation de " &  $aSofts[$po] & " en attente [" & $sPC & "]")

			While (FileExists($sNomFichier))
				Sleep(10000)
			WEnd
		EndIf

		$hID = FileOpen($sNomFichier, 9)
		If $hID = -1 Then
				_Attention("Impossible d'ouvrir " & $sNomFichier)
		Else
				FileWriteLine($hID, @ComputerName)
				FileClose($hID)
		EndIf

		; Local $envChoco = RegRead("HKEY_CURRENT_USER\Environment\", "ChocolateyInstall")
		Local $iPidChoco, $sOutput, $aArray, $iPerc, $sProgErr = ""

		GUICtrlSetData($statusbar, " Installation de " &  $aSofts[$po])

		$iPerc = (($po * 90) / UBound($aSofts)) + 10
		GUICtrlSetData($statusbarprogress, $iPerc)
		$iPidChoco = Run( @ComSpec & ' /c ' & 'choco install -y --limitoutput ' & $aSofts[$po], "",@SW_HIDE, $STDOUT_CHILD)
		ProcessWaitClose($iPidChoco)
		$sOutput = StdoutRead($iPidChoco)

		; Utilise StringSplit pour partager la sortie de StdoutRead en un tableau. Tous les retours chariot (@CRLF) sont supprimés et @CRLF (saut de ligne) est utilisé comme séparateur.
		$aArray = StringSplit(StringTrimRight(StringStripCR($sOutput), StringLen(@CRLF)), @CRLF)
		If _ArraySearch($aArray, " The install of " & $aSofts[$po] & " was successful.") = -1 Then
			$sProgErr &= " - " & $aSofts[$po] & @LF
		Else
			FileWriteLine($hFichierRapport, " " & $aSofts[$po] & " installé")
		EndIf

		If Not FileDelete($sNomFichier) Then _Attention("Impossible de supprimer " & $sNomFichier & ". Supprimez le manuellement", 1)
	Next

	GUICtrlSetData($statusbarprogress, 100)

	If($sProgErr <> "") Then
		_Attention("Les programmes suivants n'ont pas été installé : " & @lf & $sProgErr & "Réessayez ou installez-les manuellement", 1)
	EndIf

EndFunc

Func _ClearCache()

	If FileExists(@ScriptDir & '\Cache\Choco') Then
		if DirRemove(@ScriptDir & '\Cache\Choco', 1) = 1 Then
			FileWriteLine($hFichierRapport, "Cache des installations nettoyé")
			FileWriteLine($hFichierRapport, "")
			_UpdEdit($iIDEditRapport, $hFichierRapport)
		EndIf
	EndIf

EndFunc