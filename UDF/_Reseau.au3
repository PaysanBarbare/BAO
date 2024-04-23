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

Func _Reseau()

	_ChangerEtatBouton($iIDAction, "Patienter")

	Local $eGet
	Local $sIP = StringLeft(@IPAddress1, StringInStr(@IPAddress1, ".", 0, -1))

	$sIP = InputBox("Scanner réseau", "Saisissez l'ip du réseau à scanner : ", $sIP & "0")
	If (StringRegExp($sIP, "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}")) Then
		If TCPStartup() Then
			$sIP = StringLeft($sIP, StringInStr($sIP, ".", 0, -1))
			If FileExists(@ScriptDir & "\Cache\Download\oui.csv") = 0 Then
				_FileWriteLog($hLog, 'Téléchargement de la "oui list"')
				If MapExists($aMenu, "oui") Then
					_Telecharger($aMenu["oui"])
				Else
					_FileWriteLog($hLog, 'Erreur : "oui" absent des liens')
					_Attention('Erreur : "oui" n'& "'" & 'existe pas dans les liens')
				EndIf
			EndIf

			If FileExists(@ScriptDir & "\Cache\Download\oui.csv") Then
				Local $hCSV = FileOpen(@ScriptDir & "\Cache\Download\oui.csv")
				Local $sCSV = FileRead($hCSV)
				Local $aCSVtmp = _StringExplode($sCSV, @CRLF)
				_ArrayDelete($aCSVtmp, 0)
				Local $aCSV[]
				GUICtrlSetData($statusbar, 'Chargement de la "oui list"')
				For $i = 0 To UBound($aCSVtmp) -1
					GUICtrlSetData($statusbarprogress, Round(($i * 100) / UBound($aCSVtmp)))
					Local $aTmp = _StringExplode($aCSVtmp[$i], ",")
					Local $iToconcat = -1
					If UBound($aTmp) > 4 Then
						For $j = 0 To UBound($aTmp) - 1
							If StringLeft($aTmp[$j], 1) = '"' Then
								$iToconcat = $j
							EndIf
							If $iToconcat <> $j And $iToconcat <> -1 Then
								$aTmp[$iToconcat] &= $aTmp[$j]
								If StringRight($aTmp[$j], 1) = '"' And StringRight($aTmp[$j], 2) <> '""' Then
									$iToconcat = -1
								EndIf
								$aTmp[$j] = -1
							EndIf
						Next
						Local $aTodel[1]
						For $k = 0 To UBound($aTmp) - 1
							If $aTmp[$k] = -1 Then
								_ArrayAdd($aTodel, $k)
							EndIf
						Next
						$aTodel[0] = UBound($aTodel) - 1
						_ArrayDelete($aTmp, $aTodel)
					EndIf
					If UBound($aTmp) = 4 Then
						$aCSV[$aTmp[1]] = StringReplace($aTmp[2], '"', '')
					EndIf
				Next
				GUICtrlSetData($statusbar, "")
				GUICtrlSetData($statusbarprogress, 0)
			EndIf

			_FileWriteLog($hLog, 'Recherche des périphériques réseau')
			GUICtrlSetData($statusbar, 'Recherche des périphériques réseau')

			Local $hGUIreseau = GUICreate("Périphériques réseau détectés", 500, 540)
			Local $idListView = GUICtrlCreateListView("IP|Nom|Fabricant|", 10, 10, 480, 495)
			_GUICtrlListView_SetColumnWidth($idListView, 0, 100)
			_GUICtrlListView_SetColumnWidth($idListView, 1, 150)
			_GUICtrlListView_SetColumnWidth($idListView, 2, 230)
			Local $sNomReseau, $iPIDArp, $sArp, $aArp, $aMac, $sMac, $mMac[], $aTabMac[2]
			Local $iBScan = GUICtrlCreateButton("Scan approfondi", 20, 510, 120)
			Local $iBOpenIp = GUICtrlCreateButton("Interface web", 150, 510, 100)
			Local $iBCopyName = GUICtrlCreateButton("Copier le nom", 260, 510, 100)
			Local $iBQuit = GUICtrlCreateButton("Quitter", 370, 510, 100)

			$iPIDArp = Run(@ComSpec & ' /c arp -a', @WorkingDir, @SW_HIDE, $STDOUT_CHILD)
			ProcessWaitClose($iPIDArp)
			$sArp = StdoutRead($iPIDArp)
			$aArp = _StringExplode($sArp, @CR)
			For $i = 0 To UBound($aArp) - 1
				GUICtrlSetData($statusbarprogress, Round(($i * 100) / UBound($aArp)))
				$aMac = StringRegExp($aArp[$i], "(" & $sIP & "[0-9]{1,3}).*?([A-Za-z0-9]{2}-[A-Za-z0-9]{2}-[A-Za-z0-9]{2}-[A-Za-z0-9]{2}-[A-Za-z0-9]{2}-[A-Za-z0-9]{2})", 1)
				if IsArray($aMac) Then
					$aTabMac[0] = _TCPIpToName($aMac[0])
					$aTabMac[1] = $aCSV[StringUpper(StringLeft(StringReplace($aMac[1], "-", ""), 6))]
					$mMac[$aMac[0]] = $aTabMac
					GUICtrlCreateListViewItem($aMac[0] & "|" & ($mMac[$aMac[0]])[0] & "|" & ($mMac[$aMac[0]])[1], $idListView)
				EndIf
			Next
			GUICtrlSetData($statusbar, "")
			GUICtrlSetData($statusbarprogress, 0)

			GUISetState(@SW_SHOW)

			While 1
				$eGet = GUIGetMsg()
				Switch $eGet
					Case $GUI_EVENT_CLOSE
						ExitLoop

					Case $iBQuit
						ExitLoop

					Case $iBScan
						GUICtrlSetState($iBScan, $GUI_DISABLE)
						_GUICtrlListView_DeleteAllItems($idListView)
						For $i = 1 To 255
							GUICtrlSetData($iBScan, "Ping " & $sIP & $i)
							If Ping($sIP & $i, 300) Then
								If MapExists($mMac, $sIP & $i) Then
									GUICtrlCreateListViewItem($sIP & $i & "|" & ($mMac[$sIP & $i])[0] & "|" & ($mMac[$sIP & $i])[1], $idListView)
								Else
									$sNomReseau = _TCPIpToName($sIP & $i)
									$iPIDArp = Run(@ComSpec & ' /c arp -a ' & $sIP & $i, @WorkingDir, @SW_HIDE, $STDOUT_CHILD)
									ProcessWaitClose($iPIDArp)
									$sArp = StdoutRead($iPIDArp)
									$aMac = StringRegExp($sArp, "[A-Za-z0-9]{2}-[A-Za-z0-9]{2}-[A-Za-z0-9]{2}-[A-Za-z0-9]{2}-[A-Za-z0-9]{2}-[A-Za-z0-9]{2}", 1)
									if IsArray($aMac) Then
										$sMac = StringUpper(StringLeft(StringReplace($aMac[0], "-", ""), 6))
									Else
										$sMac = ""
									EndIf

									GUICtrlCreateListViewItem($sIP & $i & "|" & $sNomReseau & "|" & $aCSV[$sMac], $idListView)
								EndIf
							EndIf
						Next
						GUICtrlSetData($iBScan, "Scan approfondi")
						GUICtrlSetState($iBScan, $GUI_ENABLE)

					Case $iBOpenIp
						If GUICtrlRead($idListView) <> 0 Then
							Local $aReg = StringRegExp(GUICtrlRead(GUICtrlRead($idListView)), "(.*?)\|", 1)
							ShellExecute("http://" & $aReg[0])
						Else
							_Attention("Merci de sélectionner une IP")
						EndIf

					Case $iBCopyName
						If GUICtrlRead($idListView) <> 0 Then
							Local $aReg = StringRegExp(GUICtrlRead(GUICtrlRead($idListView)), ".*?\|(.*?)\|", 1)
							ClipPut($aReg[0])
						Else
							_Attention("Merci de sélectionner une IP")
						EndIf

				EndSwitch
			WEnd

			GUIDelete($hGUIreseau)
		Else
			_FileWriteLog($hLog, 'Echec TCP_Startup')
			_Attention('Erreur TCP')
		EndIf
	Else
		_FileWriteLog($hLog, 'Ip non valide : ' & $sIP)
		_Attention('Adresse IP non valide : "'& $sIP & '"')
	EndIf

	_ChangerEtatBouton($iIDAction, "Desactiver")

EndFunc