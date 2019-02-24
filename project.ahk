#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Remember what was launched so that the correct end sequence can be sent.
; Counter for launch commands.
; Array to store launch commands (positional and sequential).
LaunchData := { type : "", typeModifier : "", windowTitle : "", windowID : 0, dialog : true, maxPositions : 8, counter : 1, map : {} }




resetLaunchData()
{
    resetLaunchWindow()
    resetLaunchMap()
}


resetLaunchWindow()
{
    global LaunchData
    
    LaunchData.type := ""
    LaunchData.typeModifier := ""
    LaunchData.windowTitle := ""
    LaunchData.windowID := 0
}


resetLaunchMap()
{
    global LaunchData
    
    LaunchData.counter := 1
    LaunchData.map := {}
}


getFreePositionalIndex()
{
    global LaunchData
    
    index := 0
    
    Loop, 8
    {
        key := "p" A_Index
        
        if ( ! LaunchData.map.HasKey( key ) )
        {
            index := A_Index
            break
        }
    }

    return index
}


isLaunched( default = false )
{
    global LaunchData
    
    ; AutoHotKeys is such a pile of *#£$e that adding in this line makes this function work!
    ; The call to WinExist appears to make the subsequent calls to detect the window id work.
    ; logActiveWindowID( "isLaunched()" )
    launched := windowIDExists( LaunchData.windowID, default )
    ; checkActiveWindow()
    
    log( "isLaunched() + " LaunchData.windowID " -> " launched )

    return launched
}


checkLaunched( launched = true, default = false )
{
    if ( launched == isLaunched( default ) )
    {
        check := true
    }
    else
    {
        check := false
    }
    
    if ( ! check )
    {
        global Debug
        
        if ( launched )
        {
            log( "checkLaunched(), already launched" )
        }
        else
        {
            log( "checkLaunched(), not yet launched" )
        }
        
        if ( Debug )
        {
            debugBeep()
        }
    }
    
    return check
}


;; Store the launched window details.
storeLaunched( type, modifier = "" )
{    
    global LaunchData
    
    LaunchData.type := type
    LaunchData.typeModifier := modifier
    
    Loop, 8
    {
        LaunchData.windowID := WinExist( "A" )
        
        if ( LaunchData.windowID )
        {
            WinGetActiveTitle, windowTitle
            LaunchData.windowTitle := windowTitle
            ; WinGetTitle realTitle, ahk_id %LaunchData.windowID%
            ; log( "storeLaunched(), id title " realTitle )
            break
        }
        
        log( "storeLaunched( " type ", " modifier " ), unable to get window id" )
    }
    
    log( "storeLaunched( " type ", " modifier " ) -> " LaunchData.windowTitle ", " LaunchData.windowID )
    
    return LaunchData.windowID
}


windowOrLaunchedWindowID( windowID = "" )
{
    origWindowID := windowID
    
    if ( windowID )
    {
        windowID := WinExist( %windowID% )
    }
    else
    {
        global LaunchData
    
        windowID := LaunchData.windowID
    }
    
    log( "windowOrLaunchedWindowID( " origWindowID " ) -> " windowID )
 
    return windowID
}


checkLaunchedWindowIDClosed( windowID = "" )
{
    origWindowID := windowID
    windowID := windowOrLaunchedWindowID( windowID )  
    winClosed := checkWindowIDClosed( windowID )
    
    log( "checkLaunchedWindowIDClosed( " origWindowID " ) + " windowID " -> " winClosed )

    return winClosed
}


checkActiveWindow( launched = true )
{
    if ( ! launched )
    {
        return true
    }
    
    global LaunchData
    
    windowID := LaunchData.windowID
    checkActiveWindowID := WinActive( ahk_id %windowID% )
    winIsActive := ( 0 != checkActiveWindowID )

    if ( ! winIsActive )
    {
        debugBeep()
    }
    
    log( "checkActiveWindow( " launched " ) + " LaunchData.windowID ", " checkActiveWindowID " -> " winIsActive )
   
    return winIsActive
}


