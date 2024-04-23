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
		IniWriteSection($sConfig,"Installation", "Moteur=Chocolatey"&@LF&"Defaut=GoogleChrome LibreOffice-fresh k-litecodecpackbasic 7Zip"&@LF&"1=Internet GoogleChrome Firefox Opera Brave Thunderbird"&@LF&"2=Bureautique OpenOffice LibreOffice-fresh OnlyOffice wps-office-free"&@LF&"3=Multimedia k-litecodecpackbasic Skype VLC Paint.net GoogleEarth GoogleEarthPro iTunes"&@LF&"4=Divers 7Zip AdobeReader CCleaner CDBurnerXP Defraggler FoxitReader ImgBurn JavaRuntime TeamViewer"&@CRLF)
		IniWriteSection($sConfig,"BureauDistant", "Agent=DWAgent"&@LF&"Mail=votreadressemail@domaine.fr"&@CRLF)
		IniWriteSection($sConfig,"Desinfection", "Programmes de desinfection=Privazer RogueKiller AdwCleaner MalwareByte ZHPCleaner EsetOnlineScanner UserDiag1"&@CRLF)
		IniWriteSection($sConfig, "Associations", "Defaut=0,0,0,0"&@CRLF)
		IniWriteSection($sConfig, "FTP", "Protocol=sftp"&@LF&"Adresse="&@LF&"Utilisateur="&@LF&"Port=22"&@LF&"DossierRapports=/www/rapports/"&@LF&"DossierSFX=/www/dl/"&@LF&"DossierSuivi=/www/suivi/"&@LF&"DossierCapture=/www/capture/"&@CRLF)
	EndIf

EndFunc

Func _SaveConfig($sSociete, $sDossierRapport, $iIcones, $sRestauration, $sBD, $sMailBD, $sFTPProtocol, $sFTPAdresse, $sFTPPort, $sFTPUser, $sFTPDossierRapports, $sFTPDossierSFX, $sFTPDossierSuivi, $sFTPDossierCapture, $sListeProgdes, $sListeTech)
	Local $bRetour = True, $aTMPDes, $sErr
	If $sSociete = "" Or $sDossierRapport = "" Or $sListeProgdes = "" Then
		$bRetour = False
		_Attention('Les champs "Nom de votre entreprise", "Nom du dossier rapport" et "Désinfection antivirale" ne peuvent être vide')
	EndIf
	$aTMPDes = _ArrayFromString($sListeProgdes, " ")
	For $sdes In $aTMPDes
		If Not MapExists($aMenu, $sdes) Then
			$sErr &= " - " & $sdes & @CRLF
		EndIf
	Next

	If $sErr <> "" Then
		$bRetour = False
		_Attention('Erreur : Ces logiciels ne sont pas présents dans le menu "Logiciels" de BAO :' & @CRLF & $sErr)
	Else
		IniWriteSection($sConfig,"Parametrages", "Societe="&$sSociete&@LF&"Dossier="&$sDossierRapport&@LF&"Icones="&$iIcones&@LF&"Restauration="&$sRestauration)
		IniWriteSection($sConfig,"BureauDistant", "Agent="&$sBD&@LF&"Mail="&$sMailBD)
		IniWriteSection($sConfig,"Desinfection", "Programmes de desinfection="&$sListeProgdes)
		IniWriteSection($sConfig, "FTP", "Protocol="&$sFTPProtocol&@LF&"Adresse="&$sFTPAdresse&@LF&"Utilisateur="&$sFTPUser&@LF&"Port="&$sFTPPort&@LF&"DossierRapports="&$sFTPDossierRapports&@LF&"DossierSFX="&$sFTPDossierSFX&@LF&"DossierSuivi="&$sFTPDossierSuivi&@LF&"DossierCapture="&$sFTPDossierCapture)
		If $sListeTech <> "" Then
			IniWrite($sConfig, "Parametrages", "Techniciens", $sListeTech)
		EndIf
	EndIf

	Return $bRetour

EndFunc

Func _SaveConfigInstallation($sListeSoftsDefaut, $sListeSoftsInternet, $sListeSoftsBureautique, $sListeSoftsMultimedia, $sListeSoftsDivers, $sMoteur)

	IniWriteSection($sConfig,"Installation", "Moteur="&$sMoteur&@LF&"Defaut="&$sListeSoftsDefaut&@LF&"1="&$sListeSoftsInternet&@LF&"2="&$sListeSoftsBureautique&@LF&"3="&$sListeSoftsMultimedia&@LF&"4="&$sListeSoftsDivers)

