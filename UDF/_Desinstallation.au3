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

Func _DesinstallerBAO($sFTPAdresse, $sFTPUser, $sFTPPort, $sFTPDossierRapports)

	Local $iIDButtonDesinstaller = 1, $iIDButtonAnnuler = 1, $eGet, $iRapport = 0, $iEteindre = 0, $sInput, $iIDInputInfo, $sProgDes, $t = 0
	if $sNom <> "" Then
		Local $hGUIdes = GUICreate("Désinstallation de BAO", 400, 100)
		Local $iIDCheckRapport = GUICtrlCreateCheckbox("Afficher/compléter le rapport", 10, 10)
		Local $iIDCheckEteindre = GUICtrlCreateCheckbox("Eteindre l'ordinateur", 10, 30)

		If _FichierCacheExist("Suivi") = 1 Then
			If _FichierCache("Suivi") > 1 Then
			GUICtrlCreateLabel("Information de suivi à ajouter :", 200, 10)
			$iIDInputInfo = GUICtrlCreateInput("", 200, 30)
			EndIf
		EndIf

		$iIDButtonDesinstaller = GUICtrlCreateButton("Désinstaller", 100, 60, 90, 25, $BS_DEFPUSHBUTTON)
		$iIDButtonAnnuler = GUICtrlCreateButton("Annuler", 210, 60, 90, 25)



		GUISetState(@SW_SHOW)

		$eGet = GUIGetMsg()

		While $eGet <> $GUI_EVENT_CLOSE And $eGet <> $iIDButtonAnnuler And $eGet <> $iIDButtonDesinstaller
			$eGet = GUIGetMsg()
		WEnd

	EndIf

	If ($eGet = $iIDButtonDesinstaller) Then

		If(GUICtrlRead($iIDCheckRapport) = $GUI_CHECKED) Then
			$iRapport = 1
		EndIf

		If(GUICtrlRead($iIDCheckEteindre) = $GUI_CHECKED) Then
			$iEteindre = 1
		EndIf

		If(GUICtrlRead($iIDInputInfo) <> "") Then
			$sInput = GUICtrlRead($iIDInputInfo)
		EndIf

		GUIDelete()
	EndIf

	If ($eGet <> $iIDButtonAnnuler) Then

		$sSplashTxt = "Enregistrement des changements apportés"
		SplashTextOn("", $sSplashTxt, $iSplashWidth, $iSplashHeigh, $iSplashX, $iSplashY, $iSplashOpt, "", $iSplashFontSize)

		FileWriteLine($hFichierRapport, "")
		FileWriteLine($hFichierRapport, "Changements apportés :")

		_GetInfoSysteme()

		If($aListeAvSupp <> "") Then

			Local $aListeApSupp = _ListeProgrammes()
			$aListeApSupp = _ArrayUnique($aListeApSupp, 0, 0, 0, 0)

			For $sProgAvSupp in $aListeAvSupp
				If _ArraySearch($aListeApSupp, $sProgAvSupp) = -1 Then
					$t = $t + 1
					$sProgDes &= " - " & $sProgAvSupp & @CRLF
				EndIf
			Next
			If $t > 0 Then
				FileWriteLine($hFichierRapport, " " & $t & " Programme(s) désinstallé(s) : ")
				FileWrite($hFichierRapport, $sProgDes)
				FileWriteLine($hFichierRapport, "")
			EndIf
		EndIf
		FileWriteLine($hFichierRapport, " Espace libre sur " & @HomeDrive & " : " & $iFreeSpace & " Go")
		FileWriteLine($hFichierRapport, "")
		FileWriteLine($hFichierRapport, "Fin de l'intervention : " & _Now())

		If $iRapport = 1 Then
			_CompleterRapport()
		EndIf

		Local $sNomFichier = $sDossierRapport & "\" & StringReplace(StringLeft(_NowCalc(),10), "/", "") & " " & $sNom & " - Rapport intervention.txt"
		FileMove($sDossierRapport & "\Rapport intervention.txt", $sNomFichier, 1)

		Local $iRetour = 0

		$sSplashTxt = $sSplashTxt & @LF & "Sauvegarde du rapport"
		SplashTextOn("", $sSplashTxt, $iSplashWidth, $iSplashHeigh, $iSplashX, $iSplashY, $iSplashOpt, "", $iSplashFontSize)

		If StringLeft(@ScriptDir, 2) <> "\\" Then

			Do
				$iRetour = _EnvoiFTP($sFTPAdresse, $sFTPUser, $sFTPPort, $sNomFichier, $sFTPDossierRapports & StringReplace(StringLeft(_NowCalc(),10), "/", "") & " " & $sNom & " - Rapport intervention.txt")
			Until $iRetour <> -1

		EndIf

		If $iRetour = 0 Then
			FileCopy($sNomFichier, @ScriptDir & "\Rapports\" & @YEAR & "-" & @MON & "\", 9)
			$iRetour = 1
		EndIf

		if($iRetour = 1) Then
			If(_FichierCacheExist("Suivi") And _FichierCache("Suivi") <> 1) Then
				_FinIntervention(_FichierCache("Suivi"), $sFTPAdresse, $sFTPUser, $sFTPPort, $sInput)
				_SupprimerIDSuivi(_FichierCache("Suivi"))
			EndIf
		EndIf

		$sSplashTxt = $sSplashTxt & @LF & "Suppression des dépendances de BAO"
		SplashTextOn("", $sSplashTxt, $iSplashWidth, $iSplashHeigh, $iSplashX, $iSplashY, $iSplashOpt, "", $iSplashFontSize)
		_ReiniBAO()
		$sSplashTxt = $sSplashTxt & @LF & "Suppression de BAO"
		SplashTextOn("", $sSplashTxt, $iSplashWidth, $iSplashHeigh, $iSplashX, $iSplashY, $iSplashOpt, "", $iSplashFontSize)
		_Uninstall($iEteindre)
		SplashOff()
		Exit
	Else
		GUIDelete()
	EndIf
EndFunc

Func _ReiniBAO()

	If(_FichierCacheExist("BureauDistant") = 1) Then
		_UninstallDWAgent()
	EndIf

	If(_FichierCacheExist("Installation") = 1) Then
		RegDelete("HKEY_CURRENT_USER\Environment\", "ChocolateyInstall")
		DirRemove($envChoco, 1)
	EndIf

	If(_FichierCacheExist("Autologon") = 1 And GUICtrlRead($iIDAutologon) = $GUI_CHECKED) Then
		RegWrite($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","AutoAdminLogon","REG_SZ", 0)
		RegDelete($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","DefaultPassword")
	EndIf

	DirRemove(@LocalAppDataDir & "\bao", 1)
	RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce\", "BAO")
	_UACEnable()

EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _Uninstall($iRep)
; Description ...:
; Syntax ........:
; Parameters ....:
; Return values..:
;
; Author.........:
; Modified ......:
; ===============================================================================================================================
Func _Uninstall($iRep)

	Run(@ComSpec & ' /c del "' & @DesktopDir & '\BAO*.lnk"', "", @SW_HIDE)
	FileDelete(@DesktopDir & '\ESET Online Scanner.lnk')
	FileDelete(@UserProfileDir & "\Downloads\BAO-sfx.exe")
	Run(@ComSpec & ' /c del "' & @DesktopDir & '\ZHPCleaner*"', "", @SW_HIDE)

	If $sRestauration = 1 Then
		_Restauration("Fin d'intevervention BAO")
	EndIf

    If @Compiled And StringLeft(@ScriptDir, 2) = @HomeDrive Then
		ShellExecute ( @ComSpec , ' /c RMDIR /S /Q "' & FileGetShortName(@ScriptDir) & '"', "" , "", @SW_HIDE )
	EndIf

	If $iRep = 1 Then
		ShellExecute ( @ComSpec , " /c shutdown -s -t 15" , "" , "", @SW_HIDE )
	EndIf

EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _RelancerBAO()
; Description ...:
; Syntax ........:
; Parameters ....:
; Return values..:
;
; Author.........:
; Modified ......:
; ===============================================================================================================================
Func _ChangerMode()

	If(StringLeft($sNom, 4) <> "Tech") Then ;Mode lecture
		_FichierCache("Client", -1)
		_FichierCache("Client", "Tech " & $sNom)
	Else
		_FichierCache("Client", -1)
		_FichierCache("Client", StringTrimLeft($sNom, 5))
	EndIf

EndFunc