checkSwitchToLaunchedWindowID( windowID = "" )
{
    windowID := windowOrLaunchedWindowID( windowID )
    winIsActive := checkSwitchToWindowID( windowID )
    
    return winIsActive
}


waitForCloseWindow( winTitle = "" )
{
    windowID := windowOrLaunchedWindowID( winTitle )
    
    if ( ! windowID )
    {       
        return false
    }

    WinWaitClose, ahk_id %windowID%,, 8
}


checkActiveWindowOrSwitchToLaunched( launched = true )
{
    winOk := false
    
    if ( checkActiveWindow( launched ) || checkSwitchToLaunchedWindowID() )
    {
        winOk := true
    }
    
    log( "checkActiveWindowOrSwitchToLaunched( " launched " ) -> " winOk )
  
    return winOk
}


nextMonitorLaunched( launched = true )
{
    if ( checkActiveWindowOrSwitchToLaunched( launched ) )
    {
        nextMonitor()
    }
}


previousMonitorLaunched( launched = true )
{
    if ( checkActiveWindowOrSwitchToLaunched( launched ) )
    {
        previousMonitor()
    }
}


switchToProjectionMonitorLaunched( launched = true )
{
    if ( checkActiveWindowOrSwitchToLaunched( launched ) )
    {
        switchToProjectionMonitor()
    }
}


switchToMainMonitorLaunched( launched = true )
{
    if ( checkActiveWindowOrSwitchToLaunched( launched ) )
    {
        switchToMainMonitor()
    }
}


toggleProjectionMonitorLaunched( launched = true )
{
    if ( checkActiveWindowOrSwitchToLaunched( launched ) )
    {
        toggleProjectionMonitor()
    }
}


; Full screen embed URL.
toggleFullScreenYouTubeLaunched( embed = true, launched = true, fullScreen = -1 )
{
    if ( checkActiveWindowOrSwitchToLaunched( launched ) && checkActiveWindowFullScreen( fullScreen ) )
    {
        toggleFullScreenYouTube( embed = true, fullScreen = -1 )
    }
}


;; Store a context value when a key is pressed.
storeLaunchCommand( key = "" )
{
    global LaunchData
    
    ; This also gets selected file.
    launchCommand := getClipBoard()
    
    ; MsgBox %launchCommand%
  
    if ( launchCommand == "" and WinActive( "YouTube" ) )
    {
        launchCommand := getHoveredYouTubeURL()
        ; launchCommand := getBrowserStatusBar()
        clearClipBoard()
    }

    if ( launchCommand != "" )
    {
        if ( key == "p" )
        {
            index := getFreePositionalIndex()
            
            if ( index )
            {
                key := key index
            }
            else
            {
                key := ""
            }
        }
        
        if ( ! key )
        {
            key := "s" LaunchData.counter
            LaunchData.counter := LaunchData.counter + 1
        }
        
        LaunchData.map[(key)] := launchCommand
        launchCommand := LaunchData.map[(key)]
        ; MsgBox Stored launch command "%launchCommand%" as "%key%".
        launchButtonDialogRefresh()
    }
    else
    {
        MsgBox "Nothing launchable found in clipboard or near mouse position!"
    }
}


