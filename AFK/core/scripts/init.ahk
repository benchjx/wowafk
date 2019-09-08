#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


SplitPath, A_ScriptDir, ,coreDir
SplitPath, coreDir, ,afkDir
SplitPath, afkDir, ,wowafkDir
SplitPath, wowafkDir, wowafkFolderName,wowafkParent


RunWait, %coreDir%\AHK\AutoHotkey.exe %coreDir%\scripts\update.ahk
Run, %coreDir%\AHK\AutoHotkey.exe %coreDir%\scripts\main.ahk

Return