dism.exe /online /Cleanup-Image /StartComponentCleanup
dism.exe /online /Cleanup-Image /SPSuperseded
dism.exe /online /Cleanup-Image /RestoreHealth
dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
cleanmgr /d C: