#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, 100ms
SetMouseDelay, 0
#include, Gdip_All.ahk
#Include, Gdip_ImageSearch.ahk
#InstallKeybdHook
#InstallMouseHook






ControlSend, , {Space}, World of Warcraft ahk_exe Wow.exe
Random, rand, 5, 20
rand := rand*60*1000
SetTimer, jumpTimer, %rand%




loopTime() {
  Loop
  {

    pToken := Gdip_Startup()
    WinGet, wowID, ID, World of Warcraft ahk_exe Wow.exe

    haystackBitmap := pBitmap(wowID)


    Loop, Images/*.*
    {
      
      arr := ""
      needleBitmap := Gdip_CreateBitmapFromFile("Images/"A_LoopFileFullPath)

      match := Gdip_ImageSearch(haystackBitmap, needleBitmap, arr, , , , , 20)

      if (match > 0) {
        
        WinActivate, World of Warcraft ahk_exe Wow.exe
        ImageSearch, X, Y, 0, 0, A_ScreenWidth, A_ScreenHeight, *20 Images/%A_LoopFileFullPath%

        if (X) {
          MouseClick, left, X, Y, 2
        }
        
      }

      Gdip_DisposeImage(needleBitmap)
      
    }


    Loop, Images/DC/*.*
    {
      
      arr := ""
      needleBitmap := Gdip_CreateBitmapFromFile("Images/DC/"A_LoopFileFullPath)

      match := Gdip_ImageSearch(haystackBitmap, needleBitmap, arr, , , , , 20)

      if (match > 0) {
        
        WinActivate, World of Warcraft ahk_exe Wow.exe
        ImageSearch, X, Y, 0, 0, A_ScreenWidth, A_ScreenHeight, *20 Images/DC/%A_LoopFileFullPath%

        if (X) {
          WinClose, ahk_exe Wow.exe
          Sleep, 2000
          WinActivate, ahk_exe Battle.net.exe
          Sleep, 5000
        }
        
      }

      Gdip_DisposeImage(needleBitmap)
      
    }


    Gdip_DisposeImage(haystackBitmap)
    Gdip_Shutdown(pToken)
    Sleep 1000
  }
}



loopTime()

~PgDn::Reload
~Pause::Pause

jumpTimer:
  WinGetTitle, activeWindow, A

  if (activeWindow = "World of Warcraft" && A_TimeIdle > (5*60*1000)) {
    Send, {Space}
  }
  else if (activeWindow != "World of Warcraft") {
    ControlSend, , {Space}, ahk_exe Wow.exe
  }
  
  Random, rand, 5, 20
  rand := rand*60*1000
  SetTimer, jumpTimer, %rand%
Return




pBitmap(HWID) {
  image := HWID ; Some sort of hwnd. 

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