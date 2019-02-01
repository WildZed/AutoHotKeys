;; To allow re-run without dialog box.
#SingleInstance force

DetectHiddenWindows, on
SetTitleMatchMode, 2

#Include utils.ahk
; #Include %A_ScriptDir%

; lastCopyTime = 0
; lastClipboard = ""
blockOnClipboardChange = 0

WindowsPath := "C:\Windows"
LogFile := "C:\tmp\shortcutkeys.log"
Logging := false
Debug := false
SelectedBrowser := "Edge"

; lastCopyTime = 0
; lastClipboard = ""
blockOnClipboardChange = 0

NormalYouTubeURL := "https://www.youtube.com/watch?v="
NormalYouTubeURLSize := StrLen( NormalYouTubeURL )
EmbedYouTubeURL := "https://www.youtube.com/embed/"
EmbedYouTubeURLSize := StrLen( EmbedYouTubeURL )
EmbedYouTubeURLAutoPlay := "?autoplay=1"
EmbedYouTubeURLNoAutoPlay := "?autoplay=0"
EmbedYouTubePlaysInline := "&playsinline=1" ; Doesn't work.
YouTubeIdSize := 11




editFile( file )
{
    Run, notepad++.exe %A_ScriptName%
}


windowSpy( useExe = false )
{
    RegRead ahkInstallDir, HKEY_LOCAL_MACHINE, SOFTWARE\AutoHotkey, InstallDir
	
	if ( useExe )
	{
		Run %ahkInstallDir%\AU3_Spy.exe
		WinWait Active Window Info,,3
	}
	else
	{
		Run %ahkInstallDir%\WindowSpy.ahk
		WinWait Window Spy,,3
	}

    if ( not ErrorLevel )
	{
		; Move the window to the side a little for convenience.
        WinMove A,, A_ScreenWidth-400, 200
	}
}


ahkHelp()
{
    if ( WinExist( "AutoHotkey Help" ) )
	{
        WinActivate
	}
    else
    {    
        RegRead ahkInstallDir, HKEY_LOCAL_MACHINE, SOFTWARE\AutoHotkey, InstallDir
        Run %ahkInstallDir%\AutoHotKey.chm
    }
}


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


clearClipBoard()
{
    clipboard :=
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


Point( cx, cy )
{
	return { x : cx, y : cy }
}


Rectangle( cll, cur )
{
	return { ll : cll, ur : cur }
}


Area( cwidth, cheight )
{
	return { width : cwidth, height : cheight }
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


raiseWindow( name )
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
	monitor := getWindowMonitor( winTitleOrID )
	monitorArea := getMonitorArea( monitor )

    if ( winMinMax == 0 && winX == 0 && winY == 0 && winW == monitorArea.width && winH == monitorArea.height )
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
	
	log( "isWindowFullScreen( " winTitleOrID " ) + " monitorArea.width ", " monitorArea.height " -> " isFullScreen )
	
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


; Get the index of the monitor containing the specified x and y co-ordinates. 
getMonitorAt( pos, default = 1 ) 
{ 
    SysGet, numMonitors, MonitorCount
	
	monitor := default
	
    ; Iterate through all monitors. 
    Loop, %numMonitors% 
    {
		; Check if the window is on this monitor. 
        SysGet, monitor, Monitor, %A_Index%
		
        if ( pos.x >= monitorLeft && pos.x <= monitorRight && pos.y >= monitorTop && pos.y <= monitorBottom )
		{
            monitor = A_Index 
		}
    } 

    return monitor 
}


getWindowMonitor( winID )
{
	windowCentre := getWindowCentre( winID )
	monitor := getMonitorAt( windowCentre )
	
	return monitor
}


getMonitorRectangle( monitor )
{
	SysGet, monitor, Monitor, monitor
	
	ll := Point( monitorLeft, monitorBottom )
	ur = Point( monitorRight, monitorTop )
	
	return Rectangle( ll, ur )
}


getMonitorArea( monitor )
{	
	SysGet, monitor, Monitor, monitor
	
	width := monitorRight - monitorLeft
	height = monitorBottom - monitorTop
	
	return Area( width, height )
}


getWindowCentre( winID )
{	
	if ( ! winID )
	{
		log( "getWindowCentre(), missing window id" )
	}
    
	Loop, 8
	{
		WinGetPos x, y, width, height, ahk_id %winID%
		
		if ( width )
		{
			break
		}
		
		log( "getWindowCentre() + " winID ", unable to get window position details" )
		
		Sleep 200
		WinActivate ahk_id %winID%
	}

    cx := x + ( width // 2 )
    cy := y + ( height // 2 )
	
	windowArea = getMonitorArea( winID )
	
	log( "getWindowCentre() + " winId " + x=" x ", y=" y ", w=" width ", h=" height ", sw=" windowArea.width ", sh=" windowArea.height " -> cx=" cx ", cy=" cy )

	windowCentre := Point( cx, cy )
	
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


winNext()
{
	log( "winNext( " launched " ), send right" )
	SendInput +#{Right}
}


winPrevious()
{
	log( "winPrevious( " launched " ), send left" )
	SendInput +#{Left}
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


getBrowserFocus( winID )
{
    ; Click needs coordinates (mouse move).
	windowCentre := getWindowCentre( winID )
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
toggleFullScreenYouTube( embed = true, fullScreen = -1 )
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
