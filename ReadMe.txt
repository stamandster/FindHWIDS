FindHWIDS - The INF scanning HWID exporter

 === Introduction === 
FindHWIDS will output HWIDS from an INF file or files to a CSV, Excel or Sysprep.inf file. CSV and Excel output will give you all HWIDS including duplicates, plus driver date, version, etc. The Sysprep.inf output will not produce ANY duplicates. So there's no worry about crashing from having multiple HWIDS pointing to multiple INF's. And it'll only parse SCSIAdapter and HDC.

FindHWIDS will recursively scan a folder, looking at all folders within that one folder, for any INF files. It will then scan each INF file for HWIDS, those that aren't commented or not usuable in any way. FindHWIDS can also scan multiple different folders and/or files by dragging and dropping these into the Location input box.

FindHWIDS will also allow you to only export the hardware found in the current system. Useful for PE environments to export to sysprep.inf for an offline integration of MassStorage drivers. I haven't tested this function fully yet with PE. So please test!

You can also install drivers for hardware currently installed on your system.

There's also the ability to export all current hardware in the system to a log file, with information about the currently installed hardware. Useful for testing and troubleshooting purposes.

 === Change Log ===
v3.2s @ 2012-10-16 -
-- Now a 64b version available! (quicker too!)
-- Speed up CRC32 hashing
v3.2r @ 2012-10-15 -
-- Changed Checksum to CRC32 and made it an internal script instead of a third party DLL, also make export about 8% smaller
-- Please be aware the the longer the location and name of the CSV file the longer it may take for the export to complete
-- Adjusted some information for message boxes
-- You can search for PNP Id's at the start of the HWID like PCI\VEN or a string within the HWID like SUBSYS_123456C
-- UPX Compression changed to lowest to help with virus scanners
-- Changed initial CSV name to FindHWIDS-DATE-TIME.csv, which should help with historical testing and continuous testing
-- Created a ClassGUID translator to help speed up (and correct) Classes (because it won't have to reread the INF)
v3.2p @ 2011-02-28 -
-- Fixed issue with Reading sections bombing when key/value is directly followed by a section
v3.2m @ 2010-04-18 -
-- Fixed some wording issues
-- Re-organized installed files and cleanup
v3.2l @ 2009-12-13 -
-- Hopefully fixed the issue with selecting OS Arch and OS Type
v3.2j @ 2009-06-22 -
-- Added filters for processor arch and os version, you must select BOTH an OS version and processor architecture
-- Fix scan count again, will only count true/real INF files
-- Sysprep will not automatically select only currently installed hardware, so a user can select the OS Version and Processor Arch offline if needed
v3.2i @ 2009-04-29 -
-- Improves speed during filter searches
v3.2h @ 2009-04-11 -
-- Added ability to set CSV and Sysprep filenames and locations. If you don't use the default sysprep location it will warn you that sysprep will not process. All Warning and a Error messages will close after 5 seconds and will bring you back to the Main window.
-- Added a progress bar that will show the total amount of INF files scanned, so the user has some feedback on how long the process is taking
-- If the CSV file already exists it will delete it NOT append to it. If the sysprep.inf file exists it will append to it, if the file does not exist but the location is writeable a file will be created.
v3.2g @ 2009-04-02 -
-- Fixed issues with OS type and OS Arch filters filtering properly
-- Added 2008 and Vista to OS type and OS arch filter
-- At start of scan window will minimize, at end of scan window will restore
-- Choosing no export types will show a prompt telling you to choose an export type
-- Changed Export Hardware list with an additional Service property and changed arrangement of output
v3.2f @ 2009-03-20 -
-- Changed so that you can export multiple types at a time (getting ready for reg import, oempnpdrivers section)
-- Removed Excel functionality because:
---- 1) Excel dependency and 
---- 2) CSV is faster and produces the same output and 
---- 3) Having to edit both the CSV and Excel to look the same was annoying
-- Improved GUI look and added banner
-- Improved and cleaned up some backend code
v3.2e @ 2009-02-27 - 
-- Fixes tip help from "comma" to "Pipe symbol"
-- Fixes some internals issues with deleting old export hardware profile
-- Changed visuals to all display internally on main window, exporting hardware profile will not show tooltip
-- More visual changes - clear button for locations, filters
-- Fixes main window on top issue when browsing for folder/file locations
v3.2d @ 2009-02-26 - 
-- Fixed issue with timers displaying properly. 
-- Speeds up exporting via Excel by hiding Excel
-- Adds ClassGUID to outputs Excel and CSV
-- Change GUI background to white
-- Scanning process no longer minimizes main window and adds Tooltip processing. Processing staying in main window and updates Statusbar area. 
-- Fixes issue with _INIReadSectionEx to skip commented out lines.
-- Fixes issue with adding any HWID filters. You must use the Pipe symbol on all filter seperations. Updated the help functions to coincide with changes.
v3.2c @ 2009-02-26 - Add ClassGUID to output.
v3.2b @ 2009-02-24 - Fixed issue with counting INF files scanned. Changed exit function to delete only data it put there. Fixes issue with the inireadsection not grabbing data over 32k, now using Smoke_N UDF to pull data from the sections. Will now pull all HWIDS! This version DOES NOT scan for duplicate files.
v3.2.1 @ 2008-11-02 6:55pm EST - (NOT RELEASED) Added a function to scan for duplicate inf files.
v3.2 @ 2008-10-26 11:48pm EST - Created a function to scan for variables within the INF. Reducing bad data (hopefully eliminated). Scan speed is about the same.
v3.1.9.1 @ 2008-10-23 2:19pm EST - Scan time has also been reduced about 20%.
v3.1.9 @ 2008-10-23 11:49pm EST - Fixed flawed logic with strings. Hopefully rebuilding soon with a better way of handling strings. Though this version fixes some missed converting of strings into hwids.
v3.1.8 @ 2008-10-22 6:28pm EST - Adds install as an option (with DPinst.exe 32bit english only, copyright Microsoft), installing only hardware found on machine. Improves on scanning speed. Fixes some strings issue.
v3.1.7 @ 2008-09-28 5:42pm EST - Adds scan time, files scanned and hwids found to excel and csv output. Moved scanning of certain parts of the INF to produce a faster scan. Changed during scan the FindHWIDs window now minimizes.
v3.1.6 @ 2008-09-28 4:41pm EST - Fixes CSV output to mimic Excel output. Now exports the INF Description (also still outputs the PNPID description)
v3.1.5 @ 2008-09-26 11:03am EST - Added OS and OS Architecture as a filter. Choosing sysprep output will automatically choose filtering of OS and OS architecture. You can split multiple folders/files with a pipe symbol to scan granularly.
v3.1.3 @ 2008-09-26 11:03am EST - Changed find hash to use a dll instead. Much faster, in fact almost as fast as native scanning. Adding MD5 and Class to csv output.
v3.1.2 @ 2008-09-26 10:46am EST - Added md5deep to check hashing, however this version is extremely slow.
v3.1.1 @ 2008-09-26 8:24am EST - Changes Sysprep to scan for only SCSIAdapter and HDC. Corrected hardware filter for OS and Arch types.
v3.1 @ 2008-09-23 3:04pm EST - Adds functionality to the hardware filter to filter OS and architecture. Still debating whether to have System class for Sysprep.inf exports
v3.0.9 @ 2008-09-23 11:29pm EST - About is now a text file so users can see full change log. When you press Esc the program will now exit. Added more fixes for string management. The program will tell you if it the INF file does not have the appropriate data included. You can now drag and drop multiple files and folders into the input box. You can also mix files or folders together.
v3.0.8 @ 2008-09-22 7:32pm EST - INTERNAL - fixed some issues, don't remember :|
v3.0.7 @ 2008-09-22 6:04pm EST - Rebuilt functions to grab Manufacturer and other strings. Should reduce bad data.
v3.0.6 @ 2008-09-22 2:21pm EST - Created a new function to strip strings of certain items to reduce or eliminate bad data. Exported data will now save to a temp folder if it cannot write to the current directory. Fixed issue with opening the hardware export log on x64 machines. Should also see a little speed increase. You can drag and drop a file or folder to search into the location input box.
v3.0.5 @ 2008-09-18 2:18pm EST - Adds exporting of only the found HWIDS from the current system. Also, the ability capture just the hardware in the system to a log file. Same as sav_hwid.exe. New feature take advantage of WMI.
v3.0.4 @ 2008-09-18 2:18pm EST - Fixes a couple grammatical errors. Added ability to search for one or more specific PNP ID's.
v3.0.3 @ 2008-09-18 12:04am EST - Fixes quotes in HWID string.
v3.0.2 @ 2008-09-17 11:47pm EST - Added ability to filter classes. Updated the GUI to reflect extra options. Added an about button. Excel minimizes during Excel export. Sysprep only exports classes SCSIAdapter, HDC and System. Add ability to scan a specific INF file or a folder of INF files recursively.
v3.0.1 @ 2008-09-15 10:59pm EST - Adds some fixes for Sysprep to only export SCSIAdapter and HDC hwid types. Export to Excel gives more information. The GUI has changed and is a bit easier to use.
v2.9 @ 2008-09-11 3:11pm EST - Added more information that's parsed to excel. Fixed a couple issues with parsed information. Changed what's displayed in the tooltip area.
v2.8 @ 2008-09-11 11:19pm EST - Adds ability to export to an Excel spreadsheet. You must have Word installed in order for this to work. You can type excel into the option instead of sysprep or cvs.
v2.7 @ 2008-09-11 7:51pm EST - Fixed issues for string Manufacturers with quotes in value.
v2.6 @ 2008-09-11 11:08am EST - Fixed an issue with HWIDS that could be blank
v2.5 @ 2008-09-11 9:42am EST - Completely changed logic of scanning again (third times the charm). Scans are considerably faster and as accurate as I think they'll ever be.
v2.4 @ 2008-09-08 1:03pm EST - Changed everything this time around, new logic for finding HWIDS; It doesn't scan for a specific HWID and will do multiple HWIDS inline. Meaning it's more accurate.
v1.9 - INTERNAL Last version that finds HWIDS by HWID type - which isn't as accurate
v1.8 @ 2008-09-03 11:51am EST - Fixed some dyslexia for CSV and CVS; Added Display\, PCIIDE\, IDE\ and ISAPNP\
v1.7 @ 2008-09-02 2:33pm EST - Adds USBSTOR\ and HID\ , Adds a simple GUI for entering location and parse to type
v1.6 @ 2008-09-01 11:00pm EST - Migrated to Array function boosting completion time by 5 times or more (for example scanning Sound, w/ 14,219 HWIDS, took 277 seconds and now takes 54 seconds). Added line number from the INF file to make it easier finding issues with HWIDS.
v1.5 - INTERNAL Added more checks for HKR, HKLM and HKCR because of crazy asterisks
v1.4 @ 2008-09-01 3:18pm EST - Adds AHCI\ and ACPI\ to the parse list - Changed $ParseTo variable to accept both CSV and Sysprep as options
v1.3 - Adds ability to output to CSV and also gets Version - Sysprep is still the same just use blank for $ParseTo
v1.2 - Added checks for USB\ and HDAUDIO\FUNC, ExcludeFromSelect will not be added
v1.1 - Added check for SCSI\, * type and GenNvRaidDisk
v1.0 - Base check HWIDS for on PCI\VEN, will not add commented out lines and will not add end of lines that have been commented out