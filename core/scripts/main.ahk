#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance
SetBatchLines, 1
SetMouseDelay, 0
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#include %A_ScriptDir%\Gdip_all.ahk
#Include %A_ScriptDir%\Gdip_ImageSearch.ahk

#InstallKeybdHook
#InstallMouseHook
OnExit("ExitFunc")
onClipBoardChange("ClipChanged")

SplitPath, A_ScriptDir, , OutDir
SetWorkingDir, %OutDir%

global wowProcess

pToken := Gdip_Startup() ; get gdip token to utilize library
;wowWindowExists := WinExist("ahk_pid %wowProcess%")
Process, Exist, Battle.net.exe
bnetProcess := ErrorLevel
Process, Exist, WowClassic.exe
wowProcess := ErrorLevel

;EmptyMem()

bnetPath := getBnetPath()

if (!bnetProcess) {
  Run, %bnetPath%
  Sleep 2000
  Reload
}

; if world of warcraft is not started
if (!wowProcess) {
  findBnetPlayButton()
  ;Sleep 30000
}
; world of warcraft exists and we send a space command to it to indicate start of afk macro
else {
  ControlSend, ahk_parent, {Space}, World of Warcraft ahk_exe WowClassic.exe
}

Random, rand, 4, 9 ; afk timer random wait time in minutes
rand := rand*60*1000 ; convert minutes to milliseconds
SetTimer, jumpTimer, %rand% ; set timer to jump after milliseconds have passed


SetBatchLines, 1

