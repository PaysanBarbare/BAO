@echo off

if "%1"=="install" GOTO install
if "%1"=="run" GOTO run
if "%1"=="uninstall" GOTO uninstall
goto:eof

:install
RogueKiller.exe /nocancel /norestart /silent /suppressmsgboxes /noicons /DIR="%ProgramFiles%\RogueKiller\"
goto:eof

:run
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
  Timeout /T 5 /Nobreak
  GOTO LOOP
)

goto:uninstall

:uninstall
"%ProgramFiles%\RogueKiller\unins000.exe" /silent /norestart
goto:eof