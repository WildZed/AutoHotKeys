;; To allow re-run without dialog box.
#SingleInstance force

DetectHiddenWindows, on
SetTitleMatchMode, 2

WindowsPath := "C:\Windows"
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


reset()
{
    clearClipBoard()
    resetLaunched()
	resetLaunchMap()
}


clearClipBoard()
{
    clipboard =
}


getClipBoard( useCurrent = false )
{
    clipBoardStr = %clipboard%
    
    if ( ! useCurrent or clipBoardStr == "" )
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


closeBrowserWindow()
{
    Send ^w
}


;; Paste plain clipboard text.
paste()
{
    tempClipboard = %clipboard%
    clipboard = %tempClipboard% 
    Send ^v
}


isLaunched()
{
    global launchWinID
    
    launched := false
    
    if ( launchWinID != 0 )
    {
        launched := ( 0 != WinExist( ahk_id launchWinID ) )
    }
	
	; MsgBox %launched% %launchWin%
		
	; if ( launched )
	; {
	; 	MsgBox %launchWin%
	; }

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
    WinGetActiveTitle, launchWin
	WinGet, launchWinID, ID
	
	if ( launchWin == "" )
	{
		MsgBox "Failed to store launchWin!"
	}
    ; MsgBox Type %launchType% Win %launchWin%
}


windowOrLaunchedWindow( winTitle = "" )
{
    if ( winTitle == "" )
    {
        global launchWinID
    
        winTitle := ahk_id %launchWinID%
    }
    
    return winTitle
}


checkWindowClosed( winTitle = "" )
{
    winTitle := windowOrLaunchedWindow( winTitle )
    
    ; Assume true if no title.
    winClosed := true

    if ( winTitle != "" )
    {
        Sleep 200

        if ( 0 != WinExist( winTitle ) )
        {
            winClosed := false
        }
    }
    
    return winClosed
}


checkActiveWindow( launched = true )
{
    if ( ! launched )
    {
        return true
    }
    
    global launchWinID
    
    winIsActive := ( 0 != WinActive( ahk_id launchWinID ) )

    if ( ! winIsActive )
    {
        SoundBeep
        ; MsgBox %launchWin%
    }
    
    return winIsActive
}


checkSwitchToWindow( winTitle = "" )
{
    winTitle := windowOrLaunchedWindow( winTitle )
    
    if ( winTitle = "" )
    {
        SoundBeep
        return false
    }
    
    WinActivate, %winTitle%
    WinWait %winTitle%,,2
    
    winIsActive := ( 0 != WinActive( winTitle ) )
    
    if ( ! winIsActive )
    {
        SoundBeep
        ; MsgBox %winTitle%
    }

    return winIsActive
}


checkActiveWindowOrSwitchToLaunched( launched = true )
{
    winOk := false
    
    if ( checkActiveWindow( launched ) || checkSwitchToWindow() )
    {
        winOk := true
    }
    
    return winOk
}



clickWinCentre()
{
    global launchWinID
    
    WinGetPos x, y, width, height, ahk_id %launchWinID%

    x := x + ( width / 2 )
    y := y + ( height / 2 )
    
    ; MsgBox, %x%, %y%
    
    Click, %x%, %y%
}


;; Swap projected application to PC screen.
endLaunched()
{
    if ( checkSwitchToWindow() )
    {
		global launchType
		global launchTypeModifier
		
        if ( launchType == "YouTube" )
        {
            pauseOrPlayYouTubeOrVideoLAN()
            ; toggleMuteYouTube()
            winPrevious()
			toggleFullScreenYouTube( launchTypeModifier, true, 0 )
            ; Sleep 400
            closeBrowserWindow()
        }
        else if ( launchType == "Video" )
        {
            quitVideo( launchTypeModifier )
        }
    }
        
    if ( checkWindowClosed() )
    {
        SoundBeep
        SoundBeep
		resetLaunched()
    }
}


winNext( launched = true )
{
    if ( checkActiveWindowOrSwitchToLaunched( launched ) )
    {
        Send +#{Right}
    }
}


winPrevious( launched = true )
{
    if ( checkActiveWindowOrSwitchToLaunched( launched ) )
    {
        Send +#{Left}
    }
}


runWithInternetExplorer( url )
{    
    Run "C:\Program Files\Internet Explorer\iexplore.exe" %url%
}


runWithMSEdge( url )
{
    Run microsoft-edge:%url%
    ; WinActivate ahk_class IEFrame
}


runWithFirefox( url )
{
    Run "C:\Program Files (x86)\Mozilla Firefox\firefox.exe" %url%
}


runWithOpera( url )
{
    Run "C:\Program Files (x86)\Opera\launcher.exe" %url%
}


runWithSelectedBrowser( url )
{
	global SelectedBrowser
	
	if ( "IE" == SelectedBrowser )
	{
		runWithInternetExplorer( url )
	}
	else if ( "Edge" == SelectedBrowser )
	{
		runWithMSEdge( url )
	}
	else if ( "Firefox" == SelectedBrowser )
	{
		runWithFirefox( url )
	}
	else if ( "Opera" == SelectedBrowser )
	{
		runWithOpera( url )
	}
	else
	{
		Run %url%
	}
}


activateInternetExplorer()
{
    WinActivate ahk_class IEFrame
}


activateMSEdge()
{
    WinActivate ahk_class ApplicationFrameWindow
}


activateFirefox()
{
    WinActivate ahk_class MozillaWindowClass
}


activateOpera()
{
    WinActivate ahk_class IEFrame
}


activateSelectedBrowser()
{
	global SelectedBrowser
	
	if ( "IE" == SelectedBrowser )
	{
		activateInternetExplorer()
	}
	else if ( "Edge" == SelectedBrowser )
	{
		activateMSEdge()
	}
	else if ( "Firefox" == SelectedBrowser )
	{
		activateFirefox()
	}
	else if ( "Opera" == SelectedBrowser )
	{
		activateOpera()
	}
	else
	{
		WinActivate
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


playYouTube()
{
    ; Click needs coordinates (mouse move).
    clickWinCentre()
}


pauseOrPlayYouTubeOrVideoLAN()
{
    Send {Space}
}


toggleMuteYouTube()
{
    Send m
}


slowDownYouTube()
{
    Send +<
}


speedupYouTube()
{
    Send +>
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
    Send ^q
}


; Full screen normal URL.
toggleFullScreenNormalYouTube()
{
    Send f
}


; Full screen embed URL.
toggleFullScreenEmbedYouTube()
{
    Send {F11}
}


; Full screen embed URL.
toggleFullScreenYouTube( embed = true, launched = true, fullScreen = -1 )
{
    if ( checkActiveWindowOrSwitchToLaunched( launched ) && checkFullScreen( fullScreen ) )
    {
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
    if ( autoPlay )
    {
        youTubeURL := youTubeURL . EmbedYouTubeURLNoAutoPlay
    }
    else
    {
        youTubeURL := youTubeURL . EmbedYouTubeURLAutoPlay
    }
    
    ; MsgBox %youTubeURL%
    
    return youTubeURL
}
 

;; Launch YouTube clip full screen on projected displays.
launchYouTube( youTubeURLOrId = "", autoPlay = false, embed = true, winTitle = "" )
{
    if ( isLaunched() )
    {
		SoundBeep
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
    
    ; MsgBox %youTubeURL%

    runWithSelectedBrowser( youTubeURL )
    ; activateSelectedBrowser()
    
	; Not sure if this is working, hence the delay.
    if ( winTitle == "" )
    {
        WinWait - YouTube,,8
    }
    else
    {
        WinWait %winTitle%,,8
    }
    
	; A delay is required otherwise the activate doesn't work and the store and project don't work.
    Sleep 1800
    
    activateSelectedBrowser()    
    storeLaunched( "YouTube", embed )
    ; focusInternetExplorer() ; Doesn't work.
    ; Clicks to play or pause.
    playYouTube()
    
    return true
}


;; Launch YouTube clip full screen on projected displays.
projectYouTube( youTubeURLOrId = "", autoPlay = false, embed = true, winTitle = ""  )
{
    if ( launchYouTube( youTubeURLOrId, autoPlay, embed, winTitle ) )
    {
        winNext()
        toggleFullScreenYouTube( embed, true, 1 )
    }
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
launchVideoLAN( videoFile = "", autoPlay = false )
{
    if ( isLaunched() )
    {
		SoundBeep
        return
    }
    
    if ( videoFile == "" )
    {
        ; This also gets selected file.
        videoFile := getClipBoard()
    }
    
    if ( videoFile == "" )
    {
        return
    }
    
    storeLaunched( "Video", "VideoLAN" )
    
    ; MsgBox, %videoFile%
    Run "C:\Program Files (x86)\VideoLAN\VLC\vlc.exe" --started-from-file "%videoFile%"
    ; WinWait ahk_class WMP Skin Host,,8
    ; Send {F11}
    WinWait VLC media player,,8
    
    if ( ! autoPlay )
    {
        pauseOrPlayYouTubeOrVideoLAN()
    }
}


;; Launch YouTube clip full screen on projected displays.
projectVideoLAN( videoFile = "", autoPlay = false )
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
; #<key>         - WindowsKey+<key>
; ^<key>         - Ctrl+<key>
; +<key>         - Shift+<key>
; !<key>         - Alt+<key>
; <key>&<key>     - Combine 2 keys into a custom key.

;; Open Windows hot key help page.
#h::Run "https://support.microsoft.com/en-gb/help/12445/windows-keyboard-shortcuts"

;; Test string to say "Hello!".
::hlo::
MsgBox, Hello!
return

;; Call test function.
#t::
test( "Z:\Sunday Services\C Anderson.MOV" )
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
; Win-q has is caught by some other application.
!q::endLaunched()

;; Open YouTube search.
#y::projectYouTube( "", 1 )

;; Project current YouTube clip at full screen.
#p::projectActiveWindowYouTube()

; Project hovered over YouTube clip at full screen.
; Does work for some but not others.
^p::projectHoveredYouTube()

;; Show selected video file full screen on the projected display.
#v::projectVideoLAN( "", 1 )

;; Show stored launch commands.
!#v::showStoredLaunchCommands()

;; Show example YouTube video full screen on the projected display (autoplay).
^#v::projectYouTube( "LF3Zr3D2UmA", 1 ) ; , "We Want To See Jesus Lifted High" )

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


; Setup quick display of videos, YouTube clips etc. here.

;; Show example YouTube video full screen on the projected display (paused).
:*:yt1::
projectYouTube( "LF3Zr3D2UmA", 0 ) ; , "We Want To See Jesus Lifted High" )
return

;; Show example YouTube video full screen on the projected display (autoplay).
:*:yt2::
projectYouTube( "LF3Zr3D2UmA", 1 ) ; , "We Want To See Jesus Lifted High" )
return

;;


;; Show video file full screen on the projected display.
; ::v1::
; launchVideoLAN( "Z:\Sunday Services\C Anderson.MOV" )
; return
; 
; ::v2::
; projectVideoLAN()
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
