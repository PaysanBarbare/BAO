@echo off

if "%1"=="wait" GOTO wait
GOTO run

:wait
timeout 2

:run
Echo Demarrage de BAO en cours
IF %PROCESSOR_ARCHITECTURE% == x86 (IF NOT DEFINED PROCESSOR_ARCHITEW6432 goto bit32)
goto bit64
:bit32
start "" "%~dp0\Outils\AutoIt3.exe" "%~dp0\BAO.a3x"
goto cont
:bit64
start "" "%~dp0\Outils\AutoIt3_x64.exe" "%~dp0\BAO_x64.a3x"
:end