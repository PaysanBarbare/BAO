@echo off

set /p ip="Saisissez l'ip du reseau a scanner (Defaut = 192.168.1.0) : " || SET "ip=192.168.1.0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\IPv4NetworkScanner\IPv4NetworkScan.ps1" -IPv4Address %ip% -Mask 255.255.255.0 -EnableMACResolving
PAUSE