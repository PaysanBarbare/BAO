@echo off

IF %PROCESSOR_ARCHITECTURE% == x86 (IF NOT DEFINED PROCESSOR_ARCHITEW6432 goto bit32)
goto bit64
:bit32
start "" BAO.exe
goto cont
:bit64
start "" BAO_x64.exe
:end