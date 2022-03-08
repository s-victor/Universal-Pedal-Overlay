; Universal Pedal Overlay v1.1.1
; An overlay script which displays controller input such as pedal & steering for any game.
;
; Author: S.Victor
; Last update: 2022-03-09
;
; The overlay is written in Autohotkey (AHK) scripting language.
; It requires game to be in windowed or borderless mode.
; It reads input directly from controller, is independent of any games.

Process, Priority,, Low ; set Low Priority for AHK process
#Singleinstance, Force ; Running same script will skips the dialog box and replaces the old instance automatically, same as Reload command
#KeyHistory 0 ; Disable key history logging

; Feature Toggle
; 0=off. 1=on.
EnableSteeringBar := 1 ; Show/hide Steering bar

; Device number for each Axis (if you have multiple controller)
; Usually the 1st connected device's number is 1, 2nd connected device is 2, etc.
SteeringNumber = 1 ; Steering Axis
ThrottleNumber = 1 ; Throttle Axis
BrakeNumber = 1 ; Brake Axis
ClutchNumber = 1 ; Clutch Axis
HandBrakeNumber = 1 ; Handbrake Axis

; Assign Axis
; AHK reads and supports up to 6 axis for a single device (extra axis from the same device will be ignored)
; Each axis represented by a letter: X，Y，Z，R，U，V. Change them accordingly.
Z_Steering = X ; Steering Axis
Z_Throttle = Y ; Throttle Axis
Z_Brake = Z ; Brake Axis
Z_Clutch = R ; Clutch Axis
Z_HandBrake = V  ; Handbrake Axis

; Axis range visibility define
; Number in percentage, 0=0%, 100=100%
; This is basically a Deadzone setting that only affects visually how much range you can see
R_Throttle = 0-100
R_Brake = 0-100
R_Clutch = 0-100
R_HBrake = 0-100

; Whether to reverse Axis display
; 0=no reverse. 1=reverse.
Reverse_Throttle = 1 ; Throttle Axis
Reverse_Brake = 1 ; Brake Axis
Reverse_Clutch = 1 ; Clutch Axis
Reverse_HBrake = 1  ; Handbrake Axis

; Pedal bar size & screen position (in pixel)
PBarX_Pos := 400    ; X position
PBarY_Pos := 50    ; Y position
PBar_Width := 15    ; width
PBar_Height := 100    ; height
PBar_Gap := 3    ; gap between each pedal bar
PBar1X_Pos := PBarX_Pos + PBar_Width + PBar_Gap ; relative position, DO NOT CHANGE
PBar2X_Pos := PBar1X_Pos + PBar_Width + PBar_Gap ; relative position, DO NOT CHANGE
PBar3X_Pos := PBar2X_Pos + PBar_Width + PBar_Gap ; relative position, DO NOT CHANGE

; HUD color (HEX color codes)
ThrottleColor = 7FFF2A ; Throttle
BrakeColor = FF2A2A ; Brake
ClutchColor = 2AD4FF ; Clutch
HBrakeColor = DDDDDD ; Handbrake
PBar_BgColor = 222222    ; Background

; Steering bar size & screen position (in pixel)
SBar_Scale := 4    ; Steering bar length scale (multiplier)
SBar_Height := 10    ; Height
SDotX_Width := 20 ; Steering dot width
SEdge_Width := 3    ; Steering bar edge width
SBarY_Pos := 140    ; Steering bar Y position

; Steering bar auto center position, DO NOT CHANGE
SBar_length := 100 * SBar_Scale + SDotX_Width ; Steering bar length 
SBarX_Pos := A_ScreenWidth/2 - (SBar_length / 2) ; Steering bar X position
SDotX_Pos := A_ScreenWidth/2 - (SBar_length / 2) ; Steering dot default position
SEdgeL_Pos := A_ScreenWidth/2 - (SBar_length / 2) - SEdge_Width    ; Steering bar left edge
SEdgeR_Pos := A_ScreenWidth/2 + (SBar_length / 2)    ; Steering bar right edge
SMidX_Pos := A_ScreenWidth/2 - (SDotX_Width / 2)    ; Steering bar middle position
SMidY_Pos := SBar_Height + SBarY_Pos    ; Steering bar middle position

; Entire HUD(window) size & screen position (in pixel)
; A_ScreenWidth & A_ScreenHeight used to calc relative screen position
HudX_Pos := 0 ; X position
HudY_Pos := A_ScreenHeight - 200 ; Y position
Hud_Width := A_ScreenWidth ; width
Hud_Height := 200 ; height

