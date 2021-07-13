@echo off

if "%1"=="install" GOTO install
if "%1"=="run" GOTO run
if "%1"=="uninstall" GOTO uninstall
goto:eof

:install
goto:eof

:run
powershell.exe -NoProfile -ExecutionPolicy Bypass -File %~dp0\Win10.ps1 -include %~dp0\Win10.psm1 -preset %~dp0\mypreset.txt
goto:eof

:uninstall
goto:eof