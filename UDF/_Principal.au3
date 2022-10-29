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

#cs
Auteur : Bastien ROUCHES
Fonction : Liste des fonctions utiles pour le fonctionnement de I² - BAO
#ce

; Traitement du fichier config.ini

Func _InitialisationBAO($sConfig)
	Local $aSections
	If(FileExists($sConfig)) Then

		$aSections = IniReadSectionNames($sConfig)
		if @error Then
			_Erreur("Fichier 'config.ini' erroné")
		ElseIf(UBound($aSections) < 7) Then
			_Erreur("Le fichier 'config.ini' doit comporter 6 sections : " & @CRLF & "    - Parametrages" & @CRLF & "    - Installation" & @CRLF & "    - BureauDistant" & @CRLF & "    - Desinfection" & @CRLF & "    - Associations" & @CRLF & "    - FTP" & @CRLF & @CRLF & "Merci de rajouter la section manquante ou de le supprimer afin que BAO en génère un nouveau.")
		EndIf
	Else
		; Création du fichier config.ini
		IniWriteSection($sConfig,"Parametrages", "Societe=MyBigCorporation"&@LF&"Dossier=Rapport"&@LF&"Icones=1"&@LF&"Restauration=0"&@CRLF)

		IniWriteSection($sConfig,"Installation", "Defaut=GoogleChrome LibreOffice-fresh k-litecodecpackbasic 7Zip"&@LF&"1=Internet GoogleChrome Firefox Opera Safari Thunderbird"&@LF&"2=Bureautique OpenOffice LibreOffice-fresh OnlyOffice"&@LF&"3=Multimedia k-litecodecpackbasic Skype VLC Paint.net GoogleEarth GoogleEarthPro iTunes"&@LF&"4=Divers 7Zip AdobeReader CCleaner CDBurnerXP Defraggler FoxitReader ImgBurn JavaRuntime TeamViewer"&@CRLF)

		IniWriteSection($sConfig,"BureauDistant", "Agent=DWAgent"&@LF&"Mail=votreadressemail@domaine.fr"&@CRLF)

		IniWriteSection($sConfig,"Desinfection", "Programmes de desinfection=Privazer RogueKiller AdwCleaner MalwareByte ZHPCleaner EsetOnlineScanner"&@CRLF)

		IniWriteSection($sConfig, "Associations", "Defaut=0,0,0,0"&@CRLF)

		IniWriteSection($sConfig, "FTP", "Protocol=sftp"&@LF&"Adresse="&@LF&"Utilisateur="&@LF&"Port=22"&@LF&"DossierRapports=/www/rapports/"&@LF&"DossierSFX=/www/dl/"&@LF&"DossierSuivi=/www/suivi/"&@LF&"DossierCapture=/www/capture/"&@CRLF)

		TrayTip("Premier lancement", "Merci de compléter le fichier de configuration", 30)
		ShellExecuteWait($sConfig)
	EndIf

EndFunc

Func _PremierLancement($sFTPAdresse, $sFTPUser, $sFTPPort, $sFTPDossierRapports)

	Local $hGUINom = GUICreate("Client", 400, 200)
	GUICtrlCreateLabel('Entrez le nom du client :',10, 15)
	Local $iNomTmp = GUICtrlCreateInput(@UserName, 130, 12, 250)
	GUICtrlCreateLabel('(Indiquez "Tech" suivi de votre nom pour la version Technicien)', 10, 40)

	Local $aSuivi = _FileListToArrayRec(@ScriptDir & "\Cache\Suivi\", "*.txt")
	Local $iIDCombo

	If $aSuivi <> "" And _FichierCacheExist("Suivi") = 1 Then
		GUICtrlCreateLabel('Associer cette machine au numéro de suivi : ',10, 90)
		Local $iIDCombo = GUICtrlCreateCombo("Aucun",250, 88, 80)
		For $i=1 To $aSuivi[0]
			GUICtrlSetData($iIDCombo, StringTrimRight($aSuivi[$i], 4))
		Next
	EndIf

	Local $iIDValider = GUICtrlCreateButton("Valider", 125, 155, 150, 25, $BS_DEFPUSHBUTTON)
	GUISetState(@SW_SHOW)

	Local $iIdNom, $bClose = 0

	While 1
		$iIdNom = GUIGetMsg()
		Switch $iIdNom

			Case $GUI_EVENT_CLOSE
				$bClose = 1
				_FichierCache("PremierLancement", _Now())
				ExitLoop

			Case $iIDValider
				_FichierCache("PremierLancement", _Now())
				If(GUICtrlRead($iIDCombo) <> "Aucun") Then
					_FichierCache("Suivi", GUICtrlRead($iIDCombo))
					_DebutIntervention(GUICtrlRead($iIDCombo), $sFTPAdresse, $sFTPUser, $sFTPPort)
				EndIf
				ExitLoop

		EndSwitch
	WEnd

	$sNom = _ChaineSansAccents(GUICtrlRead($iNomTmp))
	$sNom = StringRegExpReplace($sNom, "(?s)[^a-z0-9A-Z-_ ]", "")

	GUIDelete()

	_FichierCache("Client", $sNom)

	_FileWriteLog($hLog, "--------------------------")
	_FileWriteLog($hLog, "Premier démarrage de BAO : ")
	_FileWriteLog($hLog, "Client : " & $sNom & " - PC : " & @ComputerName)

	$sSplashTxt = $sSplashTxt & @LF & "Génération des informations système"
	ControlSetText("Initialisation de BAO", "", "Static1", $sSplashTxt)

	 _RapportInfos()

	 If StringLeft(@ScriptDir, 2) = "\\" Then
		If FileCopy($sFileInfosys, @ScriptDir & "\Proaxive\" & $sNom & " - " & @ComputerName & " - Informations systeme.bao", 9) = 0 Then
			_FileWriteLog($hLog, 'Impossible de copier "' & $sFileInfosys & '" dans "' & @ScriptDir & '\Proaxive\"')
		EndIf
		_FichierCache("FichierASupprimer", @ScriptDir & "\Proaxive\" & $sNom & " - " & @ComputerName & " - Informations systeme.bao")
	EndIf

	If $bClose = 1 Then
		_FileWriteLog($hLog, "Fermeture par l'utilisateur : désinstallation de BAO")
		$sNom = ""
		_DesinstallerBAO($sFTPAdresse, $sFTPUser, $sFTPPort, $sFTPDossierRapports)
	EndIf

	If($iFreeSpace < 30) Then
		Local $sRepnet = MsgBox($MB_YESNOCANCEL, "Nettoyage", "L'espace libre sur le disque " & $HomeDrive & " est seulement de " & $iFreeSpace & " Go." & @CR & "Voulez vous supprimer les fichiers temporaires et les anciennes installations de Windows ?")
		If($sRepnet = 6) Then
			RunWait(@ComSpec & ' /C cleanmgr.exe /LOWDISK /D ' & $HomeDrive, "", @SW_HIDE)
		EndIf

		If @OSVersion = "WIN_10" Or @OSVersion = "WIN_8" Then
			Local $sRepnet = MsgBox($MB_YESNOCANCEL, "Nettoyage avancé", "Voulez vous compresser le dossier WinSXS et supprimer tous les anciens composants Windows ?")
			If($sRepnet = 6) Then
				RunWait(@ComSpec & ' /C Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase')
				RunWait(@ComSpec & ' /C sc stop msiserver & sc stop TrustedInstaller & sc config msiserver start= disabled & sc config TrustedInstaller start= disabled & icacls "%WINDIR%\WinSxS" /save "%WINDIR%\WinSxS_NTFS.acl" /t & takeown /f "%WINDIR%\WinSxS" /r & icacls "%WINDIR%\WinSxS" /grant "%USERDOMAIN%\%USERNAME%":(F) /t & compact /s:"%WINDIR%\WinSxS" /c /a /i * & icacls "%WINDIR%\WinSxS" /setowner "NT SERVICE\TrustedInstaller" /t & icacls "%WINDIR%" /restore "%WINDIR%\WinSxS_NTFS.acl" & sc config msiserver start= demand & sc config TrustedInstaller start= demand')
			EndIf
		EndIf
		_Attention((Round(DriveSpaceFree($HomeDrive & "\") / 1024, 2) - $iFreeSpace) & " Go libérés")
	EndIf

	Local $iIcones = IniRead($sConfig, "Parametrages", "Icones", 1)

	If($iIcones = 1) Then
		_FileWriteLog($hLog, "Ajout des icones sur le bureau")
		RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel","{20D04FE0-3AEA-1069-A2D8-08002B30309D}","REG_DWORD",0)
		RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel","{59031a47-3f72-44a7-89c5-5595fe6b30ee}","REG_DWORD",0)
	Endif

	; Vérification si autologon n'est pas déjà activé
	$iAutoAdmin = RegRead($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","AutoAdminLogon")
	if $iAutoAdmin = 0 Then
		_FichierCache("Autologon", 2)
	EndIf

	Return $sNom
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _ChangerEtatBouton($iIDBouton, $sEtat)
; Description ...:
; Syntax ........:
; Parameters ....:
; Return values..:
; Author.........: Bastien
; Modified ......:
; ===============================================================================================================================
Func _ChangerEtatBouton($iIDBouton, $sEtat)

	#include <ColorConstants.au3>

	Switch $sEtat
		Case "Activer"
			GUICtrlSetState($iIDBouton, 64)
			GUICtrlSetColor($iIDBouton, $COLOR_GREEN)

		Case "Desactiver"
			GUICtrlSetState($iIDBouton, 64)
			GUICtrlSetColor($iIDBouton, $COLOR_BLACK)

		Case "Patienter"
			GUICtrlSetState($iIDBouton, 128)

		Case "Inactif"
			GUICtrlSetState($iIDBouton, 128)
	EndSwitch
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _ProcessExit()
; Description ...:
; Syntax ........:
; Parameters ....:
; Return values..:
; Author.........: Bastien
; Modified ......:
; ===============================================================================================================================
Func _ProcessExit()
	_SaveInter()
	For $ipidto In $iPidt
		ProcessClose($ipidto)
	Next
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _StartWU()
; Description ...:
; Syntax ........:
; Parameters ....:
; Return values..:
; Author.........: Bastien
; Modified ......:
; ===============================================================================================================================
Func _StartWU()
	Run('net start wuauserv & net start bits & net start dosvc', '', @SW_HIDE)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _FichierCacheExist($sNomFichier)
; Description ...:
; Syntax ........:
; Parameters ....:
; Return values..:
; Author.........: Bastien
; Modified ......:
; ===============================================================================================================================
Func _FichierCacheExist($sNomFichier)

	Local $sFuncRetour = 0
	$sNomFichier = @LocalAppDataDir	 & "\bao\" & $sNomFichier & ".txt"

	If FileExists($sNomFichier) Then $sFuncRetour = 1

	Return $sFuncRetour
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _FichierCache($sNomFichier[, $valeur])
; Description ...:
; Syntax ........:
; Parameters ....:
; Return values..:
; Author.........: Bastien
; Modified ......:
; ===============================================================================================================================
Func _FichierCache($sNomFichier, $sValeur = "0")

	Local $sFuncRetour = "1", $sRepReini
	Local $hID
	$sNomFichier = @LocalAppDataDir & "\bao\" & $sNomFichier & ".txt"


	If($sValeur = "0") Then ;Mode lecture
		If Not FileExists($sNomFichier) Then
			$sRepReini = MsgBox($MB_YESNO, "Fichier manquant", "Le fichier " & $sNomFichier & " n'existe pas. Il est conseillé de réintialiser les réglages de BAO" & @CRLF & "Voulez vous réintialiser BAO ?")
			If ($sRepReini = 6) Then
				_ReiniBAO()
				Exit
			EndIf
		EndIf
		$hID = FileOpen($sNomFichier)
		If $hID = -1 Then
			_Attention("Impossible d'ouvrir " & $sNomFichier)
			$sFuncRetour = 0
		Else
			$sFuncRetour = FileReadLine($hID, 1)
			FileClose($hID)
		EndIf
		;$sFuncRetour = StringTrimRight(FileRead($sNomFichier), 2)
	ElseIf($sValeur = "-1") Then
		If Not FileDelete($sNomFichier) Then _Attention("Impossible de supprimer " & $sNomFichier)
	Else
		$hID = FileOpen($sNomFichier, 10)
		If $hID = -1 Then
			$sRepReini = MsgBox($MB_YESNO, "Erreur d'ouverture", "Impossible d'ouvrir " & $sNomFichier & ". Il est conseillé de réintialiser les réglages de BAO" & @CRLF & "Voulez vous réintialiser BAO ?")
			If ($sRepReini = 6) Then
				_ReiniBAO()
				Exit
			EndIf
			$sFuncRetour = 0
		Else
			FileWriteLine($hID, $sValeur)
			FileClose($hID)
		EndIf
	EndIf

	Return $sFuncRetour
EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: _UpdEdit($iIDEdit, $hFichier)
; Description ...: Affichage d'un test
; Syntax ........:
; Parameters ....:
; Return values..:
; Remark.........:
; Author.........: Bastien
; Modified ......:
; ===============================================================================================================================
Func _UpdEdit($iIDEdit, $hFichier)

	Local $bClose = 0
	If VarGetType($hFichier) = "String" Then
		$hFichier = FileOpen($hFichier, 0)
		$bClose = 1
	EndIf
	FileSetPos($hFichier, 0, $FILE_BEGIN)
	GUICtrlSetData($iIDEdit, StringReplace(FileRead($hFichier), "[BR]", @CRLF))
	GuiCtrlSendMsg($iIDEdit, $EM_LINESCROLL, 0, GuiCtrlSendMsg($iIDEdit, $EM_GETLINECOUNT, 0, 0))

	If $bClose Then
		FileClose($hFichier)
	EndIf
;~ 	FileSetPos($hFichier, 0, $FILE_BEGIN)
;~ 	GUICtrlSetData($iIDEdit, FileRead($hFichier))
;~ 	GuiCtrlSendMsg($iIDEdit, $EM_LINESCROLL, 0, GuiCtrlSendMsg($iIDEdit, $EM_GETLINECOUNT, 0, 0))
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _Erreur
; Description ...: Affichage d'une erreur
; Syntax ........: _Erreur($message)
; Parameters ....: 	$message	- Message à afficher
; Return values..: Aucun
; Remark.........: Le script s'arrete
; Author.........: Bastien
; Modified ......:
; ===============================================================================================================================
Func _Erreur($message)
	MsgBox(16, "Erreur", $message)
	Exit(1)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _Debug
; Description ...: Affichage d'un test
; Syntax ........:
; Parameters ....:
; Return values..:
; Remark.........:
; Author.........: Bastien
; Modified ......:
; ===============================================================================================================================
Func _Debug($message)
	If(IsMap($message)) Then
		Local $keys = MapKeys($message)
		Local $tab[UBound($keys)][2]
		Local $i
		For $i=0 To UBound($tab) - 1
			$tab[$i][0] = $keys[$i]
			$tab[$i][1] = $message[$keys[$i]]
		Next
		_ArrayDisplay($tab)
	ElseIf(IsArray($message)) Then
		_ArrayDisplay($message)
	Else
		ClipPut($message)
		Local $ret = MsgBox(36, "Continuer ?", $message)
		If($ret = 7) Then Exit
	EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _Attention
; Description ...: Affichage d'une information
; Syntax ........: _Attention($message)
; Parameters ....: 	$message	- Message à afficher
; Return values..: Aucun
; Remark.........: Le script continue
; Author.........: Bastien
; Modified ......:
; ===============================================================================================================================
Func _Attention($message, $notimeout = 0)
	If($notimeout = 1) Then
		MsgBox(48, "Attention", $message)
	Else
		MsgBox(48, "Attention", $message, 10)
	EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _isInternetConnected()
; Description ...:
; Syntax ........:
; Parameters ....:
; Return values..:
; Remark.........:
; Author.........:
; Modified ......:
; ===============================================================================================================================

Func _IsInternetConnected()

	Local $dData = _GetIP()
    If $dData <> -1 Then
		Return 1
	Else
		Return 0
	EndIf

EndFunc   ;==>_IsInternetConnected

Func __checkConn($url)
    Return (StringLen(InetRead($url, 1)) > 0)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _ChaineSansAccents($sString)
; Description ...:
; Syntax ........:
; Parameters ....:
; Return values..:
;
; Author.........:
; Modified ......:
; ===============================================================================================================================
Func _ChaineSansAccents($sString)
    ; Les caractères exotiques d'autres langues ne sont pas pris en compte.
    ; Complètez les tableaux si dessous pour prendre en compte d'autres types
    ; de caractères accentués.
	Dim $Var1[27] = ["à", "á", "â", "ã", "ä", "å", "æ", "ç", "è", "é", "ê", "ë", "ì", "í", "î", "ï", "ò", "ó", "ô", "ö", "ù", "ú", "û", "ü", "ý", "ÿ", "œ"]
	Dim $Var2[27] = ["a", "a", "a", "a", "a", "a", "ae", "c", "e", "e", "e", "e", "i", "i", "i", "i", "o", "o", "o", "o", "u", "u", "u", "u", "y", "y", "oe"]

    For $i = 0 To UBound($Var1) - 1
        $sString = StringRegExpReplace($sString, $Var1[$i], $Var2[$i])
        $sString = StringRegExpReplace($sString, StringUpper($Var1[$i]), StringUpper($Var2[$i]))
    Next
    Return $sString
EndFunc   ;==>_SansAccents

Func _OEMToAnsi($sOEM)
    Local $a_AnsiFName = DllCall('user32.dll', 'Int', 'OemToChar', 'str', $sOEM, 'str', ''), $sAnsi
    If @error = 0 Then $sAnsi = $a_AnsiFName[2]
    Return $sAnsi
EndFunc   ;==>_OEMToAnsi

Func _GUICtrlRichEdit_WriteLine($hWnd, $sText, $iIncrement = 0, $sAttrib = "", $iColor = -1)

    ; Count the @CRLFs
    StringReplace(_GUICtrlRichEdit_GetText($hWnd, True), @CRLF, "")
    Local $iLines = @extended
    ; Adjust the text char count to account for the @CRLFs
    Local $iEndPoint = _GUICtrlRichEdit_GetTextLength($hWnd, True, True) - $iLines
    ; Add new text
    _GUICtrlRichEdit_AppendText($hWnd, $sText & @CRLF)
    ; Select text between old and new end points
    _GuiCtrlRichEdit_SetSel($hWnd, $iEndPoint, -1)
    ; Convert colour from RGB to BGR
    $iColor = Hex($iColor, 6)
    $iColor = '0x' & StringMid($iColor, 5, 2) & StringMid($iColor, 3, 2) & StringMid($iColor, 1, 2)
    ; Set colour
    If $iColor <> -1 Then _GuiCtrlRichEdit_SetCharColor($hWnd, $iColor)
    ; Set size
    If $iIncrement <> 0 Then _GUICtrlRichEdit_ChangeFontSize($hWnd, $iIncrement)
    ; Set weight
    If $sAttrib <> "" Then _GUICtrlRichEdit_SetCharAttributes($hWnd, $sAttrib)
    ; Clear selection
    _GUICtrlRichEdit_Deselect($hWnd)

EndFunc

Func _UACDisable()
	; Désactivation de l'UAC
	Local $nUAC

	If( @OSVersion <> "WIN_XP") Then
		RegRead($HKLM & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "EnableLUA")
		If @error = 0 Then
			Local $nUAC = RegRead($HKLM & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin")
			If($nUAC<>0) Then
				_FichierCache("UAC", $nUAC)
				RegWrite($HKLM & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "EnableLUA", "REG_DWORD", "0")
				RegWrite($HKLM & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin", "REG_DWORD", "0")
			EndIf
		EndIf
	EndIf
EndFunc

Func _UACEnable()
	; Réactivation de l'UAC
	Local $nUAC

	If( @OSVersion <> "WIN_XP") Then
		RegRead($HKLM & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "EnableLUA")
		If @error = 0 Then
			if(_FichierCacheExist("UAC") = 1) Then
				$nUAC = _FichierCache("UAC")
				RegWrite($HKLM & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "EnableLUA", "REG_DWORD", "1")
				RegWrite($HKLM & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin", "REG_DWORD", $nUAC )
				_FichierCache("UAC", -1)
			EndIf
		EndIf
	EndIf
EndFunc

Func _Restart()
	run(@ScriptDir & "\run.bat", "", @SW_HIDE)
	Exit
EndFunc

Func _APropos()

	Local $iVersion = 0;

;~ 	If(_IsInternetConnected() = 1) Then

;~ 		Local $SSource = BinaryToString(InetRead("https://isergues.fr/bao.php", 1), 4)
;~ 		Local $aVersion = StringRegExp($SSource, 'Version (.*?)]', 3)

;~ 		If IsArray($aVersion) Then
;~ 			If(_ArraySearch($aVersion, $sVersion) > 0) Then
;~ 				$iVersion = 1;
;~ 			EndIf
;~ 		EndIf
;~ 	EndIf

	Local $hGUIapropos = GUICreate("A propos")

    Local $iIdApropos = GUICtrlCreateLabel('A propos de "Boîte A Outils"', 80, 10, 300)
	GUICtrlSetFont($iIdApropos, 12, 800)
	GUICtrlCreateLabel("Version "& $sVersion,10, 45)
	If $iVersion = 1 Then
		GUICtrlCreateLabel("Nouvelle version disponible !",220, 45)
		GUICtrlSetColor(-1, $COLOR_RED)
	EndIf
	GUICtrlCreateLabel('"Boîte A Outils" est un logiciel d' & "'" & 'aide au dépannage informatique'&@CRLF&"Licence : GPL-3.0-or-later"&@CRLF&"https://www.isergues.fr"&@CRLF&"Copyright 2019 - 2021 Bastien Rouches", 10, 75)
 	GUICtrlCreateLabel("Aller sur le site du logiciel : ", 40, 145)
	local $iIdLien = GUICtrlCreateButton("https://boiteaoutils.xyz", 200, 140, 190)
	GUICtrlCreateLabel("Encourager le développeur : ", 40, 170)
	local $iIdDon = GUICtrlCreateButton("Faire un don", 200, 165, 190)

 	GUICtrlCreateLabel("Licences des logiciels :"&@CRLF&""&@CRLF&"DWService Agent : MPLv2"&@CRLF&"Chocolatey Open Source : Apache 2.0"&@CRLF&"Snappy Driver Installer Origin : GNU General Public License"&@CRLF&"Windows-ISO-Downloader : Heidoc"&@CRLF&"PrivaZer : Licence jointe avec le logiciel"&@CRLF&"7zip :  GNU LGPL"&@CRLF&"Smartmontools :  GNU GPL"&@CRLF&"SetUserFTA : Freeware"&@CRLF&"Proaxive : GNU-GPL"&@CRLF&""&@CRLF&""&@CRLF&"Les logiciels personnalisables par l'utilisateur sont soumis à leurs licences"&@CRLF&"respectives", 10, 195)
	GUISetState(@SW_SHOW)

	Local $iIdAc

	While 1
		$iIdAc = GUIGetMsg()
		Switch $iIdAc

			Case $GUI_EVENT_CLOSE
				ExitLoop

			Case $iIdLien
				ShellExecute("https://boiteaoutils.xyz")

			Case $iIdDon
				ShellExecute("https://www.paypal.com/biz/fund?id=9DCB6M93TUS3C&locale.x=fr_FR")

		EndSwitch
	WEnd

	GUIDelete()

EndFunc