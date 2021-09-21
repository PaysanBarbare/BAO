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

Func _CompleterRapport()
	_ChangerEtatBouton($iIDAction, "Patienter")

	FileClose($hFichierRapport)
	ShellExecuteWait($sDossierRapport & "\Rapport intervention.txt")
	$hFichierRapport = FileOpen($sDossierRapport & "\Rapport intervention.txt", 1)
	_UpdEdit($iIDEditRapport, $hFichierRapport)
	;Local $rc = _INetSmtpMailCom($aEnvoi[2][1], "I² - Rapport Intervention", $aEnvoi[1][1], $aEnvoi[1][1], "Rapport de " & $sNom, $corps, "", "", "", "Normal", $aEnvoi[5][1], $sMdp, $aEnvoi[3][1], $aEnvoi[4][1])
	_ChangerEtatBouton($iIDAction, "Activer")

EndFunc