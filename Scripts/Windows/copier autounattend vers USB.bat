@echo off

set /p id="Saisissez la lettre de la cle USB d'installation Windows : "
copy %~dp0\autounattend.xml %id%: