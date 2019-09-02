#NoEnv
#InstallKeybdHook
#InstallMouseHook
#include gdip.ahk
#include gdip_imagesearch.ahk
SetBatchLines, 100ms

Random, rand, 5, 23
rand := rand*60*1000

ControlSend, , {Space}, ahk_exe Wow.exe
SetTimer, jumpTimer, %rand%

LoopTime() {

  Loop,
  {

  }

} ; Looptime func end


jumpTimer:
  WinGetActiveTitle, activeWindow

  if (activeWindow != "World of Warcraft") {
    ControlSend, , {Space}, ahk_exe Wow.exe
  }
  else if (activeWindow = "World of Warcraft" && A_TimeIdle > 5000) {
    ControlSend, , {Space}, ahk_exe Wow.exe
  }

  Random, rand, 5, 23
  rand := rand*60*1000

  SetTimer, jumpTimer, %rand%

Return