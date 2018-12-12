;; To allow re-run without dialog box.
#SingleInstance force

DetectHiddenWindows, on
SetTitleMatchMode, 2

normalYouTubeURL := "https://www.youtube.com/watch?v="
normalYouTubeURLSize := StrLen( normalYouTubeURL )
embedYouTubeURL := "https://www.youtube.com/embed/"
embedYouTubeURLSize := StrLen( embedYouTubeURL )
embedYouTubeURLNoAutoPlay := "?autoplay=0&playsinline=0"
youTubeIdSize := 11

; lastCopyTime = 0
; lastClipboard = ""
blockOnClipboardChange = 0

;; Counter for launch commands.
launchCounter := 1

;; Remember what was launched so that the correct end sequence can be sent.
launchType := ""

;; Array to store launch commands (positional and sequential).
launchMap := {}

; #Include %A_ScriptDir%


;; Swap to our own menu, which is the original with a few modifications.
Gosub, TRAYMENU




; Define the tray menu.
TRAYMENU:
    applicationname = Short Cut Keys
    Menu, Tray, NoStandard
    Menu, Tray, DeleteAll 
    Menu, Tray, Add, %applicationname%, TrayMenuHdlr_ScriptEdit
    Menu, Tray, Add, Show &Debug Console, TrayMenuHdlr_DebugConsole
    Menu, Tray, Add, &Help, TrayMenuHdlr_Help
    Menu, Tray, Add ; Creates a separator line.
    Menu, Tray, Add, &Window Spy, TrayMenuHdlr_WinSpy
    Menu, Tray, Add, &Reload Script, TrayMenuHdlr_ScriptReload
    Menu, Tray, Add, &Edit Script, TrayMenuHdlr_ScriptEdit
    Menu, Tray, Add, &List Hot Keys, TrayMenuHdlr_ShowHotKeyList
    Menu, Tray, Add, &List Other Keys, TrayMenuHdlr_ShowOtherKeyList
    Menu, Tray, Add ; Creates a separator line.
    Menu, Tray, Add, &Suspend Hot Keys, TrayMenuHdlr_Suspend
    Menu, Tray, Add, &Pause Script, TrayMenuHdlr_Pause
    Menu, Tray, Add, E&xit, TrayMenuHdlr_GuiClose
    Menu, Tray, Default, %applicationname%
    Menu, Tray, Tip, %applicationname%
return


TrayMenuHdlr_ShowHotKeyList:
    SetBatchLines, -1
    AutoTrim, off

    hotKeyStartStr := ";; Hot keys setup."
    lenHotKeyStartStr := StrLen( hotKeyStartStr )
    hotkeyStartRead := 0
    lastComment := ""
    keyList := ""

    Loop, Read, %A_ScriptDir%\%A_ScriptName%
    {
        line = %A_LoopReadLine%

        if ( ! line or RegExMatch( line, "^\s*;(?!;)" ) )
        {
            continue
        }

        if ( ! hotkeyStartRead )
        {
            if ( hotKeyStartStr == SubStr( line, 1, lenHotKeyStartStr ) )
            {
                hotkeyStartRead := 1
            }

            continue
        }

        if ( InStr( line, ";;" ) )
        {
            StringTrimLeft, line, line, 3
            lastComment := lastComment . " " . line

            continue
        }

        if ( ! InStr( line, "::" ) )
        {
            continue
        }

		if ( SubStr( line, 1, 2 ) == "::" )
		{
			keys := StrSplit( line, ":" )
			key := keys[3] . "<space>"

            keyLine := Format( "{1:-16}{2}`n", key, lastComment )
            keyList := keyList . keyLine

            lastComment := ""
		}
        else if ( InStr( line, "::" ) )
        {
            keys := StrSplit( line, ":" )
            key := keys[1]

            StringReplace, key, key, #, Win-
            StringReplace, key, key, !, Alt-
            StringReplace, key, key, ^, Ctrl-
            StringReplace, key, key, +, Shift-
            StringReplace, key, key, `;,

            ; key = %key%               !

            ; StringLeft, key, key, 15
            ; StringSplit, comment, line, `;
            ; StringTrimLeft, comment, comment%comment0%, 0

            keyLine := Format( "{1:-20}{2}`n", key, lastComment )
            keyList := keyList . keyLine
            ; keyList := keyList . key . "`t" . lastComment . "`n"

            lastComment := ""
        }
    }

    MsgBox, 0, Hot Keys List, %keyList%
    keyList=
return

