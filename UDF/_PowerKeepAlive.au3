#include-once
; ===============================================================================================================================
; <_PowerKeepAlive.au3>
;
; Functions to prevent/disable sleep/power-savings modes (AND screensaver)
;
; Functions:
;	_PowerKeepAlive()
;	_PowerResetState()
;
; See also:
;	<_ScreenSaverFunctions.au3>	; query, change, enable & disable screensaver.
;
; Author: Ascend4nt
;
;Source : https://www.autoitscript.com/forum/topic/152381-screensaver-sleep-lock-and-power-save-disabling/
; ===============================================================================================================================

; ==========================================================================================================================
; Func _PowerKeepAlive()
;
; Function to Prevent the Screensaver and Sleep/Power-savings modes from kicking in.
;	NOTE: Be sure to reset this state on exit!
;
; Returns:
;	Success: @error=0 & previous state as # (typically 0x80000000 [-2147483648])
;	Failure: @error set (returns 0x80000000, but thats just the normal state)
;		@error = 2 = DLLCall error. @extended = DLLCall error code (see AutoIt Help)
;
; Author: Ascend4nt
; ==========================================================================================================================

Func _PowerKeepAlive()
#cs
	; Flags:
	;	ES_SYSTEM_REQUIRED  (0x01) -> Resets system Idle timer
	;	ES_DISPLAY_REQUIRED (0x02) -> Resets display Idle timer
	;	ES_CONTINUOUS (0x80000000) -> Forces 'continuous mode' -> the above 2 will not need to continuously be reset
#ce
	Local $aRet=DllCall('kernel32.dll','long','SetThreadExecutionState','long',0x80000003)
	If @error Then Return SetError(2,@error,0x80000000)
	Return $aRet[0]	; Previous state (typically 0x80000000 [-2147483648])
EndFunc

; ==========================================================================================================================
; Func _PowerResetState()
;
; Function to Reset the Screensaver and Sleep/Power-savings modes to defaults.
;	NOTE: The timer is reset on each call to this!
;
; Returns:
;	Success: @error=0 & previous state as #
;	Failure: @error set (returns 0x80000000, but thats just the normal state)
;		@error = 2 = DLLCall error. @extended = DLLCall error code (see AutoIt Help)
;
; Author: Ascend4nt
; ==========================================================================================================================

Func _PowerResetState()
	; Flag:	ES_CONTINUOUS (0x80000000) -> (default) -> used alone, it resets timers & allows regular sleep/power-savings mode
	Local $aRet=DllCall('kernel32.dll','long','SetThreadExecutionState','long',0x80000000)
	If @error Then Return SetError(2,@error,0x80000000)
	Return $aRet[0]	; Previous state
EndFunc
