#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


; Globals.
SelectedBrowser := "Edge"
NormalYouTubeURL := "https://www.youtube.com/watch?v="
NormalYouTubeURLSize := StrLen( NormalYouTubeURL )
EmbedYouTubeURL := "https://www.youtube.com/embed/"
EmbedYouTubeURLSize := StrLen( EmbedYouTubeURL )
EmbedYouTubeURLAutoPlay := "?autoplay=1"
EmbedYouTubeURLNoAutoPlay := "?autoplay=0"
EmbedYouTubePlaysInline := "&playsinline=1" ; Doesn't work.
YouTubeIdSize := 11




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
		debugBeep()
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


closeBrowserWindow()
{
    SendInput ^w
}


exitOpera()
{
	SendInput ^+x
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
toggleFullScreenYouTube( embed = true, fullScreen = -1 )
{
	log( "toggleFullScreenYouTube( " embed ", " fullScreen " )" )
	
	if ( embed || embed == "Embed" )
	{
		toggleFullScreenEmbedYouTube()
	}
	else
	{
		toggleFullScreenNormalYouTube()
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


getBrowserFocus( windowID, tries = 4, delay = 800 )
{
    log( "getBrowserFocus( " windowID ", " tries ", " delay " )" )
    
    ; Click needs coordinates (mouse move).
	windowCentre := getWindowIDCentre( windowID )
    
	; Getting the focus in the browser YouTube player is tricky. Right click a few times and ESC.
    if ( windowCentre )
    {
        middleClick( windowCentre, tries, delay )
    }
}


pauseOrPlayYouTubeOrVideoLAN()
{
    log( "pauseOrPlayYouTubeOrVideoLAN()" )
    
    SendInput {Space}
    ; Requires a sleep otherwise the input misses the window if the window is switched afterwards.
    ; You'd think the event order would be preserved!
    Sleep 200
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

