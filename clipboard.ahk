#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; lastCopyTime = 0
; lastClipboard = ""
blockOnClipboardChange = 0




clearClipBoard()
{
    clipboard :=
}


getClipBoard( useCurrent = false )
{
    clipBoardStr = %clipboard%
    
    if ( ! useCurrent or clipBoardStr == "" )
    {
        ; blockOnClipboardChange = 1
        clipboard =
        SendInput ^c
        ClipWait, 1 ; 0.5 seconds.
        ; blockOnClipboardChange = 0

        if ErrorLevel
        {
            return ""
        }
        
        clipBoardStr = %clipboard%
    }

    StringReplace, clipBoardStr, clipBoardStr, 's`r`n, , All

    return clipBoardStr
}


;; Paste plain clipboard text.
paste()
{
    tempClipboard = %clipboard%
    clipboard = %tempClipboard% 
    SendInput ^v
}


; OnClipboardChange:
; if (A_EventInfo = 1 and blockOnClipboardChange = 0)
; {
;     if (A_TickCount - lastCopyTime < 500 and lastClipboard != "")
;     {
;         StringReplace, lastClipboard, lastClipboard, 's`r`n, , All
;         StringLeft, firstChar, lastClipboard, 1
;         if firstChar between 0 and 9 
;             Run http://wem5/cgi-bin/opencurbug/opencurwithform.pl?events=y&showbugdata=y&hotline=y&callnum=%lastClipboard%
;     }
;     lastCopyTime = %A_TickCount%
;     lastClipboard = %clipboard%
; }
; return
