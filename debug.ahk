#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

LogFile := "C:\tmp\shortcutkeys.log"
Debug := { debug : true, beep : false, logging : false, logFile : LogFile, indent : 0, indentStr : "", unitIndentStr : "  " }




createLog()
{
	global Debug
	
	if ( Debug.logging )
	{
		file := FileOpen( Debug.logFile, "w" )
		file.Close()
	}
}


createIndentString( indent, unitIndentStr )
{	
	indentStr := ""
	
	Loop, %indent%
	{
		indentStr := indentStr unitIndentStr
	}
	
	return indentStr
}


pushLogIndent()
{
	global Debug
	
	Debug.indent := Debug.indent + 1
	Debug.indentStr := createIndentString( Debug.indent, Debug.unitIndentStr )
}


popLogIndent()
{
	global Debug
	
	Debug.indent := Debug.indent - 1
	Debug.indentStr := createIndentString( Debug.indent, Debug.unitIndentStr )
}


log( text )
{
    global Debug
	
	if ( ! Debug.debug && ! Debug.logging )
	{
		return
	}
	
	text := Debug.indentStr text
    
    if ( Debug.debug )
    {
        OutputDebug ahk: %text%
    }
	
	if ( Debug.logging )
	{
		logFile := Debug.logFile
		; FileAppend, %text% "`n", %logFile%
		file := FileOpen( logFile, "a" )
		file.Write( text "`n" )
		file.Close()
	}
}


logActiveWindowID( label )
{
    global Debug
	
	if ( ! Debug.debug && ! Debug.logging )
	{
		return
	}
	
	activeWinID := WinExist( "A" )
	
	log( label " logActiveWindowID() -> " activeWinID )
}


logPush( label )
{
    global Debug
	
	if ( ! Debug.debug && ! Debug.logging )
	{
		return
	}
	
	activeWinID := WinExist( "A" )
	
	log( label " ( " activeWinID " )" )
	pushLogIndent()
}


logPop( label )
{
    global Debug
	
	if ( ! Debug.debug && ! Debug.logging )
	{
		return
	}

	activeWinID := WinExist( "A" )
	
	popLogIndent()
	log( label " ( " activeWinID " )" )
}


debugBeep( num = 1 )
{
    global Debug
    
    if ( Debug.beep )
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
    global Debug
    global SelectedBrowser
    global LaunchData
    
    debugText :=            "Logging = " Debug.logging "`n"
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
