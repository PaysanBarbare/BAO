REG DELETE "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /q
sc config SecurityHealthService start= demand
sc start SecurityHealthService
PowerShell -ExecutionPolicy Unrestricted -Command "& {$manifest = (Get-AppxPackage *Microsoft.Windows.SecHealthUI*).InstallLocation + '\AppxManifest.xml' ; Add-AppxPackage -DisableDevelopmentMode -Register $manifest}"
sc start mpssvc
netsh advfirewall reset
netsh advfirewall set domainprofile state on