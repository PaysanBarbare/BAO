Local $aRet = DllCall('Kernel32.dll', "int", "GetSystemTimes", 'uint64*', 0, 'uint64*', 0, 'uint64*', 0)
		Local $aCpuTime[2] = [$aRet[1], ($aRet[2] + $aRet[3])] ; [idle, user+kernel]
		msgbox(0,"", $aCpuTime[2])