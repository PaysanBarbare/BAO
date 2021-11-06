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

Global $sVersion = "1.0.1" ; 06/11/21

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

Local $sDossierRapport, $sNom, $bNonPremierDemarrage = False, $sRetourInfo, $iFreeSpace, $sDem, $iIDAutologon, $sListeProgrammes = @LocalAppDataDir & "\bao\ListeProgrammes.txt", $sOSv, $sSubKey, $sMdps, $sAutoUser
Global $hGUIBAO, $iLabelPC, $aResults[], $sInfos, $statusbar, $statusbarprogress, $iIDCancelDL, $sProgrun, $sProgrunUNC, $iPidt[], $iIDAction, $aMenu[], $aMenuID[], $sNomDesinstalleur, $sPrivazer, $sListeProgdes, $aButtonDes[], $iIDEditRapport, $iIDEditLog, $iIDEditLogInst, $iIDEditLogDesinst, $iIDEditInter, $HKLM, $envChoco = @AppDataCommonDir & "\Chocolatey\", $sRestauration, $sPWDZip, $aListeAvSupp, $releaseid, $idListInfosys, $aProaxiveDelele, $sSociete, $iIDBoutonInscMat, $bActiv = 2, $iAutoAdmin

; déclaration des fichiers rapport
Global $hLog, $sFileLog
Global $hEntete, $sFileEntete
Global $hInfosys, $sFileInfosys
Global $hInfosysupd, $sFileInfosysupd
Global $hInstallation, $sFileInstallation
Global $hDesinstallation, $sFileDesinstallation
Global $hRapport, $sFileRapport
Global $sNomFichierRapport

; Création des fichiers logs et rapport temporaires
$sFileLog = @LocalAppDataDir & "\bao\logs.txt"
$sFileEntete = @LocalAppDataDir & "\bao\entete.bao"
$sFileInfosys = @LocalAppDataDir & "\bao\infosys.bao"
$sFileInfosysupd = @LocalAppDataDir & "\bao\infosysupd.bao"
$sFileInstallation = @LocalAppDataDir & "\bao\install.bao"
$sFileDesinstallation = @LocalAppDataDir & "\bao\uninstall.bao"
$sFileRapport = @LocalAppDataDir & "\bao\rapport.bao"

$hLog = FileOpen($sFileLog, 9)

If @OSArch = "X64" Then
    $HKLM = "HKLM64"
Else
    $HKLM = "HKLM"
EndIf

; Si BAO est sur un partage, création d'un lecteur réseau (créé par run.bat)
;~ If(StringInStr(@ScriptDir, "\\")) Then ;UNC
;~ 	@ScriptDir = DriveMapAdd("*", @ScriptDir)
;~ EndIf

; Création du raccourci sur le bureau
;$sDriveMap = DriveMapGet(StringLeft(@ScriptDir, 2))
Local $sSplashTxt = "Patientez pendant l'initialisation de BAO"
Local $iSplashWidth = 300
Local $iSplashHeigh = 160
Local $iSplashX = @DesktopWidth - 400
Local $iSplashY = @DesktopHeight - 250
Local $iSplashOpt = 21
Local $iSplashFontSize = 10

SplashTextOn("", $sSplashTxt, $iSplashWidth, $iSplashHeigh, $iSplashX, $iSplashY, $iSplashOpt, "", $iSplashFontSize)

If(FileExists(@DesktopDir & "\BAO.lnk") = 0) Then
	$sSplashTxt = $sSplashTxt & @LF & "Création du raccourci sur le bureau"
	SplashTextOn("", $sSplashTxt, $iSplashWidth, $iSplashHeigh, $iSplashX, $iSplashY, $iSplashOpt, "", $iSplashFontSize)
	Sleep(2000)
	FileCreateShortcut(@ScriptDir & '\run.bat', @DesktopDir & "\BAO.lnk", "", "", "Boîte à Outils", @ScriptDir & "\Outils\bao.ico")
EndIf

$sSplashTxt = $sSplashTxt & @LF & "Chargement des dépendances"
SplashTextOn("", $sSplashTxt, $iSplashWidth, $iSplashHeigh, $iSplashX, $iSplashY, $iSplashOpt, "", $iSplashFontSize)

Const $sConfig = @ScriptDir & "\config.ini"

