#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=ICO\main.ico
#AutoIt3Wrapper_Outfile=FindHwids.v3.2t.exe
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;#NoTrayIcon
#AutoIt3Wrapper_plugin_funcs = FileHash, StringHash

Opt("TrayMenuMode",1)

#cs
Written by Christopher St.Amand - chris@wanderingit.com under GPL license
Freely distributable but not pay-for
#ce


#include <guiconstants.au3>
#include <ProgressConstants.au3>
#include <array.au3>
#include <file.au3>
#include <string.au3>
#include <guiconstants.au3>
;#include <Excel.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <ButtonConstants.au3>
#include <process.au3>
#include <WindowsConstants.au3>
#Include <GuiButton.au3>
#include <GUIConstantsEx.au3>
#include "crc-ward.au3"
#include "RecFileListToArray.au3"
#include "IniString.au3"

Global $oMyError = ObjEvent("AutoIt.Error","MyErrFunc")


#include <TabConstants.au3>


AutoItSetOption ("ExpandEnvStrings",1) ; So you can use Environment variables too!
Opt("GUICoordMode", 1)
DirCreate(@tempdir &"\FindHWIDS")
DirCreate(@tempdir &"\FindHWIDS\ICO")
DirCreate(@tempdir &"\FindHWIDS\BIN")
DirCreate(@tempdir &"\FindHWIDS\IMAGE")
FileInstall("ReadMe.txt",@tempdir &"\FindHWIDS\BIN\ReadMe.txt")
;Fileinstall("fshash.dll",@tempdir &"\FindHWIDS\BIN\fshash.dll")
Fileinstall("logo_fhwid.jpg",@tempdir &"\FindHWIDS\IMAGE\logo_fhwid.jpg")
Fileinstall("ICO\processing.ico",@tempdir &"\FindHWIDS\ICO\processing.ico")



DIM $ExportToLoc, $ParseTo, $ScanLocation, $LocationInput, $INFLocationRead
DIM $ClassFiltersRead, $PNPFilterRead, $CurrentHardware_CheckBox, $OStypeAndArch_CheckBox
DIM $checkbox_export_csv, $checkbox_export_sysprep, $Check_ExportToCSV, $Check_ExportToSysprep,$Check_ExportToHtml
DIM $strComputer, $objWMIService, $element
dim $Filter_X86_box,$Filter_AMD64_box,$Filter_IA64_box,$Filter_W2k_box,$Filter_XP_box,$Filter_W2k3_box,$Filter_Vi_box

Dim $SysprepLoc = "C:\Sysprep\sysprep.inf" ; Default Sysprep
Dim $SysprepFileLocRead
Dim $CSVLoc = @scriptdir &"\FindHWIDS-"& @YEAR &"-"&@MON&"-"&@MDAY&"-"&@HOUR&@MIN&@SEC&".csv" ; Default CSV
Dim $CSVFileLocRead
Dim $HardwareLoc = @scriptdir &"\hardware.log" ; Default Hardware Log Export
Dim $HTMLLoc = @scriptdir &"\hwids.html" ; Default Hardware Log Export

#cs
Dim $SysprepLoc = "Z:\Sysprep\sysprep.inf" ; Default Sysprep
Dim $CSVLoc = "Z:\hwids.csv" ; Default CSV
Dim $HardwareLoc = "Z:\hardware.log" ; Default Hardware Log Export
Dim $HTMLLoc = "Z:\hwids.html" ; Default Hardware Log Export
#ce

Const $wbemFlagReturnImmediately = 0x10
Const $wbemFlagForwardOnly = 0x20

;$strComputer = inputbox( "Please enter the name of the computer you want", "Input","localhost")
$strComputer = "."
$objWMIService = ObjGet("winmgmts:{impersonationLevel=impersonate}!\\" & $strComputer & "\root\CIMV2")

;constants
$version = "v3.2t"
$root = StringLeft(@windowsdir,2) ; Get Root of the Windows drive
$font = "Tahoma"
$INI = @ScriptDir & "\" & "findhwids.ini"

; Set hotkey to exit scan and program
HotKeySet("{esc}", "_Exit_Scan")


; ------ Create GUI
;$MainWindow = GUICreate("FindHWIDS " & $Version, 460, 385, -1, -1,-1,0x00000018)
$MainWindow = GUICreate("FindHWIDS " & $Version, 460, 560, -1, -1,-1,0x00000018)
GUISetBkColor(0xFFFFFF)

; Create Location of Files
GUICtrlCreateGroup("Location of INF files or a specific INF file",5,58,322,48)
	GUICtrlSetFont(-1, 9, 400,1, $font)
	$LocationInput = GUICtrlCreateInput("",10,80,255,20)
		GUICtrlSetFont(-1, 8.5, 400,1, $font)
		GUICtrlSetTip(-1,"You can manually enter a list of path locations to either a folder(s) and/or file(s). Separating "& @CR _
		& "This export format will not create ANY duplicate HWIDS."& @CR _
		& "You must still run sysprep -bmsd to gather built HWIDS built into windows." & @CR _
		&"We also advise that you use sysprep -clean in your cmdlines.txt to clean out unused hardware id's.","",1)
		GUICtrlSetState(-1, $GUI_DROPACCEPTED)
	$Button_Choose_Location = GUICtrlCreateButton("...",270,80,20,20,$BS_FLAT)
		GUICtrlSetFont(-1, 8.5, 400,1, $font)
	$Button_Clear_Location = GUICtrlCreateButton("CLR",295,80,25,20,$BS_FLAT)
		GUICtrlSetFont(-1, 8.5, 400,1, $font)
		GUICtrlSetTip(-1,"Clear Location Paths","",1)
GUICtrlCreateGroup("", -99, -99, 1, 1) ; close group

; Create Export Type
GUICtrlCreateGroup("Choose Export Type",5,115,322,40)
	GUICtrlSetFont(-1, 9, 400,1, $font)
	$checkbox_export_csv = GUICtrlCreateCheckbox("CSV",15,132,38,20)
		GUICtrlSetFont(-1, 8.5, 400,1, $font)
		GUICtrlSetTip(-1,"This will export all hardware id's to a comma delimited file."& @CR _
		& "This export format is best used to gather limited information quickly","",1)
	$button_csvopt = GUICtrlCreateButton("More",60,134,35,15,$BS_FLAT)
	$checkbox_export_sysprep = GUICtrlCreateCheckbox("Sysprep",120,132,60,20)
		GUICtrlSetFont(-1, 8.5, 400,1, $font)
		GUICtrlSetTip(-1,"This will export ONLY class types SCSIAdapter and HDC to the Sysprep.inf file."& @CR _
		& "This export format will not create ANY duplicate HWIDS."& @CR _
		& "You must still run sysprep -bmsd to gather built HWIDS built into windows." & @CR _
		&"We also advise that you use sysprep -clean in your cmdlines.txt to clean out unused hardware id's.","",1)
	$button_sysprepopt = GUICtrlCreateButton("More",185,134,35,15,$BS_FLAT)
GUICtrlCreateGroup("", -99, -99, 1, 1) ; close group

; Create Class Filters
GUICtrlCreateGroup("Type Your Class Filters",5,165,322,48)
	GUICtrlSetFont(-1, 9, 400,1, $font)
	$ClassFilterInput = GUICtrlCreateInput("",10,188,255,20)
		GUICtrlSetFont(-1, 8.5, 400,1, $font)
		GUICtrlSetTip(-1,"Please type the classes you would like to export, seperating each with a Pipe symbol."& @CRLF _
		&"There must be no spaces between the end of the one class and the start of another."& @CRLF _
		&"If nothing is entered, the input is blank, then the program will find ALL classes for export"& @CRLF _
		&"A listing of Classes can be found using the information button with a question mark next to this input box"& @CRLF & @CRLF _
		&"Blank => Is the default for finding ALL Classes"& @CRLF &"System|HDC|FDC => Finds three classes System and HDC and FDC","",1)
	$ClassFilterInfo = GUICtrlCreateButton("?",270,188,20,20,$BS_FLAT)
		GUICtrlSetFont(-1, 8.5, 400,1, $font)
		GUICtrlSetTip(-1,"Please click to find a listing of (but not limited to) Classes for input","",1)
	$ClassFilterInput_Clear = GUICtrlCreateButton("CLR",295,188,25,20,$BS_FLAT)
		GUICtrlSetFont(-1, 8.5, 400,1, $font)
		GUICtrlSetTip(-1,"Clear Class Filters","",1)
GUICtrlCreateGroup("", -99, -99, 1, 1) ; close group

; Create PNP Filters
GUICtrlCreateGroup("Type Your PNP ID Filters",5,223,322,48)
	GUICtrlSetFont(-1, 9, 400,1, $font)
	$PNPFilterInput = GUICtrlCreateInput("",10,245,255,20)
		GUICtrlSetFont(-1, 8.5, 400,1, $font)
		GUICtrlSetTip(-1,"Please type the PNP ID types you would like to export, seperating each with a Pipe symbol."& @CRLF _
		&"There must be no spaces between the end of the one PNP ID and the start of another."& @CRLF _
		&"If nothing is entered, the input is blank, then the program will find ALL PNP IDs for export"& @CRLF _
		&"A listing of PNP IDs can be found using the information button with a question mark next to this input box"& @CRLF & @CRLF _
		&"Blank => Is the default for finding ALL PNP IDs"& @CRLF &"PCI\VEN|ISAPNP\|USB\ => Finds three PNP IDs PCI\VEN and ISAPNP\ and USB\","",1)
	$PNPFilterInfo = GUICtrlCreateButton("?",270,245,20,20,$BS_FLAT)
		GUICtrlSetFont(-1, 8.5, 400,1, $font)
		GUICtrlSetTip(-1,"Please click to find a listing of (but not limited to) PNP types for input","",1)
	$PNPFilterInput_Clear = GUICtrlCreateButton("CLR",295,245,25,20,$BS_FLAT)
		GUICtrlSetFont(-1, 8.5, 400,1, $font)
		GUICtrlSetTip(-1,"Clear PNP ID Filters","",1)
GUICtrlCreateGroup("", -99, -99, 1, 1) ; close group

; Create Other Filters
GUICtrlCreateGroup("Other Filters",5,282,322,220)
	GUICtrlSetFont(-1, 9, 400,1, $font)
	$Filter_CurrentHardware_CheckBox = GUICtrlCreateCheckbox("Only include hardware currently installed",10,303,250,20)
		GUICtrlSetFont(-1, 8.5, 400,1, $font)
		GUICtrlSetTip(-1,"Check this box on to export only the current hardware installed in the system."& @CRLF _
		&"For export type sysprep it will ony export classes HDC and SCSIAdapter.","",1)
	$Filter_CurrentHardware_MoreButton = GUICtrlCreateButton("Export",270,303,50,20,$BS_FLAT)
		GUICtrlSetFont(-1, 8.5, 400,1, $font)
		GUICtrlSetTip(-1,"Click to Export a log file of the current hardware you have in your system."& @CRLF _
		&"This is useful for testing and troubleshooting purposes. When scan is completed it will open the file for viewing." & @CRLF _
		&"The file will be exported to a file named Hardware.log at the current directory FindHWIDS is being run from","",1)
	$Filter_OStypeAndArch_CheckBox = GUICtrlCreateCheckbox("Auto select your OS Version and Processor Architecture",10,325,290,20)
		GUICtrlSetFont(-1, 8.5, 400,1, $font)
		GUICtrlSetTip(-1,"Check this box on to automatically export only the current OS Version and Processor Architecture." & @CRLF _
		& "You must select both an OS version and Processor Architecture. The selections will gather OS version base, ie. .NT.5.2, " & @CRLF _
		& "processor arch, as well as the specified processor arch, ie. .NTamd64.5.2","",1)
	GUICtrlCreateLabel("ARCH", 15, 349, 40, 50)
		GUICtrlSetFont(-1, 8, 600, 1, $font)
	$Filter_OStypeAndArch_x86 = GUICtrlCreateCheckbox("X86",60,345,60,25)
	$Filter_OStypeAndArch_amd64 = GUICtrlCreateCheckbox("X64 (referred to as AMD64)",60,365,150,25)
	$Filter_OStypeAndArch_ia64 = GUICtrlCreateCheckbox("IA64 (Itanium only)",60,385,120,25)
	GUICtrlCreateLabel("OS", 15, 422, 40, 50)
		GUICtrlSetFont(-1, 8, 600, 1, $font)
	$Filter_OStypeAndArch_2000 = GUICtrlCreateCheckbox("2000",60,416,60,25)
	$Filter_OStypeAndArch_xp = GUICtrlCreateCheckbox("XP",60,436,60,25)
	$Filter_OStypeAndArch_2003 = GUICtrlCreateCheckbox("2003",60,456,60,25)
	$Filter_OStypeAndArch_vista = GUICtrlCreateCheckbox("Vista/2008/7",60,476,100,24)
GUICtrlCreateGroup("", -99, -99, 1, 1) ; close group

; Create Start button
$Button_Start_Scan = GUICtrlCreateButton("Start",350,65,90,20,$BS_FLAT)
	GUICtrlSetFont(-1, 9, 600,1, $font)
	GUICtrlSetTip(-1,"Start Processing Driver Folders","",1)

; Create About button
$Button_About = GUICtrlCreateButton("About",350,95,90,20,$BS_FLAT)
	GUICtrlSetFont(-1, 9, 600,1, $font)
	GUICtrlSetTip(-1,"Open the Read Me file","",1)

; Create Exit button
$Button_Exit = GUICtrlCreateButton("Exit",350,125,90,20,$BS_FLAT)
	GUICtrlSetFont(-1, 9, 600,1, $font)
	GUICtrlSetTip(-1,"Exit the FindHWIDS","",1)
#cs
; Create Read DevicePath button
$Button_ReadDevicePath = GUICtrlCreateButton("Query Registry DevicePath",340,230,110,44,$BS_FLAT + $BS_MULTILINE)
	GUICtrlSetFont(-1, 9, 600,1, $font)
	GUICtrlSetTip(-1,"Query Registry DEVICEPATH for Drivers listed for automated Windows driver installations","",1)

;
$Button_SetDevicePath = GUICtrlCreateButton("Set Registry DevicePath",340,280,110,44,$BS_FLAT + $BS_MULTILINE)
	GUICtrlSetFont(-1, 9, 600,1, $font)
	GUICtrlSetTip(-1,"Set Registry DEVICEPATH for Driver listed for automated Windows driver installations."&@CRLF&"Will use location(s) specified in the input area.","",1)
#ce

; Create Status Area
$defaultstatus = " Ready"
$statuslabel = GUICtrlCreateLabel($defaultstatus, 0, 542, 460, 16, BitOR($SS_SIMPLE, $SS_SUNKEN))
	GUICtrlSetFont(-1, 8.5, 400,1, $font)
$win_main_progress = GUICtrlCreateProgress(0, 522, 460, 20)
	GUICtrlSetData(-1,0)
	GUICtrlSetColor(-1,0x000000)

; Create Banner
	GUICtrlCreatePic(@TempDir & "\FindHWIDS\IMAGE\logo_fhwid.jpg", 0, 0, 460, 50);Heading Image


; ------- Set GUI Defaults
	Select
		Case FileExists("C:\D") ; Set Default Location
			GUICtrlSetData($LocationInput,"C:\D")
		Case FileExists(@WindowsDir &"\INF")
			GUICtrlSetData($LocationInput,@WindowsDir &"\INF")
		Case Else
			GUICtrlSetData($LocationInput,". . .")
	EndSelect
	GUICtrlSetState($checkbox_export_csv, $GUI_Checked) ; Set Default Scan Export as CSV


; ------ Start MAIN GUI
GUISetState() ;----> Start GUI
GUICtrlSetState($Button_Start_Scan,$GUI_FOCUS)


; ------ Create CSV Window
$win_csv = guicreate("FindHWIDS - CSV Options",400,200, -1, -1,$WS_POPUPWINDOW+$WS_DISABLED,$WS_EX_TOPMOST,$MainWindow)
	GUISetBkColor(0xFFFFFF)
	$win_csv_title = GUICtrlCreateLabel("CSV Export Options",10,10,200,30)
		GUICtrlSetFont(-1, 12, 800,1, $font)
	GUICtrlCreateGroup("CSV File Location",5,40,390,48) ; begin group
		GUICtrlSetFont(-1, 9, 400,1, $font)
	 $win_csvfile_input = GUICtrlCreateInput($CSVLoc,15,60,275,20)
		GUICtrlSetFont(-1, 8.5, 400,1, $font)
		GUICtrlSetTip(-1,"","",1)
	 $win_csv_file_button = GUICtrlCreateButton("...",295,60,20,20,$BS_FLAT)
		GUICtrlSetFont(-1, 8.5, 400,1, $font)
	 $win_csv_file_clear_button = GUICtrlCreateButton("CLR",320,60,25,20,$BS_FLAT)
		GUICtrlSetFont(-1, 8.5, 400,1, $font)
	 $win_csv_file_reset_button = GUICtrlCreateButton("Reset",350,60,35,20,$BS_FLAT)
		GUICtrlSetFont(-1, 8.5, 400,1, $font)
	GUICtrlCreateGroup("", -99, -99, 1, 1) ; close group
	$win_csv_button_return = GUICtrlCreateButton("Return",330,170,60,20,$BS_FLAT)
			GUICtrlSetFont(-1, 9, 600,1, $font)
			GUICtrlSetTip(-1,"Return to Main Window","",1)
	GuisetState(@SW_HIDE,$win_csv)


; ------ Create Sysprep Window
$win_sysprep = guicreate("FindHWIDS - Sysprep Options",400,200, -1, -1, $WS_POPUPWINDOW+$WS_DISABLED,$WS_EX_TOPMOST,$MainWindow)
	GUISetBkColor(0xFFFFFF)
	$win_sysprep_title = GUICtrlCreateLabel("Sysprep Export Options",10,10,200,30)
		GUICtrlSetFont(-1, 12, 800,1, $font)
	GUICtrlCreateGroup("Sysprep File Location",5,40,390,48) ; begin group
		GUICtrlSetFont(-1, 9, 400,1, $font)
	 $win_sysprepfile_input = GUICtrlCreateInput($SysprepLoc,15,60,275,20)
		GUICtrlSetFont(-1, 8.5, 400,1, $font)
		GUICtrlSetTip(-1,"","",1)
	 $win_sysprep_file_button = GUICtrlCreateButton("...",295,60,20,20,$BS_FLAT)
		GUICtrlSetFont(-1, 8.5, 400,1, $font)
	 $win_sysprep_file_clear_button = GUICtrlCreateButton("CLR",320,60,25,20,$BS_FLAT)
		GUICtrlSetFont(-1, 8.5, 400,1, $font)
	 $win_sysprep_file_reset_button = GUICtrlCreateButton("Reset",350,60,35,20,$BS_FLAT)
		GUICtrlSetFont(-1, 8.5, 400,1, $font)
	GUICtrlCreateGroup("", -99, -99, 1, 1) ; close group
	$win_sysprep_button_return = GUICtrlCreateButton("Return",330,170,60,20,$BS_FLAT)
			GUICtrlSetFont(-1, 9, 600,1, $font)
			GUICtrlSetTip(-1,"Return to Main Window","",1)
GuisetState(@SW_HIDE,$win_sysprep)


While 1
	$msg = GUIGetMsg()

	Select

		Case $msg = $GUI_EVENT_CLOSE ; -----> Close program via the X
			_Exit_Scan()

		Case $msg = $Button_Exit; -----> Close program via the X
			_Exit_Scan()

		Case $msg = $Button_Choose_Location
			$ChooseScanType = Msgbox(4+32+262144,"FindHWIDS","Are you looking for Hardware ID's in a specific INF file?")
			$LocationInput_Current = GUICtrlRead($LocationInput)
			WinSetState($MainWindow,'',@SW_HIDE)
			Select
				Case $ChooseScanType = 6 ; Yes
					$SearchLocation = FileOpenDialog("Choose a file to scan",$root,"INF (*.inf)", 1)
				Case $ChooseScanType = 7 ; No
					$SearchLocation = FileSelectFolder("Choose a scan location",$root,2,@workingdir)
			EndSelect
			WinSetState($MainWindow,'',@SW_SHOW)
			Select
				Case $LocationInput_Current <> "" and StringRight($LocationInput_Current,1) = "|"
					GUICtrlSetData($LocationInput,$LocationInput_Current & $SearchLocation)
				Case $LocationInput_Current <> "" and StringRight($LocationInput_Current,1) <> "|"
					GUICtrlSetData($LocationInput,$LocationInput_Current & "|" & $SearchLocation)
				Case Else
					GUICtrlSetData($LocationInput,$SearchLocation)
			EndSelect

		Case $msg = $Button_Clear_Location
			GUICtrlSetBkColor($LocationInput,0xFFFCCC)
			sleep(250)
			GUICtrlSetData($LocationInput,"")
			GUICtrlSetBkColor($LocationInput,0xFFFFFF)

		Case $msg = $ClassFilterInput_Clear
			GUICtrlSetBkColor($ClassFilterInput,0xFFFCCC)
			sleep(250)
			GUICtrlSetData($ClassFilterInput,"")
			GUICtrlSetBkColor($ClassFilterInput,0xFFFFFF)

		Case $msg = $PNPFilterInput_Clear
			GUICtrlSetBkColor($PNPFilterInput,0xFFFCCC)
			sleep(250)
			GUICtrlSetData($PNPFilterInput,"")
			GUICtrlSetBkColor($PNPFilterInput,0xFFFFFF)

		Case $msg = $Button_Start_Scan
			WinSetState($MainWindow,'',@SW_MINIMIZE)
			$orig_process = _ProcessGetPriority(@AutoItPID) ; Get current process speed
			ProcessSetPriority (@AutoItPID, 4) ; set process speed to high
			ReadandSave()
			_FindHWIDS($INFLocationRead,$SysprepFileLocRead,$CSVFileLocRead,$HtmlLoc,$Check_ExportToSysprep,$Check_ExportToCSV,$Check_ExportToHtml,$ClassFiltersRead,$PNPFilterRead,$CurrentHardware_CheckBox,1,$OStypeAndArch_CheckBox,$Filter_X86_box,$Filter_AMD64_box,$Filter_IA64_box,$Filter_W2k_box,$Filter_XP_box,$Filter_W2k3_box,$Filter_Vi_box)
			ProcessSetPriority (@AutoItPID, $orig_process) ; Restore Process speed
			GuiSetState(@SW_HIDE,$win_sysprep)
			GuiSetState(@SW_DISABLE,$win_sysprep)
			GuiSetState(@SW_HIDE,$win_csv)
			GuiSetState(@SW_DISABLE,$win_csv)
			WinSetState($MainWindow,'',@SW_RESTORE)

		Case $msg = $Filter_CurrentHardware_MoreButton
			dim $aFindCurrentHardware[1]
			_Read_PNP_Items($aFindCurrentHardware,$HardwareLoc,0,1)

		Case $msg = $ClassFilterInfo
			Msgbox(64+262144,"FindHWIDS","Please type the classes you would like to export, separating each with a Pipe symbol."& @CRLF &"There must be no spaces between the end of the one class and the start of another."& @CRLF &"If nothing is entered, the input is blank, then the program will find ALL classes for export"& @CRLF & @CRLF&"Class  => Description of Class"& @CRLF& @CRLF _
			& "Battery   => Battery Devices"& @CRLF _
			& "Biometric   => Biometric Devices"& @CRLF _
			& "Bluetooth   => Bluetooth Devices"& @CRLF _
			& "CDROM   => CD-ROM Drives"& @CRLF _
			& "DiskDrive   => Disk Drives"& @CRLF _
			& "Display   => Display Adapter"& @CRLF _
			& "FDC   => Floppy Disk Controllers"& @CRLF _
			& "FloppyDisk   => Floppy Disk Drives"& @CRLF _
			& "HDC   => Hard Disk Controllers"& @CRLF _
			& "HIDClass   => Human Interface Devices HID"& @CRLF _
			& "Dot4   => IEEE 1284.4 Devices"& @CRLF _
			& "Dot4Print   => IEEE 1284.4 Print Functions"& @CRLF _
			& "61883   => IEEE 1394 Devices That Support the 61883 Protocol"& @CRLF _
			& "AVC   => IEEE 1394 Devices That Support the AVC Protocol"& @CRLF _
			& "SBP2   => IEEE 1394 Devices That Support the SBP2 Protocol"& @CRLF _
			& "1394   => IEEE 1394 Host Bus Controller"& @CRLF _
			& "Image   => Imaging Device"& @CRLF _
			& "Infrared   => IrDA Devices"& @CRLF _
			& "Keyboard   => Keyboard"& @CRLF _
			& "MediumChanger   => Media Changers"& @CRLF _
			& "MTD   => Memory Technology Driver "& @CRLF _
			& "Modem   => Modem"& @CRLF _
			& "Monitor   => Monitor"& @CRLF _
			& "Mouse   => Mouse"& @CRLF _
			& "Multifunction   => Multifunction Devices"& @CRLF _
			& "Media   => Multimedia"& @CRLF _
			& "MultiportSerial   => Multiport Serial Adapters"& @CRLF _
			& "Net   => Network Adapter"& @CRLF _
			& "NetClient   => Network Client"& @CRLF _
			& "NetService   => Network Service"& @CRLF _
			& "NetTrans   => Network Transport"& @CRLF _
			& "Security_Accelerator   => PCI SSL Accelerator"& @CRLF _
			& "PCMCIA   => PCMCIA Adapters"& @CRLF _
			& "Ports   => Ports (COM & LPT ports)"& @CRLF _
			& "Printer   => Printers"& @CRLF _
			& "PNPPrinters   => Printers, Bus-specific class drivers"& @CRLF _
			& "Processor   => Processors"& @CRLF _
			& "Sensor   => Sensors"& @CRLF _
			& "SCSIAdapter   => SCSI and RAID Controllers"& @CRLF _
			& "SideShow   => Windows Slideshow" & @CRLF _
			& "SmartCardReader   => Smart Card Readers"& @CRLF _
			& "Volume   => Storage Volumes"& @CRLF _
			& "System   => System Devices"& @CRLF _
			& "TapeDrive   => Tape Drives"& @CRLF _
			& "USBDevice   => USB Device"& @CRLF _
			& "WCEUSBS   => Windows CE USB ActiveSync Devices"& @CRLF _
			& "WPD   => Windows Portable Devices")

		Case $msg = $PNPFilterInfo
			Msgbox(64+262144,"FindHWIDS","Please type the PNP ID or multiple IDs you would like to export, seperating multiple IDs each with a Pipe symbol."& @CRLF _
			&"There must be no spaces between the end of the one class and the start of another."& @CRLF _
			&"If nothing is entered, the input is blank, then the program will find ALL PNP IDs for export"& @CRLF _
			&"You can use this filter WITH or WITHOUT the other filters."& @CRLF _
			&"The program will search each of your PNP ID(s) and will search the entire string."& @CRLF _
			&"Please be aware that entering USB will find both USB\ and USBSTOR\. Or SUBSYS_1495103C will also find ID with SUBSYS_1495103C&REV_04."& @CRLF & @CRLF _
			&"Example starting PNP IDs:"& @CRLF _
			&"ISAPNP\"& @CRLF _
			&"USBSTOR\"& @CRLF _
			&"PCIIDE\"& @CRLF _
			&"IDE\"& @CRLF _
			&"PCI\VEN"& @CRLF _
			&"Display\"& @CRLF _
			&"USB\"& @CRLF _
			&"HID\"& @CRLF _
			&"AHCI\"& @CRLF _
			&"ACPI\"& @CRLF _
			&"ROOT\"& @CRLF _
			&"SCSI\"& @CRLF _
			&"*")

		Case $msg = $Button_About
			Select
				Case FileExists(@windowsdir &"\notepad.exe")
					Run("notepad.exe "& @tempdir &"\FindHWIDS\BIN\ReadMe.txt")
			EndSelect

		Case $msg = $Filter_OStypeAndArch_CheckBox
			$Read_FilterOStypeAndArch_CheckBox = GuiCtrlread($Filter_OStypeAndArch_CheckBox)
			Switch $Read_FilterOStypeAndArch_CheckBox
				Case 1 ; Checked, disable option to choose os type and arch
					GuiCtrlSetState($Filter_OStypeAndArch_x86,$GUI_DISABLE)
						GuiCtrlSetState($Filter_OStypeAndArch_x86,$GUI_UNCHECKED)
					GuiCtrlSetState($Filter_OStypeAndArch_amd64,$GUI_DISABLE)
						GuiCtrlSetState($Filter_OStypeAndArch_amd64,$GUI_UNCHECKED)
					GuiCtrlSetState($Filter_OStypeAndArch_ia64,$GUI_DISABLE)
						GuiCtrlSetState($Filter_OStypeAndArch_ia64,$GUI_UNCHECKED)
					GuiCtrlSetState($Filter_OStypeAndArch_2000,$GUI_DISABLE)
						GuiCtrlSetState($Filter_OStypeAndArch_2000,$GUI_UNCHECKED)
					GuiCtrlSetState($Filter_OStypeAndArch_xp,$GUI_DISABLE)
						GuiCtrlSetState($Filter_OStypeAndArch_xp,$GUI_UNCHECKED)
					GuiCtrlSetState($Filter_OStypeAndArch_2003,$GUI_DISABLE)
						GuiCtrlSetState($Filter_OStypeAndArch_2003,$GUI_UNCHECKED)
					GuiCtrlSetState($Filter_OStypeAndArch_vista,$GUI_DISABLE)
						GuiCtrlSetState($Filter_OStypeAndArch_vista,$GUI_UNCHECKED)
				Case 4 ; Unchecked, enable checkboxes to choose os type and arch
					GuiCtrlSetState($Filter_OStypeAndArch_x86,$GUI_ENABLE)
					GuiCtrlSetState($Filter_OStypeAndArch_amd64,$GUI_ENABLE)
					GuiCtrlSetState($Filter_OStypeAndArch_ia64,$GUI_ENABLE)
					GuiCtrlSetState($Filter_OStypeAndArch_2000,$GUI_ENABLE)
					GuiCtrlSetState($Filter_OStypeAndArch_xp,$GUI_ENABLE)
					GuiCtrlSetState($Filter_OStypeAndArch_2003,$GUI_ENABLE)
					GuiCtrlSetState($Filter_OStypeAndArch_vista,$GUI_ENABLE)
			EndSwitch

		; Start Window CSV
		Case $msg = $button_csvopt
			GuiSetState(@SW_DISABLE,$MainWindow)
			GuiSetState(@SW_ENABLE,$win_csv)
			GuiSetState(@SW_SHOW,$win_csv)

		Case $msg = $win_csv_button_return
			GuiSetState(@SW_HIDE,$win_csv)
			GuiSetState(@SW_DISABLE,$win_csv)
			GuiSetState(@SW_ENABLE,$MainWindow)
			GuiSetState(@SW_RESTORE,$MainWindow)

		Case $msg = $win_csv_file_button
			GuiSetState(@SW_HIDE,$win_csv)
			GuiSetState(@SW_Hide,$MainWindow)
			$read_win_csvfile_input = GuiCtrlread($win_csvfile_input)
			$read_win_csvfile_input = FileOpenDialog( "Choose or Create a File", $read_win_csvfile_input, "CSV (*.csv)", 8)
			GuictrlSetData($win_csvfile_input,$read_win_csvfile_input)
			GuiSetState(@SW_SHOW,$win_csv)
			GuiSetState(@SW_SHOW,$MainWindow)

		Case $msg = $win_csv_file_clear_button
			GUICtrlSetBkColor($win_csvfile_input,0xFFFCCC)
			sleep(250)
			GUICtrlSetData($win_csvfile_input,"")
			GUICtrlSetBkColor($win_csvfile_input,0xFFFFFF)

		Case $msg = $win_csv_file_reset_button
			GUICtrlSetBkColor($win_csvfile_input,0xFFFCCC)
			sleep(250)
			GUICtrlSetData($win_csvfile_input,@scriptdir &"\FindHWIDS-"& @YEAR &"-"&@MON&"-"&@MDAY&"-"&@HOUR&@MIN&@SEC&".csv")
			GUICtrlSetBkColor($win_csvfile_input,0xFFFFFF)

		; Start Window Sysprep
		Case $msg = $button_sysprepopt
			GuiSetState(@SW_DISABLE,$MainWindow)
			GuiSetState(@SW_ENABLE,$win_sysprep)
			GuiSetState(@SW_SHOW,$win_sysprep)

		Case $msg = $win_sysprep_button_return
			GuiSetState(@SW_HIDE,$win_sysprep)
			GuiSetState(@SW_DISABLE,$win_sysprep)
			GuiSetState(@SW_ENABLE,$MainWindow)
			GuiSetState(@SW_RESTORE,$MainWindow)

		Case $msg = $win_sysprep_file_button
			GuiSetState(@SW_HIDE,$win_sysprep)
			GuiSetState(@SW_Hide,$MainWindow)
			$read_win_sysprepfile_input = GuiCtrlread($win_sysprepfile_input)
			$read_win_sysprepfile_input = FileOpenDialog( "Choose or Create a File", $read_win_sysprepfile_input, "Sysprep (*.inf)", 8)
			GuictrlSetData($win_sysprepfile_input,$read_win_sysprepfile_input)
			GuiSetState(@SW_SHOW,$win_sysprep)
			GuiSetState(@SW_SHOW,$MainWindow)

		Case $msg = $win_sysprep_file_clear_button
			GUICtrlSetBkColor($win_sysprepfile_input,0xFFFCCC)
			sleep(250)
			GUICtrlSetData($win_sysprepfile_input,"")
			GUICtrlSetBkColor($win_sysprepfile_input,0xFFFFFF)

		Case $msg = $win_sysprep_file_reset_button
			GUICtrlSetBkColor($win_sysprepfile_input,0xFFFCCC)
			sleep(250)
			GUICtrlSetData($win_sysprepfile_input,"C:\Sysprep\sysprep.inf")
			GUICtrlSetBkColor($win_sysprepfile_input,0xFFFFFF)

	EndSelect

WEnd




;; ========================================================== DO NOT EDIT BELOW THESE LINES =================================================================
;; ==========================================================================================================================================================

; ------------------ Grab settings from UI
Func ReadandSave() ; data entered into scan function

	$INFLocationRead = GUICtrlRead($LocationInput)
	$ClassFiltersRead = GUICtrlRead($ClassFilterInput)
	$PNPFilterRead = GUICtrlRead($PNPFilterInput)
	$CSVFileLocRead = GUICtrlRead($win_csvfile_input)
	$SysprepFileLocRead = GUICtrlRead($win_sysprepfile_input)

	$Read_FilterOStypeAndArch_CheckBox = GUICtrlRead($Filter_OStypeAndArch_CheckBox)
	Select
		Case $Read_FilterOStypeAndArch_CheckBox = $GUI_Checked
			$OStypeAndArch_CheckBox = 1
		Case Else ;$Read_FilterOStypeAndArch_CheckBox = $GUI_UnChecked Then
			$OStypeAndArch_CheckBox = 0
	EndSelect

	$Read_Filter_OStypeAndArch_x86 = GUICtrlRead($Filter_OStypeAndArch_x86)
	Select
		Case $Read_Filter_OStypeAndArch_x86 = $GUI_Checked
			$Filter_X86_box = 1
			$OStypeAndArch_CheckBox = 0
		Case Else
			$Filter_X86_box = 0
	EndSelect

	$Read_Filter_OStypeAndArch_amd64 = GUICtrlRead($Filter_OStypeAndArch_amd64)
	Select
		Case $Read_Filter_OStypeAndArch_amd64 = $GUI_Checked
			$Filter_AMD64_box = 1
			$OStypeAndArch_CheckBox = 0
		Case Else
			$Filter_AMD64_box = 0
	EndSelect

	$Read_Filter_OStypeAndArch_ia64 = GUICtrlRead($Filter_OStypeAndArch_ia64)
	Select
		Case $Read_Filter_OStypeAndArch_ia64 = $GUI_Checked
			$Filter_IA64_box = 1
			$OStypeAndArch_CheckBox = 0
		Case Else
			$Filter_IA64_box = 0
	EndSelect

	$Read_Filter_OStypeAndArch_2000 = GUICtrlRead($Filter_OStypeAndArch_2000)
	Select
		Case $Read_Filter_OStypeAndArch_2000 = $GUI_Checked
			$Filter_W2k_box = 1
			$OStypeAndArch_CheckBox = 0
		Case Else
			$Filter_W2k_box = 0
	EndSelect

	$Read_Filter_OStypeAndArch_xp = GUICtrlRead($Filter_OStypeAndArch_xp)
	Select
		Case $Read_Filter_OStypeAndArch_xp = $GUI_Checked
			$Filter_XP_box = 1
			$OStypeAndArch_CheckBox = 0
		Case Else
			$Filter_XP_box = 0
	EndSelect

	$Read_Filter_OStypeAndArch_2003 = GUICtrlRead($Filter_OStypeAndArch_2003)
	Select
		Case $Read_Filter_OStypeAndArch_2003 = $GUI_Checked
			$Filter_W2k3_box = 1
			$OStypeAndArch_CheckBox = 0
		Case Else
			$Filter_W2k3_box = 0
	EndSelect

	$Read_Filter_OStypeAndArch_vista = GUICtrlRead($Filter_OStypeAndArch_vista)
	Select
		Case $Read_Filter_OStypeAndArch_vista = $GUI_Checked
			$Filter_Vi_box = 1
			$OStypeAndArch_CheckBox = 0
		Case Else
			$Filter_Vi_box = 0
	EndSelect

	$Read_Filter_CurrentHardware_CheckBox = GUICtrlRead($Filter_CurrentHardware_CheckBox) ;-- Restart Machine Checkbox
	Select
		Case $Read_Filter_CurrentHardware_CheckBox = $GUI_Checked
			$CurrentHardware_CheckBox = 1
		Case Else ;$Read_Filter_CurrentHardware_CheckBox = $GUI_UnChecked Then
			$CurrentHardware_CheckBox = 0
	EndSelect

	$Read_Export_CSV = GUICtrlRead($checkbox_export_csv)
	If $Read_Export_CSV = $GUI_Checked Then
		$Check_ExportToCSV = 1
		;IniWrite($DriverINI, "Settings", "ExportType", $INFLocationRead)
	Else
		$Check_ExportToCSV = 0
	EndIf

	$Read_Export_Sysprep = GUICtrlRead($checkbox_export_sysprep)
	If $Read_Export_Sysprep = $GUI_Checked Then
		$Check_ExportToSysprep = 1
		;IniWrite($DriverINI, "Settings", "ExportType", $INFLocationRead)
	Else
		$Check_ExportToSysprep = 0
	EndIf

EndFunc

; ------------------ Future to pull from INI and auto run
Func ReadandSetINI()

EndFunc

; ------------------ Finds HWIDS based on location of files, filtered by classes, os type/arch, current hardware
; ------------------ Function to grab HWIDS with pass through variable
Func _FindHWIDS($vDriverLocation,$vExportToSysprepLoc,$vExportToCSVLoc,$vExportToHtmlLoc, $vExportToSysprep=0,$vExportToCSV=0,$vExportToHtml=0, $sChosenHWIDClass="",$sChosenPNPTypes="",$iReadCurrentHardware=0,$iChecksumFile=1,$iFilterOStypeAndArch=0,$Filter_X86=0,$Filter_AMD64=0,$Filter_IA64=0,$Filter_W2k=0,$Filter_XP=0,$Filter_W2k3=0,$Filter_Vi=0)

; ------ Local Vars
		Local $aDrvrReadFile, $ayArray, $ScannedHWIDS = 0 , $ScannedINFFiles = -1, $aReadCurrentHardware[1], $INF_Install_List
		;Local $Filter_X86
		;Local $Filter_AMD64
		;Local $Filter_IA64
		;Local $Filter_W2k
		;Local $Filter_XP
		;Local $Filter_W2k3
		;Local $Filter_Vi

		$ShowChosen = 0
		IF $ShowChosen = 1 Then
			$msg = "Options Chosen"
			If $vExportToSysprep = 1 Then
				$msg = $msg & @CRLF & "Export - Sysprep => Yes"
			Else
				$msg = $msg & @CRLF & "Export - Sysprep => No"
			Endif
			If $vExportToCSV = 1 Then
				$msg = $msg & @CRLF & "Export - CSV => Yes"
			Else
				$msg = $msg & @CRLF & "Export - CSV => No"
			Endif
			If $sChosenHWIDClass = "" Then
				$msg = $msg & @CRLF & "Filter - Classes => None"
			Else
				$msg = $msg & @CRLF & "Filter - Classes => "& $sChosenHWIDClass
			Endif
			If $sChosenPNPTypes = "" Then
				$msg = $msg & @CRLF & "Filter - PNP IDs => None"
			Else
				$msg = $msg & @CRLF & "Filter - PNP IDs => "& $sChosenPNPTypes
			Endif
			If $iFilterOStypeAndArch = 1 Then
				$msg = $msg & @CRLF & "Filter - OS Type and OS Arch => Yes"
			Else
				$msg = $msg & @CRLF & "Filter - OS Type and OS Arch => No"
			Endif
			If $iReadCurrentHardware = 1 Then
				$msg = $msg & @CRLF & "Filter - Read Current Hardware => Yes"
			Else
				$msg = $msg & @CRLF & "Filter - Read Current Hardware => No"
			Endif
			If $iChecksumFile = 1 Then
				$msg = $msg & @CRLF & "Option - Checksum File => Yes"
			Else
				$msg = $msg & @CRLF & "Option - Checksum File => No"
			Endif
			msgbox(0,"Found Selections",$msg)
		Endif


; ------ Return Function if no Exports are selected
		If $vExportToSysprep=0 and $vExportToCSV=0 Then ; $vExportToHTML=0
			Msgbox(48+262144,"FindHWIDS","No export type has been chosen. Please select at least one export type.")
			GUICtrlSetData($statuslabel, " Ready")
			return
		Endif

; ------ Read Current Hardware ; Options are 1 for YES or 0 for NO ; NO is default
		Select
			Case $iReadCurrentHardware = 1 and $vExportToSysprep = 1 ; Yes to Sysprep
				_Read_PNP_Items($aReadCurrentHardware,$HardwareLoc,1) ; Filter for Sysprep only grabbing SCSIAdapter,HDC

			Case $iReadCurrentHardware = 1
				_Read_PNP_Items($aReadCurrentHardware,$HardwareLoc,0) ; Find ALL

		EndSelect


; ------ Split $sChosenHWIDClass for HWID Class types to search for, Clicking Sysprep will override
		Select
			Case $sChosenHWIDClass <> "" and StringInStr($sChosenHWIDClass,"|")<>0 ;and $vExportToSysprep = 1 ; For Multiple Classes
				$sChosenHWIDClass = StringSplit($sChosenHWIDClass,"|")

			Case $sChosenHWIDClass <> "" and StringInStr($sChosenHWIDClass,"|")=0 ;and $vExportToSysprep = 1 ; For One Class
				$sChosenHWIDClass = StringSplit($sChosenHWIDClass &"|","|")

		EndSelect ; Blank means everything


; ------ Split $sChosenPNPTypes for PNP types to search for
		Select
			Case $sChosenPNPTypes <> "" and StringInStr($sChosenPNPTypes,"|")<>0 ; For Multiple PNP IDs
				$sChosenPNPTypes = StringSplit($sChosenPNPTypes,"|")

			Case $sChosenPNPTypes <> "" and StringInStr($sChosenPNPTypes,"|")=0 ; For One PNP IDs
				;$sChosenPNPTypes = StringSplit($sChosenPNPTypes &",",",")
				$sChosenPNPTypesOne = $sChosenPNPTypes
				dim $sChosenPNPTypes[2]
				$sChosenPNPTypes[0] = 1
				$sChosenPNPTypes[1] = $sChosenPNPTypesOne

		EndSelect ; Blank means everything

TraySetIcon(@tempdir &"\FindHWIDS\ICO\processing.ico")

; ------ Start Timer
		$begin = TimerInit()
		GuiCtrlSetData($statuslabel," Processing... Please wait!")


; ------ Scan file or folder at location specified and save to array
		Select
			; ------ Start scan on multiple input files/folders
			Case StringinStr($vDriverLocation,"|")
				$aMultipleInputLocation = StringSplit($vDriverLocation,"|")
				dim $aMultipleInputLocation2[1]
				dim $aMultipleInputLocation3[1]
				For $iC1 = 1 to $aMultipleInputLocation[0]
					Select
						Case StringRight($aMultipleInputLocation[$iC1],4) <> ".inf" and FileExists($aMultipleInputLocation[$iC1]); Find Folder Location
							_ArrayAdd($aMultipleInputLocation2,$aMultipleInputLocation[$iC1])
							$aMultipleInputLocation2[0] = $aMultipleInputLocation2[0] + 1
						Case StringRight($aMultipleInputLocation[$iC1],4) = ".inf" and FileExists($aMultipleInputLocation[$iC1]); Find File Location
							_ArrayAdd($aMultipleInputLocation3,$aMultipleInputLocation[$iC1])
							$aMultipleInputLocation3[0] = $aMultipleInputLocation3[0] + 1
					EndSelect
				Next
				$aMultipleInputLocation = "" ; Get rid of old array taking up space
				dim $aFinalArray[1]
				For $iC2 = 1 to $aMultipleInputLocation2[0]
					;$aFoundINF = RecursiveFileSearch($aMultipleInputLocation2[$iC2], "(?i)\.inf", ".", 1)
					$aFoundINF = _RecFileListToArray($aMultipleInputLocation2[$iC2],"*.inf",1,1,0,2)
					;_ArrayDisplay($aFoundINF)
					_ArrayConcatenate($aFinalArray,$aFoundINF)
				Next
				Select
					Case $aMultipleInputLocation3[0] <> 0 or $aMultipleInputLocation3 <> ""
						_ArrayConcatenate($aFinalArray,$aMultipleInputLocation3)
				EndSelect
				$aMultipleInputLocation3 = "" ; Get rid of old array taking up space
				$aDrvrInf1 = $aFinalArray ; The array of inf files to scan

			; ------ Start for an individual file scan
			Case StringRight($vDriverLocation,4) = ".inf" and FileExists($vDriverLocation)
				$aDrvrInf1 = StringSplit($vDriverLocation &"|","|")

			Case StringRight($vDriverLocation,4) = ".inf" and NOT FileExists($vDriverLocation)
				Msgbox(48+262144,"FindHWIDS","File not found, please select a correct file path",5)
				WinSetState ("FindHWIDS","", @SW_RESTORE)
				return

			; ------ Start for an individual folder path scan
			Case FileExists($vDriverLocation)
				;$aDrvrInf1 = RecursiveFileSearch($vDriverLocation, "(?i)\.inf", ".", 1)
				;_FileWriteFromArray(@scriptdir &"\file1.txt",$aDrvrInf1)
				$aDrvrInf1 = _RecFileListToArray($vDriverLocation,"*.inf",1,1,0,2)
				;_FileWriteFromArray(@scriptdir &"\file2.txt",$aArray)
				;_ArrayDisplay($aDrvrInf1)

			Case NOT FileExists($vDriverLocation)
				Msgbox(48+262144,"FindHWIDS","Folder not found, please select a correct folder path",5)
				;ToolTip("")
				WinSetState ("FindHWIDS","", @SW_RESTORE)
				return

		EndSelect

		;$INF_ArraySize = Ubound($aDrvrInf1) - 1


; ------ Prepare Export Settings
	Dim $aSysprepPath, $aCSVPath, $szDrive, $szDir, $szFName, $szExt

	; ------  Export to Sysprep
		Select
			Case $vExportToSysprep = 1
				$aSysprepPath = _PathSplit($vExportToSysprepLoc, $szDrive, $szDir, $szFName, $szExt)

				Select
					Case $aSysprepPath[3] & $aSysprepPath[4] = "sysprep.inf"
						$vSysprepFileAttrib = FileGetAttrib($vExportToSysprepLoc)

						Select
							; If the file exists and it's read only warn the user we will not process for sysprep
							Case FileExists($vExportToSysprepLoc) and (StringInStr($vSysprepFileAttrib,"R") or @error)
								msgbox(48+262144,"FindHWIDS","WARNING! The location specified at "& $vExportToSysprepLoc & " Sysprep is not write enabled. Export to Sysprep will not be completed.",5)
								$vExportToSysprep = 0

							; If the file does not exist then create the folder structure and file
							Case NOT FileExists($vExportToSysprepLoc)
								dirCreate($aSysprepPath[1] & $aSysprepPath[2])
								_FileCreate($vExportToSysprepLoc)

								Select
									; If the file you tried to write doesn't exist let the user know the location isn't write enabled
									Case NOT FileExists($vExportToSysprepLoc)
										msgbox(48+262144,"FindHWIDS","WARNING! The location specified at "& $vExportToSysprepLoc & " Sysprep is not write enabled. Export to Sysprep will not be completed.",5)
										$vExportToSysprep = 0
								EndSelect

						EndSelect

					Case Else
						; If there is any other issue then warn the user of the possible issues
						msgbox(48+262144,"FindHWIDS","WARNING! The File specified at "& $vExportToSysprepLoc & " either:"& @CRLF _
							& "1) Does not have the correct filename and extension" & @CRLF _
							& "2) The location is not write enabled" & @CRLF _
							& "3) The location does not exist" & @CRLF _
							& "Export to Sysprep will not be completed.",5)
						$vExportToSysprep = 0

				EndSelect

			; If the file does not live at the default location to be processed by sysprep, warn the user
			Select
				Case $vExportToSysprepLoc <> "C:\Sysprep\sysprep.inf" and $vExportToSysprep = 1 ; and still exporting
					msgbox(48+262144,"FindHWIDS","Informational - Sysprep file at "& $vExportToSysprepLoc & " will not be processed by the Sysprep exe. Please move the file to the proper location.",5)
			EndSelect

		EndSelect


	; ------  Export to CSV
		Select
			Case $vExportToCSV = 1
				$aCSVPath = _PathSplit($vExportToCSVLoc, $szDrive, $szDir, $szFName, $szExt)

				Select
					Case $aCSVPath[4] = ".csv"
						$vCSVFileAttrib = FileGetAttrib($vExportToCSVLoc)

						Select
							Case FileExists($vExportToCSVLoc) and (StringInStr($vCSVFileAttrib,"R") or @error)
								msgbox(48+262144,"FindHWIDS","WARNING! The location specified at "& $vExportToCSVLoc & " CSV is not write enabled. Export to CSV will not be completed.",5)
								$vExportToCSV = 0

							Case Else
								FileDelete($vExportToCSVLoc)
								; Write the first line of the file in the specified location
								FileWriteLine($vExportToCSVLoc,"FullPath,INF Desc,Checksum,Driver Date,Driver Ver,PNPID,PNPID Desc,Class,ClassGUID,Manufacturer,Model,Provider,OS Signature,OS Arch")

								Select
									; If the file you tried to write doesn't exist let the user know the location isn't write enabled
									Case NOT FileExists($vExportToCSVLoc)
										msgbox(48+262144,"FindHWIDS","WARNING! The location specified at "& $vExportToCSVLoc & " CSV is not write enabled. Export to CSV will not be completed.",5)
										$vExportToCSV = 0
								EndSelect

						EndSelect

					Case Else
						msgbox(48+262144,"FindHWIDS","WARNING! The File specified at "& $vExportToCSVLoc & " either:"& @CRLF _
							& "1) Does not have the correct extension" & @CRLF _
							& "2) The location is not write enabled" & @CRLF _
							& "3) The location does not exist" & @CRLF _
							& "Export to CSV will not be completed.",5)
						$vExportToCSV = 0

				EndSelect
		EndSelect


	; ------  Export to HTML
		$vExportToHtml = 0
		Select
			Case $vExportToHtml = 1
				$aHTMLPath = _PathSplit($vExportToHTMLLoc, $szDrive, $szDir, $szFName, $szExt)

				Select
					Case $aHTMLPath[4] = ".html"
						$vHtmlFileAttrib = FileGetAttrib($vExportToHTMLLoc)

						Select
							; If the file exists but the attributes are Read Only then it's most like the location isn't writeable
							Case FileExists($vExportToHTMLLoc) and (StringInStr($vHtmlFileAttrib,"R") or @error)
								msgbox(48+262144,"FindHWIDS","WARNING! The location specified at "& $vExportToHTMLLoc & " HTML is not write enabled. Export to HTML will not be completed.",5)
								$vExportToHtml = 0

							Case Else
								; Delete the file if one exists
								FileDelete($vExportToHTMLLoc)

								; Write the first lines of the file in the specified location
								FileWriteLine($vExportToHTMLLoc,'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">' & @CRLF _
								& '<html xmlns="http://www.w3.org/1999/xhtml"> '& @CRLF _
								& '<head>' & @CRLF _
								& '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />' & @CRLF _
								& '<title>FindHWIDS Scan Performed on '& @year &'-'& @mon &'-'& @MDAY &' at '& @hour &':'& @min &':'& @sec &'</title>' & @CRLF _
								& '</head>' & @CRLF _
								& '<body>')

								Select
									; If the file you tried to write doesn't exist let the user know the location isn't write enabled
									Case NOT FileExists($vExportToHTMLLoc)
										msgbox(48+262144,"FindHWIDS","WARNING! The location specified at "& $vExportToHTMLLoc & " HTML is not write enabled. Export to HTML will not be completed.",5)
										$vExportToHTML = 0
								EndSelect

						EndSelect

					Case Else
						msgbox(48+262144,"FindHWIDS","WARNING! The File specified at "& $vExportToHTMLLoc & " either:"& @CRLF _
							& "1) Does not have the correct extension" & @CRLF _
							& "2) The location is not write enabled" & @CRLF _
							& "3) The location does not exist" & @CRLF _
							& "Export to HTML will not be completed.",5)
						$vExportToHTML = 0

				EndSelect
		EndSelect


; ------ Check if all exports have been cleared
	If $vExportToHtml = 0 and $vExportToCSV = 0 and $vExportToSysprep = 0 Then
		msgbox(16+262144,"FindHWIDS","ERROR! All the Export locations specified are not write enabled. Please choose different locations.")
		GUICtrlSetData($statuslabel, $defaultstatus)
		Return
	Endif


; ------ Start FSHash.dll
		;If $iChecksumFile = 1 Then $plH = PluginOpen(@tempdir &"\FindHWIDS\BIN\fshash.dll")

		; Set progress to 0
		Dim $i = 0
		GUICtrlSetData($win_main_progress,$i)

; ------ After Vars have been gathered START Scan of Individual INF Files for HWIDS
	$arDrvCount = Ubound($aDrvrInf1)-1
	;_ArrayDisplay($aDrvrInf1)

		For $element in $aDrvrInf1
				GUICtrlSetData($statuslabel, " Processing...")

				; ------ Checksum
				Select
					Case $iChecksumFile = 1
						Dim $BufferSize = 0x80000
						Dim $CRC32 = 0, $CRC16 = 0, $Data
						;Dim $FileSize = FileGetSize($element)
						Dim $FileHandle = FileOpen($element, 16)

						For $is = 1 To Ceiling(FileGetSize($element) / $BufferSize)
							$Data = FileRead($FileHandle, $BufferSize)
							$CRC32 = _CRC32($Data, BitNot($CRC32))
							;$CRC16 = _CRC16($Data, $CRC16)
						Next
						FileClose($FileHandle)
						;msgbox(0,'found',Hex($CRC32, 8))
						$sChecksum = Hex($CRC32, 8)

						#cs
						$fElement = FileOpen($element, 16)
						Global $sChecksum = 0

						For $is = 1 To Ceiling(FileGetSize($element) / $cBufferSize)
							$sChecksum = _CRC32(FileRead($fElement, $cBufferSize), BitNot($sChecksum))
						Next
						FileClose($fElement)
						$sChecksum = Hex($sChecksum, 8)
						#ce

					Case Else
						$sChecksum = ""
				EndSelect

				$aINFReadSection_Manufacturer = _IniReadSectionEx($element, "Manufacturer")

				IF @error or StringIsDigit("$element") then
					continueloop
				Endif

				;If @error <> 1 Then ; If there's no error then you can continue

				$ScannedINFFiles = $ScannedINFFiles + 1
				GUICtrlSetData($statuslabel, " Scanning: "& $ScannedINFFiles & " of " & $arDrvCount)

				; Set progress bar
				$i = $i + (100/ubound($aDrvrInf1))
				GUICtrlSetData($win_main_progress,$i)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FIRST INI READ
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FIRST INI READ
				Dim $FileHandle = FileOpen($element)
				$INF = FileRead($FileHandle)
				;msgbox(0,'Found',$INF)
				FileFlush ($FileHandle)
				;FileClose($FileHandle)

				;msgbox(0,'Found',$INF)
				;Filewrite($INF,"C:\inf.inf")


				; ------ Gather INF FILE Description
				;$vSourceDiskNames_INFDesc = _IniString_Read($INF,"SourceDisksNames","1","")
				$vSourceDiskNames_INFDesc = _IniString_Read($INF,"SourceDisksNames","1","")
				Select
					Case $vSourceDiskNames_INFDesc = ""
					$vSourceDiskNames_INFDesc = _IniString_Read($INF,"SourceDisksNames.NTx86","1","")
				EndSelect
				Select
					Case $vSourceDiskNames_INFDesc = ""
					$vSourceDiskNames_INFDesc = _IniString_Read($INF,"SourceDisksNames.NTam64","1","")
				EndSelect
				Select
					Case $vSourceDiskNames_INFDesc = ""
						$vSourceDiskNames_INFDesc = _IniString_Read($INF,"SourceDisksNames.NTia64","1","")
				EndSelect
				Select
					Case stringinStr($vSourceDiskNames_INFDesc,",") <> 0
					$aSourceDiskNames_INFDesc = StringSplit($vSourceDiskNames_INFDesc,",")
					$vSourceDiskNames_INFDesc = StringStripWS($aSourceDiskNames_INFDesc[1],2)
				EndSelect
				_ConvertVarStr($vSourceDiskNames_INFDesc, $element) ; String to convert , location of INF file
				_StringWithRemove($vSourceDiskNames_INFDesc,1,1,1,1)
				Select
					Case $vSourceDiskNames_INFDesc = ""
						$vSourceDiskNames_INFDesc = "Warning: There is no INF Description"
				EndSelect

				; ------ Get OS Signature
				$aINFRead_Signature = _IniString_Read($INF,"Version","Signature","") ; Read Driver Provider/Manufacturer of the INF
				_StringWithRemove($aINFRead_Signature,1,1,1)  ; $iRemoveComment = 0, $iRemoveQuotes = 0, $iRemovePercentSigns = 0, $iRemoveDollarSigns = 0
				Select
					Case $aINFRead_Signature = "$Windows NT$"
						$aINFRead_Signature = "NT Based OS"

					Case $aINFRead_Signature = "$Chicago$"
						$aINFRead_Signature = "All Windows OS"

					Case Else
						ContinueLoop

						#cs
					Case $aINFRead_Signature = "$Windows 95$"
						$aINFRead_Signature = "Windows 9x/ME"
						#ce


				EndSelect

				; ------ Get Provider or Organization Information
				$aINFRead_Provider = _IniString_Read($INF,"Version","Provider","") ; Read Driver Provider/Manufacturer of the INF
				_ConvertVarStr($aINFRead_Provider, $element) ; String to convert , location of INF file
				_StringWithRemove($aINFRead_Provider,1,1,1,1)
				$aProviderStringFull = $aINFRead_Provider
				Select
					Case $aProviderStringFull = ""
						$aProviderStringFull = "Warning: Provider not found"
				EndSelect


				; ------ Get ClassGUID
				$sINFRead_ClassGUID = _IniString_Read($INF,"Version","ClassGUID","") ; Read Driver Version of the INF
				_StringWithRemove($sINFRead_ClassGUID,1)  ; $iRemoveComment = 1, $iRemoveQuotes = 1, $iRemovePercentSigns = 1
				Local $transClassGuid = ""
				Select
					Case $sINFRead_ClassGUID <> "" ; Translate ClassGUID into Class
						$transClassGuid = _TranslateClassGuid($sINFRead_ClassGUID)
					Case Else
						$sINFRead_ClassGUID = "Warning: No Class Guid"
				EndSelect

				; ------ Get Class
				Select
					Case $transClassGuid <> "" ; Use translated ClassGUID for the Class if applicable
						$aINFClass = $transClassGuid
					Case Else ; If not translated from ClassGUID then try to read Class from INF
						$aINFClass = _IniString_Read($INF,"Version","Class","")
						_StringWithRemove($aINFClass,1,1,1)  ; $iRemoveComment = 1, $iRemoveQuotes = 1, $iRemovePercentSigns = 1
				EndSelect

				; ------ Class Filters
				$iIndex = _ArraySearch($sChosenHWIDClass, $aINFClass, 0, 0, 0, 1)
				Select
					Case $iIndex <> "-1" and $sChosenHWIDClass <> "" ; If (a) class filter(s) is found then parse
						$ClassFilter = 1
					Case $sChosenHWIDClass = "" ; Then If class filters are blank everything goes
						$ClassFilter = 1 ; Reset class filter
					Case Else
						$ClassFilter = 0
				EndSelect


				; ------ Read driver Version
				$aINFRead_Version = _IniString_Read($INF,"Version","DriverVer","00/00/0000,00.00.00.00") ; Read Driver Version of the INF
				_StringWithRemove($aINFRead_Version,1)  ; $iRemoveComment = 1, $iRemoveQuotes = 1, $iRemovePercentSigns = 1
				Select
					Case StringinStr($aINFRead_Version,",")
						$aINFRead_Version = StringSplit($aINFRead_Version,",")
						$aINFRead_Driver_Date = StringStripWs($aINFRead_Version[1],3)
						$aINFRead_Driver_Version = StringStripWs($aINFRead_Version[2],3)
						Select
							Case StringInStr($aINFRead_Driver_Version,"%")
								_StringWithRemove($aINFRead_Driver_Version,0,0,1)
								$aINFRead_Driver_Version = _IniString_Read($INF,"Strings",$aINFRead_Driver_Version,$aINFRead_Driver_Version)
						EndSelect
					Case Else
						$aINFRead_Driver_Date = "00/00/0000"
						$aINFRead_Driver_Version = "00.00.00.00"
				EndSelect

				; ------ Gather more data for each INF
					For $iA1 = 1 to $aINFReadSection_Manufacturer[0][0] ; For each Manufacturer do below

						; $aINFReadSection_Manufacturer[$iA1][0] ; Gives the first half of the INI Read ; FirstHalf = SomethingElse ; Returns FirstHalf
						; $aINFReadSection_Manufacturer[$iA1][1] ; Gives the second half of the INI Read ; FirstHalf = SomethingElse ; Returns SomethingElse

						; ------ Get Manufacturer Short Name
						_StringWithRemove($aINFReadSection_Manufacturer[$ia1][0],1,1,1)  ; $iRemoveComment = 0, $iRemoveQuotes = 0, $iRemovePercentSigns = 0, $iRemoveDollarSigns = 0
						$aMFGShortNameStringFull = _IniString_Read($INF,"Strings",$aINFReadSection_Manufacturer[$ia1][0],"")
						_StringWithRemove($aMFGShortNameStringFull,1,1) ; $iRemoveComment = 0, $iRemoveQuotes = 0, $iRemovePercentSigns = 0, $iRemoveDollarSigns = 0
						Select
							Case $aMFGShortNameStringFull = ""
								$aMFGShortNameStringFull = $aINFReadSection_Manufacturer[$ia1][0]
						EndSelect

							; ------  Get sections to grab HWIDS from
							_StringWithRemove($aINFReadSection_Manufacturer[$iA1][1],1,1) ; $iRemoveComment = 0, $iRemoveQuotes = 0, $iRemovePercentSigns = 0, $iRemoveDollarSigns = 0
							$aSplit_Manufacturers = StringSplit($aINFReadSection_Manufacturer[$iA1][1],",") ; Split Manufacturers string by comma's

							For $iA3 = 1 to $aSplit_Manufacturers[0] ; For each split value of Manufacturer string do below; IE. Company then Company.N.T.5.1 etc...

;; ----------> ISSUE WITH LARGE INF FILES 2011-02-24
								Select ; This begins the logic to find the PNP Sections for each Manufacturer
									case $iA3 = 1 ; If it's the first one you need to find this first
										;msgbox(0,$element,"KILL POINT 1")
										$aINFReadSection_EachManuSection = _IniReadSectionEx($element,$aSplit_Manufacturers[1])
										;msgbox(0,$element,"KILL POINT 1.1")
										$vModel = $aSplit_Manufacturers[1]
										$vModelBase = $aSplit_Manufacturers[1] ; Base Hardware Model, Unique
									case else ; Then you can add that to each next type in the split
										;msgbox(0,$element,"KILL POINT 2")
										$aSplit_ManufacturersStripWS = StringStripWS($aSplit_Manufacturers[$iA3],8) ; Strip the ws which sometimes occurs
										$aINFReadSection_EachManuSection = _IniReadSectionEx($element,$aSplit_Manufacturers[1] &"."& $aSplit_ManufacturersStripWS)
										;msgbox(0,$element,"KILL POINT 2.1")
										$vModel = $aSplit_Manufacturers[1] &"."& $aSplit_ManufacturersStripWS ; Hardware Model plus OS Arch Addition
								EndSelect


								Select

									Case @error<>1 ; If there's no error then you can continue
									;_ArrayDisplay($aINFReadSection_EachManuSection)

									For $iA4 = 1 to $aINFReadSection_EachManuSection[0][0] ; Read from each section each line with value

										; Gather each HWID(s) string, could possibly have multiple HWIDS per string, comments removed
										$HWIDString1 = StringStripWS($aINFReadSection_EachManuSection[$iA4][1],8)
										_StringWithRemove($HWIDString1,1,1) ; $iRemoveComment = 0, $iRemoveQuotes = 0, $iRemovePercentSigns = 0, $iRemoveDollarSigns = 0
										$lastSplit = StringSplit($HWIDString1,",") ; Split last lines, splits each line to get HWID(s) string

									; ------ Gather PNPID Description
										_StringWithRemove($aINFReadSection_EachManuSection[$iA4][0],1,1) ; Remove quotes and comments
										_ConvertVarStr($aINFReadSection_EachManuSection[$iA4][0], $element) ; String to convert , location of INF file
										$vDescriptionOfHWID = $aINFReadSection_EachManuSection[$iA4][0]


									; ------  Gather information to be written
										For $iA5 = 2 to $lastSplit[0] ; Splits multiple inline HWID in single line starting at the second one

										; ------- Change each HWID to a normal string
											$PNPID = $lastSplit[$iA5]
											Select
												; If the HWID is actually a Variable (String) then get it from the strings section
												; If the strings section doesn't have it then default back to what you found originally
												Case StringLeft($PNPID,1) = "%" and StringRight($PNPID,1) = "%"
													_StringWithRemove($PNPID,0,0,1)
													$actual_HWID = _IniString_Read($INF,"Strings",$PNPID,$PNPID)
													$PNPID = $actual_HWID
												Case StringLen($PNPID) = "1" and StringLeft($PNPID,1) = "\"
													$PNPID = "ERROR: Second (and possibly more) HWID(s) not collect because of a malformed string!"
											EndSelect

								DIM $INF = ""

										; ------ PNP HWID String Filters
											Select
												Case $sChosenPNPTypes <> ""
													For $iB1 = 1 to $sChosenPNPTypes[0]
														IF StringinStr($PNPID,"*") Then
															$PNPIDFound = StringReplace($PNPID,"*","")
														Else
															$PNPIDFound  = $PNPID
														Endif
														Select
															Case StringInStr($PNPIDFound,$sChosenPNPTypes[$iB1]) ;= $PNPStringLeft
																$PNPIDFilter = 1
																exitloop

															Case Else
																$PNPIDFilter = 0

														EndSelect
													Next

												Case $sChosenPNPTypes = ""
													$PNPIDFilter = 1

												Case Else
													$PNPIDFilter = 0

											EndSelect


										; ------ Filter by Current Hardware
											Select
												Case $iReadCurrentHardware = 1
													For $iB2 = 1 to $aReadCurrentHardware[0]
														;$PNPIDStrnLeft = StringLeft($aReadCurrentHardware[$iB2],StringLen($PNPID))
														Select
															Case StringInStr($aReadCurrentHardware[$iB2],$PNPID) ;$PNPIDStrnLeft = $PNPID
																$ExportReadCurrentHardware = 1
																ExitLoop

															Case Else
																$ExportReadCurrentHardware = 0

														EndSelect
													Next

												Case $iReadCurrentHardware = 0
													$ExportReadCurrentHardware = 1

												Case Else
													$ExportReadCurrentHardware = 0

											EndSelect


										; ------ Filter by Processor Arch and OS Type
										; Reset OSandArch variable to 0
										$vOSandArch = 0

;<-- 2009-06-22 TURNED OFF AUTO SELECT AUTO FILTER OS AND ARCH	;IF $vExportToSysprep = 1 Then $iFilterOStypeAndArch = 1

										;; Check boxes on
										; $Filter_X86 = 1
										; $Filter_AMD64 = 1
										; $Filter_IA64 = 1
										; $Filter_W2k = 1
										; $Filter_XP = 1
										; $Filter_W2k3 = 1
										; $Filter_Vi = 1

										Select
											;Case $iFilterOStypeAndArch = 2
											Case $iFilterOStypeAndArch = 0 and _
												($Filter_X86 <> 0 or $Filter_AMD64 <> 0 or $Filter_IA64 <> 0 or _
												$Filter_W2k <> 0 or $Filter_XP <> 0 or $Filter_W2k3 <> 0 or $Filter_Vi <> 0) and _
												($aINFRead_Signature = "NT Based OS" or $aINFRead_Signature = "All Windows OS")

												;msgbox(0,"Found","X86 " & $Filter_X86)
												;msgbox(0,"Found","AMD64 " & $Filter_AMD64)
												;msgbox(0,"Found","IA64 " & $Filter_IA64)
												;msgbox(0,"Found","W2k " & $Filter_W2k)
												;msgbox(0,"Found","WXP " & $Filter_XP)
												;msgbox(0,"Found","W2k3 " & $Filter_W2k3)
												;msgbox(0,"Found","VI2k8 " & $Filter_Vi)


												IF $Filter_x86 = 1 and _
													(Stringinstr($vModel,".NTia64") = 0 and _
													Stringinstr($vModel,".NTamd64") = 0) Then
													$vOSandArch = 1
												EndIf

												IF $Filter_AMD64 = 1 and Stringinstr($vModel,".NTamd64") Then
													$vOSandArch = 1
												EndIf

												IF $Filter_IA64 = 1 and Stringinstr($vModel,".NTia64") Then
													$vOSandArch = 1
												EndIf

										;<-- 2000 x86 - NT.5.0 NTx86 NTx86.5.0
												IF $Filter_W2k = 1 and _
														(Stringinstr($vModel,".NTamd64") = 0 and _
														Stringinstr($vModel,".NTia64") = 0 and _
														Stringinstr($vModel,".NT.6.1") = 0 and _
														Stringinstr($vModel,".NT.6.0") = 0 and _
														Stringinstr($vModel,".NT.5.2") = 0 and _
														Stringinstr($vModel,".NT.5.1") = 0 and _
														Stringinstr($vModel,".NTx86.6.1") = 0 and _
														Stringinstr($vModel,".NTx86.6.0") = 0 and _
														Stringinstr($vModel,".NTx86.5.2") = 0 and _
														Stringinstr($vModel,".NTx86.5.1") = 0 and _
														Stringinstr($vModel,".ME") = 0) Then

														$vOSandArch = 1
												Endif

										;<-- XP x86 - NT.5.1 NTx86 NTx86.5.1
												IF $Filter_XP = 1 and _
													(Stringinstr($vModel,".NT.6.1") = 0 and _
													Stringinstr($vModel,".NT.6.0") = 0 and _
													Stringinstr($vModel,".NT.5.2") = 0 and _
													Stringinstr($vModel,".NT.5.0") = 0 and _
													Stringinstr($vModel,".NTx86.6.1") = 0 and _
													Stringinstr($vModel,".NTx86.6.0") = 0 and _
													Stringinstr($vModel,".NTx86.5.2") = 0 and _
													Stringinstr($vModel,".NTx86.5.0") = 0 and _
													Stringinstr($vModel,".ME") = 0) Then

													$vOSandArch = 1

												Endif

											;<--  2003 x86 - NT.5.2 NTx86 NTx86.5.2
												IF $Filter_W2k3 = 1 and _
													(Stringinstr($vModel,".NT.6.1") = 0 and _
													Stringinstr($vModel,".NT.6.0") = 0 and _
													Stringinstr($vModel,".NT.5.1") = 0 and _
													Stringinstr($vModel,".NT.5.0") = 0 and _
													Stringinstr($vModel,".NTx86.6.1") = 0 and _
													Stringinstr($vModel,".NTx86.6.0") = 0 and _
													Stringinstr($vModel,".NTx86.5.1") = 0 and _
													Stringinstr($vModel,".NTx86.5.0") = 0 and _
													Stringinstr($vModel,".ME") = 0) THEN

													$vOSandArch = 1

												ENDIF

												IF $Filter_XP = 1 and $Filter_x86 = 1 and _
													(Stringinstr($vModel,".NTamd64") = 0 and _
													Stringinstr($vModel,".NTia64") = 0 and _
													Stringinstr($vModel,".NT.6.1") = 0 and _
													Stringinstr($vModel,".NT.6.0") = 0 and _
													Stringinstr($vModel,".NT.5.2") = 0 and _
													Stringinstr($vModel,".NT.5.0") = 0 and _
													Stringinstr($vModel,".NTx86.6.1") = 0 and _
													Stringinstr($vModel,".NTx86.6.0") = 0 and _
													Stringinstr($vModel,".NTx86.5.2") = 0 and _
													Stringinstr($vModel,".NTx86.5.0") = 0 and _
													Stringinstr($vModel,".ME") = 0) Then

													$vOSandArch = 1

												Endif

												;<--  Vista, W7 and 2008 x86 - NT.6.0 NTx86 NTx86.6.0 NT.6.1 NTx86.6.1
												IF $Filter_Vi = 1 and _
													(Stringinstr($vModel,".NT.5.2") = 0 and _
													Stringinstr($vModel,".NT.5.1") = 0 and _
													Stringinstr($vModel,".NT.5.0") = 0 and _
													Stringinstr($vModel,".NTx86.5.2") = 0 and _
													Stringinstr($vModel,".NTx86.5.1") = 0 and _
													Stringinstr($vModel,".NTx86.5.0") = 0 and _
													Stringinstr($vModel,".ME") = 0) Then

													$vOSandArch = 1

												ENDIF

												If ($Filter_XP = 1 or $Filter_W2k3 = 1) and $Filter_AMD64 = 1 and _
													(Stringinstr($vModel,".NTia64") = 0 and _
													Stringinstr($vModel,".NTx86") = 0 and _
													Stringinstr($vModel,".NT.6.1") = 0 and _
													Stringinstr($vModel,".NT.6.0") = 0 and _
													Stringinstr($vModel,".NT.5.1") = 0 and _
													Stringinstr($vModel,".NT.5.0") = 0 and _
													Stringinstr($vModel,".NTamd64.6.1") = 0 and _
													Stringinstr($vModel,".NTamd64.6.0") = 0 and _
													Stringinstr($vModel,".NTamd64.5.1") = 0 and _
													Stringinstr($vModel,".NTamd64.5.0") = 0 and _
													Stringinstr($vModel,".ME") = 0) Then

													$vOSandArch = 1

												Endif

												IF ($Filter_XP = 1 or $Filter_W2k3 = 1) and $Filter_IA64 = 1 and _
													(Stringinstr($vModel,".NTamd64") = 0 and _
													Stringinstr($vModel,".NTx86") = 0 and _
													Stringinstr($vModel,".NT.6.1") = 0 and _
													Stringinstr($vModel,".NT.6.0") = 0 and _
													Stringinstr($vModel,".NT.5.1") = 0 and _
													Stringinstr($vModel,".NT.5.0") = 0 and _
													Stringinstr($vModel,".NTia64.6.1") = 0 and _
													Stringinstr($vModel,".NTia64.6.0") = 0 and _
													Stringinstr($vModel,".NTia64.5.1") = 0 and _
													Stringinstr($vModel,".NTia64.5.0") = 0 and _
													Stringinstr($vModel,".ME") = 0) Then

													$vOSandArch = 1

												Endif

												;<--  Vista and 2008 x86 - NT.6.0 NTamd64 NTamd64.6.0 NT.6.1 NTamd64.6.1
												IF $Filter_Vi = 1 and $Filter_AMD64 = 1 and _
													(Stringinstr($vModel,".NTx86") = 0 and _
													Stringinstr($vModel,".NTia64") = 0 and _
													Stringinstr($vModel,".NT.5.2") = 0 and _
													Stringinstr($vModel,".NT.5.1") = 0 and _
													Stringinstr($vModel,".NT.5.0") = 0 and _
													Stringinstr($vModel,".NTamd64.5.2") = 0 and _
													Stringinstr($vModel,".NTamd64.5.1") = 0 and _
													Stringinstr($vModel,".NTamd64.5.0") = 0 and _
													Stringinstr($vModel,".ME") = 0) THEN

													$vOSandArch = 1

												ENDIF

												;<--  Vista and 2008 x86 - NT.6.0 NTia64 NTia64.6.0 NT.6.1 NTia64.6.1
												IF $Filter_Vi = 1 and $Filter_IA64 = 1 and _
													(Stringinstr($vModel,".NTx86") = 0 and _
													Stringinstr($vModel,".NTamd64") = 0 and _
													Stringinstr($vModel,".NT.5.2") = 0 and _
													Stringinstr($vModel,".NT.5.1") = 0 and _
													Stringinstr($vModel,".NT.5.0") = 0 and _
													Stringinstr($vModel,".NTia64.5.2") = 0 and _
													Stringinstr($vModel,".NTia64.5.1") = 0 and _
													Stringinstr($vModel,".NTia64.5.0") = 0 and _
													Stringinstr($vModel,".ME") = 0) THEN

													$vOSandArch = 1
												ENDIF

										; Begin Auto Filter OS Version and Processor Arch
											Case $iFilterOStypeAndArch = 1 ;and ($aINFRead_Signature = "NT Based OS" or $aINFRead_Signature = "All Windows OS")
												Select
													;<-- 2000 x86 - NT.5.0 NTx86 NTx86.5.0
													Case @OSVersion = "WIN_2000" and @OSArch = "X86" and _
														(Stringinstr($vModel,".NTia64") = 0 and _
														Stringinstr($vModel,".NTamd64") = 0 and _
														Stringinstr($vModel,".NT.6.1") = 0 and _
														Stringinstr($vModel,".NT.6.0") = 0 and _
														Stringinstr($vModel,".NT.5.2") = 0 and _
														Stringinstr($vModel,".NT.5.1") = 0 and _
														Stringinstr($vModel,".NTx86.6.1") = 0 and _
														Stringinstr($vModel,".NTx86.6.0") = 0 and _
														Stringinstr($vModel,".NTx86.5.2") = 0 and _
														Stringinstr($vModel,".NTx86.5.1") = 0 and _
														Stringinstr($vModel,".ME") = 0)
															$vOSandArch = 1

													 ;<-- XP x86 - NT.5.1 NTx86 NTx86.5.1
													Case @OSVersion = "WIN_XP" and @OSArch = "X86" and _
														(Stringinstr($vModel,".NTia64") = 0 and _
														Stringinstr($vModel,".NTamd64") = 0 and _
														Stringinstr($vModel,".NT.6.1") = 0 and _
														Stringinstr($vModel,".NT.6.0") = 0 and _
														Stringinstr($vModel,".NT.5.2") = 0 and _
														Stringinstr($vModel,".NT.5.0") = 0 and _
														Stringinstr($vModel,".NTx86.6.1") = 0 and _
														Stringinstr($vModel,".NTx86.6.0") = 0 and _
														Stringinstr($vModel,".NTx86.5.2") = 0 and _
														Stringinstr($vModel,".NTx86.5.0") = 0 and _
														Stringinstr($vModel,".ME") = 0)
															$vOSandArch = 1

													;<--  2003 x86 - NT.5.2 NTx86 NTx86.5.2
													Case @OSVersion = "WIN_2003" and @OSArch = "X86" and _
														(Stringinstr($vModel,".NTia64") = 0 and _
														Stringinstr($vModel,".NTamd64") = 0 and _
														Stringinstr($vModel,".NT.6.1") = 0 and _
														Stringinstr($vModel,".NT.6.0") = 0 and _
														Stringinstr($vModel,".NT.5.1") = 0 and _
														Stringinstr($vModel,".NT.5.0") = 0 and _
														Stringinstr($vModel,".NTx86.6.1") = 0 and _
														Stringinstr($vModel,".NTx86.6.0") = 0 and _
														Stringinstr($vModel,".NTx86.5.1") = 0 and _
														Stringinstr($vModel,".NTx86.5.0") = 0 and _
														Stringinstr($vModel,".ME") = 0)
															$vOSandArch = 1

													;<--  2003 & XP x64 - NT.5.2 NTamd64 NTamd64.5.2
													Case (@OSVersion = "WIN_2003" or @OSVersion = "WIN_XP") and @OSArch = "X64" and _
														(Stringinstr($vModel,".NTia64") = 0 and _
														Stringinstr($vModel,".NTx86") = 0 and _
														Stringinstr($vModel,".NT.6.1") = 0 and _
														Stringinstr($vModel,".NT.6.0") = 0 and _
														Stringinstr($vModel,".NT.5.1") = 0 and _
														Stringinstr($vModel,".NT.5.0") = 0 and _
														Stringinstr($vModel,".NTamd64.6.1") = 0 and _
														Stringinstr($vModel,".NTamd64.6.0") = 0 and _
														Stringinstr($vModel,".NTamd64.5.1") = 0 and _
														Stringinstr($vModel,".NTamd64.5.0") = 0 and _
														Stringinstr($vModel,".ME") = 0)
															$vOSandArch = 1

													;<--  2003 and XP ia64 (Itanium) - NT.5.2 NTia64 NTia64.5.2
													Case (@OSVersion = "WIN_2003" or @OSVersion = "WIN_XP") and @OSArch = "IA64" and _
														(Stringinstr($vModel,".NTamd64") = 0 and _
														Stringinstr($vModel,".NTx86") = 0 and _
														Stringinstr($vModel,".NT.6.1") = 0 and _
														Stringinstr($vModel,".NT.6.0") = 0 and _
														Stringinstr($vModel,".NT.5.1") = 0 and _
														Stringinstr($vModel,".NT.5.0") = 0 and _
														Stringinstr($vModel,".NTia64.6.1") = 0 and _
														Stringinstr($vModel,".NTia64.6.0") = 0 and _
														Stringinstr($vModel,".NTia64.5.1") = 0 and _
														Stringinstr($vModel,".NTia64.5.0") = 0 and _
														Stringinstr($vModel,".ME") = 0)
															$vOSandArch = 1

													;<--  Vista and 2008 x86 - NT.6.0 NTx86 NTx86.6.0 NT.6.1 NTx86.6.1
													;WIN_2008R2", "WIN_7", "WIN_2008", "WIN_VISTA
													Case (@OSVersion = "WIN_VISTA" or @OSVersion = "WIN_2008" or @OSVersion = "WIN_7") and @OSArch = "X86" and _
														(Stringinstr($vModel,".NTamd64") = 0 and _
														Stringinstr($vModel,".NTia64") = 0 and _
														Stringinstr($vModel,".NT.5.2") = 0 and _
														Stringinstr($vModel,".NT.5.1") = 0 and _
														Stringinstr($vModel,".NT.5.0") = 0 and _
														Stringinstr($vModel,".NTx86.5.2") = 0 and _
														Stringinstr($vModel,".NTx86.5.1") = 0 and _
														Stringinstr($vModel,".NTx86.5.0") = 0 and _
														Stringinstr($vModel,".ME") = 0)
															$vOSandArch = 1

													;<--  Vista and 2008 x86 - NT.6.0 NTamd64 NTamd64.6.0 NT.6.1 NTamd64.6.1
													Case (@OSVersion = "WIN_VISTA" or @OSVersion = "WIN_2008" or @OSVersion = "WIN_7" or @OSVersion = "WIN_2008R2") and @OSArch = "X64" and _
														(Stringinstr($vModel,".NTx86") = 0 and _
														Stringinstr($vModel,".NTia64") = 0 and _
														Stringinstr($vModel,".NT.5.2") = 0 and _
														Stringinstr($vModel,".NT.5.1") = 0 and _
														Stringinstr($vModel,".NT.5.0") = 0 and _
														Stringinstr($vModel,".NTamd64.5.2") = 0 and _
														Stringinstr($vModel,".NTamd64.5.1") = 0 and _
														Stringinstr($vModel,".NTamd64.5.0") = 0 and _
														Stringinstr($vModel,".ME") = 0)
															$vOSandArch = 1

													;<--  Vista and 2008 x86 - NT.6.0 NTia64 NTia64.6.0 NT.6.1 NTia64.6.1
													Case (@OSVersion = "WIN_VISTA" or @OSVersion = "WIN_2008" or @OSVersion = "WIN_2008R2") and @OSArch = "IA64" and _
														(Stringinstr($vModel,".NTamd64") = 0 and _
														Stringinstr($vModel,".NTx86") = 0 and _
														Stringinstr($vModel,".NT.5.2") = 0 and _
														Stringinstr($vModel,".NT.5.1") = 0 and _
														Stringinstr($vModel,".NT.5.0") = 0 and _
														Stringinstr($vModel,".NTia64.5.2") = 0 and _
														Stringinstr($vModel,".NTia64.5.1") = 0 and _
														Stringinstr($vModel,".NTia64.5.0") = 0 and _
														Stringinstr($vModel,".ME") = 0)
															$vOSandArch = 1
												EndSelect

											Case $iFilterOStypeAndArch = 0
												$vOSandArch = 1

											Case Else
												$vOSandArch = 0

										EndSelect


	; --------------------------------- Begin exports
										Select
											Case $PNPID <> "" and $PNPIDFilter = 1 and $ExportReadCurrentHardware = 1 and $vOSandArch = 1

												;GUICtrlSetData($statuslabel, " Scanning: "& $element & " > " & $PNPID)
												;GUICtrlSetData($statuslabel, " Scanning: "& $ScannedINFFiles & " of " & $arDrvCount)

												_StringWithRemove($vSourceDiskNames_INFDesc,0,0,0,0,2) ; INF Description
												_StringWithRemove($aINFRead_Driver_Date,0,0,0,0,2) ; DriverVer
												_StringWithRemove($aINFRead_Driver_Version,0,0,0,0,2) ; DriverVer
												_StringWithRemove($PNPID,0,0,0,0,2) ; PNPID
												_StringWithRemove($vDescriptionOfHWID,0,0,0,0,2) ; Description
												_StringWithRemove($aINFClass,0,0,0,0,2) ; INF Class
												_StringWithRemove($sINFRead_ClassGUID,0,0,0,0,2) ; Class GUID
												_StringWithRemove($aMFGShortNameStringFull,0,0,0,0,2) ; Manufacturer
												_StringWithRemove($aSplit_Manufacturers[1],0,0,0,0,2) ; Model
												_StringWithRemove($aProviderStringFull,0,0,0,0,2) ; Provider
												_StringWithRemove($aINFRead_Signature,0,0,0,0,2) ; OS Signature
												_StringWithRemove($vModel,0,0,0,0,2) ; Model Architecture

												$ScannedHWIDS = $ScannedHWIDS + 1

												If $vExportToCSV = 1 and $ClassFilter = 1 Then
													FileWriteLine($vExportToCSVLoc,$element & "," & _
													$vSourceDiskNames_INFDesc & "," & _
													$sChecksum & "," & _
													$aINFRead_Driver_Date & "," & _
													$aINFRead_Driver_Version  & "," & _
													$PNPID & ","  & _
													$vDescriptionOfHWID & "," & _
													$aINFClass & "," & _
													$sINFRead_ClassGUID & "," & _
													$aMFGShortNameStringFull & "," & _
													$vModelBase & "," & _
													$aProviderStringFull & "," & _
													$aINFRead_Signature & "," & _
													$vModel)
												EndIf

												#cs
												If $vExportToHTML = 1 and $ClassFilter = 1 Then
														FileWriteLine($vExportToHTML,$element & "," & _
														$vSourceDiskNames_INFDesc & "," & _
														$sChecksum & "," & _
														$aINFRead_Driver_Date & "," & _
														$aINFRead_Driver_Version  & "," & _
														$PNPID & ","  & _
														$vDescriptionOfHWID & "," & _
														$aINFClass & "," & _
														$sINFRead_ClassGUID & "," & _
														$aMFGShortNameStringFull & "," & _
														$vModelBase & "," & _
														$aProviderStringFull & "," & _
														$aINFRead_Signature & "," & _
														$vModel)
												EndIf
												#ce

												IF $vExportToSysprep = 1 and ($aINFClass = "hdc" or $aINFClass = "scsiadapter") Then
														INIwrite($vExportToSysprepLoc,"SysprepMassStorage",$PNPID,'"' &$element&'"' & " ; "& $aINFClass &" - "& $vDescriptionOfHWID)
												EndIF

										EndSelect

										;GUICtrlSetData($statuslabel, " Processing...")

										Next

									Next

								EndSelect

							Next
						Next
				;Endif
		Next



; ------ Close fshash.dll
		;If $iChecksumFile = 1 Then PluginClose($plH)


; ------ End Timer Called - Transform into seconds
		$dif = TimerDiff($begin)
		$dif = $dif/1000
		IF StringInStr($dif,".") Then
			$dif = StringSplit($dif,".")
			$dif = $dif[1] & "." & StringLeft($dif[2],2)
		Endif


; ------ Finish Exports if needed, etc.
		IF $vExportToCSV = 1 Then
				FileWriteLine($vExportToCSVLoc,",,,,,,,,,,,,,," & "Total Scan Time in Seconds: " & $dif)
				FileWriteLine($vExportToCSVLoc,",,,,,,,,,,,,,," & "Total Files Scanned: " & $ScannedINFFiles)
				FileWriteLine($vExportToCSVLoc,",,,,,,,,,,,,,," & "Total HWIDS Found: " & $ScannedHWIDS)
				GUICtrlSetData($statuslabel, " -- SAVING -- " & $vExportToCSVLoc & "\hwids.csv" )
		Endif


	; ---- Let everyone know what went on
		GUICtrlSetData($statuslabel, " DONE! Completed in "& $dif & "s -- Found: " & $ScannedHWIDS & " HWIDs")
		GUICtrlSetData($win_main_progress, 100)

	TraySetIcon()

EndFunc   ;==>_FindHWIDS

#cs ----------------------------------------------------------------------------
AutoIt Version: 3.2.10.0
Author: WeaponX
Updated: 2/21/08
Script Function: Recursive file search

2/21/08 - Added pattern for folder matching, flag for return type
1/24/08 - Recursion is now optional

edited by Kickarse
7/25/2008 - Script Function changed to scan for all inf/INF files


Parameters:

RFSstartdir: Path to starting folder

RFSFilepattern: RegEx pattern to match
"\.(mp3)" - Find all mp3 files - case sensitive (by default)
"(?i)\.(mp3)" - Find all mp3 files - case insensitive
"(?-i)\.(mp3|txt)" - Find all mp3 and txt files - case sensitive

RFSFolderpattern:
"(Music|Movies)" - Only match folders named Music or Movies - case sensitive (by default)
"(?i)(Music|Movies)" - Only match folders named Music or Movies - case insensitive
"(?!(Music|Movies)\b)\b.+" - Match folders NOT named Music or Movies - case sensitive (by default)

RFSFlag: Specifies what is returned in the array
0 - Files and folders
1 - Files only
2 - Folders only

RFSrecurse: TRUE = Recursive, FALSE = Non-recursive

RFSdepth: Internal use only

#ce ----------------------------------------------------------------------------

Func RecursiveFileSearch($RFSstartDir, $RFSFilepattern = ".", $RFSFolderpattern = ".", $RFSFlag = 0, $RFSrecurse = True, $RFSdepth = 0)

	;Ensure starting folder has a trailing slash
	If StringRight($RFSstartDir, 1) <> "\" Then $RFSstartDir &= "\"

	If $RFSdepth = 0 Then
		;Get count of all files in subfolders for initial array definition
		$RFSfilecount = DirGetSize($RFSstartDir, 1)

		;File count + folder count (will be resized when the function returns)
		Global $RFSarray[$RFSfilecount[1] + $RFSfilecount[2] + 1]
	EndIf

	$RFSsearch = FileFindFirstFile($RFSstartDir & "*.*")
	If @error Then Return

	;Search through all files and folders in directory
	While 1
		$RFSnext = FileFindNextFile($RFSsearch)
		If @error Then ExitLoop

		;If folder and recurse flag is set and regex matches
		If StringInStr(FileGetAttrib($RFSstartDir & $RFSnext), "D") Then

			If $RFSrecurse And StringRegExp($RFSnext, $RFSFolderpattern, 0) Then
				RecursiveFileSearch($RFSstartDir & $RFSnext, $RFSFilepattern, $RFSFolderpattern, $RFSFlag, $RFSrecurse, $RFSdepth + 1)
				If $RFSFlag <> 1 Then
					;Append folder name to array
					$RFSarray[$RFSarray[0] + 1] = $RFSstartDir & $RFSnext
					$RFSarray[0] += 1
				EndIf
			EndIf
		ElseIf StringRegExp($RFSnext, $RFSFilepattern, 0) And $RFSFlag <> 2 Then
			;Append file name to array
			$RFSarray[$RFSarray[0] + 1] = $RFSstartDir & $RFSnext
			$RFSarray[0] += 1
		EndIf
	WEnd
	FileClose($RFSsearch)

	If $RFSdepth = 0 Then
		ReDim $RFSarray[$RFSarray[0] + 1]
		Return $RFSarray
	EndIf
EndFunc   ;==>RecursiveFileSearchwithoutFileNames


;===============================================================================
; FunctionName:     _ArrayElements()
; Description:      Returns the number of unique elements from a 1D or 2D array
; Syntax:           _ArrayElements( $aArray, $iStart )
; Parameter(s):     $aArray - ByRef array to return unique elements from
;                   $iStart - (Optional) Index to start at, default is 0
; Return Value(s):  On success returns an array of unique elements,  $aReturn[0] = count
;                   On failure returns 0 and sets @error (see code below)
; Author(s):        jon8763; Modified by PsaltyDS; Modified by Kickarse
;===============================================================================
Func _ArrayElements(ByRef $aArray,$Dim2, $iStart = 0)
	If Not IsArray($aArray) Then Return SetError(1, 0, 0)

	; Setup to use SOH as delimiter
	Local $SOH = Chr(01), $sData = $SOH

	; Setup for number of dimensions
	Local $iBound1 = UBound($aArray) - 1,  $iBound2 = 0;$Dim2 = False,
	Select
		Case UBound($aArray, 0) = 2
			$Dim2 = True
			$iBound2 = UBound($aArray, 2) - 1
		Case UBound($aArray, 0) > 2
			Return SetError(2, 0, 0)
	EndSelect

	; Get list of unique elements
	For $m = $iStart To $iBound1
		If $Dim2 Then
			; 2D
			For $n = 0 To $iBound2
				If Not StringInStr($sData, $SOH & $aArray[$m][$n] & $SOH) Then $sData &= $aArray[$m][$n] & $SOH
			Next
		Else
			; 1D
			If Not StringInStr($sData, $SOH & $aArray[$m] & $SOH) Then $sData &= $aArray[$m] & $SOH
		EndIf
	Next

	; Strip start and end delimiters
	$sData = StringTrimRight(StringTrimLeft($sData, 1), 1)

	; Return results after testing for null set
	$aArray = StringSplit($sData, $SOH)
	If $aArray[0] = 1 And $aArray[1] = "" Then Local $aArray[1] = [0]
	Return $aArray
EndFunc   ;==>_ArrayElements


; ------------------ Read current hardware of the system
Func _Read_PNP_Items(byref $aFindCurrentHardware, $vExportHardwareLoc, $CurrentSystemHardwareFilter=0, $exporttolog=0)
	; $CurrentSystemHardwareFilter
	; 1 = for Sysprep
	; 2 = for ALL
	; $exporttolog
	; 1 = Yes export log of current hardware

	Local $colItems = "";, $aFindCurrentHardware[1]

	$colItems = $objWMIService.ExecQuery("Select * from Win32_PnPEntity")

	Select
		Case $exporttolog = 1 ; Export Log check file written to temp or working dir
		FileDelete($vExportHardwareLoc)
		Select
			Case FileExists($vExportHardwareLoc)
				msgbox(48+262144,"FindHWIDS","The location specified at "& $vExportHardwareLoc & " file is not write enabled. Please choose another location.")
				return
		EndSelect
		FileWriteLine($vExportHardwareLoc,"==================================================================================================")
	EndSelect

   For $objItem in $colItems

	   If $exporttolog = 1 Then

			GUICtrlSetData($statuslabel, " > "&  $objItem.Name )

			FileWriteLine($vExportHardwareLoc,"ClassGUID: "& $ObjItem.ClassGUID & @CRLF _
				& "Description: "&  $objItem.Description & @CRLF _
				& "DeviceID: "&  $objItem.DeviceID & @CRLF _
				& "PNPDeviceID: "&  $objItem.PNPDeviceID & @CRLF _
				& "Manufacturer: "&  $objItem.Manufacturer & @CRLF _
				& "Name: "&  $objItem.Name & @CRLF _
				& "Service: "&  $objItem.Service & @CRLF _
				& "Status: "&  $objItem.Status & @CRLF _
				& "Status Code: "&  $objItem.ConfigManagerErrorCode & @CRLF _
				& "==================================================================================================")

		Endif

		Select
			Case $CurrentSystemHardwareFilter = 1 and ($ObjItem.ClassGuid = "{4d36e96a-e325-11ce-bfc1-08002be10318}" or $ObjItem.ClassGuid = "{4d36e97d-e325-11ce-bfc1-08002be10318}" or $ObjItem.ClassGuid = "{4d36e97b-e325-11ce-bfc1-08002be10318}")
				_arrayadd($aFindCurrentHardware,$objItem.PNPDeviceID)
				$aFindCurrentHardware[0] = $aFindCurrentHardware[0] + 1

			Case $CurrentSystemHardwareFilter = 0
				_arrayadd($aFindCurrentHardware,$objItem.PNPDeviceID)
				$aFindCurrentHardware[0] = $aFindCurrentHardware[0] + 1

		EndSelect
	Next

	Select
		Case $exporttolog = 1
		Select
			Case FileExists(@windowsdir &"\notepad.exe")
				Run("notepad.exe "& $vExportHardwareLoc)
		EndSelect
	EndSelect

	GUICtrlSetData($statuslabel, " Ready" )

EndFunc


; ------------------ Removes certain different characters from a string
Func _StringWithRemove(byRef $sStringWith, $iRemoveComment = 0, $iRemoveQuotes = 0, $iRemovePercentSigns = 0, $iRemoveDollarSigns = 0, $iRemoveCommas = 0, $iStripWS = 0)
	; Remove Comments
	IF StringInStr($sStringWith,';') and $iRemoveComment = 1 then
			$sStringWith = StringSplit($sStringWith,';')
			$sStringWith = StringStripWs($sStringWith[1],2);$sStringWithComment[1] ;
	Endif
	; Remove Quotes
	IF StringInStr($sStringWith,'"') and $iRemoveQuotes = 1 then $sStringWith = StringReplace($sStringWith,'"',"")
	; Remove Percent Signs
	If StringInStr($sStringWith,'%') and $iRemovePercentSigns = 1 then $sStringWith = StringReplace($sStringWith,'%',"")
	; Remove Dollar Signs
	IF StringInStr($sStringWith,'$') and $iRemoveDollarSigns = 1 then $sStringWith = StringReplace($sStringWith,'$',"")
	Select
		Case StringInStr($sStringWith,',') and $iRemoveCommas = 1 ; Remove comma's completely
			$sStringWith = StringReplace($sStringWith,',','')
		Case StringInStr($sStringWith,',') and $iRemoveCommas = 2 ; Replace comma's with a space
			$sStringWith = StringReplace($sStringWith,',',' ')
	EndSelect
	; Strip Leading Whitespace
	IF $iStripWS <> "" or  $iStripWS <> "0" then $sStringWith = StringStripWS($sStringWith,$iStripWS)
EndFunc ; ===> _StringWithRemove


; ------------------ Converts a variable inline from strings section of an INF file
Func _ConvertVarStr(byref $sString_Find_Orig, $sINFLoc, $iRemoveComments=1, $iRemoveQuotes=1) ; String to convert , location of INF file
	Local $element, $aSplit_StringFindOrig, $aFound_String_Repl, $aFound_String_Split, $sFound_String_Replace, $Array_Size
	Select
		; If the string contains percent signs it's most likely a variable
		Case StringinStr($sString_Find_Orig,"%")
			; Get each Variable
			$aSplit_StringFindOrig = _StringBetween($sString_Find_Orig, '%', '%');Not using SRE
				; Start gathering strings, which we'll look for multiples of
				For $element in $aSplit_StringFindOrig
					; Grab Variable from Strings Section
					; If the element is not found it will revert to the original
					$sFound_String_Replace = INIRead($sINFLoc,"Strings",$element,$element) ; If nothing replace with original
					Select
						; Find if there's a comment on the line
						Case StringInStr($sFound_String_Replace,";") <> 0 and $iRemoveComments = 1
							$aFound_String_Split = StringSplit($sFound_String_Replace,";")
							$sFound_String_Replace = $aFound_String_Split[1]
					EndSelect
					Select
						;Removing the quotes if any are found
						Case StringinStr($sFound_String_Replace,'"') <> 0 and $iRemoveQuotes = 1
							$aFound_String_Repl = StringReplace($sFound_String_Replace,'"','')
							$sFound_String_Replace = $aFound_String_Repl
					EndSelect
					; Replace string with found variable
					$sFound_String_Replace = StringReplace($sString_Find_Orig,"%"&$element&"%",$sFound_String_Replace)
					; Make original string have new variable and if needs to be run
					$sString_Find_Orig = $sFound_String_Replace
				next
	EndSelect
EndFunc



; ------------------ Exit the program via the Esc key
Func _Exit_Scan()
	DirRemove(@tempdir &"\FindHWIDS",1)
	;FileDelete(@tempdir &"\FindHWIDS\BIN\ReadMe.txt")
	;FileDelete(@tempdir &"\FindHWIDS\BIN\fshash.dll")
	;FileDelete(@tempdir &"\FindHWIDS\IMAGE\logo_fhwid.jpg")
	;FileDelete(@tempdir &"\FindHWIDS\ICO\processing.ico")
	exit
EndFunc


; ------------------ Different INIReadSection to capture all data not captured from the original
#cs
Func _IniReadSectionEx($hFile, $vSection)
    Local $iSize = FileGetSize($hFile) / 1024
	If $iSize <= 31 Then
		Local $aSecRead = IniReadSection($hFile, $vSection)
		If @error Then Return SetError(@error, 0, '')
		Return $aSecRead
    EndIf
    Local $sFRead = @CRLF & FileRead($hFile) & @CRLF & '['
    $vSection = StringStripWS($vSection, 7)
    Local $aData = StringRegExp($sFRead, '(?s)(?i)\n\s*\[\s*' & $vSection & '\s*\]\s*\r\n(.*?)\[', 3)
    If IsArray($aData) = 0 Then Return SetError(1, 0, 0)
    Local $aKey = StringRegExp(@LF & $aData[0], '\n\s*(.*?)\s*=', 3) ; Get Key from scanned line
    Local $aValue = StringRegExp(@LF & $aData[0], '\n\s*.*?\s*=(.*?)\r', 3) ; Get Value from scanned line
    Local $nUbound = UBound($aKey)
    Local $aSection[$nUBound +1][$nUBound +1]
    $aSection[0][0] = $nUBound
    For $iCC = 0 To $nUBound - 1
		Select ; new
			Case StringLeft($aKey[$iCC],1) <> ";" ; new
				$aSection[$iCC + 1][0] = $aKey[$iCC]
				$aSection[$iCC + 1][1] = $aValue[$iCC]
		EndSelect ; new
    Next
    Return $aSection
EndFunc


Func _IniReadSectionEx($hFile, $vSection)
    Local $iSize = FileGetSize($hFile) / 1024
    If $iSize <= 31 Then
        Local $aSecRead = IniReadSection($hFile, $vSection)
        If @error Then Return SetError(@error, 0, '')
        Return $aSecRead
    EndIf
	filewriteline(@scriptdir &"\log.log",$hFile)
    Local $sFRead = @CRLF & FileRead($hFile) & @CRlf & '['
    $vSection = StringStripWS($vSection, 7)
	Local $aData = StringRegExp($sFRead, '(?s)(?i)\n\s*\[\s*' & $vSection & '\s*\]\s*\r\n(.*?)\r\n[', 3)
    ;Local $aData = StringRegExp($sFRead, '(?s)(?i)\n\s*\[\s*' & $vSection & '\s*\]\s*\r\n(.*?)[', 3)
    If IsArray($aData) = 0 Then Return SetError(1, 0, 0)
	_ArrayDisplay($aData)
    Local $aKey = StringRegExp(@LF & $aData[0], '\n\s*(.*?)\s*=', 3)
    ;Local $aValue = StringRegExp(@LF & $aData[0], '\n\s*.*?\s*=(.*?)\r', 3)
	Local $aValue = StringRegExp(@LF & $aData[0], '\n\s*.*?\s*=(.*?)\r', 3)
    Local $nUbound = UBound($aKey)
   ; Local $aSection[$nUBound +1][$nUBound +1]
	Local $aSection[$nUBound +1][2]
    $aSection[0][0] = $nUBound
    For $iCC = 0 To $nUBound - 1
        Select
			Case StringLeft($aKey[$iCC],1) <> ";"
				filewriteline(@scriptdir &"\log.log",$hFile &" ---> "& $aKey[$iCC] & "=" & $aValue[$iCC])
                $aSection[$iCC + 1][0] = $aKey[$iCC]
				$aSection[$iCC + 1][1] = $aValue[$iCC]
        EndSelect
    Next
	Fileclose($hFile)
    Return $aSection
EndFunc
#ce

Func _IniReadSectionEx($hFile, $vSection)
    Local $iSize = FileGetSize($hFile) / 1024
    If $iSize <= 31 Then
        Local $aSecRead = IniReadSection($hFile, $vSection)
        If @error Then Return SetError(@error, 0, '')
        Return $aSecRead
    EndIf
    Local $sFRead = @CRLF & FileRead($hFile) & @CRLF & '['
    $vSection = StringStripWS($vSection, 7)
    Local $aData = StringRegExp($sFRead, '(?s)(?i)\n\s*\[\s*' & $vSection & '\s*\]\s*\r\n(.*?)\[', 3)
    If IsArray($aData) = 0 Then Return SetError(1, 0, 0)
    Local $aKey = StringRegExp(@LF & $aData[0], '\n\s*(.*?)\s*=', 3)
    Local $aValue = StringRegExp(@LF & $aData[0], '\n\s*.*?\s*=(.*?)\r', 3)
    Local $nUbound = UBound($aKey)
    Local $aSection[$nUBound +1][2]
    $aSection[0][0] = $nUBound
    For $iCC = 0 To $nUBound - 1
		Select
			Case StringLeft($aKey[$iCC],1) <> ";"
				$aSection[$iCC + 1][0] = $aKey[$iCC]
				$aSection[$iCC + 1][1] = $aValue[$iCC]
		EndSelect
    Next
    Return $aSection
EndFunc



Func _TranslateClassGuid($vClassGUID)
	; based on http://msdn.microsoft.com/en-us/library/windows/hardware/ff553426%28v=vs.85%29.aspx

	Switch $vClassGUID
		Case "{72631e54-78a4-11d0-bcf7-00aa00b7b32a}"
			$vClassName = "Battery"
			$vClassExtName = "Battery Devices"
			$vClassDesc = "This class includes battery devices and UPS devices."

		Case "{53D29EF7-377C-4D14-864B-EB3A85769359}"
			$vClassName = "Biometric"
			$vClassExtName = "Biometric Device"
			$vClassDesc = "(Windows Server 2003 and later versions of Windows) This class includes all biometric-based personal identification devices."

		Case "{e0cbf06c-cd8b-4647-bb8a-263b43f0f974}"
			$vClassName = "Bluetooth"
			$vClassExtName = "Bluetooth Devices"
			$vClassDesc = "(Windows XP SP1 and later versions of Windows) This class includes all Bluetooth devices."

		Case "{4d36e965-e325-11ce-bfc1-08002be10318}"
			$vClassName = "CDROM"
			$vClassExtName = "CD-ROM Drives"
			$vClassDesc = "This class includes CD-ROM drives, including SCSI CD-ROM drives. By default, the system's CD-ROM class installer also installs a system-supplied CD audio driver and CD-ROM changer driver as Plug and Play filters."

		Case "{4d36e967-e325-11ce-bfc1-08002be10318}"
			$vClassName = "DiskDrive"
			$vClassExtName = "Disk Drives"
			$vClassDesc = "This class includes hard disk drives. See also the HDC and SCSIAdapter classes."

		Case "{4d36e968-e325-11ce-bfc1-08002be10318}"
			$vClassName	= "Display"
			$vClassExtName = "Display Adapters"
			$vClassDesc = "This class includes video adapters. Drivers for this class include display drivers and video miniport drivers."

		Case "{4d36e969-e325-11ce-bfc1-08002be10318}"
			$vClassName	= "FDC"
			$vClassExtName = "Floppy Disk Controllers"
			$vClassDesc = "This class includes floppy disk drive controllers."

		Case "{4d36e980-e325-11ce-bfc1-08002be10318}"
			$vClassName = "FloppyDisk"
			$vClassExtName = "Floppy Disk Drives"
			$vClassDesc = "This class includes floppy disk drives."

		Case "{4d36e96a-e325-11ce-bfc1-08002be10318}"
			$vClassName = "HDC"
			$vClassExtName = "Hard Disk Controllers"
			$vClassDesc = "This class includes hard disk controllers, including ATA/ATAPI controllers but not SCSI and RAID disk controllers."

		Case "{745a17a0-74d3-11d0-b6fe-00a0c90f57da}"
			$vClassName = "HID Class"
			$vClassExtName = "Human Interface Devices (HID)"
			$vClassDesc = "This class includes interactive input devices that are operated by the system-supplied HID class driver. This includes USB devices that comply with the USB HID Standard and non-USB devices that use a HID minidriver. For more information, see HIDClass Device Setup Class. (See also the Keyboard or Mouse classes later in this list.)"

		Case "{48721b56-6795-11d2-b1a8-0080c72e74a2}"
			$vClassName = "DOT4"
			$vClassExtName = "IEEE 1284.4 Devices"
			$vClassDesc = "This class includes devices that control the operation of multifunction IEEE 1284.4 peripheral devices."

		Case "{49ce6ac8-6f86-11d2-ble5-0080c72e74a2}"
			$vClassName = "DOT4Print"
			$vClassExtName = "IEEE 1284.4 Print Functions"
			$vClassDesc = "This class includes Dot4 print functions. A Dot4 print function is a function on a Dot4 device and has a single child device, which is a member of the Printer device setup class."

		Case "{7ebefbc0-3200-11d2-b4c2-00a0C9697d07}"
			$vClassName = "61883"
			$vClassExtName = "IEEE 1394 Devices That Support the 61883 Protocol"
			$vClassDesc = "This class includes IEEE 1394 devices that support the IEC-61883 protocol device class. The 61883 component includes the 61883.sys protocol driver that transmits various audio and video data streams over the 1394 bus. These currently include standard/high/low quality DV, MPEG2, DSS, and Audio. These data streams are defined by the IEC-61883 specifications."

		Case "{c06ff265-ae09-48f0-812c16753d7cba83}"
			$vClassName = "AVC"
			$vClassExtName = "IEEE 1394 Devices That Support the AVC Protocol"
			$vClassDesc = "This class includes IEEE 1394 devices that support the AVC protocol device class."

		Case "{d48179be-ec20-11d1-b6b8-00c04fa372a7}"
			$vClassName = "SBP2"
			$vClassExtName = "IEEE 1394 Devices That Support the SBP2 Protocol"
			$vClassDesc = "This class includes IEEE 1394 devices that support the SBP2 protocol device class."

		Case "{6bdd1fc1-810f-11d0-bec7-08002be2092f}"
			$vClassName = "1394"
			$vClassExtName = "IEEE 1394 Host Bus Controller"
			$vClassDesc = "This class includes 1394 host controllers connected on a PCI bus, but not 1394 peripherals. Drivers for this class are system-supplied."

		Case "{6bdd1fc6-810f-11d0-bec7-08002be2092f}"
			$vClassName = "Image"
			$vClassExtName = "Imaging Device"
			$vClassDesc = "This class includes still-image capture devices, digital cameras, and scanners. "

		Case "{6bdd1fc5-810f-11d0-bec7-08002be2092f}"
			$vClassName = "Infrared"
			$vClassExtName = "IrDA Devices"
			$vClassDesc = "Adapter class for other NDIS network adapter miniports."

		Case "{4d36e96b-e325-11ce-bfc1-08002be10318}"
			$vClassName = "Keyboard"
			$vClassExtName = "Keyboard"
			$vClassDesc = "This class includes all keyboards. That is, it must also be specified in the (secondary) INF for an enumerated child HID keyboard device."

		Case "{ce5939ae-ebde-11d0-b181-0000f8753ec4}"
			$vClassName = "MediumChanger"
			$vClassExtName = "Media Changers"
			$vClassDesc = "This class includes SCSI media changer devices."

		Case "{4d36e970-e325-11ce-bfc1-08002be10318}"
			$vClassName = "MTD"
			$vClassExtName = "Memory Technology Driver"
			$vClassDesc = "This class includes memory devices, such as flash memory cards."

		Case "{4d36e96d-e325-11ce-bfc1-08002be10318}"
			$vClassName = "Modem"
			$vClassExtName = "Modem"
			$vClassDesc = "This class includes modem devices. An INF file for a device of this class specifies the features and configuration of the device and stores this information in the registry. An INF file for a device of this class can also be used to install device drivers for a controllerless modem or a software modem. These devices split the functionality between the modem device and the device driver. For more information about modem INF files and Microsoft Windows Driver Model (WDM) modem devices, see Overview of Modem INF Files and Adding WDM Modem Support."

		Case "{4d36e96e-e325-11ce-bfc1-08002be10318}"
			$vClassName = "Monitor"
			$vClassExtName = "Monitor"
			$vClassDesc = "This class includes display monitors. An INF for a device of this class installs no device driver(s), but instead specifies the features of a particular monitor to be stored in the registry for use by drivers of video adapters. (Monitors are enumerated as the child devices of display adapters.)"

		Case "{4d36e96f-e325-11ce-bfc1-08002be10318}"
			$vClassName = "Mouse"
			$vClassExtName = "Mouse"
			$vClassDesc = "This class includes all mouse devices and other kinds of pointing devices, such as trackballs. That is, this class must also be specified in the (secondary) INF for an enumerated child HID mouse device."

		Case "{4d36e971-e325-11ce-bfc1-08002be10318}"
			$vClassName = "Multifunction"
			$vClassExtName = "Multifunction Devices"
			$vClassDesc = "This class includes combo cards, such as a PCMCIA modem and netcard adapter. The driver for such a Plug and Play multifunction device is installed under this class and enumerates the modem and netcard separately as its child devices."

		Case "{4d36e96c-e325-11ce-bfc1-08002be10318}"
			$vClassName = "Media"
			$vClassExtName = "Multimedia"
			$vClassDesc = "This class includes Audio and DVD multimedia devices, joystick ports, and full-motion video capture devices."

		Case "{50906cb8-ba12-11d1-bf5d-0000f805f530}"
			$vClassName = "MultiportSerial"
			$vClassExtName = "Multiport Serial Adapters"
			$vClassDesc = "This class includes intelligent multiport serial cards, but not peripheral devices that connect to its ports. It does not include unintelligent (16550-type) multiport serial controllers or single-port serial controllers (see the Ports class)."

		Case "{4d36e972-e325-11ce-bfc1-08002be10318}"
			$vClassName = "Net"
			$vClassExtName = "Network Adapter"
			$vClassDesc = "This class includes NDIS miniport drivers excluding Fast-IR miniport drivers, NDIS intermediate drivers (of virtual adapters), and CoNDIS MCM miniport drivers."

		Case "{4d36e973-e325-11ce-bfc1-08002be10318}"
			$vClassName = "NetClient"
			$vClassExtName = "Network Client"
			$vClassDesc = "This class includes network and/or print providers."

		Case "{4d36e974-e325-11ce-bfc1-08002be10318}"
			$vClassName = "NetService"
			$vClassExtName = "Network Service"
			$vClassDesc = "This class includes network services, such as redirectors and servers."

		Case "{4d36e975-e325-11ce-bfc1-08002be10318}"
			$vClassName = "NetTrans"
			$vClassExtName = "Network Transport"
			$vClassDesc = "This class includes NDIS protocols CoNDIS stand-alone call managers, and CoNDIS clients, in addition to higher level drivers in transport stacks."

		Case "{268c95a1-edfe-11d3-95c3-0010dc4050a5}"
			$vClassName = "SecurityAccelerator"
			$vClassExtName = "PCI SSL Accelerator"
			$vClassDesc = "This class includes devices that accelerate secure socket layer (SSL) cryptographic processing."

		Case "{4d36e977-e325-11ce-bfc1-08002be10318}"
			$vClassName = "PCMCIA"
			$vClassExtName = "PCMCIA Adapters"
			$vClassDesc = "This class includes PCMCIA and CardBus host controllers, but not PCMCIA or CardBus peripherals. Drivers for this class are system-supplied."

		Case "{4d36e978-e325-11ce-bfc1-08002be10318}"
			$vClassName = "Ports"
			$vClassExtName = "Ports (COM & LPT ports)"
			$vClassDesc = "This class includes serial and parallel port devices. See also the MultiportSerial class."

		Case "{4d36e979-e325-11ce-bfc1-08002be10318}"
			$vClassName = "Printer"
			$vClassExtName = "Printers"
			$vClassDesc = "This class includes printers."

		Case "{4658ee7e-f050-11d1-b6bd-00c04fa372a7}"
			$vClassName = "PNPPrinters"
			$vClassExtName = "Printers, Bus-specific class drivers"
			$vClassDesc = "This class includes SCSI/1394-enumerated printers. Drivers for this class provide printer communication for a specific bus."

		Case "{50127dc3-0f36-415e-a6cc-4cb3be910b65}"
			$vClassName = "Processor"
			$vClassExtName = "Processors"
			$vClassDesc = "This class includes processor types."

		Case "{4d36e97b-e325-11ce-bfc1-08002be10318}"
			$vClassName = "SCSIAdapter"
			$vClassExtName = "SCSI and RAID Controllers"
			$vClassDesc = "This class includes SCSI HBAs (Host Bus Adapters) and disk-array controllers."

		Case "{5175d334-c371-4806-b3ba-71fd53c9258d}"
			$vClassName = "Sensor"
			$vClassExtName = "Sensors"
			$vClassDesc = "(Windows 7 and later versions of Windows) This class includes sensor and location devices, such as GPS devices."

		Case "{50dd5230-ba8a-11d1-bf5d-0000f805f530}"
			$vClassName = "SmartCardReader"
			$vClassExtName = "Smart Card Readers"
			$vClassDesc = "This class includes smart card readers."

		Case "{71a27cdd-812a-11d0-bec7-08002be2092f}"
			$vClassName = "Volume"
			$vClassExtName = "Storage Volumes"
			$vClassDesc = "This class includes storage volumes as defined by the system-supplied logical volume manager and class drivers that create device objects to represent storage volumes, such as the system disk class driver."

		Case "{4d36e97d-e325-11ce-bfc1-08002be10318}"
			$vClassName = "System"
			$vClassExtName = "System Devices"
			$vClassDesc = "This class includes HALs, system buses, system bridges, the system ACPI driver, and the system volume manager driver."

		Case "{6d807884-7d21-11cf-801c-08002be10318}"
			$vClassName = "TapeDrive"
			$vClassExtName = "Tape Drives"
			$vClassDesc = "This class includes tape drives, including all tape miniclass drivers."

		Case "{36fc9e60-c465-11cf-8056-444553540000}"
			$vClassName = "USBDevice"
			$vClassExtName = "USB Device"
			$vClassDesc = "USBDevice includes all USB devices that do not belong to another class. This class is not used for USB host controllers and hubs"

		Case "{25dbce51-6c8f-4a72-8a6d-b54c2b4fc835}"
			$vClassName = "WCEUSBS"
			$vClassExtName = "Windows CE USB ActiveSync Devices"
			$vClassDesc = "This class includes Windows CE ActiveSync devices. The WCEUSBS setup class supports communication between a personal computer and a device that is compatible with the Windows CE ActiveSync driver (generally, PocketPC devices) over USB."

		Case "{eec5ad98-8080-425f-922a-dabf3de3f69a}"
			$vClassName = "WPD"
			$vClassExtName = "Windows Portable Devices (WPD)"
			$vClassDesc = "(Windows Vista and later versions of Windows) This class includes WPD devices."

		Case "{997b5d8d-c442-4f2e-baf3-9c8e671e9e21}"
			$vClassName = "SideShow"
			$vClassExtName = "Windows SideShow"
			$vClassDesc = "(Windows Vista and later versions of Windows) This class includes all devices that are compatible with Windows SideShow."

		Case "{2D3B1222-B28A-44f7-BE45-3D7FD2F57C43}" ; Emulex Crap
			$vClassName = "ElxPlus"
			$vClassExtName = "Emulex PLUS"
			$vClassDesc = ""

		Case "{1a3e09be-1e45-494b-9174-d7385b45bbf5}" ; NVIDIA Crap
			$vClassName = "Vendor_ClassName"
			$vClassExtName = "NVIDIA Network Bus Enumerator"
			$vClassDesc = ""

		Case "{4B571702-E6C6-4db1-A2C6-FD1D53A70FC3}" ; ALI Crap
			$vClassName = "ALiUSB"
			$vClassExtName = "ALi USB Controller"
			$vClassDesc = ""

		Case "{a0a588a4-c46f-4b37-b7ea-c82fe89870c6}" ; INTEL Crap
			$vClassName = "SDHost"
			$vClassExtName = "Intel SD Controller"
			$vClassDesc = ""

		Case "{555E05A3-904C-42cf-AEF4-EE4035EC6362}" ; Axalto Crap
			$vClassName = "Egatecard"
			$vClassExtName = "Axalto USB SD"
			$vClassDesc = ""

		Case "{09E9A11D-CCB2-45ae-9BE8-65C263E60490}" ; Broadcom Crap
			$vClassName = "CVAULT"
			$vClassExtName = "Broadcom Fingerprint Scanner"
			$vClassDesc = ""

		Case "{e7f8dc5e-a591-4264-8a30-6eae85be7a3f}" ; ActivCard Crap
			$vClassName = "ActivCardClass"
			$vClassExtName = "ActivCard SmartReader"
			$vClassDesc = ""

		Case "{084ABEA7-3EE1-4917-AA78-7670D1E625E1}" ; ActivCard Crap
			$vClassName = "ActivCardKeyBus"
			$vClassExtName = "ActivCard Virtual Reader Enumerator"
			$vClassDesc = ""

		Case "{41AD5E8B-5CB0-4275-B829-EDA617114AE8}" ; ActivCard Crap
			$vClassName = "ActivKeySimBus"
			$vClassExtName = "ActivIdentity SmartReader"
			$vClassDesc = ""

		Case Else
			Return ''

	EndSwitch

Return $vClassName

EndFunc

#cs
Func _FindDriversforDevicePath($driverLocation)
	$Array = RecursiveFileSearchwithoutFileNames($driverLocation, "(?i)\.inf",".",1)
	$avResult = _ArrayElements($Array, 1)
	$regAddArray = _ArrayToString($avResult, ";", 1)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion","DevicePath","REG_Expand_SZ",StringLower($regAddArray) &";C:\Windows\INF")
EndFunc
#ce

;----------------------------------------------------------------------------------------------------------
; Com Error Handler
;----------------------------------------------------------------------------------------------------------

Func MyErrFunc()
Local $HexNumber
Local $strMsg

$HexNumber = Hex($oMyError.Number, 8)
$strMsg = "Error Number: " & $HexNumber & @CRLF
$strMsg &= "WinDescription: " & $oMyError.WinDescription & @CRLF
$strMsg &= "Script Line: " & $oMyError.ScriptLine & @CRLF
MsgBox(0, "ERROR", $strMsg)
SetError(1)
Endfunc
