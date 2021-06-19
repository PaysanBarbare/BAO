@echo off

if "%1"=="install" GOTO install
if "%1"=="run" GOTO run
if "%1"=="uninstall" GOTO uninstall
goto:eof

:install
goto:eof

:run
AdwCleaner.exe
sc start DWAgent
goto:eof

:uninstall
goto:eof