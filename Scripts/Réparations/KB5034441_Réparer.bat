@echo off

echo Lancer la reparation ?
CHOICE /C ON

IF %ERRORLEVEL% EQU 1 goto:continue
IF %ERRORLEVEL% EQU 2 goto:eof

:continue

copy "%~dp0KB5034441.ps1" %TEMP%\
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\KB5034441.ps1" -BackupFolder %CD:~0,2%\KB5034441_backup