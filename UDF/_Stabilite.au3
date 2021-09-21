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
	GUICtrlSetData($statusbar, " Tests en cours, patientez")

	Local $iIDrun, $sStress

	Local $hMat = GUICreate("Centre de tests", 1200, 600)
	GUICtrlCreateGroup("Choisissez un outil", 10, 10, 285,580)
	Local $iButtonMemoire = GUICtrlCreateButton("Test de mémoire vive", 20, 30, 265)
	Local $iButtonRess = GUICtrlCreateButton("Moniteur de ressources", 20, 60, 265)
	Local $iButtonFiabilite = GUICtrlCreateButton("Moniteur de fiabilité", 20, 90, 265)
	Local $iButtonStress = GUICtrlCreateButton("Stress test (Heavy Load)", 20, 120, 265)
	Local $iButtonHD = GUICtrlCreateButton("Test vitesse de disque (CrystalDiskMark)", 20, 150, 265)

	GUICtrlCreateGroup("Etat SMART des disques durs", 305, 10, 485,580)
	GUICtrlSetData($statusbar, " Tests en cours, patientez")
	GUICtrlSetData($statusbarprogress, 10)
	Local $sSmart = _GetSmart2(0)
	GUICtrlCreateEdit($sSmart, 315, 30, 465, 550)

	GUICtrlCreateGroup("Gestionnaire de périphériques", 800, 10, 390,300)
	Local $iBoutonGest = GUICtrlCreateButton("Ouvrir le gestionnaire de périphériques", 900, 30, 200)
	GUICtrlSetData($statusbarprogress, 50)
	Local $sDevProb = _DeviceProblems()
	GUICtrlCreateEdit($sDevProb, 810, 60, 370, 240)

	GUICtrlCreateGroup("Etats de veille", 800, 310, 390,280)
	Local $iBoutonHOn = GUICtrlCreateButton("Activer veille prolongée", 810, 330, 180)
	Local $iBoutonHOff = GUICtrlCreateButton("Désactiver veille prolongée", 1000, 330, 180)
	Local $iBoutonFastOn = GUICtrlCreateButton("Activer démarrage rapide", 810, 360, 180)
	Local $iBoutonFastOff = GUICtrlCreateButton("Désactiver démarrage rapide", 1000, 360, 180)
	GUICtrlSetData($statusbarprogress, 75)
	Local $sHib = _HibernateTest()
	Local $sEditPower = GUICtrlCreateEdit(_OEMToAnsi($sHib), 810, 390, 370, 190)

	GUICtrlSetData($statusbarprogress, 100)

	GUISetState(@SW_SHOW)

	GUICtrlSetData($statusbar, "")
	GUICtrlSetData($statusbarprogress, 0)

	Local $idMsgInst = GUIGetMsg()

	While ($idMsgInst <> $GUI_EVENT_CLOSE)

		Switch $idMsgInst

			Case $iButtonMemoire
				_TestsMemoire()

			Case $iButtonRess
				ShellExecute("perfmon", "/res")

			Case $iButtonFiabilite
				ShellExecute("perfmon", "/rel")

			Case $iBoutonGest
				ShellExecute("devmgmt.msc")

			Case $iButtonStress
				If @OSArch = "X64" Then
					$sStress = "HeavyLoad-x64"
				Else
					$sStress = "HeavyLoad-x86"
				EndIf

				If MapExists($aMenu, $sStress) Then
					If(_Telecharger($sStress, ($aMenu[$sStress])[2])) Then
						_Executer($sStress)
					EndIf
				Else
					_Attention($sStress & " n'existe pas dans les liens")
				EndIf

			Case $iButtonHD

				If MapExists($aMenu, "CrystalDiskMark.zip") Then
					If(_Telecharger("CrystalDiskMark.zip", ($aMenu["CrystalDiskMark.zip"])[2])) Then
						_Executer("CrystalDiskMark.zip")
					EndIf
				Else
					_Attention("CrystalDiskMark.zip n'existe pas dans les liens")
				EndIf

			Case $iBoutonHOn
				$iIDrun = Run( @ComSpec & ' /c powercfg /hibernate On', "",@SW_HIDE)
				ProcessWaitClose($iIDrun)
				$sHib = _HibernateTest()
				GUICtrlSetData($sEditPower, _OEMToAnsi($sHib))

			Case $iBoutonHOff
				$iIDrun = Run( @ComSpec & ' /c powercfg /hibernate Off', "",@SW_HIDE)
				ProcessWaitClose($iIDrun)
				$sHib = _HibernateTest()
				GUICtrlSetData($sEditPower, _OEMToAnsi($sHib))

			Case $iBoutonFastOn
				If RegWrite($HKLM & "\SYSTEM\CurrentControlSet\Control\Session Manager\Power","HiberbootEnabled","REG_DWORD", 1) Then
					$sHib = _HibernateTest()
					GUICtrlSetData($sEditPower, _OEMToAnsi($sHib))
				EndIf

			Case $iBoutonFastOff
				If RegWrite($HKLM & "\SYSTEM\CurrentControlSet\Control\Session Manager\Power","HiberbootEnabled","REG_DWORD", 0) Then
					$sHib = _HibernateTest()
					GUICtrlSetData($sEditPower, _OEMToAnsi($sHib))
				EndIf

		EndSwitch

		$idMsgInst = GUIGetMsg()
	WEnd

	GUIDelete($hMat)

	_ChangerEtatBouton($iIDAction, "Desactiver")
EndFunc

