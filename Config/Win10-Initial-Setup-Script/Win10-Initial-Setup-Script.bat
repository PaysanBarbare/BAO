@echo off

if "%1"=="install" GOTO install
if "%1"=="run" GOTO run
if "%1"=="uninstall" GOTO uninstall
goto:eof

:install
goto:eof

:run
echo "Execution de Win10-initial-Setup"
echo "Liste des preset disponibles :"
dir /b /a-d %~dp0\*.txt
set /p id="choisissez un preset : (Ctrl+C pour annuler) "
powershell.exe -NoProfile -ExecutionPolicy Bypass -File %~dp0\Win10.ps1 -include %~dp0\Win10.psm1 -preset %~dp0\%id%
goto:eof

:uninstall
goto:eof