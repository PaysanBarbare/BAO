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

Func _CreerIDSuivi()
	Local $iPIN = Random(1000, 9999, 1)

	If(StringLeft($sNom, 4) = "Tech") Then
		$iPIN = InputBox("Code de suivi", "Entrez un code de suivi à 4 chiffres", $iPIN, " 4")
	Else
		If _FichierCache("Suivi") = 1 Then
			_FichierCache("Suivi", $iPIN)
		Else
			_Attention("Ce client a déjà un code de suivi, merci de supprimer l'association préalablement")
			$iPIN = ""
		EndIf
	EndIf

	If ($iPIN <> "") Then
		If FileExists($sScriptDir & '\Cache\Suivi\' & $iPIN & '.txt') = 0 Then
			Local $hSuivi = FileOpen($sScriptDir & '\Cache\Suivi\' & $iPIN & '.txt', 9)
			FileClose($hSuivi)

			If(StringLeft($sNom, 4) <> "Tech") Then
				_FichierCache("Suivi", $iPIN)
				GUICtrlSetData($iLabelPC, "Client : " & $sNom & " (" & $iPIN & ")")
				_DebutIntervention($iPIN)
			EndIf

		Else
			_Attention("Ce code est déjà utilisé, merci de renouveller l'opération avec un code différent")
		EndIf
	EndIf
EndFunc

Func _SupprimerIDSuivi($idSuivi)
	If FileExists($sScriptDir & '\Cache\Suivi\' & $idSuivi & '.txt') Then
		FileDelete($sScriptDir & '\Cache\Suivi\' & $idSuivi & '.txt')
	EndIf
EndFunc

Func _SupprimerSuivi()
	Local $iSuivi = _FichierCache("Suivi")
	_SupprimerIDSuivi($iSuivi)
	_FichierCache("Suivi", 1)
	If(StringLeft($sNom, 4) <> "Tech") Then
		GUICtrlSetData($iLabelPC, "Client : " & $sNom)
	EndIf
EndFunc

Func _DebutIntervention($iCodeSuivi)
	local $iRetour
	Local $sNomFichier = $sScriptDir & '\Cache\Suivi\' & $iCodeSuivi & '.txt'
	FileWriteLine($sNomFichier, _FichierCache("PremierLancement") & " - Intervention débutée")
	Local $sFTPDossierSuivi = IniRead($sConfig, "FTP", "DossierSuivi", "")
	Do
		$iRetour = _EnvoiFTP($sNomFichier, $sFTPDossierSuivi & $iCodeSuivi & '.txt')
	Until $iRetour <> -1

EndFunc

Func _FinIntervention($iCodeSuivi)
	local $iRetour
	Local $sNomFichier = $sScriptDir & '\Cache\Suivi\' & $iCodeSuivi & '.txt'
	FileWriteLine($sNomFichier, _Now() & " - Intervention terminée")
	Local $sFTPDossierSuivi = IniRead($sConfig, "FTP", "DossierSuivi", "")
	Do
		$iRetour = _EnvoiFTP($sNomFichier, $sFTPDossierSuivi & $iCodeSuivi & '.txt')
	Until $iRetour <> -1

EndFunc

Func _CreerIndex()

	GUICtrlSetData($statusbar, " Création et envoi du fichier index.php")
	GUICtrlSetData($statusbarprogress, 20)

	Local $sNomFichier = $sScriptDir & '\Cache\Suivi\index.php'
	Local $hIndexPhp = FileOpen($sNomFichier, 10)
	FileWrite($hIndexPhp, '<!DOCTYPE html>' & @CRLF & @TAB & '<html>' & @CRLF & @TAB &  @TAB &  '<head>' & @CRLF & @TAB &  @TAB &  @TAB & '<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>' & @CRLF & @TAB & @TAB & @TAB & '<title>Suivi des interventions</title>' & @CRLF & @TAB & @TAB & '</head>' & @CRLF & @TAB & @TAB & '<body>' & @CRLF & @TAB & @TAB & @TAB & '<form method="POST">' & @CRLF & @TAB & @TAB & @TAB & @TAB & 'Entrez votre code de suivi : <input type="text" name="suivi" value="<?php if(!empty($_POST[''suivi''])) echo $_POST[''suivi''] ?>" />' & @CRLF & @TAB & @TAB & @TAB & @TAB & '<button type="submit">Envoyer</button>' & @CRLF & @TAB & @TAB & @TAB & @TAB & '<hr />' & @CRLF &'<?php ' & @CRLF & @TAB & 'if(!empty($_POST[''suivi'']))' & @CRLF & @TAB & '{' & @CRLF & @TAB & @TAB & '$file = htmlspecialchars($_POST[''suivi'']).".txt";' & @CRLF & @TAB & @TAB & 'If (file_exists($file))' & @CRLF &	@TAB & @TAB & '{' & @CRLF & @TAB & @TAB & @TAB & '$inter = file_get_contents($file);' & @CRLF & @TAB & @TAB & @TAB & 'echo nl2br($inter);' & @CRLF & @TAB & @TAB & '}' & @CRLF & @TAB & @TAB & 'else' & @CRLF & @TAB & @TAB & '{' & @CRLF &	@TAB & @TAB & @TAB & 'echo "Aucune intervention en cours avec ce code";' & @CRLF & @TAB & @TAB & '}' & @CRLF & @TAB & '}' & @CRLF & '?>' & @CRLF & @CRLF & @TAB & @TAB & @TAB & '</form>' & @CRLF & @TAB & @TAB & '</body>' & @CRLF & @TAB & '</html>')
	FileClose($hIndexPhp)

	Sleep(1000)
	GUICtrlSetData($statusbarprogress, 50)
	Local $iRetour = 0

	Local $sFTPDossierSuivi = IniRead($sConfig, "FTP", "DossierSuivi", "")
	Do
		$iRetour = _EnvoiFTP($sNomFichier, $sFTPDossierSuivi & 'index.php')
	Until $iRetour <> -1

	if($iRetour <> 1) Then
		_Attention("Le Fichier n'a pas été envoyé")
	Else
		GUICtrlSetData($statusbarprogress, 100)
		Sleep(2000)
	EndIf

	GUICtrlSetData($statusbar, "")
	GUICtrlSetData($statusbarprogress, 0)

EndFunc