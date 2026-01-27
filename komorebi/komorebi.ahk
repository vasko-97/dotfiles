; set this up to run constantly via Task Scheduler by importing komorebi-ahk.xml

#Requires AutoHotkey v2.0.2
#SingleInstance Force

Komorebic(cmd) {
    RunWait(Format("komorebic.exe {}", cmd), , "Hide")
}

; --------------------------------
; Reload / toggle
; --------------------------------

; todo: consider adding key to reload AHK like whkd has
!+o::Komorebic("reload-configuration")
!+i::Komorebic("toggle-shortcuts")

; --------------------------------
; Window actions
; --------------------------------

^!q::Komorebic("close")
!m::Komorebic("minimize")

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

!+1::Komorebic("move-to-workspace 0")
!+2::Komorebic("move-to-workspace 1")
!+3::Komorebic("move-to-workspace 2")
!+4::Komorebic("move-to-workspace 3")
!+5::Komorebic("move-to-workspace 4")
!+6::Komorebic("move-to-workspace 5")
!+7::Komorebic("move-to-workspace 6")
!+8::Komorebic("move-to-workspace 7")
!+9::Komorebic("move-to-workspace 8")

^!+s::Komorebic("cycle-move-to-workspace next")
^!+a::Komorebic("cycle-move-to-workspace previous")

; Prevent Alt menu bar activation that various apps may be using
~Alt::Return

; use Ctrl+j/k/h/l to move around in Teams and Outlook
#HotIf WinActive("ahk_exe ms-teams.exe") || WinActive("ahk_exe msteams.exe") || WinActive("ahk_exe olk.exe")

^h::Send "{Left}"
^j::Send "{Down}"
^k::Send "{Up}"
^l::Send "{Right}"

#HotIf

; ===============================
; PANIC KILL SWITCH
; Ctrl + Alt + Shift + Esc
; ===============================

^!+Esc::{
    TrayTip("komorebi AHK", "Panic kill switch activated.`nScript exiting.", 1)
    ExitApp
}
