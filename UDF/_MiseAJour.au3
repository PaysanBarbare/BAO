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

Func _MiseAJourOS()

	_ChangerEtatBouton($iIDAction, "Patienter")

	If(StringLeft($sNom, 4) = "Tech") Then

		_DlISO()
		_ChangerEtatBouton($iIDAction, "Desactiver")

	Else

		Local $iNoWIN=0, $iNoOFF=0, $iNoAutre=0, $l=0, $eGet, $iBT[0], $iHauteur, $sNomF, $iBT[0], $aWIN[0], $aOFF[0], $aAUTRE[0]

		Local $aTmpWIN = _FileListToArray($sScriptDir & "\Cache\ISO\", "*win*.*", 1)
		If @error Then
			$iNoWIN = 1
			_ArrayAdd($aWIN,0)
		Else
			$aWIN = $aTmpWIN
		EndIf
		Local $aTmpOFF = _FileListToArray($sScriptDir & "\Cache\ISO\", "*off*.*", 1)
		If @error Then
			$iNoOFF = 1
			_ArrayAdd($aOFF,0)
		Else
			$aOFF = $aTmpOFF
		EndIf
		Local $aTmpAUTRE = _FileListToArrayRec($sScriptDir & "\Cache\ISO\", "*.*|*off*.*;*win*.*", 1)
		If @error Then
			$iNoAutre = 1
			_ArrayAdd($aAUTRE,0)
		Else
			$aAUTRE = $aTmpAUTRE
		EndIf

		If($iNoWIN = 1 And $iNoOFF = 1 And $iNoAutre = 1) Then
			$iHauteur = 4
		Else
			If $aWIN[0] > $aOFF[0] Then
				If $aAUTRE[0] > $aWIN[0] Then
					$iHauteur = $aAUTRE[0]
				Else
					$iHauteur = $aWIN[0]
				EndIf
			ElseIf $aAUTRE[0] > $aOFF[0] Then
				$iHauteur = $aAUTRE[0]
			Else
				$iHauteur = $aOFF[0]
			EndIf
		EndIf

		If $iHauteur < 4 Then
			$iHauteur = 4
		EndIf

		Local $hGUImaj = GUICreate("Windows et Office", 800, $iHauteur * 25 + 50)

		GUICtrlCreateGroup("Outils", 5, 10, 160, $iHauteur * 25 + 30)
		Local $iIDISODO = GUICtrlCreateButton("Windows ISO Downloader", 10, 30, 150, 20)
		Local $iIDMCT = GUICtrlCreateButton("Media Creation Tool", 10, 55, 150, 20)
		Local $iIDUSB = GUICtrlCreateButton("Copier ISO sur USB", 10, 80, 150, 20)
		Local $iIDSite = GUICtrlCreateButton("setup.office.com", 10, 105, 150, 20)

		GUICtrlCreateGroup("Windows", 175, 10, 200, $iHauteur * 25 + 30)

		If $iNoWIN =  0 Then
			For $j = 1 To $aWIN[0]
				_ArrayAdd($iBT, GUICtrlCreateButton($aWIN[$j], 180, ($j * 25)+5, 190, 20))
			Next
		Else
			GUICtrlCreateLabel("Aucun ISO/IMG/EXE trouvé", 180, 30)
		EndIf

		GUICtrlCreateGroup("Office", 385, 10, 200, $iHauteur * 25 + 30)

		If $iNoOFF = 0 Then
			For $l = 1 To $aOFF[0]
				_ArrayAdd($iBT, GUICtrlCreateButton($aOFF[$l], 390, ($l* 25)+5, 190, 20))
			Next
		Else
			GUICtrlCreateLabel("Aucun ISO/IMG/EXE trouvé", 390, 30)
		EndIf

		GUICtrlCreateGroup("Autre", 595, 10, 200, $iHauteur * 25 + 30)

		If $iNoAutre = 0 Then
			For $m = 1 To $aAUTRE[0]
				_ArrayAdd($iBT, GUICtrlCreateButton($aAUTRE[$m], 600, ($m * 25)+5, 190, 20))
			Next
		Else
			GUICtrlCreateLabel("Aucun ISO/IMG/EXE trouvé", 600, 30)
		EndIf

		If UBound($iBT) = 0 Then
			_ArrayAdd($iBT, 1000)
		EndIf

		GUISetState(@SW_SHOW)

		While 1
			$eGet = GUIGetMsg()
			Switch $eGet
				Case $GUI_EVENT_CLOSE
					GUIDelete($hGUImaj)
					ExitLoop

				Case $iIDMCT
					GUIDelete($hGUImaj)
					If(_Telecharger("MediaCreationTool", ($aMenu["MediaCreationTool"])[2])) Then
						_Executer("MediaCreationTool")
					EndIf
					ExitLoop

				Case $iIDUSB
					GUIDelete($hGUImaj)
					If(_Telecharger("WindowsUSBDVDDownloadTool", ($aMenu["WindowsUSBDVDDownloadTool"])[2])) Then
						_Executer("WindowsUSBDVDDownloadTool")
					EndIf
					ExitLoop

				Case $iIDISODO
					GUIDelete($hGUImaj)
					$sNomF = _DlISO()
					If($sNomF <> "") Then
						_Attention('"' & $sNomF & '" a bien été téléchargé. Vous pouvez maintenant l' & "'" & 'installer à partir du bouton "Windows et Office"')
					EndIf
					ExitLoop

				Case $iIDSite
					GUIDelete($hGUImaj)
					ShellExecute("https://setup.office.com")
					ExitLoop


				Case $iBT[0] To $iBT[UBound($iBT)-1]

					Local $sFileTE = GUICtrlRead($eGet)
					GUIDelete($hGUImaj)

					Local $sDocTE =  $sScriptDir & '\Cache\ISO\tmp\'

					If(StringInStr(@ScriptDir, "\\") And (StringRight($sFileTE, 3) = "img" Or StringRight($sFileTE, 3) = "iso")) Then
						GUICtrlSetData($statusbar, "Copie en cours, patientez")
						GUICtrlSetData($statusbarprogress, 10)

						RunWait(@ComSpec & ' /c robocopy "' & $sScriptDir & '\Cache\ISO" "' &  @LocalAppDataDir & '\bao" "' &  $sFileTE & '"')
						$sDocTE = @LocalAppDataDir & '\bao\tmp\'
					EndIf

					DirRemove($sDocTE, 1)

					If (StringRight($sFileTE, 3) = "img" Or StringRight($sFileTE, 3) = "iso") Then

						If(FileCopy($sScriptDir & "\Outils\7z.*", $sDocTE, 9)) Then
							GUICtrlSetData($statusbar, "Extraction en cours, patientez")
							GUICtrlSetData($statusbarprogress, 20)
							RunWait(@ComSpec & ' /c 7z.exe x "..\' &  $sFileTE & '"', $sDocTE)

							;_Debug(@ComSpec & ' /c 7z.exe x ..\' &  $sFileTE & ' & ' & $sDocTE)

							If FileExists($sDocTE & "setup.exe") Then
								If(StringInStr(@ScriptDir, "\\")) Then
									FileDelete($sDocTE & '..\' & $sFileTE)
								EndIf
								FileCreateShortcut($sDocTE & "setup.exe", @DesktopDir & "\BAO - Installation de " & $sFileTE)
								Run($sDocTE & "setup.exe")
							Else
								;_Attention($sFileTE & " n'a pas pu être extrait, essayez d'extraire celui ci manuellement")
								ShellExecute($sDocTE)
							EndIf
						Else
							_Attention("Extraction du fichier ISO impossible")
							ShellExecute(@LocalAppDataDir & "\bao\tmp\")
						EndIf
					Else
						GUICtrlSetData($statusbar, "Lancement de " & $sFileTE)
						GUICtrlSetData($statusbarprogress, 50)
						Run($sScriptDir & '\Cache\ISO\' & $sFileTE)
						Sleep(5000)
					EndIf

					GUICtrlSetData($statusbar, "")
					GUICtrlSetData($statusbarprogress, 0)
					ExitLoop

			EndSwitch
		WEnd

		_ChangerEtatBouton($iIDAction, "Desactiver")

	EndIf

EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _DlISO()
; Description ...: Télécharger ISO avec iso downloader
; Syntax ........:
; Parameters ....:
; Return values..: $sNomFicIso
; Author.........: Bastien
; Modified ......:
; ===============================================================================================================================

Func _DlISO()

	Local $sNomFicIso, $iPIDIsoD, $eGetM, $bStop = False
	ClipPut("")

	If MapExists($aMenu, "Windows-ISO-Downloader") Then
		If(_Telecharger("Windows-ISO-Downloader", ($aMenu["Windows-ISO-Downloader"])[2])) Then
			$iPIDIsoD = _Executer("Windows-ISO-Downloader")

			 Local $hGUIISOd = GUICreate("En attente", 300, 110, 0, 0)
			 GUICtrlCreateLabel("En attente d'un fichier ISO / IMG dans le presse papier", 10, 10)
			 GUICtrlCreateLabel('(Merci de cliquer sur "Copier le lien..." sur la droite)', 10, 35)
			 Local $iIDButtonAnnuleriso = GUICtrlCreateButton("Annuler", 105, 70, 90, 25, $BS_DEFPUSHBUTTON)
			 GUISetState(@SW_SHOW)

			$eGetM = GUIGetMsg()
			While $eGetM <> $GUI_EVENT_CLOSE And $eGetM <>  $iIDButtonAnnuleriso
				If (StringInStr(ClipGet(), ".iso") Or StringInStr(ClipGet(), ".exe") Or StringInStr(ClipGet(), ".img")) Then
					ProcessClose($iPIDIsoD)
					ExitLoop
				ElseIf(StringLeft(ClipGet(), 5) = "https") Then
					ProcessClose($iPIDIsoD)
					_Attention('Le fichier va être téléchargé via votre navigateur. Vous pourrez ensuite le renommer et le copier dans le dossier "Cache\ISO\"')
					ShellExecute(ClipGet())
					ShellExecute($sScriptDir & "\Cache\ISO\")
					$bStop = True
					ExitLoop
				EndIf
				$eGetM = GUIGetMsg()
			WEnd

			If $eGetM <> $GUI_EVENT_CLOSE And $eGetM <>  $iIDButtonAnnuleriso And $bStop <> True Then
				GUIDelete($hGUIISOd)
				Local $sURLiso = ClipGet()
				Local $aLiensp = StringSplit(ClipGet(), "/")
				$sNomFicIso = _ArrayPop($aLiensp)
				If(StringInStr($sNomFicIso, "?")) Then
					$sNomFicIso = StringLeft($sNomFicIso, StringInStr($sNomFicIso, "?") -1)
				EndIf
				$sNomFicIso = InputBox("Nom du fichier", "Entrez le nom du fichier : ", $sNomFicIso)

				If($sNomFicIso <> "") Then
					Local $sDestiso = $sScriptDir & "\Cache\ISO\"
					DirCreate($sDestiso)

					Local $sec, $TotalSize, $Bytes, $CalBytes, $Percentage, $hDownload
					Local $iIsoSize = InetGetSize($sURLiso)
					If FileExists($sDestiso & $sNomFicIso) And $iIsoSize = FileGetSize($sDestiso) Then
						_Attention($sDestiso & "existe déjà.")
					Else
						$hDownload = InetGet($sURLiso, $sDestiso & $sNomFicIso, 1, 1)
						$TotalSize = Round($iIsoSize / 1024)
						GUICtrlSetData($statusbar, " Téléchargement de " & $sNomFicIso)
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
									InetClose($hDownload)
									FileDelete($sDestiso & $sNomFicIso)
									Return $sNomFicIso
								EndIf
							WEnd
							$CalBytes = Round(InetGetInfo($hDownload,0))
							$TotalSize = $TotalSize - (($CalBytes - $Bytes) /1024)
							$Percentage = Round($TotalSize /  $iIsoSize * 100000)
							$Percentage = 100 - $Percentage
							GUICtrlSetData($statusbarprogress,$Percentage)
						Until InetGetInfo($hDownload,2)
						GUICtrlSetData($statusbar, "")
						GUICtrlSetData($statusbarprogress, 0)
						GUICtrlSetState($iIDCancelDL, $GUI_DISABLE)
						Local $aData = InetGetInfo($hDownload)
						If @error Then
							_Attention("Erreur lors du téléchargement de " & $sNomFicIso)
						Else
							If FileExists($sDestiso & $sNomFicIso) And FileGetSize($sDestiso & $sNomFicIso) <> $iIsoSize Then
								_Attention("Echec du téléchargement de " & $sNomFicIso)
							EndIf
						EndIf
					EndIf
				EndIf
			Else
				ProcessClose($iPIDIsoD)
				GUIDelete($hGUIISOd)
			EndIf
		EndIf
	Else
		_Attention("Windows-ISO-Downloader n'existe pas dans les liens")
	EndIf

	Return $sNomFicIso

EndFunc

Func _SetUserAgent($agent)
    Local $agentLen = StringLen($agent)
    Dim $tBuff = DllStructCreate("char["&$agentLen&"]")
    DllStructSetData($tBuff, 1, $agent)
    Local $chk_UrlMkSetSessionOption = DllCall("urlmon.dll", "long", "UrlMkSetSessionOption", "dword", 0x10000001, "ptr", DllStructGetPtr($tBuff), "dword", $agentLen, "dword", 0)
EndFunc