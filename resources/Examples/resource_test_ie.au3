#AutoIt3Wrapper_Res_File_Add=test_1.htm, rt_html, TEST_HTML_1
#AutoIt3Wrapper_Res_File_Add=test_1.gif, rt_html, TEST_GIF_1

$oIE = ObjCreate("Shell.Explorer.2")
$gui = GUICreate("HTML from resources example",500,400)
$ie_ctrl = GUICtrlCreateObj ($oIE, 0, 0 , 500, 400)
GUISetState(@SW_SHOW)

; image from resource (all HTML supported types)
$oIE.navigate("res://" & @AutoItExe & "/test_gif_1")
Sleep(3000)
; html from resource (with embeded image from resources)
$oIE.navigate("res://" & @AutoItExe & "/test_html_1")

While 1
    If GUIGetMsg() = -3 Then Exit
WEnd
