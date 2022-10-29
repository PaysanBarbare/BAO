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

Func _Supervision($sFTPAdresse, $sFTPUser, $sFTPPort, $sFTPDossierCapture)

	Local $iRetour

	If StringLeft($sNom, 4) <> "Tech" Then
		If _FichierCacheExist("Supervision") = 0 Then
			$iRetour = _SendCapture($sFTPAdresse, $sFTPUser, $sFTPPort, $sFTPDossierCapture)

			If $iRetour = 1 Then
				_ChangerEtatBouton($iIDAction, "Activer")
				_FichierCache("Supervision", 1)
			Else
				_FileWriteLog($hLog, "Impossible d'activer la supervision")
			EndIf
		Else
			FileDelete(@ScriptDir & "\Cache\Supervision\" & $sNomCapture)
			_ChangerEtatBouton($iIDAction, "Desactiver")
			_FichierCache("Supervision", -1)
		EndIf
	Else
		_CreerIndexSupervisionLocal()
		ShellExecute(@ScriptDir & "\Cache\Supervision\index.html")
	EndIf

	_UpdEdit($iIDEditLog, $hLog)

EndFunc

Func _CreerIndexSupervisionLocal()

	Local $iWidth = "33%", $hIndex
	Local $shtml = '<html><title>BAO - Supervision</title><meta http-equiv="refresh" content="60"><body>'
	Local $aCaptures = _FileListToArray(@ScriptDir & "\Cache\Supervision\", "*.png", 1)

	If @error = 0 Then
		If $iNBCaptures <> $aCaptures[0] Then
			$iNBCaptures = $aCaptures[0]
			$hIndex = FileOpen(@ScriptDir & "\Cache\Supervision\index.html", 2)

			If $aCaptures[0] = 1 Then
				$iWidth = "100%"
			ElseIf $aCaptures[0] = 2 Then
				$iWidth = "50%"
			EndIf

			_ArrayDelete($aCaptures, 0)

			Local $i = 0
			For $sImage In $aCaptures
				$i+=1
				$shtml &= '<a href="'&$sImage&'" title="'&$sImage&'"><img src="'&$sImage&'" style="float: left; width: '&$iWidth&';" /></a>'
				If $i = 3 Then
					$shtml &= '<br />'
					$i=0
				EndIf
			Next
			FileWrite($hIndex, $shtml & "</body></html>")
			FileClose($hIndex)
		EndIf
	ElseIf $iNBCaptures <> 0 Or Not FileExists(@ScriptDir & "\Cache\Supervision\index.html") Then
		$iNBCaptures = 0
		$shtml &= "<p>Aucune capture trouvée</p></body></html>"
		$hIndex = FileOpen(@ScriptDir & "\Cache\Supervision\index.html", 2)
		FileWrite($hIndex, $shtml & "</body></html>")
		FileClose($hIndex)
	EndIf

EndFunc

Func _SendCapture($sFTPAdresse, $sFTPUser, $sFTPPort, $sFTPDossierCapture)

	Local $iRetour = 0, $bCapt = False

	FileDelete($sCheminCapture & $sNomCapture)

 	$bCapt = _ScreenCapture_Capture($sCheminCapture & $sNomCapture)

	If $bCapt And StringLeft(@ScriptDir, 2) <> "\\" Then
		Local $nb = 0
		Do
			$iRetour = _EnvoiFTP($sFTPAdresse, $sFTPUser, $sFTPPort, $sCheminCapture & $sNomCapture, $sFTPDossierCapture & $sNomCapture, 0, 1)
			$nb+=1
		Until $iRetour <> -1 or $nb = 3
	ElseIf $bCapt Then
		FileCopy($sCheminCapture & $sNomCapture, @ScriptDir & "\Cache\Supervision\" & $sNomCapture, 1)
		$iRetour = 1
	Else
		_FileWriteLog($hLog, "La capture d'écran n'a pas pu être réalisée")
	EndIf

	Return $iRetour
EndFunc

Func _CreerIndexSupervision($sFTPAdresse, $sFTPUser, $sFTPPort)

	GUICtrlSetData($statusbar, " Envoi fichier index.php sur FTP")
	GUICtrlSetData($statusbarprogress, 20)

	Local $sNomFichier = @ScriptDir & '\Outils\index.php'

	If FileExists($sNomFichier) Then

		Sleep(1000)
		GUICtrlSetData($statusbarprogress, 50)
		Local $iRetour = 0

		Local $sFTPDossierCapture = IniRead($sConfig, "FTP", "DossierCapture", "")

		If($sFTPAdresse <> "" And $sFTPUser <> "" And $sFTPDossierCapture) Then
			Local $nb = 0
			Do
				$iRetour = _EnvoiFTP($sFTPAdresse, $sFTPUser, $sFTPPort, $sNomFichier, $sFTPDossierCapture & 'index.php')
				$nb+=1
			Until $iRetour <> -1 Or $nb=3

			if($iRetour <> 1) Then
				_Attention("Le Fichier n'a pas été envoyé")
				_FileWriteLog($hLog, "Fichier index pour supervision non envoyé sur FTP")
			Else
				GUICtrlSetData($statusbarprogress, 100)
				Sleep(2000)
				_FileWriteLog($hLog, 'Fichier créé sur le ftp: "' & $sFTPDossierCapture & 'index.php' & '"')
				_UpdEdit($iIDEditLog, $hLog)
			EndIf
		Else
			_Attention("Merci de configurer les infos FTP dans config.ini")
			_FileWriteLog($hLog, 'FTP non configuré, envoie index de supervision impossible')
		EndIf
	Else
		_Attention($sNomFichier & " n'existe pas")
		_FileWriteLog($hLog, $sNomFichier & ' absent')
	EndIf

	GUICtrlSetData($statusbar, "")
	GUICtrlSetData($statusbarprogress, 0)

EndFunc