; ============================================================
; Core stuff begins
; DO NOT CHANGE this section, unless you know what you are doing
SetFormat, FloatFast, 0    ; remove decimal point
Gui, Color, 000002    ; GUI background color, for transparent purpose

Gui, Add, Progress, x%PBarX_Pos% y%PBarY_Pos% w%PBar_Width% h%PBar_Height% c%HBrakeColor% Background%PBar_BgColor% Vertical Range%R_HBrake% vHBrakeBar
Gui, Add, Progress, x%PBar1X_Pos% y%PBarY_Pos% w%PBar_Width% h%PBar_Height% c%ClutchColor% Background%PBar_BgColor% Vertical Range%R_Clutch% vClutchBar
Gui, Add, Progress, x%PBar2X_Pos% y%PBarY_Pos% w%PBar_Width% h%PBar_Height% c%BrakeColor% Background%PBar_BgColor% Vertical Range%R_Brake% vBrakeBar
Gui, Add, Progress, x%PBar3X_Pos% y%PBarY_Pos% w%PBar_Width% h%PBar_Height% c%ThrottleColor% Background%PBar_BgColor% Vertical Range%R_Throttle% vThrottleBar

if (EnableSteeringBar) {
    Gui, Add, Picture, x%SBarX_Pos% y%SBarY_Pos% w%SBar_length% h%SBar_Height%, c_black.png    ; Steering bar image position
    Gui, Add, Picture, x%SMidX_Pos% y%SMidY_Pos% w%SDotX_Width% h%SEdge_Width%, c_orange.png    ; Steering bar middle image position
    Gui, Add, Picture, x0 y%SBarY_Pos% w%SDotX_Width% h%SBar_Height% vSteerDot, c_orange.png    ; Steering dot image position
    Gui, Add, Picture, x%SEdgeL_Pos% y%SBarY_Pos% w%SEdge_Width% h%SBar_Height%, c_orange.png    ; Steering bar left edge image position
    Gui, Add, Picture, x%SEdgeR_Pos% y%SBarY_Pos% w%SEdge_Width% h%SBar_Height%, c_orange.png    ; Steering bar right edge image position
}

Gui -Caption +LastFound +AlwaysOnTop +ToolWindow +E0x20    ; code "E0x20" makes mouse click through HUD window.
WinSet, TransColor, 000002    ; set transparent color, same as GUI background color.
Gui, Show, x%HudX_Pos% y%HudY_Pos% w%Hud_Width% h%Hud_Height%    ; getting HUD size & position
SetTimer, Update, 1    ; script loop speed, higher is slower
Update:
    GetKeyState, SteeringAxis, %SteeringNumber%Joy%Z_Steering%
    GetKeyState, ThrottleAxis, %ThrottleNumber%Joy%Z_Throttle%
    GetKeyState, BrakeAxis, %BrakeNumber%Joy%Z_Brake%
    GetKeyState, ClutchAxis, %ClutchNumber%Joy%Z_Clutch%
    GetKeyState, HBrakeAxis, %HandBrakeNumber%Joy%Z_HandBrake%

    If (Reverse_Throttle = 1)
        Rev_Throttle := 100 - ThrottleAxis
    else
        Rev_Throttle := ThrottleAxis

    If (Reverse_Brake = 1)
        Rev_Brake := 100 - BrakeAxis
    else
        Rev_Brake := BrakeAxis

    If (Reverse_Clutch = 1)
        Rev_Clutch := 100 - ClutchAxis
    else
        Rev_Clutch := ClutchAxis

    If (Reverse_HBrake = 1)
        Rev_HBrake := 100 - HBrakeAxis
    else
        Rev_HBrake := HBrakeAxis

    SteeringAxis *= %SBar_Scale%
    SteeringAxis += %SDotX_Pos%

    GuiControl Move, SteerDot, x%SteeringAxis%
    GuiControl,, ThrottleBar, %Rev_Throttle%
    GuiControl,, BrakeBar, %Rev_Brake%
    GuiControl,, ClutchBar, %Rev_Clutch%
    GuiControl,, HBrakeBar, %Rev_HBrake%
Return
; Core stuff ends
; ============================================================

; Global Hotkey
; # = Win key，^ = Ctrl，! = Alt，+ = Shift. Check AHK help files for details.
#^!r::Reload ; Reload script (Win+Ctrl+Alt+R)
Return
#^!x::ExitApp ; Exit script (Win+Ctrl+Alt+X)
Return
