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
	If(FileExists($sConfig)) Then

		Local $aSections = IniReadSectionNames($sConfig)
		if @error Then
			_Erreur("Fichier 'config.ini' erroné")
		EndIf

		If $aSections[1]<>"Parametrages" Then
			_Erreur("Section 'Parametrages' absente dans le fichier 'config.ini'")
		EndIf

		If $aSections[2]<>"Installation" Then
			_Erreur("Section 'Installation' absente dans le fichier 'config.ini'")
		EndIf

		If $aSections[3]<>"BureauDistant" Then
			_Erreur("Section 'BureauDistant' absente dans le fichier 'config.ini'")
		EndIf

		If $aSections[4]<>"Desinfection" Then
			_Erreur("Section 'Desinfection' absente dans le fichier 'config.ini'")
		EndIf

		If $aSections[5]<>"FTP" Then
			_Erreur("Section 'FTP' absente dans le fichier 'config.ini'")
		EndIf
	Else
		; Création du fichier config.ini
		IniWriteSection($sConfig,"Parametrages", "Dossier=Rapport"&@LF&"Icones=1"&@LF&"Restauration=0"&@CRLF)

		IniWriteSection($sConfig,"Installation", "Defaut=GoogleChrome LibreOffice-fresh K-LiteCodecPackFull 7Zip"&@LF&"1=Internet GoogleChrome Firefox Opera Safari Thunderbird"&@LF&"2=Bureautique OpenOffice LibreOffice-fresh"&@LF&"3=Multimedia K-LiteCodecPackFull Skype VLC Paint.net GoogleEarth GoogleEarthPro iTunes"&@LF&"4=Divers 7Zip AdobeReader CCleaner CDBurnerXP Defraggler ImgBurn JavaRuntime TeamViewer"&@CRLF)

		IniWriteSection($sConfig,"BureauDistant", "Agent=https://www.dwservice.net/download/dwagent_x86.exe"&@LF&"Mail=votreadressemail@domaine.fr"&@CRLF)

		IniWriteSection($sConfig,"Desinfection", "Desinstalleur=UninstallView"&@LF&"Programmes de desinfection=RogueKiller AdwCleaner MalwareByte ZHPCleaner"&@CRLF)

		IniWriteSection($sConfig, "FTP", "Adresse="&@LF&"Utilisateur="&@LF&"Port=21"&@LF&"DossierRapports=/www/rapports/"&@LF&"DossierSFX=/www/dl/"&@LF&"DossierSuivi=/www/suivi/"&@CRLF)

		TrayTip("Premier lancement", "Merci de compléter le fichier de configuration", 30)
		ShellExecuteWait($sConfig)
	EndIf

	If(FileExists($sScriptDir & "\Liens\") = 0) Then _Erreur('Dossier "Liens" manquant')

EndFunc

Func _PremierLancement()

	Local $hGUINom = GUICreate("Client", 400, 200)
	GUICtrlCreateLabel('Entrez le nom du client :',10, 15)
	Local $iNomTmp = GUICtrlCreateInput(@UserName, 130, 12, 250)
	GUICtrlCreateLabel('(Indiquez "Tech" suivi de votre nom pour la version Technicien)', 10, 40)

	Local $aSuivi = _FileListToArrayRec($sScriptDir & "\Cache\Suivi\", "*.txt")
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
				ExitLoop

			Case $iIDValider
				_FichierCache("PremierLancement", _Now())
				If(GUICtrlRead($iIDCombo) <> "Aucun") Then
					_FichierCache("Suivi", GUICtrlRead($iIDCombo))
					_DebutIntervention(GUICtrlRead($iIDCombo))
				EndIf
				ExitLoop

		EndSwitch
	WEnd

	$sNom = _ChaineSansAccents(GUICtrlRead($iNomTmp))
	$sNom = StringRegExpReplace($sNom, "(?s)[^a-z0-9A-Z-_ ]", "")

	GUIDelete()

	_FichierCache("Client", $sNom)

	 _RapportInfos()

	If $bClose = 1 Then
		$sNom = ""
		_DesinstallerBAO()
	EndIf

	If($iFreeSpace < 30) Then
		Local $sRepnet = MsgBox($MB_YESNOCANCEL, "Nettoyage", "L'espace libre sur le disque " & @HomeDrive & " est seulement de " & $iFreeSpace & " Go." & @CR & "Voulez vous supprimer les fichiers temporaires et les anciennes installations de Windows ?")
		If($sRepnet = 6) Then
			RunWait(@ComSpec & ' /C cleanmgr.exe /LOWDISK /D ' & @HomeDrive, "", @SW_HIDE)
			FileWriteLine($hFichierRapport, "Nettoyage de disque : " & (Round(DriveSpaceFree(@HomeDrive & "\") / 1024, 2) - $iFreeSpace) & " Go libérés")
			FileWriteLine($hFichierRapport, "")
		EndIf

		If @OSVersion = "WIN_10" Or @OSVersion = "WIN_8" Then
			Local $sRepnet = MsgBox($MB_YESNOCANCEL, "Nettoyage avancé", "Voulez vous compresser le dossier WinSXS et supprimer tous les anciens composants Windows ?")
			If($sRepnet = 6) Then
				RunWait(@ComSpec & ' /C Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase')
				RunWait(@ComSpec & ' /C sc stop msiserver & sc stop TrustedInstaller & sc config msiserver start= disabled & sc config TrustedInstaller start= disabled & icacls "%WINDIR%\WinSxS" /save "%WINDIR%\WinSxS_NTFS.acl" /t & takeown /f "%WINDIR%\WinSxS" /r & icacls "%WINDIR%\WinSxS" /grant "%USERDOMAIN%\%USERNAME%":(F) /t & compact /s:"%WINDIR%\WinSxS" /c /a /i * & icacls "%WINDIR%\WinSxS" /setowner "NT SERVICE\TrustedInstaller" /t & icacls "%WINDIR%" /restore "%WINDIR%\WinSxS_NTFS.acl" & sc config msiserver start= demand & sc config TrustedInstaller start= demand')
			EndIf
		EndIf
		FileWriteLine($hFichierRapport, "Nettoyage de disque : " & (Round(DriveSpaceFree(@HomeDrive & "\") / 1024, 2) - $iFreeSpace) & " Go libérés")
		FileWriteLine($hFichierRapport, "")
	Else
		FileWriteLine($hFichierRapport, "Espace disque libre sur " & @HomeDrive & " : " & $iFreeSpace & " Go")
		FileWriteLine($hFichierRapport, "")
	EndIf

	Local $iIcones = IniRead($sConfig, "Parametrages", "Icones", 1)

	If($iIcones = 1) Then
		RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel","{20D04FE0-3AEA-1069-A2D8-08002B30309D}","REG_DWORD",0)
		RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel","{59031a47-3f72-44a7-89c5-5595fe6b30ee}","REG_DWORD",0)
	Endif

	Return $sNom
EndFunc

Func _RapportInfos()
	FileWriteLine($hFichierRapport, "Rapport PC " & @ComputerName & " de " & $sNom & " du " & _NowDate())
	FileWriteLine($hFichierRapport, "")
	FileWriteLine($hFichierRapport, "Informations système")
	$sRetourInfo = _GetInfoSysteme()

	; copie du contenu du dossier à copier
	FileCopy(@ScriptDir & "\A copier\*", $sDossierRapport & "\", 8)

	If($sRetourInfo <> "OK") Then
		FileWriteLine($hFichierRapport, $sInfos)
		Local $sRep = MsgBox(52, "Etat SMART du disque dur", $sRetourInfo & ". Voulez vous continuer ?")
		if($sRep = 7) Then
			FileWriteLine($hFichierRapport, $sRetourInfo)
			Exit(1)
		EndIf
	EndIf

	FileWriteLine($hFichierRapport, $sInfos)

	if _GetSmart() Then

		Local $sDisque, $sAttrib
		Local $aAttrib
		Local $aDisque = MapKeys($aResults)
		Local $aResultsToTxt[]
		Local $aTempr[7]

		For $sDisque In $aDisque

			$aAttrib = MapKeys($aResults[$sDisque])

			For $sAttrib in $aAttrib

				Switch ($sAttrib)

 					Case 1 ; plus pris en compte
						$aTempr[3] = " Taux d'erreur en lecture : " & ($aResults[$sDisque])[$sAttrib]
						If ($aResults[$sDisque])[$sAttrib] > 0 Then
							Local $sRep = MsgBox(52, "Etat SMART du disque dur", "Disque " & $sDisque & " - Taux d'erreur en lecture : " & ($aResults[$sDisque])[$sAttrib])
							if($sRep = 7) Then
								FileWriteLine($hFichierRapport, "Disque " & $sDisque & " - Taux d'erreur en lecture : " & ($aResults[$sDisque])[$sAttrib])
								Exit(1)
							EndIf
						EndIf

					Case 5
						$aTempr[4] = " Nombre de secteurs réalloués : " & ($aResults[$sDisque])[$sAttrib]
						If ($aResults[$sDisque])[$sAttrib] > 0 Then
							Local $sRep = MsgBox(52, "Etat SMART du disque dur", "Disque " & $sDisque & " - Nombre de secteurs réalloués : " & ($aResults[$sDisque])[$sAttrib])
							if($sRep = 7) Then
								FileWriteLine($hFichierRapport, "Alerte SMART du disque " & $sDisque & " - Nombre de secteurs réalloués : " & ($aResults[$sDisque])[$sAttrib])
								Exit(1)
							EndIf
						EndIf

					Case 9
						$aTempr[0] = " Heures de fonctionnement : " & ($aResults[$sDisque])[$sAttrib] & " heures"
						If ($aResults[$sDisque])[$sAttrib] > 10000 Then
							Local $sRep = MsgBox(52, "Etat SMART du disque dur", "Disque " & $sDisque & " - Nombre d'heures de fonctionnement : " & ($aResults[$sDisque])[$sAttrib])
							if($sRep = 7) Then
								FileWriteLine($hFichierRapport, "Alerte SMART du disque " & $sDisque & " - Nombre d'heures de fonctionnement : " & ($aResults[$sDisque])[$sAttrib])
								Exit(1)
							EndIf
						EndIf

					Case 12
						$aTempr[1] = " Nombre de démarrage : " &($aResults[$sDisque])[$sAttrib] & "x"
						If ($aResults[$sDisque])[$sAttrib] > 10000 Then
							Local $sRep = MsgBox(52, "Etat SMART du disque dur", "Disque " & $sDisque & " - Nombre de démarrage : " & ($aResults[$sDisque])[$sAttrib])
							if($sRep = 7) Then
								FileWriteLine($hFichierRapport, "Alerte SMART du disque " & $sDisque & " - Nombre de démarrage : " & ($aResults[$sDisque])[$sAttrib])
								Exit(1)
							EndIf
						EndIf

					Case 194
						$aTempr[2] = " Température du disque : " & ($aResults[$sDisque])[$sAttrib] & "°"
						If ($aResults[$sDisque])[$sAttrib] > 70 Then
							Local $sRep = MsgBox(52, "Etat SMART du disque dur", "Disque " & $sDisque & " - Température : " & ($aResults[$sDisque])[$sAttrib] & "°")
							if($sRep = 7) Then
								FileWriteLine($hFichierRapport, "Alerte SMART du disque " & $sDisque & " - Température : " & ($aResults[$sDisque])[$sAttrib] & "°")
								Exit(1)
							EndIf
						EndIf

					Case 197
						$aTempr[5] = " Nombre de secteurs instables : " & ($aResults[$sDisque])[$sAttrib]
						If ($aResults[$sDisque])[$sAttrib] > 0 Then
							Local $sRep = MsgBox(52, "Etat SMART du disque dur", "Disque " & $sDisque & " - Nombre de secteurs instables : " & ($aResults[$sDisque])[$sAttrib])
							if($sRep = 7) Then
								FileWriteLine($hFichierRapport, "Alerte SMART du disque " & $sDisque & " - Nombre de secteurs instables : " & ($aResults[$sDisque])[$sAttrib])
								Exit(1)
							EndIf
						EndIf

					Case 198
						$aTempr[6] = " Nombre de secteurs incorrigibles : " & ($aResults[$sDisque])[$sAttrib]
						If ($aResults[$sDisque])[$sAttrib] > 0 Then
							Local $sRep = MsgBox(52, "Etat SMART du disque dur", "Disque " & $sDisque & " - Nombre de secteurs incorrigibles : " & ($aResults[$sDisque])[$sAttrib])
							if($sRep = 7) Then
								FileWriteLine($hFichierRapport, "Alerte SMART du disque " & $sDisque & " - Taux d'erreur en lecture : " & ($aResults[$sDisque])[$sAttrib])
								Exit(1)
							EndIf
						EndIf

				EndSwitch

			Next
			$aResultsToTxt[$sDisque] = $aTempr

		Next
		;_debug($aResultsToTxt)
		Local $sResults, $sDisqueS

		Local $aDisqueS = MapKeys($aResultsToTxt)


		For $sDisqueS In $aDisqueS

			FileWriteLine($hFichierRapport, "")
			FileWriteLine($hFichierRapport, "Etat Smart du disque " & $sDisqueS)

			For $j = 0 To 6
				if(($aResultsToTxt[$sDisqueS])[$j] <> "") Then
					FileWriteLine($hFichierRapport, ($aResultsToTxt[$sDisqueS])[$j])
				EndIf
			Next
		Next

	EndIf
	FileWriteLine($hFichierRapport, "")
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

	Local $sFuncRetour = "1"
	Local $hID
	$sNomFichier = @LocalAppDataDir & "\bao\" & $sNomFichier & ".txt"


	If($sValeur = "0") Then ;Mode lecture
		If Not FileExists($sNomFichier) Then _Attention("Le fichier " & $sNomFichier & " n'existe pas")
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
			_Attention("Impossible d'ouvrir " & $sNomFichier)
			$sFuncRetour = 0
		Else
			FileWriteLine($hID, $sValeur)
			FileClose($hID)
		EndIf
	EndIf

	Return $sFuncRetour
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _InfoSysteme
; Description ...:
; Syntax ........:
; Parameters ....:
; Return values..:
; Author.........: Bastien
; Modified ......:
; ===============================================================================================================================
Func _GetInfoSysteme()
	Local $sRetour = "OK"

	; Système d'exploitation
	Dim $Obj_WMIService = ObjGet("winmgmts:\\" & "localhost" & "\root\cimv2")
	Dim $Obj_Services = $Obj_WMIService.ExecQuery("Select * from Win32_OperatingSystem")
	Local $Obj_Item
	For $Obj_Item In $Obj_Services
		$sInfos &= " Système d'exploitation : " & $Obj_Item.Caption & " " & @OSArch & " version " & $Obj_Item.Version & @CRLF
	Next

	; Ordinateur
	Dim $Obj_Services = $Obj_WMIService.ExecQuery("Select * from Win32_ComputerSystem")
	Local $Obj_Item
	For $Obj_Item In $Obj_Services
		$sInfos &= " Fabricant : " & $Obj_Item.Manufacturer & @CRLF
		$sInfos &= " Modèle : " & $Obj_Item.Model & @CRLF
		$sInfos &= " Mémoire vive : " & Round((($Obj_Item.TotalPhysicalMemory / 1024) / 1024), 0) & " Mo" & @CRLF
	Next

	; Processeur
	Dim $Obj_Services = $Obj_WMIService.ExecQuery("Select * from Win32_Processor")
	Local $Obj_Item
	For $Obj_Item In $Obj_Services
		$sInfos &= " Processeur : " & $Obj_Item.Name & @CRLF
		$sInfos &= " Socket : " & $Obj_Item.SocketDesignation & @CRLF
	Next

	; Carte graphique
	Dim $Obj_Services = $Obj_WMIService.ExecQuery("Select * from Win32_VideoController")
	Local $Obj_Item
	For $Obj_Item In $Obj_Services
		$sInfos &= " Carte Graphique : " &$Obj_Item.Name & @CRLF
	Next

	; Disque dur
	Dim $Obj_Services = $Obj_WMIService.ExecQuery("Select * from Win32_DiskDrive")
	Local $Obj_Item
	For $Obj_Item In $Obj_Services
		if $Obj_Item.MediaType = "Fixed hard disk media" Then
			$sInfos &= " Disque dur " & $Obj_Item.Index & " : " & $Obj_Item.Model & " - " & Round($Obj_Item.Size / 1000000000, 0) & " Go - Status " & $Obj_Item.Status & @CRLF
			If $Obj_Item.Status <> "OK" Then
				$sRetour = "L'Etat SMART du disque " & $Obj_Item.Index & " est : " & $Obj_Item.Status
			EndIf
		EndIf
	Next


	Return $sRetour
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _GetSmart()
; Description ...:
; Syntax ........:
; Parameters ....:
; Return values..:
; Author.........: Bastien
; Modified ......:
; ===============================================================================================================================
Func _GetSmart()


	Dim $Obj_WMIService = ObjGet("winmgmts:\\" & "localhost" & "\root\wmi")
		Dim $Obj_Services = $Obj_WMIService.ExecQuery("Select * from MSStorageDriver_FailurePredictData")
		Local $Obj_Item
		Local $aSmart
		Local $aSmartAttribut[]
		Local $i
		Local $bReturn = False
		Local $aNomDisque[2]
		Local $sNomDisque

		; Liste des valeurs SMART pertinentes :
		; ID = 1 Taux d'erreur en lecture annulé car souvent incorrect
		; ID = 5 Nombre de secteur réalloués
		; ID = 9 Heures de fonctionnement
		; ID = 12 Nombre de démarrage
		; ID = 194 Température du disque
		; ID = 197 Nombre de secteurs instables
		; ID = 198 Nombre de secteurs incorrigibles


		For $Obj_Item In $Obj_Services

			Local $aSmartFound = [5,9,12,194,197,198]
			Local $sMax
			Local $sPos
			Local $sMax

			if IsArray($Obj_Item.VendorSpecific) Then
				$bReturn = True
				$aNomDisque = StringRegExp($Obj_Item.InstanceName, 'Ven_(.*)&Prod_(.*)\\',3)
				If(IsArray($aNomDisque) And UBound($aNomDisque) = 2) Then
					$sNomDisque = $aNomDisque[0] & " " & $aNomDisque[1]
				Else
					$aNomDisque = StringRegExp($Obj_Item.InstanceName, 'Disk([A-Za-z0-9]*)',3)
					If(IsArray($aNomDisque)) Then
						$sNomDisque = $aNomDisque[0]
					Else
						$sNomDisque = "non défini"
					EndIf
				EndIf

				$aSmart = $Obj_Item.VendorSpecific

				$sMax = UBound($aSmart) - 1
				For $i=2 To $sMax Step 12
					If _ArrayBinarySearch($aSmartFound, $aSmart[$i]) <> -1 Then
						_ArrayDelete($aSmartFound, "0;" & $aSmart[$i])
						if($aSmart[$i]=9 Or $aSmart[$i]=12) Then
							; calcul POH
							$aSmartAttribut[$aSmart[$i]]=$aSmart[$i+6] * 256 + $aSmart[$i+5]
						Else
							$aSmartAttribut[$aSmart[$i]]=$aSmart[$i+5]
						EndIf

					EndIf
				Next
			EndIf

			$aResults[$sNomDisque]=$aSmartAttribut
		Next

	Return $bReturn

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
	FileSetPos($hFichier, 0, $FILE_BEGIN)
	GUICtrlSetData($iIDEdit, FileRead($hFichier))
	GuiCtrlSendMsg($iIDEdit, $EM_LINESCROLL, 0, GuiCtrlSendMsg($iIDEdit, $EM_GETLINECOUNT, 0, 0))
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
		Local $ret = MsgBox(36, "Continuer ?", $message)
		If($ret = 7) Then Exit
		ClipPut($message)
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

Func _APropos()

	Local $iVersion = 0;

	If(_IsInternetConnected() = 1) Then

		Local $SSource = BinaryToString(InetRead("https://isergues.fr/bao.php", 1), 4)
		Local $aVersion = StringRegExp($SSource, 'Version (.*?)]', 3)

		If IsArray($aVersion) Then
			If(_ArraySearch($aVersion, FileGetVersion ( @ScriptFullPath, $FV_PRODUCTVERSION)) > 0) Then
				$iVersion = 1;
			EndIf
		EndIf
	EndIf

	Local $hGUIapropos = GUICreate("A propos")

    Local $iIdApropos = GUICtrlCreateLabel('A propos de "Boîte A Outils"', 80, 10, 300)
	GUICtrlSetFont($iIdApropos, 12, 800)
	GUICtrlCreateLabel("Version "& FileGetVersion ( @ScriptFullPath, $FV_PRODUCTVERSION),10, 45)
	If $iVersion = 1 Then
		GUICtrlCreateLabel("Nouvelle version disponible !",220, 45)
		GUICtrlSetColor(-1, $COLOR_RED)
	EndIf
	GUICtrlCreateLabel('"Boîte A Outils" est un logiciel d' & "'" & 'aide au dépannage informatique'&@CRLF&"Auteur : Bastien Rouchès""Licence : GPL-3.0-or-later"&@CRLF&"https://www.isergues.fr"&@CRLF&"Copyright 2019 - 2021 Bastien Rouches", 10, 75)
 	GUICtrlCreateLabel("Aller sur le site du logiciel : ", 40, 145)
	local $iIdLien = GUICtrlCreateButton("GitHub", 200, 140, 100)
	GUICtrlCreateLabel("Encourager le développeur : ", 40, 170)
	local $iIdDon = GUICtrlCreateButton("Faire un don", 200, 165, 100)

 	GUICtrlCreateLabel("Licences des logiciels :"&@CRLF&""&@CRLF&"DWService Agent : MPLv2"&@CRLF&"Chocolatey Open Source : Apache 2.0"&@CRLF&"Snappy Driver Installer Origin : GNU General Public License"&@CRLF&"Windows-ISO-Downloader : Heidoc"&@CRLF&"PrivaZer : Licence jointe avec le logiciel"&@CRLF&"7zip :  GNU LGPL"&@CRLF&""&@CRLF&""&@CRLF&"Les logiciels personnalisables par l'utilisateur sont soumis à leurs licences"&@CRLF&"respectives", 10, 195)
	GUISetState(@SW_SHOW)

	Local $iIdAc

	While 1
		$iIdAc = GUIGetMsg()
		Switch $iIdAc

			Case $GUI_EVENT_CLOSE
				ExitLoop

			Case $iIdLien
				ShellExecute("https://github.com/PaysanBarbare/BAO")

			Case $iIdDon
				ShellExecute("https://www.paypal.com/biz/fund?id=9DCB6M93TUS3C")

		EndSwitch
	WEnd

	GUIDelete()

EndFunc