#include "UDF\_BureauDistant.au3"
#include "UDF\_Desinfection.au3"
#include "UDF\_Desinstallation.au3"
#include "UDF\_FTP.au3"
#include "UDF\_Infosys.au3"
#include "UDF\_Installation.au3"
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
#include "UDF\_Suivi.au3"
#include "UDF\_Telechargement.au3"

; Désactivation de la mise en veille https://www.autoitscript.com/forum/topic/152381-screensaver-sleep-lock-and-power-save-disabling/

$sSplashTxt = $sSplashTxt & @LF & "Désactivation de la mise en veille"
SplashTextOn("", $sSplashTxt, $iSplashWidth, $iSplashHeigh, $iSplashX, $iSplashY, $iSplashOpt, "", $iSplashFontSize)

_PowerKeepAlive()

; Lancement des fonctions à la fermeture
OnAutoItExitRegister("_PowerResetState")
OnAutoItExitRegister("_ProcessExit")
;OnAutoItExitRegister("_DriveMapDel")
;OnAutoItExitRegister("_StartWU")

$sSplashTxt = $sSplashTxt & @LF & "Lecture du fichier de configuration"
SplashTextOn("", $sSplashTxt, $iSplashWidth, $iSplashHeigh, $iSplashX, $iSplashY, $iSplashOpt, "", $iSplashFontSize)

_InitialisationBAO($sConfig)

; Création du dossier rapport et du fichier rapport d'intervention

$sSociete = IniRead($sConfig, "Parametrages", "Societe", "NomSociete")

$sDossierRapport = @DesktopDir & "\" & IniRead($sConfig, "Parametrages", "Dossier", "Rapports")
If DirCreate($sDossierRapport) = 0 Then	_Erreur("Impossible de créer le dossier '" & $sDossierRapport & "' sur le bureau")

; intialisation des variables FTP
Local $sFTPAdresse = IniRead($sConfig, "FTP", "Adresse", "")
Local $sFTPUser = IniRead($sConfig, "FTP", "Utilisateur", "")
Local $sFTPPort = IniRead($sConfig, "FTP", "Port", "")
Local $sFTPDossierSuivi = IniRead($sConfig, "FTP", "DossierSuivi", "")
Local $sFTPDossierRapports = IniRead($sConfig, "FTP", "DossierRapports", "")

_CalculFS()

$sSplashTxt = $sSplashTxt & @LF & "Vérification version et licence Windows"
SplashTextOn("", $sSplashTxt, $iSplashWidth, $iSplashHeigh, $iSplashX, $iSplashY, $iSplashOpt, "", $iSplashFontSize)

If(@OSVersion = "WIN_7") Then
	$releaseid = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\", "CSDVersion")
ElseIf(@OSVersion = "WIN_10") Then
	$releaseid = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\", "ReleaseId")
	If $releaseid = "2009" Then
		$releaseid = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\", "DisplayVersion")
	EndIf
EndIf

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
		$sOSv = $sOSv & " (activé)";
		$bActiv = 1
	EndIf
Next

If $bActiv = 2 Then
	$sOSv = $sOSv & " (non activé)";
EndIf

if(_FichierCacheExist("Client") = 0) Then

	If($sFTPAdresse <> "" And $sFTPUser <> "" And $sFTPDossierSuivi) Then
		_FichierCache("Suivi", 1)
	EndIf

	$sNom = _PremierLancement($sFTPAdresse, $sFTPUser, $sFTPPort, $sFTPDossierRapports)
Else
	$bNonPremierDemarrage = True
	$sNom = _FichierCache("Client")
	$sSplashTxt = $sSplashTxt & @LF & "Recherche des modifications sur le matériel"
	SplashTextOn("", $sSplashTxt, $iSplashWidth, $iSplashHeigh, $iSplashX, $iSplashY, $iSplashOpt, "", $iSplashFontSize)
	_GetInfoSysteme()
;~ 	If FileGetPos($hFichierRapport) = 0 Then
;~ 		_RapportInfos($bActiv)
;~ 	EndIf
EndIf

