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

Func _TestsStabilite()
	_FichierCache("Stabilite", $iIDAction)
	_ChangerEtatBouton($iIDAction, "Patienter")

	Local $sTestRam = @WindowsDir &"\system32\MdSched.exe"
	If (@OSArch = "X64" and @AutoItX64 = 0) Then
		$sTestRam = @WindowsDir &"\sysnative\MdSched.exe"
	EndIf

	Local $hEventLog = _EventLog__Open("", "System")
	Local $iOffset = _EventLog__Read($hEventLog, True, False)
	_FichierCache("StabiliteTime", $iOffset)
	_EventLog__Close($hEventLog)

	ShellExecuteWait($sTestRam)

	_ChangerEtatBouton($iIDAction, "Desactiver")
EndFunc

Func _ResultatStabilite()
	Local $iOffset = _FichierCache("StabiliteTime")
	Local $hEventLog = _EventLog__Open("", "System")
	Local $aEvent = _EventLog__Read($hEventLog, False, True, $iOffset)

	Do
		If $aEvent[10] = "Microsoft-Windows-MemoryDiagnostics-Results" Then
			_Attention($aEvent[13])
			FileWriteLine($hFichierRapport, "Test de mémoire vive effectué : " & $aEvent[13])
			FileWriteLine($hFichierRapport, "")
			ExitLoop
		EndIf
		$aEvent = _EventLog__Read($hEventLog)
	Until $aEvent[0] = False

	If $aEvent[0] = False Then
		_Attention("Le résultat du test de mémoire vive n'a pas été trouvé dans le journal d'évènement", 1)
	EndIf

	_EventLog__Close($hEventLog)
EndFunc