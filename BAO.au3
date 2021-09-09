#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Version=Beta
#AutoIt3Wrapper_Outfile_type=a3x
#AutoIt3Wrapper_Icon=bao.ico
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
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

Global $sVersion = "0.6.5" ; 09/21

#include-once
#include <APIDiagConstants.au3>
#include <Array.au3>
#include <ButtonConstants.au3>
#include <ColorConstants.au3>
#include <Constants.au3>
#include <Crypt.au3>
#include <Date.au3>
#include <EditConstants.au3>
#include <EventLog.au3>
#include <File.au3>
#include <FTPEx.au3>
#include <GUIConstantsEx.au3>
#include <GuiMenu.au3>
#include <IE.au3>
#include <Inet.au3>
#include <MemoryConstants.au3>
#include <Misc.au3>
#include <Process.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <String.au3>
#include <StringConstants.au3>
#include <WinAPIConv.au3>
#include <WinAPIShellEx.au3>
#include <WindowsConstants.au3>

; BAO ne peut être lancé qu'une fois.
_Singleton(@ScriptName, 0)

Local $sDossierRapport, $sNom, $sRetourInfo, $iFreeSpace, $sDem, $iIDAutologon, $sListeProgrammes = @LocalAppDataDir & "\bao\ListeProgrammes.txt", $sOSv, $bActiv = 0, $hSplash
Global $iLabelPC, $aResults[], $sInfos, $statusbar, $statusbarprogress, $iIDCancelDL, $sProgrun, $sProgrunUNC, $iPidt[], $iIDAction, $hFichierRapport, $aMenu[], $aMenuID[], $sNomDesinstalleur, $sPrivazer, $sListeProgdes, $aButtonDes[], $iIDEditRapport, $HKLM, $envChoco = @AppDataCommonDir & "\Chocolatey\", $sRestauration, $sPWDZip, $aListeAvSupp, $releaseid

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

If(FileExists(@DesktopDir & "\BAO.lnk") = 0) Then
	$hSplash = SplashTextOn("Démarrage de BAO", "Création du raccourci sur le bureau" & @LF & "Chargement des dépendances", 300, 160, @DesktopWidth - 400, @DesktopHeight - 250, 21, "", 10)
	Sleep(2000)
	FileCreateShortcut(@ScriptDir & '\run.bat', @DesktopDir & "\BAO.lnk", "", "", "Boîte à Outils",@ScriptDir & "\Outils\bao.ico")
	;FileCreateShortcut(@ScriptFullPath, @DesktopDir & "\BAO.lnk", @ScriptDir)
EndIf

Const $sConfig = @ScriptDir & "\config.ini"

#include "UDF\_BureauDistant.au3"
#include "UDF\_Desinfection.au3"
#include "UDF\_Desinstallation.au3"
#include "UDF\_Installation.au3"
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
If($hSplash <> "") Then
	$hSplash = SplashTextOn("Démarrage de BAO", "Création du raccourci sur le bureau" & @LF & "Chargement des dépendances" & @LF & "Désactivation de la mise en veille", 300, 160, @DesktopWidth - 400, @DesktopHeight - 250, 21, "", 10)
EndIf
_PowerKeepAlive()

; Lancement des fonctions à la fermeture
OnAutoItExitRegister("_PowerResetState")
OnAutoItExitRegister("_ProcessExit")
;OnAutoItExitRegister("_DriveMapDel")
;OnAutoItExitRegister("_StartWU")

If($hSplash <> "") Then
	$hSplash = SplashTextOn("Démarrage de BAO", "Création du raccourci sur le bureau" & @LF & "Chargement des dépendances" & @LF & "Désactivation de la mise en veille" & @LF & "Lecture du fichier de configuration", 300, 160, @DesktopWidth - 400, @DesktopHeight - 250, 21, "", 10)
EndIf
_InitialisationBAO($sConfig)

; Création du dossier rapport et du fichier rapport d'intervention
If($hSplash <> "") Then
	$hSplash = SplashTextOn("Démarrage de BAO", "Création du raccourci sur le bureau" & @LF & "Chargement des dépendances" & @LF & "Désactivation de la mise en veille" & @LF & "Lecture du fichier de configuration" & @LF & "Création du dossier rapport", 300, 160, @DesktopWidth - 400, @DesktopHeight - 250, 21, "", 10)