TrayMenuHdlr_ShowOtherKeyList:
	keyList :=           "<space>		Play/Pause VideoLAN, YouTube, etc.`n"
	keyList := keyList . "Ctrl-q		Quit VideoLAN.`n"
	keyList := keyList . "Alt-<Tab>	Cycle through windows.`n"
	keyList := keyList . "Win-<Tab>	Cycle through windows in 3D.`n"
	keyList := keyList . "Alt-<Esc>		Cycle through windows in the order they were opened.`n"
	keyList := keyList . "Win-r		Run command.`n"
	keyList := keyList . "Win-e		Open File Explorer.`n"
	keyList := keyList . "Ctrl-Shift-<Esc>	Open Task Manager.`n"
	keyList := keyList . "Win-<Up>		Maximise the active window.`n"
	keyList := keyList . "Win-<Down>		Minimise the active window.`n"
	keyList := keyList . "Win-<Left>		Maximise the active window to the left.`n"
	keyList := keyList . "Win-<Right>		Maximise the active window to the right.`n"
	keyList := keyList . "Win-<Home>		Minimise all but the active window.`n"
	keyList := keyList . "Win-Shift-<Right>	Shift active window to next screen.`n"
	keyList := keyList . "Win-Shift-<Left>	Shift active window to previous screen.`n"
    MsgBox, 0, Other Keys List, %keyList%
return


TrayMenuHdlr_ScriptReload:
    Reload
return


TrayMenuHdlr_ScriptEdit:
    Run, notepad++.exe %A_ScriptName%
return


TrayMenuHdlr_DebugConsole:
    ListLines
return


TrayMenuHdlr_WinSpy:
    RegRead ahkInstallDir, HKEY_LOCAL_MACHINE, SOFTWARE\AutoHotkey, InstallDir
    Run %ahkInstallDir%\WindowSpy.ahk
    WinWait Window Spy,,3

    if not ErrorLevel
        WinMove Window Spy,, A_ScreenWidth-400, 200 ; Move the window to the side a little for convenience.
return


TrayMenuHdlr_WinSpyEXE:
    RegRead ahkInstallDir, HKEY_LOCAL_MACHINE, SOFTWARE\AutoHotkey, InstallDir
    Run %ahkInstallDir%\AU3_Spy.exe
    WinWait Active Window Info,,3

    if not ErrorLevel
        WinMove A,, A_ScreenWidth-400, 200 ; Move the window to the side a little for convenience.
return


TrayMenuHdlr_Help:
    IfWinExist AutoHotkey Help
        WinActivate
    else
    {    
        RegRead ahkInstallDir, HKEY_LOCAL_MACHINE, SOFTWARE\AutoHotkey, InstallDir
        Run %ahkInstallDir%\AutoHotKey.chm
    }
return


TrayMenuHdlr_Suspend:
    Suspend Toggle

    if ( A_IsSuspended )
    {
        Menu, Tray, Check, &Suspend Hot Keys
    }
    else
    {
        Menu, Tray, Uncheck, &Suspend Hot Keys
    }
return


TrayMenuHdlr_Pause:
    if ( A_IsPaused )
    {
        Pause off
        Menu, Tray, Uncheck, &Pause Script
    }
    else
    {
        Menu, Tray, Check, &Pause Script
        Pause On
    }
return


TrayMenuHdlr_GuiClose:
    ExitApp
return


reset()
{
	clearClipBoard()
	global launchType
	launchType := ""
	global launchMap
	launchMap := {}
	global launchCounter
	launchCounter = 1
}


clearClipBoard()
{
	clipboard =
}


getClipBoard( useCurrent = 0 )
{
	clipBoardStr = %clipboard%
	
	if ( 0 == useCurrent or clipBoardStr == "" )
	{
		; blockOnClipboardChange = 1
		clipboard =
		Send ^c
		ClipWait, 2
		; blockOnClipboardChange = 0

		if ErrorLevel
		{
			return ""
		}
		
		clipBoardStr = %clipboard%
	}

    StringReplace, clipBoardStr, clipBoardStr, 's`r`n, , All

    return clipBoardStr
}


; OnClipboardChange:
; if (A_EventInfo = 1 and blockOnClipboardChange = 0)
; {
;     if (A_TickCount - lastCopyTime < 500 and lastClipboard != "")
;     {
;         StringReplace, lastClipboard, lastClipboard, 's`r`n, , All
;         StringLeft, firstChar, lastClipboard, 1
;         if firstChar between 0 and 9 
;             Run http://wem5/cgi-bin/opencurbug/opencurwithform.pl?events=y&showbugdata=y&hotline=y&callnum=%lastClipboard%
;     }
;     lastCopyTime = %A_TickCount%
;     lastClipboard = %clipboard%
; }
; return


; -----------------------------------------------------------------------
; Get the position and size of the desktop, taking the taskbar area into account.
; This function probably doesn't work on secondary monitors.
Win__GetDesktopPos(ByRef X, ByRef Y, ByRef W, ByRef H)
{
    ; Get dimensions of the system tray (taskbar)
    WinGetPos, TrayX, TrayY, TrayW, TrayH, ahk_class Shell_TrayWnd

    if (TrayW = A_ScreenWidth)
    {
        ; Horizontal Taskbar
        X := 0
        Y := TrayY ? 0 : TrayH
        W := A_ScreenWidth
        H := A_ScreenHeight - TrayH
    }
    else
    {
        ; Vertical Taskbar
        X := TrayX ? 0 : TrayW
        Y := 0
        W := A_ScreenWidth - TrayW
        H := A_ScreenHeight
    }
}


; -----------------------------------------------------------------------
; Mimic Windows-7 Win-Left Key Combination
Win__HalfLeft()
{
    Win__GetDesktopPos(X, Y, W, H)
    WinMove, A,, X, Y, W/2, H
}


; -----------------------------------------------------------------------
; Mimic Windows-7 Win-Right Key Combination
Win__HalfRight()
{   
    Win__GetDesktopPos(X, Y, W, H)
    WinMove, A,, X + W/2, Y, W/2, H
}


altMsgBox( title, text )
{
	text := Format( "{1:-80}", text )
	Gui, altmsgbox:Add, Text, , %text%
	Gui, altmsgbox:Add, Button, galtMsgBoxClose Default w80 x+-80 y+m, OK
	Gui, altmsgbox:Show, Center, %title%
	WinWaitClose, %title%
	; Tooltip, Script is still running
	; Sleep 20000
	; Tooltip,
}


altMsgBoxClose()
{
	Gui, altmsgbox:Destroy
}


RaiseWindow( name )
{
    ; MsgBox %name%

    if ( name != "" )
    {
        SetTitleMatchMode, 1
        WinWait %name%, "", 4
        WinActivate %name%
    }
}


;; Paste plain clipboard text.
paste()
{
    tempClipboard = %clipboard%
    clipboard = %tempClipboard% 
    Send ^v
}


;; Launch a google search for the current selection.
googleSearch()
{
    searchStr := getClipBoard()

    if ( searchStr == "" )
    {
        return
    }

    Run "http://www.google.co.uk/search?hl=en&q=%searchStr%&btnG=Search"
}


;; Launch a google search for the current selection.
youTubeSearch()
{
    searchStr := getClipBoard()

    if ( searchStr == "" )
    {
		Run "https://www.youtube.com/?gl=GB&hl=en-GB"
    }
	else
	{
	    Run "https://www.youtube.com/results?search_query=%searchStr%"
	}
}


playYouTube()
{
	Click
}


pauseOrPlayYouTubeOrVideoLAN()
{
	Send {Space}
}


; Full screen normal URL.
fullScreenYouTube()
{
	Send f
}


; Full screen embed URL.
fullScreenEmbedYouTube()
{
	Send {F11}
}


composeYouTubeURL( youTubeURLOrId, autoPlay = 0, embed = 1 )
{
	global embedYouTubeURL
	global normalYouTubeURL
	global embedYouTubeURLNoAutoPlay
	global embedYouTubeURLSize
	global normalYouTubeURLSize
	global youTubeIdSize
	
	if ( youTubeURLOrId == "" )
	{
		return ""
	}
	
	youTubeIdPos := InStr( youTubeURLOrId, embedYouTubeURL )
	
	if ( 0 != youTubeIdPos )
	{
		youTubeIdPos := youTubeIdPos + embedYouTubeURLSize
	}
	else
	{
		youTubeIdPos := InStr( youTubeURLOrId, normalYouTubeURL )
		
		if ( 0 != youTubeIdPos )
		{
			youTubeIdPos := youTubeIdPos + normalYouTubeURLSize
		}
		else
		{
			youTubeIdPos := 1
		}
	}
	
	youTubeId := SubStr( youTubeURLOrId, youTubeIdPos, youTubeIdSize )
	
	; MsgBox %youTubeIdPos% %youTubeIdSize% %youTubeId%
	
	if ( embed )
	{
		youTubeURL := embedYouTubeURL . youTubeId
	}
	else
	{
		youTubeURL := normalYouTubeURL . youTubeId
	}
	
	if ( 0 == autoPlay )
	{
		youTubeURL := youTubeURL . embedYouTubeURLNoAutoPlay
	}
	
	; MsgBox %youTubeURL%
	
	return youTubeURL
}
 

