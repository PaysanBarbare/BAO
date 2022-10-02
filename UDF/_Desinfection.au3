#cs

Copyright 2019-2020 Bastien Rouches

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

Func _ListeProgrammes()

	Local $act_key, $act_name, $sIcon, $iIDIcon = 0,$sUninstallString, $sQuietUninstallString, $sInstallDate, $system_component, $aVirg, $iWindowsInstaller
	Local $count, $tab = 1, $all_keys[0][9]

	Local $keys[2]
	$keys[0] = "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
	$keys[1] = "HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall"

	If(@OSArch = "X64") Then
		ReDim $keys[4]
		$keys[2] = "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
		$keys[3] = "HKLM64\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
	EndIf

	For $key in $keys
		$count = 1
		While 1
			$act_key = RegEnumKey ($key, $count)
			;MsgBox(0,"",$key & "\" & $act_key)

			If @error <> 0 then ExitLoop
			$act_name = RegRead ($key & "\" & $act_key, "DisplayName")
			$system_component = RegRead ($key & "\" & $act_key, "SystemComponent")
			$act_name = StringReplace ($act_name, " (remove only)", "")
			$sIcon = RegRead ($key & "\" & $act_key, "DisplayIcon")
			$iIDIcon = 0

			if($sIcon = "") Then
				$sIcon = "shell32.dll"
			EndIf

			$sUninstallString = RegRead ($key & "\" & $act_key, "UninstallString")
			$sQuietUninstallString = RegRead ($key & "\" & $act_key, "QuietUninstallString")
			$sInstallDate = RegRead ($key & "\" & $act_key, "InstallDate")
			$iWindowsInstaller = RegRead ($key & "\" & $act_key, "WindowsInstaller")
			;MsgBox(0,"",$act_name)

			If $act_name <> "" And $system_component <> "1" And _ArraySearch($all_keys, $act_name,0,0,0,0,0,0) = -1 Then
				ReDim $all_keys[$tab][9]

				If($sIcon = "shell32.dll") Then
					Local $hSearch = FileFindFirstFile(@WindowsDir & "\Installer\" & $act_key & "\" & "*.ico")

					 If $hSearch <> -1 Then
						$sIcon = @WindowsDir & "\Installer\" & $act_key & "\" & FileFindNextFile($hSearch)
					 Else
						$hSearch = FileFindFirstFile(@WindowsDir & "\Installer\" & $act_key & "\" & "*.exe")
						 If $hSearch <> -1 Then
							$sIcon = @WindowsDir & "\Installer\" & $act_key & "\" & FileFindNextFile($hSearch)
						Else
							$iIDIcon = 23
						EndIf
					 EndIf
					 FileClose($hSearch)
				Else
					$aVirg = StringSplit($sIcon, ",")
					if(@error = 0 And $aVirg[0] > 1) Then
						$sIcon = StringReplace($aVirg[1], '"',"")
						$iIDIcon = $aVirg[2]
					EndIf
				EndIf

				$all_keys[$tab-1][0] = $act_name
				$all_keys[$tab-1][1] = $sIcon
				$all_keys[$tab-1][2] = $iIDIcon
				$all_keys[$tab-1][3] = $sUninstallString
				$all_keys[$tab-1][4] = $sQuietUninstallString
				$all_keys[$tab-1][5] = $sInstallDate
				$all_keys[$tab-1][6] = $iWindowsInstaller
				$all_keys[$tab-1][7] = $act_key
				$all_keys[$tab-1][8] = $key & "\" & $act_key

				$tab = $tab + 1
			EndIf
			$count = $count + 1
		WEnd

	Next
	_ArraySort($all_keys,0,0,0,0)
	Return $all_keys

EndFunc

Func _Nettoyage()

	Local $iRet = 0
	_ChangerEtatBouton($iIDAction, "Patienter")

	If _FichierCacheExist("Desinfection") = 0 Then
		_FichierCache("Desinfection", $iIDAction)
	EndIf

	While 1
		$iRet = _Desinstalleur()
		If $iRet = 0 Then
			ExitLoop
		EndIf
	WEnd

	_CalculProgDesinstallation()
	_UpdEdit($iIDEditLogDesinst, $sFileDesinstallation)
	_ChangerEtatBouton($iIDAction, "Activer")

EndFunc

Func _Desinstalleur()

	Local $retour = 0, $ipid, $iLabelProg, $iPerc, $sOutput, $iErreur = 0, $sEchecs, $sRepReg, $iPosExe
	Local $aListeProgInst = _ListeProgrammes()
	Local $sBlacklist = @ScriptDir & "\Config\Blacklist.txt", $aBList, $hBlack
	Local $aItems[0][5], $iIDBDes, $iIDBSupp, $iIDBAdd, $iIDBMod, $iIDBAct, $iIDBQuit

	If(FileExists($sBlacklist)) Then
		$aBList = FileReadToArray($sBlacklist)
	Else
		$hBlack = FileOpen($sBlacklist, 1)
		FileClose($hBlack)
	EndIf

	Local $hGUIDesintalleur = GUICreate("Sélection des programmes à désinstaller", 800, 600)
	Local $idTreeView = GUICtrlCreateTreeView(10, 10, 585, 580, BitOR($TVS_CHECKBOXES, $TVS_FULLROWSELECT))
	_GUICtrlTreeView_BeginUpdate($idTreeView)
	Local $iNBProginst = UBound($aListeProgInst)
	ReDim $aItems[$iNBProginst][5]
	For $a = 1 To $iNBProginst
		$aItems[$a-1][0] = GUICtrlCreateTreeViewItem($a - 1 & " - " & $aListeProgInst[$a-1][0], $idTreeView)
		_GUICtrlTreeView_SetIcon($idTreeView, -1, $aListeProgInst[$a-1][1], $aListeProgInst[$a-1][2])
		If _ArraySearch($aBList, $aListeProgInst[$a-1][0]) <> -1 Then
			GUICtrlSetState($aItems[$a-1][0], $GUI_CHECKED)
		EndIf
		$aItems[$a-1][1] = GUICtrlCreateContextMenu($aItems[$a-1][0])
		$aItems[$a-1][2] = GUICtrlCreateMenuItem("Désinstaller", $aItems[$a-1][1])
		$aItems[$a-1][3] = GUICtrlCreateMenuItem("Supprimer l'entrée du registre", $aItems[$a-1][1])
		$aItems[$a-1][4] = GUICtrlCreateMenuItem("Ajouter à la blacklist", $aItems[$a-1][1])
	Next
	_GUICtrlTreeView_EndUpdate($idTreeView)

	$iIDBDes = GUICtrlCreateButton("Désinstaller", 605, 10, 185, 25)
	$iIDBAdd = GUICtrlCreateButton("Ajouter à la blacklist", 605, 40, 185, 25)
	$iIDBMod = GUICtrlCreateButton("Modifier la blacklist", 605, 70, 185, 25)
	$iIDBAct = GUICtrlCreateButton("Actualiser la liste", 605, 100, 185, 25)

	$iIDBQuit = GUICtrlCreateButton("Quitter", 605, 130, 185, 25)

	GUISetState(@SW_SHOW)

	Local $idMsgDes = GUIGetMsg()

	While $idMsgDes <> $GUI_EVENT_CLOSE And $idMsgDes <> $iIDBQuit

		Switch $idMsgDes

			Case $iIDBDes

				Local $sRange, $iContinue = 0
				For $b = 1 To UBound($aItems)

					;GUICtrlSetData($iProgress, $iPerc)
					If(BitAND(GUICtrlRead($aItems[$b-1][0]), $GUI_UNCHECKED)) Then
						;_Attention($aListeProgInst[$b-1][0] & " " & GUICtrlRead($aItems[$b-1][0], 1))
						$sRange = $sRange & $b - 1 & ";"
						;_Attention($aListeProgInst[$b-1][0] & " " & ($b-1))
					Else
						$iContinue = 1
					EndIf
				Next

				if $iContinue = 1 Then

					_FileWriteLog($hLog, 'Désinstallation silentieuse des logiciels')

					Local $hUninstProg = GUICreate("Désinstallation en cours ...", 300, 100, @DesktopWidth - 400, @DesktopHeight - 250)
					$iLabelProg = GUICtrlCreateLabel("", 10, 10, 280, 25)
					Local $iProgress = GUICtrlCreateProgress(10, 40, 280, 20)
					Local $iButtonSuivant = GUICtrlCreateButton("Passer au suivant", 100, 70, 100)
					GUICtrlSetState($iButtonSuivant, $GUI_DISABLE)

					GUISetState(@SW_SHOW, $hUninstProg)

					_ArrayDelete($aListeProgInst, StringTrimRight($sRange, 1))

					$iPerc = 0
					Local $iNBItems = UBound($aListeProgInst)

					For $b = 1 To $iNBItems
						$iPerc = Round((100 / $iNBItems) * ($b - 1))
						GUICtrlSetData($iProgress, $iPerc)
						GUICtrlSetData($iLabelProg, "Désinstallation en cours de " & $aListeProgInst[$b-1][0])
						if $aListeProgInst[$b-1][4] <> "" Then
							$ipid = Run(@ComSpec & ' /c "' & $aListeProgInst[$b-1][4] & '"',"", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
						Else
							If $aListeProgInst[$b-1][6] = "1" Then
								$aListeProgInst[$b-1][3] = "MsiExec.exe /X" & $aListeProgInst[$b-1][7] & " /passive /norestart"
							ElseIf(StringLeft($aListeProgInst[$b-1][3], 7) = "MsiExec") Then
								$aListeProgInst[$b-1][3] = StringReplace($aListeProgInst[$b-1][3], "/i", "/x")
								If (StringLeft($aListeProgInst[$b-1][3], 1) = '"') Then
									$aListeProgInst[$b-1][3] = $aListeProgInst[$b-1][3] & ' /passive /norestart'
								Else
									$aListeProgInst[$b-1][3] = '"' & $aListeProgInst[$b-1][3] & '" /passive /norestart'
								EndIf
							ElseIf(StringRight($aListeProgInst[$b-1][3], 10)="/uninstall" Or StringRegExp($aListeProgInst[$b-1][3], "unins00[0-9]{1}.exe")) Then
								If (StringLeft($aListeProgInst[$b-1][3], 1) = '"') Then
									$aListeProgInst[$b-1][3] = $aListeProgInst[$b-1][3] & ' /silent'
								Else
									If StringRight($aListeProgInst[$b-1][3], 10)="/uninstall" Then
										$aListeProgInst[$b-1][3] = '"' & StringReplace($aListeProgInst[$b-1][3], " /uninstall", '" /uninstall /silent')
									Else
										$aListeProgInst[$b-1][3] = '"' & $aListeProgInst[$b-1][3] & '" /silent'
									EndIf
								EndIf
							ElseIf(StringRight($aListeProgInst[$b-1][3], 4)=".exe" Or StringRight($aListeProgInst[$b-1][3], 5)='.exe"') Then
								If (StringLeft($aListeProgInst[$b-1][3], 1) = '"') Then
									$aListeProgInst[$b-1][3] = $aListeProgInst[$b-1][3] & ' /S'
								Else
									$aListeProgInst[$b-1][3] = '"' & $aListeProgInst[$b-1][3] & '" /S'
								EndIf
							ElseIf(StringLeft($aListeProgInst[$b-1][3], 1) <> '"') Then
								$iPosExe = StringInStr($aListeProgInst[$b-1][3], ".exe")
								If $iPosExe <> 0 Then
									$aListeProgInst[$b-1][3] = '"' & _StringInsert($aListeProgInst[$b-1][3], '"', $iPosExe + 3)
								Else
									$iPosExe = StringInStr($aListeProgInst[$b-1][3], "/")
									If $iPosExe <> 0 Then
										$aListeProgInst[$b-1][3] = '"' & _StringInsert($aListeProgInst[$b-1][3], '"', $iPosExe - 2)
									EndIf
								EndIf
							EndIf
							_FileWriteLog($hLog, 'Désinstallation de ' & $aListeProgInst[$b-1][0])
							_FileWriteLog($hLog, 'CMD : ' & $aListeProgInst[$b-1][3])
							$ipid = Run(@ComSpec & ' /c ' & $aListeProgInst[$b-1][3],"", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
						EndIf
						Sleep(500)

						$sOutput = StderrRead($ipid)
						While @error = 0
							; Sort de la boucle si le processus ferme ou si StderrRead retourne une erreur.

							$iErreur = 1
							$sOutput = StderrRead($ipid)
						WEnd
						If $iErreur = 0 Then
							GUICtrlSetState($iButtonSuivant, $GUI_ENABLE)
							Local $idMsgDes2 = GUIGetMsg()
							While($idMsgDes2 <> $iButtonSuivant And $idMsgDes2 <> $GUI_EVENT_CLOSE)
								RegEnumVal($aListeProgInst[$b-1][8],1)
								If @error Then
									ExitLoop
								EndIf
								$idMsgDes2 = GUIGetMsg()
							WEnd
							GUICtrlSetState($iButtonSuivant, $GUI_DISABLE)
						ElseIf $sOutput <> "" Then
							$sEchecs = $sEchecs & $aListeProgInst[$b-1][0] & " : " &  _OEMToAnsi($sOutput) & @LF
						EndIf
						$iErreur = 0
						Sleep(1000)
					Next
					$retour = 1
					GUICtrlSetData($iProgress, 100)
					Sleep(1000)
					GUIDelete($hUninstProg)
					ExitLoop
				Else
					_Attention("Merci de sélectionner au moins 1 élément")
				EndIf

			Case $iIDBAdd
				Local $sRange, $iContinue = 0
				For $b = 1 To UBound($aItems)

					;GUICtrlSetData($iProgress, $iPerc)
					If(BitAND(GUICtrlRead($aItems[$b-1][0]), $GUI_UNCHECKED)) Then
						;_Attention($aListeProgInst[$b-1][0] & " " & GUICtrlRead($aItems[$b-1][0], 1))
						$sRange = $sRange & $b - 1 & ";"
						;_Attention($aListeProgInst[$b-1][0] & " " & ($b-1))
					Else
						$iContinue = 1
					EndIf
				Next

				if $iContinue = 1 Then

					_ArrayDelete($aListeProgInst, StringTrimRight($sRange, 1))

					Local $iNBItems = UBound($aListeProgInst)

					For $b = 1 To $iNBItems
						If _ArraySearch($aBList, $aListeProgInst[$b-1][0]) = -1 Then
							FileWriteLine($sBlacklist, $aListeProgInst[$b-1][0])
							_ArrayAdd($aBList, $aListeProgInst[$b-1][0])
						EndIf
					Next
					_Attention($iNBItems & " element(s) ajouté(s) à la liste noire")
					$retour = 1
					ExitLoop
				Else
					_Attention("Merci de sélectionner au moins 1 élément")
				EndIf

			Case $iIDBMod
				ShellExecuteWait($sBlacklist)
				$aBList = FileReadToArray($sBlacklist)

			Case $iIDBAct
				$retour = 1
				ExitLoop

			Case Else

				For $i = 0 To $iNBProginst - 1
					If $idMsgDes = $aItems[$i][2] Then
						If(StringLeft($aListeProgInst[$i][3], 1) <> '"') Then
							$iPosExe = StringInStr($aListeProgInst[$i][3], ".exe")
							$aListeProgInst[$i][3] = '"' & _StringInsert($aListeProgInst[$i][3], '"', $iPosExe + 3)
						EndIf
						_FileWriteLog($hLog, 'Désinstallation de ' & $aListeProgInst[$i][0])
						_FileWriteLog($hLog, 'CMD : ' & $aListeProgInst[$i][3])
						$ipid = RunWait(@ComSpec & ' /c "' & $aListeProgInst[$i][3] & '"',"", @SW_HIDE)
						Sleep(5000)
						$retour = 1

					ElseIf $idMsgDes = $aItems[$i][3] Then
						$sRepReg = MsgBox($MB_YESNO, "Suppression de " & $aListeProgInst[$i][0], "Voulez supprimer la clé de registre : " & @LF & $aListeProgInst[$i][8])
						If ($sRepReg = 6) Then
							_FileWriteLog($hLog, 'Suppression clé de registre de ' & $aListeProgInst[$i][0])
							_FileWriteLog($hLog, 'REG : ' & $aListeProgInst[$i][8])
							RegDelete($aListeProgInst[$i][8])
							$retour = 1
							Sleep(1000)
						EndIf
					ElseIf $idMsgDes = $aItems[$i][4] Then
						If _ArraySearch($aBList, $aListeProgInst[$i][0]) <> -1 Then
							_Attention($aListeProgInst[$i][0] & " est déjà dans la liste noire")
						Else
							$sRepReg = MsgBox($MB_YESNO, "Ajout de " & $aListeProgInst[$i][0] & " à la blacklist", "Voulez vous ajouter " & $aListeProgInst[$i][0] & " à la liste noire ?")
							If ($sRepReg = 6) Then
								FileWriteLine($sBlacklist, $aListeProgInst[$i][0])
								_ArrayAdd($aBList, $aListeProgInst[$i][0])
							EndIf
						EndIf
					EndIf
				Next
				If $retour = 1 Then
					ExitLoop
				EndIf

		EndSwitch

		$idMsgDes = GUIGetMsg()
	WEnd

	_UpdEdit($iIDEditLog, $hLog)

	GUIDelete($hGUIDesintalleur)

	If $sEchecs <> "" Then
		_Attention("Les programmes suivants n'ont pas été désinstallé : " & @lf & $sEchecs & "Réessayez ou désinstallez-les manuellement", 1)
	EndIf
	Return $retour

EndFunc

Func _CalculProgDesinstallation()
	If($aListeAvSupp <> "") Then
		$hDesinstallation = FileOpen($sFileDesinstallation,2)

		Local $aListeApSupp = _ListeProgrammes()
		$aListeApSupp = _ArrayUnique($aListeApSupp, 0, 0, 0, 0)

		For $sProgAvSupp in $aListeAvSupp
			If _ArraySearch($aListeApSupp, $sProgAvSupp) = -1 Then
				FileWrite($hDesinstallation, $sProgAvSupp & "[BR]")
			EndIf
		Next
		FileClose($hDesinstallation)
	EndIf
EndFunc

Func _NettoyageProg($aButtonDes)
	Local $sNomProgDes = $aButtonDes[$iIDAction]
	Local $iPidret

	If IsString($sNomProgDes) And MapExists($aMenu, $sNomProgDes) Then
		_ChangerEtatBouton($iIDAction, "Patienter")
		If(_Telecharger($aMenu[$sNomProgDes])) Then
			$iPidret = _Executer($sNomProgDes)
			If $iPidret = 0 Then
				_ChangerEtatBouton($iIDAction, "Desactiver")
			ElseIf(_FichierCacheExist($sNomProgDes) = 0) Then
				_FileWriteLog($hLog, "Execution de " & $sNomProgDes)
				_UpdEdit($iIDEditLog, $hLog)
				$iPidt[$sNomProgDes & "n"] = $iPidret
				_FichierCache($sNomProgDes, $iIDAction)
				_ChangerEtatBouton($iIDAction, "Activer")
			Else
				_ChangerEtatBouton($iIDAction, "Activer")
			EndIf
		Else
			_ChangerEtatBouton($iIDAction, "Desactiver")
		EndIf
	ElseIf(FileExists(@ScriptDir & "\Cache\Download\" & $aButtonDes[$iIDAction + 1] & ".bat")) Then
		RunWait(@ComSpec & ' /c ""' & @ScriptDir & "\Cache\Download\" & $aButtonDes[$iIDAction + 1] & '.bat" uninstall"')
		FileDelete(@ScriptDir & "\Cache\Download\" & $aButtonDes[$iIDAction + 1] & ".bat")
	Else
		If FileExists(@ScriptDir & "\Config\" & $aButtonDes[$iIDAction + 1] & "\" & $aButtonDes[$iIDAction + 1] & ".bat") = 0 Then
			_Attention($sNomProgDes & " n'existe pas dans les liens")
		Else
			_Attention('Ce bouton sert à désinstaller "' & $aButtonDes[$iIDAction + 1] & '" après un redémarrage de l' & "'" & 'ordinateur ou un arrêt intempestif de bao')
		EndIf
	EndIf
EndFunc

Func _ResetBrowser()
	_FichierCache("ResetBrowser", $iIDAction)
	_ChangerEtatBouton($iIDAction, "Patienter")

	Local $iNettoyage, $iIE, $iStartFS, $iEndFS, $iLVIE, $iLVCHROME, $iLVEDGE1, $iLVEDGE2, $iLVFIREFOX

	Local $hGUInav = GUICreate("Nettoyage des navigateurs Internet", 600, 350)
	GUICtrlCreateLabel("Choisissez un mode de nettoyage :", 10, 10)
	Local $iID1 = GUICtrlCreateRadio("Manuel (Ouvre les navigateurs 1 par 1)", 60, 30)
	Local $iID2 = GUICtrlCreateRadio("Léger (Supprime cache et historique de tous les profils de chaque navigateur)", 60, 50)
	GUICtrlSetState($iID2, $GUI_CHECKED)
	Local $iID3 = GUICtrlCreateRadio("Modéré (Réinitialise chaque profil, en conservant les favoris et les mots de passe enregistrés)", 60, 70)
	Local $iID4 = GUICtrlCreateRadio("Complet (Supprime le dossier contenant les profils)", 60, 90)
	Local $iID5 = GUICtrlCreateCheckbox("Nettoyer aussi Internet Explorer et MS Edge (ancienne version)", 60, 120)

	GUICtrlCreateLabel("Résultats : ", 10, 150)
	Local $iIDListViewNav = GUICtrlCreateListView("Navigateur|Mode|Résultat", 10, 170, 580, 140)
	_GUICtrlListView_SetColumnWidth($iIDListViewNav, 0, 200)
	_GUICtrlListView_SetColumnWidth($iIDListViewNav, 1, 100)
	_GUICtrlListView_SetColumnWidth($iIDListViewNav, 2, 270)
	$iLVIE = GUICtrlCreateListViewItem("Internet Explorer", $iIDListViewNav)
	$iLVEDGE1 = GUICtrlCreateListViewItem("Microsoft Edge (ancien)", $iIDListViewNav)
	$iLVEDGE2 = GUICtrlCreateListViewItem("Microsoft Edge (nouveau)", $iIDListViewNav)

	RegEnumVal($HKLM & "\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe\",1)
	If @error = 0 Then
		$iLVCHROME = GUICtrlCreateListViewItem("Google Chrome", $iIDListViewNav)
	EndIf

	RegEnumVal($HKLM & "\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\firefox.exe\",1)
	If @error = 0 Then
		$iLVFIREFOX = GUICtrlCreateListViewItem("Mozilla Firefox", $iIDListViewNav)
	EndIf

	Local $iIDButtonDemarrer = GUICtrlCreateButton("Nettoyer", 200, 320, 90, 25, $BS_DEFPUSHBUTTON)
	Local $iIDButtonAnnuler = GUICtrlCreateButton("Quitter", 310, 320, 90, 25)
	GUISetState(@SW_SHOW)

	Local $eGet = GUIGetMsg()

	While $eGet <> $GUI_EVENT_CLOSE And $eGet <> $iIDButtonAnnuler

		If($eGet = $iIDButtonDemarrer) Then
			_FileWriteLog($hLog, "Nettoyage des navigateurs")
			;~ 	If(FileExists(@ScriptDir & "\Outils\ResetBrowser.exe")) Then
			;~ 			FileWriteLine($hFichierRapport, " Nettoyage des navigateurs Internet")
			;~ 			Run(@ScriptDir & "\Outils\ResetBrowser.exe")
			;~ 			_UpdEdit($iIDEditRapport, $hFichierRapport)
			;~ 	Else
			;~ 		_Attention("ResetBrowser.exe n'est pas dans le dossier Outils, Téléchagez le")
			;~ 		ShellExecute("https://www.comment-supprimer.com/telecharger/resetbrowser/")
			;~ 	EndIf
				; Nettoyage des navigateurs

			_BrowserClose()

			$iNettoyage = 1
			$iIE = 0

			If (GUICtrlRead($iID2) = $GUI_CHECKED) Then
				$iNettoyage = 2
			ElseIf(GUICtrlRead($iID3) = $GUI_CHECKED) Then
				$iNettoyage = 3
			ElseIf(GUICtrlRead($iID4) = $GUI_CHECKED) Then
				$iNettoyage = 4
			EndIf

			If (GUICtrlRead($iID5) = $GUI_CHECKED) Then
				$iIE = 1
			EndIf

			; nettoyage IE et Edge ancien
			If $iIE = 1 Then
				_FileWriteLog($hLog, "Nettoyage d'Internet Explorer")
				GUICtrlSetData($statusbar, " Nettoyage d'Internet Explorer")

				RunWait("RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255")
				GUICtrlSetData($iLVIE, "Internet Explorer| - | Effectué")

				If (FileExists(@LocalAppDataDir & "\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\")) Then
					_FileWriteLog($hLog, "Nettoyage de Microsoft Edge (ancienne version)")
					GUICtrlSetData($statusbar, " Nettoyage de Microsoft Edge (ancienne version)")
					GUICtrlSetData($statusbarprogress, 10)

					$iStartFS = DriveSpaceFree(@LocalAppDataDir & "\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC") / 1024

					Local $aEdge = _FileListToArray(@LocalAppDataDir & "\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC", "#!*", 2)

					If(IsArray($aEdge)) Then
						For $i = 1 To $aEdge[0]
							DirRemove(@LocalAppDataDir & "\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\" & $aEdge[$i], 1)
						Next
					EndIf

					$iEndFS = DriveSpaceFree(@LocalAppDataDir & "\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC") / 1024
					GUICtrlSetData($iLVEDGE1, "Microsoft Edge (ancien)| - | Effectué : " & Round($iStartFS - $iEndFS, 2) & " Go libérés")
					_FileWriteLog($hLog, Round($iStartFS - $iEndFS, 2) & " Go libérés")

				EndIf
			EndIf

			Switch $iNettoyage

				Case 1
					_FileWriteLog($hLog, "Nettoyage manuel des navigateurs")
					GUICtrlSetData($statusbarprogress, 30)
					ShellExecuteWait("msedge")
					GUICtrlSetData($iLVEDGE2, "Microsoft Edge (nouveau)| Manuel | -")
					GUICtrlSetData($statusbarprogress, 60)
					ShellExecuteWait("Chrome")
					GUICtrlSetData($iLVCHROME, "Google Chrome | Manuel | -")
					GUICtrlSetData($statusbarprogress, 90)
					ShellExecuteWait("firefox")
					GUICtrlSetData($iLVFIREFOX, "Mozilla Firefox | Manuel | -")

				Case 2
					_FileWriteLog($hLog, "Nettoyage léger des navigateurs")
						If (FileExists(@LocalAppDataDir & "\Microsoft\Edge\User Data\")) Then
							GUICtrlSetData($statusbarprogress, 30)
							_FileWriteLog($hLog, "Nettoyage du profil par défaut de Edge")
							GUICtrlSetData($statusbar, " Nettoyage de Microsoft Edge")
							$iStartFS = DriveSpaceFree(@LocalAppDataDir & "\Microsoft\Edge\User Data\") / 1024
							DirRemove(@LocalAppDataDir & "\Microsoft\Edge\User Data\Default\Cache\", 1)
							FileDelete(@LocalAppDataDir & "\Microsoft\Edge\User Data\Default\*History*")

							Local $aProfilsedge = _FileListToArrayRec(@LocalAppDataDir & "\Microsoft\Edge\User Data\", "Profile *")
							If $aProfilsedge <> "" Then
								For $i=1 To $aProfilsedge[0]
									_FileWriteLog($hLog, "Nettoyage du profil " & $aProfilsedge[$i] & " de Edge")
									DirRemove(@LocalAppDataDir & "\Microsoft\Edge\User Data\" & $aProfilsedge[$i] & "Cache\", 1)
									FileDelete(@LocalAppDataDir & "\Microsoft\Edge\User Data\" & $aProfilsedge[$i] & "*History*")
								Next
							EndIf

							$iEndFS = DriveSpaceFree(@LocalAppDataDir & "\Microsoft\Edge\User Data\") / 1024
							GUICtrlSetData($iLVEDGE2, "Microsoft Edge (nouveau)| Léger | Effectué : " & Round($iStartFS - $iEndFS, 2) & " Go libérés")
							_FileWriteLog($hLog, Round($iStartFS - $iEndFS, 2) & " Go libérés")
						Else
							_FileWriteLog($hLog, "Rien à nettoyer pour Edge")
							GUICtrlSetData($iLVEDGE2, "Microsoft Edge (nouveau)| - | -")
						EndIf

						If (FileExists(@LocalAppDataDir & "\Google\Chrome\User Data\Default\")) Then
							GUICtrlSetData($statusbarprogress, 60)
							_FileWriteLog($hLog, "Nettoyage du profil par défaut de Chrome")
							GUICtrlSetData($statusbar, " Nettoyage de Google Chrome")
							$iStartFS = DriveSpaceFree(@LocalAppDataDir & "\Google\Chrome\User Data\") / 1024
							DirRemove(@LocalAppDataDir & "\Google\Chrome\User Data\Default\Cache\", 1)
							FileDelete(@LocalAppDataDir & "\Google\Chrome\User Data\Default\*History*")

							Local $aProfils = _FileListToArrayRec(@LocalAppDataDir & "\Google\Chrome\User Data\", "Profile *")
							If $aProfils <> "" Then
								For $i=1 To $aProfils[0]
									_FileWriteLog($hLog, "Nettoyage du profil " & $aProfils[$i] & " de Chrome")
									DirRemove(@LocalAppDataDir & "\Google\Chrome\User Data\" & $aProfils[$i] & "Cache\", 1)
									FileDelete(@LocalAppDataDir & "\Google\Chrome\User Data\" & $aProfils[$i] & "*History*")
								Next
							EndIf

							$iEndFS = DriveSpaceFree(@LocalAppDataDir & "\Google\Chrome\User Data\") / 1024
							If $iLVCHROME Then
								GUICtrlSetData($iLVCHROME, "Google Chrome | Léger | Effectué : " & Round($iStartFS - $iEndFS, 2) & " Go libérés")
							EndIf
							_FileWriteLog($hLog, Round($iStartFS - $iEndFS, 2) & " Go libérés")
						Else
							_FileWriteLog($hLog, "Rien à nettoyer pour Chrome")
							GUICtrlSetData($iLVCHROME, "Google Chrome | - | -")
						EndIf

						If (FileExists(@AppDataDir & "\Mozilla\Firefox\Profiles\")) Then
							GUICtrlSetData($statusbarprogress, 90)
							_FileWriteLog($hLog, "Nettoyage de Firefox")
							GUICtrlSetData($statusbar, " Nettoyage de Mozilla Firefox")
							$iStartFS = DriveSpaceFree(@AppDataDir & "\Mozilla\Firefox\Profiles\") / 1024
							Local $aProfil = _FileListToArray(@AppDataDir & "\Mozilla\Firefox\Profiles", "*", 2)
							DirRemove(@LocalAppDataDir & "\Mozilla\Firefox\Profiles\", 1)
							_SQLite_Startup(@ScriptDir & "\Outils\sqlite3.dll", False, 1)
							For $i = 1 To $aProfil[0]
								If FileExists(@AppDataDir & "\Mozilla\Firefox\Profiles\" & $aProfil[$i] & "\places.sqlite") Then
									; fichiers à supprimer
									_FileWriteLog($hLog, "Nettoyage du profil " & $aProfil[$i] & " de Firefox")
									FileDelete(@AppDataDir & "\Mozilla\Firefox\Profiles\" & $aProfil[$i] & "\favicons.sqlite")
									FileDelete(@AppDataDir & "\Mozilla\Firefox\Profiles\" & $aProfil[$i] & "\content-prefs.sqlite")
									FileDelete(@AppDataDir & "\Mozilla\Firefox\Profiles\" & $aProfil[$i] & "\permissions.sqlite")
									FileDelete(@AppDataDir & "\Mozilla\Firefox\Profiles\" & $aProfil[$i] & "\formhistory.sqlite")
									FileDelete(@AppDataDir & "\Mozilla\Firefox\Profiles\" & $aProfil[$i] & "\search.json.mozlz4")
									DirRemove(@AppDataDir & "\Mozilla\Firefox\Profiles\" & $aProfil[$i] & "\extensions\", 1)
									; Nettoyage de l'historique tout en gardant les favoris:
									;ConsoleWrite("_SQLite_LibVersion=" & _SQLite_LibVersion() & @CRLF)
									_SQLite_Open(@AppDataDir & "\Mozilla\Firefox\Profiles\" & $aProfil[$i] & "\places.sqlite")
									_SQLite_Exec(-1, "DELETE FROM moz_historyvisits; VACUUM;")
									_SQLite_Close()
								EndIf
							Next
							_SQLite_Shutdown()

							$iEndFS = DriveSpaceFree(@AppDataDir & "\Mozilla\Firefox\Profiles\") / 1024
							If $iLVFIREFOX Then
								GUICtrlSetData($iLVFIREFOX, "Mozilla Firefox | Léger | Effectué : " & Round($iStartFS - $iEndFS, 2) & " Go libérés")
							EndIf
							_FileWriteLog($hLog, Round($iStartFS - $iEndFS, 2) & " Go libérés")
						Else
							_FileWriteLog($hLog, "Rien à nettoyer pour Firefox")
							GUICtrlSetData($iLVFIREFOX, "Mozilla Firefox | - | -")
						EndIf


				Case 3
					_FileWriteLog($hLog, "Nettoyage modéré des navigateurs")
					GUICtrlSetData($statusbarprogress, 30)
					If (FileExists(@LocalAppDataDir & "\Microsoft\Edge\User Data\Default\")) Then
						_FileWriteLog($hLog, "Nettoyage du profil par défaut de Edge")
						GUICtrlSetData($statusbar, " Nettoyage de Microsoft Edge")
						$iStartFS = DriveSpaceFree(@LocalAppDataDir & "\Microsoft\Edge\User Data\") / 1024
						ShellExecuteWait("msedge", '--profile-directory="Default" edge://settings/resetProfileSettings')

						Local $aProfilsedge = _FileListToArrayRec(@LocalAppDataDir & "\Microsoft\Edge\User Data\", "Profile *")
						If $aProfilsedge <> "" Then
							For $i=1 To $aProfilsedge[0]
								_FileWriteLog($hLog, "Nettoyage du profil " & $aProfilsedge[$i] & " de Edge")
								ShellExecuteWait("msedge", '--profile-directory="'& StringTrimRight($aProfilsedge[$i], 1) &'" edge://settings/resetProfileSettings')
							Next
						EndIf

						$iEndFS = DriveSpaceFree(@LocalAppDataDir & "\Microsoft\Edge\User Data\") / 1024
						GUICtrlSetData($iLVEDGE2, "Microsoft Edge (nouveau)| Modéré | Effectué : " & Round($iStartFS - $iEndFS, 2) & " Go libérés")
						_FileWriteLog($hLog, Round($iStartFS - $iEndFS, 2) & " Go libérés")

					EndIf

					If (FileExists(@LocalAppDataDir & "\Google\Chrome\User Data\Default\")) Then
						GUICtrlSetData($statusbarprogress, 60)
						_FileWriteLog($hLog, "Nettoyage du profil par défaut de Chrome")
						GUICtrlSetData($statusbar, " Nettoyage de Google Chrome")
						$iStartFS = DriveSpaceFree(@LocalAppDataDir & "\Google\Chrome\User Data\") / 1024
						ShellExecuteWait("chrome", '--profile-directory="Default" chrome://settings/resetProfileSettings')

						Local $aProfils = _FileListToArrayRec(@LocalAppDataDir & "\Google\Chrome\User Data\", "Profile *")
						If $aProfils <> "" Then
							For $i=1 To $aProfils[0]
								_FileWriteLog($hLog, "Nettoyage du profil " & $aProfils[$i] & " de Chrome")
								ShellExecuteWait("chrome", '--profile-directory="'& StringTrimRight($aProfils[$i], 1) &'" chrome://settings/resetProfileSettings')
							Next
						EndIf

						$iEndFS = DriveSpaceFree(@LocalAppDataDir & "\Google\Chrome\User Data\") / 1024
						If $iLVCHROME Then
							GUICtrlSetData($iLVCHROME, "Google Chrome | Modéré | Effectué : " & Round($iStartFS - $iEndFS, 2) & " Go libérés")
						EndIf
						_FileWriteLog($hLog, Round($iStartFS - $iEndFS, 2) & " Go libérés")

					EndIf


					If (FileExists(@AppDataDir & "\Mozilla\Firefox\Profiles\")) Then
						GUICtrlSetData($statusbarprogress, 90)
						_FileWriteLog($hLog, "Nettoyage de Firefox")
						GUICtrlSetData($statusbar, " Nettoyage de Mozilla Firefox")
						$iStartFS = DriveSpaceFree(@AppDataDir & "\Mozilla\Firefox\Profiles\") / 1024
						ShellExecuteWait("firefox", '-safe-mode')
						ProcessWaitClose("firefox.exe")
						$iEndFS = DriveSpaceFree(@AppDataDir & "\Mozilla\Firefox\Profiles\") / 1024
						If $iLVFIREFOX Then
							GUICtrlSetData($iLVFIREFOX, "Mozilla Firefox | Modéré | Effectué : " & Round($iStartFS - $iEndFS, 2) & " Go libérés")
						EndIf
						_FileWriteLog($hLog, Round($iStartFS - $iEndFS, 2) & " Go libérés")
					EndIf

				Case 4
					_FileWriteLog($hLog, "Nettoyage complet des navigateurs")
					GUICtrlSetData($statusbarprogress, 30)

					If FileExists(@LocalAppDataDir & "\Microsoft\Edge\User Data\") Then
						$iStartFS = DriveSpaceFree(@LocalAppDataDir & "\Microsoft\Edge\User Data\") / 1024
						If DirRemove(@LocalAppDataDir & "\Microsoft\Edge\User Data\", 1) Then
							_FileWriteLog($hLog, 'Dossier "' & @LocalAppDataDir & "\Microsoft\Edge\User Data\" & '" supprimé')
						Else
							_FileWriteLog($hLog, 'Dossier "' & @LocalAppDataDir & "\Microsoft\Edge\User Data\" & '" NON supprimé')
						EndIf
						$iEndFS = DriveSpaceFree(@LocalAppDataDir & "\Microsoft\Edge\User Data\") / 1024
						GUICtrlSetData($iLVEDGE2, "Microsoft Edge (nouveau)| Complet | Effectué : " & Round($iStartFS - $iEndFS, 2) & " Go libérés")
						_FileWriteLog($hLog, Round($iStartFS - $iEndFS, 2) & " Go libérés")
					EndIf
					GUICtrlSetData($statusbarprogress, 60)
					If FileExists(@LocalAppDataDir & "\Google\Chrome\User Data\") Then
						$iStartFS = DriveSpaceFree(@LocalAppDataDir & "\Google\Chrome\User Data\") / 1024
						If DirRemove(@LocalAppDataDir & "\Google\Chrome\User Data\", 1) Then
							_FileWriteLog($hLog, 'Dossier "' & @LocalAppDataDir & "\Google\Chrome\User Data\" & '" supprimé')
						Else
							_FileWriteLog($hLog, 'Dossier "' & @LocalAppDataDir & "\Microsoft\Edge\User Data\" & '" NON supprimé')
						EndIf
						$iEndFS = DriveSpaceFree(@LocalAppDataDir & "\Google\Chrome\User Data\") / 1024
						If $iLVCHROME Then
							GUICtrlSetData($iLVCHROME, "Google Chrome | Complet | Effectué : " & Round($iStartFS - $iEndFS, 2) & " Go libérés")
						EndIf
						_FileWriteLog($hLog, Round($iStartFS - $iEndFS, 2) & " Go libérés")
					EndIf
					GUICtrlSetData($statusbarprogress, 90)
					If FileExists(@LocalAppDataDir & "\Mozilla\Firefox\Profiles\") Then
						If DirRemove(@LocalAppDataDir & "\Mozilla\Firefox\Profiles\", 1) Then
							_FileWriteLog($hLog, 'Dossier "' & @LocalAppDataDir & "\Mozilla\Firefox\Profiles\" & '" supprimé')
						Else
							_FileWriteLog($hLog, 'Dossier "' & @LocalAppDataDir & "\Mozilla\Firefox\Profiles\" & '" NON supprimé')
						EndIf
					EndIf

					If FileExists(@AppDataDir & "\Mozilla\Firefox\Profiles\") Then
						$iStartFS = DriveSpaceFree(@AppDataDir & "\Mozilla\Firefox\Profiles\") / 1024
						If DirRemove(@AppDataDir & "\Mozilla\Firefox\Profiles\", 1) Then
							_FileWriteLog($hLog, 'Dossier "' & @AppDataDir & "\Mozilla\Firefox\Profiles\" & '" supprimé')
							$iEndFS = DriveSpaceFree(@AppDataDir & "\Mozilla\Firefox\Profiles\") / 1024
							If $iLVFIREFOX Then
								GUICtrlSetData($iLVFIREFOX, "Mozilla Firefox | Complet | Effectué : " & Round($iStartFS - $iEndFS, 2) & " Go libérés")
							EndIf
							_FileWriteLog($hLog, Round($iStartFS - $iEndFS, 2) & " Go libérés")
						Else
							_FileWriteLog($hLog, 'Dossier "' & @AppDataDir & "\Mozilla\Firefox\Profiles\" & '" NON supprimé')
						EndIf
					EndIf

			EndSwitch
			GUICtrlSetData($statusbar, "")
			GUICtrlSetData($statusbarprogress, 0)

		EndIf

		$eGet = GUIGetMsg()
	WEnd

	GUIDelete()

	If $iNettoyage Then
		_UpdEdit($iIDEditLog, $hLog)
		_ChangerEtatBouton($iIDAction, "Activer")
	Else
		_ChangerEtatBouton($iIDAction, "Desactiver")
	EndIf

EndFunc

Func _BrowserClose()
	_FileWriteLog($hLog, "Fermeture automatique des navigateurs Internet")
    Local $aList = 0
    Local $aProcesses = StringSplit('iexplore.exe|chrome.exe|firefox.exe|MicrosoftEdge.exe', '|', $STR_NOCOUNT) ; Multiple processes
    For $i = 0 To UBound($aProcesses) - 1
        $aList = ProcessList($aProcesses[$i])
        If $aList[0][0] > 0 Then ; An array is returned and @error is NEVER set, so lets check the count.
;~         _ArrayDisplay($aList)
            Local $bIsProcessClosed = False ; Declare a variable to hold a boolean.
            For $j = 1 To $aList[0][0]
                $bIsProcessClosed = ProcessClose($aList[$j][1]) ; In AutoIt 0 or 1 can be considered boolean too. It's like a bit in SQL or in C, where 1 and 0 means true or false.
                If Not $bIsProcessClosed Then ConsoleWrite('CLOSE ERROR PID: ' & $aList[$j][1] & @CRLF)
            Next
        EndIf
    Next
EndFunc   ;==>_BrowserClose