If(FileExists(@ScriptDir & "\Logiciels\") = 0) Then _Erreur('Dossier "Logiciels" manquant')

; initialisation désinfection
$sListeProgdes = _StringExplode(IniRead($sConfig, "Desinfection", "Programmes de desinfection", "Privazer RogueKiller AdwCleaner MalwareByte ZHPCleaner"), " ")

If(FileExists($sListeProgrammes)) Then
	_FileReadToArray($sListeProgrammes, $aListeAvSupp, 0)
Else
	$aListeAvSupp = _ListeProgrammes()
	$aListeAvSupp =  _ArrayUnique($aListeAvSupp, 0, 0, 0, 0)
	_FileWriteFromArray($sListeProgrammes, $aListeAvSupp)
EndIf

; Déclaration des boutons de fonctions (pour calculer la taille de la fenêtre BAO)
Local $iIDButtonBureaudistant
Local $iIDButtonInstallation
Local $iIDButtonSauvegarde
Local $iIDButtonWU
Local $iIDButtonPilotes
Local $iIDButtonStabilite
Local $iIDButtonScripts

; Soit :
Local $iFonctions = 7

$hGUIBAO = GUICreate($sSociete & " - Boîte A Outils (bêta) " & $sVersion, 860, 210 + ($iFonctions * 30) + UBound($sListeProgdes) * 25)

$statusbar = GUICtrlCreateLabel("", 10, 135 + ($iFonctions * 30) + UBound($sListeProgdes) * 25, 410, 20, $SS_CENTERIMAGE)
$statusbarprogress = GUICtrlCreateProgress(440, 135 + ($iFonctions * 30) + UBound($sListeProgdes) * 25, 250, 20)
$iIDCancelDL = GUICtrlCreateButton("Passer / Annuler", 700, 135 + ($iFonctions * 30) + UBound($sListeProgdes) * 25, 150, 20)
GUICtrlSetState($iIDCancelDL, $GUI_DISABLE)
GUICtrlSetFont($statusbar, 11)

Local $iIDMenu1clearcache, $iIDMenu1update, $iIDMenu1copier, $iIDMenu1sfx, $iIDMenu2index

Local $iIDMenu1 = GUICtrlCreateMenu("&Configuration")
Local $iIDMenu1config = GUICtrlCreateMenuItem("Editer config.ini", $iIDMenu1)
Local $iIDMenu1dossierRapport = GUICtrlCreateMenuItem("Ouvrir dossier Rapport", $iIDMenu1)
Local $iIDMenu1dossier = GUICtrlCreateMenuItem("Ouvrir dossier du programme", $iIDMenu1)
Local $iIDMenu1dossierAppdata = GUICtrlCreateMenuItem("Ouvrir dossier AppData", $iIDMenu1)
Local $iIDMenu1reini = GUICtrlCreateMenuItem("Reinitialiser BAO", $iIDMenu1)
Local $iIDMenu1tech = GUICtrlCreateMenuItem("Passer en mode Tech/Client", $iIDMenu1)

If(StringLeft($sNom, 4) = "Tech") Then
	GUICtrlCreateMenuItem("", $iIDMenu1)
	$iIDMenu1clearcache = GUICtrlCreateMenuItem("Effacer le cache installation", $iIDMenu1)
	$iIDMenu1update = GUICtrlCreateMenuItem("Tout mettre à jour", $iIDMenu1)
	$iIDMenu1copier = GUICtrlCreateMenuItem("Copier BAO sur support externe", $iIDMenu1)
	$iIDMenu1sfx = GUICtrlCreateMenuItem("Créer archive SFX", $iIDMenu1)
EndIf
GUICtrlCreateMenuItem("", $iIDMenu1)

Local $iIDMenu1redemarrer = GUICtrlCreateMenuItem("Redémarrer BAO", $iIDMenu1)
Local $iIDMenu1quitter = GUICtrlCreateMenuItem("Quitter", $iIDMenu1)

Local $iIDMenu2 = GUICtrlCreateMenu("&Suivi")
Local $iIDMenu2ajout = GUICtrlCreateMenuItem("Nouveau code de suivi", $iIDMenu2)
Local $iIDMenu2completer = GUICtrlCreateMenuItem("Ajouter une information de suivi", $iIDMenu2)

Local $iIDMenu2supp
If(StringLeft($sNom, 4) <> "Tech") Then
	$iIDMenu2supp = GUICtrlCreateMenuItem("Supprimer l'association", $iIDMenu2)
Else
	$iIDMenu2supp = GUICtrlCreateMenuItem("Supprimer un code de suivi", $iIDMenu2)
EndIf

If(StringLeft($sNom, 4) = "Tech") Then
	$iIDMenu2index = GUICtrlCreateMenuItem("Créer index.php sur le serveur FTP", $iIDMenu2)
EndIf

If(_FichierCacheExist("Suivi") = 0) Then
	GUICtrlSetState($iIDMenu2, $GUI_DISABLE)
EndIf

Local $aDoc = _FileListToArrayRec(@ScriptDir & "\Logiciels\", "*.ini", 1, 0, 1)
Local $sHeure, $iMin = @MIN
Local $i, $j, $iPremElement, $iDernElement, $x = 70

Local $iIDMenuLog = GUICtrlCreateMenu("Logiciels")

$iPremElement = $iIDMenuLog + 1
Local $aTemp, $iIDMenuDoc, $aTempLog[12], $sNomLog, $aShortcut, $aLogMenu, $sIDSM, $iToDel, $iToOpen, $iToRen

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
			$aTempLog[11] = $aDoc[$i]

			; Construction de deux Maps (un trié par nom et l'autre par ID menu
			$aMenu[$sNomLog] = $aTempLog
			$aMenuID[$sIDSM] = $aTempLog

			If $aTempLog[7] = 1 Then
				$sIDSM = GUICtrlCreateButton($sNomLog, 700, $x, 150, 25)
				$x = $x + 25
				$aTempLog[11] = -1
				$aMenuID[$sIDSM] = $aTempLog
			EndIf

		Next
 	EndIf
	If(StringLeft($sNom, 4) = "Tech") Then
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

If(StringLeft($sNom, 4) = "Tech") Then
	GUICtrlCreateMenuItem("", $iIDMenuLog)
	$iIDMenuAdd = GUICtrlCreateMenuItem("Ajouter un lien/logiciel", $iIDMenuLog)
	$iIDMenuAddDoc = GUICtrlCreateMenuItem("Ajouter un dossier", $iIDMenuLog)
	$iIDMenuManu = GUICtrlCreateMenuItem("Modifier manuellement", $iIDMenuLog)
	$iDernElement = $iIDMenuManu
Else
	GUICtrlCreateDummy()
	GUICtrlCreateDummy()
	GUICtrlCreateDummy()
	$iDernElement = GUICtrlCreateDummy()
EndIf



Local $iIDMenuVar = GUICtrlCreateMenu("Var. env.")
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
Local $iIDMenuHelp = GUICtrlCreateMenu("?")
Local $sIDHelp = GUICtrlCreateMenuItem("Aide", $iIDMenuHelp)
Local $sIDapropos = GUICtrlCreateMenuItem("A propos", $iIDMenuHelp)

Local $sYear = @YEAR
Local $sMon = @MON
Local $sDay = @MDAY
$sHeure = GUICtrlCreateLabel(@MDAY &"/"& @MON &"/"& @YEAR &" - "& @HOUR &":"& @MIN , 10, 164 + ($iFonctions * 30) + UBound($sListeProgdes) * 25)

;If(_IsInternetConnected() = 1) Then
Run(@ComSpec & ' /C w32tm /resync', "", @SW_HIDE)
;EndIf

Local $iIDCheckboxwu = GUICtrlCreateCheckbox("Désactiver Windows Update", 350, 160 + ($iFonctions * 30) + UBound($sListeProgdes) * 25)
If(_FichierCacheExist("WUInactif") = 1) Then
	GUICtrlSetState(-1, $GUI_CHECKED)
EndIf

Local $iIDRestau = GUICtrlCreateButton("Créer un point de restauration", 130, 160 + ($iFonctions * 30) + UBound($sListeProgdes) * 25, 190, 20)

If(StringLeft($sNom, 4) <> "Tech") Then
	_UACDisable()
	; Activation de BAO au démarrage
	RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce","BAO","REG_SZ",'"' & @DesktopDir & '\BAO.lnk"')

	If _FichierCacheExist("Autologon") = 1 Then
		$iIDAutologon = GUICtrlCreateCheckbox("Autologon", 530, 160 + ($iFonctions * 30) + UBound($sListeProgdes) * 25)
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
	_RecupFTP($sFTPAdresse, $sFTPUser, $sFTPPort, $sFTPDossierRapports)
EndIf

Local $iIDespacelibre = GUICtrlCreateLabel(@HomeDrive & " " & $iFreeSpace & " Go libre", 620, 164 + ($iFonctions * 30) + UBound($sListeProgdes) * 25)
Local $aMemStats = MemGetStats()
Local $iIDRAMlibre = GUICtrlCreateLabel("RAM : " & $aMemStats[$MEM_LOAD] & '% utilisée', 720, 164 + ($iFonctions * 30) + UBound($sListeProgdes) * 25)


GUICtrlSetFont($iLabelPC, 18)

Local $sDate = _FichierCache("PremierLancement")
GUICtrlCreateLabel("Nom du PC : " & @ComputerName, 450, 2)
GUICtrlCreateLabel("OS : " & $sOSv, 450, 18, 400)
If($bActiv = 2) Then
	GUICtrlSetColor(-1, $COLOR_RED)
Else
	GUICtrlSetColor(-1, $COLOR_GREEN)
EndIf
GUICtrlSetFont(-1, Default, 600)
GUICtrlCreateLabel("Début : " & $sDate, 450, 34, 200, 15)
GUICtrlSetFont(-1, Default, 600)


$iIDButtonBureaudistant = GUICtrlCreateButton("Bureau distant", 10, 50, 150, 25)
$iIDButtonInstallation = GUICtrlCreateButton("Installation", 10, 80, 150, 25)
$iIDButtonSauvegarde = GUICtrlCreateButton("Sauvegarde et restauration", 10, 110, 150, 25)
$iIDButtonWU = GUICtrlCreateButton("Windows et Office", 10, 140, 150, 25)
$iIDButtonPilotes = GUICtrlCreateButton("Pilotes", 10, 170, 150, 25)
$iIDButtonStabilite = GUICtrlCreateButton("Centre de contrôles", 10, 200, 150, 25)
$iIDButtonScripts = GUICtrlCreateButton("Scripts et outils", 10, 230, 150, 25)

Local $y = 70 + ($iFonctions * 30)
Local $pgroup = $y-20

Local $iIDButtonNettoyage = GUICtrlCreateButton("1 - Désinstallation", 10, $y, 150, 25)
If(_FichierCacheExist("Desinfection") = 1) Then
	_ChangerEtatBouton($iIDButtonNettoyage, "Activer")
EndIf

$y = $y + 25
Local $z
Local $iIDMenuDes, $iLargeur

For $z = 1 To UBound($sListeProgdes)
	If FileExists(@ScriptDir & "\Config\" & $sListeProgdes[$z - 1] & "\" & $sListeProgdes[$z - 1] & ".bat") Then
		$iLargeur = 125
		GUICtrlCreateButton("X", 135, $y, 25, 25)
	Else
		$iLargeur = 150
	EndIf
	$iIDMenuDes = GUICtrlCreateButton($z + 1 & " - " & $sListeProgdes[$z - 1], 10, $y, $iLargeur, 25)
	$aButtonDes[$iIDMenuDes] = $sListeProgdes[$z - 1]

	If(_FichierCacheExist($sListeProgdes[$z - 1]) = 1) Then
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

If _FichierCacheExist("Envoi") = 1 Then	_ChangerEtatBouton($iIDButtonEnvoi, "Activer")

If _FichierCacheExist("WU") = 1 Then _ChangerEtatBouton($iIDButtonWU, "Activer")

If _FichierCacheExist("Installation") = 1 Then _ChangerEtatBouton($iIDButtonInstallation, "Activer")

If _FichierCacheExist("Stabilite") = 1 Then _ChangerEtatBouton($iIDButtonStabilite, "Activer")

If _FichierCacheExist("StabiliteTime") = 1 Then
	_ResultatStabilite()
	_FichierCache("StabiliteTime", -1)
EndIf

Local $iIDTAB = GUICtrlCreateTab(170, 50, 520, 77 + ($iFonctions * 30) + UBound($sListeProgdes) * 25)
Local $iIDTABInfossys = GUICtrlCreateTabItem("Infos système")
$idListInfosys = GUICtrlCreateListView("Nom |Valeur ", 180, 80, 500, 37 + ($iFonctions * 30) + UBound($sListeProgdes) * 25)
_GUICtrlListView_SetColumnWidth($idListInfosys, 0, 130)
_GUICtrlListView_SetColumnWidth($idListInfosys, 1, 360)
Local $iIDTABInstall = GUICtrlCreateTabItem("Intervention")
$iIDEditInter = GUICtrlCreateEdit("", 180, 80, 300, 190)
GUICtrlCreateGroup("Modèles", 490, 80, 190, 130)
Local $idSampleMessage = GUICtrlCreateTreeView(490, 100, 170, 90)
Local $aModele = _FileListToArray(@ScriptDir & '\Config\Modeles\', "*.txt")
Local $iIDTVModele[$aModele[0]]
For $i = 1 To $aModele[0]
	$iIDTVModele[$i-1] = GUICtrlCreateTreeViewItem(StringTrimRight($aModele[$i], 4), $idSampleMessage)
Next
Local $iNumRapport = 0, $iIDBoutonVoirOld
Local $aRapportsOld = _FileListToArray(@AppDataCommonDir & "\BAO\", "*.bao")
If @error = 0 Then
	$iNumRapport = $aRapportsOld[0]
Else
	$iNumRapport = 0
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
$iIDEditLogInst = GUICtrlCreateEdit("", 180, 300, 245, -183 + ($iFonctions * 30) + UBound($sListeProgdes) * 25, BitOR($ES_READONLY, $WS_VSCROLL))
$iIDEditLogDesinst = GUICtrlCreateEdit("", 435, 300, 245, -183 + ($iFonctions * 30) + UBound($sListeProgdes) * 25, BitOR($ES_READONLY, $WS_VSCROLL))
Local $iIDTABLogs = GUICtrlCreateTabItem("Logs")
Local $iIDButtonClear = GUICtrlCreateButton("Effacer les logs", 180, 80)
$iIDEditLog = GUICtrlCreateEdit("", 180, 110, 500, 7 + ($iFonctions * 30) + UBound($sListeProgdes) * 25, BitOR($ES_READONLY, $WS_VSCROLL))
GUICtrlCreateTabItem("")

If _FichierCacheExist("Inscription") = 1 Then _ChangerEtatBouton($iIDBoutonInscMat, "Activer")

_RapportParseur($idListInfosys )
;_UpdEdit($iIDEditLog, $sFileLog)
_UpdEdit($iIDEditLogInst, $sFileInstallation)
_UpdEdit($iIDEditLogDesinst, $sFileDesinstallation)
_UpdEdit($iIDEditInter, $sFileRapport)

;_RemplirListInfosys($iIDTABInfossys)

$sSplashTxt = $sSplashTxt & @LF & "Ouverture de BAO"
SplashTextOn("", $sSplashTxt, $iSplashWidth, $iSplashHeigh, $iSplashX, $iSplashY, $iSplashOpt, "", $iSplashFontSize)

GUISetState(@SW_SHOW)

If $bNonPremierDemarrage Then
	GUICtrlSetState($iIDTABInstall, $GUI_SHOW)
EndIf

If _FichierCacheExist("Restauration") = 0 Then

	$sRestauration = IniRead($sConfig, "Parametrages", "Restauration", 0)
	If $sRestauration = 1 Then
		_FileWriteLog($hLog, 'Création point de restauration "' & $sSociete & ' - Debut Intervention"')
		$sSplashTxt = $sSplashTxt & @LF & "Création d'un point de restauration"
		SplashTextOn("", $sSplashTxt, $iSplashWidth, $iSplashHeigh, $iSplashX, $iSplashY, $iSplashOpt, "", $iSplashFontSize)
		_Restauration($sSociete & ' - Debut Intervention')
		_FichierCache("Restauration", 1)
	EndIf
EndIf

Local $stdoutwu, $datawu, $iFreeSpacech, $tmpSearch, $sRepDF

SplashOff()

_UpdEdit($iIDEditLog, $hLog)

While 1
	$iIDAction = GUIGetMsg()
	If @MIN > $iMin Then

		GUICtrlSetData ($sHeure, @MDAY &"/"& @MON &"/"& @YEAR &" - "& @HOUR &":"& @MIN)
		$iMin = @MIN

		If Not($sYear = @YEAR And $sMon = @MON And $sDay = @MDAY) Then
			_FileWriteLog($hLog, "Correction automatique de l'heure")
			_UpdEdit($iIDEditLog, $hLog)
			_Attention("L'horloge a été resynchronisée, vérifiez la pile de BIOS", 1)
			$sYear = @YEAR
			$sMon = @MON
			$sDay = @MDAY
		EndIf

		If(GUICtrlRead($iIDCheckboxwu) = $GUI_CHECKED) Then
			Run(@ComSpec & ' /c net stop wuauserv & net stop bits & net stop dosvc', '', @SW_HIDE)
		EndIf

		$iFreeSpacech = Round(DriveSpaceFree(@HomeDrive & "\") / 1024, 2)
		If($iFreeSpacech <> $iFreeSpace) Then
			GUICtrlSetData($iIDespacelibre, @HomeDrive & " " & $iFreeSpacech & " Go libre")
			$iFreeSpace = $iFreeSpacech
		EndIf

		$aMemStats = MemGetStats()
		GUICtrlSetData($iIDRAMlibre, "RAM : " & $aMemStats[$MEM_LOAD] & '% utilisée')

	EndIf

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

				Local $sDomaine
				If(GUICtrlRead($iIDAutologon) = $GUI_CHECKED) Then
					_FileWriteLog($hLog, 'Activation Autologon')
					_UpdEdit($iIDEditLog, $hLog)
					$sSubKey = RegEnumKey("HKEY_USERS\.DEFAULT\Software\Microsoft\IdentityCRL\StoredIdentities", 1)
					If $sSubKey = "" Then
						$sAutoUser = @UserName
					Else
						$sAutoUser = "MicrosoftAccount\" & $sSubKey
					EndIf

					$sMdps = InputBox("Mot de passe de session", "Entrez votre mot de passe de session pour" & @CRLF & '"' & $sAutoUser & '"', "", "*")

					If $sMdps <> "" Then
						$sDomaine = RegRead($HKLM & "\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters", "Domain")
						RegWrite($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","AutoAdminLogon","REG_SZ", 1)
						RegWrite($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","DefaultUserName","REG_SZ", @UserName)
						RegWrite($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","DefaultPassword","REG_SZ", $sMdps)
						If($sDomaine <> "") Then
							RegWrite($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","DefaultDomain","REG_SZ", $sDomaine)
						EndIf
						_FichierCache("Autologon", 1)
					Else
						GUICtrlSetState($iIDAutologon, $GUI_UNCHECKED)
						_FichierCache("Autologon", 2)
					EndIf
				ElseIf(GUICtrlRead($iIDAutologon) = $GUI_UNCHECKED) Then
					_FileWriteLog($hLog, 'Désactivation Autologon')
					$sDomaine = RegRead($HKLM & "\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters", "Domain")
					_UpdEdit($iIDEditLog, $hLog)
					RegWrite($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","AutoAdminLogon","REG_SZ", 0)
					RegDelete($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","DefaultUserName")
					RegDelete($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","DefaultPassword")
					If($sDomaine <> "") Then
						RegDelete($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","DefaultDomain")
					EndIf
					_FichierCache("Autologon", 2)
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

				_CreerSfx($sFTPAdresse, $sFTPUser, $sFTPPort)

			Case $iIDMenu1reini

				_ReiniBAO()
				_Restart()

			Case $iIDMenu1tech

				_ChangerMode()
				_Restart()

			Case $iIDMenu2ajout

				_CreerIDSuivi($sFTPAdresse, $sFTPUser, $sFTPPort)

			Case $iIDMenu2completer

				_CompleterSuivi($sFTPAdresse, $sFTPUser, $sFTPPort)

			Case $iIDMenu2supp

				_SupprimerSuivi($sFTPAdresse, $sFTPUser, $sFTPPort)

			Case $iIDMenu2index

				_CreerIndex($sFTPAdresse, $sFTPUser, $sFTPPort)

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
					If StringLeft($sNom, 4) = "Tech" And ($aMenuID[$iIDAction])[11] <> -1 Then
						Local $hDLL = DllOpen("user32.dll")
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

				_DesinstallerBAO($sFTPAdresse, $sFTPUser, $sFTPPort, $sFTPDossierRapports)

			Case $sIDHelp

				ShellExecute("https://boiteaoutils.notion.site/boiteaoutils/Bo-te-A-Outils-BAO-a8530d0ca7834f36b2a8ea856deba06b")

			Case $sIDapropos

				_APropos()

		EndSwitch
	EndIf
WEnd