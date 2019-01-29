;; To allow re-run without dialog box.
#SingleInstance force

DetectHiddenWindows, on
SetTitleMatchMode, 2

WindowsPath := "C:\Windows"
LogFile := "C:\tmp\shortcutkeys.log"
Logging := false
Debug := false
NormalYouTubeURL := "https://www.youtube.com/watch?v="
NormalYouTubeURLSize := StrLen( NormalYouTubeURL )
EmbedYouTubeURL := "https://www.youtube.com/embed/"
EmbedYouTubeURLSize := StrLen( EmbedYouTubeURL )
EmbedYouTubeURLAutoPlay := "?autoplay=1"
EmbedYouTubeURLNoAutoPlay := "?autoplay=0"
EmbedYouTubePlaysInline := "&playsinline=1" ; Doesn't work.
YouTubeIdSize := 11
SelectedBrowser := "Edge"

; lastCopyTime = 0
; lastClipboard = ""
blockOnClipboardChange = 0

;; Counter for launch commands.
launchCounter := 1

;; Remember what was launched so that the correct end sequence can be sent.
launchType := ""
launchTypeModifier := ""
launchWin := ""
launchWinID := 0

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
	showHotKeyList()
return

TrayMenuHdlr_ShowOtherKeyList:
    keyList :=           "<space>        Play/Pause VideoLAN, YouTube, etc.`n"
    keyList := keyList . "Ctrl-q        Quit VideoLAN.`n"
    keyList := keyList . "Alt-<Tab>    Cycle through windows.`n"
    keyList := keyList . "Win-<Tab>    Cycle through windows in 3D.`n"
    keyList := keyList . "Alt-<Esc>        Cycle through windows in the order they were opened.`n"
    keyList := keyList . "Win-r        Run command.`n"
    keyList := keyList . "Win-e        Open File Explorer.`n"
    keyList := keyList . "Ctrl-Shift-<Esc>    Open Task Manager.`n"
    keyList := keyList . "Win-<Up>        Maximise the active window.`n"
    keyList := keyList . "Win-<Down>        Minimise the active window.`n"
    keyList := keyList . "Win-<Left>        Maximise the active window to the left.`n"
    keyList := keyList . "Win-<Right>        Maximise the active window to the right.`n"
    keyList := keyList . "Win-<Home>        Minimise all but the active window.`n"
    keyList := keyList . "Win-Shift-<Right>    Shift active window to next screen.`n"
    keyList := keyList . "Win-Shift-<Left>    Shift active window to previous screen.`n"
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


createLog()
{
	global LogFile
	global Logging
	
	if ( Logging )
	{
		file := FileOpen( LogFile, "w" )
		file.Close()
	}
}


log( text )
{
	global LogFile
	global Logging
	
	if ( Logging )
	{
		; FileAppend, %text% "`n", %LogFile%
		file := FileOpen( LogFile, "a" )
		file.Write( text "`n" )
		file.Close()
	}
}


logActiveWindowID( label )
{
	activeWinID := WinExist( "A" )
	
	log( label " logActiveWindowID() -> " activeWinID )
}


