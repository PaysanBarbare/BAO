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

Func _DesinstallerBAO()

	Local $sRepsup = 7
	if $sNom <> "" Then
		$sRepsup = MsgBox($MB_YESNOCANCEL, "Suppression", "Voulez vous éteindre l'ordinateur après la désinstallation ?")
	EndIf

	If ($sRepsup = 6 Or $sRepsup = 7) Then
		FileWriteLine($hFichierRapport, "Espace libre sur " & @HomeDrive & " à la fin de l'intervention : " & $iFreeSpace & " Go")
		FileClose($hFichierRapport)
		Local $sNomFichier = $sDossierRapport & "\" & StringReplace(StringLeft(_NowCalc(),10), "/", "") & " " & $sNom & " - Rapport intervention.txt"
		FileMove($sDossierRapport & "\Rapport intervention.txt", $sNomFichier, 1)
		FileCopy($sNomFichier, @ScriptDir & "\Rapports\", 9)
		Local $sFTPDossierRapports = IniRead($sConfig, "FTP", "DossierRapports", "")
		Local $iRetour
		Do
			$iRetour = _EnvoiFTP($sNomFichier, $sFTPDossierRapports & StringReplace(StringLeft(_NowCalc(),10), "/", "") & " " & $sNom & " - Rapport intervention.txt")
			if($iRetour = 1) Then
				If(_FichierCacheExist("Suivi") And _FichierCache("Suivi") <> 1) Then
					_FinIntervention(_FichierCache("Suivi"))
					_SupprimerIDSuivi(_FichierCache("Suivi"))
				EndIf
			EndIf
		Until $iRetour <> -1

		_ReiniBAO()
		_Uninstall($sRepsup)
		Exit
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

	If $iRep = 6 Then
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