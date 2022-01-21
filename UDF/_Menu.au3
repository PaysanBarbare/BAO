#cs

Copyright 2021 Bastien Rouches

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

Func _MenuAdd()

	Local $aListDoc = _FileListToArrayRec(@ScriptDir & "\Logiciels\", "*.ini", 1, 0, 1)
	If $aListDoc = "" Then
		_Attention("Ajoutez d'abord un dossier")
	Else
		Local $sLien, $iCombo, $sCombo, $aEnr[13], $sNameL, $sTmpdom, $sFolderLog, $bChoco = False
		Local $hGUIMenu = GUICreate("Ajout de logiciel", 600, 240)
		GUICtrlCreateLabel("Nom du logiciel :", 10, 10)
		Local $iNomLogiciel = GUICtrlCreateInput("", 160, 8, 140)

		GUICtrlCreateLabel("Ajouter au dossier :", 320, 10)
		$iCombo = GUICtrlCreateCombo(StringTrimRight($aListDoc[1], 4), 450, 8, 140, default, $CBS_DROPDOWNLIST)
		If $aListDoc[0] > 1 Then
			$sCombo = _ArrayToString($aListDoc, "|", 2)
			$sCombo = StringReplace($sCombo, ".ini", "")
			GUICtrlSetData($iCombo, $sCombo)
		EndIf

		If(StringLeft(ClipGet(), 4) = "http") Then
			$sLien = ClipGet()
			$sNameL = StringRegExpReplace($sLien, "^.*/", "")
			If StringInStr($sNameL, ".") <> 0 And $sNameL <> "" Then
				GUICtrlSetData($iNomLogiciel, StringLeft($sNameL, StringInStr($sNameL, ".") - 1))
			EndIf
		ElseIf(StringLeft(ClipGet(), 14) = "choco install ") Then
			$sLien = "choco"
			$sNameL = StringTrimLeft(ClipGet(), 14)
			If $sNameL <> "" Then
				GUICtrlSetData($iNomLogiciel, $sNameL)
			EndIf
		EndIf
		GUICtrlCreateLabel("Lien (direct ou page parente) :", 10, 40)
		Local $iLien = GUICtrlCreateInput($sLien, 160, 38, 230)
		Local $iBrowse = GUICtrlCreateButton("Parcourir", 400, 35, 80)
		Local $iTest = GUICtrlCreateCheckbox("Tester le lien", 490, 35)

		GUICtrlCreateGroup("Réglages avancés", 10, 70, 580, 135)
		Local $iFavoris = GUICtrlCreateCheckbox("Ajouter aux favoris", 20, 90)
		Local $iSite = GUICtrlCreateCheckbox("Ouvrir dans le navigateur", 20, 110)
		Local $iNepasmaj = GUICtrlCreateCheckbox("Ne pas mettre à jour", 20, 130)
		Local $iDomaine = GUICtrlCreateCheckbox("Domaine pour les liens relatifs :", 20, 150)
		GUICtrlCreateLabel("Téléchargement indirect : le lien contient ", 20, 180)
		Local $sExp = GUICtrlCreateInput("", 220, 177, 120)
		GUICtrlCreateLabel("mais ne contient pas ", 350, 180)
		Local $sExpnot = GUICtrlCreateInput("", 460, 177, 120)
		Local $iHeaders = GUICtrlCreateCheckbox("Activer headers HTTP", 300, 90)
		Local $iMdp = GUICtrlCreateCheckbox("Rechercher mot de passe dans le source", 300, 110)
		Local $iForcedl = GUICtrlCreateCheckbox("Forcer le téléchargement (précisez l'extension)", 300, 130)
		GUICtrlCreateLabel("Extension (téléchargement forcé ou indirect) : ", 320, 153)
		Local $sExtension = GUICtrlCreateInput("", 545, 150, 35)
		GUICtrlSetLimit(-1, 3)
		Local $sDomaine = GUICtrlCreateInput("https://", 185, 150, 105)
		Local $iIDButtonAnnuler = GUICtrlCreateButton("Annuler", 210, 210, 80, 25)
		Local $iIDButtonDemarrer = GUICtrlCreateButton("Ajouter", 310, 210, 80, 25, $BS_DEFPUSHBUTTON)
		GUISetState(@SW_SHOW)

		Local $eGet = GUIGetMsg()

		While $eGet <> $GUI_EVENT_CLOSE And $eGet <> $iIDButtonAnnuler
			Switch $eGet
				Case $iBrowse
					$sFolderLog = FileOpenDialog("Sélectionner un exécutable", "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}", "Tous les fichiers (*.*)")
					GUICtrlSetData($iLien, $sFolderLog)

				Case $iSite
					If(GUICtrlRead($iSite) = $GUI_CHECKED) Then
						GUICtrlSetState($iNepasmaj, BitOR($GUI_DISABLE, $GUI_UNCHECKED))
						GUICtrlSetState($iForcedl, BitOR($GUI_DISABLE, $GUI_UNCHECKED))
						GUICtrlSetState($sExtension, $GUI_DISABLE)
						GUICtrlSetState($sExp, $GUI_DISABLE)
						GUICtrlSetState($sExpnot, $GUI_DISABLE)
						GUICtrlSetState($iHeaders, BitOR($GUI_DISABLE, $GUI_UNCHECKED))
						GUICtrlSetState($iMdp, BitOR($GUI_DISABLE, $GUI_UNCHECKED))
						GUICtrlSetState($iDomaine, BitOR($GUI_DISABLE, $GUI_UNCHECKED))
						GUICtrlSetState($sDomaine, $GUI_DISABLE)
					Else
						GUICtrlSetState($iNepasmaj, $GUI_ENABLE)
						GUICtrlSetState($iForcedl, $GUI_ENABLE)
						GUICtrlSetState($sExtension, $GUI_ENABLE)
						GUICtrlSetState($sExp, $GUI_ENABLE)
						GUICtrlSetState($sExpnot, $GUI_ENABLE)
						GUICtrlSetState($iHeaders, $GUI_ENABLE)
						GUICtrlSetState($iMdp, $GUI_ENABLE)
						GUICtrlSetState($iDomaine, $GUI_ENABLE)
						GUICtrlSetState($sDomaine, $GUI_ENABLE)
					EndIf
				Case $iForcedl
					If(GUICtrlRead($iForcedl) = $GUI_CHECKED) Then
						GUICtrlSetState($iSite, $GUI_DISABLE)
					Else
						GUICtrlSetState($iSite, $GUI_ENABLE)
					EndIf
				Case $iHeaders
					If(GUICtrlRead($iHeaders) = $GUI_CHECKED) Then
						GUICtrlSetState($iSite, $GUI_DISABLE)
					Else
						GUICtrlSetState($iSite, $GUI_ENABLE)
					EndIf

				Case $iNepasmaj
					If(GUICtrlRead($iNepasmaj) = $GUI_CHECKED) Then
						GUICtrlSetState($iSite, $GUI_DISABLE)
					Else
						GUICtrlSetState($iSite, $GUI_ENABLE)
					EndIf

				Case $iMdp
					If(GUICtrlRead($iMdp) = $GUI_CHECKED) Then
						GUICtrlSetState($iSite, $GUI_DISABLE)
					Else
						GUICtrlSetState($iSite, $GUI_ENABLE)
					EndIf

				Case $iDomaine
					If(GUICtrlRead($iDomaine) = $GUI_CHECKED) Then
						$sTmpdom = StringLeft(GUICtrlRead($iLien), StringInStr(GUICtrlRead($iLien), "/", 0, 3))
						GUICtrlSetData($sDomaine, $sTmpdom)
						GUICtrlSetState($iSite, $GUI_DISABLE)
					Else
						GUICtrlSetState($iSite, $GUI_ENABLE)
					EndIf

				Case $iIDButtonDemarrer
					$aEnr[1] = GUICtrlRead($iNomLogiciel)
					$aEnr[2] = GUICtrlRead($iLien)

					If MapExists($aMenu, $aEnr[1]) Then
						_Attention($aEnr[1] & " existe déjà, merci de choisir un autre nom")
					ElseIf $aEnr[1] = "" Then
						_Attention("Le nom du logiciel ne peut être vide")
					ElseIf StringInStr($aEnr[1], "\") Then
						_Attention('Le nom du logiciel ne peut contenir le caractère "\"')
					ElseIf $aEnr[2] = "" Then
						_Attention("Le lien ne peut être vide")
					ElseIf StringLeft($aEnr[2], 5) = "choco" Then
						$aEnr[2] = "choco"
						$bChoco = True
						ExitLoop
					Else
						If GUICtrlRead($iSite) = $GUI_CHECKED Then
							$aEnr[3] = 1
						Else
							$aEnr[3] = 0
						EndIf
						If GUICtrlRead($iForcedl) = $GUI_CHECKED Then
							$aEnr[4] = 1
						Else
							$aEnr[4] = 0
						EndIf
						If GUICtrlRead($iHeaders) = $GUI_CHECKED Then
							$aEnr[5] = 1
						Else
							$aEnr[5] = 0
						EndIf
						If GUICtrlRead($iMdp) = $GUI_CHECKED Then
							$aEnr[6] = 1
						Else
							$aEnr[6] = 0
						EndIf
						If GUICtrlRead($iFavoris) = $GUI_CHECKED Then
							$aEnr[7] = 1
						Else
							$aEnr[7] = 0
						EndIf
						If GUICtrlRead($sExtension) <> "" Then
							$aEnr[8] = GUICtrlRead($sExtension)
						Else
							$aEnr[8] = ""
						EndIf
						If GUICtrlRead($sExp) <> "" Then
							$aEnr[11] = GUICtrlRead($sExp)
						Else
							$aEnr[11] = ""
						EndIf
						If GUICtrlRead($sExpnot) <> "" Then
							$aEnr[12] = GUICtrlRead($sExpnot)
						Else
							$aEnr[12] = ""
						EndIf
						If GUICtrlRead($iDomaine) = $GUI_CHECKED Then
							$aEnr[9] = GUICtrlRead($sDomaine)
						Else
							$aEnr[9] = ""
						EndIf
						If GUICtrlRead($iNepasmaj) = $GUI_CHECKED Then
							$aEnr[10] = 1
						Else
							$aEnr[10] = 0
						EndIf

						GUISetState(@SW_MINIMIZE)
						WinActivate($hGUIBAO)
						If(GUICtrlRead($iTest) = $GUI_CHECKED) Then
							If _TryDL($aEnr) Then
								ExitLoop
							Else
								GUISetState(@SW_RESTORE)
							EndIf
						Else
							ExitLoop
						EndIf
					EndIf

			EndSwitch
			$eGet = GUIGetMsg()
		WEnd

		If($eGet = $iIDButtonDemarrer) Then
			_SauvToIni($aEnr, GUICtrlRead($iCombo) & ".ini")
			GUIDelete()
			_Attention("Nouveau logiciel ajouté" & @CRLF & "Redémarrer BAO quand vous aurez terminé les modifications")
			WinSetTitle($hGUIBAO, "", $sSociete & " - Boîte A Outils (bêta) " & $sVersion & " - Redémarrage nécessaire *")
		Else
			GUIDelete()
		EndIf
	EndIf
EndFunc

Func _MenuMod($aEnr)
	; $aEnr[1] = NomDuLogiciel
	; $aEnr[2] = Lien
	; $aEnr[3] = Site
	; $aEnr[4] = ForceDL
	; $aEnr[5] = Headers
	; $aEnr[6] = Mdp
	; $aEnr[7] = Favoris
	; $aEnr[8] = Extension
	; $aEnr[9] = Domaine
	; $aEnr[10] = Nepasmaj
	; $aEnr[11] = Expression
	; $aEnr[12] = ExpressionNonPresente
	; $aEnr[13] = Dossier
	Local $iCombo, $sCombo, $btmpmod = False, $sTmpdom, $bChoco = False
	Local $aListDoc = _FileListToArrayRec(@ScriptDir & "\Logiciels\", "*.ini|" & $aEnr[11], 1, 0, 1)
	Local $hGUIMenuMod = GUICreate('Modification de logiciel (maintenez la touche "MAJ" pour ouvrir directement)', 600, 240)
	GUICtrlCreateLabel("Nom du logiciel :", 10, 10)
	Local $iNomLogiciel = GUICtrlCreateInput($aEnr[1], 160, 8, 140)
	GUICtrlSetState(-1, $GUI_DISABLE)

	GUICtrlCreateLabel("Déplacer dans le dossier :", 320, 10)
	$iCombo = GUICtrlCreateCombo("-----------", 450, 8, 140, default, $CBS_DROPDOWNLIST)
	If $aListDoc[0] > 1 Then
		$sCombo = _ArrayToString($aListDoc, "|", 1)
		$sCombo = StringReplace($sCombo, ".ini", "")
		GUICtrlSetData($iCombo, $sCombo)
	EndIf

	GUICtrlCreateLabel("Lien (direct ou page parente) :", 10, 40)
	Local $iLien = GUICtrlCreateInput($aEnr[2], 160, 38, 330)
	Local $iTest = GUICtrlCreateCheckbox("Tester le lien", 500, 35)

	GUICtrlCreateGroup("Réglages avancés", 10, 70, 580, 135)
	Local $iFavoris = GUICtrlCreateCheckbox("Ajouter aux favoris", 20, 90)
	If $aEnr[7] = 1 Then
		GUICtrlSetState(-1, $GUI_CHECKED)
	EndIf
	Local $iSite = GUICtrlCreateCheckbox("Ouvrir dans le navigateur", 20, 110)
	If $aEnr[3] = 1 Then
		GUICtrlSetState(-1, $GUI_CHECKED)
	EndIf
	Local $iNepasmaj = GUICtrlCreateCheckbox("Ne pas mettre à jour", 20, 130)
	If $aEnr[3] = 1 Then
		GUICtrlSetState(-1, $GUI_DISABLE)
	ElseIf $aEnr[10] = 1 Then
		GUICtrlSetState(-1, $GUI_CHECKED)
		GUICtrlSetState($iSite, $GUI_DISABLE)
	EndIf
	Local $iDomaine = GUICtrlCreateCheckbox("Domaine pour les liens relatifs :", 20, 150)
	GUICtrlCreateLabel("Téléchargement indirect : le lien contient ", 20, 180)
	Local $sExp = GUICtrlCreateInput("", 220, 177, 120)
	GUICtrlCreateLabel("mais ne contient pas ", 350, 180)
	Local $sExpnot = GUICtrlCreateInput("", 460, 177, 120)

	Local $iHeaders = GUICtrlCreateCheckbox("Activer headers HTTP", 300, 90)
	If $aEnr[3] = 1 Then
		GUICtrlSetState(-1, $GUI_DISABLE)
	ElseIf $aEnr[5] = 1 Then
		GUICtrlSetState(-1, $GUI_CHECKED)
		GUICtrlSetState($iSite, $GUI_DISABLE)
	EndIf
	Local $iMdp = GUICtrlCreateCheckbox("Rechercher mot de passe dans le source", 300, 110)
	If $aEnr[3] = 1 Then
		GUICtrlSetState(-1, $GUI_DISABLE)
	ElseIf $aEnr[6] = 1 Then
		GUICtrlSetState(-1, $GUI_CHECKED)
		GUICtrlSetState($iSite, $GUI_DISABLE)
	EndIf

	Local $iForcedl = GUICtrlCreateCheckbox("Forcer le téléchargement (précisez l'extension)", 300, 130)
	If $aEnr[3] = 1 Then
		GUICtrlSetState(-1, $GUI_DISABLE)
	ElseIf $aEnr[4] = 1 Then
		GUICtrlSetState(-1, $GUI_CHECKED)
		GUICtrlSetState($iSite, $GUI_DISABLE)
	EndIf

	GUICtrlCreateLabel("Extension (téléchargement forcé ou indirect) : ", 320, 153)
	Local $sExtension = GUICtrlCreateInput("", 545, 150, 35)
	GUICtrlSetLimit(-1, 3)
	If $aEnr[3] = 1 Then
		GUICtrlSetState($sExtension, $GUI_DISABLE)
		GUICtrlSetState($sExp, $GUI_DISABLE)
		GUICtrlSetState($sExpnot, $GUI_DISABLE)
	ElseIf $aEnr[8] <> "" Or $aEnr[11] <> "" Or $aEnr[12] <> "" Then
		If $aEnr[8] <> "" Then
			GUICtrlSetData($sExtension, $aEnr[8])
		EndIf
		If $aEnr[11] <> "" Then
			GUICtrlSetData($sExp, $aEnr[11])
		EndIf
		If $aEnr[12] <> "" Then
			GUICtrlSetData($sExpnot, $aEnr[12])
		EndIf
		GUICtrlSetState($iSite, $GUI_DISABLE)
	EndIf

	Local $sDomaine = GUICtrlCreateInput("https://", 185, 150, 105)
	If $aEnr[3] = 1 Then
		GUICtrlSetState($iDomaine, $GUI_DISABLE)
		GUICtrlSetState($sDomaine, $GUI_DISABLE)
	ElseIf $aEnr[9] <> "" Then
		GUICtrlSetState($iDomaine, $GUI_CHECKED)
		GUICtrlSetData($sDomaine, $aEnr[9])
		GUICtrlSetState($iSite, $GUI_DISABLE)
	EndIf

	If $aEnr[2] = "choco" Then
		$bChoco = True
		GUICtrlSetState($iLien,  $GUI_DISABLE)
		GUICtrlSetState($iTest,  $GUI_DISABLE)
		GUICtrlSetState($iSite,  $GUI_DISABLE)
		GUICtrlSetState($iNepasmaj,  $GUI_DISABLE)
		GUICtrlSetState($sExp,  $GUI_DISABLE)
		GUICtrlSetState($sExpnot,  $GUI_DISABLE)
		GUICtrlSetState($iHeaders,  $GUI_DISABLE)
		GUICtrlSetState($iMdp,  $GUI_DISABLE)
		GUICtrlSetState($iForcedl,  $GUI_DISABLE)
		GUICtrlSetState($sExtension,  $GUI_DISABLE)
		GUICtrlSetState($sDomaine,  $GUI_DISABLE)
		GUICtrlSetState($iDomaine,  $GUI_DISABLE)
	EndIf

	Local $iIDButtonOuvrir = GUICtrlCreateButton("Télécharger/Ouvrir", 40, 210, 130, 25, $BS_DEFPUSHBUTTON)
	Local $iIDButtonAnnuler = GUICtrlCreateButton("Annuler", 210, 210, 80, 25)
	Local $iIDButtonDemarrer = GUICtrlCreateButton("Modifier", 300, 210, 80, 25)
	Local $iIDButtonSupprimer = GUICtrlCreateButton("Supprimer", 390, 210, 80, 25)
	GUISetState(@SW_SHOW)

	Local $eGet = GUIGetMsg()

	While $eGet <> $GUI_EVENT_CLOSE And $eGet <> $iIDButtonAnnuler
		Switch $eGet
			Case $iSite
				$btmpmod = True
				If(GUICtrlRead($iSite) = $GUI_CHECKED) Then
					GUICtrlSetState($iNepasmaj, BitOR($GUI_DISABLE, $GUI_UNCHECKED))
					GUICtrlSetState($iForcedl, BitOR($GUI_DISABLE, $GUI_UNCHECKED))
					GUICtrlSetState($sExtension, $GUI_DISABLE)
					GUICtrlSetState($sExp, $GUI_DISABLE)
					GUICtrlSetState($sExpnot, $GUI_DISABLE)
					GUICtrlSetState($iHeaders, BitOR($GUI_DISABLE, $GUI_UNCHECKED))
					GUICtrlSetState($iMdp, BitOR($GUI_DISABLE, $GUI_UNCHECKED))
					GUICtrlSetState($iDomaine, BitOR($GUI_DISABLE, $GUI_UNCHECKED))
					GUICtrlSetState($sDomaine, $GUI_DISABLE)
				Else
					GUICtrlSetState($iNepasmaj, $GUI_ENABLE)
					GUICtrlSetState($iForcedl, $GUI_ENABLE)
					GUICtrlSetState($sExtension, $GUI_ENABLE)
					GUICtrlSetState($sExp, $GUI_ENABLE)
					GUICtrlSetState($sExpnot, $GUI_ENABLE)
					GUICtrlSetState($iHeaders, $GUI_ENABLE)
					GUICtrlSetState($iMdp, $GUI_ENABLE)
					GUICtrlSetState($iDomaine, $GUI_ENABLE)
					GUICtrlSetState($sDomaine, $GUI_ENABLE)
				EndIf
			Case $iForcedl
				$btmpmod = True
				If(GUICtrlRead($iForcedl) = $GUI_CHECKED) Then
					GUICtrlSetState($iSite, $GUI_DISABLE)
				Else
					GUICtrlSetState($iSite, $GUI_ENABLE)
				EndIf
			Case $iHeaders
				$btmpmod = True
				If(GUICtrlRead($iHeaders) = $GUI_CHECKED) Then
					GUICtrlSetState($iSite, $GUI_DISABLE)
				Else
					GUICtrlSetState($iSite, $GUI_ENABLE)
				EndIf

			Case $iNepasmaj
				If(GUICtrlRead($iNepasmaj) = $GUI_CHECKED) Then
					GUICtrlSetState($iSite, $GUI_DISABLE)
				Else
					GUICtrlSetState($iSite, $GUI_ENABLE)
				EndIf

			Case $iMdp
				$btmpmod = True
				If(GUICtrlRead($iMdp) = $GUI_CHECKED) Then
					GUICtrlSetState($iSite, $GUI_DISABLE)
				Else
					GUICtrlSetState($iSite, $GUI_ENABLE)
				EndIf

			Case $iDomaine
				$btmpmod = True
				If(GUICtrlRead($iDomaine) = $GUI_CHECKED) Then
					$sTmpdom = StringLeft(GUICtrlRead($iLien), StringInStr(GUICtrlRead($iLien), "/", 0, 3))
					GUICtrlSetData($sDomaine, $sTmpdom)
					GUICtrlSetState($iSite, $GUI_DISABLE)
				Else
					GUICtrlSetState($iSite, $GUI_ENABLE)
				EndIf

			Case $iIDButtonDemarrer
				$aEnr[2] = GUICtrlRead($iLien)

				If $aEnr[2] = "" Then
					_Attention("Le lien ne peut être vide")
				Else
					If GUICtrlRead($iSite) = $GUI_CHECKED Then
						$aEnr[3] = 1
					Else
						$aEnr[3] = 0
					EndIf
					If GUICtrlRead($iForcedl) = $GUI_CHECKED Then
						$aEnr[4] = 1
					Else
						$aEnr[4] = 0
					EndIf
					If GUICtrlRead($iHeaders) = $GUI_CHECKED Then
						$aEnr[5] = 1
					Else
						$aEnr[5] = 0
					EndIf
					If GUICtrlRead($iMdp) = $GUI_CHECKED Then
						$aEnr[6] = 1
					Else
						$aEnr[6] = 0
					EndIf
					If GUICtrlRead($iFavoris) = $GUI_CHECKED Then
						$aEnr[7] = 1
					Else
						$aEnr[7] = 0
					EndIf
					If GUICtrlRead($sExtension) <> "" Then
						If GUICtrlRead($sExtension) <> $aEnr[8] Then
							$btmpmod = True
						EndIf
						$aEnr[8] = GUICtrlRead($sExtension)
					Else
						$aEnr[8] = ""
					EndIf
					If GUICtrlRead($sExp) <> "" Then
						If GUICtrlRead($sExp) <> $aEnr[11] Then
							$btmpmod = True
						EndIf
						$aEnr[11] = GUICtrlRead($sExp)
					Else
						$aEnr[11] = ""
					EndIf
					If GUICtrlRead($sExpnot) <> "" Then
						If GUICtrlRead($sExpnot) <> $aEnr[12] Then
							$btmpmod = True
						EndIf
						$aEnr[12] = GUICtrlRead($sExpnot)
					Else
						$aEnr[12] = ""
					EndIf
					If GUICtrlRead($iDomaine) = $GUI_CHECKED Then
						$aEnr[9] = GUICtrlRead($sDomaine)
					Else
						$aEnr[9] = ""
					EndIf
					If GUICtrlRead($iNepasmaj) = $GUI_CHECKED Then
						$aEnr[10] = 1
					Else
						$aEnr[10] = 0
					EndIf

					GUISetState(@SW_MINIMIZE)
					If $btmpmod Then
						WinActivate($hGUIBAO)
						If(GUICtrlRead($iTest) = $GUI_CHECKED) Then
							If _TryDL($aEnr) Then
								ExitLoop
							Else
								GUISetState(@SW_RESTORE)
							EndIf
						Else
							ExitLoop
						EndIf
					Else
						ExitLoop
					EndIf
				EndIf

			Case $iIDButtonSupprimer
				IniDelete(@ScriptDir & "\Logiciels\" & $aEnr[13], $aEnr[1])
				ExitLoop

			Case $iIDButtonOuvrir
				_ExecuteProg()
				ExitLoop

		EndSwitch
		$eGet = GUIGetMsg()
	WEnd

	If($eGet = $iIDButtonDemarrer) Then
		If GUICtrlRead($iCombo) = "-----------" Then
			_SauvToIni($aEnr, $aEnr[13])
		Else
			_SauvToIni($aEnr, GUICtrlRead($iCombo) & ".ini", $aEnr[12])
		EndIf
		GUIDelete()
		_Attention("Modifications enregistrées" & @CRLF & "Redémarrer BAO quand vous aurez terminé les modifications")
		WinSetTitle($hGUIBAO, "", $sSociete & " - Boîte A Outils (bêta) " & $sVersion & " - Redémarrage nécessaire *")
	ElseIf($eGet = $iIDButtonSupprimer) Then
		GUIDelete()
		WinSetTitle($hGUIBAO, "", $sSociete & " - Boîte A Outils (bêta) " & $sVersion & " - Redémarrage nécessaire *")
	Else
		GUIDelete()
	EndIf
EndFunc

Func _MenuAddDoc()
	Local $aListDoc = _FileListToArrayRec(@ScriptDir & "\Logiciels\", "*.ini", 1, 0, 1)
	Local $hGUIMenuDoc = GUICreate("Ajouter un dossier", 300, 70)
	GUICtrlCreateLabel("Nom du dossier :", 10, 10)
	Local $iDossier = GUICtrlCreateInput("", 130, 8, 160)
	Local $iIDButtonDemarrer = GUICtrlCreateButton("Créer", 50, 40, 90, 25, $BS_DEFPUSHBUTTON)
	Local $iIDButtonAnnuler = GUICtrlCreateButton("Annuler", 160, 40, 90, 25)
	GUISetState(@SW_SHOW)

	Local $eGet = GUIGetMsg()
	Local $sInput

	While $eGet <> $GUI_EVENT_CLOSE And $eGet <> $iIDButtonAnnuler

		If $eGet = $iIDButtonDemarrer Then
			$sInput = GUICtrlRead($iDossier)
			If $sInput <> "" Then
				If _ArraySearch($aListDoc, $sInput & ".ini") = -1 Then
					ExitLoop
				Else
					_Attention("Ce dossier existe déjà")
				EndIf
			Else
				_Attention("Le nom du dossier ne peut être vide")
			EndIf
		EndIf
		$eGet = GUIGetMsg()
	WEnd

	GUIDelete()

	If($eGet = $iIDButtonDemarrer) Then
		Local $hFileIni = FileOpen(@ScriptDir & "\Logiciels\" & $sInput & ".ini", 513)
		 If $hFileIni = -1 Then
			_Attention("Une erreur est survenue lors de la création du fichier.")
		 Else
			FileWrite($hFileIni, '; Exemple' & @CRLF & ';' & @CRLF & '; [Nom Du Logiciel]' & @CRLF & '; lien=https://lelogiciel.fr/logiciel.exe' & @CRLF & '; site=1 # ouvre le lien dans le navigateur par défaut' & @CRLF & "; forcedl=1 # télécharge directement, même si ce n'est pas un lien direct. Préciser l'extension" & @CRLF & '; headers=1 # télécharge en envoyant des entêtes http (nécessaire pour Nirsoft)' & @CRLF & '; motdepasse=1 # toujours pour nirsoft, récupère le mot de passe sur la page' & @CRLF & '; extension=.exe # extension du fichier si forcedl=1 ou téléchargement indirect' & @CRLF & '; expression=Windows.10.v # filtre le lien qui contient ce mot si téléchargement indirect' & @CRLF & '; expressionnonincluse=PowerShell # filtre le lien qui ne contient pas ce mot si téléchargement indirect' & @CRLF & "; domaine=https://nirsoft.fr # complète l'url en cas de lien relatif dans le code source de la page" & @CRLF & '; nepasmaj=1 # ne pas mettre à jour si le logiciel est déjà téléchargé (SDI par exemple)' & @CRLF & @CRLF)
			FileClose($hFileIni)
			_Attention($sInput & " a été créé." & @CRLF & "Redémarrer BAO quand vous aurez terminé les modifications")
			WinSetTitle($hGUIBAO, "", $sSociete & " - Boîte A Outils (bêta) " & $sVersion & " - Redémarrage nécessaire *")
		EndIf
	EndIf
EndFunc

Func _SauvToIni($aRec, $sDossier, $sDossierToDelete="")

	; $aEnr[1] = NomDuLogiciel
	; $aEnr[2] = Lien
	; $aEnr[3] = Site
	; $aEnr[4] = ForceDL
	; $aEnr[5] = Headers
	; $aEnr[6] = Mdp
	; $aEnr[7] = Favoris
	; $aEnr[8] = Extension
	; $aEnr[9] = Domaine
	; $aEnr[10] = Nepasmaj
	; $aEnr[11] = Expression
	; $aEnr[12] = ExpressionNonIncluse

	Local $sData = "lien=" & $aRec[2] & @LF
	If $aRec[7] = 1 Then
		$sData &= "favoris=1" & @LF
	EndIf
	If $aRec[3] = 1 Then
		$sData &= "site=1" & @LF
	Else
		If $aRec[4] = 1 Then
			$sData &= "forcedl=1" & @LF
		EndIf
		If $aRec[8] <> "" Then
			$sData &= "extension=" & $aRec[8] & @LF
		EndIf
		If $aRec[11] <> "" Then
			$sData &= "expression=" & $aRec[11] & @LF
		EndIf
		If $aRec[12] <> "" Then
			$sData &= "expressionnonincluse=" & $aRec[12] & @LF
		EndIf
		If $aRec[5] = 1 Then
			$sData &= "headers=1" & @LF
		EndIf
		If $aRec[6] = 1 Then
			$sData &= "motdepasse=1" & @LF
		EndIf
		If $aRec[9] <> "" Then
			$sData &= "domaine=" & $aRec[9] & @LF
		EndIf
		If $aRec[10] = 1 Then
			$sData &= "nepasmaj=1" & @LF
		EndIf
	EndIf
	$sData &= @CRLF
	;_Attention(@ScriptDir & "\Logiciels\" & $sDossier & " " & $aRec[1] & " " & $sData, 1)
	IniWriteSection(@ScriptDir & "\Logiciels\" & $sDossier, $aRec[1], $sData)
	If @error = 0 Then
		_FileWriteLog($hLog, $aRec[1] & ' a bien été ajouté à ' & $sDossier)
	Else
		_Attention($aRec[1] & " n'a pas pu être ajouté à " & $sDossier)
		_FileWriteLog($hLog, $aRec[1] & "(" & $aRec[2] & ") n'a pas pu être ajouté à " & $sDossier)
	EndIf

	If $sDossierToDelete <> "" Then
		IniDelete(@ScriptDir & "\Logiciels\" & $sDossierToDelete, $aRec[1])
	EndIf

	_IniClasserAlpa($sDossier)
EndFunc


Func _IniClasserAlpa($sfichierini)
	local $aSections = IniReadSectionNames(@ScriptDir & "\Logiciels\" & $sfichierini)
	Local $aTmpSection[$aSections[0]]
	_ArraySort($aSections, 0, 1)

	For $i = 1 To $aSections[0]
		$aTmpSection[$i - 1] = IniReadSection(@ScriptDir & "\Logiciels\" & $sfichierini, $aSections[$i])
	Next
	Local $hIni = FileOpen(@ScriptDir & "\Logiciels\" & $sfichierini, 514)
	FileWrite($hIni, "; Exemple" & @CRLF & ";" & @CRLF & "; [Nom Du Logiciel] " & @CRLF & "; lien=https://lelogiciel.fr/logiciel.exe" & @CRLF & "; site=1 # ouvre le lien dans le navigateur par défaut" & @CRLF & "; forcedl=1 # télécharge directement, même si ce n'est pas un lien direct. Préciser l'extension" & @CRLF & "; headers=1 # télécharge en envoyant des entêtes http (nécessaire pour Nirsoft)" & @CRLF & "; motdepasse=1 # toujours pour nirsoft, récupère le mot de passe sur la page" & @CRLF & "; extension=.exe # extension du fichier si forcedl=1 ou téléchargement indirect" & @CRLF & '; expression=Windows.10.v # filtre le lien qui contient ce mot si téléchargement indirect' & @CRLF & '; expressionnonincluse=PowerShell # filtre le lien qui ne contient pas ce mot si téléchargement indirect' & @CRLF & "; domaine=https://nirsoft.fr # complète l'url en cas de lien relatif dans le code source de la page" & @CRLF & "; nepasmaj=1 # ne pas mettre à jour si le logiciel est déjà téléchargé (SDI par exemple)" & @CRLF & @CRLF)
	FileClose($hIni)

	For $i = 1 To $aSections[0]
		For $j=1 To ($aTmpSection[$i-1])[0][0]
			IniWrite(@ScriptDir & "\Logiciels\" & $sfichierini, $aSections[$i], ($aTmpSection[$i-1])[$j][0], ($aTmpSection[$i-1])[$j][1])
		Next
		FileWriteLine(@ScriptDir & "\Logiciels\" & $sfichierini, "")
	Next

EndFunc