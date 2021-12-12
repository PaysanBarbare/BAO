@echo off

if "%1"=="install" GOTO install
if "%1"=="run" GOTO run
if "%1"=="uninstall" GOTO uninstall
goto:eof

:install
goto:eof

:run
set dirscript=%~dp0
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\PcNeuf.ps1"
pause
goto:eof

:uninstall
goto:eof