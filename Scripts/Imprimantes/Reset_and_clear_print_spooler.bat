:: Created by: Shawn Brink
:: Created on: August 5th 2017
:: Tutorial: https://www.tenforums.com/tutorials/90615-reset-clear-print-spooler-windows-10-a.html


@echo off
powershell -windowstyle hidden -command "Start-Process cmd -ArgumentList '/s,/c,net stop spooler & DEL /F /S /Q %systemroot%\System32\spool\PRINTERS\* & net start spooler' -Verb runAs"


