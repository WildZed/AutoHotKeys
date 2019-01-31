;; To allow re-run without dialog box.
#SingleInstance force

DetectHiddenWindows, on
SetTitleMatchMode, 2

#Include utils.ahk

; Remember what was launched so that the correct end sequence can be sent.
; Counter for launch commands.
; Array to store launch commands (positional and sequential).
LaunchData := {	type : "", typeModifier : "", windowTitle : "", windowID : 0, counter : 1, map : {} }




;; Swap to our own menu, which is the original with a few modifications.
Gosub, TRAYMENU


; Define the tray menu.
TRAYMENU:
    applicationname = Short Cut Keys
    Menu, Tray, NoStandard
    Menu, Tray, DeleteAll 
    Menu, Tray, Add, %applicationname%, TrayMenuHdlr_ScriptEdit
    Menu, Tray, Add, Show &Debug Console, TrayMenuHdlr_DebugConsole
    Menu, Tray, Add, &Help, TrayMenuHdlr_Help
    Menu, Tray, Add ; Creates a separator line.
    Menu, Tray, Add, &Window Spy, TrayMenuHdlr_WinSpy
    Menu, Tray, Add, &Reload Script, TrayMenuHdlr_ScriptReload
    Menu, Tray, Add, &Edit Script, TrayMenuHdlr_ScriptEdit
    Menu, Tray, Add, &List Hot Keys, TrayMenuHdlr_ShowHotKeyList
    Menu, Tray, Add, &List Other Keys, TrayMenuHdlr_ShowOtherKeyList
    Menu, Tray, Add ; Creates a separator line.
    Menu, Tray, Add, &Suspend Hot Keys, TrayMenuHdlr_Suspend
    Menu, Tray, Add, &Pause Script, TrayMenuHdlr_Pause
    Menu, Tray, Add, E&xit, TrayMenuHdlr_GuiClose
    Menu, Tray, Default, %applicationname%
    Menu, Tray, Tip, %applicationname%
return


TrayMenuHdlr_ShowHotKeyList:
	showHotKeyList()
return


TrayMenuHdlr_ShowOtherKeyList:
    keyList :=           "<space>        Play/Pause VideoLAN, YouTube, etc.`n"
    keyList := keyList . "Ctrl-q        Quit VideoLAN.`n"
    keyList := keyList . "Alt-<Tab>    Cycle through windows.`n"
    keyList := keyList . "Win-<Tab>    Cycle through windows in 3D.`n"
    keyList := keyList . "Alt-<Esc>        Cycle through windows in the order they were opened.`n"
    keyList := keyList . "Win-r        Run command.`n"
    keyList := keyList . "Win-e        Open File Explorer.`n"
    keyList := keyList . "Ctrl-Shift-<Esc>    Open Task Manager.`n"
    keyList := keyList . "Win-<Up>        Maximise the active window.`n"
    keyList := keyList . "Win-<Down>        Minimise the active window.`n"
    keyList := keyList . "Win-<Left>        Maximise the active window to the left.`n"
    keyList := keyList . "Win-<Right>        Maximise the active window to the right.`n"
    keyList := keyList . "Win-<Home>        Minimise all but the active window.`n"
    keyList := keyList . "Win-Shift-<Right>    Shift active window to next screen.`n"
    keyList := keyList . "Win-Shift-<Left>    Shift active window to previous screen.`n"
    MsgBox, 0, Other Keys List, %keyList%
return


TrayMenuHdlr_ScriptReload:
    Reload
return


TrayMenuHdlr_ScriptEdit:
	editFile( %A_ScriptName% )
return


TrayMenuHdlr_DebugConsole:
    ListLines
return


TrayMenuHdlr_WinSpy:
    windowSpy()
return


TrayMenuHdlr_WinSpyEXE:
	windowSpy( true )
return


TrayMenuHdlr_Help:
	ahkHelp()
return


TrayMenuHdlr_Suspend:
    Suspend Toggle

    if ( A_IsSuspended )
    {
        Menu, Tray, Check, &Suspend Hot Keys
    }
    else
    {
        Menu, Tray, Uncheck, &Suspend Hot Keys
    }
return


TrayMenuHdlr_Pause:
    if ( A_IsPaused )
    {
        Pause off
        Menu, Tray, Uncheck, &Pause Script
    }
    else
    {
        Menu, Tray, Check, &Pause Script
        Pause On
    }
return


TrayMenuHdlr_GuiClose:
    ExitApp
