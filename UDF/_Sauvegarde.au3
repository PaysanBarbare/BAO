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

Func _SauvegardeAutomatique()

	_ChangerEtatBouton($iIDAction, "Patienter")

	Local $hGUIsvg = GUICreate("Sauvegarde", 400, 170)
	GUICtrlCreateLabel("Choisissez la source", 10, 10)
	GUICtrlSetData($statusbar, "Recherche en cours")
	GUICtrlSetData($statusbarprogress, 33)
	Local $iIDComboSource = GUICtrlCreateCombo(_WinAPI_ShellGetKnownFolderPath("{5E6C858F-0E22-4760-9AFE-EA3317B67173}"),10, 25, 380)

	Local $aDrive = DriveGetDrive ($DT_ALL)

	For $i = 1 To $aDrive[0]
		If (StringUpper($aDrive[$i]) <> @HomeDrive AND DriveGetType($aDrive[$i]) = "Fixed") Then
			If(FileExists($aDrive[$i] & "\Users")) Then
				Local $aUsers = _FileListToArrayRec($aDrive[$i] & "\Users", "*|Default*;All Users;Public", 2)
				For $k=1 To $aUsers[0]
					GUICtrlSetData($statusbarprogress, 66)
					GUICtrlSetData($iIDComboSource, StringUpper($aDrive[$i]) & "\Users\"& $aUsers[$k])
				Next
			EndIf
		EndIf
	Next

	GUICtrlSetData($statusbar, "")
	GUICtrlSetData($statusbarprogress, 0)

	GUICtrlCreateLabel("Choisissez la destination", 10, 50)
	Local $sFolderD = $sDossierRapport
	Local $iIDInput = GUICtrlCreateInput($sFolderD,10, 65, 280)
	Local $iIDBrowse = GUICtrlCreateButton("Parcourir",300, 63, 90, 25)

	Local $aDrive = DriveGetDrive ($DT_ALL)
	Local $sDossierDesti, $sLetter

;~ 	For $i = 1 To $aDrive[0]
;~ 		If (DriveGetType($aDrive[$i]) = "Removable" Or DriveGetType($aDrive[$i]) = "Fixed") Then
;~ 			If(DriveSpaceFree($aDrive[$i]) > 1000) Then
;~ 				GUICtrlSetData($iIDInput, StringUpper($aDrive[$i]) & " [" & DriveGetLabel($aDrive[$i]) & "] - Espace libre : " & Round((DriveSpaceFree($aDrive[$i]) / 1024), 2) & " Go")
;~ 			EndIf
;~ 		EndIf
;~ 	Next

	Local $iIDCheckBrowser = GUICtrlCreateCheckbox("Sauvegarder les mots de passe de navigateurs", 10, 90)
	Local $iIDCheckMail = GUICtrlCreateCheckbox("Sauvegarder les mots de passe de messagerie", 10, 110)

	Local $iIDButtonDemarrer = GUICtrlCreateButton("Sauvegarder", 100, 140, 90, 25, $BS_DEFPUSHBUTTON)
	Local $iIDButtonAnnuler = GUICtrlCreateButton("Annuler", 210, 140, 90, 25)
	GUISetState(@SW_SHOW)

	Local $eGet = GUIGetMsg()

	While $eGet <> $GUI_EVENT_CLOSE And $eGet <> $iIDButtonAnnuler And $eGet <> $iIDButtonDemarrer
		If $eGet = $iIDComboSource Then
			If(GUICtrlRead($iIDComboSource) = _WinAPI_ShellGetKnownFolderPath("{5E6C858F-0E22-4760-9AFE-EA3317B67173}")) Then
				GUICtrlSetState ($iIDCheckBrowser, $GUI_ENABLE)
				GUICtrlSetState ($iIDCheckMail, $GUI_ENABLE)
			Else
				GUICtrlSetState ($iIDCheckBrowser, $GUI_UNCHECKED)
				GUICtrlSetState ($iIDCheckMail, $GUI_UNCHECKED)
				GUICtrlSetState ($iIDCheckBrowser, $GUI_DISABLE)
				GUICtrlSetState ($iIDCheckMail, $GUI_DISABLE)
			EndIf
		ElseIf $eGet = $iIDBrowse Then
			$sFolderD = FileSelectFolder("Dossier de destination", "")
			GUICtrlSetData($iIDInput, $sFolderD)
		EndIf
		$eGet = GUIGetMsg()
	WEnd

	If($eGet = $iIDButtonDemarrer) Then

		; Sauvegarde session actuelle
		If(GUICtrlRead($iIDComboSource) = _WinAPI_ShellGetKnownFolderPath("{5E6C858F-0E22-4760-9AFE-EA3317B67173}")) Then

			$sLetter = StringLeft(GUICtrlRead($iIDInput), 2)
			Local $iBrowser = 0, $iMail = 0

			If(GUICtrlRead($iIDInput) = $sDossierRapport) Then
				TrayTip("Attention", 'Les fichiers seront sauvegardés dans le dossier "' & $sLetter & "\Sauvegarde " & $sNom & " du " & StringReplace(_NowDate(),"/","") & '"', 10, 2)
			EndIf

			If(GUICtrlRead($iIDCheckBrowser) = $GUI_CHECKED) Then
				$iBrowser = 1
			EndIf

			If(GUICtrlRead($iIDCheckMail) = $GUI_CHECKED) Then
				$iMail = 1
			EndIf

			$sDossierDesti = $sLetter & "\Sauvegarde " & $sNom & " du " & StringReplace(_NowDate(),"/","")

			GUIDelete()

			If($sLetter <> "" And DirCreate($sDossierDesti & '\Autres données\') = 1) Then

				FileWriteLine($hFichierRapport, "Démarrage de la sauvegarde")
				FileWriteLine($hFichierRapport, '  Destination : "' & $sDossierDesti & '"')

				If MapExists($aMenu, "ProduKey") Then
					_Telecharger("ProduKey", ($aMenu["ProduKey"])[2])
					Local $iPidPK = _Executer("ProduKey", '/shtml "' & $sDossierDesti & '\Autres données\ProduKeys.html"')
					ProcessWaitClose($iPidPK)
					If(FileExists($sDossierDesti & '\Autres données\ProduKeys.html')) Then
						FileWriteLine($hFichierRapport, "  Clés de produit copiées")
					Else
						_Attention("Clés de produits non copiées")
					EndIf
				EndIf

				If $iBrowser = 1 And MapExists($aMenu, "&WebBrowserPassView.zip") Then
					_Telecharger("&WebBrowserPassView.zip", ($aMenu["&WebBrowserPassView.zip"])[2])
					TrayTip ( "Aide", 'Cliquez sur "View > HTML Report - All Items"', 10 , 1 )
					Local $iPidW = _Executer("&WebBrowserPassView.zip")
					While(ProcessExists($iPidW))
						If FileExists(@ScriptDir & "\Cache\Download\WebBrowserPassView\report.html") Then
							Sleep(2000)
							FileMove(@ScriptDir & "\Cache\Download\WebBrowserPassView\report.html", $sDossierDesti & "\Autres données\BrowsersPwd.html", 1)
							FileWriteLine($hFichierRapport, "  Mots de passe de navigateurs copiés")
							ProcessClose($iPidW)
						EndIf
					WEnd
;~ 					_Telecharger("WebBrowserPassView", ($aMenu["WebBrowserPassView"])[2])
;~ 					Local $iPidW = _Executer("WebBrowserPassView", '/shtml "' & $sDossierDesti & '\BrowsersPwd.html"')
;~ 					ProcessWaitClose($iPidW)
;~ 					If(FileExists($sDossierDesti & '\BrowsersPwd.html')) Then
;~ 						FileWriteLine($hFichierRapport, "  Mots de passe de navigateurs sauvegardés")
;~ 					Else
;~ 						_Attention("Mots de passe de navigateurs non copiées")
;~ 					EndIf
				EndIf

				If $iMail = 1 And MapExists($aMenu, "MailPassView") Then
					_Telecharger("MailPassView", ($aMenu["MailPassView"])[2])
 					TrayTip ( "Aide", 'Cliquez sur "View > HTML Report - All Items"', 10 , 1 )
 					Local $iPidM = _Executer("MailPassView")
 					While(ProcessExists($iPidM))
 						If FileExists(@ScriptDir & "\Cache\Download\MailPassView\report.html") Then
							Sleep(2000)
 							FileMove(@ScriptDir & "\Cache\Download\MailPassView\report.html", $sDossierDesti & "\Autres données\MailsPwd.html", 1)
 							FileWriteLine($hFichierRapport, "  Mots de passe mail copiés")
 							ProcessClose($iPidM)
 						EndIf
 					WEnd
;~ 					_Telecharger("MailPassView", ($aMenu["MailPassView"])[2])
;~ 					Local $iPidM = _Executer("MailPassView", '/shtml "' & $sDossierDesti & '\MailsPwd.html"')
;~ 					ProcessWaitClose($iPidM)
;~ 					If(FileExists($sDossierDesti & '\MailsPwd.html')) Then
;~ 						FileWriteLine($hFichierRapport, "  Mots de passe des clients de messagerie sauvegardés")
;~ 					Else
;~ 						_Attention("Mots de passe des clients de messagerie non copiées")
;~ 					EndIf
				EndIf

;~ 				If MapExists($aMenu, "MailPassView") Then
;~ 					_Telecharger("MailPassView", ($aMenu["MailPassView"])[2])
;~ 					TrayTip ( "Aide", 'Cliquez sur "View > HTML Report - All Items"', 10 , 1 )
;~ 					Local $iPidM = _Executer("MailPassView")
;~ 					While(ProcessExists($iPidM))
;~ 						If FileExists(@ScriptDir & "\Cache\Download\MailPassView\report.html") Then
;~ 							FileMove(@ScriptDir & "\Cache\Download\MailPassView\report.html", $sDossierDesti & "\MailsPwd.html", 1)
;~ 							FileWriteLine($hFichierRapport, "  Mots de passe mail copiés")
;~ 							ProcessClose($iPidM)
;~ 						EndIf
;~ 					WEnd
;~ 				EndIf

;~ 				If MapExists($aMenu, "WebBrowserPassView") Then
;~ 					_Telecharger("WebBrowserPassView", ($aMenu["WebBrowserPassView"])[2])
;~ 					TrayTip ( "Aide", 'Cliquez sur "View > HTML Report - All Items"', 10 , 1 )
;~ 					Local $iPidW = _Executer("WebBrowserPassView")
;~ 					While(ProcessExists($iPidW))
;~ 						If FileExists(@ScriptDir & "\Cache\Download\WebBrowserPassView\report.html") Then
;~ 							FileMove(@ScriptDir & "\Cache\Download\WebBrowserPassView\report.html", $sDossierDesti & "\BrowsersPwd.html", 1)
;~ 							FileWriteLine($hFichierRapport, "  Mots de passe de navigateurs copiés")
;~ 							ProcessClose($iPidW)
;~ 						EndIf
;~ 					WEnd
;~ 				EndIf

;~ 				If MapExists($aMenu, "#WebBrowserPassView") Then
;~ 					ShellExecute(($aMenu["#WebBrowserPassView"])[2])
;~ 					ClipPut($sDossierDesti & "\MDP navigateurs.txt")
;~ 					_Attention("Merci d'enregistrer les mots de passe dans le dossier " & '"' & $sDossierDesti & '" (CTRL + V)', 1)
;~ 				EndIf

				Local $mListeSVG[]
				$mListeSVG["{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}"] = "Desktop"
				$mListeSVG["{56784854-C6CB-462b-8169-88E350ACB882}"] = "Contacts"
				$mListeSVG["{1777F761-68AD-4D8A-87BD-30B759FA33DD}"] = "Favorites"
				$mListeSVG["{374DE290-123F-4565-9164-39C4925E467B}"] = "Downloads"
				$mListeSVG["{FDD39AD0-238F-46AF-ADB4-6C85480369C7}"] = "Documents"
				$mListeSVG["{33E28130-4E1E-4676-835A-98395C3BC3BB}"] = "Pictures"
				$mListeSVG["{4BD8D571-6D19-48D3-BE97-422220080E43}"] = "Music"
				$mListeSVG["{18989B1D-99B5-455B-841C-AB7C74E4DDFC}"] = "Videos"



				Local $iInc = Round(100/8)

				Local $aKeysDocs = MapKeys($mListeSVG)

				For $sKeys In $aKeysDocs

					GUICtrlSetData($statusbar, " Copie " & _WinAPI_ShellGetKnownFolderPath($sKeys))
					GUICtrlSetData($statusbarprogress, $iInc)
					$iInc = $iInc + Round(100/8)

					If(DriveSpaceFree($sLetter) < DirGetSize(_WinAPI_ShellGetKnownFolderPath($sKeys)) / 1048576) Then
						_Attention("Espace sur le disque " & $sLetter & " insuffisant")
						FileWriteLine($hFichierRapport, '  Dossier "' & _WinAPI_ShellGetKnownFolderPath($sKeys) & '" non sauvegardé : espace disque insuffisant')
					Else
						RunWait(@ComSpec & ' /c robocopy "' & _WinAPI_ShellGetKnownFolderPath($sKeys) & '" "' &  $sDossierDesti & '\' & $mListeSVG[$sKeys] & '" /E')
						FileWriteLine($hFichierRapport, '  Dossier "' & $mListeSVG[$sKeys] & '" : ' & Round(DirGetSize($sDossierDesti & "\" & $mListeSVG[$sKeys]) / (1024 * 1024 * 1024), 2) & " sur " & Round(DirGetSize(_WinAPI_ShellGetKnownFolderPath($sKeys)) / (1024 * 1024 * 1024), 2) & " Go copiés")
					EndIf

				Next

				If(FileExists(@LocalAppDataDir & "\Google\Chrome\User Data\Default\Bookmarks")) Then
					FileCopy(@LocalAppDataDir & "\Google\Chrome\User Data\Default\Bookmarks", $sDossierDesti & "\Autres données\", 1)
					FileWriteLine($hFichierRapport, "  Favoris de Google Chrome sauvegardés")
				EndIf

				If(FileExists(@AppDataDir & "\Mozilla\Firefox\Profiles")) Then
					Local $aTempFF = _FileListToArray(@AppDataDir & "\Mozilla\Firefox\Profiles\", "*", 2)

					For $sTmpDoc In $aTempFF
						If(FileExists(@AppDataDir & "\Mozilla\Firefox\Profiles\" & $sTmpDoc & "\bookmarkbackups")) Then
							DirCopy(@AppDataDir & "\Mozilla\Firefox\Profiles\" & $sTmpDoc & "\bookmarkbackups", $sDossierDesti & "\Autres données\FirefoxBookmarks", 1)
							FileWriteLine($hFichierRapport, "  Marque-pages de Firefox sauvegardés")
						EndIf
					Next
				EndIf

				If(FileExists(@LocalAppDataDir & "\Microsoft\Outlook")) Then
					DirCopy(@LocalAppDataDir & "\Microsoft\Outlook", $sDossierDesti & "\Autres données\Outlook", 1)
					FileWriteLine($hFichierRapport, "  PST de Microsoft Outlook sauvegardés")
				EndIf

				FileWriteLine($hFichierRapport, "")

				FileSetPos($hFichierRapport, 0, $FILE_BEGIN)
				Local $hFichierSauvegarde = FileOpen($sDossierDesti & "\Autres données\Infos sauvegarde.txt", 1)
				FileWrite($hFichierSauvegarde, FileRead($hFichierRapport))

				Local $aListe = _ListeProgrammes()

				FileWriteLine($hFichierSauvegarde, "Programmes installés :")
				For $aProgi in $aListe
					FileWriteLine($hFichierSauvegarde, " - " & $aProgi[0])
				Next
				FileWriteLine($hFichierSauvegarde, "")

				FileWriteLine($hFichierSauvegarde, "Liste des imprimantes installées :")

				Local $iPID1 = Run(@ComSpec & ' /c wmic printer get DriverName, Name, Portname', "", @SW_HIDE, $STDOUT_CHILD)
				ProcessWaitClose($iPID1)
				FileWrite($hFichierSauvegarde, _WinAPI_OemToChar(StdoutRead($iPID1)))

				Local $iPID2 = Run(@ComSpec & ' /c ipconfig /all', "", @SW_HIDE, $STDOUT_CHILD)
				ProcessWaitClose($iPID2)
				FileWrite($hFichierSauvegarde, _WinAPI_OemToChar(StdoutRead($iPID2)))

				FileClose($hFichierSauvegarde)

				FileCreateShortcut($sDossierDesti, $sDossierRapport & "\Sauvegarde.lnk")

				GUICtrlSetData($statusbar, "")
				GUICtrlSetData($statusbarprogress, 0)
				_UpdEdit($iIDEditRapport, $hFichierRapport)
				_ChangerEtatBouton($iIDAction, "Activer")
				If(_FichierCacheExist("Sauvegarde") = 0) Then
					_FichierCache("Sauvegarde", "1")
				EndIf
			Else
				_Attention("Echec de la création du dossier " & $sDossierDesti)
				_ChangerEtatBouton($iIDAction, "Desactiver")
			EndIf
		Else
			$sLetter = StringLeft(GUICtrlRead($iIDInput), 2)
			Local $sSource = GUICtrlRead($iIDComboSource)
			Local $sPos = StringInStr($sSource, "\", 0, -1)
			Local $sUserSlave = StringTrimLeft($sSource, $sPos)

			If(GUICtrlRead($iIDInput) = $sDossierRapport) Then
				$sDossierDesti = $sDossierRapport & "\Sauvegarde " & $sNom & " du " & StringReplace(_NowDate(),"/","")
			Else
				$sDossierDesti =  $sLetter & "\Sauvegarde " & $sUserSlave & " du " & StringReplace(_NowDate(),"/","")
			EndIf

			GUIDelete()


			If($sLetter <> "" And DirCreate($sDossierDesti & '\Autres données\') = 1) Then

				FileWriteLine($hFichierRapport, "Démarrage de la sauvegarde")
				FileWriteLine($hFichierRapport, '  Destination : "' & $sDossierDesti & '"')

				If MapExists($aMenu, "ProduKey") Then
					_Telecharger("ProduKey", ($aMenu["ProduKey"])[2])
					Local $iPidPK = _Executer("ProduKey", '/external /shtml "' & $sDossierDesti & '\Autres données\ProduKeys.html')
					ProcessWaitClose($iPidPK)
					If(FileExists($sDossierDesti & '\Autres données\ProduKeys.html')) Then
						FileWriteLine($hFichierRapport, "  Clés de produit copiées")
					Else
						_Attention("Clés de produits non copiées")
					EndIf
				EndIf

				GUICtrlSetData($statusbar, " Copie " & $sSource & " en cours")
				GUICtrlSetData($statusbarprogress, 50)

				If(DriveSpaceFree($sLetter) < (DirGetSize($sSource) - DirGetSize($sSource & "\Appdata")) / 1048576) Then
					_Attention("Espace sur le disque " & $sLetter & " insuffisant")
					FileWriteLine($hFichierRapport, '  Dossier "' & $sSource & '" non sauvegardé : espace disque insuffisant')
				Else
					RunWait(@ComSpec & ' /c robocopy "' & $sSource & '" "' &  $sDossierDesti & '" /E /XD "' & $sSource & '\Appdata"')
					FileWriteLine($hFichierRapport, '  Dossier "' & $sSource & '" : ' & Round(DirGetSize($sDossierDesti) / (1024 * 1024 * 1024), 2) & " sur " & Round((DirGetSize($sSource) - DirGetSize($sSource & "\Appdata")) / (1024 * 1024 * 1024), 2) & " Go copiés")
				EndIf


				If(FileExists($sSource & "\AppData\Local\Google\Chrome\User Data\Default\Bookmarks")) Then
					FileCopy($sSource & "\AppData\Local\Google\Chrome\User Data\Default\Bookmarks", $sDossierDesti & "\Autres données\", 1)
					FileWriteLine($hFichierRapport, "  Favoris de Google Chrome sauvegardés")
				EndIf

				If(FileExists($sSource & "\Roaming\LocalMozilla\Firefox\Profiles")) Then
					Local $aTempFF = _FileListToArray($sSource & "\AppData\Roaming\Mozilla\Firefox\Profiles\", "*", 2)

					For $sTmpDoc In $aTempFF
						If(FileExists($sSource & "\AppData\Roaming\Mozilla\Firefox\Profiles\" & $sTmpDoc & "\bookmarkbackups")) Then
							DirCopy($sSource & "\AppData\Roaming\Local\Mozilla\Firefox\Profiles\" & $sTmpDoc & "\bookmarkbackups", $sDossierDesti & "\Autres données\FirefoxBookmarks", 1)
							FileWriteLine($hFichierRapport, "  Marque-pages de Firefox sauvegardés")
						EndIf
					Next
				EndIf

				If(FileExists($sSource & "\AppData\Local\Microsoft\Outlook")) Then
					DirCopy($sSource& "\AppData\Local\Microsoft\Outlook", $sDossierDesti & "\Autres données\Outlook", 1)
					FileWriteLine($hFichierRapport, "  PST de Microsoft Outlook sauvegardés")
				EndIf

				FileWriteLine($hFichierRapport, "")

				GUICtrlSetData($statusbar, "")
				GUICtrlSetData($statusbarprogress, 0)
				_UpdEdit($iIDEditRapport, $hFichierRapport)
				_ChangerEtatBouton($iIDAction, "Activer")
				If(_FichierCacheExist("Sauvegarde") = 0) Then
					_FichierCache("Sauvegarde", "1")
				EndIf
			Else
				_Attention("Echec de la création du dossier " & $sDossierDesti)
				_ChangerEtatBouton($iIDAction, "Desactiver")
			EndIf

		EndIf

	Else
		GUIDelete()
		_ChangerEtatBouton($iIDAction, "Desactiver")
	EndIf
EndFunc

Func _CopierSur()
	Local $hGUIcopie = GUICreate("Copie BAO sur support externe", 400, 80)

	Local $iIDCombo = GUICtrlCreateCombo("Choisissez la destination",10, 10, 380)

	Local $aDrive = DriveGetDrive ($DT_ALL)
	Local $sDossierDesti, $sLetter

	For $i = 1 To $aDrive[0]
		If (DriveGetType($aDrive[$i]) = "Removable" Or DriveGetType($aDrive[$i]) = "Fixed") Then
			If StringUpper($aDrive[$i]) <> @HomeDrive Then
				GUICtrlSetData($iIDCombo, StringUpper($aDrive[$i]) & " [" & DriveGetLabel($aDrive[$i]) & "] - Espace libre : " & Round((DriveSpaceFree($aDrive[$i]) / 1024), 2) & " Go")
			EndIf
		EndIf
	Next

	Local $iIDButtonDemarrer = GUICtrlCreateButton("Copier", 100, 40, 90, 25, $BS_DEFPUSHBUTTON)
	Local $iIDButtonAnnuler = GUICtrlCreateButton("Annuler", 210, 40, 90, 25)
	GUISetState(@SW_SHOW)

	Local $eGet = GUIGetMsg()

	While $eGet <> $GUI_EVENT_CLOSE And $eGet <> $iIDButtonAnnuler And $eGet <> $iIDButtonDemarrer
		$eGet = GUIGetMsg()
	WEnd

	If($eGet = $iIDButtonDemarrer And GUICtrlRead($iIDCombo) <> "Choisissez la destination") Then
		$sLetter = StringLeft(GUICtrlRead($iIDCombo), 2)
		GUIDelete()

		$sDossierDesti = $sLetter & "\BAO"
		GUICtrlSetData($statusbar, "Copie en cours")
		RunWait(@ComSpec & ' /c robocopy "' & @ScriptDir & '" "' &  $sDossierDesti & '" /MIR /XD "' & @ScriptDir & '\Cache\Pwd\"')
		GUICtrlSetData($statusbar, "")
		;DirCopy(@ScriptDir, $sDossierDesti, 1)
	Else
		GUIDelete()
	EndIf

EndFunc