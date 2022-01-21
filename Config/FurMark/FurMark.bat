@echo off

if "%1"=="install" GOTO install
if "%1"=="run" GOTO run
if "%1"=="uninstall" GOTO uninstall
goto:eof

:install
Echo Patientez pendant l'installation de FurMark
"%~dp0\FurMark.exe" /nocancel /norestart /silent /suppressmsgboxes /noicons /DIR="%ProgramFiles%\FurMark\"
goto:eof

:run
Echo Execution de FurMark
"%ProgramFiles%\FurMark\FurMark.exe"

:LOOP
tasklist | find /i "FurMark" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO uninstall
) ELSE (
  Timeout /T 5 /Nobreak > nul
  GOTO LOOP
)

goto:uninstall

:uninstall
Echo Desinstallation de FurMark en cours
"%ProgramFiles%\FurMark\unins000.exe" /silent /norestart
goto:eof