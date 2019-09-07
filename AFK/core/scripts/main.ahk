#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance
SetBatchLines, 100ms ; 100ms to ensure a low use of cpu
SetMouseDelay, 0
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#include %A_ScriptDir%\Gdip_all.ahk
#Include %A_ScriptDir%\Gdip_ImageSearch.ahk

#InstallKeybdHook
#InstallMouseHook
DetectHiddenWindows, On
OnExit("ExitFunc")

SplitPath, A_ScriptDir, , OutDir

SetWorkingDir, %OutDir%

pToken := Gdip_Startup() ; get gdip token to utilize library
wowWindowExists := WinExist("ahk_class GxWindowClass")
bnetWindowExists :=  WinExist("ahk_exe Battle.net.exe")
Process, Exist, Battle.net.exe
bnetProcess := ErrorLevel


FileRead, bnetPath, battle.net path.txt
if (ErrorLevel = 1) {
  setbatchlines, -1
  FoundFile := 0
  Loop, Files, C:\*Battle.net, RD
  { 
    if A_LoopFileLongPath contains users,windows,microsoft
      Continue

    Loop, %A_LoopFileLongPath%\*.exe
    {
      if (A_LoopFileName = "Battle.net.exe") {
        foundFile := 1
        FileAppend , %A_LoopFileFullPath%, battle.net path.txt, UTF-8
        Goto, startLabel
      }
    }
  }
  Loop, Files, D:\*Battle.net, RD
  { 
    if A_LoopFileLongPath contains users,windows,microsoft
      Continue

    Loop, %A_LoopFileLongPath%\*.exe
    {
      if (A_LoopFileName = "Battle.net.exe") {
        foundFile := 1
        FileAppend , %A_LoopFileFullPath%, battle.net path.txt, UTF-8
        Goto, startLabel
      }
    }
  }
}
else if (ErrorLevel = 0 && !wowWindowExists) {
  Run, %bnetPath%
  Goto, bnetLabel
}




startLabel:
SetBatchLines, 200ms



if (!bnetProcess) { ; if battle.net client is not started
  MsgBox, Start Battle.net and try again
  ExitApp, "Battle.net not found"
}
bnetLabel:
if (!wowWindowExists) { ; if world of warcraft is not started
  WinActivate, ahk_exe Battle.net.exe

  Loop images/*.*
  {
    ImageSearch, X, Y, 0, 0, A_ScreenWidth, A_ScreenHeight, *15 images/%A_LoopFileFullPath%

    if (X) {
      MouseClick, left, X, Y, 2
      break
    }
  }
  Sleep 500
  Reload
} else { ; world of warcraft exists and we send a space command to it to indicate start of afk macro
  ControlSend, , {Space}, ahk_class GxWindowClass
}

Random, rand, 9, 24 ; afk timer random wait time in minutes
rand := rand*60*1000 ; convert minutes to milliseconds
SetTimer, jumpTimer, %rand% ; set timer to jump after milliseconds have passed

/*
* Main loop function
*/
loopTime() {
  Sleep 2000
  Loop
  {
    if (WinExist("ahk_class GxWindowClass")) { ; If WoW window exists go ahead with main function
      WinGet, wowHWND, ID, ahk_class GxWindowClass ; get WoW window HWID
      haystackBitmap := pBitmap(wowHWND)


      Loop, images/*.* ; Loop images for dealing with buttons/serverlist
      {
        arr := "" ; empty var for Gdip_ImageSearch to fill with cooridnates
        needleBitmap := Gdip_CreateBitmapFromFile("images/"A_LoopFileFullPath)
        match := Gdip_ImageSearch(haystackBitmap, needleBitmap, arr, , , , , 15)

        if (match > 0) {
          WinActivate, ahk_class GxWindowClass
          ImageSearch, X, Y, 0, 0, A_ScreenWidth, A_ScreenHeight, *15 images/%A_LoopFileFullPath%

          if (X) {
            MouseClick, left, X, Y, 2
          }
        }

        Gdip_DisposeImage(needleBitmap) ; remove needle image from memory
      }

      Loop, images/dc/*.* ; Loop images indicating a disconnect occured
      {
        arr := "" ; empty var for Gdip_ImageSearch to fill with cooridnates
        needleBitmap := Gdip_CreateBitmapFromFile("images/dc/"A_LoopFileFullPath)
        match := Gdip_ImageSearch(haystackBitmap, needleBitmap, arr, , , , , 15)

        if (match > 0) {
          WinActivate, ahk_class GxWindowClass
          ImageSearch, X, Y, 0, 0, A_ScreenWidth, A_ScreenHeight, *15 images/dc/%A_LoopFileFullPath%

          if (X) {
            WinClose, ahk_class GxWindowClass
            Sleep, 2000
            WinActivate, ahk_exe Battle.net.exe
            Sleep, 2000
            Reload
          }
        }

        Gdip_DisposeImage(needleBitmap) ; remove needle image from memory
      }

      Gdip_DisposeImage(haystackBitmap) ; remove haystack image from memory
    }
    else { ; else bring Battle.net client to front and start game
      WinActivate, ahk_exe Battle.net.exe

      Loop images/*.* ; loop regular images for dealing with buttons/serverlist
      {
        ImageSearch, X, Y, 0, 0, A_ScreenWidth, A_ScreenHeight, *15 images/%A_LoopFileFullPath%

        if (X) {
          MouseClick, left, X, Y, 2
          break
        }
      }
      Reload
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


/*
* Timer label
*/
jumpTimer:
  WinGetTitle, activeWindow, A


  if (activeWindow = "World of Warcraft" && A_TimeIdle < 5000) {
    /*
    * If mouse/keeyboard idle time is less than 5 seconds AND WoW is active then dont do anything
    */
  }
  else {
    ControlSend, , {Space}, ahk_class GxWindowClass
  }

  Random, rand, 9, 24 ; new afk timer random wait time in minutes
  rand := rand*60*1000 ; convert minutes to milliseconds
  SetTimer, jumpTimer, %rand% ; refresh timer to jump after milliseconds have passed
Return


/*
* Exit function to shutdown GDIP and delete it's objects
*/
ExitFunc(ExitReason, ExitCode) {
  Gdip_DisposeImage(needleBitmap)
  Gdip_DisposeImage(haystackBitmap)
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