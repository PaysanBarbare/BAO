:: This batch script created by FreeBooter : https://www.tenforums.com/antivirus-firewalls-system-security/167692-built-windows-10-home-antivirus-blocked-system-administrator-post2069815.html?s=a91f9cd2586e73034d8da6f9bac3ad74#post2069815
:: This batch script will reset Local Group Policy settings to system default settings 
:: Modifié par malekal.com - 2022

@Echo Off

Cls

REM  --> Check for permissions
Reg query "HKU\S-1-5-19\Environment" 
REM --> If error flag set, we do not have admin.
if %errorlevel% NEQ 0 (
ECHO                 **************************************
ECHO                  Execution d'Admin shell... Patientez...
ECHO                 **************************************

    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = "%*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B


:gotAdmin
Cls

Rd /S /Q %SystemRoot%\System32\GroupPolicyUsers
Rd /S /Q %SystemRoot%\System32\GroupPolicy
gpupdate /force
reg delete HKLM\SOFTWARE\Policies /f
reg delete HKCU\SOFTWARE\Policies /f
pause
Exit

 Cls & Mode CON  LINES=5 COLS=48 & Color 0C & Title - WARNING -
 Echo.
 Echo. 
 Echo Vous devez lancer le script par un clic droit / Executer en tant qu'administrateur 
 Pause >Nul & Exit