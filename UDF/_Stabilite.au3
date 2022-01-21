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

Func _TestsStabilite()

	_FichierCache("Stabilite", $iIDAction)
	_ChangerEtatBouton($iIDAction, "Patienter")
	GUICtrlSetData($statusbar, "Contrôles en cours, patientez")

	Local $iIDrun, $sStress, $sOutput, $aAssoc[0][2], $hAssoc, $iBoutonInput, $iBoutonAssoc, $sReadComboFile, $sComboDoc, $sReadInput, $sReadComboVeille, $sComboDefaut, $sDevProb, $hFileConfig, $aDefautAsso

	$aDefautAsso = _ArrayFromString(IniRead($sConfig, "Associations", "Defaut", ""), ",")
	Local $hMat = GUICreate("Centre de contrôles", 1200, 600)
	GUICtrlCreateGroup("Choisissez un outil", 10, 10, 380, 190)
	GUICtrlSetFont (-1, 9, 800)
	Local $iButtonMemoire = GUICtrlCreateButton("Test de mémoire vive", 20, 30, 360)
	Local $iButtonRess = GUICtrlCreateButton("Moniteur de ressources", 20, 60, 360)
	Local $iButtonFiabilite = GUICtrlCreateButton("Moniteur de fiabilité", 20, 90, 360)

	GUICtrlCreateGroup("Association de fichiers", 10, 200, 380,390)
	GUICtrlSetFont (-1, 9, 800)
	GUICtrlSetData($statusbarprogress, 25)
	Local $iBoutonAff = GUICtrlCreateButton("Afficher toutes les associations du système", 20, 220, 360)
	Local $iBoutonMod = GUICtrlCreateButton("Modifier les fichiers de configuration", 20, 250, 360)

	GUICtrlCreateLabel("Choississez vos réglages : ", 20, 280)

	Local $aDossiersAssoc = _FileListToArray(@ScriptDir & "\Config\Associations\", "*", 2)
	Local $aFichiers

	Local $k, $l, $iCombo[0], $iIndex

	If IsArray($aDossiersAssoc) Then
		For $k = 1 To $aDossiersAssoc[0]

			$aFichiers = _FileListToArray(@ScriptDir & "\Config\Associations\" & $aDossiersAssoc[$k], "*.txt", 1)
			_ArrayAdd($iCombo, GUICtrlCreateCombo($aDossiersAssoc[$k], 20, 275 + ($k * 25), 175))
		Next
	EndIf

	GUICtrlCreateLabel("Configuration actuelle du système: ", 205, 280)
	Local $sEditAssoc = GUICtrlCreateEdit("", 205, 300, 175, 240, $ES_READONLY)
	Local $iBoutonAssocALL = GUICtrlCreateButton("Appliquer", 20, 275 + ($k * 25), 175)
	$k = 1
	GUICtrlCreateGraphic(20, 545, 360, 1, $SS_BLACKRECT)

	$iBoutonInput = GUICtrlCreateInput("", 20, 555, 175, 25)
	$iBoutonAssoc = GUICtrlCreateButton("Appliquer cette association", 205, 555, 175)

	GUICtrlCreateGroup("Etat SMART des disques durs", 400, 10, 390,380)
	GUICtrlSetFont (-1, 9, 800)
	_FileWriteLog($hLog, 'Vérification SMART dans le centre de contrôles')
	Local $sSmart = _GetSmart2(0)
	GUICtrlCreateEdit(StringReplace($sSmart, "[BR]", @CRLF & @TAB), 410, 30, 370, 350)

	GUICtrlCreateGroup("Alignement SSD", 400, 390, 390,200)
	GUICtrlSetFont (-1, 9, 800)
	Local $hRichEdit = _GUICtrlRichEdit_Create($hMat, "", 410, 410, 370, 170,  BitOR($ES_MULTILINE, $WS_VSCROLL))
	_FileWriteLog($hLog, 'Vérification alignement SSD')
	_AlignementSSD($hRichEdit)

	GUICtrlCreateGroup("Gestionnaire de périphériques", 800, 10, 390,190)
	GUICtrlSetFont (-1, 9, 800)
	Local $iBoutonGest = GUICtrlCreateButton("Ouvrir le gestionnaire de périphériques", 900, 30, 200)
	GUICtrlSetData($statusbarprogress, 50)
	_FileWriteLog($hLog, 'Recherche des erreurs du gestionnaire de périphériques')
	$sDevProb = _DeviceProblems()
	GUICtrlCreateEdit($sDevProb, 810, 60, 370, 130)

	GUICtrlCreateGroup("Etats de veille", 800, 200, 390,190)
	GUICtrlSetFont (-1, 9, 800)
	Local $iBoutonComboVeille = GUICtrlCreateCombo("Activer veille prolongée AVEC démarrage rapide", 810, 220, 370, Default,$CBS_DROPDOWNLIST)
	 GUICtrlSetData($iBoutonComboVeille, "Activer veille prolongée SANS démarrage rapide|Désactiver veille prolongée")
	Local $iBoutonVeille = GUICtrlCreateButton("Appliquer", 910, 250, 180)

	GUICtrlSetData($statusbarprogress, 75)
	_FileWriteLog($hLog, 'Vérification états veille')
	Local $sHib = _HibernateTest()
	Local $sEditPower = GUICtrlCreateEdit(_OEMToAnsi($sHib), 810, 280, 370, 100)

	GUICtrlCreateGroup("Indices de performance", 800, 390, 390,200)
	GUICtrlSetFont (-1, 9, 800)
	Local $iBoutonCalc = GUICtrlCreateButton("Calculer les indices de performance", 910, 410, 180)
	Local $sEditPerf = GUICtrlCreateEdit("", 810, 440, 370, 140)

	GUICtrlSetData($statusbarprogress, 100)

	GUISetState(@SW_SHOW)
	Local $m, $aAssocTMP
	If IsArray($aDossiersAssoc) Then
		For $l = 1 To Ubound($iCombo)

			$aFichiers = _FileListToArray(@ScriptDir & "\Config\Associations\" & $aDossiersAssoc[$l], "*.txt", 1)

			If IsArray($aFichiers) Then
				GUICtrlSetData($iCombo[$l-1], _ArrayToString($aFichiers, "|", 1))

				If($l-1 < UBound($aDefautAsso) And $aDefautAsso[$l-1] <= $aFichiers[0] And $aDefautAsso[$l-1] <> 0) Then
					_GUICtrlComboBox_SetCurSel ($iCombo[$l-1], $aDefautAsso[$l-1])
				EndIf
				For $m = 1 To $aFichiers[0]
					_FileReadToArray(@ScriptDir & "\Config\Associations\" & $aDossiersAssoc[$l] & "\" & $aFichiers[$m], $aAssocTMP, 4, ", ")
					_ArrayAdd($aAssoc, $aAssocTMP)
					if @error Then
						_Attention(@error)
					EndIf
				Next
				$m = 1
			EndIf
		Next

	EndIf

	_GetConfigAssoc($aAssoc, $sEditAssoc)

	GUICtrlSetData($statusbar, "")
	GUICtrlSetData($statusbarprogress, 0)

	Local $idMsgInst = GUIGetMsg()

	While ($idMsgInst <> $GUI_EVENT_CLOSE)

		Switch $idMsgInst

			Case $iButtonMemoire
				_FileWriteLog($hLog, 'Test de mémoire vive demandé')
				_TestsMemoire()

			Case $iButtonRess
				ShellExecute("perfmon", "/res")

			Case $iButtonFiabilite
				ShellExecute("perfmon", "/rel")

			Case $iBoutonGest
				ShellExecute("devmgmt.msc")

			Case $iBoutonAff
				Run( @ComSpec & ' /k "' & @ScriptDir & '\Outils\SetUserFTA\SetUserFTA.exe" get')

			Case $iBoutonMod
				GUICtrlSetState($iBoutonMod, $GUI_DISABLE)
				ShellExecute(@ScriptDir & "\Config\Associations\")
				ExitLoop

			Case $iBoutonAssocALL
				GUICtrlSetState($iBoutonAssocALL, $GUI_DISABLE)
				For $combo in $iCombo
					$sReadComboFile = GUICtrlRead($combo)
					$sComboDoc = _GUICtrlComboBox_SetCurSel ($combo, 0)
					If (StringRight($sReadComboFile, 4)  = ".txt") Then
						_FileWriteLog($hLog, 'Association avec fichier config "' & $sReadComboFile & '"')
						Run( @ComSpec & ' /c ""' & @ScriptDir & '\Outils\SetUserFTA\SetUserFTA.exe" "' & @ScriptDir & "\Config\Associations\" & GUICtrlRead($combo) & "\" & $sReadComboFile & '""', "", @SW_HIDE)
					EndIf
				Next
				_GetConfigAssoc($aAssoc, $sEditAssoc)
				GUICtrlSetState($iBoutonAssocALL, $GUI_ENABLE)

			Case $iBoutonAssoc
				$sReadInput = GUICtrlRead($iBoutonInput)
				If $sReadInput <> "" And StringInStr($sReadInput, ",") Then
					GUICtrlSetState($iBoutonAssoc, $GUI_DISABLE)
					_FileWriteLog($hLog, 'Association manuelle : ' & $sReadInput)
					Run( @ComSpec & ' /c "' & @ScriptDir & '\Outils\SetUserFTA\SetUserFTA.exe" ' & StringReplace($sReadInput, ", ", " "), "", @SW_HIDE)
					_GetConfigAssoc($aAssoc, $sEditAssoc)
					GUICtrlSetState($iBoutonAssoc, $GUI_ENABLE)
				Else
					_Attention("Le format est incorrect")
				EndIf

			Case $iBoutonVeille
				GUICtrlSetState($iBoutonVeille, $GUI_DISABLE)
				$sReadComboVeille = GUICtrlRead($iBoutonComboVeille)
				_FileWriteLog($hLog, 'Changement veille')
				Switch $sReadComboVeille
					Case "Activer veille prolongée AVEC démarrage rapide"
						$iIDrun = Run( @ComSpec & ' /c powercfg /hibernate On', "",@SW_HIDE)
						ProcessWaitClose($iIDrun)
						If RegRead($HKLM & "\SYSTEM\CurrentControlSet\Control\Session Manager\Power\","HiberbootEnabled") = 0 Then
							RegWrite($HKLM & "\SYSTEM\CurrentControlSet\Control\Session Manager\Power","HiberbootEnabled","REG_DWORD", 1)
						EndIf
						$sHib = _HibernateTest()
						GUICtrlSetData($sEditPower, _OEMToAnsi($sHib))

					Case "Activer veille prolongée SANS démarrage rapide"
						$iIDrun = Run( @ComSpec & ' /c powercfg /hibernate On', "",@SW_HIDE)
						ProcessWaitClose($iIDrun)
						If RegRead($HKLM & "\SYSTEM\CurrentControlSet\Control\Session Manager\Power\","HiberbootEnabled") = 1 Then
							RegWrite($HKLM & "\SYSTEM\CurrentControlSet\Control\Session Manager\Power","HiberbootEnabled","REG_DWORD", 0)
						EndIf
						$sHib = _HibernateTest()
						GUICtrlSetData($sEditPower, _OEMToAnsi($sHib))

					Case "Désactiver veille prolongée"
						If RegRead($HKLM & "\SYSTEM\CurrentControlSet\Control\Session Manager\Power\","HiberbootEnabled") = 0 Then
							RegWrite($HKLM & "\SYSTEM\CurrentControlSet\Control\Session Manager\Power","HiberbootEnabled","REG_DWORD", 1)
						EndIf
						$iIDrun = Run( @ComSpec & ' /c powercfg /hibernate Off', "",@SW_HIDE)
						ProcessWaitClose($iIDrun)
						$sHib = _HibernateTest()
						GUICtrlSetData($sEditPower, _OEMToAnsi($sHib))

				EndSwitch
				GUICtrlSetState($iBoutonVeille, $GUI_ENABLE)

			Case $iBoutonCalc
				_FileWriteLog($hLog, 'Calcul des indices de performance')
				GUICtrlSetState($iBoutonCalc, $GUI_DISABLE)
				$iIDrun = Run( @ComSpec & ' /c winsat prepop')
				ProcessWaitClose($iIDrun)
				$iIDrun = Run(@ComSpec & ' /c ' & '@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -command "GET-WMIOBJECT WIN32_WINSAT | SELECT-OBJECT CPUSCORE,D3DSCORE,DISKSCORE,GRAPHICSSCORE,MEMORYSCORE"', "", "", $STDIN_CHILD + $STDOUT_CHILD + $STDERR_CHILD)
				StdinWrite($iIDrun)
				;ClipPut(@ComSpec & ' /c ' & '@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -command "GET-WMIOBJECT WIN32_WINSAT | SELECT-OBJECT CPUSCORE,D3DSCORE,DISKSCORE,GRAPHICSSCORE,MEMORYSCORE"')
				 While 1
					$sOutput = StdoutRead($iIDrun)
					If @error Then ExitLoop
					If $sOutput <> "" Then
						_GUICtrlEdit_AppendText($sEditPerf, $sOutput)
						;FileWriteLine($hFichierRapport, "[SCORE]" &  $sOutput & "[/SCORE]")
					EndIf
				 WEnd
				 GUICtrlSetState($iBoutonCalc, $GUI_ENABLE)

		EndSwitch

		$idMsgInst = GUIGetMsg()
	WEnd

	GUIDelete($hMat)

	_ChangerEtatBouton($iIDAction, "Activer")
EndFunc

Func _TestsMemoire()

	_FileWriteLog($hLog, 'Test de mémoire vive démarré')
	_UpdEdit($iIDEditLog, $hLog)
	Local $sTestRam = @WindowsDir &"\system32\MdSched.exe"
	If (@OSArch = "X64" and @AutoItX64 = 0) Then
		$sTestRam = @WindowsDir &"\sysnative\MdSched.exe"
	EndIf

	Local $hEventLog = _EventLog__Open("", "System")
	Local $iOffset = _EventLog__Read($hEventLog, True, False)
	If(IsArray($iOffset) And $iOffset[0]) Then
		_FichierCache("StabiliteTime", $iOffset[1])
	EndIf
	_EventLog__Close($hEventLog)

	ShellExecuteWait($sTestRam)

	_ChangerEtatBouton($iIDAction, "Desactiver")
EndFunc

Func _ResultatStabilite()
	Local $iOffset = _FichierCache("StabiliteTime")
	Local $hEventLog = _EventLog__Open("", "System")
	Local $aEvent = _EventLog__Read($hEventLog, False, True, $iOffset)

	$sSplashTxt = $sSplashTxt & @LF & "Recherche résultat du test de mémoire vive"
	ControlSetText("Initialisation de BAO", "", "Static1", $sSplashTxt)

	If IsArray($aEvent) Then
		Do
			If $aEvent[10] = "Microsoft-Windows-MemoryDiagnostics-Results" Then
				_FileWriteLog($hLog, 'Résultat du test de mémoire vive : ' & $aEvent[13])
				_UpdEdit($iIDEditLog, $hLog)
				ExitLoop
			EndIf
			$aEvent = _EventLog__Read($hEventLog)
		Until $aEvent[0] = False

		If $aEvent[0] = False Then
			_Attention("Le résultat du test de mémoire vive n'a pas été trouvé dans le journal d'évènement", 1)
			_FileWriteLog($hLog, "Le résultat du test de mémoire vive n'a pas été trouvé dans le journal d'évènement")
		EndIf
	Else
		_Attention("Le résultat du test de mémoire vive n'a pas été trouvé dans le journal d'évènement (Offset = "&$iOffset&")", 1)
		_FileWriteLog($hLog, "Le résultat du test de mémoire vive n'a pas été trouvé dans le journal d'évènement (Offset = "&$iOffset&")")
	EndIf

	_EventLog__Close($hEventLog)
EndFunc

Func _DeviceProblems()

	Local $DEVobjWMIService = ObjGet("winmgmts:\\" & "localhost" & "\root\cimv2")
	Local $DEVcolItems = $DEVobjWMIService.ExecQuery("Select * from Win32_PnPEntity " & "WHERE ConfigManagerErrorCode <> 0")
	Local $aErrorGest[31]
	$aErrorGest[0] = "Ce périphérique n'est pas configuré correctement. (1)"
	$aErrorGest[1] = "Windows ne peut pas charger le pilote de cet appareil. (2)"
	$aErrorGest[2] = "Le pilote de cet appareil est peut-être endommagé ou votre système ne dispose peut-être pas de suffisamment de mémoire ou d'autres ressources. (3)"
	$aErrorGest[3] = "Cet appareil ne fonctionne pas correctement. L'un de ses pilotes ou votre registre est peut-être endommagé. (4)"
	$aErrorGest[4] = "le pilote de cet appareil a besoin d'une ressource qui ne peut pas être gérée par Windows. (5)"
	$aErrorGest[5] = "La configuration de démarrage de cet appareil est en conflit avec d'autres appareils. (6)"
	$aErrorGest[6] = "Impossible de filtrer. (7)"
	$aErrorGest[7] = "Le chargeur de pilote de l'appareil est manquant. (8)"
	$aErrorGest[8] = "Ce périphérique ne fonctionne pas correctement, car le microprogramme de contrôle ne signale pas correctement les ressources pour l'appareil. (9)"
	$aErrorGest[9] = "Impossible de démarrer cet appareil. (10)"
	$aErrorGest[10] = "Échec de cet appareil. (11)"
	$aErrorGest[11] = "Ce périphérique ne peut pas trouver suffisamment de ressources disponibles. (12)"
	$aErrorGest[12] = "Windows ne pouvez pas vérifier les ressources de ce périphérique. (13)"
	$aErrorGest[13] = "Ce périphérique ne peut pas fonctionner correctement tant que vous n'avez pas redémarré votre ordinateur. (14)"
	$aErrorGest[14] = "Cet appareil ne fonctionne pas correctement en raison d'un problème de réénumération. (15)"
	$aErrorGest[15] = "Windows ne peut pas identifier toutes les ressources utilisées par cet appareil. (16)"
	$aErrorGest[16] = "Ce périphérique demande un type de ressource inconnu. (17)"
	$aErrorGest[17] = "Réinstallez les pilotes pour cet appareil. (18)"
	$aErrorGest[18] = "Échec lors de l'utilisation du chargeur VxD. (19)"
	$aErrorGest[19] = "Votre registre est peut-être endommagé. (20)"
	$aErrorGest[20] = "Défaillance du système : essayez de modifier le pilote de cet appareil. Si cela ne fonctionne pas, consultez la documentation de votre matériel. Windows supprime cet appareil. (21)"
	$aErrorGest[21] = "Cet appareil est désactivé. (22)"
	$aErrorGest[22] = "Défaillance du système : essayez de modifier le pilote de cet appareil. Si cela ne fonctionne pas, consultez la documentation de votre matériel. (23)"
	$aErrorGest[23] = "Ce périphérique n'est pas présent, ne fonctionne pas correctement ou tous ses pilotes ne sont pas installés. (24)"
	$aErrorGest[24] = "Windows est toujours en cours d'installation sur cet appareil. (25)"
	$aErrorGest[25] = "Windows est toujours en cours d'installation sur cet appareil. (26))"
	$aErrorGest[26] = "Cet appareil n'a pas de configuration de journal valide. (27)"
	$aErrorGest[27] = "Les pilotes de cet appareil ne sont pas installés. (28)"
	$aErrorGest[28] = "Ce périphérique est désactivé, car le microprogramme de l'appareil ne lui a pas donné les ressources requises. (29)"
	$aErrorGest[29] = "Cet appareil utilise une ressource de demande d'interruption (IRQ) qu'un autre appareil utilise. (30)"
	$aErrorGest[30] = "cet appareil ne fonctionne pas correctement car Windows ne peut pas charger les pilotes requis pour cet appareil. (31)"

	Local $retour

	If IsObj($DEVcolItems) Then
		For $DEVobjItem in $DEVcolItems
			If($DEVobjItem.ConfigManagerErrorCode <> "" And $DEVobjItem.ConfigManagerErrorCode < 31) Then
				$retour = $retour & $DEVobjItem.name & ": " & @CRLF & "  - " & $DEVobjItem.DeviceID & @CRLF & "  - " & $aErrorGest[$DEVobjItem.ConfigManagerErrorCode - 1] & @CRLF & @CRLF
			Else
				_Attention("Code d'erreur inconnu dans le gestionnaire de périphérique : " & $DEVobjItem.ConfigManagerErrorCode)
				$retour = $retour & $DEVobjItem.name & ": " & @CRLF & "  - " & $DEVobjItem.DeviceID & @CRLF & "  - Erreur inconnue (" & $DEVobjItem.ConfigManagerErrorCode & ")" & @CRLF & @CRLF
			EndIf
		Next
	Else
		_Attention("Impossible de vérifier si le gestionnaire de périphériques contient des erreurs")
		$retour = "Vérification du gestionnaire de périphériques impossible"
	EndIf

	If $retour = "" Then
		$retour = "Aucun problème n'a été détecté dans le gestionnaire de périphériques"
	EndIf

	Return $retour
EndFunc

Func _HibernateTest()
	Local $iPidpower = Run( @ComSpec & ' /c powercfg /a', "",@SW_HIDE, $STDOUT_CHILD)
	ProcessWaitClose($iPidpower)
	Local $sOutput = StdoutRead($iPidpower)
	Return $sOutput
EndFunc

Func _GetConfigAssoc($aAssoc, $iIDEdit)

	Local $sConfigA, $iPidAssoc, $sOutput, $aAllAssoc, $aExtToSearch, $iPos

	If IsArray($aAssoc) Then
		$aExtToSearch = _ArrayUnique($aAssoc)
		Sleep(500)
		$iPidAssoc = Run( @ComSpec & ' /c "' & @ScriptDir & '\Outils\SetUserFTA\SetUserFTA.exe" get', "",@SW_HIDE, $STDOUT_CHILD)
		ProcessWaitClose($iPidAssoc)
		Sleep(500)
		$sOutput = StdoutRead($iPidAssoc)

		$aAllAssoc = _ArrayFromString($sOutput, ", ", @CRLF)

		For $sExt In $aExtToSearch
			$iPos = _ArraySearch($aAllAssoc, $sExt, 0, 0, 0, 0, 1, 0)
			If $ipos <> -1 Then
				$sConfigA &= $aAllAssoc[$iPos][0] & ", " & $aAllAssoc[$iPos][1] & @CRLF
			EndIf
		Next


;~ 		For $sConfpc in $aAllAssoc
;~ 			If _ArraySearch($aAssoc, StringLeft($sConfpc, StringInStr($sConfpc, ",") -1), 0, 0, 0, 0, 1, 0) <> -1 Then
;~ 				$sConfigA &= $sConfpc & @CRLF
;~ 			EndIf
;~ 		Next
 		GUICtrlSetData($iIDEdit, $sConfigA)
	EndIf

EndFunc

Func _AlignementSSD($iIDEditAlign)

	local $aDisk[0][2]
	Dim $Obj_WMIService = ObjGet("winmgmts:\\" & "localhost" & "\root\Microsoft\Windows\Storage")
	If @error = 0 Then
		Dim $Obj_Services = $Obj_WMIService.ExecQuery("Select * from MSFT_PhysicalDisk")

		Local $sColor = "0x006600", $sOffset = "Aligné", $y = 410, $j = 0, $isize

		For $Obj_Item In $Obj_Services
			If $Obj_Item.MediaType=4 Then
				ReDim $aDisk[$j + 1][2]
				$aDisk[$j][0] = $Obj_Item.DeviceId
				$aDisk[$j][1] = $Obj_Item.FriendlyName
				$j+=1
			EndIf
		Next

		If UBound($aDisk) > 0 Then
			For $i=0 To UBound($aDisk)-1
				_GUICtrlRichEdit_WriteLine($iIDEditAlign, "Disque " & $aDisk[$i][0] & " : " & $aDisk[$i][1], 0, "", "0x000000")
				Dim $Obj_Services = $Obj_WMIService.ExecQuery("Select * from MSFT_Partition where DiskNumber = " & $aDisk[$i][0])
				Local $Obj_Item
				For $Obj_Item In $Obj_Services
					$isize = Round($Obj_Item.Size / (1024 * 1024 * 1024))
					If $isize > 1 Then
						If IsFloat($Obj_Item.Offset / 1024) Then
							$sOffset = "Non aligné"
							$sColor = "0xff0000"
						EndIf

						_GUICtrlRichEdit_WriteLine($iIDEditAlign, @TAB & "Partition " & $Obj_Item.PartitionNumber & " (" & Round($Obj_Item.Size / (1024 * 1024 * 1024)) & " Go) : " & $sOffset, 0, "", $sColor)
					EndIf
				Next
				_GUICtrlRichEdit_AppendText($iIDEditAlign, @CRLF)
			Next
		EndIf
	Else
		_GUICtrlRichEdit_AppendText($iIDEditAlign, "Erreur : ne peut être vérifié avec cet outil")
	EndIf
EndFunc