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

	; Navigateurs pris en charge (en plus de Firefox et Opera)
	Local $mBrowsers[], $iIDListView[], $programFilesDir
	$mBrowsers["Chrome"] = @LocalAppDataDir & "\Google\Chrome"
	$mBrowsers["Chromium"] = @LocalAppDataDir & "\Chromium"
	$mBrowsers["Edge"] = @LocalAppDataDir & "\Microsoft\Edge"
	$mBrowsers["Brave"] = @LocalAppDataDir & "\BraveSoftware\Brave-Browser"
	$mBrowsers["AvastBrowser"] =@LocalAppDataDir & "\AVAST Software\Browser"

	Local $aKeyBrowsers = MapKeys($mBrowsers)

	Local $iNettoyage, $iFFAuto, $aBrowsersInLV, $hWnd

	Local $hGUInav = GUICreate("Nettoyage des navigateurs Internet", 600, 350)
	GUICtrlCreateLabel("Choisissez un mode de nettoyage :", 10, 10)
	Local $iID1 = GUICtrlCreateRadio("1 - Manuel (avec menu BAO-Nettoyage)", 60, 30)
	Local $iFF = GUICtrlCreateCheckbox("Firefox : vider cache et historique automatiquement", 300, 30)
	Local $iID2 = GUICtrlCreateRadio("2 - Réinitialisation des paramètres (Fonction intégrée au navigateur)", 60, 50)
	Local $iID3 = GUICtrlCreateRadio("3 - Suppression des profils (Favoris et mots de passe conservés)", 60, 70)
	GUICtrlSetState($iID1, $GUI_CHECKED)
	GUICtrlSetState($iFF, $GUI_CHECKED)

	GUICtrlCreateLabel("Résultats : ", 10, 90)
	Local $iIDListViewNav = GUICtrlCreateListView("Navigateurs détectés|Profils nettoyés|Etat", 10, 110, 480, 200)
	_GUICtrlListView_SetColumnWidth($iIDListViewNav, 0, 200)
	_GUICtrlListView_SetColumnWidth($iIDListViewNav, 1, 150)
	_GUICtrlListView_SetColumnWidth($iIDListViewNav, 2, 120)

	For $sBrowser In $aKeyBrowsers
		Local $iTmpItem, $sBrowserTMP = $sBrowser
		If $sBrowser = "edge" Then
			$sBrowserTMP = "msedge"
		EndIf
		RegEnumVal($HKLM & "\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\" & StringLower($sBrowserTMP) & ".exe\",1)
		If @error = 0 Then
			$iTmpItem = GUICtrlCreateListViewItem($sBrowser, $iIDListViewNav)
			$iIDListView[$sBrowser] = $iTmpItem
		EndIf
	Next

	$programFilesDir = RegRead("HKLM64\SOFTWARE\Microsoft\Windows\CurrentVersion", "ProgramFilesDir")
	If FileExists($programFilesDir & "\Opera\opera.exe") Then
		$iIDListView["Opera"] = GUICtrlCreateListViewItem("Opera", $iIDListViewNav)
	EndIf

	RegEnumVal($HKLM & "\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\firefox.exe\",1)
	If @error = 0 Then
		$iIDListView["Firefox"] = GUICtrlCreateListViewItem("Firefox", $iIDListViewNav)
	Else
		GUICtrlSetState($iFF, $GUI_DISABLE)
	EndIf

	$aBrowsersInLV = MapKeys($iIDListView)

	Local $iIDButtonSuivant = GUICtrlCreateButton("Suivant", 500, 110, 90, 25)
	GUICtrlSetState($iIDButtonSuivant, $GUI_DISABLE)

	Local $iIDButtonDemarrer = GUICtrlCreateButton("Nettoyer", 200, 320, 90, 25, $BS_DEFPUSHBUTTON)
	Local $iIDButtonAnnuler = GUICtrlCreateButton("Quitter", 310, 320, 90, 25)
	GUISetState(@SW_SHOW)

	Local $eGet = GUIGetMsg()

	While $eGet <> $GUI_EVENT_CLOSE And $eGet <> $iIDButtonAnnuler

		If $eGet = $iID2 Or $eGet = $iID3 Then
			GUICtrlSetState($iFF, $GUI_UNCHECKED)
			GUICtrlSetState($iFF, $GUI_DISABLE)
		ElseIf $eGet = $iID1 Then
			GUICtrlSetState($iFF, $GUI_ENABLE)
		ElseIf($eGet = $iIDButtonDemarrer) Then

			GUICtrlSetState($iIDButtonDemarrer, $GUI_DISABLE)
			GUICtrlSetState($iIDButtonAnnuler, $GUI_DISABLE)
			_FileWriteLog($hLog, "Nettoyage des navigateurs")

			For $sBrowserInLV In $aBrowsersInLV
				GUICtrlSetData($iIDListView[$sBrowserInLV], $sBrowserInLV & "| |En attente")
			Next

			_BrowserClose()

			$iNettoyage = 1

			If (GUICtrlRead($iID2) = $GUI_CHECKED) Then
				$iNettoyage = 2
			ElseIf(GUICtrlRead($iID3) = $GUI_CHECKED) Then
				$iNettoyage = 3
			ElseIf(GUICtrlRead($iFF) = $GUI_CHECKED) Then
				$iFFAuto = 1
			EndIf

			Local $iSplashWidth = 600
			Local $iSplashHeigh = 70
			Local $iSplashX = @DesktopWidth - 900
			Local $iSplashY = @DesktopHeight - 160

			Switch $iNettoyage

				Case 1
					_FileWriteLog($hLog, "Mode 1")

					SplashTextOn("Nettoyage des navigateurs : 1 - Mode manuel", "", $iSplashWidth, $iSplashHeigh, $iSplashX, $iSplashY, 16)
					Local $sModeleBookmark = '{"checksum":"1bbdee4bfc702f14d8c89791ecc807be","roots":{"bookmark_bar":{"children":[{"children":[{"date_added":"13312747939582318","date_last_used":"0","guid":"ca3a00ae-f502-4534-8572-631fa89ca526","id":"8","meta_info":{"power_bookmark_meta":""},"name":"Choisir la page de démarrage","type":"url","url":"%navigateur%://settings/onStartup"},{"date_added":"13312747922842454","date_last_used":"0","guid":"d7563cf8-34e3-4f25-8e0a-806df2f23af2","id":"7","meta_info":{"power_bookmark_meta":""},"name":"Supprimer les extensions malveillantes","type":"url","url":"%navigateur%://extensions/"},{"date_added":"13312747920483274","date_last_used":"0","guid":"826e13cc-b21f-4bd0-b8d5-32f2c4ad76c9","id":"6","meta_info":{"power_bookmark_meta":""},"name":"Supprimer les notifications intempestives","type":"url","url":"%navigateur%://settings/content/notifications"},{"date_added":"13312747944491453","date_last_used":"0","guid":"4544c826-1008-485b-9c14-5c904680767b","id":"9","meta_info":{"power_bookmark_meta":""},"name":"Changer le moteur de recherche par défaut","type":"url","url":"%navigateur%://settings/search"},{"date_added":"13312748017043161","date_last_used":"0","guid":"7e20dda9-eceb-45b2-bf49-bb17b5a573e1","id":"11","meta_info":{"power_bookmark_meta":""},"name":"Effacer l'&"'"&'historique de navigation","type":"url","url":"%navigateur%://settings/clearBrowserData"}],"date_added":"13312747898915548","date_last_used":"0","date_modified":"13312748198532004","guid":"939c7ac0-d93a-4540-acf0-a43d538516d6","id":"5","name":"BAO-Nettoyage","type":"folder"}],"date_added":"13312747880305172","date_last_used":"0","date_modified":"13312747898915811","guid":"0bc5d13f-2cba-5d74-951f-3f233fe6c908","id":"1","name":"Barredefavoris","type":"folder"},"other":{"children":[],"date_added":"13312747880305173","date_last_used":"0","date_modified":"0","guid":"82b081ec-3dd3-529c-8475-ab6c344590dd","id":"2","name":"Autresfavoris","type":"folder"},"synced":{"children":[],"date_added":"13312747880305174","date_last_used":"0","date_modified":"0","guid":"4cf2e351-0e85-532b-bb37-df045d8f8d0f","id":"3","name":"Favorissurmobile","type":"folder"}},"version":1}'
					Local $sBookmark, $hFileBookmark, $ipidb, $bBookmark = 0
					For $sBrowser In $aKeyBrowsers
						If MapExists($iIDListView, $sBrowser) Then
							_FileWriteLog($hLog, "Nettoyage de " & $sBrowser)
							GUICtrlSetData($iIDListView[$sBrowser], $sBrowser & "| 0 | En cours")
							$sBookmark = StringReplace($sModeleBookmark, "%navigateur%", StringLower($sBrowser))
							If FileExists($mBrowsers[$sBrowser] & '\User Data\Default\') Then
								ControlSetText("Nettoyage des navigateurs : 1 - Mode manuel", "", "Static1", 'Navigateur : ' & $sBrowser & ' - Profil : Default' & @Lf & 'Utilisez le menu "BAO - Nettoyage" dans la barre de favoris (CTRL + SHIFT + B)')
								If Not FileMove($mBrowsers[$sBrowser] & '\User Data\Default\Bookmarks', $mBrowsers[$sBrowser] & '\User Data\Default\BookmarksSVG', 1) Then
									_FileWriteLog($hLog, 'Pas de fichier "Bookmarks" dans le dossier "' & $mBrowsers[$sBrowser] & '\User Data\Default\' & '"')
									$bBookmark = 1
								EndIf
								$hFileBookmark = FileOpen($mBrowsers[$sBrowser] & '\User Data\Default\Bookmarks', 2)
								FileWrite($hFileBookmark, $sBookmark)
								FileClose($hFileBookmark)
								If $sBrowser = "Edge" Then
									$sBrowser = "MSEdge"
								EndIf
								ShellExecute($sBrowser, '--profile-directory="Default" --start-maximized')
								ProcessWait($sBrowser & ".exe", 5)
								GUICtrlSetState($iIDButtonSuivant, $GUI_ENABLE)
								While ProcessExists($sBrowser & ".exe")
									If $eGet = $iIDButtonSuivant Then
										GUICtrlSetState($iIDButtonSuivant, $GUI_DISABLE)
										ProcessClose($sBrowser & ".exe")
										ProcessWaitClose($sBrowser & ".exe")
									EndIf
									$eGet = GUIGetMsg()
								WEnd
								If $sBrowser = "MSEdge" Then
									$sBrowser = "Edge"
								EndIf
								If $bBookmark = 0 And Not FileMove($mBrowsers[$sBrowser] & '\User Data\Default\BookmarksSVG', $mBrowsers[$sBrowser] & '\User Data\Default\Bookmarks', 1) Then
									_FileWriteLog($hLog, 'Attention, les bookmarks du profil "Default" n' & "'" & 'ont pas été récupérés')
									_Attention('Attention, "BookmarksSVG" du profil "Default" de ' & $sBrowser & ' n' & "'" & 'a pas pu être renommé en "Bookmarks". Essayez manuellement')
									ShellExecuteWait($mBrowsers[$sBrowser] & '\User Data\Default\')
								EndIf
								$bBookmark = 0
								GUICtrlSetData($iIDListView[$sBrowser], $sBrowser & "| 1 | En cours")
							Else
								_FileWriteLog($hLog, 'Le dossier "' & $mBrowsers[$sBrowser] & '\User Data\Default\' & '" n' & "'existe pas")
							EndIf

							Local $iProfil = 1
							While FileExists($mBrowsers[$sBrowser] & "\User Data\Profile " & $iProfil & "\")
								If (FileExists($mBrowsers[$sBrowser] & "\User Data\Profile " & $iProfil & "\")) Then
									ControlSetText("Nettoyage des navigateurs : 1 - Mode manuel", "", "Static1", 'Navigateur : ' & $sBrowser & ' - Profil : Profile ' & $iProfil  & @Lf & 'Utilisez le menu "BAO - Nettoyage" dans la barre de favoris (CTRL + SHIFT + B)')
									If Not FileMove($mBrowsers[$sBrowser] & "\User Data\Profile " & $iProfil & "\Bookmarks", $mBrowsers[$sBrowser] & "\User Data\Profile " & $iProfil & "\BookmarksSVG", 1) Then
										_FileWriteLog($hLog, 'Pas de fichier "Bookmarks" dans le dossier "' & $mBrowsers[$sBrowser] & '\User Data\Profile ' & $iProfil & '\' & '"')
										$bBookmark = 1
									EndIf
									$hFileBookmark = FileOpen($mBrowsers[$sBrowser] & "\User Data\Profile " & $iProfil & "\Bookmarks", 2)
									FileWrite($hFileBookmark, $sBookmark)
									FileClose($hFileBookmark)

									If $sBrowser = "Edge" Then
										$sBrowser = "MSEdge"
									EndIf
									ShellExecute($sBrowser, '--profile-directory="Profile ' & $iProfil & '" --start-maximized')
									ProcessWait($sBrowser & ".exe", 5)
									GUICtrlSetState($iIDButtonSuivant, $GUI_ENABLE)
									While ProcessExists($sBrowser & ".exe")
										If $eGet = $iIDButtonSuivant Then
											GUICtrlSetState($iIDButtonSuivant, $GUI_DISABLE)
											ProcessClose($sBrowser & ".exe")
											ProcessWaitClose($sBrowser & ".exe")
										EndIf
										$eGet = GUIGetMsg()
									WEnd
									If $sBrowser = "MSEdge" Then
										$sBrowser = "Edge"
									EndIf
									If $bBookmark = 0 And Not FileMove($mBrowsers[$sBrowser] & "\User Data\Profile " & $iProfil & "\BookmarksSVG", $mBrowsers[$sBrowser] & "\User Data\Profile " & $iProfil & "\Bookmarks", 1) Then
										_FileWriteLog($hLog, 'Attention, les bookmarks du profil "Profile ' & $iProfil & '" n' & "'" & 'ont pas été récupérés')
										_Attention('Attention, "BookmarksSVG" du profil "Profile ' & $iProfil & '" de ' & $sBrowser & ' n' & "'" & 'a pas pu être renommé en "Bookmarks". Essayez manuellement')
										ShellExecuteWait($mBrowsers[$sBrowser] & '\User Data\Profile ' & $iProfil & '\')
									EndIf
									$bBookmark = 0
									GUICtrlSetData($iIDListView[$sBrowser], $sBrowser & "| " & ($iProfil + 1) & " | En cours")
								Else
									_FileWriteLog($hLog, 'Le dossier "' & $mBrowsers[$sBrowser] & '\User Data\Profile ' & $iProfil & '\' & '" n' & "'existe pas")
								EndIf
								$iProfil += 1
							WEnd
							GUICtrlSetData($iIDListView[$sBrowser], $sBrowser & "| " & $iProfil & " | Terminé")
						EndIf
					Next

					; Opera
					If MapExists($iIDListView, "Opera") Then
						_FileWriteLog($hLog, "Nettoyage d'Opera")
						GUICtrlSetData($iIDListView["Opera"], "Opera| 0 | En cours")
						$sBookmark = StringReplace($sModeleBookmark, "%navigateur%", "opera")
						If FileExists(@AppDataDir & '\Opera Software\Opera Stable\') Then
							ControlSetText("Nettoyage des navigateurs : 1 - Mode manuel", "", "Static1", 'Navigateur : Opera - Profil : Default' & @Lf & 'Utilisez le menu "BAO - Nettoyage" dans la barre de favoris (CTRL + SHIFT + B)')
							If Not FileMove(@AppDataDir & '\Opera Software\Opera Stable\Bookmarks', @AppDataDir & '\Opera Software\Opera Stable\BookmarksSVG') Then
								_FileWriteLog($hLog, 'Pas de fichier "Bookmarks" dans le dossier "' & @AppDataDir & '\Opera Software\Opera Stable\"')
								$bBookmark = 1
							EndIf
							$hFileBookmark = FileOpen(@AppDataDir & '\Opera Software\Opera Stable\Bookmarks', 2)
							FileWrite($hFileBookmark, $sBookmark)
							FileClose($hFileBookmark)
							ShellExecute($programFilesDir & "\Opera\launcher.exe", '--start-maximized')
							ProcessWait("opera.exe", 5)
							GUICtrlSetState($iIDButtonSuivant, $GUI_ENABLE)
							While ProcessExists("opera.exe")
								If $eGet = $iIDButtonSuivant Then
									GUICtrlSetState($iIDButtonSuivant, $GUI_DISABLE)
									ProcessClose("opera.exe")
									ExitLoop
								EndIf
								$eGet = GUIGetMsg()
							WEnd

							If $bBookmark = 0 And Not FileMove(@AppDataDir & '\Opera Software\Opera Stable\BookmarksSVG', @AppDataDir & '\Opera Software\Opera Stable\Bookmarks', 1) Then
								_FileWriteLog($hLog, "Attention, les bookmarks d'Opera n'ont pas été récupérés")
								_Attention('Attention, "BookmarksSVG" du profil "Default" d' & "'" & 'Opera n' & "'" & 'a pas pu être renommé en "Bookmarks". Essayez manuellement')
								ShellExecuteWait(@AppDataDir & '\Opera Software\Opera Stable\')
							EndIf
							$bBookmark = 0
							GUICtrlSetData($iIDListView["Opera"], "Opera| 1 | Terminé")
						EndIf
					EndIf

					; Firefox
					If MapExists($iIDListView, "Firefox") Then
						_FileWriteLog($hLog, "Nettoyage de Firefox")
						If (FileExists(@AppDataDir & "\Mozilla\Firefox\Profiles\")) Then
							Local $iNbProfilsFF = 0
							_SQLite_Startup(@ScriptDir & "\Outils\sqlite3.dll", False, 1)
							Local $aProfil = _FileListToArray(@AppDataDir & "\Mozilla\Firefox\Profiles", "*", 2)
							If @error = 0 Then
								For $i = 1 To $aProfil[0]
									If FileExists(@AppDataDir & "\Mozilla\Firefox\Profiles\" & $aProfil[$i] & "\places.sqlite") Then
										ControlSetText("Nettoyage des navigateurs : 1 - Mode manuel", "", "Static1", 'Navigateur : Firefox - Profil : ' & $aProfil[$i] & '' & @Lf & 'Vérifiez les extensions et les préférences de Firefox')
										$iNbProfilsFF += 1
										GUICtrlSetData($iIDListView["Firefox"], "Firefox| " & $iNbProfilsFF & " | En cours")
										; fichiers à supprimer
										_FileWriteLog($hLog, "Nettoyage du profil " & $aProfil[$i] & " de Firefox")
										If $iFFAuto Then
											DirRemove(@LocalAppDataDir & "\Mozilla\Firefox\Profiles\", 1)
											FileDelete(@AppDataDir & "\Mozilla\Firefox\Profiles\" & $aProfil[$i] & "\favicons.sqlite")
											FileDelete(@AppDataDir & "\Mozilla\Firefox\Profiles\" & $aProfil[$i] & "\content-prefs.sqlite")
											FileDelete(@AppDataDir & "\Mozilla\Firefox\Profiles\" & $aProfil[$i] & "\permissions.sqlite")
											FileDelete(@AppDataDir & "\Mozilla\Firefox\Profiles\" & $aProfil[$i] & "\formhistory.sqlite")
											FileDelete(@AppDataDir & "\Mozilla\Firefox\Profiles\" & $aProfil[$i] & "\search.json.mozlz4")
											; Nettoyage de l'historique tout en gardant les favoris:
											;ConsoleWrite("_SQLite_LibVersion=" & _SQLite_LibVersion() & @CRLF)
											_SQLite_Open(@AppDataDir & "\Mozilla\Firefox\Profiles\" & $aProfil[$i] & "\places.sqlite")
											_SQLite_Exec(-1, "DELETE FROM moz_historyvisits; VACUUM;")
											_SQLite_Close()
										EndIf
										ShellExecute("firefox", '-profile "' & @AppDataDir & "\Mozilla\Firefox\Profiles\" & $aProfil[$i] & '" about:preferences about:addons')
										ProcessWait("firefox.exe", 5)
										GUICtrlSetState($iIDButtonSuivant, $GUI_ENABLE)
										While ProcessExists("firefox.exe")
											If $eGet = $iIDButtonSuivant Then
												GUICtrlSetState($iIDButtonSuivant, $GUI_DISABLE)
												ProcessClose("firefox.exe")
												ExitLoop
											EndIf
											$eGet = GUIGetMsg()
										WEnd

									EndIf
								Next
							EndIf
							_SQLite_Shutdown()
							GUICtrlSetData($iIDListView["Firefox"], "Firefox| " & $iNbProfilsFF & "| Terminé")
						EndIf
					EndIf

				Case 2
					_FileWriteLog($hLog, "Mode 2")
					SplashTextOn("Nettoyage des navigateurs : 2 - Réinitialisation des paramètres", "", $iSplashWidth, $iSplashHeigh, $iSplashX, $iSplashY, 16)
					For $sBrowser In $aKeyBrowsers
						If MapExists($iIDListView, $sBrowser) Then
							_FileWriteLog($hLog, "Nettoyage de " & $sBrowser)
							GUICtrlSetData($iIDListView[$sBrowser], $sBrowser & "| 0 | En cours")

							If FileExists($mBrowsers[$sBrowser] & '\User Data\Default\') Then
								If $sBrowser = "Edge" Then
									$sBrowser = "MSEdge"
									ControlSetText("Nettoyage des navigateurs : 2 - Réinitialisation des paramètres", "", "Static1", 'Navigateur : ' & $sBrowser & ' - Profil : Default' & @Lf & 'Cliquez sur "réinitialiser les paramètres"')
									ShellExecute($sBrowser, '--profile-directory="Default" edge://settings/resetProfileSettings')
								ElseIf $sBrowser = "Brave" Then
									ShellExecute($sBrowser, '--profile-directory="Default" --start-maximized')
									ClipPut('brave://settings/resetProfileSettings')
									ControlSetText("Nettoyage des navigateurs : 2 - Réinitialisation des paramètres", "", "Static1", 'Navigateur : ' & $sBrowser & ' - Profil : Profile ' & $iProfil & @Lf & "Coller dans la barre d'adresse le contenu du presse-papier")
								Else
									ControlSetText("Nettoyage des navigateurs : 2 - Réinitialisation des paramètres", "", "Static1", 'Navigateur : ' & $sBrowser & ' - Profil : Default' & @Lf & 'Cliquez sur "réinitialiser les paramètres"')
									ShellExecute($sBrowser, '--profile-directory="Default" ' & $sBrowser & '://settings/resetProfileSettings')
								EndIf

								ProcessWait($sBrowser & ".exe", 5)
								GUICtrlSetState($iIDButtonSuivant, $GUI_ENABLE)
								While ProcessExists($sBrowser & ".exe")
									If $eGet = $iIDButtonSuivant Then
										GUICtrlSetState($iIDButtonSuivant, $GUI_DISABLE)
										ProcessClose($sBrowser & ".exe")
										ProcessWaitClose($sBrowser & ".exe")
									EndIf
									$eGet = GUIGetMsg()
								WEnd
								If $sBrowser = "MSEdge" Then
									$sBrowser = "Edge"
								EndIf
								GUICtrlSetData($iIDListView[$sBrowser], $sBrowser & "| 1 | En cours")
							EndIf

							Local $iProfil = 1
							While FileExists($mBrowsers[$sBrowser] & "\User Data\Profile " & $iProfil & "\")
								If $sBrowser = "Edge" Then
									$sBrowser = "MSEdge"
									ControlSetText("Nettoyage des navigateurs : 2 - Réinitialisation des paramètres", "", "Static1", 'Navigateur : ' & $sBrowser & ' - Profil : Profile ' & $iProfil & @Lf & 'Cliquez sur "Réinitialiser les paramètres"')
									ShellExecute($sBrowser, '--profile-directory="Profile ' & $iProfil & '" edge://settings/resetProfileSettings --start-maximized')
								ElseIf $sBrowser = "Brave" Then
									ShellExecute($sBrowser, '--profile-directory="Profile ' & $iProfil & '" --start-maximized')
									ClipPut('brave://settings/resetProfileSettings')
									ControlSetText("Nettoyage des navigateurs : 2 - Réinitialisation des paramètres", "", "Static1", 'Navigateur : ' & $sBrowser & ' - Profil : Profile ' & $iProfil & @Lf & "Coller dans la barre d'adresse le contenu du presse-papier")
								Else
									ControlSetText("Nettoyage des navigateurs : 2 - Réinitialisation des paramètres", "", "Static1", 'Navigateur : ' & $sBrowser & ' - Profil : Profile ' & $iProfil & @Lf & 'Cliquez sur "Réinitialiser les paramètres"')
									ShellExecute($sBrowser, '--profile-directory="Profile ' & $iProfil & '" ' & $sBrowser & '://settings/resetProfileSettings')
								EndIf
								ProcessWait($sBrowser & ".exe", 5)
								GUICtrlSetState($iIDButtonSuivant, $GUI_ENABLE)
								While ProcessExists($sBrowser & ".exe")
									If $eGet = $iIDButtonSuivant Then
										GUICtrlSetState($iIDButtonSuivant, $GUI_DISABLE)
										ProcessClose($sBrowser & ".exe")
										ProcessWaitClose($sBrowser & ".exe")
									EndIf
									$eGet = GUIGetMsg()
								WEnd
								If $sBrowser = "MSEdge" Then
									$sBrowser = "Edge"
								EndIf
								GUICtrlSetData($iIDListView[$sBrowser], $sBrowser & "| " & ($iProfil + 1) & " | En cours")
								$iProfil += 1
							WEnd
							GUICtrlSetData($iIDListView[$sBrowser], $sBrowser & "| " & $iProfil & " | Terminé")
						EndIf
					Next

					; Opera
					If MapExists($iIDListView, "Opera") Then
						_FileWriteLog($hLog, "Nettoyage d'Opera")
						GUICtrlSetData($iIDListView["Opera"], "Opera| 0 | En cours")

						If FileExists(@AppDataDir & '\Opera Software\Opera Stable\') Then
							ControlSetText("Nettoyage des navigateurs : 2 - Réinitialisation des paramètres", "", "Static1", 'Navigateur : Opera' & @Lf & "Coller dans la barre d'adresse le contenu du presse-papier")
							ShellExecute($programFilesDir & "\Opera\launcher.exe")
							ProcessWait("opera.exe", 5)
							ClipPut("opera://settings/resetProfileSettings")
							GUICtrlSetState($iIDButtonSuivant, $GUI_ENABLE)
							While ProcessExists("opera.exe")
								If $eGet = $iIDButtonSuivant Then
									GUICtrlSetState($iIDButtonSuivant, $GUI_DISABLE)
									ProcessClose("opera.exe")
									ExitLoop
								EndIf
								$eGet = GUIGetMsg()
							WEnd
							GUICtrlSetData($iIDListView["Opera"], "Opera| 1 | Terminé")
						Else
							GUICtrlSetData($iIDListView["Opera"], "Opera| 0 | Erreur")
						EndIf
					EndIf

					; Firefox
					If MapExists($iIDListView, "Firefox") Then
						If (FileExists(@AppDataDir & "\Mozilla\Firefox\Profiles\")) Then
							_FileWriteLog($hLog, "Nettoyage de Firefox")
							Local $iNbProfilsFF = 0
							Local $aProfil = _FileListToArray(@AppDataDir & "\Mozilla\Firefox\Profiles", "*", 2)
							If @error = 0 Then
								For $i = 1 To $aProfil[0]
									If FileExists(@AppDataDir & "\Mozilla\Firefox\Profiles\" & $aProfil[$i] & "\places.sqlite") Then
										ControlSetText("Nettoyage des navigateurs : 2 - Réinitialisation des paramètres", "", "Static1", 'Navigateur : Firefox - Profil : ' & $aProfil[$i] & '' & @Lf & 'Cliquez sur "Réparer Firefox"')
										$iNbProfilsFF += 1
										GUICtrlSetData($iIDListView["Firefox"], "Firefox| " & $iNbProfilsFF & " | En cours")
										; fichiers à supprimer
										_FileWriteLog($hLog, 'Réparation du profil "' & $aProfil[$i] & '" de Firefox')

										ShellExecute("firefox", '-profile "' & @AppDataDir & "\Mozilla\Firefox\Profiles\" & $aProfil[$i] & '" -safe-mode')
										ProcessWait("firefox.exe", 5)
										GUICtrlSetState($iIDButtonSuivant, $GUI_ENABLE)
										While ProcessExists("firefox.exe")
											If $eGet = $iIDButtonSuivant Then
												GUICtrlSetState($iIDButtonSuivant, $GUI_DISABLE)
												ProcessClose("firefox.exe")
												ExitLoop
											EndIf
											$eGet = GUIGetMsg()
										WEnd

									EndIf
								Next
							EndIf
							GUICtrlSetData($iIDListView["Firefox"], "Firefox| " & $iNbProfilsFF & " | Terminé")
						EndIf
					EndIf


				Case 3
					_FileWriteLog($hLog, "Mode 3")
					SplashTextOn("Nettoyage des navigateurs : 3 - Suppression des profils", "", $iSplashWidth, $iSplashHeigh, $iSplashX, $iSplashY, 16)
					For $sBrowser In $aKeyBrowsers
						If MapExists($iIDListView, $sBrowser) Then
							ControlSetText("Nettoyage des navigateurs : 2 - Suppression des profils", "", "Static1", 'Navigateur : ' & $sBrowser & ' - Profil : Default' & @Lf & "Patientez")
							_FileWriteLog($hLog, "Nettoyage de " & $sBrowser)
							GUICtrlSetData($iIDListView[$sBrowser], $sBrowser & "| 0 | En cours")
							If FileExists($mBrowsers[$sBrowser] & '\User Data\Default\Bookmarks') Then
								FileCopy($mBrowsers[$sBrowser] & '\User Data\Default\Bookmarks', @LocalAppDataDir & "\bao\User Data\Default\", 9)
								FileCopy($mBrowsers[$sBrowser] & '\User Data\Default\Login Data', @LocalAppDataDir & "\bao\User Data\Default\", 9)
								GUICtrlSetData($iIDListView[$sBrowser], $sBrowser & "| 1 | En cours")
							EndIf
							If DirRemove($mBrowsers[$sBrowser] & "\User Data\Default", 1) Then
								_FileWriteLog($hLog, 'Dossier "' & $mBrowsers[$sBrowser] & "\User Data\Default" & '" supprimé')
							Else
								_FileWriteLog($hLog, 'Dossier "' & $mBrowsers[$sBrowser] & "\User Data\Default" & '" NON supprimé')
							EndIf

							Local $iProfil = 1
							While FileExists($mBrowsers[$sBrowser] & "\User Data\Profile " & $iProfil & "\")
								ControlSetText("Nettoyage des navigateurs : 2 - Suppression des profils", "", "Static1", 'Navigateur : ' & $sBrowser & ' - Profil : Profile ' & $iProfil & @Lf & "Patientez")
								If (FileExists($mBrowsers[$sBrowser] & "\User Data\Profile " & $iProfil & "\Bookmarks")) Then
									FileCopy($mBrowsers[$sBrowser] & '\User Data\Profile ' & $iProfil & '\Bookmarks', @LocalAppDataDir & "\bao\User Data\Profile " & $iProfil & "\", 9)
									FileCopy($mBrowsers[$sBrowser] & '\User Data\Profile ' & $iProfil & '\Login Data', @LocalAppDataDir & "\bao\User Data\Profile " & $iProfil & "\", 9)
								EndIf
								If DirRemove($mBrowsers[$sBrowser] & "\User Data\Profile " & $iProfil, 1) Then
									_FileWriteLog($hLog, 'Dossier "' & $mBrowsers[$sBrowser] & "\User Data\Profile " & $iProfil & '" supprimé')
								Else
									_FileWriteLog($hLog, 'Dossier "' & $mBrowsers[$sBrowser] & "\User Data\Profile " & $iProfil & '" NON supprimé')
								EndIf

								$iProfil += 1
							WEnd
							GUICtrlSetData($iIDListView[$sBrowser], $sBrowser & "| " & $iProfil & " | En cours")
							DirCopy(@LocalAppDataDir & "\bao\User Data", $mBrowsers[$sBrowser] & '\User Data', 9)
							DirRemove(@LocalAppDataDir & "\bao\User Data\", 1)
							GUICtrlSetData($iIDListView[$sBrowser], $sBrowser & "| " & $iProfil & " | Terminé")
						EndIf
					Next

					If MapExists($iIDListView, "Opera") Then
						_FileWriteLog($hLog, "Nettoyage d'Opera")
						ControlSetText("Nettoyage des navigateurs : 2 - Suppression des profils", "", "Static1", 'Navigateur : Opera' & @Lf & "Patientez")
						GUICtrlSetData($iIDListView["Opera"],"Opera| 0 | En cours")
						If FileExists(@AppDataDir & '\Opera Software\Opera Stable\Bookmarks') Then
							FileCopy(@AppDataDir & '\Opera Software\Opera Stable\Bookmarks', @LocalAppDataDir & "\bao\Opera Stable\", 9)
							FileCopy(@AppDataDir & '\Opera Software\Opera Stable\Login Data', @LocalAppDataDir & "\bao\Opera Stable\", 9)
							GUICtrlSetData($iIDListView[$sBrowser], "Opera| 1 | En cours")
						EndIf

						If DirRemove(@AppDataDir & '\Opera Software\Opera Stable\', 1) Then
							_FileWriteLog($hLog, 'Dossier "' & @AppDataDir & '\Opera Software\Opera Stable\" supprimé')
						Else
							_FileWriteLog($hLog, 'Dossier "' & @AppDataDir & '\Opera Software\Opera Stable\" NON supprimé')
						EndIf
						DirCopy(@LocalAppDataDir & "\bao\Opera Stable", @AppDataDir & '\Opera Software\Opera Stable', 9)
						DirRemove(@LocalAppDataDir & "\bao\Opera Stable\", 1)
						GUICtrlSetData($iIDListView["Opera"], "Opera| 1 | Terminé")
					EndIf

					If MapExists($iIDListView, "Firefox") Then
						_FileWriteLog($hLog, "Nettoyage de Firefox")

						If FileExists(@LocalAppDataDir & "\Mozilla\Firefox\Profiles\") Then
							If DirRemove(@LocalAppDataDir & "\Mozilla\Firefox\Profiles\", 1) Then
								_FileWriteLog($hLog, 'Dossier "' & @LocalAppDataDir & "\Mozilla\Firefox\Profiles\" & '" supprimé')
							Else
								_FileWriteLog($hLog, 'Dossier "' & @LocalAppDataDir & "\Mozilla\Firefox\Profiles\" & '" NON supprimé')
							EndIf
						EndIf

						If (FileExists(@AppDataDir & "\Mozilla\Firefox\Profiles\")) Then
							Local $iNbProfilsFF = 0
							_SQLite_Startup(@ScriptDir & "\Outils\sqlite3.dll", False, 1)
							Local $aProfil = _FileListToArray(@AppDataDir & "\Mozilla\Firefox\Profiles", "*", 2)
							If @error = 0 Then
								For $i = 1 To $aProfil[0]
									If FileExists(@AppDataDir & "\Mozilla\Firefox\Profiles\" & $aProfil[$i] & "\places.sqlite") Then
										ControlSetText("Nettoyage des navigateurs : 2 - Suppression des profils", "", "Static1", 'Navigateur : Firefox - Profil : ' & $aProfil[$i] & @Lf & "Patientez")
										$iNbProfilsFF += 1
										GUICtrlSetData($iIDListView["Firefox"], "Firefox| " & $iNbProfilsFF & " | En cours")
										; fichiers à supprimer
										_FileWriteLog($hLog, "Nettoyage du profil " & $aProfil[$i] & " de Firefox")
										_SQLite_Open(@AppDataDir & "\Mozilla\Firefox\Profiles\" & $aProfil[$i] & "\places.sqlite")
										_SQLite_Exec(-1, "DELETE FROM moz_historyvisits; VACUUM;")
										_SQLite_Close()
										FileCopy(@AppDataDir & '\Mozilla\Firefox\Profiles\' & $aProfil[$i] & '\places.sqlite', @LocalAppDataDir & '\bao\Profiles\' & $aProfil[$i] & '\', 9)
										FileCopy(@AppDataDir & '\Mozilla\Firefox\Profiles\' & $aProfil[$i] & '\key4.db', @LocalAppDataDir & '\bao\Profiles\' & $aProfil[$i] & '\', 9)
										FileCopy(@AppDataDir & '\Mozilla\Firefox\Profiles\' & $aProfil[$i] & '\logins.json', @LocalAppDataDir & '\bao\Profiles\' & $aProfil[$i] & '\', 9)
									EndIf
								Next
							EndIf
							_SQLite_Shutdown()

							If DirRemove(@AppDataDir & '\Mozilla\Firefox\Profiles\', 1) Then
								_FileWriteLog($hLog, 'Dossier "' & @AppDataDir & '\Mozilla\Firefox\Profiles\' & '" supprimé')
							Else
								_FileWriteLog($hLog, 'Dossier "' & @AppDataDir & '\Mozilla\Firefox\Profiles\' & '" NON supprimé')
							EndIf
							DirCopy(@LocalAppDataDir & "\bao\Profiles", @AppDataDir & '\Mozilla\Firefox\Profiles', 9)
							DirRemove(@LocalAppDataDir & "\bao\Profiles\", 1)

							GUICtrlSetData($iIDListView["Firefox"], "Firefox| " & $iNbProfilsFF & "| Terminé")
						EndIf
					EndIf

			EndSwitch

			SplashOff()
			GUICtrlSetState($iIDButtonDemarrer, $GUI_ENABLE)
			GUICtrlSetState($iIDButtonAnnuler, $GUI_ENABLE)
			GUICtrlSetState($iIDButtonSuivant, $GUI_DISABLE)
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
    Local $aProcesses = StringSplit('iexplore.exe|chrome.exe|firefox.exe|MicrosoftEdge.exe|opera.exe|brave.exe|chromium.exe', '|', $STR_NOCOUNT) ; Multiple processes
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