/*
* Main loop function
*/
loopTime() {
  Loop
  {
    ; If WoW window exists go ahead with main function
    if (WinExist("ahk_pid " . wowProcess)) {

      ; get active window name
      WinGetTitle, activeWindow, A
      activeWindowHWND := WinExist("A")
      WinGet, activeWindowPID, PID, ahk_id %activeWindowHWND%

      if (activeWindowPID = wowProcess) {


        ; Loop images for dealing with buttons/serverlist
        Loop, images/*.*
        {
          ; imagesearch for same picture as needle
          ImageSearch, X, Y, 0, 0, A_ScreenWidth, A_ScreenHeight, *20 *Trans0xFF69B4 images/%A_LoopFileFullPath%

          if (X) {
            ; if iamge is enter world, sleep 2sec
            ; allows for addons to load and if the intent was to change character
            if (InStr(A_LoopFileName, "enter world")) {
              Sleep 2000
            }
            MouseClick, left, X, Y, 2
          }
        }

        ; Loop images indicating a disconnect occured
        Loop, images/dc/*.*
        {
          ; imagesearch for same picture as needle
          ImageSearch, X, Y, 0, 0, A_ScreenWidth, A_ScreenHeight, *20 *Trans0xFF69B4 images/dc/%A_LoopFileFullPath%

          ; if match then some kind of disconnect occured
          if (X) {
            ; close wow window
            WinClose, ahk_pid %wowProcess%
            Sleep, 2000
            ; activate battle.net client
            WinActivate, ahk_exe Battle.net.exe
            ;Sleep, 3000
            ; reload script (easier than writing additional logic)
            Reload
          }
        }
      }
      else {
        ; get WoW window HWID
        WinGet, wowHWND, ID, ahk_pid %wowProcess%
        ; create haystack bitmap from hwnd
        haystackBitmap := pBitmap(wowHWND)
        pColor := Gdip_GetPixel(haystackBitmap, 0, 0)

        if (pColor = 0 || pColor = "0") {
          WinActivate, ahk_pid %wowProcess%
        }


        ; Loop images for dealing with buttons/serverlist
        Loop, images/*.*
        {
          ; empty var for Gdip_ImageSearch to fill with cooridnates
          arr := ""
          ; create needle bitmap from image
          needleBitmap := Gdip_CreateBitmapFromFile("images/"A_LoopFileFullPath)
          ; imagesearch haystack with needle, save match number in var
          match := Gdip_ImageSearch(haystackBitmap, needleBitmap, arr, , , , , 20, 0xFF69B4)

          if (match > 0) {
            ; activate wow window
            ; perform regular imagesearch for same picture as needle
            ImageSearch, X, Y, 0, 0, A_ScreenWidth, A_ScreenHeight, *20 *Trans0xFF69B4 images/%A_LoopFileFullPath%

            if (X) {
              ; if iamge is enter world, sleep 2sec
              ; allows for addons to load and if the intent was to change character
              if (InStr(A_LoopFileName, "enter world")) {
                Sleep 2000
              }
              
              WinActivate, ahk_pid %wowProcess%
              MouseClick, left, X, Y, 2
            }
          }

          ; remove needle image from memory
          Gdip_DisposeImage(needleBitmap)
        }

        ; Loop images indicating a disconnect occured
        Loop, images/dc/*.*
        {
          ; empty var for Gdip_ImageSearch to fill with cooridnates
          arr := ""
          ; create needle bitmap from image
          needleBitmap := Gdip_CreateBitmapFromFile("images/dc/"A_LoopFileFullPath)
          ; imagesearch haystack with needle, save match number in var
          match := Gdip_ImageSearch(haystackBitmap, needleBitmap, arr, , , , , 20, 0xFF69B4)

          if (match > 0) {
            ; activate wow window
            WinActivate, ahk_pid %wowProcess%
            ; perform regular imagesearch for same picture as needle
            ImageSearch, X, Y, 0, 0, A_ScreenWidth, A_ScreenHeight, *20 *Trans0xFF69B4 images/dc/%A_LoopFileFullPath%

            ; if match then some kind of disconnect occured
            if (X) {
              ; close wow window
              WinClose, ahk_pid %wowProcess%
              Sleep, 2000
              ; activate battle.net client
              WinActivate, ahk_exe Battle.net.exe
              Sleep, 3000
              ; reload script (easier than writing additional logic)
              Reload
            }
          }

          ; remove needle image from memory
          Gdip_DisposeImage(needleBitmap)
        }

        ; remove haystack image from memory
        Gdip_DisposeImage(haystackBitmap)
      }

    }
    ; if no WoW window exists
    else {
      findBnetPlayButton()
    }


    Sleep 1000
  }
}


/*
* Call loop function to initiatlize on script startup
*/
loopTime()

/*
* Reload and Pause keys
*/
~PgDn::Reload
~Pause::Pause
~PgUp::BlockInput, On
~+^PgDn::ExitApp
~^Space::
Sleep 200
  While (GetKeyState("Space", "P")) {
    Random, jumpSleep, 78, 121
    SendInput, {Space}
    Sleep, %jumpSleep%
  }
Return


!F4::
  WinGetTitle, activeWindow, A
  if (activeWindow = "World of Warcraft") {

    MsgBox, 4,, Close macro?
    IfMsgBox Yes
    {
      WinActivate, World of Warcraft ahk_exe WowClassic.exe
      SendInput, !{F4}
      ExitApp, User confirmed exit after alt-F4
    }
    else
    {
      WinActivate, World of Warcraft ahk_exe WowClassic.exe
      SendInput, !{F4}
    }
  }
  else {
    SendInput, !{F4}
  }
  
Return


/*
* Timer label
*/
jumpTimer:
  ; get active windows name
  WinGetTitle, activeWindow, A

  ; If mouse/keeyboard idle time is less than 5 seconds AND WoW is active then dont do anything
  if (activeWindow = "World of Warcraft" && A_TimeIdle < 5000) {

  }
  else {
    Random, shortRand,1, 1000
    Sleep, %shortRand%
    ControlSend, , {Space}, World of Warcraft ahk_exe WowClassic.exe
  }

  Random, rand, 4, 9 ; new afk timer random wait time in minutes
  rand := rand*60*1000 ; convert minutes to milliseconds
  SetTimer, jumpTimer, %rand% ; refresh timer to jump after milliseconds have passed
Return


/*
* Exit function to shutdown GDIP and delete it's objects
*/
ExitFunc(ExitReason, ExitCode) {
  ; dispose of bitmaps
  Gdip_DisposeImage(needleBitmap)
  Gdip_DisposeImage(haystackBitmap)
  ; shutdown dll token
  Gdip_Shutdown(pToken)
}



/*
* Function to get bitmap from HWID
*/
pBitmap(HWID) {
  image := HWID

  image := WinExist(image) ? WinExist(image) : image

  if (DllCall("IsIconic", "ptr",image)) {
    DllCall("ShowWindow", "ptr",image, "int",4) ; Restore if minimized!
  }

  VarSetCapacity(rc, 16)
  DllCall("GetClientRect", "ptr",image, "ptr",&rc)

  hbm := CreateDIBSection(NumGet(rc, 8, "int"), NumGet(rc, 12, "int"))
  VarSetCapacity(rc, 0)

  hdc := CreateCompatibleDC()
  obm := SelectObject(hdc, hbm)
  DllCall("PrintWindow", "ptr",image, "ptr",hdc, "uint",0x3)

  pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
  SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
  return pBitmap
}



findBnetPlayButton() {
  ; activate battle.net client
  bnetPath := getBnetPath()
  Run, %bnetPath%
  Sleep 2000



  newWowStarted := 0
  wowArray = []
  ; loop images to find play button
  while (!WinExist("World of Warcraft ahk_exe WowClassic.exe")) {

    Run, %bnetPath%

    bnetLoopLabel:
    Loop images/bnet/*.PNG
    {
      ImageSearch, X, Y, 0, 0, A_ScreenWidth, A_ScreenHeight, *20 images/bnet/%A_LoopFileFullPath%
      if (X) {
        MouseClick, left, X, Y, 1
        X := 0
        Sleep 500
        Goto, bnetLoopLabel
      }
    }

    Loop images/bnet/play/*.PNG
    {
      ImageSearch, X, Y, 0, 0, A_ScreenWidth, A_ScreenHeight, *20 images/bnet/play/%A_LoopFileFullPath%
      if (X) {
        MouseClick, left, X, Y, 1
        X := 0
        Sleep 10000
      }
    }
  }

  Process, Exist, WowClassic.exe
  wowProcess := ErrorLevel
}


getBnetPath() {
  FileRead, bnetPath, battle.net path.txt

  ; file with path is empty or doesnt exist
  if (ErrorLevel = 1) {
    ; batchlines -1 for speed
    setbatchlines, -1
    ; get list of drives on system
    DriveGet, drives, List
    ; split string into array of drive letters
    drives := StrSplit(drives, "")

    ; loop through drive letters array
    for i, drive in drives
    {
      Loop, Files, %drive%:\*Battle.net, RD
      {
        if A_LoopFileLongPath contains users,windows,microsoft
          Continue

        Loop, %A_LoopFileLongPath%\*.exe
        {
          if (A_LoopFileName = "Battle.net.exe") {
            FileAppend , %A_LoopFileFullPath%, battle.net path.txt, UTF-8
            SetBatchLines, 1
            return %A_LoopFileFullPath%
          }
        }
      }
    }
  }
  else {
    SetBatchLines, 1
    return %bnetPath%
  }
}



; Clipboard paste
ClipChanged() {
	clip := Clipboard
	if (RegExMatch(Clipboard, "/script DEFAULT_CHAT_FRAME:AddMessage") > 0 ) {
    WinActivate, World of Warcraft ahk_exe WowClassic.exe
    KeyWait, w
    SetKeyDelay, 50, 50
    SendInput,{enter}
    Sleep 50
    SendInput, %clip%{enter}
	}
}



EmptyMem(PID="AHK Rocks"){
    pid:=(pid="AHK Rocks") ? DllCall("GetCurrentProcessId") : pid
    h:=DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
    DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
    DllCall("CloseHandle", "Int", h)
}

Join(sep, params*) {
  for index,param in params
      str .= param . sep
  return SubStr(str, 1, -StrLen(sep))
}