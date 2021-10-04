@echo off

if "%1"=="install" GOTO install
if "%1"=="run" GOTO run
if "%1"=="uninstall" GOTO uninstall
goto:eof

:install
copy "%~dp0\Privazer.exe" "%LOCALAPPDATA%\bao\"
copy "%~dp0\PrivaZer.ini" "%LOCALAPPDATA%\bao\"
goto:eof

:run
Echo Execution de Privazer en cours
"%LOCALAPPDATA%\bao\Privazer.exe"
goto:uninstall

:uninstall
del "%LOCALAPPDATA%\bao\Privazer.exe"
del "%LOCALAPPDATA%\bao\PrivaZer.ini"
goto:eof