#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Version=Beta
#AutoIt3Wrapper_Outfile_type=a3x
#AutoIt3Wrapper_Outfile=D:\GitHub\BAO\BAO\BAO.a3x
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
;#AutoIt3Wrapper_Run_Au3Stripper=y
;#Au3Stripper_Parameters=/mo
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#pragma compile(ProductName, BAO)
#pragma compile(CompanyName, Isergues Informatique)
#pragma compile(FileDescription, Boite A Outils)
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

#cs

	A propos du logiciel
		Auteur : Bastien ROUCHES - Isergues Infomatique
		Nom du programme : Boite A Outils
		Fonction : Assistance au dépannage des ordinateurs pour Windows
		- Prise en main à distance
		- Contrôle de l'ordinateur
		- Désinfection
		- Mise à jour
		- Installation de pilotes
		- Test de mémoire vive
		- Rapport d'intervention
		- Installation silentieuse
		- Sauvegarde de fichiers
		- Téléchargement et exécution d'outils de dépannage personnalisables par le technicien


	Normes de programmation

		$iDescriptionDeLaVariable = Integer
		$sDescriptionDeLaVariable = String
		$hDescriptionDeLaVariable = Handle
		$aDescriptionDeLaVariable = Array

#ce

Opt("MustDeclareVars", 1)

Global $sVersion = "1.1.0" ; 20/11/22

#include-once
#include <APIDiagConstants.au3>
#include <Array.au3>
#include <ButtonConstants.au3>
#include <ColorConstants.au3>
#include <ComboConstants.au3>
#include <Constants.au3>
#include <Crypt.au3>
#include <Date.au3>
#include <EditConstants.au3>
#include <EventLog.au3>
#include <File.au3>
#include <FTPEx.au3>
#include <GuiComboBox.au3>
#include <GUIConstantsEx.au3>
#include <GuiEdit.au3>
#include <GuiListView.au3>
#include <GuiMenu.au3>
#include <GuiRichEdit.au3>
#include <GuiTreeView.au3>
#include <IE.au3>
#include <Inet.au3>
#include <ListViewConstants.au3>
#include <MemoryConstants.au3>
#include <Misc.au3>
#include <Process.au3>
#include <ProgressConstants.au3>
#include <ScreenCapture.au3>
#include <SQLite.au3>
;#include <SQLite.dll.au3>
#include <StaticConstants.au3>
#include <String.au3>
#include <StringConstants.au3>
#include <TreeViewConstants.au3>
#include <WinAPIConv.au3>
#include <WinAPIShellEx.au3>
#include <WindowsConstants.au3>

; BAO ne peut être lancé qu'une fois.
_Singleton(@ScriptName, 0)

Local $sDossierRapport, $sConfigDossierRapport, $sNom, $bNonPremierDemarrage = False, $sRetourInfo, $iFreeSpace, $sDem, $iIDAutologon, $sListeProgrammes = @LocalAppDataDir & "\bao\ListeProgrammes.txt", $sOSv, $sSubKey, $sMdps, $sAutoUser, $sDomaine
Global $hGUIBAO, $iIcones, $sFTPAdresse, $sFTPUser, $sFTPPort, $sFTPDossierSuivi, $sFTPDossierRapports, $sFTPDossierCapture, $sFTPDossierSFX, $iLabelPC, $aResults[], $sInfos, $statusbar, $statusbarprogress, $iWallpaper, $iIDCancelDL, $sProgrun, $sProgrunUNC, $iPidt[], $iIDAction, $aMenu[], $aMenuID[], $sNomDesinstalleur, $sPrivazer, $aListeProgdes, $sListeProgdes, $aListeTech, $sListeTech, $aButtonDes[], $iIDEditRapport, $iIDEditLog, $iIDEditLogInst, $iIDEditLogDesinst, $iIDEditInter, $HKLM, $envChoco = @AppDataCommonDir & "\Chocolatey\", $sRestauration, $sPWDZip, $aListeAvSupp, $releaseid, $idListInfosys, $aProaxiveDelele, $sSociete, $iIDBoutonInscMat, $bActiv = 2, $iAutoAdmin, $sFTPProtocol, $HomeDrive = StringLeft(@WindowsDir,2), $iSupervision = 0, $sCheminCapture = @ScriptDir & "\Cache\Supervision\", $sNomCapture = $sNom, $iNBCaptures = 0, $iScreenWidth, $iScreenHeight, $iIDBoutonRaf
Global $sYear = @YEAR, $sMon = @MON, $sDay = @MDAY, $sHeure, $iMin = @MIN, $iIDCheckboxwu, $iIDRestau, $iIDespacelibre, $aMemStats, $iIDRAMlibre, $iFreeSpacech, $iModeTech = 0, $mInfosClient[], $sAgent, $sMailBD, $iIDListStats, $iIDLabelNewInt, $iIDListResult, $iIDInputRecherche

; déclaration des fichiers rapport
Global $hLog, $sFileLog
Global $hEntete, $sFileEntete
Global $hInfosys, $sFileInfosys
Global $hInfosysupd, $sFileInfosysupd
Global $hInfosClient, $sFileInfosClient
Global $hInstallation, $sFileInstallation
Global $hDesinstallation, $sFileDesinstallation
Global $hRapport, $sFileRapport
Global $sNomFichierRapport

; Création des fichiers logs et rapport temporaires
$sFileLog = @LocalAppDataDir & "\bao\logs.txt"
$sFileEntete = @LocalAppDataDir & "\bao\entete.bao"
$sFileInfosys = @LocalAppDataDir & "\bao\infosys.bao"
$sFileInfosysupd = @LocalAppDataDir & "\bao\infosysupd.bao"
$sFileInfosClient = @LocalAppDataDir & "\bao\infosclient.bao"
$sFileInstallation = @LocalAppDataDir & "\bao\install.bao"
$sFileDesinstallation = @LocalAppDataDir & "\bao\uninstall.bao"
$sFileRapport = @LocalAppDataDir & "\bao\rapport.bao"

$hLog = FileOpen($sFileLog, 9)

If @OSArch = "X64" Then
    $HKLM = "HKLM64"
Else
    $HKLM = "HKLM"
EndIf

Local $hDLL = DllOpen("user32.dll")
Local $iFastStart = False
If _IsPressed("10", $hDLL) Then
	$iFastStart = True
	_FileWriteLog($hLog, 'Démarrage rapide activé')
EndIf

; Création du raccourci sur le bureau
;$sDriveMap = DriveMapGet(StringLeft(@ScriptDir, 2))
Local $sSplashTxt = "Patientez pendant l'Initialisation de BAO"
Local $iSplashWidth = 300
Local $iSplashHeigh = 180
Local $iSplashX = @DesktopWidth - 400
Local $iSplashY = @DesktopHeight - 290
Local $iSplashOpt = 4
Local $iSplashFontSize = 10

If _FichierCacheExist("Technicien") = 0 Then
	SplashTextOn("Initialisation de BAO (SHIFT = démarrage rapide)", $sSplashTxt, $iSplashWidth, $iSplashHeigh, $iSplashX, $iSplashY, $iSplashOpt, "", $iSplashFontSize)
EndIf

If(FileExists(@DesktopDir & "\BAO.lnk") = 0) Then
	$sSplashTxt = $sSplashTxt & @LF & "Création du raccourci sur le bureau"
	ControlSetText("Initialisation de BAO (SHIFT = démarrage rapide)", "", "Static1", $sSplashTxt)
	FileCopy(@ScriptDir & "\Outils\bao.ico", @LocalAppDataDir & "\bao\bao.ico")
	FileCreateShortcut(@ScriptDir & '\run.bat', @DesktopDir & "\BAO.lnk", "", "", "Boîte à Outils", @LocalAppDataDir & "\bao\bao.ico")
EndIf

$sSplashTxt = $sSplashTxt & @LF & "Chargement des dépendances"
ControlSetText("Initialisation de BAO (SHIFT = démarrage rapide)", "", "Static1", $sSplashTxt)

Const $sConfig = @ScriptDir & "\config.ini"

#include "UDF\_BureauDistant.au3"
#include "UDF\_Desinfection.au3"
#include "UDF\_Desinstallation.au3"
#include "UDF\_FTP.au3"
#include "UDF\_Infosys.au3"
#include "UDF\_Installation.au3"
#include "UDF\_Intervention.au3"
#include "UDF\_Menu.au3"
#include "UDF\_Mdp.au3"
#include "UDF\_MiseAJour.au3"
#include "UDF\_PowerKeepAlive.au3"
#include "UDF\_Pilotes.au3"
#include "UDF\_Principal.au3"
#include "UDF\_Rapport.au3"
#include "UDF\_Restauration.au3"
#include "UDF\_Sauvegarde.au3"
#include "UDF\_Scripts.au3"
#include "UDF\_Sfx.au3"
#include "UDF\_Stabilite.au3"
#include "UDF\_Supervision.au3"
#include "UDF\_Telechargement.au3"
#include "UDF\SFTPEx.au3"

; Désactivation de la mise en veille https://www.autoitscript.com/forum/topic/152381-screensaver-sleep-lock-and-power-save-disabling/

