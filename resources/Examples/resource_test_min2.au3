#AutoIt3Wrapper_Res_File_Add=image3.jpg, rt_rcdata, TEST_JPG_1

#include "GUIConstantsEx.au3"
#include "StaticConstants.au3"
#include "resources.au3"
 
$gui = GUICreate("Data from resources simple example 2",400,150)
$pic1 = GUICtrlCreatePic("",0,0,400,150)
GUICtrlSetState(-1, $GUI_DISABLE)
_ResourceSetImageToCtrl($pic1, "TEST_JPG_1") ; set JPG image to picture control from resource
$label1 = GUICtrlCreateLabel("this is label over image",00,10,400,25,$SS_CENTER)
GUICtrlSetFont(-1, 14)
GUICtrlSetColor(-1, 0xffff00)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
$btn1 = GUICtrlCreateButton("Test",150,100,100,25)
GUISetState(@SW_SHOW)

While 1
	$msg = GUIGetMsg() 
	If $msg = $GUI_EVENT_CLOSE Then Exit
	If $msg = $btn1 Then MsgBox(0,'','Hello world!')
WEnd
