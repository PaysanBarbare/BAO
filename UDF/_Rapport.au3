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

Global $aBalise[]
$aBalise["PC_NAME"] = "Nom de l'ordinateur"
$aBalise["OS"] = "Système d'exploitation"
$aBalise["RELEASE"] = "Version"
$aBalise["GENUINE"] = "Licence activée"
$aBalise["INSTALL_DATE"] = "Date d'installation"
$aBalise["BIOS"] = "BIOS"
$aBalise["MODEL"] = "Modèle"
$aBalise["RAM"] = "Mémoire vive"
$aBalise["CPU"] = "Processeur"
$aBalise["SOCKET"] = "Socket"
$aBalise["MB"] = "Carte mère"
$aBalise["SN"] = "S/N"
$aBalise["GC"] = "Carte graphique"
$aBalise["HDD?"] = "Disque"

Func _ExporterRapport()
	_ChangerEtatBouton($iIDAction, "Patienter")

	Local $sData
	$sData = FileRead(@LocalAppDataDir & "\bao\entete.bao")
	$sData &= FileRead(@LocalAppDataDir & "\bao\infosys.bao")
	$sData &= @CRLF & "[UPDATE]" & @CRLF & FileRead(@LocalAppDataDir & "\bao\infosysupd.bao") & "[/UPDATE]" & @CRLF
	$sData &= @CRLF & "[INSTALL]" & @CRLF & FileRead(@LocalAppDataDir & "\bao\install.bao") & @CRLF & "[/INSTALL]" & @CRLF
	$sData &= @CRLF & "[UNINSTALL]" & @CRLF & FileRead(@LocalAppDataDir & "\bao\uninstall.bao") &  @CRLF & "[/UNINSTALL]" & @CRLF
	_CalculFS()
	$sData &= @CRLF & "[FREESPACE_END]" & $iFreeSpace & " Go[/FREESPACE_END]" & @CRLF
	$sData &= @CRLF & "[RAPPORT]" & @CRLF & FileRead(@LocalAppDataDir & "\bao\rapport.bao") & "[/RAPPORT]" & @CRLF
	$sData &= @CRLF & "[LOGS]" & @CRLF & FileRead(@LocalAppDataDir & "\bao\logs.txt") & "[/LOGS]" & @CRLF

    ; Display a save dialog to select a file.
	Local $sFileSaveDialog = FileSaveDialog("Choisissez un répertoire", @DesktopDir, "Fichiers Boite à Outils (*.bao)", 0, "Rapport intervention.bao")
    If @error = 0 Then
        ; Retrieve the filename from the filepath e.g. Example.au3.
        Local $sFileName = StringTrimLeft($sFileSaveDialog, StringInStr($sFileSaveDialog, "\", $STR_NOCASESENSEBASIC, -1))

        ; Check if the extension .au3 is appended to the end of the filename.
        Local $iExtension = StringInStr($sFileName, ".", $STR_NOCASESENSEBASIC)

        ; If a period (dot) is found then check whether or not the extension is equal to .au3.
        If $iExtension Then
            ; If the extension isn't equal to .au3 then append to the end of the filepath.
            If Not (StringTrimLeft($sFileName, $iExtension - 1) = ".bao") Then $sFileSaveDialog &= ".bao"
        Else
            ; If no period (dot) was found then append to the end of the file.
            $sFileSaveDialog &= ".bao"
        EndIf
		If(FileExists($sFileSaveDialog)) Then
			_Attention("Le fichier existe déjà, merci de choisir un nom différent")
		Else
			_FileWriteLog($hLog, "Export du rapport : " & $sFileSaveDialog)
			Local $hExport = FileOpen($sFileSaveDialog, 1)
			FileWrite($hExport, $sData)
			FileClose($hExport)
		EndIf
    EndIf

	_ChangerEtatBouton($iIDAction, "Activer")

EndFunc

Func _CompleterRapport($iRapport, $sNomRapportComplet)
	Local $sData
	FileCopy(@LocalAppDataDir & "\bao\rapport.bao", $sDossierRapport & "\" & StringReplace(StringLeft(_NowCalc(),10), "/", "") & " - Rapport Intervention.txt", 1)
	$sData = FileRead(@LocalAppDataDir & "\bao\entete.bao")
	$sData &= FileRead(@LocalAppDataDir & "\bao\infosys.bao")
	$sData &= @CRLF & "[UPDATE]" & @CRLF & FileRead(@LocalAppDataDir & "\bao\infosysupd.bao") & @CRLF & "[/UPDATE]" & @CRLF
	$sData &= @CRLF & "[INSTALL]" & @CRLF & FileRead(@LocalAppDataDir & "\bao\install.bao") & @CRLF & "[/INSTALL]" & @CRLF
	$sData &= @CRLF & "[UNINSTALL]" & @CRLF & FileRead(@LocalAppDataDir & "\bao\uninstall.bao") &  @CRLF & "[/UNINSTALL]" & @CRLF
	_CalculFS()
	$sData &= @CRLF & "[FREESPACE_END]" & $iFreeSpace & " Go[/FREESPACE_END]" & @CRLF
	$sData &= @CRLF & "[END]" & _Now() & "[/END]" & @CRLF
	$sData &= @CRLF & "[RAPPORT]" & @CRLF & FileRead(@LocalAppDataDir & "\bao\rapport.bao") & "[/RAPPORT]" & @CRLF
	$sData &= @CRLF & "[LOGS]" & @CRLF & FileRead(@LocalAppDataDir & "\bao\logs.txt") & "[/LOGS]" & @CRLF

	Local $hRapportComplet = FileOpen($sNomRapportComplet, 2)
	FileWrite($hRapportComplet, $sData)
	FileClose($hRapportComplet)

	If $iRapport Then
		ShellExecuteWait($sNomRapportComplet)
	EndIf

EndFunc

Func _RapportParseur($iIDTABInfossys)

	Local $aArrayRapport, $aArrayRapportupd, $aCat, $aCatTmp, $aCatUpd[0][2], $sCateg, $bFind = false, $iFindUpd, $iPosBR, $sDD, $aDDSmart

	If _FileReadToArray($sFileInfosys, $aArrayRapport, 0) = 0 Then
		_FileWriteLog($hLog, "Regénération de " & $sFileInfosys)
		_Attention("Le fichier " & $sFileInfosys & " est introuvable, celui ci va être regénéré")
		_RapportInfos(1)
		_FileReadToArray($sFileInfosys, $aArrayRapport, 0)
	EndIf

	If FileExists($sFileInfosysupd) Then

		If _FileReadToArray($sFileInfosysupd, $aArrayRapportupd, 0) Then
			$bFind = True

			For $i = 0 To UBound($aArrayRapportupd) - 1
				ReDim $aCatUpd[$i+1][2]
				$aCatTmp = StringRegExp($aArrayRapportupd[$i], "\[(\w+)\](.+)\[", 1)
				$aCatUpd[$i][0] = $aCatTmp[0]
				$aCatUpd[$i][1] = $aCatTmp[1]
			Next
		EndIf

	EndIf

	For $sOBJ In $aArrayRapport
		$aCat = StringRegExp($sOBJ, "\[(\w+)\](.+)\[", 1)
		If UBound($aCat) > 1 Then
			If($bFind) Then
				$iFindUpd = _ArraySearch($aCatUpd, $aCat[0], 0, 0, 0, 0, 1, 0)
				If $iFindUpd <> -1 Then
					;_FileWriteLog($hLog, "Mise à jour détectée : " & $aCatUpd[$iFindUpd][1])
					$aCat[1] = " ** MAJ ** " & $aCatUpd[$iFindUpd][1]
				EndIf
			EndIf
			if MapExists($aBalise, $aCat[0]) Then
				$sCateg = $aBalise[$aCat[0]]
			Else
				$sCateg = $aCat[0]
			EndIf

			$iPosBR = StringInStr($aCat[1], "[BR]")

			If $iPosBR Then
				GUICtrlCreateListViewItem("", $idListInfosys)
				$sDD = StringLeft($aCat[1], $iPosBR - 1)
				$aDDSmart = StringSplit(StringMid($aCat[1], $iPosBR + 4), "[BR]", 3)
				GUICtrlCreateListViewItem($sCateg & "|" & $sDD, $idListInfosys)
				For $sDDSmart In $aDDSmart
					GUICtrlCreateListViewItem("|" & $sDDSmart, $idListInfosys)
				Next
			Else
				GUICtrlCreateListViewItem($sCateg & "|" & $aCat[1], $idListInfosys)
			EndIf
		EndIf
	Next
	_UpdEdit($iIDEditLog, $hLog)
EndFunc

Func _SaveInter()
	$hRapport = FileOpen($sFileRapport, 2)
	FileWrite($hRapport,GUICtrlRead($iIDEditInter))
	FileClose($hRapport)
EndFunc

Func _SaveChangeToInter()
	_ChangerEtatBouton($iIDBoutonInscMat, "Patienter")
	_SaveInter()
	Local $aUpd, $sToadd, $aArrayRapportupd, $bOKch = False
	$hRapport = FileOpen($sFileRapport, 1)
	If FileExists($sFileInfosysupd) Then
		If _FileReadToArray($sFileInfosysupd, $aArrayRapportupd, 0) Then
			$bOKch = True
			_FileWriteLog($hLog, "Inscription des changements de config dans le rapport")
			$sToadd = "### Changements apportés ###" & @CRLF
			For $i = 0 To UBound($aArrayRapportupd) - 1
				$aUpd = StringRegExp($aArrayRapportupd[$i], "\[(\w+)\](.+)\[", 1)
				$sToadd&=$aBalise[$aUpd[0]] & " mis à jour : " & $aUpd[1] & @CRLF
			Next
			$sToadd &= @CRLF
			FileWrite($hRapport, $sToadd)
		EndIf
	EndIf
	Local $sInsR = FileRead($sFileInstallation)
	If $sInsR <> "" Then
		$bOKch = True
		_FileWriteLog($hLog, "Inscription des logiciels installés")
		FileWrite($hRapport, "### Liste des logiciels installés ###" & @CRLF & StringReplace($sInsR, "[BR]", @CRLF) & @CRLF)
	EndIf

	Local $sDesR = FileRead($sFileDesinstallation)
	If $sDesR <> "" Then
		$bOKch = True
		_FileWriteLog($hLog, "Inscription des logiciels désinstallés")
		FileWrite($hRapport, "### Liste des logiciels désinstallés ###" & @CRLF & StringReplace($sDesR, "[BR]", @CRLF) & @CRLF)
	EndIf

	Local $iGainSpace = _CalculFSGain()
	If $iGainSpace <> 0 Then
		_FileWriteLog($hLog, "Espace libéré : " & $iGainSpace)
		FileWrite($hRapport, "### Espace libéré sur le disque " & $HomeDrive & " ###" & @CRLF & $iGainSpace & " Go" & @CRLF & @CRLF)
	EndIf

	_UpdEdit($iIDEditInter, $hRapport)
	FileClose($hRapport)

	If $bOKch = False Then
		_FileWriteLog($hLog, "Aucun changement détecté")
		_ChangerEtatBouton($iIDBoutonInscMat, "Desactiver")
	Else
		_FichierCache("Inscription", 1)
		_ChangerEtatBouton($iIDBoutonInscMat, "Activer")
	EndIf

EndFunc


Func _GetModele($sFichierModele)
	_FileWriteLog($hLog, "Ajout du modèle " & $sFichierModele & " au rapport")
	Local $hIntertmp = FileOpen(@ScriptDir & "\Config\Modeles\" & $sFichierModele & ".txt",0)
	$hRapport = FileOpen($sFileRapport, 1)
	FileWrite($hRapport, FileRead($hIntertmp))
	FileClose($hIntertmp)
	_UpdEdit($iIDEditInter, $hRapport)
	FileClose($hRapport)
EndFunc