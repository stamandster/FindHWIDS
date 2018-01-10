#AutoIt3Wrapper_Res_File_Add=test_1.txt, rt_rcdata, TEST_TXT_1
#AutoIt3Wrapper_Res_File_Add=image1.bmp, rt_bitmap, TEST_BMP_1
#AutoIt3Wrapper_Res_File_Add=image2.bmp, rt_bitmap, TEST_BMP_2
#AutoIt3Wrapper_Res_File_Add=image3.jpg, rt_rcdata, TEST_JPG_3
#AutoIt3Wrapper_Res_File_Add=binary1.dat, rt_rcdata, TEST_BIN_1
#AutoIt3Wrapper_Res_File_Add=C:\WINDOWS\Media\tada.wav, sound, TEST_WAV_1

#include "resources.au3"
 
$gui = GUICreate("Data from resources example",820,400)
$pic1 = GUICtrlCreatePic("",0,0,400,300)
$pic2 = GUICtrlCreatePic("",400,0,400,150)
$pic3 = GUICtrlCreatePic("",400,150,400,150)
$pic4 = GUICtrlCreatePic("",600,320,400,100)
$label1 = GUICtrlCreateLabel("",20,320,380,100)
$label2 = GUICtrlCreateLabel("",400,320,200,100)
GUISetState(@SW_SHOW)

; get string from resource
$string = _ResourceGetAsString("TEST_TXT_1")
GUICtrlSetData($label1, $string)

; set BMP image to picture control from resource  bitmap
_ResourceSetImageToCtrl($pic1, "TEST_BMP_1", $RT_BITMAP)

; get bitmap from resource (as pointer)
$hBmp = _ResourceGet("TEST_BMP_2", $RT_BITMAP)
; and use it for whatever you like
_SetBitmapToCtrl($pic2, $hBmp)

; set JPG image to picture control from resource
_ResourceSetImageToCtrl($pic3, "TEST_JPG_3")

; set image to picture control from external DLL resource
_ResourceSetImageToCtrl($pic4, "#14355", $RT_BITMAP, @SystemDir & "\shell32.dll")

; get/use picture from resources as hImage type
$size1 = _ResourceGetImageSize("TEST_BMP_1", $RT_BITMAP)
$size2 = _ResourceGetImageSize("TEST_JPG_3")
GUICtrlSetData($label2, $size1 & @CRLF & $size2)

; save binary data or another type (image) from resource to file and get its size in bytes
$size1 = _ResourceSaveToFile(@ScriptDir & "\binary_data1.dat", "TEST_BIN_1")
$size2 = _ResourceSaveToFile(@ScriptDir & "\binary_data2.bmp", "TEST_BMP_1", $RT_BITMAP)

; save binary data from resource to file (create not existing directory)
_ResourceSaveToFile("C:\Dir1\SubDir2\binary_data1.dat", "TEST_BIN_1", $RT_RCDATA, 0, 1)
_ResourceSaveToFile("C:\Dir1\SubDir2\binary_data2.bmp", "TEST_BMP_1", $RT_BITMAP, 0, 1)

; play WAV from resource (sync/async)
_ResourcePlaySound("TEST_WAV_1")
_ResourcePlaySound("TEST_WAV_1", $SND_ASYNC)

While 1
    If GUIGetMsg() = -3 Then Exit
WEnd

Func _ResourceGetImageSize($ResName, $ResType = 10) ; $RT_RCDATA = 10
	; get/use picture from resources as hImage type
	$hImage = _ResourceGetAsImage($ResName, $ResType)
	_GDIPlus_Startup()
	$width =  _GDIPlus_ImageGetWidth ($hImage)
	$height = _GDIPlus_ImageGetHeight($hImage)
	_GDIPlus_Shutdown()
	
	Return "Size of " & $ResName & " is: " & $width & "x" & $height
EndFunc
