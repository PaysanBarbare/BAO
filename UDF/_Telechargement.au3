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

; #FUNCTION# ====================================================================================================================
; Name ..........: _Telecharger
; Description ...: Telechargement direct ou indirect exe, zip, msi
; Syntax ........: _Telecharger($sNom, $sChemin)
; Parameters ....: 	$sNom	- Nom du programme
;					$sURL	- Chemin du fichier .url
; Return values..: Success - 1, defini Global $sProgrun avec lien à ouvrir
;                  Failure - Renvoi le lien contenu dans fichier url.
; Author.........: Bastien
; Modified ......:
; ===============================================================================================================================
Func _Telecharger($sNom, $sChemin)

	Local $dl = 0
	Local $ext
	Local $lastModified
	Local $FileName
	Local $FileNameUrl
	Local $FileNameExe
	Local $dlFileSize
	Local $FileSize
	Local $aLien = [$sNom, $sChemin]
	Local $hDownload
	Local $bOK = False
	Local $url
	Local $iInternet = 1
	Local $sec, $TotalSize, $Bytes, $CalBytes, $Percentage
	Local $oHTTP, $oReceived, $oStatusCode, $file

	If _isInternetConnected() = 0 Then
		$iInternet = 0
	Else

		DirCreate($sScriptDir & "\Cache\Download\")
		$dl = 0

		$url = $sChemin

		; Téléchargement indirect
		If (StringLeft(StringRight($sNom, 4), 1)) = "." Then
			$ext = StringRight($sNom, 4)
			$aLien[0] = StringTrimRight($sNom, 4)

			Local $source = BinaryToString(InetRead($url), 4)
			$url = StringRegExp($source, ' href="(.*?)' & $ext & '"', 3)

			If(IsArray($url)) Then
				$url = $url[0] & $ext

				; le lien réupéré dans la page est un lien relatif (surement à améliorer)
				If(StringLeft($url,4) <> "http") Then
					_IEErrorHandlerRegister()
					Local $oIE=_IECreate($sChemin,0,0)
					Local $oLinks = _IELinkGetCollection($oIE)

					For $oLink In $oLinks
						If(StringRight($oLink.href, 4) = $ext) Then
							$url = $oLink.href
						EndIf
						if(StringLeft($url,4) = "http") Then
							ExitLoop
						EndIf
					Next
					_IEQuit($oIE)

					If StringLeft($url,4) <> "http" Then
						; le lien absolu n'a pas pu être récupéré, ouverture du lien d'origine
						_Attention("Le logiciel n'a pas pu être télécharger automatiquement. Enregistrez " & $sNom & " dans le dossier " & @ScriptDir & "\Cache\Download\")
						ShellExecute($sChemin)
						Return True
					EndIf
				EndIf
			Else
				; Pas de lien trouvé dans la page
				_Attention("Le logiciel n'a pas pu être télécharger automatiquement. Enregistrez " & $sNom & " dans le dossier " & @ScriptDir & "\Cache\Download\")
				ShellExecute($sChemin)
				Return True
			EndIf

		Else
			$ext = StringRight($url, 4)
			If StringLeft($ext, 1) <> "." Then
				; Pas d'extension défini, on pari sur .exe. Il faudrait faire une recherche MIME sur fichier, mais normalement c'est un cas rare
				$ext = ".exe"
			EndIf
		EndIf

		$sProgrun = $sScriptDir & "\Cache\Download\" & $aLien[0] & $ext

;~ 		If(StringInStr(@ScriptDir, "\\") And $ext = ".zip") Then ;UNC
;~ 			;$sScriptDir = DriveMapAdd("*", @ScriptDir)
;~ 			$sProgrunUNC = $sScriptDir & "\Cache\Download\" & $aLien[0] & $ext
;~ 		EndIf

		If($iInternet = 0) Then
			If(FileExists($sProgrun)) Then
				; Le script continue même sans Internet
				$bOK = True
			EndIf

		Else

			$dlFileSize = InetGetSize($url)


			If(FileExists($sProgrun)) Then

				$FileSize = FileGetSize($sProgrun)

				If($dlFileSize <> 0 And $dlFileSize <> $FileSize And $sNom <> "SDI.zip") Then
					$dl = 1
					FileMove($sProgrun, $sScriptDir & "\Cache\Download\Old\", 1 + 8)
					If(StringRight($sProgrun, 4) = ".zip") Then
						If(FileExists(StringTrimRight($sProgrun, 4))) Then
							If(DirGetSize(StringTrimRight($sProgrun, 4))/1048576 > 500) Then
								Local $sRepdln = MsgBox($MB_YESNO, "Télécharger à nouveau", 'Le dossier "' & StringTrimRight($sProgrun, 4) & '" dépasse 500 Mo, êtes vous sûr de vouloir télécharger "' & $sNom & '" à nouveau ?')
								If ($sRepdln = 6) Then
									DirRemove(StringTrimRight($sProgrun, 4), 1)
								Else
									$dl = 0
								EndIf
							Else
								DirRemove(StringTrimRight($sProgrun, 4), 1)
							EndIf
						EndIf
					EndIf
				ElseIf($dlFileSize = 0 And $sNom <> "SDI.zip") Then
					Local $sDate = FileGetTime ($sProgrun)
					If(_DateDiff( "D" ,$sDate[0] & "/" & $sDate[1] & "/" & $sDate[2], _NowCalcDate ( )) > 5) Then
						$dl = 1
						FileMove($sProgrun, $sScriptDir & "\Cache\Download\Old\", 1 + 8)
						If(StringRight($sProgrun, 4) = ".zip") Then
							If(FileExists(StringTrimRight($sProgrun, 4))) Then
								DirRemove(StringTrimRight($sProgrun, 4), 1)
							EndIf
						EndIf
					Else
						$bOK = True
					EndIf
				Else
					$bOK = True
				EndIf
			Else
				$dl = 1
			EndIf

			if $dl = 1 Then
				; Téléchargement direct
				$hDownload = InetGet($url, $sProgrun, 1, 1)
				$TotalSize = Round($dlFileSize / 1024)
				GUICtrlSetData($statusbar, " Téléchargement de " & $aLien[0])
				GUICtrlSetState($iIDCancelDL, $GUI_ENABLE)
				GUISetState()
				Do
				$sec = @SEC
				$Bytes = Round(InetGetInfo($hDownload,0))
				While @SEC = $sec
				Sleep(10)
				If GUIGetMsg() = $iIDCancelDL Then
					GUICtrlSetData($statusbar, "")
					GUICtrlSetData($statusbarprogress, 0)
					GUICtrlSetState($iIDCancelDL, $GUI_DISABLE)
					FileDelete($sProgrun)
					InetClose($hDownload)
					If(FileExists($sScriptDir & "\Cache\Download\Old\" & $aLien[0] & $ext)) Then FileMove($sScriptDir & "\Cache\Download\Old\" & $aLien[0] & $ext, $sScriptDir & "\Cache\Download\", 1 + 8)
					Return False
				EndIf
				WEnd
				$CalBytes = Round(InetGetInfo($hDownload,0))
				$TotalSize = $TotalSize - (($CalBytes - $Bytes) /1024)
				$Percentage = Round($TotalSize / $dlFileSize * 100000)
				$Percentage = 100 - $Percentage
				GUICtrlSetData($statusbarprogress,$Percentage)
				Until InetGetInfo($hDownload,2)
				GUICtrlSetState($iIDCancelDL, $GUI_DISABLE)
				GUICtrlSetData($statusbar, "")
				GUICtrlSetData($statusbarprogress, 0)

				Local $aData = InetGetInfo($hDownload)
				If @error Then
					If(FileExists($sScriptDir & "\Cache\Download\Old\" & $aLien[0] & $ext)) Then
						FileMove($sScriptDir & "\Cache\Download\Old\" & $aLien[0] & $ext, $sScriptDir & "\Cache\Download\", 1 + 8)
						_Attention("Erreur lors du téléchargement de " & $aLien[0] & ". La version précédente sera exécutée")
						$bOK = True
					Else
						_Attention("Erreur lors du téléchargement de " & $aLien[0])
					EndIf
				Else
					If FileExists($sProgrun) And FileGetSize($sProgrun) = $dlFileSize Then
						$bOK = True
					Else
						; Essai de téléchargement avec headers, certains log Nirsoft nécessite cela
						$oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
						$oHTTP.Open("POST", $url)
						$oHTTP.SetRequestHeader("referer", "http://www.google.com")
						$oHTTP.SetRequestHeader("user-agent", "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.6) Gecko/20070725 Firefox/2.0.0.6")
						$oHTTP.SetRequestHeader("Accept", "text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5")
						$oHTTP.SetRequestHeader("Accept-Language", "en-us,en;q=0.5")
						$oHTTP.SetRequestHeader("Accept-Encoding", "gzip,deflate")
						$oHTTP.SetRequestHeader("Accept-Charset", "ISO-8859-1,utf-8;q=0.7,*;q=0.7")
						$oHTTP.SetRequestHeader("Keep-Alive", "300")
						$oHTTP.Send()

						$oStatusCode = $oHTTP.Status
						$oReceived = $oHTTP.ResponseBody
						If $oStatusCode == 200 then
							$file = FileOpen($sProgrun, 2) ; The value of 2 overwrites the file if it already exists
							FileWrite($file, $oReceived)
							FileClose($file)
							$bOK = True
						EndIf
					EndIf
				EndIf

				InetClose($hDownload)
			EndIf
		EndIf
	EndIf

	Return $bOK
EndFunc   ;==>_Telecharger

; #FUNCTION# ====================================================================================================================
; Name ..........: _Executer
; Description ...:
; Syntax ........:
; Parameters ....:
; Return values..:
; Author.........: Bastien
; Modified ......:
; ===============================================================================================================================
Func _Executer($sNom, $arg = "", $norun = 0)

	Local $sDocp, $iPid = 0, $sProgruntmp = $sProgrun

	GUICtrlSetData($statusbar, "Exécution de " & $sNom)

	If(StringRight($sNom, 4) = ".zip") Then
		$sNom = StringTrimRight($sNom, 4)
	EndIf

	If(StringRight($sProgrun, 4) = ".zip") Then

		If($sProgrunUNC <> "") Then ;UNC
			$sProgruntmp = $sProgrunUNC
		EndIf

		$sDocp = $sScriptDir & "\Cache\Download\" & $sNom & "\"

		If FileExists($sDocp) = 0 Then
			If _Zip_UnzipAll($sProgruntmp, $sDocp) = 0 Then

				Switch @error
					Case 1
						_Attention('Unzip : zipfldr.dll does not exist')
;
					Case 2
						_Attention('Unzip : Library not installed')

					Case 3
						_Attention('Unzip : Not a full path')

					Case 4
						_Attention('Unzip : ZIP file does not exist')

					Case 5
						_Attention('Unzip : Failed to create destination (if necessary)')

					Case 6
						_Attention('Unzip : Failed to open destination')

					Case 7
						_Attention('Unzip : Failed to extract file(s)')

				EndSwitch
			EndIf
		EndIf

		If(StringInStr(@ScriptDir, "\\")) Then ;UNC
 			;DriveMapDel($sScriptDir)
; 			$sScriptDir = @ScriptDir
 ;			$sDocp = @ScriptDir & "\Cache\Download\" & $sNom & "\"
			; attribution des droits sur les fichiers en réseau
			;ClipPut('icacls "' & $sDocp & '" /T /grant *S-1-1-0:F')
			;_debug('icacls "' & $sDocp & '" /T /grant *S-1-1-0:F')
			RunWait('icacls * /T /grant *S-1-1-0:F', $sDocp, @SW_HIDE)
 		EndIf

		$sDocp = _RechercheExeInZip($sDocp, $sNom)
	EndIf

	Local $sDocOutil = $sScriptDir & "\Outils\" & $sNom & "\"
	If(FileExists($sDocOutil)) Then
		If($sDocp <> "") Then
			FileCopy($sDocOutil & "*", $sDocp, 1)
		Else
			FileCopy($sDocOutil & "*", $sScriptDir & "\Cache\Download\")
		EndIf
	EndIf

	If($norun = 0) Then

		If(FileExists($sDocOutil & $sNom & ".bat")) Then
			If($sDocp = "") Then
				$sDocp = $sScriptDir & "\Cache\Download\"
			EndIf

			RunWait(@ComSpec & ' /c "' & $sNom & '.bat" install' ,$sDocp)
			$sProgrun = @ComSpec & ' /c "' & $sNom & '.bat" run ' & @OSArch
			$iPid = Run($sProgrun, $sDocp)

		ElseIf($arg <> "") Then
			If($sDocp = "") Then
				$sDocp = $sScriptDir & "\Cache\Download\"
			EndIf

			$iPid = ShellExecute($sProgrun, $arg, $sDocp)
		Else
			If(StringInStr (FileGetAttrib ($sProgrun), "D")) Then
				ShellExecute($sProgrun)
			Else
				$iPid = Run($sProgrun, $sDocp)
			EndIf
		EndIf
	Else
		$iPid = $sDocp
	EndIf

	GUICtrlSetData($statusbar, "")

	Return $iPid

EndFunc   ;==>_Executer

; #FUNCTION# ====================================================================================================================
; Name ..........: _RechercheExeInZip
; Description ...:
; Syntax ........:
; Parameters ....:
; Return values..:
; Author.........: Bastien
; Modified ......:
; ===============================================================================================================================

Func _RechercheExeInZip($doc, $sNom)

	$sProgrun = $doc
	_FileListToArray($doc, "*", $FLTA_FILES)
	If(@error = 4) Then
		; l'exe est dans un sous dossier
		Local $tmp = _FileListToArray($doc, "*", $FLTA_FOLDERS)
		If UBound($tmp) = 2 Then
			$doc = $doc & $tmp[1] & "\"
		EndIf
	EndIf

	Local $arch = StringRight(@OSArch, 2)
	Local $aTemp = _FileListToArray($doc, "*" & $arch & "*.exe")

	If(UBound($aTemp) > 0) Then
		$sProgrun = $doc & $aTemp[1]
	Else
		$aTemp = _FileListToArrayRec($doc, $sNom & "*.exe|*Translation*")

		If(UBound($aTemp) > 0) Then
			$sProgrun = $doc & $aTemp[1]
		Else
			If(StringRight($sNom, 2) = $arch) Then
				$aTemp = _FileListToArrayRec($doc, StringTrimRight($sNom, 4) & "*.exe")

				If(UBound($aTemp) > 0) Then
					$sProgrun = $doc & $aTemp[1]
				EndIf
			EndIf
		EndIf
	EndIf

	Return $doc

EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _DriveMapDel
; Description ...:
; Syntax ........:
; Parameters ....:
; Return values..:
; Author.........: Bastien
; Modified ......:
; ===============================================================================================================================

Func _DriveMapDel()
	If(StringInStr(@ScriptDir, "\\")) Then ;UNC
		DriveMapDel($sScriptDir)
	EndIf
EndFunc

Func _UpdateProg()

	Local $sNomLogk
	Local $aListeLiens = MapKeys($aMenu)
	For $sNomLogk in $aListeLiens
		If(StringLeft($sNomLogk, 1) <> "#" And StringLeft(($aMenu[$sNomLogk])[2], 4) = "http") Then
			_Telecharger($sNomLogk, ($aMenu[$sNomLogk])[2])
		EndIf
	Next

EndFunc


Func _ExecuteProg()
	If StringLeft(($aMenuID[$iIDAction])[1], 1) <> "#" And StringLeft(($aMenuID[$iIDAction])[2], 4) = "http"  Then
		If(_Telecharger(($aMenuID[$iIDAction])[1], ($aMenuID[$iIDAction])[2])) Then
			$iPidt[($aMenuID[$iIDAction])[1]] = _Executer(($aMenuID[$iIDAction])[1])
		EndIf
	Else
		If(StringInStr(($aMenuID[$iIDAction])[2], " ") > 0) Then
			Run(($aMenuID[$iIDAction])[2])
		Else
			ShellExecute(($aMenuID[$iIDAction])[2])
		EndIf
	EndIf
EndFunc