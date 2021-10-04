@echo off

if "%1"=="install" GOTO install
if "%1"=="run" GOTO run
if "%1"=="uninstall" GOTO uninstall
goto:eof

:install
Echo Patientez pendant l'installation de RogueKiller
"%~dp0\RogueKiller.exe" /nocancel /norestart /silent /suppressmsgboxes /noicons /DIR="%ProgramFiles%\RogueKiller\"
goto:eof

:run
Echo Execution de RogueKiller en cours, double cliquez sur son icone dans la barre de notification
REM if "%2"=="X64" (
REM %ProgramFiles%\RogueKiller\RogueKiller64.exe
REM ) else (
REM %ProgramFiles%\RogueKiller\RogueKiller.exe
REM )

:LOOP
tasklist | find /i "RogueKiller" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO uninstall
) ELSE (
  Timeout /T 5 /Nobreak > nul
  GOTO LOOP
)

goto:uninstall

:uninstall
Echo Desinstallation de RogueKiller en cours
"%ProgramFiles%\RogueKiller\unins000.exe" /silent /norestart
goto:eof