$sSplashTxt = $sSplashTxt & @LF & "Désactivation de la mise en veille"
ControlSetText("Initialisation de BAO (SHIFT = démarrage rapide)", "", "Static1", $sSplashTxt)

_PowerKeepAlive()

; Lancement des fonctions à la fermeture
OnAutoItExitRegister("_PowerResetState")
OnAutoItExitRegister("_ProcessExit")
;OnAutoItExitRegister("_DriveMapDel")
;OnAutoItExitRegister("_StartWU")

$sSplashTxt = $sSplashTxt & @LF & "Lecture du fichier de configuration"
ControlSetText("Initialisation de BAO (SHIFT = démarrage rapide)", "", "Static1", $sSplashTxt)

_InitialisationBAO($sConfig)

; Création du dossier rapport et du fichier rapport d'intervention

$sSociete = IniRead($sConfig, "Parametrages", "Societe", "NomSociete")
$iIcones = IniRead($sConfig, "Parametrages", "Icones", 1)
$sRestauration = IniRead($sConfig, "Parametrages", "Restauration", 0)
$aListeTech = _StringExplode(IniRead($sConfig, "Parametrages", "Techniciens", ""), " ")
$sAgent = IniRead($sConfig, "BureauDistant", "Agent", "DWAgent")
$sMailBD = IniRead($sConfig, "BureauDistant", "Mail", "")

;$iSupervision = IniRead($sConfig, "Parametrages", "Supervision", "0")
$sConfigDossierRapport = IniRead($sConfig, "Parametrages", "Dossier", "Rapports")
$sDossierRapport = @DesktopDir & "\" & $sConfigDossierRapport

DirCreate(@ScriptDir & "\Cache\Download")
DirCreate(@ScriptDir & "\Cache\Supervision")

; intialisation des variables FTP
$sFTPProtocol = IniRead($sConfig, "FTP", "Protocol", "ftp")
$sFTPAdresse = IniRead($sConfig, "FTP", "Adresse", "")
$sFTPUser = IniRead($sConfig, "FTP", "Utilisateur", "")
$sFTPPort = IniRead($sConfig, "FTP", "Port", "")
$sFTPDossierSuivi = IniRead($sConfig, "FTP", "DossierSuivi", "")
$sFTPDossierRapports = IniRead($sConfig, "FTP", "DossierRapports", "")
$sFTPDossierCapture = IniRead($sConfig, "FTP", "DossierCapture", "")
$sFTPDossierSFX = IniRead($sConfig, "FTP", "DossierSFX", "")

if(_FichierCacheExist("Client") = 0) Then
	_CalculFS()
	$sNom = _PremierLancement()
Else
	$bNonPremierDemarrage = True
	$sNom = _FichierCache("Client")
	If _FichierCacheExist("Technicien") = 1 Then $iModeTech = 1
	If $iFastStart = False And $iModeTech = 0 Then
		$sSplashTxt = $sSplashTxt & @LF & "Recherche des modifications sur le matériel"
		ControlSetText("Initialisation de BAO (SHIFT = démarrage rapide)", "", "Static1", $sSplashTxt)
		_GetInfoSysteme()
	EndIf
EndIf
_CalculFS()

If _FichierCacheExist("Intervention") = 0 Then
	If ($iModeTech = 0 And StringLeft(@ScriptDir, 2) = "\\" And $sFTPAdresse <> "" And $sFTPUser <> "" And $sFTPDossierSuivi <> "") Or $iModeTech = 1 Then
		_FichierCache("Intervention", 1)
	EndIf
EndIf

$sSplashTxt = $sSplashTxt & @LF & "Vérification version et licence Windows"
ControlSetText("Initialisation de BAO (SHIFT = démarrage rapide)", "", "Static1", $sSplashTxt)

If(@OSVersion = "WIN_7") Then
	$releaseid = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\", "CSDVersion")
ElseIf(@OSVersion = "WIN_10") Then
	$releaseid = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\", "ReleaseId")
	If $releaseid = "2009" Then
		$releaseid = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\", "DisplayVersion")
	EndIf
EndIf

If $iFastStart = False And $iModeTech = 0 Then
	; Système d'exploitation
	Dim $Obj_WMIService = ObjGet("winmgmts:\\" & "localhost" & "\root\cimv2")
	Dim $Obj_Services = $Obj_WMIService.ExecQuery("Select * from Win32_OperatingSystem")
	Local $Obj_Item
	For $Obj_Item In $Obj_Services
		$sOSv = $Obj_Item.Caption & " " & @OSArch & " " & $releaseid
	Next

	;$sOSv = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\", "ProductName") & " " & @OSArch & " " & $releaseid

	Dim $Obj_WMIService = ObjGet("winmgmts:\\" & "localhost" & "\root\cimv2")
	Dim $Obj_Services = $Obj_WMIService.ExecQuery("Select * from SoftwareLicensingProduct where PartialProductKey <> null")
	Local $Obj_Item
	For $Obj_Item In $Obj_Services
		if $Obj_Item.LicenseStatus = 1 And $Obj_Item.ApplicationId = "55c92734-d682-4d71-983e-d6ec3f16059f" And $Obj_Item.LicenseIsAddon = False Then
			$sOSv = $sOSv & " (activé)"
			$bActiv = 1
			ExitLoop
		EndIf
	Next
	If $bActiv = 2 Then
		$sOSv = $sOSv & " (non activé)"
	EndIf
Else
	If $iModeTech = 0 Then
		$sOSv = "(non vérifié en démarrage rapide)"
	EndIf
	$bActiv = 1
EndIf

