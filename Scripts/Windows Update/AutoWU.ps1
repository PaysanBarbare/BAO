if (-not (Get-PackageProvider -name NuGet)) {
    Install-PackageProvider -Name NuGet -Force
}
if (-not (Get-Module -Name PSWindowsUpdate)) {
    Install-Module -Name PSWindowsUpdate -Force
}
#Install-WindowsUpdate -AcceptAll -AutoReboot
Get-WindowsUpdate -install -acceptall -autoreboot