return


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
		
		if ( ! Debug and hotKeyEndStr == SubStr( line, 1, lenHotKeyEndStr ) )
		{
			break
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


reset()
{
    clearClipBoard()
    resetLaunchData()
}


reloadAndReset()
{
	Reload
	createLog()
}


debugState()
{
	global Logging
	global SelectedBrowser
	global LaunchData
	
	debugText := 			"Logging = " Logging "`n"
	debugText := debugText  "SelectedBrowser = " SelectedBrowser "`n"
	debugText := debugText  "launch type = " LaunchData.type "`n"
	debugText := debugText  "launch type modifier = " LaunchData.typeModifier "`n"
	debugText := debugText  "launch window title = " LaunchData.windowTitle "`n"
	debugText := debugText  "launch window ID = " LaunchData.windowID "`n"
	
	MsgBox %debugText%
}


isLaunched()
{
    global LaunchData
    
	; AutoHotKeys is such a pile of *#£$e that adding in this line makes this function work!
	; The call to WinExist appears to make the subsequent calls to detect the window id work.
	logActiveWindowID( "isLaunched()" )
	launched := windowIDExists( LaunchData.windowID )
	checkActiveWindow()
	
	log( "isLaunched() + " LaunchData.windowID " -> " launched )

    return launched
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
			WinGetActiveTitle, launchWin
			; WinGetTitle realTitle, ahk_id %LaunchData.windowID%
			; log( "storeLaunched(), id title " realTitle )
			break
		}
		
		log( "storeLaunched( " type ", " modifier " ), unable to get window id" )
	}
	
	log( "storeLaunched( " type ", " modifier " ) -> " LaunchData.windowTitle ", " LaunchData.windowID )
	
	return LaunchData.windowID
}


windowOrLaunchedWindowID( winTitle = "" )
{	
    if ( winTitle )
    {
		winID := WinExist( %winTitle% )
    }
	else
	{
        global LaunchData
    
        winID := LaunchData.windowID
	}
	
   	log( "windowOrLaunchedWindowID( " winTitle " ) -> " winID )
 
    return winID
}


checkWindowClosed( winTitle = "" )
{
    winID := windowOrLaunchedWindowID( winTitle )
    
    ; Assume true if no title.
    winClosed := true

    if ( winID )
    {
		winClosed := ! windowIDExists( launchWinID )
    }
	
	log( "checkWindowClosed( " winTitle " ) + " winID " -> " winClosed )

    return winClosed
}


checkActiveWindow( launched = true )
{
    if ( ! launched )
    {
        return true
    }
    
    global LaunchData
    
	winID := LaunchData.windowID
	checkActiveWinID := WinActive( ahk_id %winID% )
	winIsActive := ( 0 != checkActiveWinID )

    if ( ! winIsActive )
    {
		global Debug
		
		if ( Debug )
		{
			SoundBeep
			; MsgBox %LaunchData.windowTitle%
		}
    }
	
 	log( "checkActiveWindow( " launched " ) + " LaunchData.windowID ", " checkActiveWinID " -> " winIsActive )
   
    return winIsActive
}


checkSwitchToWindow( winTitle = "" )
{
	global Debug
	
	winID := windowOrLaunchedWindowID( winTitle )
    
    if ( ! winID )
    {
		log( "checkSwitchToWindow( " winTitle " ), no window to switch" )
		
		if ( Debug )
		{
			SoundBeep
		}

        return false
    }
    
    WinActivate ahk_id %winID%
    WinWait ahk_id %winID%,,2
    
	winIsActive := ( 0 != WinActive( ahk_id %winID% ) )
    
    if ( ! winIsActive )
    {
		if ( Debug )
		{
			SoundBeep
		}
    }
	
 	log( "checkSwitchToWindow( " winTitle " ) + " winID " -> " winIsActive )

    return winIsActive
}


waitForCloseWindow( winTitle = "" )
{
    winID := windowOrLaunchedWindowID( winTitle )
    
    if ( ! winID )
    {		
        return false
    }

	WinWaitClose, ahk_id %winID%,, 8
}


checkActiveWindowOrSwitchToLaunched( launched = true )
{
    winOk := false
    
    if ( checkActiveWindow( launched ) || checkSwitchToWindow() )
    {
        winOk := true
    }
	
   	log( "checkActiveWindowOrSwitchToLaunched( " launched " ) -> " winOk )
  
    return winOk
}


