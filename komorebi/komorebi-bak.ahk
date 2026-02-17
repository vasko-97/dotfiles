; set this up to run constantly via Task Scheduler by importing komorebi-ahk.xml

; todo: consider making more and better use of this library
#Include Notify.ahk

#Requires AutoHotkey v2.0.2
#SingleInstance Force

; ################################################################################## Nav Layer ##############################################################################################################

navLayer := false

; Toggle nav layer with Win + Space
; #Space::
^Space::
{
    global navLayer
    navLayer := !navLayer
    
    Notify.Show("Nav Layer", "Turned Nav Layer " (navLayer ? "ON" : "OFF"), , , , "theme=Monokai dur=3 pos=br")
}

#HotIf navLayer

*h::Send "{Blind}{Left}"
*j::Send "{Blind}{Down}"
*l::Send "{Blind}{Right}"
*k::Send "{Blind}{Up}"
*u::Send "{Blind}{Home}"
*o::Send "{Blind}{End}"

#HotIf

; ################################################################################## Komorebi ##############################################################################################################

Komorebic(cmd) {
    RunWait(Format("komorebic.exe {}", cmd), , "Hide")
}

; --------------------------------
; Reload / toggle
; --------------------------------

; todo: consider separate bindings to start/stop/kill
#k::  ; Win+K toggle
{
    pid := ProcessExist("komorebi.exe")
    if (pid) {
        ; Komorebi is running → stop it
        Notify.Show("Komorebi", "Stopping Komorebi...", , , , "theme=Matrix dur=3 pos=br")
        Komorebic("stop --bar")
    } else {
        ; Komorebi not running → start it
        Notify.Show("Komorebi", "Starting Komorebi...", , , , "theme=Matrix dur=3 pos=br")
        Komorebic("start --bar --clean-state")
        Notify.Show("Komorebi", "Started Komorebi. Focusing open windows...", , , , "theme=Matrix dur=3 pos=br")

        ; todo: consider separate binding that start komorebi without this script, to use if I know all windows are already maximised
        configDir := EnvGet("KOMOREBI_CONFIG_HOME")
        scriptPath := configDir "\FocusOpenWindows.ps1"
        ; temporarily disabling focus windows script to see if it's what's causing phantom tiles
        RunWait('powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' scriptPath '"')
        Notify.Show("Komorebi", "Finished focusing open windows.", , , , "theme=Matrix dur=3 pos=br")
    }
}

; todo: consider adding key to reload AHK like whkd has
!+o::Komorebic("reload-configuration")

; --------------------------------
; Window actions
; --------------------------------

^!q::Komorebic("close")
!m::Komorebic("manage")
!+m::Komorebic("unmanage")

; --------------------------------
; Focus windows
; --------------------------------

!h::Komorebic("focus left")
!l::Komorebic("focus right")
!j::Komorebic("focus down")
!k::Komorebic("focus up")
!o::Komorebic("cycle-focus previous")
!i::Komorebic("cycle-focus next")

; --------------------------------
; Move windows
; --------------------------------

!+h::Komorebic("move left")
!+l::Komorebic("move right")
!+j::Komorebic("move down")
!+k::Komorebic("move up")
!+Enter::Komorebic("promote")

; --------------------------------
; Stack windows
; --------------------------------

!Left::Komorebic("stack left")
!Down::Komorebic("stack down")
!Up::Komorebic("stack up")
!Right::Komorebic("stack right")
!;::Komorebic("unstack")
![::Komorebic("cycle-stack previous")
!]::Komorebic("cycle-stack next")

; --------------------------------
; Resize
; --------------------------------

!=::Komorebic("resize-axis horizontal increase")
!-::Komorebic("resize-axis horizontal decrease")
!+=::Komorebic("resize-axis vertical increase")
!+_::Komorebic("resize-axis vertical decrease")

; --------------------------------
; Manipulate windows
; --------------------------------

^!t::Komorebic("toggle-float")
!u::Komorebic("toggle-monocle")

; --------------------------------
; Window manager options
; --------------------------------

^!r::Komorebic("retile")
!p::Komorebic("toggle-pause")

; --------------------------------
; Layout / workspace helpers
; --------------------------------

^!x::Komorebic("focus-last-workspace")
!y::Komorebic("move-to-workspace 8")

; --------------------------------
; Workspaces (focus)
; --------------------------------

^!1::Komorebic("focus-workspace 0")
^!2::Komorebic("focus-workspace 1")
^!3::Komorebic("focus-workspace 2")
^!4::Komorebic("focus-workspace 3")
^!5::Komorebic("focus-workspace 4")

!6::Komorebic("focus-workspace 5")
!7::Komorebic("focus-workspace 6")
!8::Komorebic("focus-workspace 7")
!9::Komorebic("focus-workspace 8")

^!s::Komorebic("cycle-workspace next")
^!a::Komorebic("cycle-workspace previous")

; --------------------------------
; Move windows across workspaces
; --------------------------------

^!+1::Komorebic("move-to-workspace 0")
^!+2::Komorebic("move-to-workspace 1")
^!+3::Komorebic("move-to-workspace 2")
^!+4::Komorebic("move-to-workspace 3")
^!+5::Komorebic("move-to-workspace 4")
!+6::Komorebic("move-to-workspace 5")
!+7::Komorebic("move-to-workspace 6")
!+8::Komorebic("move-to-workspace 7")
!+9::Komorebic("move-to-workspace 8")

^!+s::Komorebic("cycle-move-to-workspace next")
^!+a::Komorebic("cycle-move-to-workspace previous")

; Prevent Alt menu bar activation that various apps may be using
~Alt::Return

; ################################################################################## Misc App Remaps #############################################################################################################

; use Ctrl+J/K to move around in Teams and Outlook. todo: add H/L if needed, but might not be
#HotIf WinActive("ahk_exe ms-teams.exe") || WinActive("ahk_exe olk.exe") || WinActive("ahk_exe brave.exe")

^j::Send "{Down}"
^k::Send "{Up}"

#HotIf

; map Ctrl+M to Enter globally in JetBrains IDEs
#HotIf WinActive("ahk_exe rider64.exe") || WinActive("ahk_exe datagrip64.exe")

^m::Send "{Enter}"

#HotIf

; ################################################################################## Kill Switch (Ctrl + Alt + Shift + Esc)  #############################################################################################################

^!+Esc::{
    TrayTip("komorebi AHK", "Panic kill switch activated.`nScript exiting.", 1)
    ExitApp
}