EndFunc

Func _SaveResetConfig($sMoteur)

	If $sMoteur = "Winget" Then
		IniWriteSection($sConfig,"Installation", "Moteur=Winget"&@LF&"Defaut=Google.Chrome TheDocumentFoundation.LibreOffice CodecGuide.K-LiteCodecPack.Basic 7zip.7zip"&@LF&"1=Internet Google.Chrome Mozilla.Firefox Opera.Opera Brave.Brave Mozilla.Thunderbird"&@LF&"2=Bureautique Apache.OpenOffice TheDocumentFoundation.LibreOffice ONLYOFFICE.DesktopEditors Kingsoft.WPSOffice"&@LF&"3=Multimedia CodecGuide.K-LiteCodecPack.Basic Microsoft.Skype VideoLAN.VLC dotPDN.paintdotnet Google.EarthPro Apple.iTunes"&@LF&"4=Divers 7zip.7zip Adobe.Acrobat.Reader.64-bit Piriform.CCleaner Piriform.Defraggler Foxit.FoxitReader LIGHTNINGUK.ImgBurn Oracle.JavaRuntimeEnvironment TeamViewer.TeamViewer"&@CRLF)
	Else
		IniWriteSection($sConfig,"Installation", "Moteur=Chocolatey"&@LF&"Defaut=GoogleChrome LibreOffice-fresh k-litecodecpackbasic 7Zip"&@LF&"1=Internet GoogleChrome Firefox Opera Brave Thunderbird"&@LF&"2=Bureautique OpenOffice LibreOffice-fresh OnlyOffice wps-office-free"&@LF&"3=Multimedia k-litecodecpackbasic Skype VLC Paint.net GoogleEarth GoogleEarthPro iTunes"&@LF&"4=Divers 7Zip AdobeReader CCleaner CDBurnerXP Defraggler FoxitReader ImgBurn JavaRuntime TeamViewer"&@CRLF)
	EndIf

EndFunc

