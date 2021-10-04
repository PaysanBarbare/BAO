@echo off

if "%1"=="install" GOTO install
if "%1"=="run" GOTO run
if "%1"=="uninstall" GOTO uninstall
goto:eof

:install
goto:eof

:run
powershell.exe -NoProfile -ExecutionPolicy Bypass -File %~dp0\Windows10Debloater.ps1

:uninstall
goto:eof