;; Launch YouTube clip full screen on projected displays.
launchYouTube( youTubeURLOrId = "", autoPlay = 0, winTitle = "" )
{
	if ( youTubeURLOrId == "" )
	{
		youTubeURLOrId := getClipBoard()
	
		if ( youTubeURLOrId == "" )
		{
			return
		}
	}
	
	youTubeURL := composeYouTubeURL( youTubeURLOrId, autoPlay )
	
	; MsgBox %youTubeURL%

	Run %youTubeURL%
	WinActivate ahk_class MozillaWindowClass
	
	if ( winTitle == "" )
	{
		WinWait - YouTube,,8
	}
	else
	{
		WinWait %winTitle%,,8
	}
	
	global launchType
	launchType := "YouTube"
	
	Sleep 1400
	
	; fullScreenYouTube()
	fullScreenEmbedYouTube()
	
	playYouTube()

	if ( 0 == autoPlay )
	{
		pauseOrPlayYouTubeOrVideoLAN()
	}
}


;; Launch YouTube clip full screen on projected displays.
projectYouTube( youTubeURLOrId = "", autoPlay = 0, winTitle = ""  )
{
	launchYouTube( youTubeURLOrId, autoPlay, winTitle )
	Send +#{Right}
}


;; Swap projected application to PC screen.
endProject()
{
	global launchType
	
	Send +#{Left}
	
	if ( launchType == "YouTube" )
	{
		Send {F11}
	}
	else if ( launchType == "VideoLAN" )
	{
		; pauseOrPlayYouTubeOrVideoLAN()
		; Send f
		Send ^q
	}
	
	launchType := ""
}


;; Launch active window YouTube clip full screen on projected displays.
projectActiveWindowYouTube()
{
	; Full screen, pause, send to other display.
	Send f
	Send {Space}
	Send +#{Right}
}


getHoveredYouTubeURL()
{
	Send {RButton}
	Sleep 200
	Send a
	Sleep 200
	Send {Enter}
	Sleep 200
	
	youTubeURL := getClipBoard()
	; MsgBox %youTubeURL%
	
	return youTubeURL
}


;; Launch youtube clip hovered over.
projectHoveredYouTube()
{
	youTubeURL := getHoveredYouTubeURL()
	projectYouTube( youTubeURL )
}


;; Launch YouTube clip full screen on projected displays.
launchVideoLAN( videoFile = "", autoPlay = 0 )
{
	if ( videoFile == "" )
	{
		; This also gets selected file.
		videoFile := getClipBoard()
	}
	
	if ( videoFile == "" )
	{
		return
	}
	
	global launchType
	launchType := "VideoLAN"
	
	; MsgBox, %videoFile%
	Run "C:\Program Files (x86)\VideoLAN\VLC\vlc.exe" --started-from-file "%videoFile%"
	; WinWait ahk_class WMP Skin Host,,8
	; Send {F11}
	WinWait VLC media player,,8
	
	if ( 0 == autoPlay )
	{
		pauseOrPlayYouTubeOrVideoLAN()
	}
}


;; Launch YouTube clip full screen on projected displays.
projectVideoLAN( videoFile = "", autoPlay = 0 )
{
	launchVideoLAN( videoFile, autoPlay )
	Send +#{Right}
}


;; Store a context value when a key is pressed.
storeLaunchCommand( key )
{
	global launchMap
	
	; This also gets selected file.
	launchCommand := getClipBoard()
	
	if ( launchCommand == "" and 0 != WinActive( "- YouTube" ) )
	{
		launchCommand := getHoveredYouTubeURL()
		clearClipBoard()
	}

	if ( launchCommand != "" )
	{
		launchMap[(key)] := launchCommand
		launchCommand := launchMap[(key)]
		; MsgBox Stored launch command "%launchCommand%" as "%key%".
	}
}


launchStoredCommand( key )
{
	global launchMap
	
	launchCommand := launchMap[(key)]
	
	if ( launchCommand == "" )
	{
		return
	}
	
	; MsgBox Launching "%launchCommand%".

	if ( InStr( launchCommand, "youtube" ) )
	{
		projectYouTube( launchCommand, 1 )
	}
	else
	{
		projectVideoLAN( launchCommand, 1 )
	}
}