showStoredLaunchCommands()
{
    global LaunchData
    keyList := ""
    
    ; altMsgBox( "Entries", "Number of entries: " LaunchData.map.Count() )
    
    For key, value in LaunchData.map
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


isActiveLaunchedWindow()
{
    global LaunchData
    
    activeWinID := WinActive( "A" )
    
    activeIsLaunched := ( activeWinID == LaunchData.windowID )
    
    log( "isActiveLaunchedWindow() + " activeWinID ", " LaunchData.windowID " -> " activeIsLaunched )
    
    return activeIsLaunched
}


; GUI.

launchButtonDialog()
{
    global LaunchData
	
	log( "launchButtonDialog()" )
   
    LaunchData.dialog := true
    
    title := "Launch Buttons"
    text := Format( "{1:-80}", text )
    keyList := ""
    
    Gui, launchbtnbox:Add, Text, , The currently stored launch commands.
   
    For key, value in LaunchData.map
    {
        Gui, launchbtnbox:Add, Button, glaunchStoreCommandButton Default w28 h28 xm, %key%
        Gui, launchbtnbox:Add, Text, x+m yp+8, %value%
    }
    
    ; Gui, launchbtnbox:Add, Button, glaunchButtonDialogRefresh Default w80 x+-80 y+m, Refresh
    Gui, launchbtnbox:Add, Button, glaunchButtonDialogClose Default w80 xm yp+28, Close
    Gui, launchbtnbox:Add, Button, glaunchButtonDialogClearPositional Default w80 x+m, Clear Positional
    Gui, launchbtnbox:Add, Button, glaunchButtonDialogClearCounter Default w80 x+m, Clear Counter
    Gui, launchbtnbox:Show, x1000 yCenter, %title%
    ; Gui +LastFound
    ; Get window position and dimensions
    WinGetPos, x, y, w, h, A
    ; MsgBox, %w% %A_ScreenWidth%
    xPos := A_ScreenWidth - w
    ; MsgBox, %xPos%
    WinMove A,, %xPos%, %y%
    
    ; Modal dialog. Blocks hot key thread.
    ; WinWaitClose, %title%
    ; Tooltip, Script is still running
    ; Sleep 20000
    ; Tooltip,
}


launchStoreCommandButton()
{
    ; ControlGetText, button, Button, A
    GuiControlGet, button,, %A_GuiControl%
    
    launchStoredCommand( button )
}


launchButtonDialogClearPositional()
{
    global LaunchData
    
    Loop, 8
    {
        key := "p" A_Index
        
        if ( LaunchData.map.HasKey( key ) )
        {
            LaunchData.map.Delete( key )
        }
    }
   
    launchButtonDialogRefresh()
}


launchButtonDialogClearCounter()
{
    global LaunchData
    
    toDelete := {}
    
    For key, value in LaunchData.map
    {
        if ( "s" == SubStr( key, 1, 1 ) )
        {
            toDelete[key] := key
        }
    }
    
    For key in toDelete
    {
        LaunchData.map.Delete( key )
    }
    
    LaunchData.counter := 1
  
    launchButtonDialogRefresh()
}


launchButtonDialogRefresh()
{      
    global LaunchData
    
    if ( ! LaunchData.dialog )
    {
        return
    }
    
    storeActiveWindow()
    Gui, launchbtnbox:Destroy
    launchButtonDialog()
    restoreActiveWindow()
}


launchButtonDialogClose()
{
    global LaunchData
    
    LaunchData.dialog := false
    Gui, launchbtnbox:Destroy
}


launchStoredCommand( key )
{
    global LaunchData
    
    launchCommand := LaunchData.map[(key)]
    
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


; Switch active window (focus) to launched or back to stored window.
toggleFocusLaunchedWindow()
{
    if ( ! checkLaunched( true, true ) )
    {
        return
    }
    
    global LaunchData
    
	if ( isActiveLaunchedWindow() )
	{
		log( "toggleSwitchLaunchedWindow() + " LaunchData.type ", " LaunchData.typeModifier ", switching back to stored window..." )
			
		if ( ! isActiveStoredWindow() )
		{
			restoreActiveWindow()
			; lastActiveWindow()
		}
	}
	else
	{
		log( "toggleSwitchLaunchedWindow() + " LaunchData.type ", " LaunchData.typeModifier ", switching to launched window..." )
	
		storeActiveWindow()
			
		if ( checkSwitchToLaunchedWindowID() )
		{
			log( "toggleSwitchLaunchedWindow(), switched to window." )
		}
	}
}


; Switch active window to launched and pause/play, then switch back.
pausePlayLaunched()
{ 
    if ( ! checkLaunched( true, true ) )
    {
        return
    }
    
    global LaunchData
    
    log( "pausePlayLaunched() + " LaunchData.type ", " LaunchData.typeModifier ", checking for pause/play..." )
    
    if ( LaunchData.type == "YouTube" || LaunchData.type == "Video" )
    {
        storeActiveWindow()
        
        if ( checkSwitchToLaunchedWindowID() )
        {
            log( "pausePlayLaunched(), switched to window, pause/play..." )

            ; WinWait A,, 2
            getBrowserFocus( LaunchData.windowID, 4, 20 )
            pauseOrPlayYouTubeOrVideoLAN()

            ; restoreActiveWindow()
            
            if ( ! isActiveStoredWindow() )
            {
                lastActiveWindow()
            }
        }
    }
}


;; Swap projected application to PC screen.
endLaunched()
{
    logActiveWindowID( "endLaunched()" )

    if ( checkSwitchToLaunchedWindowID() )
    {
        global LaunchData
        
        log( "endLaunched() + " LaunchData.type " + " LaunchData.typeModifier ", switched to window, ending..." )
        
        if ( LaunchData.type == "YouTube" )
        {
            getBrowserFocus( LaunchData.windowID, 4, 20 )
            pauseOrPlayYouTubeOrVideoLAN()
            ; toggleMuteYouTube()
            ; Move off projection screen first before toggling full screen and closing window.
            toggleFullScreenYouTubeLaunched( LaunchData.typeModifier, true, 0 )
            ; Screen swapping doesn't work for full screen, so this needs to happen after toggling full screen.
            switchToMainMonitorLaunched()
            closeBrowserWindow()
        }
        else if ( LaunchData.type == "Video" )
        {
            switchToMainMonitorLaunched()
            quitVideo( LaunchData.typeModifier )
        }
        
        waitForCloseWindow()
    }
    
    logActiveWindowID( "endLaunched()" )
       
    if ( checkLaunchedWindowIDClosed() )
    {
        log( "endLaunched(), window closed" )
        
        if ( Debug )
        {
            debugBeep( 2 )
        }
        
        resetLaunchWindow()
    }
}


;; Launch YouTube clip full screen on projected displays.
launchYouTube( youTubeURLOrId = "", autoPlay = false, embed = true, winTitle = "" )
{
    if ( ! checkLaunched( false, true ) )
    {
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
    
    ; if ( winTitle == "" )
    ; {
    ;     WinWait, YouTube,,4
    ; }
    ; else
    ; {
    ;     WinWait, %winTitle%,,4
    ; }
     
    if ( winTitle == "" )
    {
        WinWaitActive, YouTube,,4
    }
    else
    {
        WinWaitActive, %winTitle%,,4
    }
   
    ; A delay is required otherwise the activate/store doesn't work and the store and project don't work.
    ; Apparently not any more. Oh yes it still needs it sometimes, but trying WinWaitActive first.
    ; Sleep 1800
    ; Sleep 800
    
    ; activateSelectedBrowser()    
    windowID := storeLaunched( "YouTube", embed )
    ; focusInternetExplorer() ; Doesn't work.
    getBrowserFocus( windowID, 4, 100 )
    
    return true
}


;; Launch YouTube clip full screen on projected displays.
launchVideo( videoFile = "", autoPlay = false )
{
    if ( ! checkLaunched( false, true ) )
    {
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
projectYouTube( youTubeURLOrId = "", autoPlay = false, embed = true, winTitle = ""  )
{
    log( "projectYouTube( " youTubeURLOrId ", " autoPlay ", " embed ", " winTitle " ) + " youTubeURL ", launching" )
	
    if ( launchYouTube( youTubeURLOrId, autoPlay, embed, winTitle ) )
    {
        ; Must move to projection screen before toggling full screen, otherwise it gets the wrong size.
        switchToProjectionMonitorLaunched()
        toggleFullScreenYouTubeLaunched( embed, true, 1 )
    }
}


;; Launch youtube clip hovered over.
projectHoveredYouTube()
{
    youTubeURL := getHoveredYouTubeURL()
    projectYouTube( youTubeURL )
}


;; Launch YouTube clip full screen on projected displays.
projectVideo( videoFile = "", autoPlay = false )
{
    if ( launchVideo( videoFile, autoPlay ) )
	{
        ; Must move to projection screen before toggling full screen, otherwise it gets the wrong size.
        switchToProjectionMonitorLaunched()
	}
}
