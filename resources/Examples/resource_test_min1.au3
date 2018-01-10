#AutoIt3Wrapper_Res_File_Add=image3.jpg, rt_rcdata, TEST_JPG_1

#include "resources.au3"
 
$gui = GUICreate("Data from resources simple example 1",400,150)
$pic1 = GUICtrlCreatePic("",0,0,400,150)
_ResourceSetImageToCtrl($pic1, "TEST_JPG_1") ; set JPG image to picture control from resource
GUISetState(@SW_SHOW)

While 1
	If GUIGetMsg() = -3 Then Exit
WEnd
