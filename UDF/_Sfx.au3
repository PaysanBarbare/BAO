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
Fonction : Création de fichier auto extractible avec 7zip et envoi sur FTP
#ce

Func _CreerSFX()

	; Création de l'archive 7z
	If FileExists($sScriptDir & "\Outils\BAO.7z") Then FileDelete($sScriptDir & "\Outils\BAO.7z")
	If FileExists($sScriptDir & "\Outils\BAO-sfx.exe") Then FileDelete($sScriptDir & "\Outils\BAO-sfx.exe")
	GUICtrlSetData($statusbar, " Création de l'archive SFX")
	GUICtrlSetData($statusbarprogress, 0)
	RunWait(@ComSpec & ' /c 7z.exe a BAO.7z .\..\* -x!Cache -x!Rapports -xr!PrivaZer-donor.ini', $sScriptDir & "\Outils\", @SW_HIDE)
	GUICtrlSetData($statusbarprogress, 50)
	RunWait(@ComSpec & ' /c copy /b 7zsd_All.sfx + sfx.config + BAO.7z BAO-sfx.exe', $sScriptDir & "\Outils\", @SW_HIDE)
	GUICtrlSetData($statusbarprogress, 100)

	Local $sFTPDossierSFX = IniRead($sConfig, "FTP", "DossierSFX", "")

	Local $iRetour
	Do
		$iRetour = _EnvoiFTP($sScriptDir & "\Outils\BAO-sfx.exe", $sFTPDossierSFX & "BAO-sfx.exe")
	Until $iRetour <> -1

	if $iRetour = 0 Then
		FileMove($sScriptDir & "\Outils\BAO-sfx.exe", @DesktopDir, 1)
		_Attention("L'archive BAO-sfx.exe a été enregistrée sur votre bureau")
	EndIf

	GUICtrlSetData($statusbar, "")
	GUICtrlSetData($statusbarprogress, 0)

EndFunc