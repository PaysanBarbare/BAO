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

Func _Supervision()

	Local $iRetour

	If($iModeTech = 0) Then
		If _FichierCacheExist("Supervision") = 0 Then

			_GetResolution()

			$iRetour = _SendCapture()

			If $iRetour = 1 Then
				_ChangerEtatBouton($iIDAction, "Activer")
				_FichierCache("Supervision", 1)
				_DesactivationFondecran()
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

Func _GetResolution()
	Dim $Obj_WMIService = ObjGet("winmgmts:\\" & "localhost" & "\root\cimv2")
	Dim $Obj_Services = $Obj_WMIService.ExecQuery("Select * from Win32_VideoController")
	Local $Obj_Item
	For $Obj_Item In $Obj_Services
		$iScreenWidth = $Obj_Item.CurrentHorizontalResolution
		$iScreenHeight = $Obj_Item.CurrentVerticalResolution
		If $iScreenWidth <> "" Then
			ExitLoop
		EndIf
	Next

	If $iScreenWidth = "" Then
		_FileWriteLog($hLog, "Résolution de l'écran non récupérée")
		$iScreenHeight = @DesktopHeight
		$iScreenWidth = @DesktopWidth
	EndIf
EndFunc

Func _CreerIndexSupervisionLocal()

	Local $iWidth = "33%", $hIndex
	Local $shtml = '<html><title>BAO - Supervision locale</title><meta http-equiv="refresh" content="60"><body>'
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
				$shtml &= '<a href="'&$sImage&'" title="'&$sImage&'"><img src="'&$sImage&'" alt="'&$sImage&' (intervention terminée)" style="float: left; width: '&$iWidth&';" /></a>'
				If $i = 3 Then
					$shtml &= '<br />'
					$i=0
				EndIf
			Next
			FileWrite($hIndex, $shtml & "</body></html>")
			FileClose($hIndex)
		EndIf
	Else
		$iNBCaptures = 0
		$shtml &= "<p>Aucune capture trouvée</p></body></html>"
		$hIndex = FileOpen(@ScriptDir & "\Cache\Supervision\index.html", 2)
		FileWrite($hIndex, $shtml & "</body></html>")
		FileClose($hIndex)
	EndIf

EndFunc

Func _MakeCapture()
	Local $return = false
	$return = _ScreenCapture_Capture($sCheminCapture & $sNomCapture, 0, 0, $iScreenWidth, $iScreenHeight)
	If $return = False Then
		_FileWriteLog($hLog, "La capture d'écran n'a pas pu être réalisée")
	EndIf
	Return $return
EndFunc

Func _SendCapture()

	Local $iRetour = 0, $bCapt = False

	FileDelete($sCheminCapture & $sNomCapture)

 	$bCapt = _MakeCapture()

	If $bCapt Then
		Local $nb = 0
		Do
			$iRetour = _EnvoiFTP($sCheminCapture & $sNomCapture, $sFTPDossierCapture & $sNomCapture, 0, 1)
			$nb+=1
		Until $iRetour <> -1 or $nb = 3

		If StringLeft(@ScriptDir, 2) = "\\" Then
			_SendCaptureLocal()
		EndIf
	EndIf

	Return $iRetour
EndFunc

Func _SendCaptureLocal()
	If _MakeCapture() Then
		FileCopy($sCheminCapture & $sNomCapture, @ScriptDir & "\Cache\Supervision\" & $sNomCapture, 1)
	EndIf
EndFunc

Func _CreerIndexSupervision()

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
				$iRetour = _EnvoiFTP($sNomFichier, $sFTPDossierCapture & 'index.php')
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

Func _DesactivationFondecran()
	If _FichierCacheExist("Fondecran") = 0 Then
		Local $sWallpaper = RegRead("HKEY_CURRENT_USER\Control Panel\Desktop\", "WallPaper"), $bVerifWallpaper = False
		If $sWallpaper <> "" Then
			If Not FileExists($sWallpaper) Then
				If FileExists(@AppDataDir & '\Microsoft\Windows\Themes\TranscodedWallpaper') Then
					If FileCopy(@AppDataDir & '\Microsoft\Windows\Themes\TranscodedWallpaper', $sWallpaper) Then
						_FileWriteLog($hLog, "Restauration du fond d'écran avant désactivation (" & $sWallpaper & ")")
						$bVerifWallpaper = True
					Else
						_FileWriteLog($hLog, "Désactivation du fond d'écran impossible : copie de TranscodeWallpaper échouée")
					EndIf
				Else
					_FileWriteLog($hLog, "Désactivation du fond d'écran impossible car l'image n'a pas été trouvée")
				EndIf
			Else
				$bVerifWallpaper = True
			EndIf
			If $bVerifWallpaper Then
				_FileWriteLog($hLog, "Désactivation du fond d'écran")
				_FichierCache("Fondecran", $sWallpaper)
				RegWrite("HKEY_CURRENT_USER\Control Panel\Desktop","WallPaper","REG_SZ",'')
				ControlSend('Program Manager', '', '', '{F5}')
			EndIf
		EndIf
	EndIf
EndFunc

Func _ActivationFondecran()
	If _FichierCacheExist("Fondecran") Then
		Local $sWallpaper = _FichierCache("Fondecran")
		If $sWallpaper <> "" Then
			_FileWriteLog($hLog, "Réactivation du fond d'écran")
			RegWrite("HKEY_CURRENT_USER\Control Panel\Desktop","WallPaper","REG_SZ",$sWallpaper)
			ControlSend('Program Manager', '', '', '{F5}')
		EndIf
	EndIf
EndFunc