Func _TestsMemoire()

	Local $sTestRam = @WindowsDir &"\system32\MdSched.exe"
	If (@OSArch = "X64" and @AutoItX64 = 0) Then
		$sTestRam = @WindowsDir &"\sysnative\MdSched.exe"
	EndIf

	Local $hEventLog = _EventLog__Open("", "System")
	Local $iOffset = _EventLog__Read($hEventLog, True, False)
	_FichierCache("StabiliteTime", $iOffset)
	_EventLog__Close($hEventLog)

	ShellExecuteWait($sTestRam)

	_ChangerEtatBouton($iIDAction, "Desactiver")
EndFunc

Func _ResultatStabilite()
	Local $iOffset = _FichierCache("StabiliteTime")
	Local $hEventLog = _EventLog__Open("", "System")
	Local $aEvent = _EventLog__Read($hEventLog, False, True, $iOffset)

	Do
		If $aEvent[10] = "Microsoft-Windows-MemoryDiagnostics-Results" Then
			_Attention($aEvent[13])
			FileWriteLine($hFichierRapport, "Test de mémoire vive effectué : " & $aEvent[13])
			FileWriteLine($hFichierRapport, "")
			ExitLoop
		EndIf
		$aEvent = _EventLog__Read($hEventLog)
	Until $aEvent[0] = False

	If $aEvent[0] = False Then
		_Attention("Le résultat du test de mémoire vive n'a pas été trouvé dans le journal d'évènement", 1)
	EndIf

	_EventLog__Close($hEventLog)
EndFunc

Func _DeviceProblems()

	Local $DEVobjWMIService = ObjGet("winmgmts:\\" & "localhost" & "\root\cimv2")
	Local $DEVcolItems = $DEVobjWMIService.ExecQuery("Select * from Win32_PnPEntity " & "WHERE ConfigManagerErrorCode <> 0")
	Local $aErrorGest[31]
	$aErrorGest[0] = "Ce périphérique n’est pas configuré correctement. (1)"
	$aErrorGest[1] = "Windows ne peut pas charger le pilote de cet appareil. (2)"
	$aErrorGest[2] = "Le pilote de cet appareil est peut-être endommagé ou votre système ne dispose peut-être pas de suffisamment de mémoire ou d’autres ressources. (3)"
	$aErrorGest[3] = "Cet appareil ne fonctionne pas correctement. L’un de ses pilotes ou votre registre est peut-être endommagé. (4)"
	$aErrorGest[4] = "le pilote de cet appareil a besoin d’une ressource qui ne peut pas être gérée par Windows. (5)"
	$aErrorGest[5] = "La configuration de démarrage de cet appareil est en conflit avec d’autres appareils. (6)"
	$aErrorGest[6] = "Impossible de filtrer. (7)"
	$aErrorGest[7] = "Le chargeur de pilote de l’appareil est manquant. (8)"
	$aErrorGest[8] = "Ce périphérique ne fonctionne pas correctement, car le microprogramme de contrôle ne signale pas correctement les ressources pour l’appareil. (9)"
	$aErrorGest[9] = "Impossible de démarrer cet appareil. (10)"
	$aErrorGest[10] = "Échec de cet appareil. (11)"
	$aErrorGest[11] = "Ce périphérique ne peut pas trouver suffisamment de ressources disponibles. (12)"
	$aErrorGest[12] = "Windows ne pouvez pas vérifier les ressources de ce périphérique. (13)"
	$aErrorGest[13] = "Ce périphérique ne peut pas fonctionner correctement tant que vous n’avez pas redémarré votre ordinateur. (14)"
	$aErrorGest[14] = "Cet appareil ne fonctionne pas correctement en raison d’un problème de réénumération. (15)"
	$aErrorGest[15] = "Windows ne peut pas identifier toutes les ressources utilisées par cet appareil. (16)"
	$aErrorGest[16] = "Ce périphérique demande un type de ressource inconnu. (17)"
	$aErrorGest[17] = "Réinstallez les pilotes pour cet appareil. (18)"
	$aErrorGest[18] = "Échec lors de l’utilisation du chargeur VxD. (19)"
	$aErrorGest[19] = "Votre registre est peut-être endommagé. (20)"
	$aErrorGest[20] = "Défaillance du système : essayez de modifier le pilote de cet appareil. Si cela ne fonctionne pas, consultez la documentation de votre matériel. Windows supprime cet appareil. (21)"
	$aErrorGest[21] = "Cet appareil est désactivé. (22)"
	$aErrorGest[22] = "Défaillance du système : essayez de modifier le pilote de cet appareil. Si cela ne fonctionne pas, consultez la documentation de votre matériel. (23)"
	$aErrorGest[23] = "Ce périphérique n’est pas présent, ne fonctionne pas correctement ou tous ses pilotes ne sont pas installés. (24)"
	$aErrorGest[24] = "Windows est toujours en cours d’installation sur cet appareil. (25)"
	$aErrorGest[25] = "Windows est toujours en cours d’installation sur cet appareil. (26))"
	$aErrorGest[26] = "Cet appareil n’a pas de configuration de journal valide. (27)"
	$aErrorGest[27] = "Les pilotes de cet appareil ne sont pas installés. (28)"
	$aErrorGest[28] = "Ce périphérique est désactivé, car le microprogramme de l’appareil ne lui a pas donné les ressources requises. (29)"
	$aErrorGest[29] = "Cet appareil utilise une ressource de demande d’interruption (IRQ) qu’un autre appareil utilise. (30)"
	$aErrorGest[30] = "cet appareil ne fonctionne pas correctement car Windows ne peut pas charger les pilotes requis pour cet appareil. (31)"

	Local $retour

	For $DEVobjItem in $DEVcolItems
		$retour = $retour & $DEVobjItem.name & ": " & @CRLF & "  - " & $DEVobjItem.DeviceID & @CRLF & "  - " & $aErrorGest[$DEVobjItem.ConfigManagerErrorCode - 1] & @CRLF & @CRLF
	Next

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