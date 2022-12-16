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

#cs
Auteur : Bastien ROUCHES
Fonction : Suivi des interventions pour les clients
#ce

Func _CreerIntervention($sFile="", $bModif = False)

	Local $iRepSupp, $iPosCombo, $sNomFichierNouvelleInter, $sNNomClient, $sNPrenomClient, $sNSocieteClient, $sNAdresse, $sNTel, $sNMail, $sNMateriel, $sNDescription, $sNResolution, $sNMDP, $sNAutologon, $sNSuivi, $sNPIN, $sNtech, $iRet = False, $sNDossier
	Local $aNouvelleInter =_FileListToArrayRec(@ScriptDir & "\Rapports\Nouvelle", "*.bao"), $aInterEnCours =_FileListToArrayRec(@ScriptDir & "\Rapports\En cours", "*.bao"), $mInfosModifClient[], $sListeInter


	Local $iPIN = _CreerPIN()

	Local $hGUIInter = GUICreate("Créer/Modifier/Supprimer une intervention", 800, 435)
	Local $iInterChoix = GUICtrlCreateCombo("Nouvelle intervention", 10, 15, 385, 25, $CBS_DROPDOWNLIST)
	If $aNouvelleInter = "" And $aInterEnCours = "" Then
		GUICtrlSetState($iInterChoix, $GUI_DISABLE)
	Else
		If $aNouvelleInter <> "" Then
			For $i = 1 To $aNouvelleInter[0]
				$aNouvelleInter[$i] = "Nouvelle\"&$aNouvelleInter[$i]
			Next
			$sListeInter &= _ArrayToString($aNouvelleInter, "|", 1)
		EndIf
		If $aInterEnCours <> "" Then
			For $i = 1 To $aInterEnCours[0]
				$aInterEnCours[$i] = "En cours\"&$aInterEnCours[$i]
			Next
			$sListeInter &= _ArrayToString($aInterEnCours, "|", 1)
		EndIf
		GUICtrlSetData($iInterChoix, $sListeInter)
	EndIf
	GUICtrlCreateGroup("Coordonnées du client", 10, 50, 385, 200)
	GUICtrlSetFont (-1, 9, 800)
	GUICtrlCreateLabel("Nom", 20, 75, 50, 25)
	Local $iInterNom = GUICtrlCreateInput("", 80, 70, 110, 25)
	GUICtrlCreateLabel("Prénom", 210, 75, 50, 25)
	Local $iInterPrenom = GUICtrlCreateInput("", 275, 70, 110, 25)
	GUICtrlCreateLabel("Société", 20, 105, 50, 25)
	Local $iInterSociete = GUICtrlCreateInput("", 80, 100, 305, 25)
	GUICtrlCreateLabel("Adresse", 20, 135, 50, 25)
	Local $iInterAdresse = GUICtrlCreateEdit("", 80, 130, 305, 75)
	GUICtrlCreateLabel("Téléphone", 20, 215, 50, 25)
	Local $iInterTel = GUICtrlCreateInput("", 80, 210, 80, 25)
	GUICtrlCreateLabel("Email", 180, 215, 50, 25)
	Local $iInterMail = GUICtrlCreateInput("", 225, 210, 160, 25)
	GUICtrlCreateGroup("Appareil(s) déposé(s)", 10, 260, 385, 130)
	GUICtrlSetFont (-1, 9, 800)
	Local $iInterMateriel = GUICtrlCreateEdit("", 20, 285, 365, 90)
	GUICtrlCreateGroup("Description de la demande", 405, 10, 385, 120)
	GUICtrlSetFont (-1, 9, 800)
	Local $iInterDemande = GUICtrlCreateEdit("", 415, 30, 365, 85)
	GUICtrlCreateGroup("Résolution", 405, 140, 385, 110)
	GUICtrlSetFont (-1, 9, 800)
	Local $iInterResolution = GUICtrlCreateEdit("", 415, 160, 365, 75)
	GUICtrlCreateLabel("Mot de passe", 415, 260, 80, 25)
	Local $iInterMDP = GUICtrlCreateInput("", 505, 255, 110, 25)
	Local $iInterAutologon = GUICtrlCreateCheckbox("Autologon", 635, 255, 130, 25)
	Local $iInterSuivi = GUICtrlCreateCheckbox("Activer le suivi client", 415, 285, 130, 25)
	Local $iInterPin = GUICtrlCreateInput($iPIN, 550, 285, 90, 20)
	If _FichierCacheExist("Intervention") = 0 Then
		GUICtrlSetState($iInterSuivi, $GUI_DISABLE)
	EndIf
	Local $iInterPrint = GUICtrlCreateCheckbox("Imprimer la fichier intervention", 415, 310, 155, 25)
	Local $iInterPrintSelect = GUICtrlCreateCombo("Imprimante par défaut", 590, 310, 200, 20)
	GUICtrlSetData($iInterPrintSelect, "Choisir l'imprimante")
	GUICtrlSetState($iInterPrintSelect, $GUI_DISABLE)
	GUICtrlCreateGroup("Etat de l'intervention", 405, 340, 385, 50)
	GUICtrlSetFont (-1, 9, 800)
	Local $iInterNew = GUICtrlCreateRadio("Nouvelle", 410, 355, 70, 30)
	GUICtrlSetState($iInterNew, $GUI_CHECKED)
	Local $iInterPending = GUICtrlCreateRadio("En cours", 480, 355, 70, 30)
	Local $iInterClose = GUICtrlCreateRadio("Terminée", 550, 355, 70, 30)
	GUICtrlCreateLabel("Technicien : ", 620, 363, 70, 25)
	Local $iComboTech
	If $aListeTech <> "" Then
		$iComboTech = GUICtrlCreateCombo("", 690, 360, 90)
		GUICtrlSetData($iComboTech, _ArrayToString($aListeTech))
	EndIf
	GUICtrlSetState($iComboTech, $GUI_DISABLE)
	GUICtrlSetState($iInterClose, $GUI_DISABLE)
	GUICtrlSetState($iInterPin, $GUI_DISABLE)

	Local $iInterSave = GUICtrlCreateButton("Enregistrer", 260, 400, 130, 25, $BS_DEFPUSHBUTTON)
	Local $iInterDel = GUICtrlCreateButton("Supprimer", 410, 400, 130, 25)
	GUICtrlSetState($iInterDel, $GUI_DISABLE)

	GUISetState(@SW_SHOW)

	If $sFile <> "" Then
		If $bModif = False Then
			$mInfosModifClient = _GetInfosClient($sFile)
			GUICtrlSetData($iInterNom, $mInfosModifClient["LASTNAME"])
			GUICtrlSetData($iInterPrenom, $mInfosModifClient["FIRSTNAME"])
			GUICtrlSetData($iInterSociete, $mInfosModifClient["COMPANY"])
			GUICtrlSetData($iInterAdresse, StringReplace($mInfosModifClient["ADDRESS"], "[BR]", @CRLF))
			GUICtrlSetData($iInterTel, $mInfosModifClient["PHONE"])
			GUICtrlSetData($iInterMail, $mInfosModifClient["MAIL"])
			GUICtrlSetData($iInterMateriel, StringReplace($mInfosModifClient["DEVICES"], "[BR]", @CRLF))
			GUICtrlSetData($iInterMDP, $mInfosModifClient["PASSWORD"])
			If $mInfosModifClient["AUTOLOGON"] = "1" Then
				GUICtrlSetState($iInterAutologon, $GUI_CHECKED)
			Else
				GUICtrlSetState($iInterAutologon, $GUI_UNCHECKED)
			EndIf
		Else
			GUICtrlSetData($iInterChoix, '')
			GUICtrlSetData($iInterChoix, $sListeInter, StringTrimLeft($sFile, StringLen(@ScriptDir & "\Rapports\")))
			$mInfosModifClient = _GetInfosClient($sFile)
			GUICtrlSetData($iInterNom, $mInfosModifClient["LASTNAME"])
			GUICtrlSetData($iInterPrenom, $mInfosModifClient["FIRSTNAME"])
			GUICtrlSetData($iInterSociete, $mInfosModifClient["COMPANY"])
			GUICtrlSetData($iInterAdresse, StringReplace($mInfosModifClient["ADDRESS"], "[BR]", @CRLF))
			GUICtrlSetData($iInterTel, $mInfosModifClient["PHONE"])
			GUICtrlSetData($iInterMail, $mInfosModifClient["MAIL"])
			GUICtrlSetData($iInterMateriel, StringReplace($mInfosModifClient["DEVICES"], "[BR]", @CRLF))
			GUICtrlSetData($iInterDemande, StringReplace($mInfosModifClient["CASE"], "[BR]", @CRLF))
			GUICtrlSetData($iInterResolution, StringReplace($mInfosModifClient["RESOLUTION"], "[BR]", @CRLF))
			GUICtrlSetData($iInterMDP, $mInfosModifClient["PASSWORD"])
			If $mInfosModifClient["AUTOLOGON"] = "1" Then
				GUICtrlSetState($iInterAutologon, $GUI_CHECKED)
			Else
				GUICtrlSetState($iInterAutologon, $GUI_UNCHECKED)
			EndIf
			If $mInfosModifClient["TRACKING"] <> "" Then
				GUICtrlSetData($iInterPin, $mInfosModifClient["TRACKING"])
			EndIf

			If _FichierCacheExist("Intervention") = 1 And GUICtrlRead($iInterPin) <> "" Then
				GUICtrlSetState($iInterSuivi, $GUI_ENABLE)
				GUICtrlSetState($iInterSuivi, $GUI_CHECKED)
				GUICtrlSetState($iInterPin, $GUI_ENABLE)
			Else
				GUICtrlSetData($iInterPin, StringRight(StringTrimRight(GUICtrlRead($iInterChoix), 4), 4))
				GUICtrlSetState($iInterSuivi, $GUI_UNCHECKED)
				GUICtrlSetState($iInterPin, $GUI_DISABLE)
			EndIf
			GUICtrlSetState($iInterPrint, $GUI_UNCHECKED)
			GUICtrlSetState($iInterDel, $GUI_ENABLE)
			If StringLeft(GUICtrlRead($iInterChoix), 8) = "Nouvelle" Then
				GUICtrlSetState($iInterNew, $GUI_CHECKED)
			ElseIf StringLeft(GUICtrlRead($iInterChoix), 8) = "En cours" Then
				GUICtrlSetState($iInterPending, $GUI_CHECKED)
				GUICtrlSetState($iComboTech, $GUI_ENABLE)
			Else
				GUICtrlSetState($iComboTech, $GUI_ENABLE)
			EndIf
			GUICtrlSetData($iComboTech, '')
			GUICtrlSetData($iComboTech, _ArrayToString($aListeTech), $mInfosModifClient["TECH"])
			GUICtrlSetState($iInterClose, $GUI_ENABLE)
		EndIf
	EndIf

	Local $idMsgInst = GUIGetMsg()

	While ($idMsgInst <> $GUI_EVENT_CLOSE)
		Switch $idMsgInst

			Case $iInterChoix
				If GUICtrlRead($iInterChoix) = "Nouvelle intervention" Then
					GUICtrlSetData($iInterNom, "")
					GUICtrlSetData($iInterPrenom, "")
					GUICtrlSetData($iInterSociete, "")
					GUICtrlSetData($iInterAdresse, "")
					GUICtrlSetData($iInterTel, "")
					GUICtrlSetData($iInterMail, "")
					GUICtrlSetData($iInterMateriel, "")
					GUICtrlSetData($iInterDemande, "")
					GUICtrlSetData($iInterResolution, "")
					GUICtrlSetData($iInterMDP, "")
					GUICtrlSetState($iInterAutologon, $GUI_UNCHECKED)
					GUICtrlSetState($iInterSuivi, $GUI_UNCHECKED)
					GUICtrlSetData($iInterPin, $iPIN)
					GUICtrlSetState($iInterPrint, $GUI_UNCHECKED)
					GUICtrlSetState($iInterDel, $GUI_DISABLE)
					GUICtrlSetState($iInterNew, $GUI_CHECKED)
					If _FichierCacheExist("Intervention") = 1 Then
						GUICtrlSetState($iInterSuivi, $GUI_ENABLE)
					EndIf
					GUICtrlSetState($iInterPin, $GUI_DISABLE)
					GUICtrlSetState($iInterClose, $GUI_DISABLE)
				Else
					$mInfosModifClient = _GetInfosClient(@ScriptDir & "\Rapports\" & GUICtrlRead($iInterChoix))
					GUICtrlSetData($iInterNom, $mInfosModifClient["LASTNAME"])
					GUICtrlSetData($iInterPrenom, $mInfosModifClient["FIRSTNAME"])
					GUICtrlSetData($iInterSociete, $mInfosModifClient["COMPANY"])
					GUICtrlSetData($iInterAdresse, StringReplace($mInfosModifClient["ADDRESS"], "[BR]", @CRLF))
					GUICtrlSetData($iInterTel, $mInfosModifClient["PHONE"])
					GUICtrlSetData($iInterMail, $mInfosModifClient["MAIL"])
					GUICtrlSetData($iInterMateriel, StringReplace($mInfosModifClient["DEVICES"], "[BR]", @CRLF))
					GUICtrlSetData($iInterDemande, StringReplace($mInfosModifClient["CASE"], "[BR]", @CRLF))
					GUICtrlSetData($iInterResolution, StringReplace($mInfosModifClient["RESOLUTION"], "[BR]", @CRLF))
					GUICtrlSetData($iInterMDP, $mInfosModifClient["PASSWORD"])
					If $mInfosModifClient["AUTOLOGON"] = "1" Then
						GUICtrlSetState($iInterAutologon, $GUI_CHECKED)
					Else
						GUICtrlSetState($iInterAutologon, $GUI_UNCHECKED)
					EndIf
					If $mInfosModifClient["TRACKING"] <> "" Then
						GUICtrlSetData($iInterPin, $mInfosModifClient["TRACKING"])
					EndIf

					If _FichierCacheExist("Intervention") = 1 And GUICtrlRead($iInterPin) <> "" Then
						GUICtrlSetState($iInterSuivi, $GUI_ENABLE)
						GUICtrlSetState($iInterSuivi, $GUI_CHECKED)
						GUICtrlSetState($iInterPin, $GUI_ENABLE)
					Else
						GUICtrlSetData($iInterPin, StringRight(StringTrimRight(GUICtrlRead($iInterChoix), 4), 4))
						GUICtrlSetState($iInterSuivi, $GUI_UNCHECKED)
						GUICtrlSetState($iInterPin, $GUI_DISABLE)
					EndIf
					GUICtrlSetState($iInterPrint, $GUI_UNCHECKED)
					GUICtrlSetState($iInterDel, $GUI_ENABLE)
					If StringLeft(GUICtrlRead($iInterChoix), 8) = "Nouvelle" Then
						GUICtrlSetState($iInterNew, $GUI_CHECKED)
					ElseIf StringLeft(GUICtrlRead($iInterChoix), 8) = "En cours" Then
						GUICtrlSetState($iInterPending, $GUI_CHECKED)
						GUICtrlSetState($iComboTech, $GUI_ENABLE)
					Else
						GUICtrlSetState($iComboTech, $GUI_ENABLE)
					EndIf
					GUICtrlSetData($iComboTech, '')
					GUICtrlSetData($iComboTech, _ArrayToString($aListeTech), $mInfosModifClient["TECH"])
					GUICtrlSetState($iInterClose, $GUI_ENABLE)
				EndIf

			Case $iInterDel
				$iRepSupp = MsgBox(4, "Confirmation de suppression", 'Etes vous sûr de vouloir supprimer l'&"'"&'intervention "'&GUICtrlRead($iInterChoix)&'" ?')
				If $iRepSupp = 6 Then
					FileDelete(@ScriptDir & "\Rapports\" & GUICtrlRead($iInterChoix))
					$iPosCombo = _GUICtrlComboBox_GetCurSel($iInterChoix)
					_ArrayDelete($aNouvelleInter, $iPosCombo)
					_GUICtrlComboBox_DeleteString($iInterChoix, $iPosCombo)
					_GUICtrlComboBox_SetCurSel($iInterChoix, 0)
					If UBound($aNouvelleInter) = 1 Then
						GUICtrlSetState($iInterChoix, $GUI_DISABLE)
					EndIf
					GUICtrlSetState($iInterDel, $GUI_DISABLE)
					GUICtrlSetData($iInterNom, "")
					GUICtrlSetData($iInterPrenom, "")
					GUICtrlSetData($iInterSociete, "")
					GUICtrlSetData($iInterAdresse, "")
					GUICtrlSetData($iInterTel, "")
					GUICtrlSetData($iInterMail, "")
					GUICtrlSetData($iInterMateriel, "")
					GUICtrlSetData($iInterDemande, "")
					GUICtrlSetData($iInterResolution, "")
					GUICtrlSetData($iInterMDP, "")
					GUICtrlSetState($iInterAutologon, $GUI_UNCHECKED)
					GUICtrlSetState($iInterSuivi, $GUI_UNCHECKED)
					GUICtrlSetData($iInterPin, $iPIN)
					GUICtrlSetState($iInterPrint, $GUI_UNCHECKED)
					GUICtrlSetState($iInterClose, $GUI_UNCHECKED)
					GUICtrlSetState($iInterDel, $GUI_DISABLE)
				EndIf

			Case $iInterSuivi
				If GUICtrlRead($iInterSuivi) = $GUI_CHECKED Then
					GUICtrlSetState($iInterPin, $GUI_ENABLE)
				Else
					GUICtrlSetData($iInterPin, $iPIN)
					GUICtrlSetState($iInterPin, $GUI_DISABLE)
				EndIf

			Case $iInterClose
				GUICtrlSetState($iInterSuivi, $GUI_DISABLE)
				GUICtrlSetState($iInterPin, $GUI_DISABLE)
			Case $iInterNew
				GUICtrlSetState($iInterSuivi, $GUI_ENABLE)
				GUICtrlSetState($iComboTech, $GUI_DISABLE)
			Case $iInterPending
				GUICtrlSetState($iInterSuivi, $GUI_ENABLE)
				GUICtrlSetState($iComboTech, $GUI_ENABLE)
			Case $iInterClose
				GUICtrlSetState($iComboTech, $GUI_ENABLE)
			Case $iInterPrint
				If GUICtrlRead($iInterPrint) = $GUI_CHECKED Then
					GUICtrlSetState($iInterPrintSelect, $GUI_ENABLE)
				Else
					GUICtrlSetState($iInterPrintSelect, $GUI_DISABLE)
				EndIf

			Case $iInterSave
				If GUICtrlRead($iInterNom) = "" And GUICtrlRead($iInterSociete) = "" Then
					_Attention("Complétez au moins le nom du client ou la société")
				ElseIf GUICtrlRead($iInterSuivi) = $GUI_CHECKED And Not IsInt(GUICtrlRead($iInterPin)+0) Then
					_Attention("Le code de suivi client doit être un entier à 4 chiffres")
				ElseIf GUICtrlRead($iInterSuivi) = $GUI_CHECKED And (GUICtrlRead($iInterPin) < 999 Or GUICtrlRead($iInterPin) > 9999) Then
					_Attention("Le code de suivi client doit être compris entre 1000 et 9999")
				Else
					$sNNomClient = GUICtrlRead($iInterNom)
					$sNPrenomClient = GUICtrlRead($iInterPrenom)
					$sNSocieteClient = GUICtrlRead($iInterSociete)
					$sNAdresse = GUICtrlRead($iInterAdresse)
					$sNTel = GUICtrlRead($iInterTel)
					$sNMail = GUICtrlRead($iInterMail)
					$sNMateriel = GUICtrlRead($iInterMateriel)
					$sNDescription = GUICtrlRead($iInterDemande)
					$sNResolution = GUICtrlRead($iInterResolution)
					$sNMDP = GUICtrlRead($iInterMDP)
					If GUICtrlRead($iInterAutologon) = $GUI_CHECKED Then
						$sNAutologon = 1
					Else
						$sNAutologon = 0
					EndIf

					If GUICtrlRead($iInterSuivi) = $GUI_CHECKED Then
						$sNPIN = GUICtrlRead($iInterPin)
						If GUICtrlRead($iInterChoix) = "Nouvelle intervention" Then
							$iPIN = _CreerPIN($sNPIN)
							$sNPIN = $iPIN
						Else
							$iPIN = $sNPIN
						EndIf
					Else
						$iPIN = GUICtrlRead($iInterPin)
						$sNPIN = ""
					EndIf
					If GUICtrlRead($iInterNew) = $GUI_CHECKED Then
						$sNDossier = "Nouvelle\"
					ElseIf GUICtrlRead($iInterPending) = $GUI_CHECKED Then
						$sNDossier = "En cours\"
					Else
						$sNDossier = @YEAR & "-" & @MON & "\"
					EndIf

					If $sNSocieteClient <> "" Then
						$sNomFichierNouvelleInter = @ScriptDir & "\Rapports\" & $sNDossier & StringReplace(StringLeft(_NowCalc(),10), "/", "") & " " & $sNSocieteClient & " - " & $iPIN & ".bao"
					Else
						$sNomFichierNouvelleInter = @ScriptDir & "\Rapports\" & $sNDossier & StringReplace(StringLeft(_NowCalc(),10), "/", "") & " " & $sNNomClient & " " & $sNPrenomClient & " - " & $iPIN & ".bao"
					EndIf

					If GUICtrlRead($iComboTech) <> "" Then
						$sNtech = GUICtrlRead($iComboTech)
					EndIf

					If GUICtrlRead($iInterChoix) <> "Nouvelle intervention" Then
						FileDelete(@ScriptDir & "\Rapports\" & GUICtrlRead($iInterChoix))
					EndIf

					If _RapportInfosClient($sNomFichierNouvelleInter, $sNNomClient, $sNPrenomClient, $sNSocieteClient, $sNtech, $sNPIN, $sNAdresse, $sNTel, $sNMail, $sNMateriel, $sNDescription, $sNResolution, $sNMDP, $sNAutologon) Then

						If GUICtrlRead($iInterPrint) = $GUI_CHECKED Then
							If GUICtrlRead($iInterPrintSelect) = "Imprimante par défaut" Then
								_PrintInter($sNomFichierNouvelleInter, "printdefault")
							Else
								_PrintInter($sNomFichierNouvelleInter, "print")
							EndIf
						EndIf
						If GUICtrlRead($iInterChoix) = "Nouvelle intervention" Then
							DirCreate(@ScriptDir & "\Proaxive\")
							FileCopy($sNomFichierNouvelleInter, @ScriptDir & "\Proaxive\", 1)
						EndIf

						$iRet = True
						If GUICtrlRead($iInterSuivi) = $GUI_CHECKED Then
							If $sNDossier = "En cours\" Then
								_CompleterSuivi($sNomFichierNouvelleInter)
							ElseIf $sNDossier = @YEAR & "-" & @MON & "\" Then
								_CompleterSuivi($sNomFichierNouvelleInter, True)
							EndIf
						EndIf
						ExitLoop
					Else
						_Attention("Erreur lors de l'enregistrement")
					EndIf
				EndIf

		EndSwitch

		$idMsgInst = GUIGetMsg()
	WEnd
	GUIDelete($hGUIInter)
	Return $iRet
EndFunc

Func _DeplacerIntervention($sFile, $sDossier)
	Local $bReturn = False
	If FileExists($sFile) Then
		If FileMove($sFile, $sDossier, 9) Then
			$bReturn = True
			_FileWriteLog($hLog, 'Intervention "' & $sFile & '" déplacée dans "' & $sDossier & '"')
		Else
			_FileWriteLog($hLog, 'Impossible de déplacer l' & "'" & 'intervention "' & $sFile & '" dans "' & $sDossier & '"')
		EndIf
	EndIf
	return $bReturn
EndFunc

Func _PrintInter($sNomFichierToPrint, $sDefaut = "printdefault")

	Local $mInfosClient = _GetInfosClient($sNomFichierToPrint)
	Local $sFTracking, $sFNomClient, $sFPrenomClient, $sFSocieteClient, $sFAdresse, $sFTel, $sFMail, $sFTech, $sFDescription, $sFMateriel, $sFMDP
	Global $o_object
	If MapExists($mInfosClient, "TRACKING") Then $sFTracking = $mInfosClient["TRACKING"]
	If MapExists($mInfosClient, "LASTNAME") Then $sFNomClient = $mInfosClient["LASTNAME"]
	If MapExists($mInfosClient, "FIRSTNAME") Then $sFPrenomClient = $mInfosClient["FIRSTNAME"]
	If MapExists($mInfosClient, "COMPANY") Then $sFSocieteClient = $mInfosClient["COMPANY"]
	If MapExists($mInfosClient, "ADDRESS") Then $sFAdresse = $mInfosClient["ADDRESS"]
	If MapExists($mInfosClient, "PHONE") Then $sFTel = $mInfosClient["PHONE"]
	If MapExists($mInfosClient, "MAIL") Then $sFMail = $mInfosClient["MAIL"]
	If MapExists($mInfosClient, "TECH") Then $sFTech = $mInfosClient["TECH"]
	If MapExists($mInfosClient, "DEVICES") Then $sFMateriel = $mInfosClient["DEVICES"]
	If MapExists($mInfosClient, "CASE") Then $sFDescription = $mInfosClient["CASE"]
	If MapExists($mInfosClient, "PASSWORD") Then $sFMDP = $mInfosClient["PASSWORD"]

	Local $s_html = '<!DOCTYPE html>'
	$s_html &= '<html>'
	$s_html &= '  <head>'
	$s_html &= '    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>'
	$s_html &= '  <title>' & $sSociete & ' - Fiche intervention</title>'
	$s_html &= '  <style>'

	$s_html &= '    body {'
	$s_html &= '        height: 842px;'
	$s_html &= '        width: 595px;'
	$s_html &= '        margin-left: auto;'
	$s_html &= '        margin-right: auto;'
	$s_html &= '        font-family: Arial, sans-serif;'
	$s_html &= '    }'

	$s_html &= '    fieldset {'
	$s_html &= '    	margin-bottom: 10px;'
	$s_html &= '    }'

	$s_html &= '	legend {'
	$s_html &= '	    background-color: #000;'
	$s_html &= '	    color: #fff;'
	$s_html &= '	    padding: 3px 6px;'
	$s_html &= '	}'

	$s_html &= '	input {'
	$s_html &= '	    width: 100%;'
	$s_html &= '	    height: 25px;'
	$s_html &= ' 	}'

	$s_html &= '	.largeinput {'
	$s_html &= '		width: 100%;'
	$s_html &= '	}'

	$s_html &= '	label {'
	$s_html &= '		font-style: italic;'
	$s_html &= '		display: inline-block;'
	$s_html &= '		width: 200px;'
	$s_html &= '		font-size: 0.7em;'
	$s_html &= '	}'

	$s_html &= '	textarea {'
	$s_html &= '		width: 100%;'
	$s_html &= '		height: 80px;'
	$s_html &= '	}'

	$s_html &= '	textarea.description {'
	$s_html &= '		height: 260px;'
	$s_html &= '	}'

	$s_html &= '	.row {'
	$s_html &= '	  display: flex;'
	$s_html &= '	}'

	$s_html &= '	.column {'
	$s_html &= '	  flex: 50%;'
	$s_html &= '	  padding: 5px;'
	$s_html &= '	}'

	$s_html &= '	.largecolumn {'
	$s_html &= '		padding: 5px;'
	$s_html &= '		width: 100%;'
	$s_html &= '	}'

	$s_html &= '	hr {'
	$s_html &= '		padding: 5px;'
	$s_html &= '		height: none;'
	$s_html &= '		border: none;'
	$s_html &= '		border-top: 1px dashed grey;'
	$s_html &= '	}'
    $s_html &= '  </style>'
	$s_html &= ' </head>'
	$s_html &= ' <body>'
	If $sFSocieteClient <> "" Then
		$s_html &= '  <h1>' & $sFSocieteClient & '</h1>'
	Else
		$s_html &= '  <h1>' & $sFNomClient & " " & $sFPrenomClient & '</h1>'
	EndIf
	$s_html &= '  <fieldset>'
    $s_html &= '	<legend>Coordonnées du client</legend>'
    $s_html &= '	<div class="row">'
	$s_html &= '   	<div class="column">'
	$s_html &= '    		<label>Nom </label><input type="text" value="' & $sFNomClient & '" >'
	$s_html &= '    	</div>'
	$s_html &= '    	<div class="column">'
	$s_html &= '    		<label>Prénom </label><input type="text" value="' & $sFPrenomClient & '" >'
	$s_html &= '    	</div>'
	$s_html &= '    </div>'
	$s_html &= '    <div class="row">'
    $s_html &= '		<div class="largecolumn"><label>Société </label><input type="text" value="' & $sFSocieteClient & '" class="largeinput"></div>'
    $s_html &= '	</div>'
    $s_html &= '	<div class="row">'
    $s_html &= '		<div class="largecolumn"><label>Adresse </label><textarea>' & StringReplace($sFAdresse, "[BR]", @CRLF) & '</textarea></div>'
    $s_html &= '	</div>'
    $s_html &= '	<div class="row">'
	$s_html &= '    	<div class="column">'
	$s_html &= '    		<label>Téléphone </label><input type="text" value="' & $sFTel & '" >'
	$s_html &= '    	</div>'
	$s_html &= '    	<div class="column">'
	$s_html &= '    		<label>Mail </label><input type="text" value="' & $sFMail & '" >'
	$s_html &= '    	</div>'
	$s_html &= '    </div>'
    $s_html &= '  </fieldset>'
    $s_html &= '  <fieldset>'
    $s_html &= '	<legend>Description de la demande</legend>'
    $s_html &= '	 <div class="row">'
    $s_html &= '		<div class="largecolumn"><label>Appareil(s) déposé(s) </label><textarea>' & StringReplace($sFMateriel, "[BR]", @CRLF) & '</textarea></div>'
    $s_html &= '	</div>'
    $s_html &= '	<div class="row">'
    $s_html &= '		<div class="largecolumn"><label>Description de la demande </label><textarea class="description">' & StringReplace($sFDescription, "[BR]", @CRLF) & '</textarea></div>'
    $s_html &= '	</div>'
    $s_html &= '	<div class="row">'
    $s_html &= '		<div class="column">'
	$s_html &= '    		<label>Mot(s) de passe </label><input type="text" value="' & $sFMDP & '" >'
	$s_html &= '    	</div>'
	If _FichierCacheExist("Intervention") Then
		$s_html &= '    	<div class="column">'
		$s_html &= '    		<label>Code de suivi </label><input type="text" value="' & $sFTracking & '" >'
		$s_html &= '    	</div>'
		$s_html &= '    </div>'
		$s_html &= '  </fieldset>'
		$s_html &= '  <hr>'
		$s_html &= '  <p>Code de suivi en ligne : ' & $sFTracking & '</p>'
	Else
		$s_html &= '  </fieldset>'
	EndIf
	$s_html &= ' </body>'
	$s_html &= '</html>'
	$o_object = _IECreate("about:blank", 0, 0)
	_IEBodyWriteHTML($o_object, $s_html)
	_IEAction($o_object, $sDefaut)
	OnAutoItExitRegister("_ExitIE")
EndFunc

Func _ExitIE()
	_IEQuit($o_object)
EndFunc

Func _RechercherInter($sRecherche)
	Local $bTrouve = False, $hSearch, $sFichierTrouve
	GUICtrlSetData($iIDListResult, "")
	Local $aFoldersSearch = _FileListToArray(@ScriptDir & "\Rapports\", "*", 2)

	If @error = 0 Then
		For $i = 1 To $aFoldersSearch[0]
			$hSearch = FileFindFirstFile(@ScriptDir & "\Rapports\" & $aFoldersSearch[$i] & "\*" & $sRecherche & "*.bao")
			If $hSearch <> -1 Then
				 While 1
					$sFichierTrouve = FileFindNextFile($hSearch)

					If @error Then
						ExitLoop
					Else
						GUICtrlSetData($iIDListResult, $aFoldersSearch[$i] & "\" & $sFichierTrouve)
						$bTrouve = True
					EndIf
				WEnd
				FileClose($hSearch)
			EndIf
		Next
	EndIf

	Return $bTrouve
EndFunc

Func _RechercherNouvellesInterventions()
	GUICtrlSetData($iIDListResult, "")
	GUICtrlSetData($iIDInputRecherche, "")
	$hSearch = FileFindFirstFile(@ScriptDir & "\Rapports\Nouvelle\*.bao")
	If $hSearch <> -1 Then
		 While 1
			$sFichierTrouve = FileFindNextFile($hSearch)

			If @error Then
				ExitLoop
			Else
				GUICtrlSetData($iIDListResult, "Nouvelle\" & $sFichierTrouve)
			EndIf
		WEnd
		FileClose($hSearch)
	EndIf
	$hSearch = FileFindFirstFile(@ScriptDir & "\Rapports\En cours\*.bao")
	If $hSearch <> -1 Then
		 While 1
			$sFichierTrouve = FileFindNextFile($hSearch)

			If @error Then
				ExitLoop
			Else
				GUICtrlSetData($iIDListResult, "En cours\" & $sFichierTrouve)
			EndIf
		WEnd
		FileClose($hSearch)
	EndIf
EndFunc

Func _CreerPIN($iPIN=0)

	Local $hSuivi, $bCreateFile = False

	If $iPIN = 0 Then
		$iPIN = Random(1000, 9999, 1)
	Else
		$bCreateFile = True
	EndIf

	While 1
		If FileExists(@ScriptDir & '\Cache\Suivi\' & $iPIN & '.txt') Then
			$iPIN += 1
			If $iPIN > 9999 Then
				$iPIN = Random(1000, 9999, 1)
			EndIf
		Else
			ExitLoop
		EndIf
	WEnd

	If $bCreateFile Then
		$hSuivi = FileOpen(@ScriptDir & '\Cache\Suivi\' & $iPIN & '.txt', 9)
		FileClose($hSuivi)
	EndIf

	Return $iPIN
EndFunc

Func _CreerIDSuivi()
	Local $iPIN = Random(1000, 9999, 1)
	Local $sQuestion

	If($iModeTech = 0) And _FichierCache("Suivi") <> 1 Then
		$iPIN = _FichierCache("Suivi")
	Else

		If($iModeTech = 0) Then
			$sQuestion = "Entrez un code de suivi à 4 chiffres pour " & $sNom
		Else
			$sQuestion = "Entrez un code de suivi à 4 chiffres (nouveau client)"
		EndIf

		$iPIN = InputBox("Code de suivi", $sQuestion, $iPIN, " 4")
		If($iPIN <> "" And $iModeTech = 0) Then
			If _FichierCache("Suivi") = 1 Then
				_FichierCache("Suivi", $iPIN)
			Else
				_Attention("Ce client a déjà un code de suivi, merci de supprimer l'association préalablement")
				$iPIN = ""
			EndIf
		EndIf
	EndIf

	If ($iPIN <> "") Then
		If FileExists(@ScriptDir & '\Cache\Suivi\' & $iPIN & '.txt') = 0 Then
			Local $hSuivi = FileOpen(@ScriptDir & '\Cache\Suivi\' & $iPIN & '.txt', 9)
			FileClose($hSuivi)

			If($iModeTech = 0) Then
				_FileWriteLog($hLog, 'Association "' & $sNom & '" et suivi : ' & $iPIN)
				_UpdEdit($iIDEditLog, $hLog)
				_FichierCache("Suivi", $iPIN)
				GUICtrlSetData($iLabelPC, "Client : " & $sNom & " (" & $iPIN & ")")
				_DebutIntervention($iPIN)
			EndIf

		Else
			_Attention("Ce code est déjà utilisé, merci de renouveller l'opération avec un code différent")
		EndIf
	EndIf
EndFunc

Func _CompleterSuivi($sFile="", $bClot=False)

	Local $hGUIsuivi = GUICreate("Compléter le suivi", 400, 140)
	Local $iPIN, $eGet, $iRetour, $iIDCloture, $iNBEl = False, $iIDCombo, $aNouvelleInter, $aInterEnCours

	If($iModeTech = 1) Then
		If $sFile <> "" Then
			$iPIN = StringRight(StringTrimRight($sFile, 4), 4)
			GUICtrlCreateLabel("Suivi en ligne :" & $iPIN, 10, 10, 300)
			$iNBEl = True
		Else
			$aNouvelleInter =_FileListToArrayRec(@ScriptDir & "\Rapports\Nouvelle", "*.bao")
			$aInterEnCours =_FileListToArrayRec(@ScriptDir & "\Rapports\En cours", "*.bao")

			If $aNouvelleInter = "" And $aInterEnCours = "" Then
				_Attention("Il n'y a aucune intervention disponible")
				GUIDelete()
				Return
			Else
				GUICtrlCreateLabel("Intervention :", 10, 10, 70)
				$iIDCombo = GUICtrlCreateCombo("",80, 5, 310, default, $CBS_DROPDOWNLIST)
				If $aNouvelleInter <> "" Then
					For $i=1 To $aNouvelleInter[0]
						If FileExists(@ScriptDir & '\Cache\Suivi\' & StringRight(StringTrimRight($aNouvelleInter[$i], 4), 4) & '.txt') Then
							GUICtrlSetData($iIDCombo, "Nouvelle\"&$aNouvelleInter[$i])
							$iNBEl = True
						EndIf
					Next
				EndIf
				If $aInterEnCours <> "" Then
					For $i=1 To $aInterEnCours[0]
						If FileExists(@ScriptDir & '\Cache\Suivi\' & StringRight(StringTrimRight($aInterEnCours[$i], 4), 4) & '.txt') Then
							GUICtrlSetData($iIDCombo, "En cours\"&$aInterEnCours[$i])
							$iNBEl = True
						EndIf
					Next
				EndIf
			EndIf
		EndIf

		If Not $iNBEl Then
			_Attention("Il n'y a aucune intervention avec suivi activé disponible")
			GUIDelete()
			Return
		EndIf

		GUICtrlCreateLabel("(L'intervention sera automatiquement débutée)", 10, 30)

	Else
		$iPIN = _FichierCache("Suivi")
		If $iPIN = 1 Then
			_CreerIDSuivi()
			$iPIN = _FichierCache("Suivi")
		EndIf
		GUICtrlCreateLabel("Ajouter une information de suivi au client : " & $sNom & " (" & $iPIN & ")", 10, 10)
	EndIf

	GUICtrlCreateLabel("Information à ajouter :", 10, 55)
	Local $sInfosuivi = GUICtrlCreateInput("", 120, 50,270)

	Local $iIDCloture = GUICtrlCreateCheckbox("Terminer l'intervention ?", 10, 80)
	If $bClot = True Then
		GUICtrlSetState($iIDCloture, $GUI_CHECKED)
		GUICtrlSetState($iIDCloture, $GUI_DISABLE)
	EndIf
	Local $iIDValider = GUICtrlCreateButton("Enregistrer", 40, 110, 150, 25, $BS_DEFPUSHBUTTON)
	Local $iIDAnnuler = GUICtrlCreateButton("Annuler", 210, 110, 150, 25)

	GUISetState(@SW_SHOW)
	$eGet = GUIGetMsg()
	While $eGet <> $GUI_EVENT_CLOSE And $eGet <> $iIDAnnuler And $eGet <> $iIDValider
		$eGet = GUIGetMsg()
	WEnd

	If($eGet = $iIDValider) Then
		If($iModeTech = 1 And $iPIN = "") Then
			$iPIN = StringRight(StringTrimRight(GUICtrlRead($iIDCombo), 4), 4)
		EndIf
		Local $sNomFichier = @ScriptDir & '\Cache\Suivi\' & $iPIN & '.txt'
		If FileReadLine($sNomFichier) = "" Then
			_FileWriteLog($hLog, 'Intervention débutée sur le suivi')
			FileWriteLine($sNomFichier,  _Now() & " - Intervention débutée")
		EndIf
		If GUICtrlRead($sInfosuivi) <> "" Then
			FileWriteLine($sNomFichier,  _Now() & " - " & GUICtrlRead($sInfosuivi))
		EndIf

		If(GUICtrlRead($iIDCloture) = $GUI_CHECKED) Then
			_FileWriteLog($hLog, 'Intevention cloturée sur le suivi')
			FileWriteLine($sNomFichier, _Now() & " - Intervention terminée")
			;_SupprimerIDSuivi($iPIN)
			If($iModeTech = 0) Then
				_FichierCache("Suivi", 1)
				GUICtrlSetData($iLabelPC, "Client : " & $sNom)
			Else
				_DeplacerIntervention(@ScriptDir & "\Rapports\" & GUICtrlRead($iIDCombo), @ScriptDir & "\Rapports\" & @YEAR & "-" & @MON & "\")
			EndIf
		ElseIf StringLeft(GUICtrlRead($iIDCombo), 8) = "Nouvelle" Then
			_DeplacerIntervention(@ScriptDir & "\Rapports\" & GUICtrlRead($iIDCombo), @ScriptDir & "\Rapports\En cours\")
		EndIf

		GUIDelete()
		Local $sFTPDossierSuivi = IniRead($sConfig, "FTP", "DossierSuivi", "")
		Local $nb = 0
		Do
			$iRetour = _EnvoiFTP($sNomFichier, $sFTPDossierSuivi & $iPIN & '.txt')
			$nb+=1
		Until $iRetour <> -1 Or $nb=3
		_UpdEdit($iIDEditLog, $hLog)
	Else
		GUIDelete()
	EndIf
EndFunc

Func _SupprimerSuivisAnciens()
	Local $aSuivis =_FileListToArrayRec(@ScriptDir & "\Cache\Suivi\", "*.txt"), $iLastLine, $sDateLastLine, $sFormatDate, $sNomFichier, $sLastLine
	If $aSuivis <> "" Then
		For $i = 1 To $aSuivis[0]
			$sNomFichier = @ScriptDir & '\Cache\Suivi\' & $aSuivis[$i]
			$iLastLine = _FileCountLines($sNomFichier)
			$sLastLine = FileReadLine($sNomFichier, $iLastLine)
			If StringRight($sLastLine, 21) = "Intervention terminée" Then
				$sDateLastLine = StringLeft($sLastLine, 10)
				$sFormatDate = StringRegExpReplace($sDateLastLine, "(\d{2})/(\d{2})/(\d{4})", "${3}/${2}/${1}")
				If _DateIsValid($sFormatDate) Then
					If _DateDiff("D", $sFormatDate, _NowCalcDate()) > 15 Then
						If _EnvoiFTP($sNomFichier, $sFTPDossierSuivi & $aSuivis[$i], 1) <> 1 Then
							_FileWriteLog($hLog, 'Erreur : suppression du suivi obsolète "' & $aSuivis[$i] & '" impossible')
						Else
							_FileWriteLog($hLog, 'Suppression du suivi obsolète ' & $aSuivis[$i])
						EndIf
						FileDelete($sNomFichier)
					EndIf
				EndIf
			EndIf
		Next
	EndIf
EndFunc

Func _SupprimerIDSuivi($idSuivi)
	If FileExists(@ScriptDir & '\Cache\Suivi\' & $idSuivi & '.txt') Then
		FileDelete(@ScriptDir & '\Cache\Suivi\' & $idSuivi & '.txt')
	EndIf
EndFunc

Func _SupprimerSuivi()

	If($iModeTech = 0) Then
		Local $iSuivi = _FichierCache("Suivi")
		_SupprimerIDSuivi($iSuivi)
		If _EnvoiFTP(@ScriptDir & '\Cache\Suivi\' & $iSuivi & '.txt', $sFTPDossierSuivi & $iSuivi & '.txt', 1) <> 1 Then
			_FileWriteLog($hLog, 'Erreur : suppression du suivi "' & $iSuivi & '.txt' & '" impossible')
		Else
			_FileWriteLog($hLog, 'Suppression du suivi ' & $iSuivi & '.txt')
		EndIf
		_FichierCache("Suivi", 1)
		GUICtrlSetData($iLabelPC, "Client : " & $sNom)
	Else
		Local $hGUIsuivi = GUICreate("Suppression du suivi en ligne", 400, 140)
		Local $iPIN, $eGet, $iRetour

		Local $aNouvelleInter =_FileListToArrayRec(@ScriptDir & "\Rapports\Nouvelle", "*.bao")
		;_ArrayTrim($aNouvelleInter, 4, 1)
		Local $iIDCombo, $bSuivi = False

		If $aNouvelleInter <> "" Then
			GUICtrlCreateLabel("Choisissez le suivi d'intervention à supprimer", 10, 10)
			If FileExists(@ScriptDir & '\Cache\Suivi\' & StringRight(StringTrimRight($aNouvelleInter[1], 4), 4) & '.txt') Then
				$iIDCombo = GUICtrlCreateCombo(StringTrimRight($aNouvelleInter[1], 4),10, 40, 380)
				$bSuivi = True
			EndIf
			If UBound($aNouvelleInter) > 2 Then
				For $i = 2 To $aNouvelleInter[0]
					If FileExists(@ScriptDir & '\Cache\Suivi\' & StringRight(StringTrimRight($aNouvelleInter[$i], 4), 4) & '.txt') Then
						If Not $bSuivi Then
							$iIDCombo = GUICtrlCreateCombo(StringTrimRight($aNouvelleInter[$i], 4),10, 40, 380)
						Else
							GUICtrlSetData($iIDCombo, StringTrimRight($aNouvelleInter[$i],4))
						EndIf
						$bSuivi = True
					EndIf
				Next
			EndIf
			If Not $bSuivi Then
				GUIDelete()
				_Attention("Il n'y a aucun suivi en ligne à supprimer")
				Return
			EndIf
		Else
			_Attention("Il n'y a aucun suivi en ligne à supprimer")
			GUIDelete()
			Return
		EndIf

		Local $iIDValider = GUICtrlCreateButton("Supprimer", 40, 110, 150, 25, $BS_DEFPUSHBUTTON)
		Local $iIDAnnuler = GUICtrlCreateButton("Annuler", 210, 110, 150, 25)

		GUISetState(@SW_SHOW)

		While $eGet <> $GUI_EVENT_CLOSE And $eGet <> $iIDAnnuler And $eGet <> $iIDValider
			$eGet = GUIGetMsg()
		WEnd

		If($eGet = $iIDValider) Then
			$iPIN = StringRight(GUICtrlRead($iIDCombo), 4)

			Local $sNomFichier = @ScriptDir & '\Cache\Suivi\' & $iPIN & '.txt'
			_FileWriteLog($hLog, 'Code de suivi supprimé')
			_UpdEdit($iIDEditLog, $hLog)
			_SupprimerIDSuivi($iPIN)

			GUIDelete()
			Local $nb = 0
			Do
				$iRetour = _EnvoiFTP($sNomFichier, $sFTPDossierSuivi & $iPIN & '.txt', 1)
				$nb+=1
			Until $iRetour <> -1  Or $nb=3
		Else
			GUIDelete()
		EndIf
	EndIf
EndFunc

Func _DebutIntervention($iCodeSuivi)
	local $iRetour
	Local $sNomFichier = @ScriptDir & '\Cache\Suivi\' & $iCodeSuivi & '.txt'
	FileWriteLine($sNomFichier, _FichierCache("PremierLancement") & " - Intervention débutée")

	Local $nb = 0
	Do
		$iRetour = _EnvoiFTP($sNomFichier, $sFTPDossierSuivi & $iCodeSuivi & '.txt')
		$nb+=1
	Until $iRetour <> -1 Or $nb=3

	_FileWriteLog($hLog, 'Intervention débutée sur le suivi')
	_UpdEdit($iIDEditLog, $hLog)

EndFunc

Func _FinIntervention($iCodeSuivi, $sInput = "")
	local $iRetour
	Local $sNomFichier = @ScriptDir & '\Cache\Suivi\' & $iCodeSuivi & '.txt'
	If $sInput <> "" Then
		FileWriteLine($sNomFichier, _Now() & " - " & $sInput)
	EndIf
	FileWriteLine($sNomFichier, _Now() & " - Intervention terminée")

	Local $nb = 0
	Do
		$iRetour = _EnvoiFTP($sNomFichier, $sFTPDossierSuivi & $iCodeSuivi & '.txt')
		$nb+=1
	Until $iRetour <> -1 Or $nb=3

	_FileWriteLog($hLog, 'Intervention cloturée sur le suivi')
	_UpdEdit($iIDEditLog, $hLog)

EndFunc

Func _CreerIndex()

	GUICtrlSetData($statusbar, " Création et envoi du fichier index.php")
	GUICtrlSetData($statusbarprogress, 20)

	Local $sNomFichier = @ScriptDir & '\Cache\Suivi\index.php'
	Local $hIndexPhp = FileOpen($sNomFichier, 10)
	FileWrite($hIndexPhp, '<!DOCTYPE html>' & @CRLF & @TAB & '<html>' & @CRLF & @TAB &  @TAB &  '<head>' & @CRLF & @TAB &  @TAB &  @TAB & '<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>' & @CRLF & @TAB & @TAB & @TAB & '<title>Suivi des interventions</title>' & @CRLF & @TAB & @TAB & '</head>' & @CRLF & @TAB & @TAB & '<body>' & @CRLF & @TAB & @TAB & @TAB & '<form method="POST">' & @CRLF & @TAB & @TAB & @TAB & @TAB & 'Entrez votre code de suivi : <input type="text" name="suivi" value="<?php if(!empty($_POST[''suivi''])) echo $_POST[''suivi''] ?>" />' & @CRLF & @TAB & @TAB & @TAB & @TAB & '<button type="submit">Envoyer</button>' & @CRLF & @TAB & @TAB & @TAB & @TAB & '<hr />' & @CRLF &'<?php ' & @CRLF & @TAB & 'if(!empty($_POST[''suivi'']))' & @CRLF & @TAB & '{' & @CRLF & @TAB & @TAB & '$file = htmlspecialchars($_POST[''suivi'']).".txt";' & @CRLF & @TAB & @TAB & 'If (file_exists($file))' & @CRLF &	@TAB & @TAB & '{' & @CRLF & @TAB & @TAB & @TAB & '$inter = file_get_contents($file);' & @CRLF & @TAB & @TAB & @TAB & 'echo nl2br($inter);' & @CRLF & @TAB & @TAB & '}' & @CRLF & @TAB & @TAB & 'else' & @CRLF & @TAB & @TAB & '{' & @CRLF &	@TAB & @TAB & @TAB & 'echo "Aucune intervention en cours avec ce code";' & @CRLF & @TAB & @TAB & '}' & @CRLF & @TAB & '}' & @CRLF & '?>' & @CRLF & @CRLF & @TAB & @TAB & @TAB & '</form>' & @CRLF & @TAB & @TAB & '</body>' & @CRLF & @TAB & '</html>')
	FileClose($hIndexPhp)

	Sleep(1000)
	GUICtrlSetData($statusbarprogress, 50)
	Local $iRetour = 0

	Local $sFTPDossierSuivi = IniRead($sConfig, "FTP", "DossierSuivi", "")
	Local $nb = 0
	Do
		$iRetour = _EnvoiFTP($sNomFichier, $sFTPDossierSuivi & 'index.php')
		$nb+=1
	Until $iRetour <> -1 Or $nb=3

	if($iRetour <> 1) Then
		_Attention("Le Fichier n'a pas été envoyé")
	Else
		GUICtrlSetData($statusbarprogress, 100)
		Sleep(2000)
		_FileWriteLog($hLog, 'Fichier créé sur le ftp: "' & $sFTPDossierSuivi & 'index.php' & '"')
		_UpdEdit($iIDEditLog, $hLog)
	EndIf

	GUICtrlSetData($statusbar, "")
	GUICtrlSetData($statusbarprogress, 0)

EndFunc

Func _CalcNouvellesInter()
	Local $aNBInterNouvelles, $iNBInter

	$aNBInterNouvelles = _FileListToArray(@ScriptDir & "\Rapports\Nouvelle\", "*.bao")
	If @error Then
		$iNBInter = 0
	Else
		$iNBInter = $aNBInterNouvelles[0]
	EndIf

	GUICtrlSetData($iIDLabelNewInt, "Nouvelles interventions non affectées : " & $iNBInter)
EndFunc

Func _CalcStats()
	Local  $hSearch, $sFichierTrouve, $aFoldersSearch, $bResultSearch = False, $mTechsTrouves[], $mRes[], $sTmpTech, $sTMPDate, $aTechsTrouves, $iNBInterNouvelles, $aTot[7]

	_CalcNouvellesInter()
	_GUICtrlListView_DeleteAllItems($iIDListStats)

	$aFoldersSearch = _FileListToArray(@ScriptDir & "\Rapports\", "*", 2)

	If @error = 0 Then
		GUICtrlSetData($statusbar, "Calcul en cours ...")
		GUICtrlSetData($statusbarprogress, 0)
		For $i = 1 To $aFoldersSearch[0]
			GUICtrlSetData($statusbarprogress, Round(100 * ($i / $aFoldersSearch[0]), 0))

			If $aFoldersSearch[$i] <> "Nouvelle" Then
				$hSearch = FileFindFirstFile(@ScriptDir & "\Rapports\" & $aFoldersSearch[$i] & "\*.bao")
				If $hSearch <> -1 Then
					 While 1
						$sFichierTrouve = FileFindNextFile($hSearch)

						If @error Then
							ExitLoop
						Else
							$sTmpTech = _GetTech(@ScriptDir & "\Rapports\" & $aFoldersSearch[$i] & "\" & $sFichierTrouve)
							If $sTmpTech = "" Then
								$sTmpTech = "Indefini"
							EndIf
							If Not MapExists($mTechsTrouves, $sTmpTech) Then
								$mTechsTrouves[$sTmpTech] = $mRes
							EndIf

							If $aFoldersSearch[$i] = "En cours" Then
								$mTechsTrouves[$sTmpTech][0] += 1
								$aTot[0] += 1
							Else
								$sTMPDate = StringRegExpReplace(StringLeft($sFichierTrouve, 8), "(\d{4})(\d{2})(\d{2})", "${1}/${2}/${3}")

								If _DateIsValid($sTMPDate) Then
									If $sTMPDate = _NowCalcDate() Then
										$mTechsTrouves[$sTmpTech][1] += 1
										$mTechsTrouves[$sTmpTech][3] += 1
										$mTechsTrouves[$sTmpTech][5] += 1
										$aTot[1] += 1
										$aTot[3] += 1
										$aTot[5] += 1
									ElseIf _DateDiff("D", $sTMPDate, _NowCalcDate()) = 1 Then
										$aTot[2] += 1
										$mTechsTrouves[$sTmpTech][2] += 1
										If StringMid(_NowCalcDate(), 6, 5) = "01/01" Then
											$mTechsTrouves[$sTmpTech][6] += 1
											$mTechsTrouves[$sTmpTech][4] += 1
											$aTot[4] += 1
											$aTot[6] += 1
										ElseIf StringMid(_NowCalcDate(), 9, 2) = "01" Then
											$mTechsTrouves[$sTmpTech][5] += 1
											$mTechsTrouves[$sTmpTech][4] += 1
											$aTot[4] += 1
											$aTot[5] += 1
										Else
											$mTechsTrouves[$sTmpTech][3] += 1
											$aTot[3] += 1
											$aTot[5] += 1
										EndIf
									ElseIf StringMid($sTMPDate, 1, 7) = @YEAR & "/" & @MON Then
										$aTot[3] += 1
										$aTot[5] += 1
										$mTechsTrouves[$sTmpTech][3] += 1
										$mTechsTrouves[$sTmpTech][5] += 1
									ElseIf StringMid($sTMPDate,1, 7) = @YEAR & "/" & (@MON - 1) Then
										$aTot[4] += 1
										$aTot[5] += 1
										$mTechsTrouves[$sTmpTech][4] += 1
										$mTechsTrouves[$sTmpTech][5] += 1
									ElseIf @MON = "01" And StringMid($sTMPDate, 1, 7) = (@YEAR - 1) & "/12" Then
										$aTot[4] += 1
										$aTot[6] += 1
										$mTechsTrouves[$sTmpTech][4] += 1
										$mTechsTrouves[$sTmpTech][6] += 1
									ElseIf StringMid($sTMPDate, 1, 4) = @YEAR Then
										$aTot[5] += 1
										$mTechsTrouves[$sTmpTech][5] += 1
									ElseIf StringMid($sTMPDate, 1, 4) = @YEAR - 1 Then
										$aTot[6] += 1
										$mTechsTrouves[$sTmpTech][6] += 1
									EndIf
								EndIf

							EndIf
						EndIf
					WEnd
					FileClose($hSearch)
				EndIf
			EndIf
		Next
		$aTechsTrouves = MapKeys($mTechsTrouves)
		If $aTechsTrouves <> "" Then
			For $sTechInRap In $aTechsTrouves
				GUICtrlCreateListViewItem($sTechInRap & "|" & $mTechsTrouves[$sTechInRap][0] & "|" & $mTechsTrouves[$sTechInRap][1] & "|" & $mTechsTrouves[$sTechInRap][2] & "|" & $mTechsTrouves[$sTechInRap][3] & "|" & $mTechsTrouves[$sTechInRap][4] & "|" & $mTechsTrouves[$sTechInRap][5] & "|" & $mTechsTrouves[$sTechInRap][6], $iIDListStats)
			Next
			GUICtrlCreateListViewItem("TOTAL|" & $aTot[0] & "|" & $aTot[1] & "|" & $aTot[2] & "|" & $aTot[3] & "|" & $aTot[4] & "|" & $aTot[5] & "|" & $aTot[6], $iIDListStats)
		EndIf
		GUICtrlSetData($statusbar, "")
		GUICtrlSetData($statusbarprogress, 0)
	EndIf
EndFunc