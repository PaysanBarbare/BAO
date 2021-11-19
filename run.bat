@echo off

Echo Demarrage de BAO en cours
IF %PROCESSOR_ARCHITECTURE% == x86 (IF NOT DEFINED PROCESSOR_ARCHITEW6432 goto bit32)
goto bit64
:bit32
start "" "%~dp0Outils\AutoIt3.exe" "%~dp0BAO.a3x"
goto cont
:bit64
start "" "%~dp0Outils\AutoIt3_x64.exe" "%~dp0BAO_x64.a3x"
:end