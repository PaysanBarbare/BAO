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

#cs
Auteur : Bastien ROUCHES
Fonction : Liste des fonctions utiles pour le fonctionnement de I² - BAO
#ce

; Traitement du fichier config.ini

Func _RapportInfos($iReset = 0)
	If $iReset = 1 Then
		$hEntete = FileOpen($sFileEntete, 2) ; overwrite
	Else
		$hEntete = FileOpen($sFileEntete, 1) ; append
	EndIf
	FileWriteLine($hEntete, "[CUSTOMER]" & $sNom & "[/CUSTOMER]")
	FileWriteLine($hEntete, "")
	FileWriteLine($hEntete, "[START]" & _Now() & "[/START]")
	FileWriteLine($hEntete, "")
	FileWriteLine($hEntete, "[FREESPACE_START]" & $iFreeSpace & " Go" & "[/FREESPACE_START]")
	FileClose($hEntete)

	_FichierCache("FS_START", $iFreeSpace)

	_FileWriteLog($hLog, 'Copie des fichiers "A copier" dans le dossier rapport')
	; copie du contenu du dossier à copier
	FileCopy(@ScriptDir & "\A copier\*", $sDossierRapport & "\", 8)

	_FileWriteLog($hLog, "Récupération des informations système")
	_GetInfoSysteme($iReset)

	_FileWriteLog($hLog, "Vérification état SMART des disques durs")
	_GetSmart2()

EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: _InfoSysteme
; Description ...:
; Syntax ........:
; Parameters ....:
; Return values..:
; Author.........: Bastien
; Modified ......:
; ===============================================================================================================================
Func _GetInfoSysteme($iReset = 0)

	If _FichierCacheExist("OS") And $iReset = 0 Then
		$hInfosys = FileOpen($sFileInfosysUpd, 2)
	ElseIf $iReset = 1 Then
		$hInfosys = FileOpen($sFileInfosys, 2)
	Else
		$hInfosys = FileOpen($sFileInfosys, 1)
	EndIf
	; Système d'exploitation
	Dim $Obj_WMIService = ObjGet("winmgmts:\\" & "localhost" & "\root\cimv2")
	Dim $Obj_Services = $Obj_WMIService.ExecQuery("Select * from Win32_OperatingSystem")
	Local $Obj_Item
	For $Obj_Item In $Obj_Services
		If(_FichierCacheExist("OS") = 0 Or $iReset = 1) Then
			FileWriteLine($hInfosys, "[PC_NAME]" & @ComputerName & "[/PC_NAME]")
			FileWriteLine($hInfosys, "[OS]" & $Obj_Item.Caption & " " & @OSArch & "[/OS]")
			FileWriteLine($hInfosys, "[RELEASE]" & $releaseid & "[/RELEASE]")
			FileWriteLine($hInfosys, "[INSTALL_DATE]" & StringRegExpReplace($Obj_Item.InstallDate, "\A(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})(?:.*)", "$3/$2/$1 $4:$5:$6") & "[/INSTALL_DATE]")
			_FichierCache("OS", $Obj_Item.Caption & " " & @OSArch & " " & $releaseid & " (v." & $Obj_Item.Version & ")")
		Else
			If(_FichierCache("OS") <> $Obj_Item.Caption & " " & @OSArch & " " & $releaseid & " (v." & $Obj_Item.Version & ")") Then
				FileWriteLine($hInfosys, "[OS]" & $Obj_Item.Caption & " " & @OSArch & "[/OS]")
				FileWriteLine($hInfosys, "[RELEASE]" & $releaseid & "[/RELEASE]")
			EndIf
		EndIf
	Next

	If(_FichierCacheExist("GENUINE") = 0 Or $iReset = 1) Then
		If $bActiv = 2 Then
			FileWriteLine($hInfosys, "[GENUINE]0[/GENUINE]")
		Else
			FileWriteLine($hInfosys, "[GENUINE]1[/GENUINE]")
		EndIf
		_FichierCache("GENUINE", $bActiv)
	Else
		If(_FichierCache("GENUINE") <> $bActiv) Then
			If $bActiv = 2 Then
				FileWriteLine($hInfosys, "[GENUINE]0[/GENUINE]")
			Else
				FileWriteLine($hInfosys, "[GENUINE]1[/GENUINE]")
			EndIf
		EndIf
	EndIf

	; BIOS
	Dim $Obj_Services = $Obj_WMIService.ExecQuery("Select * from Win32_BIOS")
	Local $Obj_Item
	For $Obj_Item In $Obj_Services
		; $sInfos &= " Numéro de série : " & $Obj_Item.SerialNumber & @CRLF
		If(_FichierCacheExist("BIOS") = 0 Or $iReset = 1) Then
			FileWriteLine($hInfosys, "[BIOS]" & $Obj_Item.SMBIOSBIOSVersion & "[/BIOS]") ; (s/n : " & $Obj_Item.SerialNumber & ")
			_FichierCache("BIOS", $Obj_Item.SMBIOSBIOSVersion)
		Else
			If(_FichierCache("BIOS") <> $Obj_Item.SMBIOSBIOSVersion) Then
				FileWriteLine($hInfosys, "[BIOS]" & $Obj_Item.SMBIOSBIOSVersion & "[/BIOS]")
			EndIf
		EndIf
	Next

	; Ordinateur
	Dim $Obj_Services = $Obj_WMIService.ExecQuery("Select * from Win32_ComputerSystem")
	Local $Obj_Item
	For $Obj_Item In $Obj_Services
		If(_FichierCacheExist("RAM") = 0 Or $iReset = 1) Then
			FileWriteLine($hInfosys, "[MODEL]" & $Obj_Item.Manufacturer & " " & $Obj_Item.Model & "[/MODEL]")
			FileWriteLine($hInfosys, "[RAM]" & Round((($Obj_Item.TotalPhysicalMemory / 1024) / 1024), 0) & " Mo" & "[/RAM]")
			_FichierCache("RAM", Round((($Obj_Item.TotalPhysicalMemory / 1024) / 1024), 0) & " Mo")
		Else
			If(_FichierCache("RAM") <> Round((($Obj_Item.TotalPhysicalMemory / 1024) / 1024), 0) & " Mo") Then
				FileWriteLine($hInfosys, "[RAM]" & Round((($Obj_Item.TotalPhysicalMemory / 1024) / 1024), 0) & " Mo[/RAM]")
			EndIf
		EndIf

	Next

	; Processeur
	Dim $Obj_Services = $Obj_WMIService.ExecQuery("Select * from Win32_Processor")
	Local $Obj_Item
	For $Obj_Item In $Obj_Services
		If(_FichierCacheExist("CPU") = 0 Or $iReset = 1) Then
			FileWriteLine($hInfosys, "[CPU]" & $Obj_Item.Name & "[/CPU]")
			FileWriteLine($hInfosys, "[SOCKET]" & $Obj_Item.SocketDesignation & "[/SOCKET]")
			_FichierCache("CPU", $Obj_Item.Name)
		Else
			If(_FichierCache("CPU") <> $Obj_Item.Name) Then
				FileWriteLine($hInfosys, "[CPU]" & $Obj_Item.Name & "[/CPU]")
			EndIf
		EndIf
	Next

	; Carte mère
	Dim $Obj_Services = $Obj_WMIService.ExecQuery("Select * from Win32_BaseBoard")
	Local $Obj_Item
	For $Obj_Item In $Obj_Services
		If(_FichierCacheExist("MB") = 0 Or $iReset = 1) Then
			FileWriteLine($hInfosys, "[MB]" & $Obj_Item.Manufacturer & " " & $Obj_Item.Product & "[/MB]")
			FileWriteLine($hInfosys, "[SN]" & $Obj_Item.SerialNumber & "[/SN]")
			_FichierCache("MB", $Obj_Item.Manufacturer & " " & $Obj_Item.Product & " (s/n : " & $Obj_Item.SerialNumber & ")")
		Else
			If(_FichierCache("MB") <> $Obj_Item.Manufacturer & " " & $Obj_Item.Product & " (s/n : " & $Obj_Item.SerialNumber & ")") Then
				FileWriteLine($hInfosys, "[MB]" & $Obj_Item.Manufacturer & " " & $Obj_Item.Product & "[/MB]")
				FileWriteLine($hInfosys, "[SN]" & $Obj_Item.SerialNumber & "[/SN]")
			EndIf
		EndIf
	Next

	; Carte graphique
	Dim $Obj_Services = $Obj_WMIService.ExecQuery("Select * from Win32_VideoController")
	Local $Obj_Item, $dNum = 0
	For $Obj_Item In $Obj_Services
		If(_FichierCacheExist("GC" & $dNum) = 0 Or $iReset = 1) Then
			FileWriteLine($hInfosys, "[GC]" &$Obj_Item.Name & "[/GC]")
			_FichierCache("GC" & $dNum, $Obj_Item.Name)
		Else
			If(_FichierCache("GC" & $dNum) <> $Obj_Item.Name) Then
				FileWriteLine($hInfosys, "[GC]" & $Obj_Item.Name & "[/GC]")
			EndIf
		EndIf
		$dNum = $dNum + 1
	Next

	FileClose($hInfosys)

EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _GetSmart2()
; Description ...:
; Syntax ........:
; Parameters ....:
; Return values..:
; Author.........: Bastien
; Modified ......:
; ===============================================================================================================================

Func _GetSmart2($iRapport=1)

	Local $smartctl = @ScriptDir & "\Outils\Smartmontools\smartctl.exe", $iPidSmart, $i = 0, $sOutput, $aArray, $aSearch, $aSearch2, $aSearch3, $aSearch4, $sDisque, $aCapa, $aSearchSMART[], $aKeysSMART, $iValueSMART, $iFind, $aSmartCritique[]
	$aSearchSMART["Reallocated_Sector_Ct"] = "Nombre de secteurs réalloués"
	$aSearchSMART["Power_On_Hours"] = "Heures de fonctionnement"
	$aSearchSMART["Power_Cycle_Count"] = "Nombre de démarrages"
	$aSearchSMART["Temperature_Celsius"] = "Température"
	$aSearchSMART["Current_Pending_Sector"] = "Nombre de secteurs instables"
	$aSearchSMART["Offline_Uncorrectable"] = "Nombre de secteurs incorrigibles"
	$aSearchSMART["Critical Warning"] = "Erreur critique"
	$aSearchSMART["Temperature:"] = "Témpérature"
	$aSearchSMART["Percentage Used"] = "Usure du SSD"
	$aSearchSMART["Power Cycles"] = "Nombre de démarrages"
	$aSearchSMART["Power On Hours"] = "Heures de fonctionnement"
	$aSearchSMART["Media and Data Integrity Errors"] = "Erreur d'intégrité des données"

	$aSmartCritique["Reallocated_Sector_Ct"] = "0"
	$aSmartCritique["Power_On_Hours"] = "10000"
	$aSmartCritique["Power_Cycle_Count"] = "10000"
	$aSmartCritique["Current_Pending_Sector"] = "0"
	$aSmartCritique["Offline_Uncorrectable"] = "0"
	$aSmartCritique["Power Cycles"] = "10000"
	$aSmartCritique["Power On Hours"] = "1000"

	$aKeysSMART = MapKeys($aSearchSMART)

	If(FileExists($smartctl)) Then
		If $iRapport Then
			$hInfosys = FileOpen($sFileInfosys, 1)
		EndIf

		While 1
			$iPidSmart = Run( @ComSpec & ' /c "' & $smartctl & '" -a /dev/sd' & Chr($i + 97), "",@SW_HIDE, $STDOUT_CHILD)

			ProcessWaitClose($iPidSmart)
			Sleep(100)
			$sOutput = StdoutRead($iPidSmart)
			$aArray = StringSplit(StringTrimRight(StringStripCR($sOutput), StringLen(@CRLF)), @CRLF)

			If StringInStr($aArray[4], "Unable to detect device type") Then
				ExitLoop
			Else
				$aSearch = _ArrayFindAll($aArray, "Model", 0, 0, 0, 1)
				If(@error = 0) Then
					If($iRapport) Then
						$sDisque = "[HDD" & $i & "]"
					Else
						$sDisque = $sDisque & " Disque " & $i & " :"
					EndIf

					For $iSearch in $aSearch
						$sDisque = $sDisque & " " & StringStripWS(StringTrimLeft($aArray[$iSearch], StringInStr($aArray[$iSearch], ":")), 1)
					Next

					If($iRapport = 0 Or _FichierCacheExist("DD" & $i) = 0) Then

						_FichierCache("DD" & $i, $sDisque)

						$aSearch2 = _ArraySearch($aArray, "Capacity", 0, 0, 0, 1)
						If($aSearch2 <> -1) Then
							$aCapa = StringRegExp($aArray[$aSearch2], '\[(.*?)\]', 1)
							$sDisque = $sDisque & " - " & $aCapa[0]
						EndIf

						$aSearch3 = _ArraySearch($aArray, "test result", 0, 0, 0, 1)
						If ($aSearch3 <> -1) Then
							$sDisque = $sDisque & " - SMART : " & StringStripWS(StringTrimLeft($aArray[$aSearch3], StringInStr($aArray[$aSearch3], ":")), 1)
						EndIf

						For $sSMART in $aKeysSMART
							$aSearch4 = _ArraySearch($aArray, $sSMART, 0, 0, 0, 1)

							If ($aSearch4 <> -1) Then
								$iFind = StringInStr($aArray[$aSearch4], "-", 0, -1)
								If $iFind = 0 Then
									$iFind = StringInStr($aArray[$aSearch4], ":", 0, -1)
								EndIf

								$iValueSMART = StringStripWS(StringTrimLeft($aArray[$aSearch4], $iFind), 1)
								$sDisque = $sDisque & "[BR]" & $aSearchSMART[$sSMART] & " : " & $iValueSMART

								If ($iRapport And MapExists($aSmartCritique, $sSMART) And Int($iValueSMART) > $aSmartCritique[$sSMART]) Then
									_Attention($aSearchSMART[$sSMART] & " du disque " & $i & " : " & $iValueSMART)
								EndIf
							EndIf
						Next
						If $iRapport Then
							FileWriteLine($hInfosys, $sDisque & "[/HDD" & $i & "]")
						Else
							$sDisque = $sDisque & @CRLF & @CRLF
						EndIf
					Else
						If($iRapport And _FichierCache("DD" & $i) <> $sDisque) Then
							If FileExists($sFileInfosysUpd) Then
								FileDelete($sFileInfosysUpd)
							EndIf
							$hInfosysupd = FileOpen($sFileInfosysUpd, 1)
							FileWriteLine($hInfosys, "[HHD" & $i & "]" & $sDisque & "[/HHD" & $i & "]")
							FileClose($hInfosysupd)
						EndIf
					EndIf
				EndIf
			EndIf
			$i = $i + 1
		WEnd

		If $iRapport Then
			FileClose($hInfosys)
		EndIf

	Else
		_Attention("smartctl.exe n'est pas présent dans le dossier Outils de BAO")
	EndIf

	Return $sDisque
EndFunc

Func _CalculFS()
	$iFreeSpace = Round(DriveSpaceFree(@HomeDrive & "\") / 1024, 2)
EndFunc

Func _CalculFSGain()
	Local $iRetour = 0, $iGain, $iFreeSpaceNow = Round(DriveSpaceFree(@HomeDrive & "\") / 1024, 2)

	$iGain = _FichierCache("FS_START") - $iFreeSpaceNow
	If ($iGain > 1) Then
		$iRetour = $iGain
	EndIf

	return $iRetour
EndFunc