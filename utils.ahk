#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
; #Include %A_ScriptDir%

; Globals.
WindowsPath := "C:\Windows"




editFile( file )
{
    Run, notepad++.exe %A_ScriptName%
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


Point( cx = 0, cy = 0 )
{
	return { x : cx, y : cy }
}


Rectangle( cll, cur )
{
	return { ll : cll, ur : cur }
}


Area( ctl, cwidth, cheight )
{
	return { tl : ctl, width : cwidth, height : cheight }
}


middleClick( position, numClicks = 1, delay = 0 )
{	
    storeMousePosition()
    
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
    
    restoreMousePosition()
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


showHotKeyList()
{
    global Debug
    
    SetBatchLines, -1
    AutoTrim, off

    hotKeyStartStr := ";; Hot keys setup."
    hotKeyEndStr := ";; Hot keys end."
    lenHotKeyStartStr := StrLen( hotKeyStartStr )
    lenHotKeyEndStr := StrLen( hotKeyEndStr )
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
        
        if ( hotKeyEndStr == SubStr( line, 1, lenHotKeyEndStr ) )
        {
			if ( Debug )
			{
				continue
			}
			else
			{
				break
			}
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
        else if ( SubStr( line, 1, 3 ) == ":*:" )
        {
            keys := StrSplit( line, ":" )
            key := keys[3]

            keyLine := Format( "{1:-16}{2}`n", key, lastComment )
            keyList := keyList . keyLine

            lastComment := ""
        }
        else ; if ( InStr( line, "::" ) )
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

    ; MsgBox, 0, Hot Keys List, %keyList%
    altMsgBox( "Hot Keys List", keyList )
    keyList=
}
