#cs

Copyright 2019-2021 Bastien Rouches

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

Func _Restauration($sDescription = "")

	GUICtrlSetData($statusbar, "Création d'un point de restauration, patientez")
	GUICtrlSetData($statusbarprogress, 10)
	If($sDescription = "") Then
		$sDescription = InputBox("Création d'un point de restauration", "Description du point de restauration", "Point de restauration BAO")
		If @error Then
			GUICtrlSetData($statusbar, "")
			GUICtrlSetData($statusbarprogress, 0)
			_ChangerEtatBouton($iIDAction, "Desactiver")
			Return
		EndIf
	EndIf

	GUICtrlSetData($statusbarprogress, 50)
	RegWrite($HKLM & "\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore", "SystemRestorePointCreationFrequency","REG_DWORD",0)
	_ChangerEtatBouton($iIDAction, "Patienter")
	If _CreateSystemRestorePoint ($sDescription, 0 ) Then
		_ChangerEtatBouton($iIDAction, "Activer")
	Else
		_ChangerEtatBouton($iIDAction, "Desactiver")
	EndIf
	RegDelete($HKLM & "\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore", "SystemRestorePointCreationFrequency")
	GUICtrlSetData($statusbar, "")
	GUICtrlSetData($statusbarprogress, 0)

EndFunc