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

Func _Scripts()

	_ChangerEtatBouton($iIDAction, "Patienter")

	If(StringLeft($sNom, 4) = "Tech") Then
		DirCreate($sScriptDir & "\Scripts\")
		ShellExecute($sScriptDir & "\Scripts\")
	Else

		Local $eGet, $aButton[], $aBut[0], $sTmp, $sScriptname, $sDocscript, $iFilenbr = false
		Local $hGUIscripts = GUICreate("Scripts et outils", 500, 500)

		Local $aTab = _FileListToArray($sScriptDir & "\Scripts\", "*", 2)

		If @error = 4 Then

			Local $aFiles = _FileListToArray($sScriptDir & "\Scripts\", "*", 1)

			If @error = 4 Then

				GUICtrlCreateLabel('Il n' & "'" & 'y a pas de script dans le dossier "scripts"', 20, 20)

			Else
				If $aFiles[0] > 18 Then
					$iFilenbr = True
				EndIf

				For $k = 1 To $aFiles[0]
					$sTmp = GUICtrlCreateButton($aFiles[$k], 10, $k* 25, 480, 20)
					$aButton[$sTmp] = "root"
					_ArrayAdd($aBut, $sTmp)
				Next
			EndIf

		Else

			Local $hTab = GUICtrlCreateTab(10, 10, 480, 480)

			For $i = 1 To $aTab[0]

				GUICtrlCreateTabItem($aTab[$i])

				Local $aTmp = _FileListToArray($sScriptDir & "\Scripts\" & $aTab[$i], "*")

				If @error = 4 Then
					GUICtrlCreateLabel("Il n'y a pas de script dans cet onglet", 20, 40)
				Else
					If $aTmp[0] > 18 Then
						$iFilenbr = True
					EndIf
					For $j = 1 To $aTmp[0]
						$sTmp = GUICtrlCreateButton($aTmp[$j], 20, ($j * 25) + 10, 460, 20)
						$aButton[$sTmp]=$aTab[$i]
						_ArrayAdd($aBut, $sTmp)
					Next
				EndIf

			Next

			Local $aFilesa = _FileListToArray($sScriptDir & "\Scripts\", "*", 1)

			If @error = 0 Then

				If $aFilesa[0] > 18 Then
					$iFilenbr = True
				EndIf

				GUICtrlCreateTabItem("Non classés")

				For $l = 1 To $aFilesa[0]
					$sTmp = GUICtrlCreateButton($aFilesa[$l], 20, ($l* 25) + 10, 460, 20)
					$aButton[$sTmp] = "root"
					_ArrayAdd($aBut, $sTmp)
				Next
			EndIf

			GUICtrlCreateTabItem("")

		EndIf

		If UBound($aBut) = 0 Then
			_ArrayAdd($aBut, 1000)
		EndIf

		If $iFilenbr Then
			_Attention("Merci de ne pas dépasser 18 scripts par dossier")
		EndIf

		GUISetState(@SW_SHOW)

		While 1
			$eGet = GUIGetMsg()
			Switch $eGet
				Case $GUI_EVENT_CLOSE
					GUIDelete($hGUIscripts)
					_ChangerEtatBouton($iIDAction, "Desactiver")
					Return

 				Case $aBut[0] To $aBut[UBound($aBut)-1]

					$sScriptname = GUICtrlRead($eGet)
					If($aButton[$eGet] = "root") Then
						$sDocscript = $sScriptDir & "\Scripts\"
					Else
						$sDocscript = $sScriptDir & "\Scripts\" & $aButton[$eGet] & "\"
 					EndIf
					ExitLoop

			EndSwitch
		WEnd

		GUIDelete($hGUIscripts)

		If(StringRight($sScriptname, 4) = ".bat" Or StringRight($sScriptname, 4) = ".cmd" Or StringRight($sScriptname, 4) = ".reg") Then
			RunWait(@ComSpec & ' /c "' & $sDocscript & $sScriptname & '"',$sDocscript)
		ElseIf (StringRight($sScriptname, 4) = ".ps1") Then
			RunWait(@ComSpec & ' /c powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' & $sScriptname & '"', $sDocscript)
		Else
			ShellExecute($sScriptname, "", $sDocscript)
		EndIf

	EndIf

	_ChangerEtatBouton($iIDAction, "Desactiver")

EndFunc