;; Swap projected application to PC screen.
endLaunched()
{
	logActiveWindowID( "endLaunched()" )

    if ( checkSwitchToWindow() )
    {
		global LaunchData
		
		log( "endLaunched() + " LaunchData.type " + " LaunchData.typeModifier ", switched to window, ending..." )
		
        if ( LaunchData.type == "YouTube" )
        {
            pauseOrPlayYouTubeOrVideoLAN()
            ; toggleMuteYouTube()
			; Move off projection screen first before toggling full screen and closing window.
			toggleFullScreenYouTubeLaunched( LaunchData.typeModifier, true, 0 )
			; Screen swapping doesn't work for full screen, so this needs to happen after toggling full screen.
            ; winPreviousLaunched()
			Send +#{Left}
            Sleep 1800
            closeBrowserWindow()
        }
        else if ( LaunchData.type == "Video" )
        {
            quitVideo( LaunchData.typeModifier )
        }
		
		waitForCloseWindow()
    }
	
	logActiveWindowID( "endLaunched()" )
       
    if ( checkWindowClosed() )
    {
		log( "endLaunched(), window closed" )
		
		if ( Debug )
		{
			SoundBeep
			SoundBeep
		}
		
		resetLaunchWindow()
    }
}


winNextLaunched( launched = true )
{
    if ( checkActiveWindowOrSwitchToLaunched( launched ) )
    {
		winNext()
    }
}


winPreviousLaunched( launched = true )
{
    if ( checkActiveWindowOrSwitchToLaunched( launched ) )
    {
		winPrevious()
    }
}


; Full screen embed URL.
toggleFullScreenYouTubeLaunched( embed = true, launched = true, fullScreen = -1 )
{
    if ( checkActiveWindowOrSwitchToLaunched( launched ) && checkFullScreen( fullScreen ) )
    {
		toggleFullScreenYouTube( embed = true, fullScreen = -1 )
    }
}
 

