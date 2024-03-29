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

	_FileWriteLog($hLog, 'Création SFX')
	; Création de l'archive 7z
	Local $sPwdSFX = IniRead($sConfig, "FTP", "PwdSFX", "")
	If FileExists(@ScriptDir & "\Outils\7z\BAO.7z") Then FileDelete(@ScriptDir & "\Outils\7z\BAO.7z")
	If FileExists(@ScriptDir & "\Outils\7z\BAO-sfx.exe") Then FileDelete(@ScriptDir & "\Outils\7z\BAO-sfx.exe")
	GUICtrlSetData($statusbar, " Création de l'archive SFX")
	GUICtrlSetData($statusbarprogress, 0)

	RunWait(@ComSpec & ' /c ""' & @ScriptDir & '\Outils\7z\7z.exe" a "' & @ScriptDir & '\Outils\7z\BAO.7z" "' & @ScriptDir & '\*" -x!"' & @ScriptDir & '\Cache" -x!"' & @ScriptDir & '\Rapports""', @ScriptDir & "\Outils\7z\", @SW_HIDE)
	If $sPwdSFX = 1 Then
		RunWait(@ComSpec & ' /c ""' & @ScriptDir & '\Outils\7z\7z.exe" a "' & @ScriptDir & '\Outils\7z\BAO.7z" -i!"' & @ScriptDir & '\Cache\Pwd\*.sha"', @ScriptDir, @SW_HIDE)
		RunWait(@ComSpec & ' /c ""' & @ScriptDir & '\Outils\7z\7z.exe" rn "' & @ScriptDir & '\Outils\7z\BAO.7z" "dws.sha" "Cache\Pwd\dws.sha"', @ScriptDir, @SW_HIDE)
		RunWait(@ComSpec & ' /c ""' & @ScriptDir & '\Outils\7z\7z.exe" rn "' & @ScriptDir & '\Outils\7z\BAO.7z" "ftp.sha" "Cache\Pwd\ftp.sha"', @ScriptDir, @SW_HIDE)
	EndIf

	GUICtrlSetData($statusbarprogress, 30)
	RunWait(@ComSpec & ' /c copy /b "' & @ScriptDir & '\Outils\7z\7zsd_All.sfx" + "' & @ScriptDir & '\Outils\7z\sfx.config" + "' & @ScriptDir & '\Outils\7z\BAO.7z" "' & @ScriptDir & '\Outils\7z\BAO-sfx.exe"', @ScriptDir & "\Outils\7z\", @SW_HIDE)
	GUICtrlSetData($statusbarprogress, 60)

	Local $iRetour, $nb = 0
	Do
		$iRetour = _EnvoiFTP(@ScriptDir & "\Outils\7z\BAO-sfx.exe", $sFTPDossierSFX & "BAO-sfx.exe")
		$nb+=1
	Until $iRetour <> -1 Or $nb = 3

	if $iRetour <> 1 Then
		_FileWriteLog($hLog, 'Copie du fichier SFX sur le bureau')
		FileMove(@ScriptDir & "\Outils\7z\BAO-sfx.exe", @DesktopDir, 1)
		_Attention("L'archive BAO-sfx.exe a été enregistrée sur votre bureau")
	Else
		_FileWriteLog($hLog, 'SFX enregistré sur le FTP')
	EndIf

	_UpdEdit($iIDEditLog, $hLog)
	GUICtrlSetData($statusbar, "")
	GUICtrlSetData($statusbarprogress, 0)

EndFunc