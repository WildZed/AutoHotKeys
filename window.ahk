#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

WindowContext := { storedWindowID : 0, mouse : Point() }




isWindowIDFullScreen( windowID = "" )
{
    ; Checks if the specified or current window is full screen.
    ; Code from NiftyWindows source (with only slight modification).

    ; Use WinExist of another means to get the Unique ID (HWND) of the desired window.

    if ( ! windowID )
	{
        return false
	}

    WinGet, winMinMax, MinMax, ahk_id %windowID%
    WinGetPos, winX, winY, winW, winH, ahk_id %windowID%
	
	isFullScreen := false
	monitor := getWindowIDMonitor( windowID )
	monitorArea := getMonitorArea( monitor )

    if ( winMinMax == 0 && winX == 0 && winY == 0 && winW == monitorArea.width && winH == monitorArea.height )
    {
        WinGetClass, winClass, ahk_id %windowID%
        WinGet, winProcessName, ProcessName, ahk_id %windowID%
        SplitPath, winProcessName, , , winProcessExt

        if ( winClass != "Progman" && winProcessExt != "scr" )
        {
            ; Program is full-screen.
            isFullScreen := true
        }
    }
	
	log( "isWindowIDFullScreen( " windowID " ) + " monitorArea.width ", " monitorArea.height " -> " isFullScreen )
	
	return isFullScreen
}


; -1 - Don't care, eg. toggle whatever.
; 0 - Must be maximised, ie. because we want to un-maximise the window.
; 1 - Must be non-maximised.
checkActiveWindowFullScreen( fullScreen )
{
    if ( -1 == fullScreen )
    {
        return true
    }
	
    windowID := WinExist( "A" )
    
    if ( ! windowID )
    {
        return false
    }
    
	isFullScreen := isWindowIDFullScreen( windowID )
	fullScreenMatch := ( ( 0 == fullScreen ) == isFullScreen )
	
	log( "checkActiveWindowFullScreen( " fullScreen " ) -> " fullScreenMatch )

	return fullScreenMatch
}


isWindowMaximised()
{
    WinGet, state, MinMax
    
    isMaximised := ( state == 1 )
    
    return isMaximised
}


lastActiveWindow()
{
    SendInput !{Tab}
}


isActiveStoredWindow()
{
    global WindowContext
    
    activeWinID := WinActive( "A" )
    
    activeIsStored := ( activeWinID == WindowContext.storedWindowID )
    
    log( "isActiveStoredWindow() + " activeWinID ", " WindowContext.storedWindowID " -> " activeIsStored )
    
    return activeIsStored
}


storeActiveWindow()
{
    global WindowContext
    
  	WindowContext.storedWindowID := WinExist( "A" )
    
    WinGetTitle, winTitle, A
    
    log( "storeActiveWindow() -> " WindowContext.storedWindowID ", " winTitle )
}


restoreActiveWindow()
{
    global WindowContext
    
    storedWinID := WindowContext.storedWindowID
     ; lastActiveWindow()
    WinGetTitle, winTitle, ahk_id %storedWinID%
    log( "restoreActiveWindow() + " storedWinID ", " winTitle )
    ; Sleep 800
    checkSwitchToWindowID( storedWinID, 4 )
}


storeMousePosition()
{
    global WindowContext
    
    MouseGetPos, x, y
    WindowContext.mouse.x := x
    WindowContext.mouse.y := y
}


restoreMousePosition()
{
    global WindowContext
    
    MouseMove, WindowContext.mouse.x, WindowContext.mouse.y
}


raiseWindow( windowTitle, wait = 2 )
{
    if ( ! windowTitle )
    {
        return
    }
    
    log( "raiseWindow( " windowTitle " )" )

    originalTitleMatchMode := A_TitleMatchMode
    
    SetTitleMatchMode, 1
    WinWait %windowTitle%,, %wait%
    WinActivate %windowTitle%
    ; WinWaitActive %windowTitle%,, %wait%
    
    SetTitleMatchMode, %originalTitleMatchMode%
}


