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

Func _InstallationPilotes()
	_ChangerEtatBouton($iIDAction, "Patienter")
	If(StringLeft($sNom, 4) = "Tech") Then
		_FileWriteLog($hLog, 'Téléchargement de la base de données de pilotes')
		_UpdEdit($iIDEditLog, $hLog)
		_Telecharger($aMenu["SDI"])
		Local $sDocexe = _Executer("SDI", "", 1)
		Run(@ComSpec & ' /c "' & $sDocexe & '\autoupdate.bat"', $sDocexe)
		;_Debug(@ComSpec & ' /c "' & $sDocexe & 'autoupdate.bat"')
	Else
		_FileWriteLog($hLog, 'Recherche et installation de pilotes manquants')
		_UpdEdit($iIDEditLog, $hLog)
		_Telecharger($aMenu["SDI"])
		_Executer("SDI")
	EndIf
	_ChangerEtatBouton($iIDAction, "Desactiver")
EndFunc