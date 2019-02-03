;; To allow re-run without dialog box.
#SingleInstance force
; #MaxThreadsPerHotkey 2

DetectHiddenWindows, on
SetTitleMatchMode, 2

#Include utils.ahk
#Include clipboard.ahk
#Include window.ahk
#Include monitor.ahk
#Include browser.ahk
#Include video.ahk
#Include project.ahk
#Include debug.ahk




;; Swap to our own menu, which is the original with a few modifications.
Gosub, TRAYMENU


; Define the tray menu.
TRAYMENU:
    applicationname = Short Cut Keys
    Menu, Tray, NoStandard
    Menu, Tray, DeleteAll 
    Menu, Tray, Add, %applicationname%, TrayMenuHdlr_ScriptEdit
    Menu, Tray, Add, Show &Debug Console, TrayMenuHdlr_DebugConsole
    Menu, Tray, Add, &Show Debug View, showDebugView
    Menu, Tray, Add, &Show Hot Key History, TrayMenuHdlr_ShowKeyHistory
    Menu, Tray, Add, &Help, TrayMenuHdlr_Help
    Menu, Tray, Add ; Creates a separator line.
    Menu, Tray, Add, &Window Spy, TrayMenuHdlr_WinSpy
    Menu, Tray, Add, &Reload Script, TrayMenuHdlr_ScriptReload
    Menu, Tray, Add, &Edit Script, TrayMenuHdlr_ScriptEdit
    Menu, Tray, Add, &List Hot Keys, TrayMenuHdlr_ShowHotKeyList
    Menu, Tray, Add, &List Other Keys, TrayMenuHdlr_ShowOtherKeyList
    Menu, Tray, Add, &Launch Buttons, launchButtonDialog
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
    editFile( A_ScriptName )
return


TrayMenuHdlr_DebugConsole:
    ListLines
return


TrayMenuHdlr_ShowKeyHistory:
    KeyHistory
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

;; Close selected browser.
^!q::closeSelectedBrowser()

#!l::launchButtonDialog()

;; Show stored launch commands.
!#v::showStoredLaunchCommands()

;; End project.
; Win-q has is caught by some other application.
!q::endLaunched()

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

;; Play/pause launched window by switching to window and back.
#Space::pausePlayLaunched()


; These can store selected video file, YouTube URL on the clipboard or hovered over YouTube page link.

;; Store launch command for later launch.
^+s::storeLaunchCommand()

;; Store launch command for later launch.
^+a::storeLaunchCommand( "p" )

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
