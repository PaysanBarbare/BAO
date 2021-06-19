@echo off

IF %PROCESSOR_ARCHITECTURE% == x86 (IF NOT DEFINED PROCESSOR_ARCHITEW6432 goto bit32)
goto bit64
:bit32
start "" AutoIt3.exe BAO.a3x
goto cont
:bit64
start "" AutoIt3_x64.exe BAO_x64.a3x
:end