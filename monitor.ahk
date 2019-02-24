#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

MainMonitor := 1
ProjectionMonitor := 2





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
            monitor := A_Index 
		}
    }
    
    log( "getMonitorAt( ( " pos.x ", " pos.y " ), " default " ) -> " monitor )

    return monitor 
}


getWindowIDMonitor( windowID = 0 )
{
	if ( ! windowID )
	{
        windowID := WinExist( "A" )
	}
	
	windowCentre := getWindowIDCentre( windowID )
	monitor := getMonitorAt( windowCentre )
    
    log( "getWindowIDMonitor( " windowID " ) -> " monitor )

	return monitor
}


getMonitorRectangle( monitor )
{
	SysGet, monitor, Monitor, %monitor%
	
	ll := Point( monitorLeft, monitorBottom )
	ur = Point( monitorRight, monitorTop )
    
    log( "getMonitorRectangle( " monitor " ) -> " ll ", " ur )
    	
	return Rectangle( ll, ur )
}


getMonitorArea( monitor )
{	
	SysGet, monitor, Monitor, %monitor%
	
	tl := Point( monitorLeft, monitorTop )
	width := monitorRight - monitorLeft
	height := monitorBottom - monitorTop
    
    log( "getMonitorArea( " monitor " ) -> ( " tl.x ", " tl.y " ), " width ", " height )
	
	return Area( tl, width, height )
}


nextMonitor()
{
	log( "nextMonitor(), send right" )
	SendInput +#{Right}
}


previousMonitor()
{
	log( "previousMonitor(), send left" )
	SendInput +#{Left}
}


switchToMonitor( monitor )
{
	log( "switchToMonitor( " monitor " ), start" )
	
	currentWindowMonitor := getWindowIDMonitor()
	activeWindowMonitor := currentWindowMonitor
	
	Loop, 8
	{
		if ( activeWindowMonitor == monitor )
		{
			break
		}
		
		nextMonitor()
		Sleep 200
		activeWindowMonitor := getWindowIDMonitor()
		
		if ( activeWindowMonitor == curentWindowMonitor )
		{
			break
		}
	}
	
	log( "switchToMonitor( " monitor " ), end" )
}


switchToMainMonitor()
{
	global MainMonitor
	
	switchToMonitor( MainMonitor )
}


switchToProjectionMonitor()
{
	global ProjectionMonitor
	
	switchToMonitor( ProjectionMonitor )
}


toggleProjectionMonitor()
{
	global MainMonitor
	
	currentWindowMonitor := getWindowIDMonitor()
	
	if ( currentWindowMonitor == MainMonitor )
	{
		switchToProjectionMonitor()
	}
	else
	{
		switchToMainMonitor()
	}
}


moveWindowToNextVirtualDesktop()
{
    ; WIN+TAB=Open the desktop view.
    SendInput #{Tab}
    Sleep 800
    ; Sleep 2000
    ; SHIFT+F10=context menu. M=move. Enter for the first desktop in the list.
    SendInput +{F10}
    Sleep 800
    SendInput {Down}
    ; Sleep 2000
    SendInput {Down}
    Sleep 200
    SendInput {Right}
    Sleep 800
    SendInput {Right}
    Sleep 800
    SendInput {Enter}
    Sleep 100
    ; Sleep 2000
    ; WIN+TAB=Close the desktop view.
    SendInput #{Tab}
}