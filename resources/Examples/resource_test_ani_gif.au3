#AutoIt3Wrapper_Res_File_Add=gif-Green-UFO.gif, rt_rcdata, ANI_GIF_1

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GDIPlus.au3>
#include <Misc.au3>
#include <WinAPI.au3>
#include <Timers.au3>

#include "resources.au3"

HotKeySet("{Esc}", "Quit")
HotKeySet("{Left}", "Left")
HotKeySet("{Right}", "Right")
HotKeySet("{Pause}", "Pause")

Global $GIF_TimerID, $hImage, $IMG_Ctrl, $GFC, $GFDC, $pDimensionIDs, $tDL
Global $Pause, $i = 0

$hGUI = GUICreate("GIF Animation", 300, 200)
GUICtrlCreateLabel("text behind GIF - test of transparency", 5, 15, 200, 25)
$IMG_Ctrl = GUICtrlCreateLabel("", 10, 10, 10, 10) ; For Drawing
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT) ; Transparency's working
GUISetState(@SW_SHOW)

GifInit()
; Start Animation: instead of using the time delays between frames given from GIF we use 100ms for simplicity
_Timer_SetTimer($hGUI, 100, "_Draw_Timer")

While 1
	If GUIGetMsg() = -3 Then Quit()
WEnd

Func _Draw_Timer($hWnd, $Msg, $iIDTimer, $dwTime)
	If Not $Pause Then
		If $i = $GFC Then $i = 0 ; If $i = the frame count then reset $i to 0
		GifDrawFrame($i)
		$i += 1
	EndIf
EndFunc

Func Quit()
    _Timer_KillAllTimers($hGUI)
	_GDIPlus_ImageDispose($hImage)
	_GDIPlus_Shutdown()

	HotKeySet("{Esc}")
	HotKeySet("{Left}")
	HotKeySet("{Right}")
	HotKeySet("{Pause}")

	Exit
EndFunc

Func GifInit()
	_GDIPlus_Startup()
	; Load your animated GIF (from file or from resources)
;~ 	$hImage = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\gif-Green-UFO.gif")
	$hImage = _ResourceGetAsImage("ANI_GIF_1")

	$tDL = DllStructCreate($tagGUID) ; Create a struct to hold the GUID.
	$pDimensionIDs = DllStructGetPtr($tDL) ; Get a pointer to the GUID struct.

	; Get the FrameDimensionsCount of the loaded gif
	$GFDC = DllCall($ghGDIPDll, "int", "GdipImageGetFrameDimensionsCount", "ptr", $hImage, "int*", 0)

	; Get the FrameDimensionsList , which fills the GUID struct by passing the GUID pointer and the FrameDimensionsCount.
	DllCall($ghGDIPDll, "int", "GdipImageGetFrameDimensionsList", "ptr", $hImage, "ptr", $pDimensionIDs, "int", $GFDC[2])

	; Get the FrameCount of the loaded gif by passing the GUID pointer
	$GFC = DllCall($ghGDIPDll, "int", "GdipImageGetFrameCount", "int", $hImage, "ptr", $pDimensionIDs, "int*", 0)
	$GFC = $GFC[3]
EndFunc

Func GifDrawFrame($i)
	; Select the ActiveFrame in the loaded GIF by telling it. The frame starts at 0 ($i)
	DllCall($ghGDIPDll, "int", "GdipImageSelectActiveFrame", "ptr", $hImage, "ptr", $pDimensionIDs, "int", $i)

	; get current frame from GIF and draw it on the control
	$hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
	_SetBitmapToCtrl($IMG_Ctrl, $hBitmap)
	_WinAPI_DeleteObject($hBitmap)
EndFunc

Func Left()
	If WinActive($hGUI) Then
		If Not $Pause Then Return
		$i -= 1
		If $i = -1 Then $i = $GFC - 1
		GifDrawFrame($i)
	Else
		HotKeySet("{Left}")
		Send("{Left}")
		HotKeySet("{Left}", "Left")
	EndIf
EndFunc

Func Right()
	If WinActive($hGUI) Then
		If Not $Pause Then Return
		$i += 1
		If $i = $GFC Then $i = 0
		GifDrawFrame($i)
	Else
		HotKeySet("{Right}")
		Send("{Right}")
		HotKeySet("{Right}", "Right")
	EndIf
EndFunc

Func Pause()
	If WinActive($hGUI) Then
		$Pause = Not $Pause
        If $Pause Then
			WinSetTitle($hGUI, '', 'GIF Animation - PAUSED')
        Else
			WinSetTitle($hGUI, '', 'GIF Animation')
        EndIf
	Else
		HotKeySet("{PAUSE}")
		Send("{PAUSE}")
		HotKeySet("{PAUSE}", "Pause")
	EndIf
EndFunc