showHotKeyList()
{
	global Debug
	
    SetBatchLines, -1
    AutoTrim, off

    hotKeyStartStr := ";; Hot keys setup."
    hotKeyEndStr := ";; Hot keys end."
    lenHotKeyStartStr := StrLen( hotKeyStartStr )
    lenHotKeyEndStr := StrLen( hotKeyEndStr )
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
		
		if ( ! Debug and hotKeyEndStr == SubStr( line, 1, lenHotKeyEndStr ) )
		{
			break
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
        else if ( SubStr( line, 1, 3 ) == ":*:" )
        {
            keys := StrSplit( line, ":" )
            key := keys[3]

            keyLine := Format( "{1:-16}{2}`n", key, lastComment )
            keyList := keyList . keyLine

            lastComment := ""
        }
        else ; if ( InStr( line, "::" ) )
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

    ; MsgBox, 0, Hot Keys List, %keyList%
	altMsgBox( "Hot Keys List", keyList )
    keyList=
}


resetLaunched()
{
    global launchType
    global launchTypeModifier
    global launchWin
	global launchWinID
	
	launchType := ""
	launchTypeModifier := ""
	launchWin := ""
	launchWinID := 0
}


resetLaunchMap()
{
    global launchMap
    global launchCounter
	
    launchMap := {}
    launchCounter = 1
}


clearClipBoard()
{
    clipboard =
}


reset()
{
    clearClipBoard()
    resetLaunched()
	resetLaunchMap()
}


reloadAndReset()
{
	Reload
	createLog()
}


debugState()
{
	global Logging
	global SelectedBrowser
	global launchType
	global launchTypeModifier
	global launchWin
	global launchWinID
	
	debugText := 			"Logging = " Logging "`n"
	debugText := debugText  "SelectedBrowser = " SelectedBrowser "`n"
	debugText := debugText  "launchType = " launchType "`n"
	debugText := debugText  "launchTypeModifier = " launchTypeModifier "`n"
	debugText := debugText  "launchWin = " launchWin "`n"
	debugText := debugText  "launchWinID = " launchWinID "`n"
	
	MsgBox %debugText%
}


getClipBoard( useCurrent = false )
{
    clipBoardStr = %clipboard%
    
    if ( ! useCurrent or clipBoardStr == "" )
    {
        ; blockOnClipboardChange = 1
        clipboard =
        SendInput ^c
        ClipWait, 1 ; 0.5 seconds.
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


windowIDExists( winID )
{
	if ( ! winID )
	{
		return false
	}
	
	; SetTitleMatchMode, 3
	; SetTitleMatchMode, Slow
	; Sleep 200
	; Doesn't work. Always returns id even when window is closed.
	; The window disappears but there is a delay until the window id is cleared.
	; Now using WinWaitClose.
	checkExistWinID := WinExist( ahk_id %winID% )
	; This seems to work, but there is a delay after closing the window before the count drops to 0.
	WinGet winCount, Count, ahk_id %winID%
	checkActiveWinID := WinActive( ahk_id %winID% )
	
	winExists := ( winCount || checkExistWinID || checkActiveWinID )

	log( "windowIDExists() + " winID ", " winCount ", " checkExistWinID ", " checkActiveWinID " -> " winExists )

	return winExists
}


closeBrowserWindow()
{
    SendInput ^w
}


;; Paste plain clipboard text.
paste()
{
    tempClipboard = %clipboard%
    clipboard = %tempClipboard% 
    SendInput ^v
}


isLaunched()
{
    global launchWinID
    
	; AutoHotKeys is such a pile of *#£$e that adding in this line makes this function work!
	; The call to WinExist appears to make the subsequent calls to detect the window id work.
	logActiveWindowID( "isLaunched()" )
	launched := windowIDExists( launchWinID )
	checkActiveWindow()
	
	log( "isLaunched() + " launchWinID " -> " launched )

    return launched
}


isWindowFullScreen( winTitleOrID = "" )
{
    ; Checks if the specified or current window is full screen.
    ; Code from NiftyWindows source (with only slight modification).

    ; Use WinExist of another means to get the Unique ID (HWND) of the desired window.

    ; if ( ! winTitleOrID )
	; {
    ;     return false
	; }

    WinGet, winMinMax, MinMax, %winTitleOrID%
    WinGetPos, winX, winY, winW, winH, %winTitleOrID%
	
	isFullScreen := false

    if ( winMinMax == 0 && winX == 0 && winY == 0 && winW == A_ScreenWidth && winH == A_ScreenHeight )
    {
        WinGetClass, winClass, %winTitleOrID%
        WinGet, winProcessName, ProcessName, %winTitleOrID%
        SplitPath, winProcessName, , , winProcessExt

        if ( winClass != "Progman" && winProcessExt != "scr" )
        {
            ; Program is full-screen.
            isFullScreen := true
        }
    }
	
	log( "isWindowFullScreen( " winTitleOrID " ) -> " isFullScreen )
	
	return isFullScreen
}


isWindowMaximised()
{
    WinGet, state, MinMax
    
    isMaximised := ( state == 1 )
    
    return isMaximised
}


; -1 - Don't care, eg. toggle whatever.
; 0 - Must be maximised, ie. because we want to un-maximise the window.
; 1 - Must be non-maximised.
checkFullScreen( fullScreen )
{
    if ( -1 == fullScreen )
    {
        return true
    }
	
	isFullScreen := isWindowFullScreen()
	fullScreenMatch := ( ( 0 == fullScreen ) == isFullScreen )
	
	log( "checkFullScreen( " fullScreen " ) -> " fullScreenMatch )

	return fullScreenMatch
}


;; Store the launched window details.
storeLaunched( type, modifier = "" )
{    
    global launchType
    global launchTypeModifier
    global launchWin
	global launchWinID
    
    launchType := type
    launchTypeModifier := modifier
	
	Loop, 8
	{
		launchWinID := WinExist( "A" )
		
		if ( launchWinID )
		{
			WinGetActiveTitle, launchWin
			; WinGetTitle realTitle, ahk_id %launchWinID%
			; log( "storeLaunched(), id title " realTitle )
			break
		}
		
		log( "storeLaunched( " type ", " modifier " ), unable to get window id" )
	}
	
	log( "storeLaunched( " type ", " modifier " ) -> " launchWin ", " launchWinID )
}


windowOrLaunchedWindowID( winTitle = "" )
{	
    if ( winTitle )
    {
		winID := WinExist( %winTitle% )
    }
	else
	{
        global launchWinID
    
        winID := launchWinID
	}
	
   	log( "windowOrLaunchedWindowID( " winTitle " ) -> " winID )
 
    return winID
}


checkWindowClosed( winTitle = "" )
{
    winID := windowOrLaunchedWindowID( winTitle )
    
    ; Assume true if no title.
    winClosed := true

    if ( winID )
    {
		winClosed := ! windowIDExists( launchWinID )
    }
	
	log( "checkWindowClosed( " winTitle " ) + " winID " -> " winClosed )

    return winClosed
}


checkActiveWindow( launched = true )
{
    if ( ! launched )
    {
        return true
    }
    
    global launchWinID
    
	checkActiveWinID := WinActive( ahk_id %launchWinID% )
	winIsActive := ( 0 != checkActiveWinID )

    if ( ! winIsActive )
    {
		global Debug
		
		if ( Debug )
		{
			SoundBeep
			; MsgBox %launchWin%
		}
    }
	
 	log( "checkActiveWindow( " launched " ) + " launchWinID ", " checkActiveWinID " -> " winIsActive )
   
    return winIsActive
}


checkSwitchToWindow( winTitle = "" )
{
	global Debug
	
	winID := windowOrLaunchedWindowID( winTitle )
    
    if ( ! winID )
    {
		log( "checkSwitchToWindow( " winTitle " ), no window to switch" )
		
		if ( Debug )
		{
			SoundBeep
		}

        return false
    }
    
    WinActivate ahk_id %winID%
    WinWait ahk_id %winID%,,2
    
	winIsActive := ( 0 != WinActive( ahk_id %winID% ) )
    
    if ( ! winIsActive )
    {
		if ( Debug )
		{
			SoundBeep
		}
    }
	
 	log( "checkSwitchToWindow( " winTitle " ) + " winID " -> " winIsActive )

    return winIsActive
}


waitForCloseWindow( winTitle = "" )
{
    winID := windowOrLaunchedWindowID( winTitle )
    
    if ( ! winID )
    {		
        return false
    }

	WinWaitClose, ahk_id %winID%,, 8
}


checkActiveWindowOrSwitchToLaunched( launched = true )
{
    winOk := false
    
    if ( checkActiveWindow( launched ) || checkSwitchToWindow() )
    {
        winOk := true
    }
	
   	log( "checkActiveWindowOrSwitchToLaunched( " launched " ) -> " winOk )
  
    return winOk
}


getWindowCentre()
{
	global Debug
    global launchWin
    global launchWinID
	
	if ( ! launchWinID )
	{
		log( "getWindowCentre(), missing launchWinID" )
	}
    
	Loop, 8
	{
		WinGetPos x, y, width, height, ahk_id %launchWinID%
		
		if ( width )
		{
			break
		}
		
		log( "getWindowCentre() + " launchWinID ", unable to get window position details" )
		
		Sleep 200
		WinActivate ahk_id %launchWinID%
	}

    cx := x + ( width // 2 )
    cy := y + ( height // 2 )
	
	log( "getWindowCentre() + " launchWinID " + x=" x ", y=" y ", w=" width ", h=" height ", sw=" A_ScreenWidth ", sh=" A_ScreenHeight " -> cx=" cx ", cy=" cy )

	windowCentre := { x : cx, y : cy }
	
	return windowCentre
}


middleClick( position, numClicks = 1, delay = 0 )
{	
    CoordMode, Mouse, Screen
	MouseMove, position.x, position.y
	Click, middle, position.x, position.y
	
	log( "middleClick( " position.x ", " position.y " )" )
	
	numClicks := numClicks - 1
	
	Loop, %numClicks%
	{
		Sleep %delay%
		Click, middle, position.x, position.y
		
		log( "middleClick( " position.x ", " position.y " )" )
	}
}


rightClick( position, numClicks = 1, delay = 0 )
{	
    CoordMode, Mouse, Screen
	MouseMove, position.x, position.y
	Click, right, position.x, position.y
	
	log( "rightClick( " position.x ", " position.y " )" )
	
	numClicks := numClicks - 1
	
	Loop, %numClicks%
	{
		Sleep %delay%
		Click, right, position.x, position.y
		
		log( "rightClick( " position.x ", " position.y " )" )
	}
}


;; Swap projected application to PC screen.
endLaunched()
{
	logActiveWindowID( "endLaunched()" )

    if ( checkSwitchToWindow() )
    {
		global launchType
		global launchTypeModifier
		
		log( "endLaunched() + " launchType " + " launchTypeModifier ", switched to window, ending..." )
		
        if ( launchType == "YouTube" )
        {
            pauseOrPlayYouTubeOrVideoLAN()
            ; toggleMuteYouTube()
			; Move off projection screen first before toggling full screen and closing window.
            winPrevious()
			toggleFullScreenYouTube( launchTypeModifier, true, 0 )
            ; Sleep 400
            closeBrowserWindow()
        }
        else if ( launchType == "Video" )
        {
            quitVideo( launchTypeModifier )
        }
		
		waitForCloseWindow()
    }
	
	logActiveWindowID( "endLaunched()" )
       
    if ( checkWindowClosed() )
    {
		log( "endLaunched(), window closed" )
		
		if ( Debug )
		{
			SoundBeep
			SoundBeep
		}
		
		resetLaunched()
    }
}


winNext( launched = true )
{
    if ( checkActiveWindowOrSwitchToLaunched( launched ) )
    {
		log( "winNext( " launched " ), send right" )
        SendInput +#{Right}
    }
}


winPrevious( launched = true )
{
    if ( checkActiveWindowOrSwitchToLaunched( launched ) )
    {
		log( "winPrevious( " launched " ), send left" )
        SendInput +#{Left}
    }
}


runWithSelectedBrowser( url )
{
	global SelectedBrowser
	
	if ( "IE" == SelectedBrowser )
	{
		Run "C:\Program Files\Internet Explorer\iexplore.exe" %url%
	}
	else if ( "Edge" == SelectedBrowser )
	{
		Run microsoft-edge:%url%
	}
	else if ( "Firefox" == SelectedBrowser )
	{
		Run "C:\Program Files (x86)\Mozilla Firefox\firefox.exe" %url%
	}
	else if ( "Opera" == SelectedBrowser )
	{
		Run "C:\Program Files (x86)\Opera\launcher.exe" %url%
	}
	else
	{
		Run %url%
	}
}


activateSelectedBrowser()
{
	global SelectedBrowser
	
	activated := false
	activeWinID := 0
	
	if ( "IE" == SelectedBrowser )
	{
		WinActivate ahk_class IEFrame
		WinWaitActive ahk_class IEFrame,,1
		WinExist( ahk_class IEFrame )
		activeWinID := WinActive( ahk_class IEFrame )
	}
	else if ( "Edge" == SelectedBrowser )
	{
		WinActivate ahk_class ApplicationFrameWindow
		WinWaitActive ahk_class ApplicationFrameWindow,,1
		WinExist( ahk_class ApplicationFrameWindow )
		activeWinID := WinActive( ahk_class ApplicationFrameWindow )
	}
	else if ( "Firefox" == SelectedBrowser )
	{
		WinActivate ahk_class MozillaWindowClass
		WinWaitActive ahk_class MozillaWindowClass,,1
		WinExist( ahk_class MozillaWindowClass )
		activeWinID := WinActive( ahk_class MozillaWindowClass )
	}
	else if ( "Opera" == SelectedBrowser )
	{
		WinActivate ahk_class Chrome_WidgetWin_1
		WinWaitActive ahk_class Chrome_WidgetWin_1,,1
		WinExist( ahk_class Chrome_WidgetWin_1 )
		activeWinID := WinActive( ahk_class Chrome_WidgetWin_1 )
	}
	
	if ( activeWinID )
	{
		WinGetTitle windowTitle, ahk_id %activeWinID%
		log( "activateSelectedBrowser(), active window " activeWinID ", " windowTitle )
		WinShow, ahk_id %activeWinID%
	}
	
	activated := ( 0 != activeWinID )
	
	log( "activateSelectedBrowser() + " SelectedBrowser ", " activeWinID " -> " activated )
	
	return activated
}


exitOpera()
{
	SendInput ^+x
}


closeSelectedBrowser()
{
	global Debug
	global SelectedBrowser
	
	log( "closeSelectedBrowser() + " SelectedBrowser )
	
	activated := activateSelectedBrowser()

	if ( "Opera" == SelectedBrowser )
	{		
		if ( activated )
		{
			exitOpera()
		}
	}
	
	if ( activated )
	{
		closeBrowserWindow()
	}
	else
	{
		log( "closeSelectedBrowser() + " SelectedBrowser ", not closed" )
		
		if ( Debug )
		{
			SoundBeep
		}
	}
}


; Doesn't work.
focusInternetExplorer()
{
    global launchWin
    
    ControlFocus ; , "Internet Explorer_Server1", %launchWin%
    ; Control, Enable,, "Internet Explorer_Server1", %launchWin%
    ControlGetFocus, focusControl
    
    MsgBox %focusControl%
}


runWithAvailableVideoPlayer( videoFile )
{
	videoLANx86 = "C:\Program Files (x86)\VideoLAN\VLC\vlc.exe"
 	videoLANx64 = "C:\Program Files\VideoLAN\VLC\vlc.exe"
   
    ; MsgBox, %videoFile%
	if ( FileExist( videoLANx64 ) )
	{
		Run %videoLANx64% --started-from-file "%videoFile%"
		WinWait VLC media player,,4
	}
	else if ( FileExist( videoLANx86 ) )
	{
		Run %videoLANx86% --started-from-file "%videoFile%"
		WinWait VLC media player,,4
	}
	else
	{
		Run "%videoFile%"
		; Assuming Windows Media Player.
		WinWait ahk_class WMP Skin Host,,4
		toggleFullScreenWindowsMediaPlayer()
	}
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

; YouTube controls:
;
; Spacebar or [k]: Play / Pause
; Arrow Left: Jump back 5 seconds in the current video
; Arrow Right: Jump ahead 5 seconds in the current video
; Arrow Up: Volume up
; Arrow Down: Volume Down
; [f]: Toggle full-screen display
; [j]: Jump back 10 seconds in the current video
; [l]: Jump ahead 10 seconds in the current video
; [m]: Mute or unmute the video
; [0-9]: Jump to a point in the video. 0 jumps to the beginning of the video, 1 jumps to the point 10% into the video, 2 jumps to the point 20% into the video, and so forth.


getBrowserFocus()
{
    ; Click needs coordinates (mouse move).
	windowCentre := getWindowCentre()
	; Getting the focus in the browser YouTube player is tricky. Right click a few times and ESC.
    middleClick( windowCentre, 4, 800 )
	SendInput {Esc}
}


pauseOrPlayYouTubeOrVideoLAN()
{
    SendInput {Space}
}


toggleMuteYouTube()
{
    SendInput m
}


slowDownYouTube()
{
    SendInput +<
}


speedupYouTube()
{
    SendInput +>
}


quitVideo( modifier )
{
    if ( modifier == "VideoLAN" )
    {
        quitVideoLAN()
    }
}


quitVideoLAN()
{
    SendInput ^q
}


; Full screen normal URL.
toggleFullScreenNormalYouTube()
{
    SendInput f
}


; Full screen embed URL.
toggleFullScreenEmbedYouTube()
{
    SendInput {F11}
}


; Full screen embed URL.
toggleFullScreenWindowsMediaPlayer()
{
    SendInput {F11}
}


; Full screen embed URL.
toggleFullScreenYouTube( embed = true, launched = true, fullScreen = -1 )
{
    if ( checkActiveWindowOrSwitchToLaunched( launched ) && checkFullScreen( fullScreen ) )
    {
		log( "toggleFullScreenYouTube( " embed ", " launched ", " fullScreen " )" )
		
        if ( embed || embed == "Embed" )
        {
            toggleFullScreenEmbedYouTube()
        }
        else
        {
            toggleFullScreenNormalYouTube()
        }
    }
}


composeYouTubeURL( youTubeURLOrId, autoPlay = false, embed = true )
{
    global NormalYouTubeURL
    global NormalYouTubeURLSize
    global EmbedYouTubeURL
    global EmbedYouTubeURLAutoPlay
    global EmbedYouTubeURLNoAutoPlay
    global EmbedYouTubeURLSize
    global YouTubeIdSize
    
    if ( youTubeURLOrId == "" )
    {
        return ""
    }
    
    youTubeIdPos := InStr( youTubeURLOrId, EmbedYouTubeURL )
    
    if ( 0 != youTubeIdPos )
    {
        youTubeIdPos := youTubeIdPos + EmbedYouTubeURLSize
    }
    else
    {
        youTubeIdPos := InStr( youTubeURLOrId, NormalYouTubeURL )
        
        if ( 0 != youTubeIdPos )
        {
            youTubeIdPos := youTubeIdPos + NormalYouTubeURLSize
        }
        else
        {
            youTubeIdPos := 1
        }
    }
    
    youTubeId := SubStr( youTubeURLOrId, youTubeIdPos, YouTubeIdSize )
    
    ; MsgBox %youTubeIdPos% %YouTubeIdSize% %youTubeId%
    
    if ( embed )
    {
        youTubeURL := EmbedYouTubeURL . youTubeId
    }
    else
    {
        youTubeURL := NormalYouTubeURL . youTubeId
    }
    
    ; Do the opposite of autoplay because we must click to gain focus, which either plays or pauses.
	; No just do two clicks in the player to focus+play/pause and re-pause/play.
    if ( autoPlay )
    {
        youTubeURL := youTubeURL . EmbedYouTubeURLAutoPlay
    }
    else
    {
        youTubeURL := youTubeURL . EmbedYouTubeURLNoAutoPlay
    }
    
    ; MsgBox %youTubeURL%
    
    return youTubeURL
}
 

;; Launch YouTube clip full screen on projected displays.
launchYouTube( youTubeURLOrId = "", autoPlay = false, embed = true, winTitle = "" )
{
    if ( isLaunched() )
    {
		global Debug
		
		log( "launchYouTube(), already launched" )
		
		if ( Debug )
		{
			SoundBeep
		}

        return false
    }
   
    if ( youTubeURLOrId == "" )
    {
        youTubeURLOrId := getClipBoard()
    
        if ( youTubeURLOrId == "" )
        {
            return false
        }
    }
   
    youTubeURL := composeYouTubeURL( youTubeURLOrId, autoPlay, embed )
 	
	log( "launchYouTube( " youTubeURLOrId ", " autoPlay ", " embed ", " winTitle " ) + " youTubeURL ", launching" )
    
    ; MsgBox %youTubeURL%

    runWithSelectedBrowser( youTubeURL )
    ; activateSelectedBrowser()
    
    if ( winTitle == "" )
    {
        WinWait, YouTube,,4
    }
    else
    {
        WinWait, %winTitle%,,4
    }
    
	; A delay is required otherwise the activate/store doesn't work and the store and project don't work.
    Sleep 1800
    
    ; activateSelectedBrowser()    
    storeLaunched( "YouTube", embed )
    ; focusInternetExplorer() ; Doesn't work.
    getBrowserFocus()
    
    return true
}


;; Launch YouTube clip full screen on projected displays.
projectYouTube( youTubeURLOrId = "", autoPlay = false, embed = true, winTitle = ""  )
{
    if ( launchYouTube( youTubeURLOrId, autoPlay, embed, winTitle ) )
    {
		; Must move to projection screen before toggling full screen, otherwise it gets the wrong size.
        winNext()
        toggleFullScreenYouTube( embed, true, 1 )
    }
}


;; Launch active window YouTube clip full screen on projected displays.
projectActiveWindowYouTube()
{
    ; Full screen, pause, send to other display.
    SendInput f
    SendInput {Space}
    SendInput +#{Right}
}


getHoveredYouTubeURL()
{
	;SetKeyDelay, 400
    SendInput {Click right}
	Sleep 200
	SendInput a
	Sleep 200
	SendInput {Enter}
  	;SetKeyDelay, -1
  
    youTubeURL := getClipBoard()
    ; MsgBox %youTubeURL%
    
    return youTubeURL
}


getBrowserStatusBar()
{
    StatusBarGetText, youTubeURL
    MsgBox %youTubeURL%
    
    return youTubeURL
}

;; Launch youtube clip hovered over.
projectHoveredYouTube()
{
    youTubeURL := getHoveredYouTubeURL()
    projectYouTube( youTubeURL )
}


;; Launch YouTube clip full screen on projected displays.
launchVideo( videoFile = "", autoPlay = false )
{
    if ( isLaunched() )
    {
		global Debug
		
		log( "launchVideo(), already launched" )
	
		if ( Debug )
		{
			SoundBeep
		}
		
        return false
    }
    
    if ( videoFile == "" )
    {
        ; This also gets selected file.
        videoFile := getClipBoard()
    }
    
    if ( videoFile == "" )
    {
        return false
    }
    
	runWithAvailableVideoPlayer( videoFile )
	storeLaunched( "Video", "VideoLAN" )

    if ( ! autoPlay )
    {
        pauseOrPlayYouTubeOrVideoLAN()
    }
	
	return true
}


;; Launch YouTube clip full screen on projected displays.
projectVideo( videoFile = "", autoPlay = false )
{
    launchVideo( videoFile, autoPlay )
    SendInput +#{Right}
}


;; Store a context value when a key is pressed.
storeLaunchCommand( key )
{
    global launchMap
    
    ; This also gets selected file.
    launchCommand := getClipBoard()
    
    if ( launchCommand == "" and WinActive( "YouTube" ) )
    {
        launchCommand := getHoveredYouTubeURL()
        ; launchCommand := getBrowserStatusBar()
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
        projectYouTube( launchCommand, true )
    }
    else
    {
        projectVideo( launchCommand, true )
    }
}


showStoredLaunchCommands()
{
    global launchMap
    keyList := ""
    
    ; altMsgBox( "Entries", "Number of entries: " launchMap.Count() )
    
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
; #<key>         - WindowsKey+<key>
; ^<key>         - Ctrl+<key>
; +<key>         - Shift+<key>
; !<key>         - Alt+<key>
; <key>&<key>     - Combine 2 keys into a custom key.

;; Open Windows hot key help page.
#h::Run "https://support.microsoft.com/en-gb/help/12445/windows-keyboard-shortcuts"

;; Reload the AutoHotKey script.
#r::reloadAndReset()

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
; Win-q has is caught by some other application.
!q::endLaunched()

;; Close selected browser.
^!q::closeSelectedBrowser()

;; Open YouTube search.
#y::projectYouTube( "", true ) ; Autoplay.

;; Project current YouTube clip at full screen.
#p::projectActiveWindowYouTube()

;; Project hovered over YouTube clip at full screen.
; Does work for some but not others.
^p::projectHoveredYouTube()

;; Show selected video file full screen on the projected display.
#v::projectVideo( "", true ) ; Autoplay.

;; Show stored launch commands.
!#v::showStoredLaunchCommands()


; These can store selected video file, YouTube URL on the clipboard or hovered over YouTube page link.

;; Store launch command 1 for later launch.
^+1::storeLaunchCommand( "p1" )

;; Store launch command 2 for later launch.
^+2::storeLaunchCommand( "p2" )

;; Store launch command 3 for later launch.
^+3::storeLaunchCommand( "p3" )

;; Store launch command 4 for later launch.
^+4::storeLaunchCommand( "p4" )

;; Store launch command 5 for later launch.
^+5::storeLaunchCommand( "p5" )

;; Store launch command 6 for later launch.
^+6::storeLaunchCommand( "p6" )

;; Store launch command 7 for later launch.
^+7::storeLaunchCommand( "p7" )

;; Store launch command 8 for later launch.
^+8::storeLaunchCommand( "p8" )


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


; Setup quick display of videos, YouTube clips etc. here, using hard coded hot keys or hot strings.


; Examples.

;; Show example YouTube video full screen on the projected display (autoplay).
^#v::projectYouTube( "LF3Zr3D2UmA", true ) ; We Want To See Jesus Lifted High

;; Show example YouTube video full screen on the projected display (paused).
; Type yt1 anywhere to launch this, but choose the string carefully!
:*:yt1::
projectYouTube( "H7NhaVE0MAw", false ) ; HillSong.
return

;; Show example YouTube video full screen on the projected display (autoplay).
:*:yt2::
projectYouTube( "LqBpifDpNKc", true ) ; Oh Praise the Name (Anastasis).
return

;; Show example video file full screen on the projected display (autoplay).
:*:vd1::
projectVideo( "C:\Users\sounddesk\Documents\AutoHotKeys\TestData\P1100046.MOV", true )
return

;; Hot keys end.

; Put other hidden hot keys here?

;; Debug running state.
^!d::debugState()

;; Call test function.
#t::
test( "Z:\Sunday Services\C Anderson.MOV" )
return

;; Test string to say "Hello!".
::hlo::
MsgBox, Hello!
return


;; Show video file full screen on the projected display.
; ::v1::
; launchVideo( "Z:\Sunday Services\C Anderson.MOV" )
; return
; 
; ::v2::
; projectVideo()
; return

; Invoke stored launch command 1.
; Doesn't work.
; ^{Numpad1}::launchStoredCommand( "p1" )

; ;; Make current window fill half of the screen to the left.
; Alt & Left::    Win__HalfLeft()
; ;; Make current window fill half of the screen to the right.
; Alt & Right::  Win__HalfRight()

;; Paste plain clipboard text.
; #v::paste()
