#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

Progress, 0 , Setting variables, Updating, Updating

SplitPath, A_ScriptDir, ,coreDir
SplitPath, coreDir, ,afkDir
SplitPath, afkDir, ,wowafkDir
SplitPath, wowafkDir, wowafkFolderName,wowafkParent

SetWorkingDir, %wowafkParent%

Progress, 14 , Downloading zip, Updating, Updating
UrlDownloadToFile, https://github.com/rainfordays/wowafk/archive/master.zip, wowafk-master.zip

Progress, 28 , Setting variables, Updating, Updating
zipFile = %wowafkParent%/wowafk-master.zip ;the path of compressed 7z file

Progress, 42 , Setting output path, Updating, Updating
Output_Path := wowafkParent ;the path to extract files

Progress, 56 , Renaming archived folder, Updating, Updating
RunWait %comspec% /c %A_ScriptDir%\zip\7za.exe rn "%zipFile%" wowafk-master wowafk

Progress, 56 , Niko is RNGesus, Updating, Updating
Sleep 400
Progress, 56 , Waiting for Mendy to slay some scrubs, Updating, Updating
Sleep 600

Progress, 70 , Extracting archive, Updating, Updating
RunWait %comspec% /c %A_ScriptDir%\zip\7za.exe x -aoa "%zipFile%" -o"%Output_Path%",,hide

Progress, 84 , Removing Archive, Updating, Updating
FileDelete, %wowafkParent%/wowafk-master.zip

Progress, 100

Return