;; Launch YouTube clip full screen on projected displays.
launchYouTube( youTubeURLOrId = "", autoPlay = false, embed = true, winTitle = "" )
{
    if ( isLaunched() )
    {
		global Debug
		
		log( "launchYouTube(), already launched" )
		
		if ( Debug )
		{
			SoundBeep
		}

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
    
    if ( winTitle == "" )
    {
        WinWait, YouTube,,4
    }
    else
    {
        WinWait, %winTitle%,,4
    }
    
	; A delay is required otherwise the activate/store doesn't work and the store and project don't work.
    Sleep 1800
    
    ; activateSelectedBrowser()    
    winID := storeLaunched( "YouTube", embed )
    ; focusInternetExplorer() ; Doesn't work.
    getBrowserFocus( winID )
    
    return true
}


;; Launch YouTube clip full screen on projected displays.
projectYouTube( youTubeURLOrId = "", autoPlay = false, embed = true, winTitle = ""  )
{
    if ( launchYouTube( youTubeURLOrId, autoPlay, embed, winTitle ) )
    {
		; Must move to projection screen before toggling full screen, otherwise it gets the wrong size.
        winNextLaunched()
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
launchVideo( videoFile = "", autoPlay = false )
{
    if ( isLaunched() )
    {
		global Debug
		
		log( "launchVideo(), already launched" )
	
		if ( Debug )
		{
			SoundBeep
		}
		
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
projectVideo( videoFile = "", autoPlay = false )
{
    launchVideo( videoFile, autoPlay )
    SendInput +#{Right}
}


;; Store a context value when a key is pressed.
storeLaunchCommand( key )
{
    global LaunchData
    
    ; This also gets selected file.
    launchCommand := getClipBoard()
    
    if ( launchCommand == "" and WinActive( "YouTube" ) )
    {
        launchCommand := getHoveredYouTubeURL()
        ; launchCommand := getBrowserStatusBar()
        clearClipBoard()
    }

    if ( launchCommand != "" )
    {
        LaunchData.map[(key)] := launchCommand
        launchCommand := LaunchData.map[(key)]
        ; MsgBox Stored launch command "%launchCommand%" as "%key%".
    }
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


;; Test function.
test( str )
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




;; Hot keys setup.
; #<key>         - WindowsKey+<key>
; ^<key>         - Ctrl+<key>
; +<key>         - Shift+<key>
; !<key>         - Alt+<key>
; <key>&<key>     - Combine 2 keys into a custom key.

; WARNING: For some reason AutoHotKey is disabling the F4 key
; even though there is no hot key setup for F4.
; Solved. {Fn}{F4} is really Win-p. Hot key change to Alt-Win-p.

;; Open Windows hot key help page.
#h::Run "https://support.microsoft.com/en-gb/help/12445/windows-keyboard-shortcuts"

;; Reload the AutoHotKey script.
#r::reloadAndReset()

;; Reset stored data.
^+r::reset()

;; Clear the clipboard.
+^c::clearClipBoard()

;; Open Explorer window.
#e::Run c:\windows\explorer.exe /n`, /e`, C:\

;; Launch a google search for the current selection.
#g::googleSearch()

;; Open YouTube search.
#s::youTubeSearch()

;; End project.
; Win-q has is caught by some other application.
!q::endLaunched()

;; Close selected browser.
^!q::closeSelectedBrowser()

;; Open YouTube search.
#!y::projectYouTube( "", true ) ; Autoplay.

;; Project current YouTube clip at full screen.
; Aha Win-p does the same as {Fn}{F4} and therefore must be mapped to Win-p.
#!p::projectActiveWindowYouTube()

;; Project hovered over YouTube clip at full screen.
; Does work for some but not others.
#^!p::projectHoveredYouTube()

;; Show selected video file full screen on the projected display.
#v::projectVideo( "", true ) ; Autoplay.

;; Show stored launch commands.
!#v::showStoredLaunchCommands()


; These can store selected video file, YouTube URL on the clipboard or hovered over YouTube page link.

;; Store launch command 1 for later launch.
^+1::storeLaunchCommand( "p1" )

;; Store launch command 2 for later launch.
^+2::storeLaunchCommand( "p2" )

;; Store launch command 3 for later launch.
^+3::storeLaunchCommand( "p3" )

;; Store launch command 4 for later launch.
^+4::storeLaunchCommand( "p4" )

;; Store launch command 5 for later launch.
^+5::storeLaunchCommand( "p5" )

;; Store launch command 6 for later launch.
^+6::storeLaunchCommand( "p6" )

;; Store launch command 7 for later launch.
^+7::storeLaunchCommand( "p7" )

;; Store launch command 8 for later launch.
^+8::storeLaunchCommand( "p8" )


;; Invoke stored launch command 1.
^1::launchStoredCommand( "p1" )

;; Invoke stored launch command 2.
^2::launchStoredCommand( "p2" )

;; Invoke stored launch command 3.
^3::launchStoredCommand( "p3" )

;; Invoke stored launch command 4.
^4::launchStoredCommand( "p4" )

;; Invoke stored launch command 5.
^5::launchStoredCommand( "p5" )

;; Invoke stored launch command 6.
^6::launchStoredCommand( "p6" )

;; Invoke stored launch command 7.
^7::launchStoredCommand( "p7" )

;; Invoke stored launch command 8.
^8::launchStoredCommand( "p8" )


; Setup quick display of videos, YouTube clips etc. here, using hard coded hot keys or hot strings.


; Examples.

;; Show example YouTube video full screen on the projected display (autoplay).
^#v::projectYouTube( "LF3Zr3D2UmA", true ) ; We Want To See Jesus Lifted High

;; Show example YouTube video full screen on the projected display (paused).
; Type yt1 anywhere to launch this, but choose the string carefully!
:*:yt1::
projectYouTube( "H7NhaVE0MAw", false ) ; HillSong.
return

;; Show example YouTube video full screen on the projected display (autoplay).
:*:yt2::
projectYouTube( "LqBpifDpNKc", true ) ; Oh Praise the Name (Anastasis).
return

;; Show example video file full screen on the projected display (autoplay).
:*:vd1::
projectVideo( "C:\Users\sounddesk\Documents\AutoHotKeys\TestData\P1100046.MOV", true )
return

;; Hot keys end.

; Put other hidden hot keys here?

;; Debug running state.
^!d::debugState()

;; Call test function.
#t::
test( "Z:\Sunday Services\C Anderson.MOV" )
return

;; Test string to say "Hello!".
::hlo::
MsgBox, Hello!
return


;; Show video file full screen on the projected display.
; ::v1::
; launchVideo( "Z:\Sunday Services\C Anderson.MOV" )
; return
; 
; ::v2::
; projectVideo()
; return

; Invoke stored launch command 1.
; Doesn't work.
; ^{Numpad1}::launchStoredCommand( "p1" )

; ;; Make current window fill half of the screen to the left.
; Alt & Left::    Win__HalfLeft()
; ;; Make current window fill half of the screen to the right.
; Alt & Right::  Win__HalfRight()

;; Paste plain clipboard text.
; #v::paste()
