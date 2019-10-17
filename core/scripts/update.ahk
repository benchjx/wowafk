#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
whr.Open("GET", "https://raw.githubusercontent.com/rainfordays/wowafk/master/core/version.txt", true)
whr.Send()
; Using 'true' above and the call below allows the script to remain responsive.
whr.WaitForResponse()
remoteVersion := whr.ResponseText



;Progress, 0 , Setting variables, Updating, Updating


SplitPath, A_ScriptDir, ,coreDir
SplitPath, coreDir, ,wowafkDir
SplitPath, wowafkDir, wowafkFolderName,wowafkParent

SetWorkingDir, %wowafkParent%


FileRead, localVersion, %coreDir%\version.txt




if (CompareFileVersions(remoteVersion, localVersion) >= 0) {
  Goto, progressCompleteLabel
}


Progress, 14 , Downloading zip, Updating, Updating
UrlDownloadToFile, https://github.com/rainfordays/wowafk/archive/master.zip, wowafk-master.zip

Progress, 28 , Setting variables, Updating, Updating
zipFile = %wowafkParent%/wowafk-master.zip ;the path of compressed 7z file

Progress, 42 , Setting output path, Updating, Updating
Output_Path := wowafkParent ;the path to extract files

Progress, 56 , Renaming archived folder, Updating, Updating
RunWait %comspec% /c %A_ScriptDir%\zip\7za.exe rn "%zipFile%" wowafk-master "%wowafkFolderName%"

; joke progress
Progress, 56 , Uninstalling addons, Updating, Updating 
Sleep 800

Progress, 70 , Extracting archive, Updating, Updating
FileRemoveDir, %coreDir%, 1
RunWait %comspec% /c %A_ScriptDir%\zip\7za.exe x -aoa "%zipFile%" -o"%Output_Path%",,hide

Progress, 84 , Removing Archive, Updating, Updating
FileDelete, %wowafkParent%/wowafk-master.zip


progressCompleteLabel:

Progress, 100

Return




CompareFileVersions(a,b)
{
  StringSplit, a, a, .
  StringSplit, b, b, .
  Loop, % ( a0 < b0 ? a0 : b0 )
  {
    ai := a0-(A_Index-1) , bi := b0-(A_Index-1)
    av := (A_Index<>1)AND(StrLen(a%ai%)<StrLen(b%bi%)) ? a%ai%*(10**(StrLen(b%bi%)-StrLen(a%ai%))) : a%ia%
    bv := (A_Index<>1)AND(StrLen(b%bi%)<StrLen(a%ai%)) ? b%bi%*(10**(StrLen(a%ai%)-StrLen(b%bi%))) : b%ib%
    If ( av <> bv )
      Return ( av>bv ? -1 : 1 )
  }
  Return ( a0>b0 ? -1 : a0<b0 ? 1 : 0 )
}