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

Func _Crypter($sType, $sPwd, $sCle)

	If($sPwd <> "") Then
		Local $bEncrypted = _Crypt_EncryptData($sPwd, $sCle, $CALG_AES_256) ; Encrypt the data using the generic password string.
		Local $hFileSha = FileOpen(@ScriptDir & '\Cache\Pwd\' & $sType & '.sha', 10)
		FileWrite($hFileSha, $bEncrypted)
		FileClose($hFileSha)
	EndIf

EndFunc