#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

Debug := false
Beep := false
LogFile := "C:\tmp\shortcutkeys.log"
Logging := false




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
    global Debug, LogFile, Logging
    
    if ( Debug )
    {
        OutputDebug ahk: %text%
    }
	
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


debugBeep( num = 1 )
{
    global Beep
    
    if ( Beep )
    {
        Loop, %num%
        {
            SoundBeep
        }
    }
}


showDebugView()
{
    Run, C:\Program Files\SysInternals\Dbgview.exe
}


debugState()
{
    global Logging
    global SelectedBrowser
    global LaunchData
    
    debugText :=            "Logging = " Logging "`n"
    debugText := debugText  "SelectedBrowser = " SelectedBrowser "`n"
    debugText := debugText  "launch type = " LaunchData.type "`n"
    debugText := debugText  "launch type modifier = " LaunchData.typeModifier "`n"
    debugText := debugText  "launch window title = " LaunchData.windowTitle "`n"
    debugText := debugText  "launch window ID = " LaunchData.windowID "`n"
    
    MsgBox %debugText%
}


; Test functions.
test( str = "" )
{
	test3()
}


test1( str = "" )
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


test2()
{
	isWindowIDFullScreen()
}


test3()
{
	toggleProjectionMonitor()
}