raiseWindowID( windowID, wait = 2 )
{
    if ( ! windowID )
    {
        return
    }
    
    log( "raiseWindowID( " windowID " )" )
    
    WinWait, ahk_id %windowID%,, %wait%
    ; Nothing can activate another window when on a full screen window!
    ; WinShow, ahk_id %windowID%
    ; WinSet, Enable,, ahk_id %windowID%
    ; WinSet, Top,, ahk_id %windowID%
    WinActivate, ahk_id %windowID%
    
    log( "raiseWindowID(), window exists -> " WinActive( ahk_id %windowID% ) )
   
    ; WinGetTitle, windowTitle, ahk_id %windowID%
    ; 
    ; Loop, 8
    ; {
    ;     WinActivate, ahk_id %windowID%
    ;     WinActivate, %windowTitle%
	; 
    ;     if ( WinActive( ahk_id %windowID% ) )
    ;     {
    ;         break
    ;     }
    ;     
    ;     log( "raiseWindowID( " windowID " ), WinActivate failed" )
    ; 
    ;     Sleep 100
    ; }

    ; WinRestore, ahk_id %windowID%
    ; Sometimes the window won't activate.
    ; WinWaitActive, ahk_id %windowID%,, %wait%
}


; This is not always working for some reason.
; Maybe it has difficulty switch to some types of window.
checkSwitchToWindowID( windowID, wait = 2 )
{
    global Debug
    
    if ( ! windowID )
    {
        log( "checkSwitchToWindowID( " windowID " ), no window to switch" )
        debugBeep()

        return false
    }
    
    Loop, 4
    {
        raiseWindowID( windowID, wait )
        
        winIsActive := WinActive( ahk_id %windowID% )
        
        if ( winIsActive )
        {
            break
        }
        else
        {
            debugBeep()
        }
    }
    
    WinGetTitle, windowTitle, ahk_id %windowID%
    log( "checkSwitchToWindowID( " windowID " ) + " windowTitle " -> " winIsActive )

    return winIsActive
}


windowIDExists( windowID, default = false )
{
	if ( ! windowID )
	{
		return false
	}
	
	; SetTitleMatchMode, 3
	; SetTitleMatchMode, Slow
	; Sleep 200
	; Doesn't work. Always returns id even when window is closed.
	; The window disappears but there is a delay until the window id is cleared.
	; Now using WinWaitClose.
	checkExistWinID := WinExist( ahk_id %windowID% )
	; This seems to work, but there is a delay after closing the window before the count drops to 0.
	WinGet winCount, Count, ahk_id %windowID%
	; checkActiveWinID := WinActive( ahk_id %windowID% )
    WinGetTitle, windowTitle, ahk_id %windowID%
	
	winExistsAny := ( winCount || checkExistWinID || windowTitle )
    winExistsAll := ( winCount && checkExistWinID && windowTitle )
    
    if ( winExistsAny == winExistsAll )
    {
        winExists := winExistsAny
    }
    else
    {
        winExists := default
    }

	log( "windowIDExists( " windowID " ) + " winCount ", " checkExistWinID ", " checkActiveWinID ", " windowTitle " -> " winExists )

	return winExists
}


checkWindowIDClosed( windowID = "" )
{  
    ; Assume true if no title.
    winClosed := true

    if ( windowID )
    {
        winClosed := ! windowIDExists( windowID )
    }
    
    log( "checkWindowIDClosed( " windowID " ) -> " winClosed )

    return winClosed
}


getWindowIDCentre( windowID )
{	
	if ( ! windowID )
	{
		log( "getWindowIDCentre(), missing window id" )
        
        return false
	}
    
	Loop, 8
	{
		WinGetPos x, y, width, height, ahk_id %windowID%
		
		if ( width )
		{
			break
		}
		
		log( "getWindowIDCentre( " windowID " ), unable to get window position details" )
		
		Sleep 200
		WinActivate ahk_id %windowID%
	}
    
    if ( ! width )
    {
        return false
    }

    cx := x + ( width // 2 )
    cy := y + ( height // 2 )
	
	windowArea = getMonitorArea( windowID )
	
	log( "getWindowIDCentre( " windowID " ) -> x=" x ", y=" y ", w=" width ", h=" height ", sw=" windowArea.width ", sh=" windowArea.height " -> cx=" cx ", cy=" cy )

	windowCentre := Point( cx, cy )
	
	return windowCentre
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
		Run %A_ScriptDir%\WindowSpy.ahk
		WinWait Window Spy,,3
	}

    if ( not ErrorLevel )
	{
		; Move the window to the side a little for convenience.
        WinMove A,, A_ScreenWidth-400, 200
	}
}