showStoredLaunchCommands()
{
	global launchMap
    keyList := ""
	
	; altMsgBox( "Entries", "Number of entries: " . launchMap.Count() )
	
	For key, value in launchMap
	{
		; keyVal := key . " " . value
		; altMsgBox( "Debug", keyVal )
		keyLine := Format( "{1:-8}{2}`n", key, value )
		keyList := keyList . keyLine
	}
	
	if ( keyList != "" )
	{
		title := "Stored Videos"
		altMsgBox( title, keyList )
		; MsgBox, , %title%, %keyList%
	}
}


;; Test function.
test( str )
{
	clip := getClipBoard()
	
	if ( str == clip )
	{
		MsgBox, "%str%"
	}
	else
	{
		MsgBox,
			(
				"%str%"
				"%clip%"
			)
	}
}




;; Hot keys setup.
; #<key> 		- WindowsKey+<key>
; ^<key> 		- Ctrl+<key>
; +<key> 		- Shift+<key>
; !<key> 		- Alt+<key>
; <key>&<key> 	- Combine 2 keys into a custom key.

;; Open Windows hot key help page.
#h::Run "https://support.microsoft.com/en-gb/help/12445/windows-keyboard-shortcuts"

;; Test string to say "Hello!".
::hlo::
MsgBox, Hello!
return

;; Call test function.
#t::
test( "C:\Users\Zed\Videos\Videos22\December 2016 Matt Filming 2\P1120970.MOV" )
return

;; Reload the AutoHotKey script.
#r::Reload

;; Reset stored data.
^+r::reset()

;; Clear the clipboard.
+^c::clearClipBoard()

;; Open Explorer window.
#e::Run c:\windows\explorer.exe  /n`, /e`, C:\

;; Launch a google search for the current selection.
#g::googleSearch()

;; Open YouTube search.
#s::youTubeSearch()

;; End project.
#q::endProject()

;; Open YouTube search.
#y::projectYouTube( "", 1 )

;; Project current YouTube clip at full screen.
#p::projectActiveWindowYouTube()

; Project hovered over YouTube clip at full screen.
; Does work for some but not others.
^p::projectHoveredYouTube()

;; Show selected video file full screen on the projected display.
#v::projectVideoLAN( "", 1 )

;; Store positional launch command 1 for later launch.
^+1::storeLaunchCommand( "p1" )

;; Store positional launch command 2 for later launch.
^+2::storeLaunchCommand( "p2" )

;; Store positional launch command 3 for later launch.
^+3::storeLaunchCommand( "p3" )

;; Store positional launch command 4 for later launch.
^+4::storeLaunchCommand( "p4" )

;; Store positional launch command 5 for later launch.
^+5::storeLaunchCommand( "p5" )

;; Store positional launch command 6 for later launch.
^+6::storeLaunchCommand( "p6" )

;; Store positional launch command 7 for later launch.
^+7::storeLaunchCommand( "p7" )

;; Store positional launch command 8 for later launch.
^+8::storeLaunchCommand( "p8" )

; Invoke stored launch command 1.
; Doesn't work.
; ^{Numpad1}::launchStoredCommand( "p1" )

;; Invoke stored launch command 1.
^1::launchStoredCommand( "p1" )

;; Invoke stored launch command 2.
^2::launchStoredCommand( "p2" )

;; Invoke stored launch command 3.
^3::launchStoredCommand( "p3" )

;; Invoke stored launch command 4.
^4::launchStoredCommand( "p4" )

;; Invoke stored launch command 5.
^5::launchStoredCommand( "p5" )

;; Invoke stored launch command 6.
^6::launchStoredCommand( "p6" )

;; Invoke stored launch command 7.
^7::launchStoredCommand( "p7" )

;; Invoke stored launch command 8.
^8::launchStoredCommand( "p8" )

;; Show stored launch commands.
!#v::showStoredLaunchCommands()


; Setup quick display of videos, YouTube clips etc. here.

;; Show YouTube video full screen on the projected display (paused).
::yt1::
projectYouTube( "MknJkRGErwY", 0 ) ; , "The rarest" )
return

;; Show YouTube video full screen on the projected display (autoplay).
::yt2::
projectYouTube( "MknJkRGErwY", 1 ) ; , "The rarest" )
return

;;


;; Show video file full screen on the projected display.
; ::v1::
; launchVideoLAN( "C:\Users\Zed\Videos\Videos22\December 2016 Matt Filming 2\P1120970.MOV" )
; return
; 
; ::v2::
; projectVideoLAN()
; return

; ;; Make current window fill half of the screen to the left.
; Alt & Left::    Win__HalfLeft()
; ;; Make current window fill half of the screen to the right.
; Alt & Right::  Win__HalfRight()

;; Paste plain clipboard text.
; #v::paste()
