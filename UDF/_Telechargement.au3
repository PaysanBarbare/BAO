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
Func _Telecharger($aLogToDL, $test = 0, $sProgression="")

	Local $dl = 0
	Local $lognom = $aLogToDL[1]
	Local $url = $aLogToDL[2]
	Local $logforcedl = $aLogToDL[4]
	Local $logheaders = $aLogToDL[5]
	Local $bPWD =$aLogToDL[6]
	Local $ext = $aLogToDL[8]
	Local $expression = $aLogToDL[11]
	Local $expressionnonincluse = $aLogToDL[12]
	Local $logdomaine = $aLogToDL[9]
	Local $lognepasmaj = $aLogToDL[10]
	Local $lastModified
	Local $FileName
	Local $FileNameUrl
	Local $FileNameExe
	Local $dlFileSize
	Local $FileSize
	Local $hDownload
	Local $bOK = False
	Local $iInternet = 1
	Local $sec, $TotalSize, $Bytes, $CalBytes, $Percentage
	Local $oHTTP, $oReceived, $oStatusCode, $file
	Local $source
	Local $aPWD

	If _isInternetConnected() = 0 Then
		$iInternet = 0
	Else
		If $test = 0 Then
			_FileWriteLog($hLog, $sProgression & "Téléchargement de " & $lognom )
		Else
			_FileWriteLog($hLog, "Test de téléchargement de " & $lognom )
		EndIf
		$dl = 0

		; Téléchargement indirect
		If $logforcedl = 0 And $ext <> "" Then

			_FileWriteLog($hLog, "Recherche du lien de téléchargement dans le code source de la page")

			$source = BinaryToString(InetRead($url), 4)
			;_Debug($source)
			If $expression <> "" Then
				$url = StringRegExp($source, ' href="(.*?' & $expression & '.*?)\.' & $ext & '"', 3)
			Else
				$url = StringRegExp($source, ' href="(.*?)\.' & $ext & '"', 3)
			EndIf

			;_Debug($url)
			If(IsArray($url) = 0) Then
				_FileWriteLog($hLog, "Pas de lien trouvé avec l'extension .zip  ; recherche sans extension")
				$source = StringReplace($source, "\","")
				If $expression <> "" Then
					$url = StringRegExp($source, ' href="(.*?' & $expression & '.*?)"', 3)
				Else
					$url = StringRegExp($source, ' href="(.*?)"', 3)
				EndIf
				$ext=""
			EndIf

			If $bPWD = 1 Then
				$aPWD = StringRegExp($source, "copyTextToClipboard\(\'(.*?)\'\);", 1)
				$sPWDZip = $aPWD[0]
			EndIf


			If(IsArray($url)) Then
				If $expressionnonincluse <> "" Then
					For $urltotest In $url
						If StringInStr($urltotest, $expressionnonincluse) Then
							_FileWriteLog($hLog, "lien ignoré (contient " & $expressionnonincluse & " : " & $urltotest)
						Else
							If $ext <> "" Then
								$url = $urltotest & "." & $ext
							Else
								$url = $urltotest
								$ext = "exe"
							EndIf
							ExitLoop
						EndIf
					Next
				Else
					If $ext <> "" Then
						$url = $url[0] & "." & $ext
					Else
						$url = $url[0]
						$ext = "exe"
					EndIf
				EndIf

				If IsArray($url) Then
					If $test = 1 Then
						_Attention("Pas de lien trouvé")
					Else
						_Attention("Le logiciel n'a pas pu être téléchargé." & 'Vérifiez les réglages (lien contenant "' & $expressionnonincluse & '" ignoré)')
					EndIf
					Return False
				EndIf

				; le lien récupéré dans la page est un lien relatif (surement à améliorer)
				If(StringLeft($url,4) <> "http") Then
					If $logdomaine <> "" Then
						$url = $logdomaine & $url
					Else
						_FileWriteLog($hLog, 'Erreur : Lien relatif pour "' & $lognom & '" : "' & $url & '"')
						_Attention('Le lien récupéré est un lien relatif ("' & $url & '"). Merci de compléter la valeur "Domaine"')
						Return False
					EndIf
				EndIf
			Else
				; Pas de lien trouvé dans la page
				_FileWriteLog($hLog, "Lien non trouvé")
				If $test = 1 Then
					_Attention("Pas de lien trouvé")
				Else
					_Attention("Le logiciel n'a pas pu être télécharger automatiquement. Enregistrez " & $lognom & " dans le dossier " & @ScriptDir & "\Cache\Download\")
					ShellExecute($aLogToDL[2])
				EndIf
				Return False
			EndIf

		Else
			If $ext = "" Then
				If (StringLeft(StringRight($url, 4), 1) = ".") Then
					$ext = StringRight($url, 3)
				ElseIf(StringLeft(StringRight($url, 3), 1) = ".") Then
					$ext = StringRight($url, 2)
				Else
					_FileWriteLog($hLog, "Extension non précisée. Essai avec .exe")
					; Pas d'extension défini, on pari sur .exe. Il faudrait faire une recherche MIME sur fichier, mais normalement c'est un cas rare
					$ext = "exe"
				EndIf
			EndIf
		EndIf

		If $test = 0 Then
			$sProgrun = @ScriptDir & "\Cache\Download\" & $lognom & "." & $ext
		Else
			$sProgrun = @TempDir & "\" & $lognom & "." & $ext
		EndIf
		_FileWriteLog($hLog, "Lien de téléchargement : " & $url)
		_FileWriteLog($hLog, "Destination : " & $sProgrun)
;~ 		If(StringInStr(@ScriptDir, "\\") And $ext = ".zip") Then ;UNC
;~ 			;@ScriptDir = DriveMapAdd("*", @ScriptDir)
;~ 			$sProgrunUNC = @ScriptDir & "\Cache\Download\" & $aLien[0] & $ext
;~ 		EndIf
		;_Debug($url)

		If($iInternet = 0) Then
			If $test = 1 Then
				_Attention("Il n'y a pas Internet, le téléchargement ne peut être testé")
				Return False
			ElseIf(FileExists($sProgrun)) Then
				; Le script continue même sans Internet
				$bOK = True
			EndIf
		Else
			;_Attention($url)
			$dlFileSize = InetGetSize($url)

			If(FileExists($sProgrun) And $test = 0 And $lognepasmaj = 0) Then

				$FileSize = FileGetSize($sProgrun)

				If($dlFileSize <> 0 And $dlFileSize <> $FileSize) Then
					$dl = 1
					FileMove($sProgrun, @ScriptDir & "\Cache\Download\Old\", 1 + 8)
					If($ext = "zip") Then
						If(FileExists(StringTrimRight($sProgrun, 4))) Then
							If(DirGetSize(StringTrimRight($sProgrun, 4))/1048576 > 500) Then
								Local $sRepdln = MsgBox($MB_YESNO, "Télécharger à nouveau", 'Le dossier "' & StringTrimRight($sProgrun, 4) & '" dépasse 500 Mo, êtes vous sûr de vouloir télécharger "' & $lognom & '" à nouveau ?')
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
				ElseIf($dlFileSize = 0) Then
					Local $sDate = FileGetTime ($sProgrun)
					If(_DateDiff( "D" ,$sDate[0] & "/" & $sDate[1] & "/" & $sDate[2], _NowCalcDate ( )) > 5) Then ; le log a plus de 5 jours
						$dl = 1
						FileMove($sProgrun, @ScriptDir & "\Cache\Download\Old\", 1 + 8)
						If($ext = "zip") Then
							If(FileExists(StringTrimRight($sProgrun, 4))) Then
								DirRemove(StringTrimRight($sProgrun, 4), 1)
							EndIf
						EndIf
					Else
						_FileWriteLog($hLog, "Logiciel à jour, téléchargement ignoré")
						$bOK = True
					EndIf
				Else
					_FileWriteLog($hLog, "Logiciel à jour, téléchargement ignoré")
					$bOK = True
				EndIf
			ElseIf FileExists($sProgrun) = 0 Or $test = 1 Then
				$dl = 1
			EndIf

			if $dl = 1 And $logheaders = 0 Then
				_FileWriteLog($hLog, "Démarrage du téléchargement")

				; Téléchargement direct
				$hDownload = InetGet($url, $sProgrun, 1, 1)
				$TotalSize = Round($dlFileSize / 1024)
				GUICtrlSetData($statusbar, $sProgression & "Téléchargement de " & $lognom)
				If $test = 0 Then
					GUICtrlSetState($iIDCancelDL, $GUI_ENABLE)
				EndIf
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
							If(FileExists(@ScriptDir & "\Cache\Download\Old\" & $lognom & "." & $ext)) Then FileMove(@ScriptDir & "\Cache\Download\Old\" & $lognom & "." & $ext, @ScriptDir & "\Cache\Download\", 1 + 8)
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
					_FileWriteLog($hLog, "Erreur de téléchargement " & @error)
					If($test = 0 And FileExists(@ScriptDir & "\Cache\Download\Old\" & $lognom & "." & $ext)) Then
						FileMove(@ScriptDir & "\Cache\Download\Old\" & $lognom & "." & $ext, @ScriptDir & "\Cache\Download\", 1 + 8)
						_Attention("Erreur lors du téléchargement de " & $lognom & ". La version précédente sera exécutée")
						$bOK = True
					Else
						_Attention("Erreur lors du téléchargement de " & $lognom)
						FileDelete($sProgrun)
					EndIf
				Else
					Sleep(100)
					If FileExists($sProgrun) And FileGetSize($sProgrun) = $dlFileSize Then
						$bOK = True
					ElseIf FileExists($sProgrun) And $dlFileSize = 0 And FileGetSize($sProgrun) > 5000  Then
						$bOK =True
					Else
						_FileWriteLog($hLog, 'Erreur de téléchargement, "' & $sProgrun & '" fait seulement ' & FileGetSize($sProgrun) & ' octets')
						_Attention('Erreur lors du téléchargement de "' & $lognom & '". Vérifier le paramétrage')
					EndIf
					If $test = 1 Then
						FileDelete($sProgrun)
					EndIf
				EndIf

				InetClose($hDownload)

			ElseIf $dl = 1 And $logheaders = 1 Then
				GUICtrlSetData($statusbar, $sProgression & "Téléchargement de " & $lognom)
				$oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
				$oHTTP.Open("POST", $url)
				$oHTTP.SetRequestHeader("referer", $aLogToDL[2])
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
					If $test = 0 Then
						GUICtrlSetData($statusbarprogress, 25)
						$file = FileOpen($sProgrun, 2) ; The value of 2 overwrites the file if it already exists
						FileWrite($file, $oReceived)
						FileClose($file)
					EndIf
					$bOK = True
				Else
					_FileWriteLog($hLog, 'Erreur de téléchargement, "' & $sProgrun & '" avec headers. Code de retour : ' & $oStatusCode)
					_Attention('Erreur lors du téléchargement de "' & $lognom & '" (headers activés). Vérifier le paramétrage')
				EndIf
				GUICtrlSetData($statusbar, "")
				GUICtrlSetData($statusbarprogress, 0)
			EndIf
		EndIf
	EndIf

	Return $bOK
EndFunc   ;==>_Telecharger

Func _TryDL($aEnr)
	Local $iRetour = 0
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
	If StringLeft($aEnr[2], 2) = "\\" Then
		If FileExists($aEnr[2]) Then
			$iRetour = 1
		Else
			_FileWriteLog($hLog, $aEnr[2] & ' : dossier inexistant')
			_Attention('Le dossier "' & $aEnr[2] & '"' & " n'existe pas")
		EndIf
	ElseIf $aEnr[3] = 1 Then
		If __checkConn($aEnr[2]) Then
			$iRetour = 1
		Else
			_FileWriteLog($hLog, $aEnr[1] & ' : site inaccessible')
			_Attention("Impossible d'ouvrir le lien " & $aEnr[1])
		EndIf
	Else
		$iRetour = _Telecharger($aEnr, 1)
	EndIf

	Return $iRetour
EndFunc

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
	ElseIf(StringRight($sNom, 3) = ".7z") Then
		$sNom = StringTrimRight($sNom, 3)
	EndIf

	If(StringRight($sProgrun, 4) = ".zip" Or StringRight($sProgrun, 3) = ".7z") Then

		If($sProgrunUNC <> "") Then ;UNC
			$sProgruntmp = $sProgrunUNC
		EndIf

		$sDocp = @ScriptDir & "\Cache\Download\" & $sNom & "\"

		If FileExists($sDocp) = 0 Then
			If($sPWDZip <> "") Then
				_FileWriteLog($hLog, "Décompression de l'archive avec mot de passe")
				RunWait(@ComSpec & ' /c ""' & @ScriptDir & '\Outils\7z\7z.exe" x "' & $sProgruntmp & '" -o"' & $sDocp & '" -p"' & $sPWDZip&'""', @ScriptDir & '\Cache\Download\', @SW_HIDE)
			Else
				_FileWriteLog($hLog, "Décompression de l'archive")
				RunWait(@ComSpec & ' /c ""' & @ScriptDir & '\Outils\7z\7z.exe" x "' & $sProgruntmp & '" -o"' & $sDocp & '""', @ScriptDir & '\Cache\Download\', @SW_HIDE)
			EndIf
		EndIf

;~ 		If(StringInStr(@ScriptDir, "\\")) Then ;UNC
;~  			;DriveMapDel(@ScriptDir)
;~ ; 			@ScriptDir = @ScriptDir
;~  ;			$sDocp = @ScriptDir & "\Cache\Download\" & $sNom & "\"
;~ 			; attribution des droits sur les fichiers en réseau
;~ 			;ClipPut('icacls "' & $sDocp & '" /T /grant *S-1-1-0:F')
;~ 			;_debug('icacls "' & $sDocp & '" /T /grant *S-1-1-0:F')
;~ 			RunWait('icacls * /T /grant *S-1-1-0:F', $sDocp, @SW_HIDE)
;~  		EndIf

		$sDocp = _RechercheExeInZip($sDocp, $sNom)
	EndIf

	Local $sDocOutil = @ScriptDir & "\Config\" & $sNom & "\"
	If(FileExists($sDocOutil)) Then
		If($sDocp <> "") Then
			FileCopy($sDocOutil & "*", $sDocp, 1)
		Else
			FileCopy($sDocOutil & "*", @ScriptDir & "\Cache\Download\")
		EndIf
	EndIf
	If($norun = 0) Then

		_FileWriteLog($hLog, "Exécution de " & $sProgrun)

		If FileExists($sProgrun) = 0 Then
			_Attention($sProgrun & " n'existe pas. Si votre antivirus l'a mis en quarantaine, restaurez le maintenant", 1)
		EndIf

		If(FileExists($sDocOutil & $sNom & ".bat")) Then
			If($sDocp = "") Then
				$sDocp = @ScriptDir & "\Cache\Download\"
			EndIf

			RunWait(@ComSpec & ' /c ""' & $sDocp & $sNom & '.bat" install"')
			$sProgrun = @ComSpec & ' /c ""' & $sDocp & $sNom & '.bat" run ' & @OSArch & '"'
			$iPid = Run($sProgrun)

			If $iPid = 0 And @error <> 0 Then
				_Attention($sProgrun & " a échoué. Si votre antivirus l'a mis en quarantaine, restaurez le maintenant", 1)
				$iPid = Run($sProgrun)
			EndIf

		ElseIf($arg <> "") Then
			If($sDocp = "") Then
				$sDocp = @ScriptDir & "\Cache\Download\"
			EndIf

			$iPid = ShellExecute($sProgrun, $arg, $sDocp)
			If $iPid = 0 And @error <> 0 Then
				_Attention($sProgrun & " a échoué. Si votre antivirus l'a mis en quarantaine, restaurez le maintenant", 1)
				$iPid = ShellExecute($sProgrun, $arg, $sDocp)
			EndIf
		Else
			If(StringInStr (FileGetAttrib ($sProgrun), "D")) Then
				$iPid = ShellExecute($sProgrun)
				If $iPid = 0 And @error <> 0 Then
					_Attention($sProgrun & " a échoué. Si votre antivirus l'a mis en quarantaine, restaurez le maintenant", 1)
					$iPid = ShellExecute($sProgrun, $arg, $sDocp)
				EndIf
			Else
				$iPid = Run($sProgrun, $sDocp)
				If $iPid = 0 And @error <> 0 Then
					_Attention($sProgrun & " a échoué. Si votre antivirus l'a mis en quarantaine, restaurez le maintenant", 1)
					$iPid = Run($sProgrun, $sDocp)
				EndIf
			EndIf
		EndIf
	Else
		$iPid = $sDocp
	EndIf
	_UpdEdit($iIDEditLog, $hLog)

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

	_FileWriteLog($hLog, "Recherche de l'exécutable dans l'archive décompressée")
	_UpdEdit($iIDEditLog, $hLog)
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

Func _UpdateProg()

	Local $sNomLogk
	Local $aListeLiens = MapKeys($aMenu)
	Local $iCountEle = 0, $i = 1
	Local $bReturn

	For $sLogCount in $aMenu
		If $sLogCount[3] <> 1 And $sLogCount[6] <> 1 And $sLogCount[10] <> 1 And StringLeft($sLogCount[2], 4) = "http" Then
			$iCountEle+=1
		EndIf
	Next


	For $sNomLogk in $aListeLiens
		If(($aMenu[$sNomLogk])[3] <> 1 And ($aMenu[$sNomLogk])[6] <> 1 And ($aMenu[$sNomLogk])[10] <> 1 And StringLeft(($aMenu[$sNomLogk])[2], 4) = "http") Then
			GUICtrlSetData($statusbar, "Patientez ...")
			$bReturn = _Telecharger($aMenu[$sNomLogk], 0, "(" & $i & "/" & $iCountEle & ") ")
			$i+=1
			If ($bReturn = False) Then
				_Attention("Echec du téléchargement de " & $sNomLogk, 1)
			EndIf
		EndIf
	Next
	GUICtrlSetData($statusbar, "")
	_Attention("Téléchargement des logiciels terminé")
	;_UpdEdit($iIDEditRapport, $hFichierRapport)
EndFunc


Func _ExecuteProg()
	If StringLeft(($aMenuID[$iIDAction])[2], 5) = "choco" Then
		Local $aSoftToInstall[0]
		If FileExists( @AppDataCommonDir & "\chocolatey\choco.exe") = 0 Then
			_FileWriteLog($hLog, 'Installation de Chocolatey')
			GUICtrlSetData($statusbar, " Préparation de l'installation")
			GUICtrlSetData($statusbarprogress, 5)
			Local $sEnvVar = EnvGet("PATH")

			EnvSet("PATH", $sEnvVar & ";" & @AppDataCommonDir & "\Chocolatey\bin")
			EnvUpdate()
			RunWait(@ComSpec & ' /c ' & '@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command " [System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString(''https://chocolatey.org/install.ps1''))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"', "", @SW_HIDE)

			GUICtrlSetData($statusbarprogress, 10)

			If FileExists( @AppDataCommonDir & "\chocolatey\choco.exe") = 0 Then
				ClipPut(@ComSpec & ' /c ' & '@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command " [System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString(''https://chocolatey.org/install.ps1''))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"')
				_Attention("PowerShell n'est pas installé ou Chocolatey n'a pu s'installer. Fin de l'éxécution (cmd dans le presse papier)")
				GUICtrlSetData($statusbar, "")
				GUICtrlSetData($statusbarprogress, 0)
			Else
				_FichierCache("Installation", 1)
			EndIf
		Else
			_FileWriteLog($hLog, 'Chocolatey est déjà installé')
			_FichierCache("Installation", 1)
		EndIf

		If(_FichierCacheExist("Installation") = 1) Then
			_FileWriteLog($hLog, 'Installation de ' & ($aMenuID[$iIDAction])[1])
			_ArrayAdd($aSoftToInstall, ($aMenuID[$iIDAction])[1])
			_FichierCache("ChocoMenu", ($aMenuID[$iIDAction])[1])
			_InstallationEnCours($aSoftToInstall)

			GUICtrlSetData($statusbar, "")
			GUICtrlSetData($statusbarprogress, 0)
		EndIf
	ElseIf StringLeft(($aMenuID[$iIDAction])[2], 4) = "http" And ($aMenuID[$iIDAction])[3] = "0" Then
		If(_Telecharger($aMenuID[$iIDAction])) Then
			$iPidt[($aMenuID[$iIDAction])[1]] = _Executer(($aMenuID[$iIDAction])[1])
		EndIf
	Else
		If(StringInStr(($aMenuID[$iIDAction])[2], " ") > 0) Then
			Run(($aMenuID[$iIDAction])[2])
		Else
			If((($aMenuID[$iIDAction])[2] = "rstrui" or ($aMenuID[$iIDAction])[2] = "rstrui.exe") And @OSArch = "X64") Then
				ShellExecute(@WindowsDir & "\system32\rstrui.exe")
			Else
				ShellExecute(($aMenuID[$iIDAction])[2])
			EndIf
		EndIf
	EndIf
EndFunc