Func _PremierLancement()

	Local $hGUINom = GUICreate("Choix du mode", 520, 265)
	Local $iIDTabMode = GUICtrlCreateTab(10, 10, 500, 220)
	Local $iIDTabModeClient = GUICtrlCreateTabItem("Client")
	Local $aSuivi = _FileListToArrayRec(@ScriptDir & "\Rapports\Nouvelle\", "*.bao")
	Local $aSuivi2 = _FileListToArrayRec(@ScriptDir & "\Rapports\En cours\", "*.bao")
	Local $iIDCombo = -1
	Local $iTech

	GUICtrlCreateGroup("Choix de l'intervention", 20, 40, 360, 80)
	GUICtrlSetFont (-1, 9, 800)

	If ($aSuivi <> "" Or $aSuivi2 <> "") And _FichierCacheExist("Suivi") = 0 Then
		GUICtrlCreateLabel('Choisissez le client dans la liste : ',30, 60)
		$iIDCombo = GUICtrlCreateCombo("Aucun",30, 85, 340)
		If ($aSuivi <> "") Then
			For $i=1 To $aSuivi[0]
				GUICtrlSetData($iIDCombo, StringTrimRight("Nouvelle\" & $aSuivi[$i], 4))
			Next
		EndIf
		If ($aSuivi2 <> "") Then
			For $i=1 To $aSuivi2[0]
				GUICtrlSetData($iIDCombo, StringTrimRight("En cours\" & $aSuivi2[$i], 4))
			Next
		EndIf
	Else
		GUICtrlCreateLabel("Aucune intervention disponible", 120, 80)
	EndIf

	;GUICtrlCreateButton("Sélectionner", 110, 115, 180, 25)

	GUICtrlCreateGroup("Création du client", 20, 125, 360, 95)
	GUICtrlSetFont (-1, 9, 800)
	GUICtrlCreateLabel("Nom", 30, 155, 50, 25)
	Local $iNomClient = GUICtrlCreateInput("", 80, 150, 110, 25)
	GUICtrlCreateLabel("Prénom", 205, 155, 50, 25)
	Local $iPrenomClient = GUICtrlCreateInput("", 260, 150, 110, 25)
	GUICtrlCreateLabel("Société", 30, 190, 50, 25)
	Local $iSocieteClient = GUICtrlCreateInput("", 80, 185, 290, 25)

	GUICtrlCreateGroup("Technicien", 390, 40, 110, 180)
	GUICtrlSetFont (-1, 9, 800)

	If $aListeTech <> "" Then
		$iTech = GUICtrlCreateTreeView(390, 60, 105, 150)
		For $tech In $aListeTech
			GUICtrlCreateTreeViewItem($tech, $iTech)
		Next
	Else
		GUICtrlCreateLabel("Aucun Tech trouvé", 400, 60, 90, 25)
	EndIf

	Local $iIDTabModeTech = GUICtrlCreateTabItem("Technicien")
	GUICtrlCreateLabel("Entrez le nom de l'ordinateur :", 160, 100)
	Local $iNomTech = GUICtrlCreateInput(@ComputerName, 160, 130, 200)

	GUICtrlCreateTabItem("")
	Local $iIDValider = GUICtrlCreateButton("Valider", 170, 235, 180, 25, $BS_DEFPUSHBUTTON)
	GUISetState(@SW_SHOW)

	Local $iIdNom, $bClose = 0, $sTech, $sToEnCours

	While 1
		$iIdNom = GUIGetMsg()
		Switch $iIdNom

			Case $GUI_EVENT_CLOSE
				$bClose = 1
				_FichierCache("PremierLancement", _Now())
				ExitLoop

			Case $iIDCombo
				If(GUICtrlRead($iIDCombo) <> "Aucun") Then
					GUICtrlSetState($iNomClient, $GUI_DISABLE)
					GUICtrlSetState($iPrenomClient, $GUI_DISABLE)
					GUICtrlSetState($iSocieteClient, $GUI_DISABLE)
				Else
					GUICtrlSetState($iNomClient, $GUI_ENABLE)
					GUICtrlSetState($iPrenomClient, $GUI_ENABLE)
					GUICtrlSetState($iSocieteClient, $GUI_ENABLE)
				EndIf

			Case $iIDValider
				_FichierCache("PremierLancement", _Now())
				If GUICtrlRead($iIDTabMode, 1) = $iIDTabModeClient Then
					If $iTech > 0 Then
						$sTech = GUICtrlRead($iTech, 1)
					EndIf
					If(GUICtrlRead($iIDCombo) = "Aucun" Or $iIDCombo = -1) Then
						If GUICtrlRead($iNomClient) <> "" Or GUICtrlRead($iSocieteClient) <> "" Then
							If Not _RapportInfosClient($sFileInfosClient, GUICtrlRead($iNomClient), GUICtrlRead($iPrenomClient), GUICtrlRead($iSocieteClient), $sTech) Then
								_FileWriteLog($hLog, "Erreur premier lancement : Infos clients non sauvegardées")
							EndIf
							If GUICtrlRead($iSocieteClient) <> "" Then
								$sNom = _ChaineSansAccents(GUICtrlRead($iSocieteClient))
							Else
								If GUICtrlRead($iPrenomClient) <> "" Then
									$sNom = _ChaineSansAccents(GUICtrlRead($iNomClient) & " " & GUICtrlRead($iPrenomClient))
								Else
									$sNom = _ChaineSansAccents(GUICtrlRead($iNomClient))
								EndIf
							EndIf
							_FichierCache("Proaxive", $sNom & " - " & @ComputerName & " - Rapport intervention.bao")
							_FichierCache("EnCours", @ScriptDir & "\Rapports\En cours\" & StringReplace(StringLeft(_NowCalc(),10), "/", "") & " " & $sNom & " - " & @ComputerName & " - Rapport intervention.bao" )
							ExitLoop
						Else
							_Attention("Merci de saisir au moins le nom du client ou sa société")
						EndIf
					Else
						_SetTech(@ScriptDir & "\Rapports\" & GUICtrlRead($iIDCombo) & ".bao", $sTech)
						$sToEnCours = StringReplace(GUICtrlRead($iIDCombo), "Nouvelle\", "En cours\")
						If StringInStr(GUICtrlRead($iIDCombo), "Nouvelle\") Then
							FileMove(@ScriptDir & "\Rapports\" & GUICtrlRead($iIDCombo) & ".bao", @ScriptDir & "\Rapports\" & $sToEnCours & ".bao", 9)
							FileCopy(@ScriptDir & "\Rapports\" & $sToEnCours & ".bao", $sFileInfosClient)
							_FichierCache("EnCours", @ScriptDir & "\Rapports\" & $sToEnCours & ".bao")
						Else
							FileCopy(@ScriptDir & "\Rapports\" & GUICtrlRead($iIDCombo) & ".bao", $sFileInfosClient)
							_FichierCache("EnCours", @ScriptDir & "\Rapports\" & $sToEnCours & ".bao")
						EndIf
						Local $mInfosClientTmp = _GetInfosClient($sFileInfosClient)
						Local $sTNomClient, $sTPrenomClient, $sTSocieteClient, $sTTracking
						If MapExists($mInfosClientTmp, "LASTNAME") Then $sTNomClient = $mInfosClientTmp["LASTNAME"]
						If MapExists($mInfosClientTmp, "FIRSTNAME") Then $sTPrenomClient = $mInfosClientTmp["FIRSTNAME"]
						If MapExists($mInfosClientTmp, "COMPANY") Then $sTSocieteClient = $mInfosClientTmp["COMPANY"]
						If MapExists($mInfosClientTmp, "TRACKING") Then
							$sTTracking = $mInfosClientTmp["TRACKING"]
							If $sTTracking <> "" Then
								_FichierCache("Suivi", $sTTracking)
								If FileReadLine(@ScriptDir & '\Cache\Suivi\' & $sTTracking & '.txt') = "" Then
									_DebutIntervention($sTTracking)
								EndIf
							EndIf
						EndIf
						If $sTSocieteClient <> "" Then
							$sNom = _ChaineSansAccents($sTSocieteClient)
						Else
							If $sTPrenomClient <> "" Then
								$sTPrenomClient = " " & $sTPrenomClient
							EndIf
							$sNom = _ChaineSansAccents($sTNomClient & $sTPrenomClient)
						EndIf
						FileDelete(@ScriptDir & "\Proaxive\" & GUICtrlRead($iIDCombo) & ".bao")
						_FichierCache("Proaxive", GUICtrlRead($iIDCombo) & ".bao")
						ExitLoop
					EndIf
				Else
					_FichierCache("Technicien", 1)
					If Not _RapportInfosClient($sFileInfosClient, "Tech", GUICtrlRead($iNomTech), $sSociete) Then
						_FileWriteLog($hLog, "Erreur premier lancement : Infos tech non sauvegardées")
					EndIf
					$sNom = _ChaineSansAccents(GUICtrlRead($iNomTech))
					$iModeTech = 1
					ExitLoop
				EndIf

		EndSwitch
	WEnd

	$sNom = StringRegExpReplace($sNom, "(?s)[^a-z0-9A-Z-_ ]", "")

	GUIDelete()

	If $bClose = 1 Then
		_FileWriteLog($hLog, "Fermeture par l'utilisateur : désinstallation de BAO")
		$sNom = ""
		_DesinstallerBAO()
	EndIf

	_FichierCache("Client", $sNom)

	_FileWriteLog($hLog, "--------------------------")
	_FileWriteLog($hLog, "Premier démarrage de BAO : ")
	If $iModeTech = 0 Then
		_FileWriteLog($hLog, "Client : " & $sNom & " - PC : " & @ComputerName)
	Else
		_FileWriteLog($hLog, $sNom & " - PC : " & @ComputerName)
	EndIf

	If $iModeTech = 0 Then
		$sSplashTxt = $sSplashTxt & @LF & "Génération des informations système"
		ControlSetText("Initialisation de BAO (SHIFT = démarrage rapide)", "", "Static1", $sSplashTxt)

		_RapportInfos()

		If StringLeft(@ScriptDir, 2) = "\\" Then
			_ExporterRapport(@ScriptDir & "\Proaxive\" & _FichierCache("Proaxive"))
			_FichierCache("FichierASupprimer", @ScriptDir & "\Proaxive\" & _FichierCache("Proaxive"))
		EndIf
	Else
		_FichierCache("FS_START", $iFreeSpace)
	EndIf

	If($iModeTech = 0 And $iFreeSpace < 30) Then
		Local $sRepnet = MsgBox($MB_YESNOCANCEL, "Nettoyage", "L'espace libre sur le disque " & $HomeDrive & " est seulement de " & $iFreeSpace & " Go." & @CR & "Voulez vous supprimer les fichiers temporaires et les anciennes installations de Windows ?")
		If($sRepnet = 6) Then
			RunWait(@ComSpec & ' /C cleanmgr.exe /LOWDISK /D ' & $HomeDrive, "", @SW_HIDE)
		EndIf

		;If @OSVersion = "WIN_10" Or @OSVersion = "WIN_8" Then
		;	Local $sRepnet = MsgBox($MB_YESNOCANCEL, "Nettoyage avancé", "Voulez vous compresser le dossier WinSXS et supprimer tous les anciens composants Windows ?")
		;	If($sRepnet = 6) Then
		;		RunWait(@ComSpec & ' /C Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase')
		;		RunWait(@ComSpec & ' /C sc stop msiserver & sc stop TrustedInstaller & sc config msiserver start= disabled & sc config TrustedInstaller start= disabled & icacls "%WINDIR%\WinSxS" /save "%WINDIR%\WinSxS_NTFS.acl" /t & takeown /f "%WINDIR%\WinSxS" /r & icacls "%WINDIR%\WinSxS" /grant "%USERDOMAIN%\%USERNAME%":(F) /t & compact /s:"%WINDIR%\WinSxS" /c /a /i * & icacls "%WINDIR%\WinSxS" /setowner "NT SERVICE\TrustedInstaller" /t & icacls "%WINDIR%" /restore "%WINDIR%\WinSxS_NTFS.acl" & sc config msiserver start= demand & sc config TrustedInstaller start= demand')
		;	EndIf
		;EndIf
		_Attention((Round(DriveSpaceFree($HomeDrive & "\") / 1024, 2) - $iFreeSpace) & " Go libérés")
	EndIf

	If($iModeTech = 0 And $iIcones = 1) Then
		_FileWriteLog($hLog, "Ajout des icones sur le bureau")
		RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel","{20D04FE0-3AEA-1069-A2D8-08002B30309D}","REG_DWORD",0)
		RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel","{59031a47-3f72-44a7-89c5-5595fe6b30ee}","REG_DWORD",0)
		ControlSend('Program Manager', '', '', '{F5}')
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
			GuiFlatButton_SetColors($iIDBouton, 0x0078d7, 0xffffff, 0x0078d7)
			GUICtrlSetState($iIDBouton, 64)
			;GUICtrlSetColor($iIDBouton, $COLOR_GREEN)

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
			_Attention("Le fichier " & $sNomFichier & " n'existe pas. Il est conseillé de réintialiser BAO")
			_FileWriteLog($hLog, 'Erreur : "' & $sNomFichier & '" manquant')
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
			_Attention("Le fichier " & $sNomFichier & " n'a pas pu être ouvert. Il est conseillé de réintialiser BAO")
			_FileWriteLog($hLog, 'Erreur : "' & $sNomFichier & '" impossible à ouvrir')
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
	ShellExecute(@DesktopDir & '\BAO.lnk')
	Exit
EndFunc

Func _UpdateEverySec()
	$aMemStats = MemGetStats()
	GUICtrlSetData($iIDRAMlibre, "Utilisation mémoire vive : " & $aMemStats[$MEM_LOAD] & '%')
	GUICtrlSetData ($sHeure, @MDAY &"/"& @MON &"/"& @YEAR &" - "& @HOUR &":"& @MIN)
EndFunc

Func _UpdateEveryMin()

	If(GUICtrlRead($iIDCheckboxwu) = $GUI_CHECKED) Then
		Run(@ComSpec & ' /c net stop wuauserv & net stop bits & net stop dosvc', '', @SW_HIDE)
	EndIf

	$iFreeSpacech = $iFreeSpace
	_CalculFS()
	If($iFreeSpacech <> $iFreeSpace) Then
		GUICtrlSetData($iIDespacelibre, $HomeDrive & " " & $iFreeSpace & " Go libre sur " & $iTotalSpace & " Go")
		$iFreeSpace = $iFreeSpacech
	EndIf

	If $iModeTech = 0 And _FichierCacheExist("Supervision") = 1 Then
		_SendCaptureLocal()
	EndIf


EndFunc

Func _UpdateSupervision()
	If $iModeTech = 0 And _FichierCacheExist("Supervision") = 1 Then
		_SendCapture()
	ElseIf $iModeTech = 1 Then
		_CreerIndexSupervisionLocal()
	EndIf
EndFunc

Func _ActivationAutologon($sDomaine, $sClientMdp = "")
	Local $sSubKey, $sAutoUser, $sMdps
	_FileWriteLog($hLog, 'Activation Autologon')
	_UpdEdit($iIDEditLog, $hLog)
	$sSubKey = RegEnumKey("HKEY_USERS\.DEFAULT\Software\Microsoft\IdentityCRL\StoredIdentities", 1)
	If $sSubKey = @UserName Then
		$sAutoUser = "MicrosoftAccount\" & $sSubKey
	Else
		$sAutoUser = @UserName
	EndIf

	If $sClientMdp = "" Then
		$sMdps = InputBox("Mot de passe de session", "Entrez votre mot de passe de session pour" & @CRLF & '"' & $sAutoUser & '"', "", "*")
	Else
		$sMdps = $sClientMdp
	EndIf

	If $sMdps <> "" Then
		$sDomaine = RegRead($HKLM & "\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters", "Domain")
		RegWrite($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","AutoAdminLogon","REG_SZ", 1)
		RegWrite($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","DefaultUserName","REG_SZ", @UserName)
		RegWrite($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","DefaultPassword","REG_SZ", $sMdps)
		If($sDomaine <> "") Then
			RegWrite($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","DefaultDomain","REG_SZ", $sDomaine)
		EndIf
		_FichierCache("Autologon", 1)
	Else
		GUICtrlSetState($iIDAutologon, $GUI_UNCHECKED)
		_FichierCache("Autologon", 2)
	EndIf
EndFunc

Func _DesactivationAutologon($sDomaine)
	_FileWriteLog($hLog, 'Désactivation Autologon')
	_UpdEdit($iIDEditLog, $hLog)
	RegWrite($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","AutoAdminLogon","REG_SZ", 0)
	RegDelete($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","DefaultUserName")
	RegDelete($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","DefaultPassword")
	If($sDomaine <> "") Then
		RegDelete($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","DefaultDomain")
	EndIf
	_FichierCache("Autologon", 2)
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

	Local $hGUIapropos = GUICreate("A propos", 400, 450)

    Local $iIdApropos = GUICtrlCreateLabel('A propos de "Boîte A Outils"', 80, 10, 300)
	GUISetFont(Default, Default, Default, "Courrier New")
	GUICtrlSetFont($iIdApropos, 12, 800)
	GUICtrlCreateLabel("Version "& $sVersion,10, 45)
	If $iVersion = 1 Then
		GUICtrlCreateLabel("Nouvelle version disponible !",220, 45)
		GUICtrlSetColor(-1, $COLOR_RED)
	EndIf
	GUICtrlCreateLabel('"Boîte A Outils" est un logiciel d' & "'" & 'aide au dépannage informatique'&@CRLF&"Licence : GPL-3.0-or-later"&@CRLF&"https://www.isergues.fr"&@CRLF&"Copyright 2019 - " & @YEAR & " Bastien Rouches", 10, 75)
 	GUICtrlCreateLabel("Aller sur le site du logiciel : ", 40, 145)
	local $iIdLien = GuiFlatButton_Create("https://boiteaoutils.xyz", 200, 140, 170, 22)
	GUICtrlCreateLabel("Encourager le développeur : ", 40, 170)
	local $iIdDon = GuiFlatButton_Create("Faire un don", 200, 165, 170, 22)

	GUICtrlCreateGroup("Licences des logiciels :", 10, 195, 380, 200)
	GUICtrlSetFont (-1, 9, 800)
	Local $listlog = GUICtrlCreateList("DWService Agent : MPLv2", 20, 215, 360, 180)
	GUICtrlSetData($listlog, "Chocolatey Open Source : Apache 2.0|Snappy Driver Installer Origin : GNU General Public License|Windows-ISO-Downloader : Heidoc|PrivaZer : Licence jointe avec le logiciel|7zip :  GNU LGPL|Smartmontools :  GNU GPL|SetUserFTA : Freeware|Proaxive : GNU-GPL|UserDiag : https://userdiag.com/cgu")
 	GUICtrlCreateLabel("Les logiciels personnalisables par l'utilisateur sont soumis à leurs licences"&@CRLF&"respectives", 20, 410)
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