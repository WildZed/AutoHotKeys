#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.




runWithAvailableVideoPlayer( videoFile )
{
	videoLANx86 = "C:\Program Files (x86)\VideoLAN\VLC\vlc.exe"
 	videoLANx64 = "C:\Program Files\VideoLAN\VLC\vlc.exe"
   
    ; MsgBox, %videoFile%
	if ( FileExist( videoLANx64 ) )
	{
		Run %videoLANx64% --started-from-file "%videoFile%"
		WinWait VLC media player,,4
	}
	else if ( FileExist( videoLANx86 ) )
	{
		Run %videoLANx86% --started-from-file "%videoFile%"
		WinWait VLC media player,,4
	}
	else
	{
		Run "%videoFile%"
		; Assuming Windows Media Player.
		WinWait ahk_class WMP Skin Host,,4
		toggleFullScreenWindowsMediaPlayer()
	}
}


quitVideo( modifier )
{
    if ( modifier == "VideoLAN" )
    {
        quitVideoLAN()
    }
}


quitVideoLAN()
{
    SendInput ^q
}
