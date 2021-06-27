@echo off

if not "%minimized%"=="" goto :minimized
set minimized=true
start /min cmd /C "%~dpnx0"
goto :EOF

:minimized
pushd "%~dp0"
Outils\Autoit3.exe BAO.a3x
popd