If(FileExists(@ScriptDir & "\Logiciels\") = 0) Then _Erreur('Dossier "Logiciels" manquant')

; initialisation désinfection
$aListeProgdes = _StringExplode(IniRead($sConfig, "Desinfection", "Programmes de desinfection", "Privazer RogueKiller AdwCleaner MalwareByte ZHPCleaner"), " ")

If(FileExists($sListeProgrammes)) Then
	_FileReadToArray($sListeProgrammes, $aListeAvSupp, 0)
Else
	$aListeAvSupp = _ListeProgrammes()
	$aListeAvSupp =  _ArrayUnique($aListeAvSupp, 0, 0, 0, 0)
	_FileWriteFromArray($sListeProgrammes, $aListeAvSupp)
EndIf

; Déclaration des boutons de fonctions (pour calculer la taille de la fenêtre BAO)
Local $iIDButtonBureaudistant
Local $iIDButtonSupervision
Local $iIDButtonInstallation
Local $iIDButtonSauvegarde
Local $iIDButtonWU
Local $iIDButtonPilotes
Local $iIDButtonStabilite
Local $iIDButtonScripts

; Soit :
Local $iFonctions = 8, $iHauteurFenetre
If UBound($aListeProgdes) < 6 Then
	$iHauteurFenetre = 6 * 25
Else
	$iHauteurFenetre = UBound($aListeProgdes) * 25
EndIf

$hGUIBAO = GUICreate($sSociete & " - Boîte A Outils (bêta) " & $sVersion, 860, 210 + ($iFonctions * 30) + $iHauteurFenetre)

$statusbar = GUICtrlCreateLabel("", 10, 135 + ($iFonctions * 30) + $iHauteurFenetre, 410, 20, $SS_CENTERIMAGE)
$statusbarprogress = GUICtrlCreateProgress(440, 135 + ($iFonctions * 30) + $iHauteurFenetre, 250, 20)
$iIDCancelDL = GUICtrlCreateButton("Passer / Annuler", 700, 135 + ($iFonctions * 30) + $iHauteurFenetre, 150, 20)
GUICtrlSetState($iIDCancelDL, $GUI_DISABLE)
GUICtrlSetFont($statusbar, 11)

Local $iIDMenu1clearcache, $iIDMenu1update, $iIDMenu1copier, $iIDMenu1sfx, $iIDMenu2index, $iIDMenu1supervision, $iIDMenu1modeles

Local $iIDMenu1 = GUICtrlCreateMenu("&Configuration")
Local $iIDMenu1config = GUICtrlCreateMenuItem("Editer config.ini", $iIDMenu1)
Local $iIDMenu1dossierRapport = GUICtrlCreateMenuItem("Ouvrir dossier Rapport", $iIDMenu1)
If($iModeTech = 1) Then
	GUICtrlSetState(-1, $GUI_DISABLE)
EndIf
Local $iIDMenu1dossier = GUICtrlCreateMenuItem("Ouvrir dossier du programme", $iIDMenu1)
Local $iIDMenu1dossierAppdata = GUICtrlCreateMenuItem("Ouvrir dossier AppData", $iIDMenu1)
Local $iIDMenu1reini = GUICtrlCreateMenuItem("Reinitialiser BAO", $iIDMenu1)
Local $iIDMenu1tech = GUICtrlCreateMenuItem("Passer en mode Tech/Client", $iIDMenu1)

If($iModeTech = 1) Then
	GUICtrlCreateMenuItem("", $iIDMenu1)
	$iIDMenu1clearcache = GUICtrlCreateMenuItem("Effacer le cache installation", $iIDMenu1)
	$iIDMenu1update = GUICtrlCreateMenuItem("Tout mettre à jour", $iIDMenu1)
	$iIDMenu1copier = GUICtrlCreateMenuItem("Copier BAO sur support externe", $iIDMenu1)
	$iIDMenu1sfx = GUICtrlCreateMenuItem("Créer archive SFX", $iIDMenu1)
	$iIDMenu1supervision = GUICtrlCreateMenuItem("Créer index supervision", $iIDMenu1)
	$iIDMenu1modeles = GUICtrlCreateMenuItem("Modifier les modèles", $iIDMenu1)
EndIf
GUICtrlCreateMenuItem("", $iIDMenu1)

Local $iIDMenu1redemarrer = GUICtrlCreateMenuItem("Redémarrer BAO", $iIDMenu1)
Local $iIDMenu1quitter = GUICtrlCreateMenuItem("Quitter", $iIDMenu1)

Local $iIDMenu2 = GUICtrlCreateMenu("&Intervention")

Local $iIDMenu2supp, $iIDMenu2ajout, $iIDMenu2completer
If($iModeTech = 0) Then
	$iIDMenu2completer = GUICtrlCreateMenuItem("Ajouter une information de suivi", $iIDMenu2)
	$iIDMenu2supp = GUICtrlCreateMenuItem("Supprimer le suivi", $iIDMenu2)
	$iIDMenu2ajout = GUICtrlCreateDummy()
Else
	$iIDMenu2ajout = GUICtrlCreateMenuItem("Créer/Modifier/Supprimer Intervention", $iIDMenu2)
	$iIDMenu2completer = GUICtrlCreateMenuItem("Ajouter une information de suivi", $iIDMenu2)
	$iIDMenu2supp = GUICtrlCreateMenuItem("Supprimer un code de suivi", $iIDMenu2)
EndIf

If($iModeTech = 1) Then
	$iIDMenu2index = GUICtrlCreateMenuItem("Créer index.php sur le serveur FTP", $iIDMenu2)
ElseIf(_FichierCacheExist("Intervention") = 0) Then
	GUICtrlSetState($iIDMenu2, $GUI_DISABLE)
EndIf

Local $aDoc = _FileListToArrayRec(@ScriptDir & "\Logiciels\", "*.ini", 1, 0, 1)
Local $i, $j, $iPremElement, $iDernElement, $x = 70

Local $iIDMenuLog = GUICtrlCreateMenu("&Logiciels")

$iPremElement = $iIDMenuLog + 1
Local $aTemp, $iIDMenuDoc, $aTempLog[16], $sNomLog, $aShortcut, $aLogMenu, $sIDSM, $iToDel, $iToOpen, $iToRen, $aListBD[0]

For $i = 1 To $aDoc[0]

;~ 	If @OSArch = "X64" Then
;~ 		$aTemp = _FileListToArrayRec(@ScriptDir & "\Liens\" & $aDoc[$i], "*.url;*.txt;*.lnk|*-x86.url")
;~ 	Else
;~ 		$aTemp = _FileListToArrayRec(@ScriptDir & "\Liens\" & $aDoc[$i], "*.url;*.txt;*.lnk|*-x64.url")
;~ 	EndIf

	$iIDMenuDoc = GUICtrlCreateMenu(StringTrimRight($aDoc[$i], 4), $iIDMenuLog)

	$aLogMenu = IniReadSectionNames(@ScriptDir & "\Logiciels\" & $aDoc[$i])

	If IsArray($aLogMenu) Then
		For $j = 1 To $aLogMenu[0]

			$sNomLog = $aLogMenu[$j]
			If(($iModeTech = 0 And StringInStr(IniRead (@ScriptDir & "\Logiciels\" & $aDoc[$i], $sNomLog, "lien", "0" ), ":") <> 2) Or $iModeTech = 1) Then

				$sIDSM = GUICtrlCreateMenuItem($sNomLog, $iIDMenuDoc)

				$aTempLog[0] = $sIDSM
				$aTempLog[1] = $sNomLog
				$aTempLog[2] = IniRead (@ScriptDir & "\Logiciels\" & $aDoc[$i], $sNomLog, "lien", "0" )
				$aTempLog[3] = IniRead (@ScriptDir & "\Logiciels\" & $aDoc[$i], $sNomLog, "site", "0" )
				$aTempLog[4] = IniRead (@ScriptDir & "\Logiciels\" & $aDoc[$i], $sNomLog, "forcedl", "0" )
				$aTempLog[5] = IniRead (@ScriptDir & "\Logiciels\" & $aDoc[$i], $sNomLog, "headers", "0" )
				$aTempLog[6] = IniRead (@ScriptDir & "\Logiciels\" & $aDoc[$i], $sNomLog, "motdepasse", "0" )
				$aTempLog[7] = IniRead (@ScriptDir & "\Logiciels\" & $aDoc[$i], $sNomLog, "favoris", "0" )
				$aTempLog[8] = IniRead (@ScriptDir & "\Logiciels\" & $aDoc[$i], $sNomLog, "extension", "" )
				$aTempLog[9] = IniRead (@ScriptDir & "\Logiciels\" & $aDoc[$i], $sNomLog, "domaine", "" )
				$aTempLog[10] = IniRead (@ScriptDir & "\Logiciels\" & $aDoc[$i], $sNomLog, "nepasmaj", "0" )
				$aTempLog[11] = IniRead (@ScriptDir & "\Logiciels\" & $aDoc[$i], $sNomLog, "expression", "" )
				$aTempLog[12] = IniRead (@ScriptDir & "\Logiciels\" & $aDoc[$i], $sNomLog, "expressionnonincluse", "" )
				$aTempLog[13] = IniRead (@ScriptDir & "\Logiciels\" & $aDoc[$i], $sNomLog, "expressionaremplacer", "" )
				$aTempLog[14] = IniRead (@ScriptDir & "\Logiciels\" & $aDoc[$i], $sNomLog, "expressionderemplacement", "" )
				$aTempLog[15] = $aDoc[$i]

				; Construction de deux Maps (un trié par nom et l'autre par ID menu)
				$aMenu[$sNomLog] = $aTempLog
				$aMenuID[$sIDSM] = $aTempLog

				If $aTempLog[7] = 1 Then
					$sIDSM = GUICtrlCreateButton($sNomLog, 700, $x, 150, 25)
					$x = $x + 25
					$aTempLog[15] = -1
					$aMenuID[$sIDSM] = $aTempLog
				EndIf

				If $iModeTech = 1 And $aDoc[$i] = "Bureau Distant.ini" Then
					ReDim $aListBD[$j]
					$aListBD[$j-1] = $sNomLog
				EndIf
			EndIf
		Next
 	EndIf
	If($iModeTech = 1) Then
		GUICtrlCreateMenuItem("", $iIDMenuDoc)
		$iToOpen = GUICtrlCreateMenuItem("Modifier les logiciels", $iIDMenuDoc)
		$aTempLog[0] = "Open"
		$aTempLog[1] = $aDoc[$i]
		$aMenuID[$iToOpen] = $aTempLog
		$iToRen = GUICtrlCreateMenuItem("Renommer ce dossier", $iIDMenuDoc)
		$aTempLog[0] = "Rename"
		$aTempLog[1] = $aDoc[$i]
		$aMenuID[$iToRen] = $aTempLog
		$iToDel = GUICtrlCreateMenuItem("Supprimer ce dossier", $iIDMenuDoc)
		$aTempLog[0] = "Delete"
		$aTempLog[1] = $aDoc[$i]
		$aMenuID[$iToDel] = $aTempLog
	Else
		GUICtrlCreateDummy()
		GUICtrlCreateDummy()
		GUICtrlCreateDummy()
		GUICtrlCreateDummy()
	EndIf
Next

Local $iIDMenuAddDoc, $iIDMenuAdd, $iIDMenuManu

If($iModeTech = 1) Then
	GUICtrlCreateMenuItem("", $iIDMenuLog)
	$iIDMenuAdd = GUICtrlCreateMenuItem("Ajouter un lien/logiciel", $iIDMenuLog)
	$iIDMenuAddDoc = GUICtrlCreateMenuItem("Ajouter un dossier", $iIDMenuLog)
	$iIDMenuManu = GUICtrlCreateMenuItem("Modifier manuellement", $iIDMenuLog)
	$iDernElement = $iIDMenuManu
	If UBound($aListBD) = 0 Then
		_FileWriteLog($hLog, '"Bureau distant" est absent du menu logiciel ou il ne contient aucun logiciel')
		ReDim $aListBD[1]
		$aListBD[0] = "DWAgent"
	EndIf
Else
	GUICtrlCreateDummy()
	GUICtrlCreateDummy()
	GUICtrlCreateDummy()
	$iDernElement = GUICtrlCreateDummy()
EndIf



Local $iIDMenuVar = GUICtrlCreateMenu("&Var. env.")
Local $sIDVarALLUSERSPROFILE = GUICtrlCreateMenuItem("ALLUSERSPROFILE", $iIDMenuVar)
Local $sIDVarAPPDATA = GUICtrlCreateMenuItem("APPDATA", $iIDMenuVar)
Local $sIDVarLOCALAPPDATA = GUICtrlCreateMenuItem("LOCALAPPDATA", $iIDMenuVar)
Local $sIDVarProgramData = GUICtrlCreateMenuItem("ProgramData", $iIDMenuVar)
Local $sIDVarProgramFiles = GUICtrlCreateMenuItem("ProgramFiles", $iIDMenuVar)
Local $sIDVarProgramFiles86 = GUICtrlCreateMenuItem("ProgramFiles(x86)", $iIDMenuVar)
Local $sIDVarPUBLIC = GUICtrlCreateMenuItem("PUBLIC", $iIDMenuVar)
Local $sIDVarTEMP = GUICtrlCreateMenuItem("TEMP", $iIDMenuVar)
Local $sIDVarTMP = GUICtrlCreateMenuItem("TMP", $iIDMenuVar)
Local $sIDVarUSERPROFILE = GUICtrlCreateMenuItem("USERPROFILE", $iIDMenuVar)
Local $sIDVarwindir = GUICtrlCreateMenuItem("windir", $iIDMenuVar)
Local $iIDMenuHelp = GUICtrlCreateMenu("&?")
Local $sIDHelp = GUICtrlCreateMenuItem("Aide", $iIDMenuHelp)
Local $sIDapropos = GUICtrlCreateMenuItem("A propos", $iIDMenuHelp)

$sHeure = GUICtrlCreateLabel(@MDAY &"/"& @MON &"/"& @YEAR &" - "& @HOUR &":"& @MIN , 10, 164 + ($iFonctions * 30) + $iHauteurFenetre)

;If(_IsInternetConnected() = 1) Then
Run(@ComSpec & ' /C w32tm /resync', "", @SW_HIDE)
;EndIf

If($iModeTech = 0) Then
	 $iIDCheckboxwu = GUICtrlCreateCheckbox("Désactiver Windows Update", 350, 160 + ($iFonctions * 30) + $iHauteurFenetre)
	If(_FichierCacheExist("WUInactif") = 1) Then
		GUICtrlSetState(-1, $GUI_CHECKED)
	EndIf

	$iIDRestau = GUICtrlCreateButton("Créer un point de restauration", 130, 160 + ($iFonctions * 30) + $iHauteurFenetre, 190, 20)
Else
	$iIDCheckboxwu = GUICtrlCreateDummy()
	$iIDRestau = GUICtrlCreateDummy()
EndIf

If($iModeTech = 0) Then
	_UACDisable()
	; Activation de BAO au démarrage
	RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce","BAO","REG_SZ",'"' & @DesktopDir & '\BAO.lnk"')

	If _FichierCacheExist("Autologon") = 1 Then
		$iIDAutologon = GUICtrlCreateCheckbox("Autologon", 530, 160 + ($iFonctions * 30) + $iHauteurFenetre)
		If _FichierCache("Autologon") = 1 Then
			GUICtrlSetState($iIDAutologon, $GUI_CHECKED)
		EndIf
	EndIf

	Local $idCodeSuivi

	If(_FichierCacheExist("Suivi") And _FichierCache("Suivi") <> 1) Then
		$idCodeSuivi = " (" & _FichierCache("Suivi") & ")"
	EndIf

	$iLabelPC = GUICtrlCreateLabel("Client : " & $sNom & $idCodeSuivi, 10, 10, 540)

Else
	$iLabelPC = GUICtrlCreateLabel($sNom, 10, 10, 540)
EndIf
_CalculFS()
$iIDespacelibre = GUICtrlCreateLabel($HomeDrive & " " & $iFreeSpace & " Go libre", 620, 164 + ($iFonctions * 30) + $iHauteurFenetre)
$aMemStats = MemGetStats()
$iIDRAMlibre = GUICtrlCreateLabel("RAM : " & $aMemStats[$MEM_LOAD] & '% utilisée', 720, 164 + ($iFonctions * 30) + $iHauteurFenetre)


GUICtrlSetFont($iLabelPC, 18)

Local $sDate = _FichierCache("PremierLancement")
GUICtrlCreateLabel("Nom du PC : " & @ComputerName, 450, 2)
If $iModeTech = 0 Then
	GUICtrlCreateLabel("OS : " & $sOSv, 450, 18, 400)
Else
	GUICtrlCreateLabel("MODE TECHNICIEN", 450, 18, 400)
EndIf
If($bActiv = 2) Then
	GUICtrlSetColor(-1, $COLOR_RED)
Elseif $iFastStart = False Then
	GUICtrlSetColor(-1, $COLOR_GREEN)
EndIf
GUICtrlSetFont(-1, Default, 600)
GUICtrlCreateLabel("Début : " & $sDate, 450, 34, 200, 15)
GUICtrlSetFont(-1, Default, 600)

$iIDButtonBureaudistant = GUICtrlCreateButton("Bureau distant", 10, 50, 150, 25)
$iIDButtonSupervision = GUICtrlCreateButton("Supervision", 10, 80, 150, 25)
$iIDButtonInstallation = GUICtrlCreateButton("Installation", 10, 110, 150, 25)
$iIDButtonSauvegarde = GUICtrlCreateButton("Sauvegarde et restauration", 10, 140, 150, 25)
$iIDButtonWU = GUICtrlCreateButton("Windows et Office", 10, 170, 150, 25)
$iIDButtonPilotes = GUICtrlCreateButton("Pilotes", 10, 200, 150, 25)
$iIDButtonStabilite = GUICtrlCreateButton("Centre de contrôles", 10, 230, 150, 25)
$iIDButtonScripts = GUICtrlCreateButton("Scripts et outils", 10, 260, 150, 25)

Local $y = 70 + ($iFonctions * 30)
Local $pgroup = $y-20

Local $iIDButtonNettoyage = GUICtrlCreateButton("1 - Désinstallation", 10, $y, 150, 25)
If(_FichierCacheExist("Desinfection") = 1) Then
	_ChangerEtatBouton($iIDButtonNettoyage, "Activer")
EndIf

$y = $y + 25
Local $z
Local $iIDMenuDes, $iLargeur

For $z = 1 To UBound($aListeProgdes)
	If FileExists(@ScriptDir & "\Config\" & $aListeProgdes[$z - 1] & "\" & $aListeProgdes[$z - 1] & ".bat") Then
		$iLargeur = 125
		GUICtrlCreateButton("X", 135, $y, 25, 25)
	Else
		$iLargeur = 150
	EndIf
	$iIDMenuDes = GUICtrlCreateButton($z + 1 & " - " & $aListeProgdes[$z - 1], 10, $y, $iLargeur, 25)
	$aButtonDes[$iIDMenuDes] = $aListeProgdes[$z - 1]

	If(_FichierCacheExist($aListeProgdes[$z - 1]) = 1) Then
		_ChangerEtatBouton($iIDMenuDes, "Activer")
	EndIf
	$y = $y + 25
Next

Local $iIDButtonResetBrowser = GUICtrlCreateButton($z + 1 & " - Navigateurs Internet", 10, $y, 150, 25)
If(_FichierCacheExist("ResetBrowser") = 1) Then
	_ChangerEtatBouton($iIDButtonResetBrowser, "Activer")
EndIf

GUICtrlCreateGroup("Désinfection", 5, $pgroup, 160, (($z + 2) * 25) + 2)
GUICtrlSetFont (-1, 9, 800)

Local $iIDButtonEnvoi = GUICtrlCreateButton("Exporter le rapport", 700, $y - 60, 150, 25)
Local $iIDButtonUninstall = GUICtrlCreateButton("Désinstaller", 700, $y - 30, 150, 25)
Local $iIDButtonQuit = GUICtrlCreateButton("Quitter", 700, $y , 150, 25)

If ($x > $y - 65) Then _Attention("Il y a trop de liens dans le dossier Favoris, merci d'en supprimer")

GUICtrlCreateGroup("Favoris et raccourcis", 695, 50, 160, $y - 128)
GUICtrlSetFont (-1, 9, 800)

If _FichierCacheExist("Bureaudistant") = 1 Then	_ChangerEtatBouton($iIDButtonBureaudistant, "Activer")

If _FichierCacheExist("Supervision") = 1 Then
	_ChangerEtatBouton($iIDButtonSupervision, "Activer")
	$iSupervision = 1
EndIf

If _FichierCacheExist("Envoi") = 1 Then	_ChangerEtatBouton($iIDButtonEnvoi, "Activer")

If _FichierCacheExist("WU") = 1 Then _ChangerEtatBouton($iIDButtonWU, "Activer")

If _FichierCacheExist("Installation") = 1 Then _ChangerEtatBouton($iIDButtonInstallation, "Activer")

If _FichierCacheExist("Stabilite") = 1 Then _ChangerEtatBouton($iIDButtonStabilite, "Activer")

If _FichierCacheExist("StabiliteTime") = 1 Then
	_ResultatStabilite()
	_FichierCache("StabiliteTime", -1)
EndIf

$sNomCapture = $sNom & ".png"
If $iSupervision = 1 And $iModeTech = 0 Then
	_GetResolution()
EndIf

Local $iIDTAB, $iIDTABInfosCli, $sFPIN, $sFTracking, $sFNomClient, $sFPrenomClient, $sFSocieteClient, $sFAdresse, $sFTel, $sFMail, $sFTech, $sFDescription, $sFMateriel, $sFMDP, $sFAutologon, $iENomClient, $iEPrenomClient, $iESocieteClient, $iEAdresse, $iETel, $iEMail, $iEMateriel, $iEDescription, $iEMdp, $iETechnicien, $iClientSauvegarde, $iClientInterPrint, $iClientInterPrintSelect
Local $iIDTABInfossys, $iIDTABInstall, $idSampleMessage, $iNumRapport = 0, $aRapportsOld, $iIDBoutonVoirOld, $iIDTABLogs, $iIDButtonClear
Local $aModele = _FileListToArray(@ScriptDir & '\Config\Modeles\', "*.txt")
Local $iIDTVModele[$aModele[0]]
Local $iIDTABConfig, $iIDTABStats,$sBD, $iCEntreprise, $iCDossier, $iCIcones, $iCRestau, $iCBD, $iCIDBD, $iCProtocole, $iCFTPAdresse, $iCFTPPort, $iCFTPUtilisateur, $iCFTPRapport, $iCFTPSFX, $iCFTPSuivi, $iCFTPSupervision, $iCDesinfection, $iCSauvegarde, $iCTechnicien
Local $iIDRechercher, $hSearch, $sFichierTrouve, $aFoldersSearch, $bResultSearch = False, $iIDButtonOpen, $iIDButtonModif, $iIDButtonDupliquer, $iIDButtonNew, $iIDButtonSupprimer, $iIDNouvellesInter, $iIDButtonRapports

$iIDTAB = GUICtrlCreateTab(170, 50, 520, 77 + ($iFonctions * 30) + $iHauteurFenetre)
If $iModeTech = 0 Then
	$iIDTABInfosCli = GUICtrlCreateTabItem("Client")
	$mInfosClient = _GetInfosClient($sFileInfosClient)
	If MapExists($mInfosClient, "TRACKING") Then $sFTracking = $mInfosClient["TRACKING"]
	If MapExists($mInfosClient, "LASTNAME") Then $sFNomClient = $mInfosClient["LASTNAME"]
	If MapExists($mInfosClient, "FIRSTNAME") Then $sFPrenomClient = $mInfosClient["FIRSTNAME"]
	If MapExists($mInfosClient, "COMPANY") Then $sFSocieteClient = $mInfosClient["COMPANY"]
	If MapExists($mInfosClient, "ADDRESS") Then $sFAdresse = $mInfosClient["ADDRESS"]
	If MapExists($mInfosClient, "PHONE") Then $sFTel = $mInfosClient["PHONE"]
	If MapExists($mInfosClient, "MAIL") Then $sFMail = $mInfosClient["MAIL"]
	If MapExists($mInfosClient, "TECH") Then $sFTech = $mInfosClient["TECH"]
	If MapExists($mInfosClient, "DEVICES") Then $sFMateriel = $mInfosClient["DEVICES"]
	If MapExists($mInfosClient, "CASE") Then $sFDescription = $mInfosClient["CASE"]
	If MapExists($mInfosClient, "PASSWORD") Then $sFMDP = $mInfosClient["PASSWORD"]
	If MapExists($mInfosClient, "AUTOLOGON") Then
		$sFAutologon = $mInfosClient["AUTOLOGON"]
		If _FichierCacheExist("Autologon") And _FichierCache("Autologon") = 2 And $sFAutologon = "1" Then
			_FileWriteLog($hLog, "Activation automatique de l'autologon")
			$sDomaine = RegRead($HKLM & "\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters", "Domain")
			_ActivationAutologon($sDomaine, $sFMDP)
			GUICtrlSetState($iIDAutologon, $GUI_CHECKED)
		EndIf
	EndIf

	If _FichierCacheExist("Intervention") Then
		If _FichierCacheExist("Suivi") = 0 And $sFTracking <> "" Then
			_FichierCache("Suivi", $sFTracking)
			_DebutIntervention($sFTracking)
		ElseIf _FichierCacheExist("Suivi") = 0 Then
			_FichierCache("Suivi", 1)
		EndIf
	EndIf

	GUICtrlCreateGroup("Coordonnées du client", 180, 80, 280, 230)
	GUICtrlSetFont (-1, 9, 800)
	GUICtrlCreateLabel("Nom", 190, 105, 40, 25)
	$iENomClient = GUICtrlCreateInput($sFNomClient, 230, 100, 80, 25)
	GUICtrlCreateLabel("Prénom", 320, 105 , 40, 25)
	$iEPrenomClient = GUICtrlCreateInput($sFPrenomClient, 370, 100, 80, 25)
	GUICtrlCreateLabel("Société", 190, 135, 40, 25)
	$iESocieteClient = GUICtrlCreateInput($sFSocieteClient, 230, 130, 220, 25)
	GUICtrlCreateLabel("Adresse", 190, 165, 40, 25)
	$iEAdresse = GUICtrlCreateEdit(StringReplace($sFAdresse, "[BR]", @CRLF), 230, 160, 220, 70)
	GUICtrlCreateLabel("Tél", 190, 240, 40, 25)
	$iETel = GUICtrlCreateInput($sFTel, 230, 235, 220, 25)
	GUICtrlCreateLabel("Email",190, 275, 40, 25)
	$iEMail = GUICtrlCreateInput($sFMail, 230, 270, 220, 25)
	GUICtrlCreateGroup("Appareil(s) déposé(s)", 470, 80, 205, 230)
	GUICtrlSetFont (-1, 9, 800)
	$iEMateriel = GUICtrlCreateEdit(StringReplace($sFMateriel, "[BR]", @CRLF), 480, 100, 185, 200)
	GUICtrlCreateGroup("Description de la demande", 180, 315, 495, 190)
	GUICtrlSetFont (-1, 9, 800)
	$iEDescription = GUICtrlCreateEdit(StringReplace($sFDescription, "[BR]", @CRLF), 190, 335, 270, 160)
	GUICtrlCreateLabel("Mot de passe :", 470, 345, 70, 25)
	$iEMdp = GUICtrlCreateInput($sFMDP, 550, 340, 115, 25)
	GUICtrlCreateLabel("Technicien :", 470, 375, 70, 25)

	If $aListeTech <> "" Then
		$iETechnicien = GUICtrlCreateCombo("", 550, 370, 115, 25)
		GUICtrlSetData($iETechnicien, _ArrayToString($aListeTech), $sFTech)
	Else
		GUICtrlCreateLabel("Aucun Tech trouvé", 550, 370, 115, 25)
	EndIf
	$iClientInterPrint = GUICtrlCreateCheckbox("Imprimer la fichier intervention", 470, 405, 160, 25)
	$iClientInterPrintSelect = GUICtrlCreateCombo("Imprimante par défaut", 500, 430, 165, 25)
	GUICtrlSetData($iClientInterPrintSelect, "Choisir l'imprimante")
	$iClientSauvegarde = GUICtrlCreateButton("Sauvegarder les modifications", 470, 470, 190, 25)

	$iIDTABInfossys = GUICtrlCreateTabItem("Infos système")
	$idListInfosys = GUICtrlCreateListView("Nom |Valeur ", 180, 80, 500, 37 + ($iFonctions * 30) + $iHauteurFenetre)
	_GUICtrlListView_SetColumnWidth($idListInfosys, 0, 130)
	_GUICtrlListView_SetColumnWidth($idListInfosys, 1, 360)
	$iIDTABInstall = GUICtrlCreateTabItem("Intervention")
	$iIDEditInter = GUICtrlCreateEdit("", 180, 80, 300, 190)
	GUICtrlCreateGroup("Modèles", 490, 80, 190, 130)
	$idSampleMessage = GUICtrlCreateTreeView(491, 100, 188, 108)

	For $i = 1 To $aModele[0]
		$iIDTVModele[$i-1] = GUICtrlCreateTreeViewItem(StringTrimRight($aModele[$i], 4), $idSampleMessage)
	Next

	$aRapportsOld = _FileListToArray(@AppDataCommonDir & "\BAO\", "*.bao")
	If @error = 0 Then
		$iNumRapport = $aRapportsOld[0]
	EndIf

	$iIDBoutonVoirOld = GUICtrlCreateButton("Consulter anciens rapports (" & $iNumRapport & ")", 490, 215, 190)
	If $iNumRapport = 0 Then
		GUICtrlSetState(-1, $GUI_DISABLE)
	EndIf

	$iIDBoutonInscMat = GUICtrlCreateButton("Inscrire changements log/mat", 490, 245, 190)
	GUICtrlSetTip(-1, "Enregistre les changements logiciels et matériels dans le rapport")
	GUICtrlCreateLabel("Logiciels installés :", 180, 280)
	GUICtrlSetColor(-1, $COLOR_GREEN)
	GUICtrlCreateLabel("Logiciels désinstallés :", 435, 280)
	GUICtrlSetColor(-1, $COLOR_RED)
	$iIDEditLogInst = GUICtrlCreateEdit("", 180, 300, 245, -183 + ($iFonctions * 30) + $iHauteurFenetre, BitOR($ES_READONLY, $WS_VSCROLL))
	$iIDEditLogDesinst = GUICtrlCreateEdit("", 435, 300, 245, -183 + ($iFonctions * 30) + $iHauteurFenetre, BitOR($ES_READONLY, $WS_VSCROLL))
	_RapportParseur($idListInfosys )
;_UpdEdit($iIDEditLog, $sFileLog)
	_UpdEdit($iIDEditLogInst, $sFileInstallation)
	_UpdEdit($iIDEditLogDesinst, $sFileDesinstallation)
	_UpdEdit($iIDEditInter, $sFileRapport)
Else
	$iIDTABConfig = GUICtrlCreateTabItem("Configuration")
	GUICtrlCreateGroup("Général", 180, 80, 300, 130)
	GUICtrlSetFont (-1, 9, 800)
	 GUICtrlCreateLabel("Nom de votre entreprise :", 190, 105, 130, 25)
	$iCEntreprise =GUICtrlCreateInput($sSociete, 320, 100, 150, 25)
	GUICtrlCreateLabel("Nom du dossier rapport :", 190, 135, 130, 25)
	$iCDossier = GUICtrlCreateInput($sConfigDossierRapport, 320, 130, 150, 25)
	$iCIcones = GUICtrlCreateCheckbox('Ajouter icônes "Ce PC" et "Utilisateur" sur le bureau', 190, 160, 280, 25)
	If $iIcones = 1 Then
		GUICtrlSetState(-1, $GUI_CHECKED)
	EndIf
	$iCRestau = GUICtrlCreateCheckbox('Créer points de restauration automatique', 190, 180, 280, 25)
	If $sRestauration = 1 Then
		GUICtrlSetState(-1, $GUI_CHECKED)
	EndIf
	GUICtrlSetTip(-1, "- Un point de restauration est créé au premier démarrage de BAO" & @CRLF & "- Un point de restauration est créé à la désinstallation de BAO")

	GUICtrlCreateGroup("Bureau Distant", 490, 80, 185, 130)
	GUICtrlSetFont (-1, 9, 800)
	GUICtrlCreateLabel("Bureau Distant", 500, 105, 70, 25)
	$sBD = _ArrayToString($aListBD)
	$iCBD = GUICtrlCreateCombo("", 575, 100, 90, 25)
	GUICtrlSetData(-1, $sBD, $sAgent)
	GUICtrlCreateLabel("Identifiant (pour DWAgent) :", 500, 135, 165, 25)
	$iCIDBD = GUICtrlCreateInput($sMailBD, 500,155, 165, 25)

	GUICtrlCreateGroup("Réglages FTP/SFTP", 180, 220, 300, 260)
	GUICtrlSetFont (-1, 9, 800)
	GUICtrlCreateLabel("Protocole de connexion :", 190, 245, 140, 25)
	$iCProtocole = GUICtrlCreateCombo("SFTP", 330, 240, 140, 25)
	GUICtrlSetData(-1, "FTP", $sFTPProtocol)
	GUICtrlCreateLabel("Adresse :", 190, 275, 140, 25)
	$iCFTPAdresse = GUICtrlCreateInput($sFTPAdresse, 330,265, 140, 25)
	GUICtrlCreateLabel("Port :", 190, 305, 140, 25)
	$iCFTPPort = GUICtrlCreateInput($sFTPPort, 330, 295, 140, 25)
	GUICtrlCreateLabel("Utilisateur :", 190, 335, 140, 25)
	$iCFTPUtilisateur = GUICtrlCreateInput($sFTPUser, 330, 325, 140, 25)
	GUICtrlCreateLabel("Dossier des rapports :", 190, 365, 140, 25)
	$iCFTPRapport = GUICtrlCreateInput($sFTPDossierRapports, 330, 355, 140, 25)
	GUICtrlCreateLabel("Dossier de l'archive SFX :", 190, 395, 140, 25)
	$iCFTPSFX = GUICtrlCreateInput($sFTPDossierSFX, 330, 385, 140, 25)
	GUICtrlCreateLabel("Dossier des fichiers de suivi :", 190, 425, 140, 25)
	$iCFTPSuivi = GUICtrlCreateInput($sFTPDossierSuivi, 330, 415, 140, 25)
	GUICtrlCreateLabel("Dossier supervision :", 190, 455, 140, 25)
	$iCFTPSupervision = GUICtrlCreateInput($sFTPDossierCapture, 330, 445, 140, 25)

	GUICtrlCreateGroup("Désinfection antivirale", 490, 220, 185, 140)
	GUICtrlSetFont (-1, 9, 800)
	$iCDesinfection = GUICtrlCreateEdit(_ArrayToString($aListeProgdes, @CRLF), 500, 240, 165, 110)

	GUICtrlCreateGroup("Liste des techniciens", 490, 370, 185, 110)
	GUICtrlSetFont (-1, 9, 800)
	$iCTechnicien = GUICtrlCreateEdit(_ArrayToString($aListeTech, @CRLF), 500, 390, 165, 80)

	$iCSauvegarde = GUICtrlCreateButton("Sauvegarder les modifications", 340, 485, 200, 25, $BS_DEFPUSHBUTTON)

	$iIDTABStats = GUICtrlCreateTabItem("Recherche et statistiques")
	GUICtrlCreateGroup("Rechercher une intervention", 180, 80, 500, 210)
	GUICtrlSetFont (-1, 9, 800)
	$iIDInputRecherche = GUICtrlCreateInput("", 190, 100, 220, 25)
	$iIDRechercher = GUICtrlCreateButton("Rechercher", 420, 100, 120, 25, $BS_DEFPUSHBUTTON)
	$iIDNouvellesInter = GUICtrlCreateButton("Nouvelles / En cours", 550, 100, 120, 25)
	$iIDListResult = GUICtrlCreateList("", 190, 135, 350, 150)
	$iIDButtonOpen = GUICtrlCreateButton("Ouvrir", 550, 135, 120, 20)
	$iIDButtonModif = GUICtrlCreateButton("Modifer", 550, 160, 120, 20)
	$iIDButtonDupliquer = GUICtrlCreateButton("Dupliquer", 550, 185, 120, 20)
	$iIDButtonNew = GUICtrlCreateButton('Dép. dans "Nouvelle"', 550, 210, 120, 20)
	$iIDButtonSupprimer = GUICtrlCreateButton("Supprimer", 550, 235, 120, 20)
	$iIDButtonRapports = GUICtrlCreateButton("Dossier Rapports", 550, 260, 120, 20)
	GUICtrlSetState($iIDButtonOpen, $GUI_DISABLE)
	GUICtrlSetState($iIDButtonModif, $GUI_DISABLE)
	GUICtrlSetState($iIDButtonDupliquer, $GUI_DISABLE)
	GUICtrlSetState($iIDButtonNew, $GUI_DISABLE)
	GUICtrlSetState($iIDButtonSupprimer, $GUI_DISABLE)

	_RechercherNouvellesInterventions()

	GUICtrlCreateGroup("Statistiques interventions", 180, 300, 500, 205)
	GUICtrlSetFont (-1, 9, 800)
	$iIDLabelNewInt = GUICtrlCreateLabel("", 190, 325, 300, 25)
	$iIDBoutonRaf = GUICtrlCreateButton("Calculer", 570, 315, 100, 25)
	$iIDListStats = GUICtrlCreateListView("Technien|En cours|J|J-1|M|M-1|" & @YEAR & "|" & @YEAR - 1, 190, 350, 480, 145)
	_CalcNouvellesInter()
	;_CalcStats()


EndIf
$iIDTABLogs = GUICtrlCreateTabItem("Logs")
$iIDButtonClear = GUICtrlCreateButton("Effacer les logs", 180, 80)
$iIDEditLog = GUICtrlCreateEdit("", 180, 110, 500, 7 + ($iFonctions * 30) + $iHauteurFenetre, BitOR($ES_READONLY, $WS_VSCROLL))
GUICtrlCreateTabItem("")

If $iModeTech = 0 And $sFTech <> "" Then
	WinSetTitle($hGUIBAO, "", $sSociete & " - Tech " & $sFTech & " - Boîte A Outils (bêta) " & $sVersion)
EndIf

If _FichierCacheExist("Inscription") = 1 Then _ChangerEtatBouton($iIDBoutonInscMat, "Activer")

;_RemplirListInfosys($iIDTABInfossys)

$sSplashTxt = $sSplashTxt & @LF & "Ouverture de BAO"
ControlSetText("Initialisation de BAO (SHIFT = démarrage rapide)", "", "Static1", $sSplashTxt)

GUISetState(@SW_SHOW)

If $bNonPremierDemarrage And $iModeTech =0 Then
	GUICtrlSetState($iIDTABInstall, $GUI_SHOW)
ElseIf $bNonPremierDemarrage And $iModeTech = 1 Then
	GUICtrlSetState($iIDTABStats, $GUI_SHOW)
	_RecupFTP()
EndIf

If $iModeTech = 0 And _FichierCacheExist("Restauration") = 0 Then
	If $sRestauration = 1 Then
		_FileWriteLog($hLog, 'Création point de restauration "' & $sSociete & ' - Debut Intervention"')
		$sSplashTxt = $sSplashTxt & @LF & "Création d'un point de restauration"
		ControlSetText("Initialisation de BAO (SHIFT = démarrage rapide)", "", "Static1", $sSplashTxt)
		_Restauration($sSociete & ' - Debut Intervention')
		_FichierCache("Restauration", 1)
	EndIf
EndIf

Local $stdoutwu, $datawu, $tmpSearch, $sRepDF, $sRepSupBAO

SplashOff()

_UpdEdit($iIDEditLog, $hLog)

While 1
	$iIDAction = GUIGetMsg()
	_UpdateEveryMin()

	if $iIDAction <> 0 Then

		Switch $iIDAction

			Case $iIDCheckboxwu
				If(GUICtrlRead($iIDCheckboxwu) = $GUI_CHECKED) Then
					_FileWriteLog($hLog, 'Arrêt de WU')
					_UpdEdit($iIDEditLog, $hLog)
					RunWait(@ComSpec & ' /c net stop wuauserv & net stop bits & net stop dosvc', '', @SW_HIDE)
					_FichierCache("WUInactif", 1)
				Else
					_FileWriteLog($hLog, 'Démarrage de WU')
					_UpdEdit($iIDEditLog, $hLog)
					RunWait(@ComSpec & ' /c net start wuauserv & net start bits & net start dosvc', '', @SW_HIDE)
					_FichierCache("WUInactif", -1)
				EndIf

			Case $iIDRestau
				_Restauration()

			Case $iIDAutologon

				$sDomaine = RegRead($HKLM & "\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters", "Domain")
				If(GUICtrlRead($iIDAutologon) = $GUI_CHECKED) Then
					_ActivationAutologon($sDomaine)
				ElseIf(GUICtrlRead($iIDAutologon) = $GUI_UNCHECKED) Then
					_DesactivationAutologon($sDomaine)
				EndIf

			Case $GUI_EVENT_CLOSE
				_SaveInter()
				RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce\", "BAO")
				Exit

			Case $iIDButtonQuit
				_SaveInter()
				RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce\", "BAO")
				Exit

			Case $iIDMenu1quitter
				_SaveInter()
				RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce\", "BAO")
				Exit

			Case $iIDMenu1redemarrer
				_Restart()

			Case $iIDMenu1config
				ShellExecuteWait($sConfig)

			Case $iIDMenu1dossier
				Run("explorer.exe " & @ScriptDir)

			Case $iIDMenu1dossierAppdata
				ShellExecute(@LocalAppDataDir & "\bao")

			Case $iIDMenu1dossierRapport
				ShellExecute($sDossierRapport)

			Case $iIDMenu1clearcache

				_FileWriteLog($hLog, 'Suppression du Cache')
				_UpdEdit($iIDEditLog, $hLog)
				_ClearCache()

			Case $iIDMenu1update

				_FileWriteLog($hLog, 'Mise à jour de tous les logiciels')
				_UpdEdit($iIDEditLog, $hLog)
				_UpdateProg()

			Case $iIDMenu1copier

				_CopierSur()

			Case $iIDMenu1sfx

				_CreerSfx()

			Case $iIDMenu1supervision

				_CreerIndexSupervision()

			Case $iIDMenu1modeles
				ShellExecuteWait(@ScriptDir & "\Config\Modeles\")
				WinSetTitle($hGUIBAO, "", $sSociete & " - Boîte A Outils (bêta) " & $sVersion & " - Redémarrage nécessaire *")
				_FileWriteLog($hLog, 'Dossier "Modeles" modifié')

			Case $iIDMenu1reini

				_ReiniBAO()
				_Restart()

			Case $iIDMenu1tech

				_ChangerMode()
				_Restart()

			Case $iIDMenu2ajout

				_CreerIntervention()
				_RechercherNouvellesInterventions()

			Case $iIDMenu2completer

				_CompleterSuivi()
				If GUICtrlRead($iIDInputRecherche) = "" Then
					_RechercherNouvellesInterventions()
				Else
					_RechercherInter(GUICtrlRead($iIDInputRecherche))
				EndIf

			Case $iIDMenu2supp

				_SupprimerSuivi()

			Case $iIDMenu2index

				_CreerIndex()

			Case $iIDMenuAdd
				_MenuAdd()

			Case $iIDMenuAddDoc
				_MenuAddDoc()

			Case $iIDMenuManu
				Run("explorer.exe " & @ScriptDir & "\Logiciels\")
				WinSetTitle($hGUIBAO, "", $sSociete & " - Boîte A Outils (bêta) " & $sVersion & " - Redémarrage nécessaire *")

			Case $sIDVarALLUSERSPROFILE, $sIDVarAPPDATA, $sIDVarLOCALAPPDATA, $sIDVarProgramData, $sIDVarProgramFiles, $sIDVarProgramFiles86, $sIDVarPUBLIC, $sIDVarTEMP, $sIDVarTMP, $sIDVarUSERPROFILE, $sIDVarwindir

				Local $sVarValue = EnvGet(GUICtrlRead($iIDAction, 1))

				If($sVarValue and StringInStr($sVarValue, "\")) Then
					ShellExecute($sVarValue)
				Else
					_Attention("Cette variable d'environnement n'exite pas ou n'est pas un dossier")
				EndIf

			Case $iClientSauvegarde
				If GUICtrlRead($iENomClient) = "" And GUICtrlRead($iESocieteClient) = "" Then
					_Attention("Complétez au moins le nom du client ou la société")
				Else
					$sFNomClient = GUICtrlRead($iENomClient)
					$sFPrenomClient = GUICtrlRead($iEPrenomClient)
					$sFSocieteClient = GUICtrlRead($iESocieteClient)
					$sFAdresse = GUICtrlRead($iEAdresse)
					$sFTel = GUICtrlRead($iETel)
					$sFMail = GUICtrlRead($iEMail)
					$sFMateriel = GUICtrlRead($iEMateriel)
					$sFDescription = GUICtrlRead($iEDescription)
					$sFMDP = GUICtrlRead($iEMdp)
					If $sFTech <> GUICtrlRead($iETechnicien) Then
						$sFTech = GUICtrlRead($iETechnicien)
						WinSetTitle($hGUIBAO, "", $sSociete & " - Tech " & $sFTech & " - Boîte A Outils (bêta) " & $sVersion)
					EndIf
					If _RapportInfosClient($sFileInfosClient, $sFNomClient, $sFPrenomClient, $sFSocieteClient, $sFTech, "", $sFAdresse, $sFTel, $sFMail, $sFMateriel, $sFDescription, "", $sFMDP) Then
						If GUICtrlRead($iClientInterPrint) = $GUI_CHECKED Then
							If GUICtrlRead($iClientInterPrintSelect) = "Imprimante par défaut" Then
								_PrintInter($sFileInfosClient, "printdefault")
							Else
								_PrintInter($sFileInfosClient, "print")
							EndIf
						EndIf
						If StringLeft(@ScriptDir, 2) = "\\" Then
							_ExporterRapport(@ScriptDir & "\Proaxive\" & $sNom & " - " & @ComputerName & " - Rapport intervention.bao")
						EndIf
						_Attention("Informations client sauvegardées")
					Else
						_Attention("Erreur lors de l'enregistrement des informations client")
					EndIf
				EndIf

			Case $iCSauvegarde
				If $sFTPAdresse <> GUICtrlRead($iCFTPAdresse) Then
					If(FileExists(@ScriptDir & '\Cache\Pwd\ftp.sha')) Then
						FileDelete(@ScriptDir & '\Cache\Pwd\ftp.sha')
					EndIf
				EndIf
				If Not($sAgent = GUICtrlRead($iCBD) And $sMailBD = GUICtrlRead($iCIDBD)) Then
					If(FileExists(@ScriptDir & '\Cache\Pwd\dws.sha')) Then
						FileDelete(@ScriptDir & '\Cache\Pwd\dws.sha')
					EndIf
				EndIf
				$sSociete = GUICtrlRead($iCEntreprise)
				$sDossierRapport = GUICtrlRead($iCDossier)
				If GUICtrlRead($iCIcones) = $GUI_CHECKED Then
					$iIcones = 1
				Else
					$iIcones = 0
				EndIf
				If GUICtrlRead($iCRestau) = $GUI_CHECKED Then
					$sRestauration = 1
				Else
					$sRestauration = 0
				EndIf
				$sBD = GUICtrlRead($iCBD)
				$sMailBD = GUICtrlRead($iCIDBD)
				$sFTPProtocol = GUICtrlRead($iCProtocole)
				$sFTPAdresse = GUICtrlRead($iCFTPAdresse)
				$sFTPPort = GUICtrlRead($iCFTPPort)
				$sFTPUser = GUICtrlRead($iCFTPUtilisateur)
				$sFTPDossierRapports = GUICtrlRead($iCFTPRapport)
				$sFTPDossierSFX = GUICtrlRead($iCFTPSFX)
				$sFTPDossierSuivi = GUICtrlRead($iCFTPSuivi)
				$sFTPDossierCapture = GUICtrlRead($iCFTPSupervision)
				$sListeProgdes = StringStripWS(StringReplace(GUICtrlRead($iCDesinfection), @CRLF, " "), 7)
				$sListeTech = StringStripWS(StringReplace(GUICtrlRead($iCTechnicien), @CRLF, " "), 7)
				If _SaveConfig($sSociete, $sDossierRapport, $iIcones, $sRestauration, $sBD, $sMailBD, $sFTPProtocol, $sFTPAdresse, $sFTPPort, $sFTPUser, $sFTPDossierRapports, $sFTPDossierSFX, $sFTPDossierSuivi, $sFTPDossierCapture, $sListeProgdes, $sListeTech) Then
					_Attention("Configuration sauvegardée, BAO va être redémarré")
					_FileWriteLog($hLog, '"config.ini" modifié')
					_Restart()
				Else
					_FileWriteLog($hLog, 'Le fichier "config.ini" n' & "'" & 'a pas pu être modifié')
				EndIf

			Case $iIDRechercher
				If GUICtrlRead($iIDInputRecherche) = "" Then
					_Attention("Merci de saisir un mot pour la recherche")
				Else
					$bResultSearch = _RechercherInter(GUICtrlRead($iIDInputRecherche))

					If Not $bResultSearch Then
						_Attention('Aucun fichier trouvé contenant "' & GUICtrlRead($iIDInputRecherche) & '"')
					EndIf
				EndIf

			Case $iIDNouvellesInter
				_RechercherNouvellesInterventions()

			Case $iIDButtonOpen
				If FileExists(@ScriptDir & "\Rapports\" & (GUICtrlRead($iIDListResult))) Then
					ShellExecute(@ScriptDir & "\Rapports\" & (GUICtrlRead($iIDListResult)))
				EndIf

			Case $iIDButtonModif
				If _CreerIntervention(@ScriptDir & "\Rapports\" & (GUICtrlRead($iIDListResult)), True) Then
					If GUICtrlRead($iIDInputRecherche) = "" Then
						_RechercherNouvellesInterventions()
					Else
						_RechercherInter(GUICtrlRead($iIDInputRecherche))
					EndIf
				EndIf

			Case $iIDButtonSupprimer
				If FileExists(@ScriptDir & "\Rapports\" & (GUICtrlRead($iIDListResult))) Then
					$sRepSupBAO = MsgBox($MB_YESNO, "Suppression ...", 'Etes vous sûr de vouloir supprimer le fichier "' & GUICtrlRead($iIDListResult) & '" ?')
					If ($sRepSupBAO = 6) Then
						FileDelete(@ScriptDir & "\Rapports\" & (GUICtrlRead($iIDListResult)))
					EndIf
					If GUICtrlRead($iIDInputRecherche) = "" Then
						_RechercherNouvellesInterventions()
					Else
						_RechercherInter(GUICtrlRead($iIDInputRecherche))
					EndIf
				EndIf

			Case $iIDButtonDupliquer
				If FileExists(@ScriptDir & "\Rapports\" & (GUICtrlRead($iIDListResult))) Then
					If _CreerIntervention(@ScriptDir & "\Rapports\" & (GUICtrlRead($iIDListResult))) Then
						_RechercherNouvellesInterventions()
					EndIf
				EndIf

			Case $iIDButtonNew
				If FileExists(@ScriptDir & "\Rapports\" & (GUICtrlRead($iIDListResult))) Then
					If _DeplacerIntervention(@ScriptDir & "\Rapports\" & (GUICtrlRead($iIDListResult)), @ScriptDir & "\Rapports\Nouvelle\") Then
						_RechercherNouvellesInterventions()
					EndIf
				EndIf

			Case $iIDButtonRapports
				Run("explorer.exe " & @ScriptDir & "\Rapports\")

			Case $iIDListResult
				If GUICtrlRead($iIDListResult) = "" Then
					GUICtrlSetState($iIDButtonOpen, $GUI_DISABLE)
					GUICtrlSetState($iIDButtonModif, $GUI_DISABLE)
					GUICtrlSetState($iIDButtonDupliquer, $GUI_DISABLE)
					GUICtrlSetState($iIDButtonNew, $GUI_DISABLE)
					GUICtrlSetState($iIDButtonSupprimer, $GUI_DISABLE)
				ElseIf StringLeft(GUICtrlRead($iIDListResult), 8) <> "Nouvelle" And StringLeft(GUICtrlRead($iIDListResult), 8) <> "En cours" Then
					GUICtrlSetState($iIDButtonOpen, $GUI_ENABLE)
					GUICtrlSetState($iIDButtonModif, $GUI_DISABLE)
					GUICtrlSetState($iIDButtonDupliquer, $GUI_ENABLE)
					GUICtrlSetState($iIDButtonNew, $GUI_ENABLE)
					GUICtrlSetState($iIDButtonSupprimer, $GUI_ENABLE)
				Else
					GUICtrlSetState($iIDButtonOpen, $GUI_ENABLE)
					GUICtrlSetState($iIDButtonModif, $GUI_ENABLE)
					GUICtrlSetState($iIDButtonDupliquer, $GUI_ENABLE)
					GUICtrlSetState($iIDButtonNew, $GUI_DISABLE)
					GUICtrlSetState($iIDButtonSupprimer, $GUI_ENABLE)
				EndIf

			Case $iIDBoutonRaf
				_CalcStats()

			Case $iIDTAB
				_SaveInter()
				If GUICtrlRead($iIDTAB, 1) = $iIDTABInstall Then
					_CalculProgDesinstallation()
					_UpdEdit($iIDEditLogDesinst, $sFileDesinstallation)
				EndIf

			Case $iIDTVModele[0] To $iIDTVModele[$aModele[0] - 1]
				_SaveInter()
				_GetModele(GUICtrlRead($idSampleMessage, 1))

			Case $iIDBoutonInscMat
				_SaveChangeToInter()

			Case $iIDBoutonVoirOld
				ShellExecute(@AppDataCommonDir & "\BAO\")

			Case $iIDButtonClear
				FileClose($hLog)
				FileDelete($sFileLog)
				FileOpen($sFileLog, 1)
				_UpdEdit($iIDEditLog, $hLog)

			Case $iIDButtonBureaudistant

				_BureauDistant()

			Case $iIDButtonSupervision

				_Supervision()

			Case $iIDButtonInstallation

				_InstallationAutomatique()

			Case $iIDButtonSauvegarde

				_SauvegardeAutomatique()

			Case $iIDButtonWU

				_MiseAJourOS()

			Case $iIDButtonPilotes

				_InstallationPilotes()

			Case $iIDButtonStabilite

				_TestsStabilite()

			Case $iIDButtonScripts

				_Scripts()

			Case $iIDButtonNettoyage

				_Nettoyage()
				GUICtrlSetState($iIDTABInstall, $GUI_SHOW)

			Case $iIDButtonNettoyage + 1 to $iIDButtonResetBrowser -1 ; Désinfection

				_NettoyageProg($aButtonDes)

			Case $iIDButtonResetBrowser

				_ResetBrowser()

			Case $iIDButtonEnvoi

				_ExporterRapport()

			Case $iPremElement To $iDernElement

				If ($aMenuID[$iIDAction])[0] = "Open" Then
					ShellExecuteWait(@ScriptDir & "\Logiciels\" & ($aMenuID[$iIDAction])[1])
					WinSetTitle($hGUIBAO, "", $sSociete & " - Boîte A Outils (bêta) " & $sVersion & " - Redémarrage nécessaire *")
				ElseIf ($aMenuID[$iIDAction])[0] = "Rename" Then
					$sRepDF = InputBox("Renommer le dossier " & StringTrimRight(($aMenuID[$iIDAction])[1], 4), 'Choisissez un nouveau nom pour "' & StringTrimRight(($aMenuID[$iIDAction])[1], 4) & '" :')
					If $sRepDF <> "" Then
						If FileExists(@ScriptDir & "\Logiciels\" & $sRepDF & ".ini") = 0 Then
							If FileMove(@ScriptDir & "\Logiciels\" & ($aMenuID[$iIDAction])[1], @ScriptDir & "\Logiciels\" & $sRepDF & ".ini") Then
								_FileWriteLog($hLog, 'Le fichier "' & ($aMenuID[$iIDAction])[1] & '" a été renommé en "' & $sRepDF & '.ini"')
								WinSetTitle($hGUIBAO, "", $sSociete & " - Boîte A Outils (bêta) " & $sVersion & " - Redémarrage nécessaire *")
							Else
								_Attention("Le dossier n'a pas pu être renommé")
							EndIf
						Else
							_Attention('Le dossier "' & $sRepDF & '" existe déjà')
						EndIf
					Else
						_Attention("Erreur : Merci de rentrer un nom")
					EndIf
				ElseIf ($aMenuID[$iIDAction])[0] = "Delete" Then
					$sRepDF = MsgBox($MB_YESNO, "Suppression ...", 'Etes vous sûr de vouloir supprimer le dossier "' & StringTrimRight(($aMenuID[$iIDAction])[1], 4) & '" ainsi que son contenu ?')
					If ($sRepDF = 6) Then
						FileDelete(@ScriptDir & "\Logiciels\" & ($aMenuID[$iIDAction])[1])
						WinSetTitle($hGUIBAO, "", $sSociete & " - Boîte A Outils (bêta) " & $sVersion & " - Redémarrage nécessaire *")
					EndIf
				Else
					If $iModeTech = 1 And ($aMenuID[$iIDAction])[11] <> -1 Then
						If _IsPressed("10", $hDLL) Then
							_ExecuteProg()
						Else
							_MenuMod($aMenuID[$iIDAction])
						EndIf
					Else
						_ExecuteProg()
					EndIf
				EndIf

			Case $iIDButtonUninstall

				_DesinstallerBAO()

			Case $sIDHelp

				ShellExecute("https://boiteaoutils.xyz")

			Case $sIDapropos

				_APropos()

		EndSwitch
	EndIf
WEnd