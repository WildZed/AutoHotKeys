#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


; Globals.
EdgeBrowser := { name : "Edge", exe : "", class : "ApplicationFrameWindow" }
IEBrowser := { name : "IE", exe : "iexplore.exe", class : "IEFrame" }
FirefoxBrowser := { name : "Firefox", exe : "firefox.exe", class : "MozillaWindowClass" }
OperaBrowser := { name : "Opera", exe : "opera.exe", class : "Chrome_WidgetWin_1" }
SelectedBrowser := EdgeBrowser
; SelectedBrowser := IEBrowser
NormalYouTubeURL := "https://www.youtube.com/watch?v="
EmbedYouTubeURL := "https://www.youtube.com/embed/"
YouTubeData := { normalURL : NormalYouTubeURL, normalURLSize : StrLen( NormalYouTubeURL ), embedURL : EmbedYouTubeURL, embedURLSize : StrLen( EmbedYouTubeURL ), embedURLAutoPlay : "?autoplay=1", embedURLNoAutoPlay : "?autoplay=0", youTubeIDSize : 11 }
; EmbedYouTubePlaysInline := "&playsinline=1" ; Doesn't work.




composeYouTubeURL( youTubeURLOrId, autoPlay = false, embed = true )
{
    global YouTubeData

    if ( youTubeURLOrId == "" )
    {
        return ""
    }

    youTubeIdPos := InStr( youTubeURLOrId, YouTubeData.embedURL )

    if ( 0 != youTubeIdPos )
    {
        youTubeIdPos := youTubeIdPos + YouTubeData.embedURLSize
    }
    else
    {
        youTubeIdPos := InStr( youTubeURLOrId, YouTubeData.normalURL )

        if ( 0 != youTubeIdPos )
        {
            youTubeIdPos := youTubeIdPos + YouTubeData.normalURLSize
        }
        else
        {
            youTubeIdPos := 1
        }
    }

    youTubeId := SubStr( youTubeURLOrId, youTubeIdPos, YouTubeData.youTubeIDSize )

    ; MsgBox %youTubeIdPos% %YouTubeIdSize% %youTubeId%

    if ( embed )
    {
        youTubeURL := YouTubeData.embedURL . youTubeId
    }
    else
    {
        youTubeURL := YouTubeData.normalURL . youTubeId
    }

    ; Do the opposite of autoplay because we must click to gain focus, which either plays or pauses.
    ; No just do two clicks in the player to focus+play/pause and re-pause/play.
    if ( autoPlay )
    {
        youTubeURL := youTubeURL . YouTubeData.embedURLAutoPlay
    }
    else
    {
        youTubeURL := youTubeURL . YouTubeData.embedURLNoAutoPlay
    }

    ; MsgBox %youTubeURL%

    return youTubeURL
}


runWithSelectedBrowser( url )
{
    global SelectedBrowser

    if ( "IE" == SelectedBrowser.name )
    {
        Run "C:\Program Files\Internet Explorer\iexplore.exe" %url%
    }
    else if ( "Edge" == SelectedBrowser.name )
    {
        Run microsoft-edge:%url%
    }
    else if ( "Firefox" == SelectedBrowser.name )
    {
        Run "C:\Program Files (x86)\Mozilla Firefox\firefox.exe" %url%
    }
    else if ( "Opera" == SelectedBrowser.name )
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

    if ( "IE" == SelectedBrowser.name )
    {
        WinActivate ahk_class IEFrame
        WinWaitActive ahk_class IEFrame,,1
        WinExist( ahk_class IEFrame )
        activeWinID := WinActive( ahk_class IEFrame )
    }
    else if ( "Edge" == SelectedBrowser.name )
    {
        WinActivate ahk_class ApplicationFrameWindow
        WinWaitActive ahk_class ApplicationFrameWindow,,1
        WinExist( ahk_class ApplicationFrameWindow )
        activeWinID := WinActive( ahk_class ApplicationFrameWindow )
    }
    else if ( "Firefox" == SelectedBrowser.name )
    {
        WinActivate ahk_class MozillaWindowClass
        WinWaitActive ahk_class MozillaWindowClass,,1
        WinExist( ahk_class MozillaWindowClass )
        activeWinID := WinActive( ahk_class MozillaWindowClass )
    }
    else if ( "Opera" == SelectedBrowser.name )
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

    if ( "Opera" == SelectedBrowser.name )
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
    log( "closeBrowserWindow()" )
    SendInput ^w
}


exitOpera()
{
    SendInput ^+x
}


winWaitBrowser( winTitle, timeout = 4 )
{
    global SelectedBrowser

    class := SelectedBrowser.class
    WinWait, %winTitle% ahk_class %class%,,%timeout%
}


winWaitActiveBrowser( winTitle, timeout = 4 )
{
    global SelectedBrowser

    class := SelectedBrowser.class
    WinWaitActive, %winTitle% ahk_class %class%,,%timeout%
}


winWaitYouTube( winTitle = "YouTube", timeout = 4 )
{
    winWaitActiveBrowser( winTitle, timeout )
}


winWaitActiveYouTube( winTitle = "YouTube", timeout = 4 )
{
    winWaitActiveBrowser( winTitle, timeout )
}


checkCloseBrowserWindow( windowID, retries = 0, wait = 2 )
{
    logPush( "checkCloseBrowserWindow( " windowID " )" )

    closeBrowserWindow()
    WinWaitClose, ahk_id %windowID%,, %wait%
    success := checkWindowIDClosed( windowID )

    Loop, %retries%
    {
        if ( success )
        {
            break
        }

        ; For some reason it loses browser focus when toggled or switched to main monitor.
        getBrowserFocus( windowID, 4, 200 )
        closeBrowserWindow()
        WinWaitClose, ahk_id %windowID%,, %wait%
        success := checkWindowIDClosed( windowID )
    }

    logPop( "checkCloseBrowserWindow() -> " success )

    return success
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


; Full screen YouTube URL.
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


checkToggleFullScreenYouTube( embed = true, fullScreen = -1, retries = 0, wait = 200 )
{
    if ( ! checkActiveWindowFullScreen( fullScreen ) )
    {
        log( "toggleFullScreenYouTube( " embed ", " fullScreen " ), no toggle required" )

        return true
    }

    logPush( "toggleFullScreenYouTube( " embed ", " fullScreen " )" )

    toggleFullScreenYouTube( embed, fullScreen )
    Sleep %wait%
    success := ! checkActiveWindowFullScreen( fullScreen )

    Loop, %retries%
    {
        if ( success )
        {
            break
        }

        toggleFullScreenYouTube( embed, fullScreen )
        Sleep %wait%
        success := ! checkActiveWindowFullScreen( fullScreen )
    }

    logPop( "toggleFullScreenYouTube() -> " success )

    return success
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
    Sleep 400
    SendInput a
    Sleep 400
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
    logPush( "getBrowserFocus( " windowID ", " tries ", " delay " )" )

    ; Click needs coordinates (mouse move).
    windowCentre := getWindowIDCentre( windowID )

    ; Getting the focus in the browser YouTube player is tricky. Right click a few times and ESC.
    if ( windowCentre )
    {
        middleClick( windowCentre, tries, delay )
    }

    logPop( "getBrowserFocus(), end" )
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

