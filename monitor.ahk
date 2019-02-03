﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.





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


getWindowIDMonitor( windowID )
{
	windowCentre := getWindowIDCentre( windowID )
	monitor := getMonitorAt( windowCentre )
    
    log( "getWindowIDMonitor( " windowID " ) -> " monitor )

	return monitor
}


getMonitorRectangle( monitor )
{
	SysGet, monitor, Monitor, monitor
	
	ll := Point( monitorLeft, monitorBottom )
	ur = Point( monitorRight, monitorTop )
    
    log( "getMonitorRectangle( " monitor " ) -> " ll ", " ur )
    	
	return Rectangle( ll, ur )
}


getMonitorArea( monitor )
{	
	SysGet, monitor, Monitor, monitor
	
	width := monitorRight - monitorLeft
	height := monitorBottom - monitorTop
    
    log( "getMonitorArea( " monitor " ) -> " width ", " height )
	
	return Area( width, height )
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