EndIf
$sDossierRapport = @DesktopDir & "\" & IniRead($sConfig, "Parametrages", "Dossier", "Rapports")
If DirCreate($sDossierRapport) = 0 Then	_Erreur("Impossible de créer le dossier '" & $sDossierRapport & "' sur le bureau")
$hFichierRapport = FileOpen($sDossierRapport & "\Rapport intervention.txt", 1)

; Sauvegarde du nom du client dans un fichier unique associé à l'ordinateur

Local $sFTPAdresse = IniRead($sConfig, "FTP", "Adresse", "")
Local $sFTPUser = IniRead($sConfig, "FTP", "Utilisateur", "")
Local $sFTPDossierSuivi = IniRead($sConfig, "FTP", "DossierSuivi", "")

$iFreeSpace = Round(DriveSpaceFree(@HomeDrive & "\") / 1024, 2)

If($hSplash <> "") Then
	$hSplash = SplashTextOn("Démarrage de BAO", "Création du raccourci sur le bureau" & @LF & "Chargement des dépendances" & @LF & "Désactivation de la mise en veille" & @LF & "Lecture du fichier de configuration" & @LF & "Création du dossier rapport" & @LF & "Vérification de la licence de Windows", 300, 160, @DesktopWidth - 400, @DesktopHeight - 250, 21, "", 10)
EndIf

If(@OSVersion = "WIN_7") Then
	$releaseid = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\", "CSDVersion")
ElseIf(@OSVersion = "WIN_10") Then
	$releaseid = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\", "ReleaseId")
	If $releaseid = "2009" Then
		$releaseid = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\", "DisplayVersion")
	EndIf
EndIf

$sOSv = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\", "ProductName") & " " & @OSArch & " " & $releaseid

Dim $Obj_WMIService = ObjGet("winmgmts:\\" & "localhost" & "\root\cimv2")
Dim $Obj_Services = $Obj_WMIService.ExecQuery("Select * from SoftwareLicensingProduct where PartialProductKey <> null")
Local $Obj_Item
For $Obj_Item In $Obj_Services
	if $Obj_Item.LicenseStatus = 1 And $Obj_Item.ApplicationId = "55c92734-d682-4d71-983e-d6ec3f16059f" And $Obj_Item.LicenseIsAddon = False Then
		$sOSv = $sOSv & " (activé)";
		$bActiv = 1
	EndIf
Next

If $bActiv = 0 Then
	$sOSv = $sOSv & " (non activé)";
EndIf

if(_FichierCacheExist("Client") = 0) Then

	If($sFTPAdresse <> "" And $sFTPUser <> "" And $sFTPDossierSuivi) Then
		_FichierCache("Suivi", 1)
	EndIf

	$sNom = _PremierLancement()
Else
	$sNom = _FichierCache("Client")
	If FileGetPos($hFichierRapport) = 0 Then
		_RapportInfos()
	EndIf
EndIf



If(FileExists(@ScriptDir & "\Liens\") = 0) Then _Erreur('Dossier "Liens" manquant')

; initialisation désinfection
$sNomDesinstalleur = IniRead($sConfig, "Desinfection", "Desinstalleur", "")
$sPrivazer = IniRead($sConfig, "Desinfection", "Privazer", "Free")
$sListeProgdes = _StringExplode(IniRead($sConfig, "Desinfection", "Programmes de desinfection", "RogueKiller AdwCleaner MalwareByte ZHPCleaner"), " ")

If(FileExists($sListeProgrammes)) Then
	_FileReadToArray($sListeProgrammes, $aListeAvSupp, 0)
Else
	$aListeAvSupp = _ListeProgrammes()
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

If($hSplash <> "") Then
	$hSplash = SplashTextOn("Démarrage de BAO", "Création du raccourci sur le bureau" & @LF & "Chargement des dépendances" & @LF & "Désactivation de la mise en veille" & @LF & "Lecture du fichier de configuration" & @LF & "Création du dossier rapport" & @LF & "Vérification de la licence de Windows" & @LF & "Génération des informations système" & @LF & "Ouverture de BAO", 300, 160, @DesktopWidth - 400, @DesktopHeight - 250, 21, "", 10)
EndIf

GUICreate("Boîte A Outils (bêta) " & $sVersion, 860, 210 + ($iFonctions * 30) + UBound($sListeProgdes) * 25)
GUISetBkColor($COLOR_WHITE)

$statusbar = GUICtrlCreateLabel("", 10, 135 + ($iFonctions * 30) + UBound($sListeProgdes) * 25, 410, 20, $SS_CENTERIMAGE)
$statusbarprogress = GUICtrlCreateProgress(440, 135 + ($iFonctions * 30) + UBound($sListeProgdes) * 25, 250, 20)
$iIDCancelDL = GUICtrlCreateButton("Passer / Annuler", 700, 135 + ($iFonctions * 30) + UBound($sListeProgdes) * 25, 150, 20)
GUICtrlSetState($iIDCancelDL, $GUI_DISABLE)
GUICtrlSetFont($statusbar, 11)

Local $iIDMenu1 = GUICtrlCreateMenu("&Configuration")
Local $iIDMenu1config = GUICtrlCreateMenuItem("Editer config.ini", $iIDMenu1)
Local $iIDMenu1dossierRapport = GUICtrlCreateMenuItem("Ouvrir dossier Rapport", $iIDMenu1)
Local $iIDMenu1dossier = GUICtrlCreateMenuItem("Ouvrir dossier du programme", $iIDMenu1)
Local $iIDMenu1dossierAppdata = GUICtrlCreateMenuItem("Ouvrir dossier AppData", $iIDMenu1)
Local $iIDMenu1reini = GUICtrlCreateMenuItem("Reinitialiser BAO", $iIDMenu1)
Local $iIDMenu1tech = GUICtrlCreateMenuItem("Passer en mode Tech/Client", $iIDMenu1)
Local $iIDMenu1clearcache = GUICtrlCreateMenuItem("Effacer le cache installation (Tech)", $iIDMenu1)
Local $iIDMenu1update = GUICtrlCreateMenuItem("Tout mettre à jour (Tech)", $iIDMenu1)
Local $iIDMenu1copier = GUICtrlCreateMenuItem("Copier BAO sur support externe (Tech)", $iIDMenu1)
Local $iIDMenu1sfx = GUICtrlCreateMenuItem("Créer archive SFX (Tech)", $iIDMenu1)

Local $iIDMenu2 = GUICtrlCreateMenu("&Suivi")
Local $iIDMenu2ajout = GUICtrlCreateMenuItem("Nouveau code de suivi", $iIDMenu2)
Local $iIDMenu2completer = GUICtrlCreateMenuItem("Ajouter une information de suivi", $iIDMenu2)

Local $iIDMenu2supp
If(StringLeft($sNom, 4) <> "Tech") Then
	$iIDMenu2supp = GUICtrlCreateMenuItem("Supprimer l'association", $iIDMenu2)
Else
	$iIDMenu2supp = GUICtrlCreateMenuItem("Supprimer un code de suivi", $iIDMenu2)
EndIf

Local $iIDMenu2index = GUICtrlCreateMenuItem("Créer index.php sur le serveur FTP (Tech)", $iIDMenu2)

Local $sFTPAdresse = IniRead($sConfig, "FTP", "Adresse", "")
Local $sFTPUser = IniRead($sConfig, "FTP", "Utilisateur", "")

If(_FichierCacheExist("Suivi") = 0) Then
	GUICtrlSetState($iIDMenu2, $GUI_DISABLE)
EndIf


If(StringLeft($sNom, 4) <> "Tech") Then
	GUICtrlSetState($iIDMenu1clearcache, $GUI_DISABLE)
	GUICtrlSetState($iIDMenu1update, $GUI_DISABLE)
	GUICtrlSetState($iIDMenu1copier, $GUI_DISABLE)
	GUICtrlSetState($iIDMenu1sfx, $GUI_DISABLE)
	GUICtrlSetState($iIDMenu2index, $GUI_DISABLE)
EndIf

Local $aDoc = _FileListToArray(@ScriptDir & "\Liens\", "*", 2)
Local $sHeure, $iMin = @MIN
Local $i, $j, $iPremElement, $iDernElement, $x = 70

Local $iIDMenuLog = GUICtrlCreateMenu("Logiciels")

$iPremElement = $iIDMenuLog + 1

For $i = 1 To $aDoc[0]

	Local $aTemp

	If @OSArch = "X64" Then
		$aTemp = _FileListToArrayRec(@ScriptDir & "\Liens\" & $aDoc[$i], "*.url;*.txt;*.lnk|*-x86.url")
	Else
		$aTemp = _FileListToArrayRec(@ScriptDir & "\Liens\" & $aDoc[$i], "*.url;*.txt;*.lnk|*-x64.url")
	EndIf

	If	@error <> 1 Then
		If $aDoc[$i] <> "Favoris" Then

			Local $iIDMenuDoc = GUICtrlCreateMenu($aDoc[$i], $iIDMenuLog)
			For $j = 1 To $aTemp[0]
				Local $aTempLog[3]
				Local $sNomLog = StringTrimRight($aTemp[$j], 4)
				Local $sURL
				If(StringRight($aTemp[$j], 3) = "url") Then
					$sURL = IniRead( @ScriptDir & "\Liens\" & $aDoc[$i] & "\" & $aTemp[$j], "InternetShortcut","URL", "ERROR")
				Else
					$sURL = FileReadLine(@ScriptDir & "\Liens\" & $aDoc[$i] & "\" & $aTemp[$j])
				EndIf

				Local $sIDSM = GUICtrlCreateMenuItem($sNomLog, $iIDMenuDoc)
				$aTempLog[0] = $sIDSM
				$aTempLog[1] = $sNomLog
				$aTempLog[2] = $sURL
				; on stocke dans le tableau l'id du menu et l'url
				$aMenu[$sNomLog] = $aTempLog
				$aMenuID[$sIDSM] = $aTempLog

			Next
		Else
			For $j = 1 To $aTemp[0]
				Local $aTempLog[3]
				Local $sNomLog = StringTrimRight($aTemp[$j], 4)
				Local $sURL
				If(StringRight($aTemp[$j], 3) = "url") Then
					$sURL = IniRead( @ScriptDir & "\Liens\" & $aDoc[$i] & "\" & $aTemp[$j], "InternetShortcut","URL", "ERROR")
				ElseIf(StringRight($aTemp[$j], 3) = "lnk") Then
					Local $aShortcut = FileGetShortcut(@ScriptDir & "\Liens\" & $aDoc[$i] & "\" & $aTemp[$j])
					$sURL = $aShortcut[0]
				Else
					$sURL = FileReadLine(@ScriptDir & "\Liens\" & $aDoc[$i] & "\" & $aTemp[$j])
				EndIf

				Local $sIDSM = GUICtrlCreateButton($sNomLog, 700, $x, 150, 25)
				$aTempLog[0] = $sIDSM
				$aTempLog[1] = $sNomLog
				$aTempLog[2] = $sURL
				; on stocke dans le tableau l'id du menu et l'url
				$aMenu[$sNomLog] = $aTempLog
				$aMenuID[$sIDSM] = $aTempLog
				$x = $x + 25
			Next
		EndIf
	EndIf
Next

$iDernElement = $sIDSM
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

	Local $iAutoAdmin = RegRead($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","AutoAdminLogon")
	if _FichierCacheExist("Autologon") = 0 And $iAutoAdmin = 0 Then
		_FichierCache("Autologon", 1)
	EndIf

	If _FichierCacheExist("Autologon") = 1 Then
		$iIDAutologon = GUICtrlCreateCheckbox("Autologon", 530, 160 + ($iFonctions * 30) + UBound($sListeProgdes) * 25)
		If $iAutoAdmin = 1 Then
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

Local $iIDespacelibre = GUICtrlCreateLabel(@HomeDrive & " " & $iFreeSpace & " Go libre", 620, 164 + ($iFonctions * 30) + UBound($sListeProgdes) * 25)
Local $aMemStats = MemGetStats()
Local $iIDRAMlibre = GUICtrlCreateLabel("RAM : " & $aMemStats[$MEM_LOAD] & '% utilisée', 720, 164 + ($iFonctions * 30) + UBound($sListeProgdes) * 25)


GUICtrlSetFont($iLabelPC, 18)

Local $sDate = _FichierCache("PremierLancement")
GUICtrlCreateLabel("Nom du PC : " & @ComputerName, 450, 2)
GUICtrlCreateLabel("OS : " & $sOSv, 450, 20, 300)
If($bActiv = 0) Then
	GUICtrlSetColor(-1, $COLOR_RED)
Else
	GUICtrlSetColor(-1, $COLOR_GREEN)
EndIf
GUICtrlSetFont(-1, Default, 600)
GUICtrlCreateLabel("Début : " & $sDate, 450, 38, 200)
GUICtrlSetFont(-1, Default, 600)


$iIDButtonBureaudistant = GUICtrlCreateButton("Bureau distant", 10, 50, 150, 25)
$iIDButtonInstallation = GUICtrlCreateButton("Installation", 10, 80, 150, 25)
$iIDButtonSauvegarde = GUICtrlCreateButton("Sauvegarde", 10, 110, 150, 25)
$iIDButtonWU = GUICtrlCreateButton("Windows et Office", 10, 140, 150, 25)
$iIDButtonPilotes = GUICtrlCreateButton("Pilotes", 10, 170, 150, 25)
$iIDButtonStabilite = GUICtrlCreateButton("Test de mémoire vive", 10, 200, 150, 25)
$iIDButtonScripts = GUICtrlCreateButton("Scripts et outils", 10, 230, 150, 25)

Local $y = 70 + ($iFonctions * 30)
Local $pgroup = $y-20

Local $iIDButtonNettoyage = GUICtrlCreateButton("1 - Nettoyage", 10, $y, 150, 25)
If(_FichierCacheExist("Desinfection") = 1) Then
	_ChangerEtatBouton($iIDButtonNettoyage, "Activer")
EndIf

$y = $y + 25
Local $z
Local $iIDMenuDes, $iLargeur

For $z = 1 To UBound($sListeProgdes)
	If FileExists(@ScriptDir & "\Outils\" & $sListeProgdes[$z - 1] & "\" & $sListeProgdes[$z - 1] & ".bat") Then
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

Local $iIDButtonResetBrowser = GUICtrlCreateButton($z + 1 & " - RAZ Navigateurs", 10, $y, 150, 25)
If(_FichierCacheExist("ResetBrowser") = 1) Then
	_ChangerEtatBouton($iIDButtonResetBrowser, "Activer")
EndIf

GUICtrlCreateGroup("Désinfection", 5, $pgroup, 160, (($z + 2) * 25) + 2)

Local $iIDButtonEnvoi = GUICtrlCreateButton("Compléter le rapport", 700, $y - 60, 150, 25)
Local $iIDButtonUninstall = GUICtrlCreateButton("Désinstaller", 700, $y - 30, 150, 25)
Local $iIDButtonQuit = GUICtrlCreateButton("Quitter", 700, $y , 150, 25)

If ($x > $y - 65) Then _Attention("Il y a trop de liens dans le dossier Favoris, merci d'en supprimer")

GUICtrlCreateGroup("Favoris et raccourcis", 695, 50, 160, $y - 128)

If _FichierCacheExist("Bureaudistant") = 1 Then	_ChangerEtatBouton($iIDButtonBureaudistant, "Activer")

If _FichierCacheExist("Envoi") = 1 Then	_ChangerEtatBouton($iIDButtonEnvoi, "Activer")

If _FichierCacheExist("WU") = 1 Then _ChangerEtatBouton($iIDButtonWU, "Activer")

If _FichierCacheExist("Installation") = 1 Then _ChangerEtatBouton($iIDButtonInstallation, "Activer")

If _FichierCacheExist("Stabilite") = 1 Then _ChangerEtatBouton($iIDButtonStabilite, "Activer")

If _FichierCacheExist("StabiliteTime") = 1 Then
	_ResultatStabilite()
	_FichierCache("StabiliteTime", -1)
EndIf

GUICtrlCreateGroup("Rapport", 170, 50, 520, 77 + ($iFonctions * 30) + UBound($sListeProgdes) * 25)

$iIDEditRapport = GUICtrlCreateEdit("", 180, 70,500, 47 + ($iFonctions * 30) + UBound($sListeProgdes) * 25, BitOR($ES_READONLY, $WS_VSCROLL))
_UpdEdit($iIDEditRapport, $hFichierRapport)

GUISetState(@SW_SHOW)

If _FichierCacheExist("Restauration") = 0 Then

	$sRestauration = IniRead($sConfig, "Parametrages", "Restauration", 0)
	If $sRestauration = 1 Then
		If($hSplash <> "") Then
			$hSplash = SplashTextOn("Démarrage de BAO", "Création du raccourci sur le bureau" & @LF & "Chargement des dépendances" & @LF & "Désactivation de la mise en veille" & @LF & "Lecture du fichier de configuration" & @LF & "Création du dossier rapport" & @LF & "Vérification de la licence de Windows" & @LF & "Génération des informations système" & @LF & "Ouverture de BAO" & @LF & "Création d'un point de restauration", 300, 160, @DesktopWidth - 400, @DesktopHeight - 250, 21, "", 10)
		EndIf
		_Restauration("Démarrage de BAO")
		_FichierCache("Restauration", 1)
	EndIf
EndIf

Local $stdoutwu, $datawu, $iFreeSpacech

SplashOff()

While 1
	$iIDAction = GUIGetMsg()
	If @MIN > $iMin Then

		GUICtrlSetData ($sHeure, @MDAY &"/"& @MON &"/"& @YEAR &" - "& @HOUR &":"& @MIN)
		$iMin = @MIN

		If Not($sYear = @YEAR And $sMon = @MON And $sDay = @MDAY) Then
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

	Switch $iIDAction

		Case $iIDCheckboxwu
			If(GUICtrlRead($iIDCheckboxwu) = $GUI_CHECKED) Then
				RunWait(@ComSpec & ' /c net stop wuauserv & net stop bits & net stop dosvc', '', @SW_HIDE)
				_FichierCache("WUInactif", 1)
			Else
				RunWait(@ComSpec & ' /c net start wuauserv & net start bits & net start dosvc', '', @SW_HIDE)
				_FichierCache("WUInactif", -1)
			EndIf

		Case $iIDRestau
			_Restauration()

		Case $iIDAutologon

			Local $sDomaine = RegRead($HKLM & "\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters", "Domain")

			If(GUICtrlRead($iIDAutologon) = $GUI_CHECKED) Then
				Local $sMdps = InputBox("Mot de passe de session", "Entrez votre mot de passe de session", "", "*")

				If $sMdps <> "" Then
					RegWrite($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","AutoAdminLogon","REG_SZ", 1)
					RegWrite($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","DefaultUserName","REG_SZ", @UserName)
					RegWrite($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","DefaultPassword","REG_SZ", $sMdps)
					If($sDomaine <> "") Then
						RegWrite($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","DefaultDomain","REG_SZ", $sDomaine)
					EndIf
				Else
					GUICtrlSetState($iIDAutologon, $GUI_UNCHECKED)
				EndIf
			Else
				RegWrite($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","AutoAdminLogon","REG_SZ", 0)
				RegDelete($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","DefaultUserName")
				RegDelete($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","DefaultPassword")
				If($sDomaine <> "") Then
					RegDelete($HKLM & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon","DefaultDomain")
				EndIf
			EndIf

		Case $GUI_EVENT_CLOSE
			RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce\", "BAO")
			Exit

		Case $iIDButtonQuit
			RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce\", "BAO")
			Exit

		Case $iIDMenu1config
			ShellExecuteWait($sConfig)

		Case $iIDMenu1dossier
			ShellExecute(@ScriptDir)

		Case $iIDMenu1dossierAppdata
			ShellExecute(@LocalAppDataDir & "\bao")

		Case $iIDMenu1dossierRapport
			ShellExecute($sDossierRapport)

		Case $iIDMenu1clearcache

			_ClearCache()

		Case $iIDMenu1update

			_UpdateProg()

		Case $iIDMenu1copier

			_CopierSur()

		Case $iIDMenu1sfx

			_CreerSfx()

		Case $iIDMenu1reini

			_ReiniBAO()
			Exit

		Case $iIDMenu1tech

			_ChangerMode()
			Exit

		Case $iIDMenu2ajout

			_CreerIDSuivi()

		Case $iIDMenu2completer

			_CompleterSuivi()

		Case $iIDMenu2supp

			_SupprimerSuivi()

		Case $iIDMenu2index

			_CreerIndex()

		Case $sIDVarALLUSERSPROFILE, $sIDVarAPPDATA, $sIDVarLOCALAPPDATA, $sIDVarProgramData, $sIDVarProgramFiles, $sIDVarProgramFiles86, $sIDVarPUBLIC, $sIDVarTEMP, $sIDVarTMP, $sIDVarUSERPROFILE, $sIDVarwindir

			Local $sVarValue = EnvGet(GUICtrlRead($iIDAction, 1))

			If($sVarValue and StringInStr($sVarValue, "\")) Then
				ShellExecute($sVarValue)
			Else
				_Attention("Cette variable d'environnement n'exite pas ou n'est pas un dossier")
			EndIf

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

 		Case $iIDButtonNettoyage + 1 to $iIDButtonResetBrowser -1 ; Désinfection

			_NettoyageProg($aButtonDes)

		Case $iIDButtonResetBrowser

			_ResetBrowser()

 		Case $iIDButtonEnvoi

			_CompleterRapport()

 		Case $iPremElement To $iDernElement

			_ExecuteProg()

		Case $iIDButtonUninstall

			_DesinstallerBAO()

		Case $sIDHelp

			ShellExecute(@ScriptDir & "\bao_manuel.pdf")

		Case $sIDapropos

			_APropos()

	EndSwitch
WEnd