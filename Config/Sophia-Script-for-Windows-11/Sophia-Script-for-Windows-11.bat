@echo off

if "%1"=="install" GOTO install
if "%1"=="run" GOTO run
if "%1"=="uninstall" GOTO uninstall
goto:eof

:install
goto:eof

:run
echo Lancer la personnalisation ?
CHOICE /C ON

IF %ERRORLEVEL% EQU 1 goto:continue
IF %ERRORLEVEL% EQU 2 goto:eof

:continue
set dirscript=%~dp0
REGEDIT /S "%~dp0\TaskbarAI.reg"
%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\PcNeuf.ps1"
pause
goto:eof

:uninstall
goto:eof