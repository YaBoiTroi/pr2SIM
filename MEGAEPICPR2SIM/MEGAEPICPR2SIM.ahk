; NEED TO ADD
;-BETTER SETUP/GUI
;-VISUAL RECOGNITION WHEN TO QUIT REG SIM
;-WINSET ALWAYSONTOP FOR MINIMIZE


; features I hope to add
;-GUI for INI options/setup
;-extra mode to allow instances to be minimized during sim idle
;-multi-monitor/multi-display start
;-play around with winset region
;-sysget network, check if sim can even run

;fix
;-weird offset when winRestore a minimized window







;START THE SCRIPT WITH windows + F12. RELOAD THE SCRIPT WITH windows + F11

#Warn ; debugging
#InstallMouseHook
#InstallKeybdHook
#MenuMaskKey vkE8 ; prevents windows menu from activating randomly
#HotkeyModifierTimeout 100
#KeyHistory, 500
#include, FindText.ahk
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Persistent
CoordMode, Pixel, Screen
SendMode Input
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, 3 ; forces perfect title match


; initiate globals, avoids extra paramaters
global accounts:=[{}]
global IDs:=[]
global filePath
global levelID
global savedAccounts:=0
global savedAccountsGet:=False
global whichMonitor
global repeatLoadoutWarning
global pr2Location
global startingWidth
global startingHeight
global titleBarHeight
global borderThickness
global windowSizeGet:=False
global locationx
global locationy
global mydpi
global pr2Monitor
global pr2MonitorLeft
global pr2MonitorRight
global pr2MonitorTop
global pr2MonitorBottom
global desktopWidth
global desktopHeight
global serverInfoURL:="https://pr2hub.com/files/server_status_2.txt" 
global serverList:=["Derron", "Carina", "Grayan","Fitz"] ; stand-in associative array string:a_index
global currentServer:="Derron"
global legal:=False
global bound:=False
global totalRuns:=0
global currentTick:=A_TickCount
global getRewards:=False
global dims
global reboot:=False
global resetConsec:=0
global resetTotal:=0
global delay
global star
global starGot:=False
global simType
global pixelOffset:=10
global timeLost:=0
global currID
setup()
SetControlDelay, 1 ; + (delay//2) ;delay after each controlClick 
SetKeyDelay, 0 , 0 ; delay after text input/key press
SetWinDelay, 0 ; + (delay//2) ; delay after win function (needs testing with other setups)
FindText().BindWindow(0)
return




;Hotkeys!

#F8:: ; toggle windows transparency
	loop, 4 {
		WinGet, transStatus, Transparent, % "ahk_id " . IDs[A_Index]
		if(transStatus=""){
			WinSet, Transparent, 0, % "ahk_id " . IDs[A_Index]
			WinSet, Transparent, on, % "ahk_id " . IDs[A_Index]
		}
		else{
			WinSet, Transparent, 255, % "ahk_id " . IDs[A_Index]
			WinSet, Transparent, off, % "ahk_id " . IDs[A_Index]
		}
	}
return

#F9::
    MsgBox, See you soon! Go use those shiny new ranks!
	;try{
		;WinSet, AlwaysOnTop , Off, % "ahk_id " currID
	;}
	FindText().BindWindow(0)
	Loop, 4{
		WinClose, % "ahk_id " . IDs[A_Index]
	}
    ExitApp
#F10::
	try{
	WinGet, ExStyle, ExStyle, % "ahk_id " currID
	}
	;if (ExStyle & 0x8){  ; 0x8 is WS_EX_TOPMOST.
	;	WinSet, AlwaysOnTop , Off, % "ahk_id " currID
	;	ontop:=true
	;}
    Pause, Toggle
	;if (ontop){  ; 0x8 is WS_EX_TOPMOST.
		;WinSet, AlwaysOnTop , On, % "ahk_id " currID
		;ontop:=false
	;}
    return
#F11::
	FindText().BindWindow(0)
	Loop, 4{
		WinClose, % "ahk_id " . IDs[A_Index]
	}
    Reload ; reloads the script. Just close your pr2 instances if you want to start again, then hit F12
    return

;showHotkeys:
#h::
    if(!legal){
        return
    }
    MsgBox,, Silly goose forgot the hotkeys`?, Windows+F12`: begin the sim`nWindows+F11: reload the script`nWindows+F10: pause the script`nWindows+F9: end the script`nWindows+h: show all hotkeys
    return
#F12::  ;basically does everything for you once you hit f12..
	Loop{
		if(!legal){
			return
		}
		if(resetConsec>2){
			SysGet, internetCheck, 63
			internetStatus:=Mod(internetCheck, 2)
			if(!internetStatus){
				While(!internetStatus){
					MsgBox, 0, Dangit!, Your internet is down! What the heck dude! We will try again later, I guess..., 30
					SysGet, internetCheck, 63
					internetStatus:=Mod(internetCheck, 2)
				}
			}
		;	MsgBox, 0, Donezo.., Something is SERIOUSLY messed up.. are the servers down?`n`nThe script will now close
		;	Loop, 4{
		;		WinClose, % "ahk_id " . IDs[A_Index]
		;	}
		;	ExitApp
		}
		bootInstances() ;load all instances
		if(reboot){
			Continue
		}
		checkHappyHour() ; checks for happy hour
		if(reboot){
			Continue
		}
		loginSome() ;logs all 4 accounts in
		if(reboot){
			Continue
		}
		levelPrep() ; finds sim level
		if(reboot){
			Continue
		}
		Loop{ ; begins macro
			if(simType=3){
				macro()
			}
			else{
				macroExperimental() 
			}
			if(reboot){
				break
			}
		}
	}

; Contains everything to upkeep the sim after initial setup
macro(){
	if(checkHappyHour()){
		loginSome(True) 
		Sleep, 7500
	}
	;FindTheseTexts(star,, True, delay, 5, "Level queue")
    FindTheseTexts(  "|<>*164$26.00U000800030000k000Q00070001k000S000DU0y3w7rzzzkTzzs3zzs0Dzw01zw00Ty007zk01zw00zT00DXs03kS01s3k0M0A0A01020088",, True, delay, 5, "Level queue",631,556,657,581,,False,,True)
	if(reboot){
		return
	}
	;FindTheseTexts("|<>*126$50.zz0M0000Dzw600003U3VU0000s0MM0000C07600003U1lUDkM3s0QMDy70y07671lkDU1VVUAA6s1sM0331jzw603ksPzw1UTw6As00MTn1XC00670kQnU01XUA3Ms00Mk70qC006C1kDXU01XVw1ss00MTv0QC0063ss700000000k0000000M000000060000000300000003k0000000s2",,, delay, 5, "level play",382,480,432,560)
	Loop, 4{
		Switch A_Index {
			case 1:
				FindThisText("|<>*106$79.0007k000000000003s000000000001w000000000000y000000000000T00000000000000000000000000000000000T7s3sDXw0Dzw7zjy1w7rz0Dzy3zzzUy3zzkDzz1zzzkT1zzsDzzUzy3sDUz1w7sDkTy1y7kT0z3s7sDz0z3sDUTVw3w0DUTVw7kDky1y07kDky3s7sT0z03s7sT1w3wDUTU1w3wDUy1y7kDk0y1y7kT0z3w7sDz0z3sDUTVzjw7zUTVw7kDkTzy3zkDky3s7sDzz1zs7sT1w3w3zTUzw3wDUy1y0CDUT00000000007k0000000000U7s0000000000Tzw0000000000Dzw00000000007zw00000000003zw00U", IDs[1],,1, True,5, delay, "level play",35,.6,.6,"wait0",,295,586,374,616,,,30) ; level play
				if(reboot){
					break
				}
			case 2:
				FindThisText("|<>*182$30.07zs00Tzw00zzz01zzzU3zzzk7zzzkDzzzsDzzzwTzzzwTzzzyTzzzyzzzzyzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzyTzzzyTzzzwDzzzwDzzzs7zzzk3zzzU1zzz00zzy00Dzw003zU0U", IDs[A_Index],,-1, True,5, delay+5 , "level play",10,.6,.6,"wait0",,444,484,474,515,,,,0) ; level play
				if(reboot){
					break
				}
			case 3:
				FindThisPixel(0xEFE1A4,IDs[3],630,450,630,450,10,True,,,," wait for p4 to join queue")
				FindThisText("|<>*182$30.07zs00Tzw00zzz01zzzU3zzzk7zzzkDzzzsDzzzwTzzzwTzzzyTzzzyzzzzyzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzyTzzzyTzzzwDzzzwDzzzs7zzzk3zzzU1zzz00zzy00Dzw003zU0U", IDs[A_Index],,1, True,5, delay+5 , "level play",30,.6,.6,"wait0",,444,484,474,515,,,,0) ; level play
				if(reboot){
					break
				}
			case 4:
				FindThisText("|<>*182$30.07zs00Tzw00zzz01zzzU3zzzk7zzzkDzzzsDzzzwTzzzwTzzzyTzzzyzzzzyzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzyTzzzyTzzzwDzzzwDzzzs7zzzk3zzzU1zzz00zzy00Dzw003zU0U", IDs[A_Index],,1, True,5, delay +5 , "level play",60,.6,.6,"wait0",,444,484,474,515,,,,0) ; level play
				if(reboot){
					break
				}
			}
	}
	if(reboot){
		return
	}
	Sleep, delay + 15
	shout()
	;Sleep, 58000
	Sleep, 117500-timeLost ; Sleep till 1:58 (big exp)
	FindThisText("|<>**10$135.03zzzzzzzzzzzzzzzzzzy00Tzzzzzzzzzzzzzzzzzzzzk7zzzzzzzzzzzzzzzzzzzzz1zU0000000000000000007wS000000000000000000003nU00000000000000000000Cs000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z00000003zU000S60000007s0000000zz0003lk000000z0000000TXw0000C0000007s0000003k3k0001k000000z0000000w0D0000C0000007s000000D01sQ3Xry000000z0000001s073UQSzk000007s000000C00wQ3Xlk000000z0000001k07XUQSC0000007s000000C00wQ3Xlk000000z0000001k07XUQSC0000007s000000C00wQ3Xlk000000z0000001k07XUQSC0000007s000000D00sQ3Xlk000000z0000000s6D3UQSC0000007s0000007UxsQ3Xlk000000z0000000S7y3UwSC0000007s0000001wRUTDXls000000z00000007zz1zwSDk000007s0000000Tzw7vXky000000z0000000007U00000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000zU00000000000000000000Dw000000000000000000001vk00000000000000000000STU0000000000000000000Dlzzzzzzzzzzzzzzzzzzzzzw3zzzzzzzzzzzzzzzzzzzzy07zzzzzzzzzzzzzzzzzzzz0U", IDs[1],,, True,5, delay+10, "quit 1",,,,,,1070,922,1205,978) ;quit1
	if(reboot){
		return
	}
	Sleep, delay + 15
	ControlSend,, {Space down}, % "ahk_id " . IDs[2] ;slash2
	Sleep, 75 + (delay//5)
	ControlSend,, {Space up}, % "ahk_id " . IDs[2]
	Sleep, 2650 ;wait for dude 2
	FindThisText("|<>**10$135.03zzzzzzzzzzzzzzzzzzy00Tzzzzzzzzzzzzzzzzzzzzk7zzzzzzzzzzzzzzzzzzzzz1zU0000000000000000007wS000000000000000000003nU00000000000000000000Cs000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z00000003zU000S60000007s0000000zz0003lk000000z0000000TXw0000C0000007s0000003k3k0001k000000z0000000w0D0000C0000007s000000D01sQ3Xry000000z0000001s073UQSzk000007s000000C00wQ3Xlk000000z0000001k07XUQSC0000007s000000C00wQ3Xlk000000z0000001k07XUQSC0000007s000000C00wQ3Xlk000000z0000001k07XUQSC0000007s000000D00sQ3Xlk000000z0000000s6D3UQSC0000007s0000007UxsQ3Xlk000000z0000000S7y3UwSC0000007s0000001wRUTDXls000000z00000007zz1zwSDk000007s0000000Tzw7vXky000000z0000000007U00000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000zU00000000000000000000Dw000000000000000000001vk00000000000000000000STU0000000000000000000Dlzzzzzzzzzzzzzzzzzzzzzw3zzzzzzzzzzzzzzzzzzzzy07zzzzzzzzzzzzzzzzzzzz0U", IDs[2],,, True,5, delay+10, "quit 2",,,,,,1070,922,1205,978) ;quit 2
	if(reboot){
		return
	}
	Sleep, delay + 15
	ControlSend,, {Space down}, % "ahk_id " . IDs[3] ; slash 3
	Sleep, 75 + (delay//5)
	ControlSend,, {Space up}, % "ahk_id " . IDs[3] 
	Sleep, 2750 ; wait for dude 3
	FindThisText("|<>**10$135.03zzzzzzzzzzzzzzzzzzy00Tzzzzzzzzzzzzzzzzzzzzk7zzzzzzzzzzzzzzzzzzzzz1zU0000000000000000007wS000000000000000000003nU00000000000000000000Cs000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z00000003zU000S60000007s0000000zz0003lk000000z0000000TXw0000C0000007s0000003k3k0001k000000z0000000w0D0000C0000007s000000D01sQ3Xry000000z0000001s073UQSzk000007s000000C00wQ3Xlk000000z0000001k07XUQSC0000007s000000C00wQ3Xlk000000z0000001k07XUQSC0000007s000000C00wQ3Xlk000000z0000001k07XUQSC0000007s000000D00sQ3Xlk000000z0000000s6D3UQSC0000007s0000007UxsQ3Xlk000000z0000000S7y3UwSC0000007s0000001wRUTDXls000000z00000007zz1zwSDk000007s0000000Tzw7vXky000000z0000000007U00000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000zU00000000000000000000Dw000000000000000000001vk00000000000000000000STU0000000000000000000Dlzzzzzzzzzzzzzzzzzzzzzw3zzzzzzzzzzzzzzzzzzzzy07zzzzzzzzzzzzzzzzzzzz0U", IDs[3],,, True,5, delay+10, "quit 3",,,,,,1070,922,1205,978) ;quit 3
	if(reboot){
		return
	}
	Sleep, delay + 15
	ControlSend,, {Space down}, % "ahk_id " . IDs[4] ;slash 4
	Sleep, 75 + (delay//5)
	ControlSend,, {Space up}, % "ahk_id " . IDs[4]
	Sleep, 2850 ;wait for dude 4
	FindThisText("|<>**10$135.03zzzzzzzzzzzzzzzzzzy00Tzzzzzzzzzzzzzzzzzzzzk7zzzzzzzzzzzzzzzzzzzzz1zU0000000000000000007wS000000000000000000003nU00000000000000000000Cs000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z00000003zU000S60000007s0000000zz0003lk000000z0000000TXw0000C0000007s0000003k3k0001k000000z0000000w0D0000C0000007s000000D01sQ3Xry000000z0000001s073UQSzk000007s000000C00wQ3Xlk000000z0000001k07XUQSC0000007s000000C00wQ3Xlk000000z0000001k07XUQSC0000007s000000C00wQ3Xlk000000z0000001k07XUQSC0000007s000000D00sQ3Xlk000000z0000000s6D3UQSC0000007s0000007UxsQ3Xlk000000z0000000S7y3UwSC0000007s0000001wRUTDXls000000z00000007zz1zwSDk000007s0000000Tzw7vXky000000z0000000007U00000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000zU00000000000000000000Dw000000000000000000001vk00000000000000000000STU0000000000000000000Dlzzzzzzzzzzzzzzzzzzzzzw3zzzzzzzzzzzzzzzzzzzzy07zzzzzzzzzzzzzzzzzzzz0U", IDs[4],,, True,5, delay+10, "quit 4",,,,,,1070,922,1205,978) ;quit 4
	if(reboot){
		return
	}
	Sleep, delay + 15
	FindTheseTexts("|<>*171$39.000E000002000000M000003000000s000007000000w000007U00000w00000Dk00001y00000Dk00001y00000Ts00zk3z0Dtzzzzzy7zzzzz0Tzzzzk0zzzzw01zzzy007zzzU00Dzzk000zzw0007zz0000zzs0007zz0001zzw000DzzU003zjy000Tszk003w1z000z07s007k0T000w01w00D003U01k00C00M000k0200020U",,, delay, 5, "return to lobby",869,719,908,757,,,True) ; return to lobby
	if(reboot){
		return
	}
	Sleep, delay + 15
	totalRuns++
	resetConsec:=0
	;repeat
	
}

;big boy sim for big boys
macroExperimental(){
	if(checkHappyHour()){
		loginSome(True) 
		Sleep, 7500
	}
    FindTheseTexts(  "|<>*164$26.00U000800030000k000Q00070001k000S000DU0y3w7rzzzkTzzs3zzs0Dzw01zw00Ty007zk01zw00zT00DXs03kS01s3k0M0A0A01020088",, True, delay, 5, "Level queue",631,556,657,581,,,,True)
	if(reboot){
		return
	}
	Sleep, delay + 15
	Loop, 4{
		Switch A_Index {
			case 1:
				FindThisText("|<>*106$79.0007k000000000003s000000000001w000000000000y000000000000T00000000000000000000000000000000000T7s3sDXw0Dzw7zjy1w7rz0Dzy3zzzUy3zzkDzz1zzzkT1zzsDzzUzy3sDUz1w7sDkTy1y7kT0z3s7sDz0z3sDUTVw3w0DUTVw7kDky1y07kDky3s7sT0z03s7sT1w3wDUTU1w3wDUy1y7kDk0y1y7kT0z3w7sDz0z3sDUTVzjw7zUTVw7kDkTzy3zkDky3s7sDzz1zs7sT1w3w3zTUzw3wDUy1y0CDUT00000000007k0000000000U7s0000000000Tzw0000000000Dzw00000000007zw00000000003zw00U", IDs[1],,1, True,5, delay + 15, "level play",50,,,"wait0",,295,586,374,616,,,30,,False) ; level play
				if(reboot){
					break
				}
				
			case 2:
				FindThisText("|<>AFAC94@0.97$30.07zk00Tzw00zzy01zzzU3z0zU7s07kDs03sDs41wTtzVwTzzVyTzzVyTzzVyzzz1yzzy3yzzw7yzzkDzzzUTzzzVzyzzVzyTzVzyTzVzwDzzzwDzzzs7zVzs3zVzk3zVzU0zzy00Tzw007zs000z00U", IDs[A_Index],,-1, True,5, delay + 15, "level play",10,,,"wait0",,444,484,474,514,,,,0) ; level play
				;FindThisText("|<>*182$30.07zs00Tzw00zzz01zzzU3zzzk7zzzkDzzzsDzzzwTzzzwTzzzyTzzzyzzzzyzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzyTzzzyTzzzwDzzzwDzzzs7zzzk3zzzU1zzz00zzy00Dzw003zU0U", IDs[A_Index],,-1, True,5, delay + 15, "level play",10,.6,.6,"wait0",,444,484,474,515,,,,0) ; level play
				if(reboot){
					break
				}
				
			case 3:
				;FindThisPixel(0xEFE1A4,IDs[3],630,450,630,450,10,True,,,," wait for p4 to join queue")
				FindThisText("|<>AFAC94@0.97$30.07zk00Tzw00zzy01zzzU3z0zU7s07kDs03sDs41wTtzVwTzzVyTzzVyTzzVyzzz1yzzy3yzzw7yzzkDzzzUTzzzVzyzzVzyTzVzyTzVzwDzzzwDzzzs7zVzs3zVzk3zVzU0zzy00Tzw007zs000z00U", IDs[A_Index],,1, True,5, delay + 15, "level play",30,,,"wait0",,444,484,474,514,,,,0) 
				;FindThisText("|<>*182$30.07zs00Tzw00zzz01zzzU3zzzk7zzzkDzzzsDzzzwTzzzwTzzzyTzzzyzzzzyzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzyTzzzyTzzzwDzzzwDzzzs7zzzk3zzzU1zzz00zzy00Dzw003zU0U", IDs[A_Index],,1, True,5, delay + 15, "level play",30,,"wait0",,444,484,474,515,,,,0) ; level play
				if(reboot){
					break
				}
				
			case 4:
				FindThisText("|<>AFAC94@0.97$30.07zk00Tzw00zzy01zzzU3z0zU7s07kDs03sDs41wTtzVwTzzVyTzzVyTzzVyzzz1yzzy3yzzw7yzzkDzzzUTzzzVzyzzVzyTzVzyTzVzwDzzzwDzzzs7zVzs3zVzk3zVzU0zzy00Tzw007zs000z00U", IDs[A_Index],,1, True,5, delay + 15, "level play",70,,,"wait0",,444,484,474,514,,,,0) 
				;FindThisText("|<>*182$30.07zs00Tzw00zzz01zzzU3zzzk7zzzkDzzzsDzzzwTzzzwTzzzyTzzzyzzzzyzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzyTzzzyTzzzwDzzzwDzzzs7zzzk3zzzU1zzz00zzy00Dzw003zU0U", IDs[A_Index],,1, True,5, delay + 15, "level play",70,,,"wait0",,444,484,474,515,,,,0) ; level play
				
				
			}
		
	}
	if(reboot){
		return
	}

	Sleep, delay + 15
	timeLost:=0
	shout()
	;Sleep, 58000
	Sleep, 117500-timeLost ; Sleep till 2 minutes (big exp)
	FindThisText("|<>**10$135.03zzzzzzzzzzzzzzzzzzy00Tzzzzzzzzzzzzzzzzzzzzk7zzzzzzzzzzzzzzzzzzzzz1zU0000000000000000007wS000000000000000000003nU00000000000000000000Cs000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z00000003zU000S60000007s0000000zz0003lk000000z0000000TXw0000C0000007s0000003k3k0001k000000z0000000w0D0000C0000007s000000D01sQ3Xry000000z0000001s073UQSzk000007s000000C00wQ3Xlk000000z0000001k07XUQSC0000007s000000C00wQ3Xlk000000z0000001k07XUQSC0000007s000000C00wQ3Xlk000000z0000001k07XUQSC0000007s000000D00sQ3Xlk000000z0000000s6D3UQSC0000007s0000007UxsQ3Xlk000000z0000000S7y3UwSC0000007s0000001wRUTDXls000000z00000007zz1zwSDk000007s0000000Tzw7vXky000000z0000000007U00000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000zU00000000000000000000Dw000000000000000000001vk00000000000000000000STU0000000000000000000Dlzzzzzzzzzzzzzzzzzzzzzw3zzzzzzzzzzzzzzzzzzzzy07zzzzzzzzzzzzzzzzzzzz0U", IDs[1],,, True,5, delay+10, "quit 1",,,,,,1070,922,1205,978) ;quit 1
	if(reboot){
		return
	}
	Sleep, delay + 15

;begin person 2
	ControlSend,, {Space down}, % "ahk_id " . IDs[2] ;
	Sleep, 75 + (delay//5)								  ; slash 2
	ControlSend,, {Space up}, % "ahk_id " . IDs[2]   ;
	Sleep, 275
	;FindThisPixel(0xFEF4FA, IDs[2],890,540,910,560,15,,,,True,"wait hat instance 2") ; wait for hat 2
	currentTime:=A_TickCount
	while(FindThisPixel(0x453A36,IDs[2],913,578,917,582,5,,,,False, " wait hat instance 2")){
		if(A_TickCount-currentTime>5000){
			reboot("wait hat instance 2",IDs[2])
			break
		}
	}
	if(reboot){
		return
	}
	Sleep, delay + 15
	ControlSend,, {Up down}{Right down}, % "ahk_id " . IDs[2] ; start move 2
	Sleep, delay + 15
	FindThisText("|<>*108$102.00000T0000000003U00007zs00000000TU0000zbw00000003zU0003y1y0000000zzk000DU0D0000007zvk001k007000000zy1s0zw0007U0000DzU1s1zs0007U0001zs00w1zU0203k000Dy000w1z007U3k001zU000S3y007k3k00Ts0000T3w007E1k03w00001z3w00301k0T00000Dz7s00300s7k00000zz7s003k0sw000007zy7k001s0y000000zzUDk001s0s000003zy0Dk001s0E00000Tzk0Tk001s0000003zy00Tk000s000000Dzs00Tk000k000001zz000Tk000000000Dzs000Tk000000000zz0000Tk000000007zw0000Tk00000000zzU0000Tk00000007zw00000Tk0000000TzU00000Tk0000003zy000000Tk000000Tzk000000Tk000001zy0000000Tk00000Dzk0000000Tk00001zz00000000Tk00007zs00000000Tk0000zz000000000Tk0007zs000000000Tk000zzU000000000Tk003zw0000000000Tk00DzU0000000000Tk00Tz00000000000TU00Tz00000000000TU03zk00000000000TU03s000000000000TU07s000000000000Tk07s000000000000zk07s000000000000zk07s000000000000yk07s000000000000wk07s000000000000zU07s000000000000zU07s000000000000zU07s000000000000zU07w000000000000zU07w000000000000zU07w000000000000zU07w000000000000zU07w000000000000z007w000000000000z007w000000000000z007w000000000000z00Tw000000000000z00Ls000000000000z00bs000000000000z00js000000000000z01Tk000000000000z01zU000000000000z03z0000000000000z07z0000000000000z0Dy0000000000000z0Tw0000000000000z0zs0000000000000z1zk0000000000000T3zk0000000000000TDzU0000000000000Tzz00000000000000Tzy00000000000000Tzw00000000000000Tzk00000000000000DzU00000000000000Cz000000000000000Dw0000000000000007k00000000000000030000000000000000U", IDs[2],,,,5,delay, "gun wait instance 2",,,,,,21,35,123,117,false) ; wait for gun 2
	if(reboot){
		return
	}
	Sleep, delay + 150
	ControlSend,, {Left Down}{Space down}{Down down}{Up up}, % "ahk_id " . IDs[2] ; 
	Sleep, 50 + (delay//5)													; gun back 2
	ControlSend,, {Left Up}{Space up}{Up down}{Down up}, % "ahk_id " . IDs[2] 	 ;
	Sleep, delay + 15
	FindThisPixel(0xBD7B6A, IDs[2],730,545,770,555,8,,,1,True,"hit wall instance 2") ; wait for wall dude 2
	if(reboot){
		return
	}
	Sleep, delay + 15
    ControlSend,,{Down down}, % "ahk_id " . IDs[2] ; stop move 2, get down
	Sleep, 100 + (delay*3)
	ControlSend,, {Down up}{Up up}{Right up}, % "ahk_id " . IDs[2]
	Sleep, delay + 15
	FindThisText("|<>**10$135.03zzzzzzzzzzzzzzzzzzy00Tzzzzzzzzzzzzzzzzzzzzk7zzzzzzzzzzzzzzzzzzzzz1zU0000000000000000007wS000000000000000000003nU00000000000000000000Cs000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z00000003zU000S60000007s0000000zz0003lk000000z0000000TXw0000C0000007s0000003k3k0001k000000z0000000w0D0000C0000007s000000D01sQ3Xry000000z0000001s073UQSzk000007s000000C00wQ3Xlk000000z0000001k07XUQSC0000007s000000C00wQ3Xlk000000z0000001k07XUQSC0000007s000000C00wQ3Xlk000000z0000001k07XUQSC0000007s000000D00sQ3Xlk000000z0000000s6D3UQSC0000007s0000007UxsQ3Xlk000000z0000000S7y3UwSC0000007s0000001wRUTDXls000000z00000007zz1zwSDk000007s0000000Tzw7vXky000000z0000000007U00000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000zU00000000000000000000Dw000000000000000000001vk00000000000000000000STU0000000000000000000Dlzzzzzzzzzzzzzzzzzzzzzw3zzzzzzzzzzzzzzzzzzzzy07zzzzzzzzzzzzzzzzzzzz0U", IDs[2],,, True,5, delay+10, "quit 2",,,,,,1070,922,1205,978) ;quit 2
	if(reboot){
		return
	}
	Sleep, delay + 15

;begin person 3
	ControlSend,, {Space down}, % "ahk_id " . IDs[3] ;
	Sleep, 75 + (delay//5)										  ; slash 3
	ControlSend,, {Space up}, % "ahk_id " . IDs[3]   ;
	Sleep, 275
    ;FindThisPixel(0xFEF4FA, IDs[3],890,540,910,560,15,,,,True,"wait hat instance 3") ; wait for hat 3
	currentTime:=A_TickCount
	while(FindThisPixel(0x453A36,IDs[3],913,578,917,582,5,,,,False, " wait hat instance 3")){
		if(A_TickCount-currentTime>5000){
			reboot("wait hate instance 3",IDs[3])
			break
		}
	}
    if(reboot){
		return
	}
	Sleep, delay + 15
	ControlSend,, {Up down}{Right down}, % "ahk_id " . IDs[3] ; start move 3
	FindThisText("|<>*108$102.00000T0000000003U00007zs00000000TU0000zbw00000003zU0003y1y0000000zzk000DU0D0000007zvk001k007000000zy1s0zw0007U0000DzU1s1zs0007U0001zs00w1zU0203k000Dy000w1z007U3k001zU000S3y007k3k00Ts0000T3w007E1k03w00001z3w00301k0T00000Dz7s00300s7k00000zz7s003k0sw000007zy7k001s0y000000zzUDk001s0s000003zy0Dk001s0E00000Tzk0Tk001s0000003zy00Tk000s000000Dzs00Tk000k000001zz000Tk000000000Dzs000Tk000000000zz0000Tk000000007zw0000Tk00000000zzU0000Tk00000007zw00000Tk0000000TzU00000Tk0000003zy000000Tk000000Tzk000000Tk000001zy0000000Tk00000Dzk0000000Tk00001zz00000000Tk00007zs00000000Tk0000zz000000000Tk0007zs000000000Tk000zzU000000000Tk003zw0000000000Tk00DzU0000000000Tk00Tz00000000000TU00Tz00000000000TU03zk00000000000TU03s000000000000TU07s000000000000Tk07s000000000000zk07s000000000000zk07s000000000000yk07s000000000000wk07s000000000000zU07s000000000000zU07s000000000000zU07s000000000000zU07w000000000000zU07w000000000000zU07w000000000000zU07w000000000000zU07w000000000000z007w000000000000z007w000000000000z007w000000000000z00Tw000000000000z00Ls000000000000z00bs000000000000z00js000000000000z01Tk000000000000z01zU000000000000z03z0000000000000z07z0000000000000z0Dy0000000000000z0Tw0000000000000z0zs0000000000000z1zk0000000000000T3zk0000000000000TDzU0000000000000Tzz00000000000000Tzy00000000000000Tzw00000000000000Tzk00000000000000DzU00000000000000Cz000000000000000Dw0000000000000007k00000000000000030000000000000000U",IDs[3],,,,5,delay, "gun wait instance 3",,,,,,21,35,123,117,false) ; wait for gun 3
	if(reboot){
		return
	}
	Sleep, delay + 150
	ControlSend,, {Left down}{Space down}{Down down}{Up up}, % "ahk_id " . IDs[3] ; 
	Sleep, 50 + (delay//5)												 ; gun back 3
	ControlSend,, {Left Up}{Space up}{Up down}{Down up}, % "ahk_id " . IDs[3] 	 ;
	Sleep, delay + 15
	FindThisPixel(0xBD7B6A, IDs[3],730,550,770,550,5,,,1,True,"hit wall instance 3") ; wait for wall dude 3
	if(reboot){
		return
	}
	Sleep, delay + 15
    ControlSend,, {Down down}, % "ahk_id " . IDs[3] ; stop move 3, get down
	Sleep, 100 + (delay*3)
	ControlSend,, {Down up}{Up up}{Right up}, % "ahk_id " . IDs[3]
	Sleep, delay + 15
	FindThisText("|<>**10$135.03zzzzzzzzzzzzzzzzzzy00Tzzzzzzzzzzzzzzzzzzzzk7zzzzzzzzzzzzzzzzzzzzz1zU0000000000000000007wS000000000000000000003nU00000000000000000000Cs000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z00000003zU000S60000007s0000000zz0003lk000000z0000000TXw0000C0000007s0000003k3k0001k000000z0000000w0D0000C0000007s000000D01sQ3Xry000000z0000001s073UQSzk000007s000000C00wQ3Xlk000000z0000001k07XUQSC0000007s000000C00wQ3Xlk000000z0000001k07XUQSC0000007s000000C00wQ3Xlk000000z0000001k07XUQSC0000007s000000D00sQ3Xlk000000z0000000s6D3UQSC0000007s0000007UxsQ3Xlk000000z0000000S7y3UwSC0000007s0000001wRUTDXls000000z00000007zz1zwSDk000007s0000000Tzw7vXky000000z0000000007U00000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000zU00000000000000000000Dw000000000000000000001vk00000000000000000000STU0000000000000000000Dlzzzzzzzzzzzzzzzzzzzzzw3zzzzzzzzzzzzzzzzzzzzy07zzzzzzzzzzzzzzzzzzzz0U", IDs[3],,, True,5, delay+10, "quit 3",,,,,,1070,922,1205,978) ;quit 3
	if(reboot){
		return
	}
	Sleep, delay + 15

;begin person 4
	ControlSend,, {Space down}, % "ahk_id " . IDs[4] ;
	Sleep, 75 + (delay//5)										  ; slash 4
	ControlSend,, {Space up}, % "ahk_id " . IDs[4]   ;
	Sleep, 275
    ;FindThisPixel(0xFEF4FA, IDs[4],890,540,910,560,15,,,,True,"wait hat instance 4") ; wait for hat 4
    currentTime:=A_TickCount
	while(FindThisPixel(0x453A36,IDs[4],913,578,917,582,5,,,,False, " wait hat instance 4")){
		if(A_TickCount-currentTime>5000){
			reboot("wait hate instance 4",IDs[4])
			break
		}
	}
	if(reboot){
		return
	}
	Sleep, delay + 15
	ControlSend,, {Up down}{Right down}, % "ahk_id " . IDs[4] ; move 4
	Sleep, delay + 15
	FindThisText("|<>*108$102.00000T0000000003U00007zs00000000TU0000zbw00000003zU0003y1y0000000zzk000DU0D0000007zvk001k007000000zy1s0zw0007U0000DzU1s1zs0007U0001zs00w1zU0203k000Dy000w1z007U3k001zU000S3y007k3k00Ts0000T3w007E1k03w00001z3w00301k0T00000Dz7s00300s7k00000zz7s003k0sw000007zy7k001s0y000000zzUDk001s0s000003zy0Dk001s0E00000Tzk0Tk001s0000003zy00Tk000s000000Dzs00Tk000k000001zz000Tk000000000Dzs000Tk000000000zz0000Tk000000007zw0000Tk00000000zzU0000Tk00000007zw00000Tk0000000TzU00000Tk0000003zy000000Tk000000Tzk000000Tk000001zy0000000Tk00000Dzk0000000Tk00001zz00000000Tk00007zs00000000Tk0000zz000000000Tk0007zs000000000Tk000zzU000000000Tk003zw0000000000Tk00DzU0000000000Tk00Tz00000000000TU00Tz00000000000TU03zk00000000000TU03s000000000000TU07s000000000000Tk07s000000000000zk07s000000000000zk07s000000000000yk07s000000000000wk07s000000000000zU07s000000000000zU07s000000000000zU07s000000000000zU07w000000000000zU07w000000000000zU07w000000000000zU07w000000000000zU07w000000000000z007w000000000000z007w000000000000z007w000000000000z00Tw000000000000z00Ls000000000000z00bs000000000000z00js000000000000z01Tk000000000000z01zU000000000000z03z0000000000000z07z0000000000000z0Dy0000000000000z0Tw0000000000000z0zs0000000000000z1zk0000000000000T3zk0000000000000TDzU0000000000000Tzz00000000000000Tzy00000000000000Tzw00000000000000Tzk00000000000000DzU00000000000000Cz000000000000000Dw0000000000000007k00000000000000030000000000000000U", IDs[4],,,,5,delay, "gun wait instance 4",,,,,,21,35,123,117,false) ; wait for gun 4
	if(reboot){
		return
	}
	Sleep, delay + 150
	ControlSend,, {Left Down}{Space down}{Down down}{Up up}, % "ahk_id " . IDs[4] ; 
	Sleep, 50 + (delay//5)											 ; gun back 4
	ControlSend,, {Left up}{Space up}{Up down}{Down up}, % "ahk_id " . IDs[4] 	 ;
	Sleep, delay + 15
	
	;sim 1 ending
	if(simType=1){
		currentTime:=A_TickCount
		Loop, {
			if(FindThisText("|<>*97$26.0Dz00Dzw07zzU3zzw1zzzUzzzwDzzz7zzztzzzyTzzzbzzztzzzyTzzzbzzztzzzyTzzzbzzzszzzwDzzz1zzzUDzzk1zzs0Dzw00zw000A0000000000000000000000000000000000000000000000000000001zU01zy01zzk0zzz0Dzzk7zzy3zzzkzzzyTzzzbzzztzzzyTzzzbzzztzzzyTzzzbzzztzzzyDzzz3zzzkTzzs7zzy0zzz03zz00TzU01zU0000000000000000000000000000000000000000000000000000000000Dz00Dzw07zzU3zzw1zzzUzzzwDzzz7zzztzzzyTzzzjzzzzzzzzzzzzzzzzxzzzyTzzzbzzzszzzwDzzz1zzzUDzzk1zzs0Dzw00zw003w08", Ids[4],,,,.1,delay+5,"wait for gun reload",,,,,False,137,18,163,118, False)){
				
				ControlSend,, {Left Down}{Space down}, % "ahk_id " . IDs[4] ;
				Sleep, 50 + (delay*2)													 ; gun back 4 (repeat till finish)
				ControlSend,, {Left Up}{Space up}, % "ahk_id " . IDs[4] 
			}
			Sleep, delay + 15
			if(FindThisText("|<>*215$251.01zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz003zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzy0Tzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz1w000000000000000000000000000000000000000T3U000000000000000000000000000000000000000CC0000000000000000000000000000000000000000CQ0000000000000000000000000000000000000000Rk0000000000000000000000000000000000000000TU0000000000000000000000000000000000000000z00000000000000000000000000000000000000001y00000000000000000000000000000000000000003w00000000000000000000000000000000000000007s0000000000000000000000000000000000000000Dk0000000000000000000000000000000000000000TU0000000000000000000000000000000000000000z00000000000000000000000000000000000000001y00000000000000000000000000000000000000003w00000000000000000000000000000000000000007s0000000000000000000000000000000000000000Dk0007zy0006000000000k0000s0000Q01k0000000TU000Dzy000Q000000003U0001k0000s03U0000000z0000Q0y000s00000000700003U0001k0700000001y0000s0w001k00000000C0000700003U0C00000003w0001k0s003U00000000Q0000C0000700Q00000007s0003U1kDsTtkCCyvw03z3y00Q00TkCz0vwD0s000Dk000703UzsznUQTtzw07yDy00s01zkTz1zwC3k000TU000C0D3lsQ70syHtw03UwS01k07XkzD3wwQ70000z0000Q1yD1ssC1ls7Us073kS03U0S3lsD7UwwC0001y0000zzsQ1lkQ3XkC1k0C70Q0700s3XUCC0ssw0003w0001zz0s3XUs77UQ3U0QC0s0C01k770QQ1llk0007s0003Vw1zz71kCD0s700sQ1k0Q03UCC0ss3XnU000Dk00070w3zyC3UQS1kC01ks3U0s070QQ1lk73j0000TU000C0w700Q70sw3UQ03Vk701k0C0ss3XUC7Q0000z0000Q1wC00sC1ls70s073UC03U0Q1lk770QDs0001y0000s1sQ01kQ3XkC1k0C70Q0700s3XUCC0sDk0003w0001k1sw3XUsD7UQ3U0QD1s0C01sD7UwS3kT00007s0003U3syT7VwyD0s700wD7U0Q01swDbkyT0y0000Dk000703kzwDlzwS1kC01yDy00zzlzkTz1zw0w0000TU000C03kzkDVysw3UQ01wDs01zzVz0vw3jk1k0000z000000000000000000000000000000000003U0001y00000000000000000000000000000000000700003w00000000000000000000000000000000000Q00007s00000000000000000000000000000000001s0000Dk0000000000000000000000000000000000DU0000TU0000000000000000000000000000000000S00000z00000000000000000000000000000000000000001y00000000000000000000000000000000000000003y0000000000000000000000000000000000000000Dw0000000000000000000000000000000000000000Ss0000000000000000000000000000000000000000ts0000000000000000000000000000000000000003ns0000000000000000000000000000000000000007Xw000000000000000000000000000000000000001y3zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs3zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU1zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw2", IDs[4],,, True,.1, delay, "look for return outfit sim",,.4,.4,,False,707,802,958,858,False)){ ; look for return button appearing)
				break
			}
			if((A_TickCount-currentTime)>10000){
				reboot("return to lobby button",IDs[4])
				return
			}
		} 
		
	}

	;add check for something to quit INSTANTLY
	;sim2 ending
	if(simType=2){
		Sleep, 450
		FindThisText("|<>**10$135.03zzzzzzzzzzzzzzzzzzy00Tzzzzzzzzzzzzzzzzzzzzk7zzzzzzzzzzzzzzzzzzzzz1zU0000000000000000007wS000000000000000000003nU00000000000000000000Cs000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z00000003zU000S60000007s0000000zz0003lk000000z0000000TXw0000C0000007s0000003k3k0001k000000z0000000w0D0000C0000007s000000D01sQ3Xry000000z0000001s073UQSzk000007s000000C00wQ3Xlk000000z0000001k07XUQSC0000007s000000C00wQ3Xlk000000z0000001k07XUQSC0000007s000000C00wQ3Xlk000000z0000001k07XUQSC0000007s000000D00sQ3Xlk000000z0000000s6D3UQSC0000007s0000007UxsQ3Xlk000000z0000000S7y3UwSC0000007s0000001wRUTDXls000000z00000007zz1zwSDk000007s0000000Tzw7vXky000000z0000000007U00000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000z0000000000000000000007s000000000000000000000zU00000000000000000000Dw000000000000000000001vk00000000000000000000STU0000000000000000000Dlzzzzzzzzzzzzzzzzzzzzzw3zzzzzzzzzzzzzzzzzzzzy07zzzzzzzzzzzzzzzzzzzz0U", IDs[4],,, True,5, delay, "quit 4",,,,,,1070,922,1205,978) ;quit 4
	}
	Sleep, delay + 15
	ControlSend,, {Right Up}{Up up}, % "ahk_id " . IDs[4]
	FindText().BindWindow(0)
	bound:=False
	Sleep, delay + 15
	FindTheseTexts("|<>*171$39.000E000002000000M000003000000s000007000000w000007U00000w00000Dk00001y00000Dk00001y00000Ts00zk3z0Dtzzzzzy7zzzzz0Tzzzzk0zzzzw01zzzy007zzzU00Dzzk000zzw0007zz0000zzs0007zz0001zzw000DzzU003zjy000Tszk003w1z000z07s007k0T000w01w00D003U01k00C00M000k0200020U",,, delay, 5, "return to lobby",869,719,908,757,,,True) ; return to lobby
	if(reboot){
		return
	}
	totalRuns++
	resetConsec:=0
}

; brings user from empty desktop, to 4 intentionally placed, sized and named instances
bootInstances(){
	if(reboot){ ; closes specific instances
		Loop, 4{
			WinClose, % "ahk_id " . IDs[A_Index]
		}
		reboot:=False
	}
	WinGet, currID, ID, A ; get ID of current window focus
	Loop, 4{ 
		Run, %filePath%,,, pid     ;run pr2 and store pid (process ID)
		WinWait, ahk_pid %pid%  ; wait for windows to catch up
		ID:= WinExist("ahk_pid" pid) ; get the windows HWND pointer address
		if(!windowSizeGet){
			rect := VarSetCapacity(RECT, 16, 0)
			WinGetPos,wX,wY,wW,wH, % "ahk_id " ID
			DllCall("user32\GetClientRect", Ptr, ID, Ptr, &rect)
			DllCall("user32\ClientToScreen", Ptr, ID, Ptr, &rect)
			clX := NumGet(&rect, 0, "Int")
			clY := NumGet(&rect, 4, "Int")
			borderThickness:=clX-wX
			titleBarHeight:=clY-wY
			;startingWidth:=startingWidth-(borderThickness*2)
            ;startingHeight:=startingHeight-(borderThickness)-1
            Switch pr2Location{
                case 1:
                    locationx:=pr2MonitorLeft ;top left corner of chosen monitor
                    locationy:=pr2MonitorTop 
                case 2:
                    locationx:=pr2MonitorRight-(startingWidth*2) ;top left corner of chosen monitor
                    locationy:=pr2MonitorTop 
                case 3:
                    locationx:=pr2MonitorLeft ;top left corner of chosen monitor
                    locationy:=pr2MonitorBottom-(startingHeight*2) 
                case 4:
                    locationx:=pr2MonitorRight-(startingWidth*2) ;top left corner of chosen monitor
                    locationy:=pr2MonitorBottom-(startingHeight*2)
                case 5:
                    locationx:=Round(desktopWidth/2)-startingWidth ;top left corner of chosen monitor
                    locationy:=Round(desktopHeight/2)-startingHeight
            }
		}
        
		IDs[A_Index]:=ID
		Process, Priority, %pid%, H
		WinSetTitle,Adobe Flash Player 32,, % "Best Game Ever Instance " . A_Index ;change window name for clarity later
		if(!windowSizeGet){
			dims:=WinMoveEx(locationx+((Mod(A_Index+1, 2))*startingWidth), locationy+(startingHeight*(A_Index-2>0 ? 1 : 0)), startingWidth, startingHeight, ID) ; move instance to adjusted coordinates (exclude border)
			windowSizeGet:=True
		}
		else{
			WinMoveEx(locationx+((Mod(A_Index+1, 2))*startingWidth), locationy+(startingHeight*(A_Index-2>0 ? 1 : 0)), startingWidth, startingHeight, ID) ; move instance to adjusted coordinates (exclude border)
		}
		WinSet, Bottom,, % "ahk_id " . ID
	}
	WinActivate, ahk_id %currID% ; restore window focus before pr2 instances were created
    ;FindTheseTexts("|<>*38$125.zzzzzzzzzzzzlzzzzzzzzzzzzzzzzzzzzXzzzbzzzzzzzzzzzzzzzz7zzyDzzzzzzzzzzzzzzzyDzzwTzzzzzzzzzzzzzzzwTzzszzzzzzzzzzzzzzzzszzzlzzzzw7zUTlUw7skTlz0y0T0zzU3y0TW0k7l0TXs0w0s0zz03s0T0107U0T7U0s1U0zwD7VsS3UQD1sSD3kwT3kzsyC7sQDVwS7swQDlswDlzXzwTssz7swTssszllszlz7zszllyDlszlllzXXlzXyDzlzXXwTXlzXXU077U07wTzXz77sz7Xz7700CD00Dszz7yCDlyD7yCCDzwSDzzlz6DwQTXwSDwQQTzswTzzlyADksz7swDlssTllsTlzVswD3lyDlsD3lsT7XsT7zU1w0DXwTXk0DXk0D0k0D307s0z7sz7W0z7k0z1k0y7Uzw3yDlyD63yDs7y3s7wDzzzzzzzzyDzzzzzzzzzzzzzzzzzzzwTzzzzzzzzzzzzzzzzzzzszzzzzzzzzzzzzzzzzzzzlzzzzzzzzzzzzzzzzzzzzXzzzzzzzzzzzzzzzzzzzz7zzzzzzzzzzs", 2,, delay, 5, "main double click after load",159,936,284,964) ;past main menu then mute
	Loop, 4 {
		FindThisPixel(0xDBDBDB, IDs[A_Index],400,300,800,800, 50, True, true,,True,"wait for load main",20000)
	}
	if(reboot){
		return
	}
	Sleep, 50 + delay																																									
	FindTheseTexts("|<>**4$143.00zzzzzzzzzzzzzzzzzzzy001zzzzzzzzzzzzzzzzzzzzzw0Dy0000000000000000000Dy1w000000000000000000000T3U000000000000000000000CC0000000000000000000000CM0000000000000000000000Bk0000000000000000000000T00000000000000000000000S00000000000000000000000w00000000000000000000001k00000000000000000000001U0000000000000000000000300000000000000000000000600000000000000000000000A00000000000000000000000M00000000000000000000000k00000000000000000000001U0000000000000000000000300000000000000000000000600000000000000000000000A00000000000000006000000M00000000000000006000000k00000000000000006000001U0000000000000000600000300000000000000A00C00000600000000000000Q00C00000A00000000000000Q00A00000M00000000000000Q00A00000k00000000000000M00M00001U00000000000k00M00M000030000000003U1k00s00k00006000000000T01k00k00k0000A000000003u01U01k01U0000M00000000To01U01U01U0000k00000003zc01U03U0300001U000000DTzE030030060000300000003zyU030060060000600001zzzzx02600C00A0000A0000200Dxu00400A00M0000M00007zzzjo00A00M00k0000k0000Dzzxzc00M00k00U0001U0000TzzzzE00k01U01U000300000vzzzyW00U010030000600001y0Tzxw210020060000A00003zzzzu00200400A0000M00007zzzzo00400800M0000k0000Dzzzzc00800E00k0001U0000TzzzzE00k01U01U000300000zzzzyzV1U030020000600001zzzzx00300600A0000A00003zzzzu00600A00M0000M00007zzzzo00M00M00k0000k0000Dzzzzc00k01k01U0001U0000001zzE01U030030000300000000zyU0600600A0000600000000zx00A00Q00M0000A00000000Tu00k00k00k0000M00000000Do03003U0300000k000000007c0C00600600001U000000007k0M00M00M000030000000003U1U00k00k0000600000000000000300300000A00000000000000A00600000M00000000000000s00M00000k00000000000003U01U00001U0000000000000600700000300000000000000000Q00000600000000000000000k00000A00000000000000003000000M0000000000000000A000000k0000000000000000M000001U0000000000000000000000300000000000000000000000600000000000000000000000A00000000000000000000000M00000000000000000000000k00000000000000000000001U00000000000000000000003U0000000000000000000000D00000000000000000000000S00000000000000000000000y00000000000000000000003g00000000000000000000006Q0000000000000000000000QQ0000000000000000000001kQ00000000000000000000070T000000000000000000001w0DzzzzzzzzzzzzzzzzzzzzzUE",,, delay, 5, "mute instance",1225,904,1368,993)
	if(reboot){
		return
	}
}

; logs in all accounts in array 'instances' on currentServer
loginSome(logoutFirst:=False){
	Loop, 4{
        loopID:=IDs[A_Index]
		if(logoutFirst){ ; if changing servers mid sim
			FindThisText("|<>*159$140.M0000000000000000000000q0000000000000000000000BU0000000000000000000003M0000s00000000000080000q0000C000000000000C0000BU0003U000000000003U0003M0000s000000000000s0000q0000C000000000000C0000BU0003U03y0Ti1z0s7Dw0003M0000s01zkDzUzsC1nz0000q0000C00wS7XsSD3UQC0000BU0003U0C3VkS71ks73U0003M0000s070Qs3XUCC1ks0000q0000C01k7C0ss3XUQC0000BU0003U0Q1nUCC0ss73U0003M0000s070Qs3XUCC1ks0000q0000C01k7C0ss3XUQC0000DU0003U0Q1nUCC0ss73U0003s0000s070Qs3XUCC1ks0000y0000C00sC71sQ73UwC0000DU0003U0D7Vsy7XkwT3U0003s0000zzlzkDzUzs7zkz0000y0000DzwDs1ys7s0zQ7k000DU0000000000C00000000003s000000000s3U0000000000y000000000D1s0000000000DU000000003sw00000000003s000000000Ty00000000000y0000000003z00000000000DU0000000000000000000003s0000000000000000000000y0000000000000000000000BU0000000000000000000007Q0000000000000000000001r0000000000000000000000Qs000000000000000000000DDU00000000000000000000DlzzzzzzzzzzzzzzzzzzzzzzwDzzzzzzzzzzzzzzzzzzzzzzU", loopID,,,,5, delay + 250, "logout button",,,,,907,938,1047,977)  ; logout button
			;old "|<>*111$84.s0000000000008s000000000000Ms000000000000ss000000000000ss000000000000ss00T03tUDUA0lys01zkDzUzsA0lys03lsCDVswA0kss03UsQ3VUQA0kss070Qs3XUCC1kss070Qs3XUCC1kss070Qs3XUCC1kss070Qs3XUCC1kss070Qs3XUCC1kss070Qs3XUCC1kss070Qs3XUCC1kss03UsQ7VkQC1kss03lsSDVswD7kszzVzkDzUzs7zkTzzUT03vUDU3tkD0000003U00000000000s3U00000000000s3000000000000Q7000000000000Dy0000000000007s0000000U"
			if(reboot){
				return
			}
		}
		FindThisText("|<>*147$91.M0000000007z000A0000000003zU0060000000000DU003000000000070001U0000000003U000k0080000001k000M00Ts0Tz000s1ryA00zz0TzU00Q0zza00Q3US1k00C0T3n00S0sS0s0070C0tU0C0QC0Q003U70Sk070770C001k3U7M03U3XU7000s1k3g01k1lk3U00Q0s1q00s0ss1k00C0Q0v00Q0QQ0s0070C0RU0C0QC0Q003U70Ck070C70C001k3U7M03k73kD000s1k3y0swD0zzU00Q0s1zzwDz0Dxk01zkQ0zzy3z03ss00zsC0Q000S000Q00000000000000C00000000000000C0000000000000sD0000000000000Tz0000000000000Dz00000002", loopID,,,,5, delay + 250, "login main menu",,,,,,645,563,736,591)  ; login button
		if(reboot){
			return
		}
        if(!savedAccountsGet){
            checkForSaved() ; checks for any saved accounts
			savedAccountsGet:=True
			if(savedAccounts!=0){
				FindThisText("|<>*200$18.zzzzzzzzzDzsDzsDzs1zU1zU0Q00Q00Q0U",loopID ,,,,5, delay, "reset known user menu after savedcheck",,,,,,850,442,868,453) ; click back on menu
				if(reboot){
					return
				}
			}
        }
		if(savedAccounts){
            FindThisText("|<>*200$18.zzzzzzzzzDzsDzsDzs1zU1zU0Q00Q00Q0U",loopID,,,,5, delay, "known users list post saved check",,,,,,850,442,868,453) ; known users list
			if(reboot){
				return
			}
			ControlSend,, {PgDn}, % "ahk_id " . loopID
            if(savedAccounts>5){
				Sleep, delay + 15
			    ControlSend,, % "{PgDn " . savedAccounts-5 . "}", % "ahk_id " . loopID ; reveal and select 'use other account', extra pgdn inputs if lots of saved accounts
            }
			Sleep, delay + 15
			KeyWait, Shift
			ControlSend,, {Enter}, % "ahk_id " . loopID
			Sleep, delay + 250
		}
        if(currentServer!="Derron"){
            FindThisText("|<>*220$18.zzzzzzzzz7zw7zw7zw1zU1zU0C00C00C0U", loopID,,,,5, delay, "server list dropdown",,,,,,847,622,865,633,,,,,False)  ;server list
			if(reboot){
				return
			}
			Loop, 4{
				if(serverList[A_Index]=currentServer){ ; locates index of servername and presses down accordingly
					Sleep, delay + 25
					Loop, % (A_Index-1){
						ControlSend,, {down}, % "ahk_id " . loopID ; pick server
						Sleep, delay + 25
					}
					KeyWait, Control
					ControlSend,, {Enter}, % "ahk_id " . loopID
					Sleep, delay + 15
					break
				}
			}
        }
        FindThisText("|<>*119$101.z00000000003w0001y00000000007s0003w0000000000Dk0007s0000000000TU000Dk000000000000000TU000000000000000z0000U00000000001y000zy00zrs7s7tzXw003zy07zzkDkDrzbs00Dzz0TzzUTUTzzjk00zzy1zzz0z0zzzTU03y3y3y1y1y1zXzz007s3wDs3w3w3w3zy00Dk7wTk7s7s7s3zw00zU7sz0DkDkDk7zs01y0Dly0TUTUTUDzk03w0TXw0z0z0z0TzU07s0z7s1y1y1y0zz00Ds1yDk3w3w3w1zy00Dk7wTk7s7s7s3zw00TUDkTkTkDkDk7zzzszUzUzzzUTUTUDzzzkzzy0zzz0z0z0TzzzUzzw1zzy1y1y0zzzz0zzU0zvw3w3w1zzzy0zy00C7s7s7s3w000020000Tk000000000000000z00000000000000w7y00000000000001zzs00000000000003zzk00000000000007zy000000000000007zk0000004", loopID,,-1,,5, 100 + delay, "user text field",85,,,,,637,236,738,269,,,,,False)  ; user field
		if(reboot){
			return
		}
		KeyWait, Shift
		ControlSend,, % "{text}" . accounts[A_Index].username, % "ahk_id " . loopID ; type username
		Sleep, delay + 15
		FindThisText("|<>*119$101.z00000000003w0001y00000000007s0003w0000000000Dk0007s0000000000TU000Dk000000000000000TU000000000000000z0000U00000000001y000zy00zrs7s7tzXw003zy07zzkDkDrzbs00Dzz0TzzUTUTzzjk00zzy1zzz0z0zzzTU03y3y3y1y1y1zXzz007s3wDs3w3w3w3zy00Dk7wTk7s7s7s3zw00zU7sz0DkDkDk7zs01y0Dly0TUTUTUDzk03w0TXw0z0z0z0TzU07s0z7s1y1y1y0zz00Ds1yDk3w3w3w1zy00Dk7wTk7s7s7s3zw00TUDkTkTkDkDk7zzzszUzUzzzUTUTUDzzzkzzy0zzz0z0z0TzzzUzzw1zzy1y1y0zzzz0zzU0zvw3w3w1zzzy0zy00C7s7s7s3w000020000Tk000000000000000z00000000000000w7y00000000000001zzs00000000000003zzk00000000000007zy000000000000007zk0000004", loopID,,-1,,5, 100 + delay, "pass text field",155,,,,,637,236,738,269,,,,,False)
		if(reboot){
			return
		}
		KeyWait, Shift
		ControlSend,, % "{text}" . accounts[A_Index].password, % "ahk_id " . loopID ; type password
		Sleep, delay + 50
        FindThisText("|<>**10$186.0zzzzzzzzzzzzzzzzzzzzzzzzzzzzz03zzzzzzzzzzzzzzzzzzzzzzzzzzzzzkDzzzzzzzzzzzzzzzzzzzzzzzzzzzzzwDU0000000000000000000000000001wS00000000000000000000000000000SQ00000000000000000000000000000Cw00000000000000000000000000000Dw000000000000000000000000000007s000000000000000000000000000007s000000000000000000000000000007s000000000000000000000000000007s000000000000000000000000000007s000000000000000000000000000007s000000000000000000000000000007s000000000000000000000000000007s000000000000000000000000000007s000000000000000000000000000007s000000000000000000000000000007s000000000000000000000000000007s00000000Q00000000D000000000007s00000000Q00000000D000000000007s00000000Q00000000D000000000007s00000000Q00000000D000000000007s00000000Q00000000D000000000007s00000000Q00Tk3xk0D3jk000000007s00000000Q00zs7zk0D3zs000000007s00000000Q01swD7k0D3tw000000007s00000000Q03kSS3E0D3kQ000000007s00000000Q03UCQ1k0D3UQ000000007s00000000Q03UCQ1k0D3UQ000000007s00000000Q03UCQ1k0D3UQ000000007s00000000Q03UCQ1k0D3UQ000000007s00000000Q03UCQ1k0D3UQ000000007s00000000Q03UCQ1k0D3UQ000000007s00000000Q03UCQ1k0D3UQ000000007s00000000Q03kSS3E0D3UQ000000007s00000000Q01swD7k0D3UQ000000007s00000000Tzszs7zk0D3UQ000000007s00000000TzsTk3xk0D3UQ000000007s000000000000001k00000000000007s0000000000000Q1k00000000000007s0000000000000S3k00000000000007s0000000000000T7U00000000000007s0000000000000Dz000000000000007s00000000000007y000000000000007s000000000000000000000000000007s000000000000000000000000000007w00000000000000000000000000000Dw00000000000000000000000000000DQ00000000000000000000000000000CS00000000000000000000000000000SD00000000000000000000000000000wDzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw7zzzzzzzzzzzzzzzzzzzzzzzzzzzzzs1zzzzzzzzzzzzzzzzzzzzzzzzzzzzzUU", loopID,,, True,5, delay, "login to game",,,,,,487,720,673,775) ; login
		if(reboot){
			return
		}
		if(A_Index=2){
			Sleep, 5000 + (delay*20) ; too fast boiii
		}
		
	}
}

; brings specified instance(s) from the page past login to the sim
levelPrep(){
    Loop, 4{
		loopID:=IDs[A_Index]
		FindThisPixel(0xB20505,loopID,550,900,680,1050,50,,,1,True,"wait past login load",15000)
		if(reboot){
			return
		}
		Sleep, 250 + (delay * 10)
        FindThisText(Text:="|<>*193$31.00TU001zy003zzk07zzw07zzz07zzzk3zzzw3zzzy1zzzzVzzzzszzzzwzzzzyTzzzzjzzzzrzzzzzzzzzzzzzzyzzzzzTzzzzjzzzzrzzzzvzzzzszzzzwTzzzw7zzzy3zzzy0zzzy0Dzzy03zzy00Tzy007zw000zs08", loopID,,,,5, (delay*5) + 100, "hat menu",,,,,,443,303,474,335) ; click (?) for hats
        if(reboot){
			return
		}
		FindThisText(Text:="|<>*171$128.0000000001U00000000000000000000S00000000000000000000Ds00000000000000000003zk0000000000000000001zz0000000000000000001zzw000000000000000007zzzk0000000000000000Dzzzz0000000000000000Dzzzzw000000000000000Dzzzzzk000000000000007zzzzzzU00000000000007zzzzzzy00000000000003zzzzzzzs0000000000001zzzzzzzzU000000000000Tzzzzzzzy000000000000Dzzzzzzzzk000000000007zzzzzzzzz000000000001zzzzzzzzzs00000000000zzzzzzzzzzU0000000000Tzzzzzzzzzw00000000007zzzzzzzzzzk0000000001zzzzzzzzzzy0000000000zzzzzzzzzzzk000000000Dzzzzzzzzzzz0000000007zzzzzzzzzzzs000000001zzzzzzzzzzzz000000000Tzzzzzzzzzzzs00000000Dzzzzzzzzzzzz000000003zzzzzzzzzzzzs00000000zzzzzzzzzzzzz00000000Tzzzzzzzzzzzzw00000007zzzzzzzzzzzzzU0000001zzzzzzzzzzzzzw0000000TzzzzzzzzzzzzzU000000Dzzzzzzzzzzzzzw0000003zzzzzzzzzzzzzzU000000zzzzzzzzzzzzzzw000000Dzzzzzzzzzzzzzz0000003zzzzzzzzzzzzzzs000000zzzzzzzzzzzzzzz000000Dzzzzzzzzzzzzzzs000003zzzzzzzzzzzzzzz000000zzzzzzzzzzzzzzzk00000Dzzzzzzzzzzzzzzy000003zzzzzzzzzzzzzzzU00000zzzzzzzzzzzzzzzw00000DzzzzzzzzzzzzzzzU00003zzzzzzzzzzzzzzzs00000zzzzzzzzzzzzzzzy00000Dzzzzzzzzzzzzzzzk00003zzzzzzzzzzzzzzzw00000zzzzzzzzzzzzzzzzU0000Dzzzzzzzzzzzzzzzs00003zzzzzzzzzzzzzzzy00000zzzzzzzzzzzzzzzzk0000Dzzzzzzzzzzzzzzzw00003zzzzzzzzzzzzzzzz00000Tzzzzzzzzzzzzzzzk00007zzzzzzzzzzzzzzzU00001zzzzzzzzzzzzzzzU00000TzzzzzzzzzzzzzzU000007zzzzzzzzzzzzzzU000001zzzzzzzzzzzzzzU000000DzzzzzzzzzzzzzU0000003zzzzzzzzzzzzzU0000000zzzzzzzzzzzzzU0000000Dzzzzzzzzzzzz000000003zzzzzzzzzzzz000000000Tzzzzzzzzzzz0000000007zzzzzzzzzzy0000000001zzzzzzzzzzy0000000000Tzzzzzzzzzy0000000000Dzzzzzzzzzw00000000007zzzzzzzzzw00000000001zzzzzzzzzw00000000000zzzzzzzzzs00000000000Tzzzzzzzzs00000000000Dzzzzzzzzk000000000007zzzzzzzzk000000000003zzzzzzzzU000000000003zzzzzzzzU000000000001zzzzzzzzU000000000001zzzzzzzz0000000000001zzzzzzzz0000000000001zzzzzzzz0000000000001zzzzzzzy0000000000003zzzzzzzy0000000000003zzzzzzzy0000000000003zzzzzzzy0000000000001zzzzzzzw0000000000001zzzzzzzw0000000000000zzzzzzzw0000000000000Tzzzzzzw0000000000000Dzzzzzzw00000000000007zzzzzzw00000000000003zzzzzzw00000000000000zzzzzzw00000000000000Dzzzzzs000000000000003zzzzzw000000000000000zzzzzw000000000000000Dzzzzw0000000000000003zzzzw0000000000000000zzzzw00000000000000007zzzw00000000000000000zzzs000000000000000007zzs000000000000000000zzk0000000000000000003z0000000000000000000U", loopID,,,,5, (delay*3) + 100, "click exp hat",,,,,,238,307,366,415) ; exp hat
		if(reboot){
			return
		}
		;FindThisText(Text:="|<>*139$70.zzs000006003zzU00000M00C00000000000s00000000003U0000000000C000ysQ3VVrks00DzVkC67znU01sy70sMT7i0071sQ3VVsCzzks3VkC670Tzz3UC70sMQ1y00C0sQ3VVk7s00s3VkC670TU03UC70sMQ1y00C0sQ3VVk7s00s3VkC670TU01kS70sMS3i003XsSDVVwSzzwDzUzy67znzzkDi1wsMRw00000s0001k000003U0007000000C0000Q000000s0001k000003U0007000000C0000Q08", loopID,,,,5, (delay*10) + 500, "equip exp hat",,,,,,520,674,590,700) ; click equip
		FindThisText(Text:="|<>**10$250.1zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzy0Tzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzy3zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzwT0000000000000000000000000000000000000003ts0000000000000000000000000000000000000007j0000000000000000000000000000000000000000Ds0000000000000000000000000000000000000000TU0000000000000000000000000000000000000001y00000000000000000000000000000000000000007s0000000000000000000000000000000000000000TU0000000000000000000000000000000000000001y00000000000000000000000000000000000000007s0000000000000000000000000000000000000000TU0000000000000000000000000000000000000001y00000000000000000000000000000000000000007s0000000000000000000000000000000000000000TU0000000000000000000000000000000000000001y00000000000000000000000000000000000000007s0000000000000000000000000000000000000000TU00000000000003zzU00000w00000000000000001y00000000000000Dzy000003k00000000000000007s00000000000000s0000000000000000000000000TU00000000000003U0000000000000000000000001y00000000000000C00000000000000000000000007s00000000000000s007vVkCD7TU00000000000000TU00000000000003U00zy70swTz000000000000001y00000000000000C007bsQ3XlyS000000000000007s00000000000000s00w6VkCD7Uw00000000000000TU00000000000003zzXUC70swQ1k00000000000001y00000000000000DzyC0sQ3Xlk7000000000000007s00000000000000s00s3VkCD70Q00000000000000TU00000000000003U03UC70swQ1k00000000000001y00000000000000C00C0sQ3Xlk7000000000000007s00000000000000s00s3VkCD70Q00000000000000TU00000000000003U03UC70swQ1k00000000000001y00000000000000C0071cQ7XlsD000000000000007s00000000000000s00TDVwyD7ns00000000000000TU00000000000003zzkzy3zswTz000000000000001y00000000000000Dzz1zs7vXlrs000000000000007s0000000000000000003U00070000000000000000TU000000000000000000C0000Q0000000000000001y0000000000000000000s0001k0000000000000007s0000000000000000003U00070000000000000000TU000000000000000000C0000Q0000000000000001y0000000000000000000s0001k0000000000000007s0000000000000000000000000000000000000000TU0000000000000000000000000000000000000001y00000000000000000000000000000000000000007s0000000000000000000000000000000000000000Tk0000000000000000000000000000000000000003rU000000000000000000000000000000000000000CT0000000000000000000000000000000000000003szzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz1zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs3zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz2", loopID,,,,5, (delay*10) + 300, "equip exp hat",,,,,,430,655,680,710) ; click equip
		
		if(reboot){
			return
		}


		; hat color, previously used to track characters
	/*

		FindThisText(Text:="|<>*153$7.zMksssM4634", loopID,,-1,,5, delay + 350, "click hat color", 14) ; hat color
		if(reboot){
			return
		}
		FindThisText(Text:="|<>*202$56.zzzzzzzzzk000000004000000001000000000E000000004000000001000000000E000000004000000001000000000E000000004000000001000000000E000000004000000001000000000E000000004000000001000000000E000000004000000001000000000M", loopID,2,,,5, delay + 200, "click color Hex Text box") ; color hex text
		if(reboot){
			return
		}
		ControlSend,, {text}#000000, % "ahk_id " . loopID ; black color
		Sleep, delay + 150
		FindThisText("|<>*153$14.S8wmG4cVC8Gm4Yn8bWC", loopID,,,,5, delay + 150, "confirm hat color") ; OK button for hat color
		if(reboot){
			return
		}
		FindThisText(Text:="|<>*153$7.zMksssM4634", loopID,,-2,,5, delay + 350, "click hat color", 14) ; hat color
		if(reboot){
			return
		}
		FindThisText(Text:="|<>*202$56.zzzzzzzzzk000000004000000001000000000E000000004000000001000000000E000000004000000001000000000E000000004000000001000000000E000000004000000001000000000E000000004000000001000000000E000000004000000001000000000M", loopID,2,,,5, delay + 150, "click color Hex Text box") ; color hex text
		if(reboot){
			return
		}
		ControlSend,, {text}#000000, % "ahk_id " . loopID ; black color
		Sleep, delay + 150
		FindThisText("|<>*153$14.S8wmG4cVC8Gm4Yn8bWC", loopID,,,,5, delay + 150, "confirm hat color") ; OK button for hat color
		if(reboot){
			return
		}
	*/

	
		;Did I really do this instead of just placing a stat change block? Yes. Yes I did. I'm dumb.
	/* 
		FindThisText("|<>*116$18.k00k00000nwTnwvnBnnBnnAnnAznAT00300z00QU", loopID,2,-1,,5, delay + 15, "ing locator for stats", 34) ; change stats
		if(reboot){
			return
		}
		ControlSend,, {text}0, % "ahk_id " . loopID ; 0 speed
		Sleep, delay + 50
		FindThisText("|<>*116$18.k00k00000nwTnwvnBnnBnnAnnAznAT00300z00QU", loopID,2,-3,,5, delay + 15, "ing locator for stats", 34) ; change stats
		if(reboot){
			return
		}
		ControlSend,, {text}46, % "ahk_id " . loopID ; 46 jump
		Sleep, delay + 50
		FindThisText("|<>*116$18.k00k00000nwTnwvnBnnBnnAnnAznAT00300z00QU", loopID,2,-2,,5, delay + 15, "ing locator for stats", 34) ; change stats
		if(reboot){
			return
		}
		ControlSend,, {text}80, % "ahk_id " . loopID ; 80 accel
		Sleep, delay + 50
		FindThisText("|<>*116$18.k00k00000nwTnwvnBnnBnnAnnAznAT00300z00QU", loopID,2,-1,,5, delay + 15, "ing locator for stats", 34) ; change stats
		if(reboot){
			return
		}
		ControlSend,, {text}100, % "ahk_id " . loopID ; remainder speed
		Sleep, delay + 50
	*/
		FindThisText("|<>*123$61.00000000k000000000M000000000A000000000600000000030000000001U07w0MS0z0kwDzUAz1zsNzbzs7zVzwDzv0w3s1s27kw0C1k1s03UC030k0s01U31zUM0Q00k1bzkA0A00M0rzs60600A0TkA3030060DU61U1k0307U30k0s01U3k1UM0S00k1w3kA07U8M0zzs601zwA0Pzg300Ty60AT61U03w307", loopID,,,,5, delay + 15, "search tab",,,,,,1235,20,1296,43) ; search tab
		if(reboot){
			return
		}
		FindThisText("|<>*120$56.s0Q000000C070000003U1k000000s0Q000000C070000003U1kDU1w1js0QDy1zkTy0731ksC73U1lkAA1Vks0QQ070QMC073U1U363U1kzUTzlUs0Q3y7zwMC0707lU061U1U0CQ01UM0MQ1b00M70C70ss760s70sQD3VU7zU7z1zkM0TU0z07s62", loopID,,,,5, delay, "search by dropdown",,,,,,862,96,918,116,,,,,False) ;search by dropdown
		if(reboot){
			return
		}
		;FindThisText("|<>*136$97.s000000001U0A7zkQ000000000k063zyC000000000M031k3b000000000A01Us0vU00000000600kQ0Bk00y3UC3s300MC07s01zkk67z1U0A701w01kQM371kk063U0y00k6C3X0MM031k0T00s3X1XUCA01Us0DU0M0lVlU3600kQ07k0DzsskzzX00MC03s07zwAMTzlU0A701w03006QA00k063U1y01k03A700M031k0z00s00q3U0A01Us0PU0C1kT0s7600kQ0Rk07VkD0S7300MC0wzzVzk3U7z1U0A7zwTzkDk1k0z0k063zs8", loopID,,,,5, delay, "level ID type",,,,,,867,246,964,266) ; level ID
		FindThisText("|<>*112$85.1y0000000000M03zs000000000A03US000000000601U3000000000301k1k000000001U0s0s3s0TUPkS0lsQ007z0zsDszkTz7U071ksC70sQD3Xz030MM33UM670sTw3UC01VUA33UQ1zVU303kkC01k603szzUzsM700k300QTzlzAA3U0M1w06A00s661k0A0q03700s330s760P01XU0M3VUA330Bk1ks7C1kk61VU6S1kS773sM3Vkk37zk7z1zgA0zkM1UzU0z0T7607UA0s", loopID,,, True,5, delay, "click level ID",,,,"wait0",,1056,249,1141,269)
		if(reboot){
			return
		}
		FindThisText("|<>*119$18.zzzzzzzzyDzsDzs1zU1zU1z00Q00Q0U", loopID,,-1,,5, delay, "click text box level search",75,,,,,918,175,936,185,,,,,False) ; level id text box
		if(reboot){
			return
		}
		ControlSend,,% "{text}" . levelID, % "ahk_id " . loopID ; enter sim ID
		Sleep, delay + 15
		FindThisText("|<>**25$205.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000Tzz0000000003z00000000000000000006Dzzzzzzzzzzzzzzzzzzzzzzzzzzzzw000Dzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw00D00000000000000000000000000000030070000000000000000000000000000000k070000000000000000000000000000000A03U000000000000000000000000000000201U000000000000000000000000000000100E0000000000000000000000000000000U0c0000000000000000000000000000000E04000000000000000000000000000000080200000000000000000000000000000004010000000000000000000000000000000203U000000000000000000000000000000101k0000000000000000000000000000000U0s0000000000000000000000000000000E0Q000000000000000000000000000000080C00000000000000000000000000000004070000000000000000000000000000000203U00000000Dy0000000001k000000000101k00000000TzU000000000s0000000000U0s00000000DXs000000000Q0000000000E0Q00000000D0S000000000C000000000080C0000000070700000000070000000000707000000003U3UTk7z3jXw3jk000000003U3U00000001s00Tw7zlzXz1zw000000001k1k00000000z00SD7lsyHnkyT000000000s0s00000000Dy0S3nUSS3kwS3U00000000Q0Q000000003zsC0s0DD1kSC1k00000000C0C000000000Dy70Q0zbUs070s000000007070000000000zXzy7znkQ03UQ000000003U3U0000000003tzz7ztsC01kC000000001k1k00000001k0ws07kww700s7000000000s0s00000000w0CQ03USS3UQQ3U00000000Q0Q00000000S0DC01kDD1kCC1k00000000C0C000000007U77UQsDbUwD70s00000000707000000001wTVwySDnkDD3UQ000000003U3U00000000TzUTy7zts3z1kC000000001k1k000000007z07y1yQw0z0s7000000000s0s0000000000000000000000000000000Q0Q0000000000000000000000000000000C0C000000000000000000000000000000070700000000000000000000000000000003U3U0000000000000000000000000000001k1k0000000000000000000000000000000s0s0000000000000000000000000000000Q0Q0000000000000000000000000000000C0D0000000000000000000000000000000603U000000000000000000000000000000701k0000000000000000000000000000003U0w0000000000000000000000000000003k0D0000000000000000000000000000003k03zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk00zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk00Dzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004", loopID,,, True,5, delay, "search button",,,,,,1002,221,1207,296) ; search button
		if(reboot){
			return
		}
	} 
    /*



	if(!starGot){
		FindText().BindWindow(IDs[1], 1)
		bound:=True
		if(FindText(X:="wait", Y:=.5,0,0,0,0,0,0,"|<>*161$9.20E27zTlsDXgEI")){
			star:="|<>*161$9.20E27zTlsDXgEI"
		}
		else{
			star:="|<>*165$9.20E27zTlsDV4EI"
		}
		starGot:=True
		FindText().BindWindow(0)
		bound:=False
	}
    */
}

;reads the pr2hub server info "happy_hour" flag, if '1', return that server name (hh server)
checkHappyHour(){
	webOBJ := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	webOBJ.Open("GET", serverInfoURL)
	webOBJ.Send()
	serverInfo := webOBJ.ResponseText
	serverInfoPrep:= StrReplace(serverInfo, "server_id", "¦") ; inStr func later cant find strings, so replace the string we are looking for with an uncommon character to use in inStr
	Loop, Parse, serverInfoPrep, ¦
		{
			if(A_Index=2||A_Index=3||A_Index=4||A_Index=5){ ; loop index 2,3,4,5 contain the 4 main servers info
				if(SubStr(A_LoopField, (InStr(A_LoopField, "happy_hour")+12), 1)){ ; if location of flag '0' or '1'
					if(currentserver=serverList[A_Index-1]){
						return
					}
					currentServer:=serverList[A_Index-1]
					return True
				}
			}		
	}
}

; checks if any instance has softlocked (is not in the sim instance when they should be) !!(does not work if server delay causes character to enter a level other than the sim, e.x a campaign level)
shout(){
    Loop, 3 {
		FindThisText("|<>FFFFFF@1.00$259.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw", IDs[A_Index+1],,, True,5, delay, "chat message send",,,,,,119,943,378,988,,,,,False)
	    if(reboot){
			return
		}
		Switch A_Index
		{
			case 1:
				Sleep, delay + 15
				if(FindText("wait", .25, 0, 0, 0, 0, 0, 0, "|<>*165$26.QE00AY0021SSCUIYYc59ly1G6EnIgobZlsu")){
				if(FindThisText("|<>**5$181.1zzzzzzzzzzzzzzzzzzzzzzzzzzzzk1zzzzzzzzzzzzzzzzzzzzzzzzzzzzw3zzzzzzzzzzzzzzzzzzzzzzzzzzzzzVw0000000000000000000000000007ls0000000000000000000000000000ws0000000000000000000000000000Cw00000000000000000000000000007y00000000000000000000000000003y00000000000000000000000000000z00000000000000000000000000000TU0000000000000000000000000000Dk00000000000000000000000000007s00000000000000000000000000003w00000000000000000000000000001y00000000000000000000000000000z00000000000000000000000000000TU0000000000000000000000000000Dk00000000000000000000000000007s00000000000000000000000000003w0000000007z0w0000000000000001y0000000007zkS0000000000000000z0000000007lwD0000000000000000TU000000007UD7U000000000000000Dk000000007U3nk0000000000000007s000000003U1tsDs3y0Tk000000003w000000003k00wDy3zkTw000000001y000000001s00SD7XlsSD000000000z000000000w00DD1tkSS3k00000000TU00000000S007b0Qs0C0s00000000Dk00000000D003nUCTU70Q000000007s000000007U01tk77y3zy000000003w000000003k00ws3Vzlzz000000001y000000001s0CSQ1k7ws0000000000z000000000Q07DC0s0SQ0000000000TU00000000D07bb0Qs7C0000000000Dk000000003k7XnkSQ3bUQ000000007s000000000yDVswSDXlwy000000003w000000000DzUwDy3zkTy000000001y0000000003zUS3y0zk7y000000000z00000000000000000000000000000TU0000000000000000000000000000Dk00000000000000000000000000007s00000000000000000000000000003w00000000000000000000000000001y00000000000000000000000000000z00000000000000000000000000000TU0000000000000000000000000000Ds0000000000000000000000000000Dw00000000000000000000000000007i00000000000000000000000000003bU0000000000000000000000000003nw0000000000000000000000000003szzzzzzzzzzzzzzzzzzzzzzzzzzzzzsDzzzzzzzzzzzzzzzzzzzzzzzzzzzzs1zzzzzzzzzzzzzzzzzzzzzzzzzzzzkE", IDs[2],,,True,.5, delay+10,, ,, ,,False, 1047,520, 1228, 575,False,,,,False))
					ControlSend,, {text}NEEEED, % "ahk_id " . IDs[2]
				}
				Sleep, delay + 15
				KeyWait, Control
				ControlSend,, {Enter}, % "ahk_id " . IDs[2]
			case 2:
				Sleep, delay + 15
				ControlSend,, % "{text}We broke " . resetTotal . " times! Epic!", % "ahk_id " . IDs[3]
				Sleep, delay + 15
				KeyWait, Control
				ControlSend,, {Enter}, % "ahk_id " . IDs[3]
			case 3:
				Sleep, delay + 15
				ControlSend,, % "{text}We've simmed " . totalRuns .  " times over " . ((A_TickCount-currentTick)//3600000) . " hours and " . Mod(((A_TickCount-currentTick)//60000), 60) . " minutes. Wowzers!", % "ahk_id " . IDs[4]
				Sleep, delay + 15
				KeyWait, Control
				ControlSend,, {Enter}, % "ahk_id " . IDs[4]
		}
    }
}
	
setup(){
	MsgBox, 0, PR2 is cool, Welcome to the EPIC PR2 player count optimizer!`n`nIf anything is not working as intended or you need help, contact @yaboitroi on discord (epicmidget)
	SysGet, monitorCount, monitorCount
	if (FileExist("EPICsimDetails.ini")){
		IniRead, whichMonitor, EPICsimDetails.ini,general, whichmonitor
		IniRead, startingHeight, EPICsimDetails.ini,general, startingheight
		IniRead, startingWidth, EPICsimDetails.ini,general, startingwidth
		IniRead, levelID, EPICsimDetails.ini,general, levelid
		IniRead, simType, EPICsimDetails.ini,general, simtype
		IniRead, pr2Location, EPICsimDetails.ini,general, pr2location
		IniRead, user1, EPICsimDetails.ini,general, user1
		IniRead, pass1, EPICsimDetails.ini,general, pass1
		IniRead, user2, EPICsimDetails.ini,general, user2
		IniRead, pass2, EPICsimDetails.ini,general, pass2
		IniRead, user3, EPICsimDetails.ini,general, user3
		IniRead, pass3, EPICsimDetails.ini,general, pass3
		IniRead, user4, EPICsimDetails.ini,general, user4
		IniRead, pass4, EPICsimDetails.ini,general, pass4
		IniRead, delay, EPICsimDetails.ini,general, delay
		SysGet, pr2Monitor, monitorWorkArea , %whichMonitor% ; stores monitor boundaries as variables
        details:={whichmonitor:whichMonitor, levelid:levelID, startingwidth:startingWidth, startingheight:startingHeight, simtype:simType, pr2location:pr2Location, user1:user1, pass1:pass1, user2:user2, pass2:pass2, user3:user3, pass3:pass3, user4:user4, pass4:pass4, delay:delay}   
		missingDetails:=false
		                                   ; 
		IniRead, mydpi, EPICsimDetails.ini,general, mydpi                                                           ;
		if((mydpi!=A_Screendpi)&&(startingWidth!="ERROR")&&(startingHeight!="ERROR")){                            ;
			SysGet, pr2Monitor, monitorWorkArea , %whichMonitor% ; stores monitor boundaries as variables       ;
			desktopWidth:=(pr2MonitorRight-pr2MonitorLeft)                                                      ;
			desktopHeight:=(pr2MonitorBottom-pr2MonitorTop)                                                     ;
			if(startingHeight>Round(desktopHeight/2)){                                                          ;
				startingHeight:=Round(desktopHeight/2)                                                          ; screen dpi nonsense
			}                                                                                                   ;
			if(startingWidth>Round(desktopWidth/2)){                                                            ;
				startingWidth:=Round(desktopWidth/2)                                                            ;
			}                                                                                                   ;
		}                                                                                                       ;
		iniWrite, % A_Screendpi, EPICsimDetails.ini,general, mydpi                                                ;

		for key, value in details
			if ((value="ERROR")||(value="")) 
				missingDetails:=True
		if(missingDetails){
			MsgBox, You must redo setup as you have some missing data entries
			Goto, beginSetup
		}                                                
		MsgBox, 4, PR2 is cool, Would you like to reanswer any startup prompts`? Skipping a question will use the answer previously obtained
			IfMsgBox, no
				{
				Goto, endSetup
			    }
	}

	beginSetup:
	MsgBox,, PR2 is cool, Welcome to the EPIC sim setup!
	if(levelID!="ERROR"){
	MsgBox, 4, PR2 is cool, Would you like to reenter your level ID?
		IfMsgBox, No
			{
			Goto, getMonitor
			}
	}
	Loop {
		;InputBox, levelID, PR2 is cool, Log in to PR2 and search user 'U'. pick any one of their levels and paste the level ID here. Try to pick one that isn't near the top of the search. If you're unsure of how to find the level ID`, type help. (blockeditor could also be used to create your own)
		InputBox, levelID, PR2 is cool, Log in to PR2 and search for user 'Delicious Experience''s levels. You will have one of two choices:`n`n-Sim that gives outfit rewards`n-Sim that doesn't (~3 seconds faster)`n`nPaste the level ID here.`n`nIf you're unsure of how to find the level ID`, type help.`n`nYou may also use user 'U's sim level if the other two don't work for whatever reason,,500,400
		while(levelID="help"){
			MsgBox, 0, PR2 is cool, To find the levelID, click the question mark below the level, then hit the green arrow. The level ID should be after the 'level=' part.
			InputBox, levelID, PR2 is cool, Log in to PR2 and search for user 'Delicious Experience''s levels. You will have one of two choices:`nSim that gives outfit rewards, or`nSim that doesn't (~3 seconds faster) Paste the level ID here. If you're unsure of how to find the level ID`, type help.`n`nYou may also use user 'U's sim level if the other two don't work for whatever reason
		}
		if(ErrorLevel||(levelID="")){
			IniRead, levelID, EPICsimDetails.ini,general, levelid
				if(levelID!=""){
					break
				}
		}
		if levelID is digit
			break  
		MsgBox,0 , PR2 is cool, Please enter a valid levelID
	}
	iniWrite, % levelID, EPICsimDetails.ini,general, levelid
	Loop {
		InputBox, simType , PR2 is cool, Which type of map did you pick? Enter one of these values: `n`n-Sim with outfit rewards `(1`)`n-Sim without outfit rewards`(2`)`n-'U' obj sim backup`(3`)
		if(ErrorLevel||(simType="")){
		IniRead, simType, EPICsimDetails.ini,general, simtype
			if(simType!=""){
				break
			}
		}
		if simType between 1 and 3
			break
		MsgBox,0 , PR2 is cool, Please enter a valid simType
	}
	iniWrite, % simType, EPICsimDetails.ini,general, simtype
	
	getMonitor:
	if(whichMonitor!="ERROR"){
		MsgBox, 4, PR2 is cool, Would you like to reenter which monitor the instances will intially load on?
			IfMsgBox, No
				{
				Goto, getPr2Location
				}
		}
	Loop {
		InputBox, whichMonitor , PR2 is cool, Pick which monitor to load pr2 on.`n -Your main monitor (1)`, or`n-any other monitor (2+) `n`nThis can be seen in your windows display settings
		if(ErrorLevel||(whichMonitor="")){
			IniRead, whichMonitor, EPICsimDetails.ini,general, whichmonitor
				if(whichMonitor!=""){
					break
				}
		}
		else if whichMonitor between 1 and monitorCount
			break
		MsgBox,0 , PR2 is cool, Please enter a valid monitor number
	}
	iniWrite, % whichMonitor, EPICsimDetails.ini,general, whichmonitor

	getPr2Location:
	SysGet, pr2Monitor, monitorWorkArea , %whichMonitor% ; stores monitor boundaries as variables
	desktopWidth:=(pr2MonitorRight-pr2MonitorLeft)
	desktopHeight:=(pr2MonitorBottom-pr2MonitorTop)
	if(pr2Location!="ERROR"){
		MsgBox, 4, PR2 is cool, Would you like to reenter your initial instance loading location?
			IfMsgBox, No
				{
				Goto, getStartingWidth
				}
		}
	Loop {
		InputBox, pr2Location , PR2 is cool, Enter a value to determine where you would like your pr2 instances to be initially displayed`:`n-Top left corner`(1`)``n-Top right corner`(2`)``n-Bottom left corner`(3`)`n-Bottom right corner`(4`)`n Center screen`(5`)
		if(ErrorLevel||(pr2Location="")){
			IniRead, pr2Location, EPICsimDetails.ini,general, pr2location
				if(pr2Location!=""){
					break
				}
		}
		else if pr2Location between 1 and 5
			break
		MsgBox,0 , PR2 is cool, Please enter a valid number
	}
	iniWrite, % pr2Location, EPICsimDetails.ini,general, pr2location

	getStartingWidth:
	if(startingWidth!="ERROR"){
		MsgBox, 4, PR2 is cool, Would you like to reenter the starting pr2 window width?
			IfMsgBox, No
				{
				Goto, getStartingHeight
				}
	}
	Loop {
		InputBox, startingWidth , PR2 is cool, Enter the width `(in pixels`) that you would like your instances to be booted. Values lower than 300 will be set to 300`, and values greater than half of your monitors width will be set to half.
		if(ErrorLevel||(startingWidth="")){
			IniRead, startingWidth, EPICsimDetails.ini,general, startingheight
			if(startingWidth!=""){
				break
			}
		}
		else if startingWidth is digit
			{
			if(startingWidth>Round(desktopWidth/2)){
				startingWidth:=Round(desktopWidth/2)
			}
			if(startingWidth<300){
				startingWidth:=300
			}
			break
		}
			MsgBox,0 , PR2 is cool, Please enter an integer value
	}		
	IniWrite, % startingWidth, EPICsimDetails.ini,general, startingwidth

	getStartingHeight:
	if(startingHeight!="ERROR"){
		MsgBox, 4, PR2 is cool, Would you like to reenter the starting pr2 window height?
			IfMsgBox, No
				{
				Goto, getUserInfo1
				}
		}
	Loop {
		InputBox, startingHeight , PR2 is cool, Enter the height `(in pixels`) that you would like your instances to be booted. Values lower than 300 will be set to 300`, and values greater than half of your monitors height will be set to half.
		if(ErrorLevel||(startingHeight="")){
			IniRead, startingHeight, EPICsimDetails.ini,general, startingheight
			if(startingHeight!=""){
				break
			}
		}
		else if startingHeight is digit
			{
			if(startingHeight>Round(desktopHeight/2)){
				startingHeight:=Round(desktopHeight/2)
			}
			if(startingHeight<300){
				startingHeight:=300
			}
			break
		}
			MsgBox,0 , PR2 is cool, Please enter an integer value
	}
	IniWrite, % startingHeight, EPICsimDetails.ini,general, startingheight

	getUserInfo1:
	if(pass1!="ERROR"){
		MsgBox, 4, PR2 is cool, Would you like to reenter the first player's login info?
			IfMsgBox, No
				{
				Goto, getUserInfo2
				}
		}
	Loop{
		InputBox, user1 , PR2 is cool, Enter username 1:
		if(ErrorLevel||(user1="")){
			IniRead, user1, EPICsimDetails.ini,general, user1
				if(user1!=""){
					break
				}
			MsgBox, You must enter a username	
		}
		else{
			break
		}
	}
	Loop{
		InputBox, pass1, PR2 is cool, Enter password 1:
		if(ErrorLevel||(pass1="")){
			IniRead, pass1, EPICsimDetails.ini,general, pass1
				if(pass1!=""){
					break
				}
			MsgBox, You must enter a password
		}
		else{
			break
		}
	}
	IniWrite, % user1, EPICsimDetails.ini,general, user1
	IniWrite, % pass1, EPICsimDetails.ini,general, pass1


	getUserInfo2:
	if(pass2!="ERROR"){
		MsgBox, 4, PR2 is cool, Would you like to reenter the second player's login info?
			IfMsgBox, No
				{
				Goto, getUserInfo3
				}
		}
		Loop{
			InputBox, user2 , PR2 is cool, Enter username 2:
			if(ErrorLevel||(user2="")){
				IniRead, user2, EPICsimDetails.ini,general, user2
					if(user2!=""){
						break
					}
				MsgBox, You must enter a username	
			}
			else{
				break
			}
		}
		Loop{
			InputBox, pass2 , PR2 is cool, Enter password 2:
			if(ErrorLevel||(pass2="")){
				IniRead, pass2, EPICsimDetails.ini,general, pass2
					if(pass2!=""){
						break
					}
				MsgBox, You must enter a password
			}
			else{
				break
			}
		}
	IniWrite, % user2, EPICsimDetails.ini,general, user2
	IniWrite, % pass2, EPICsimDetails.ini,general, pass2

	getUserInfo3:
	if(pass3!="ERROR"){
		MsgBox, 4, PR2 is cool, Would you like to reenter the third player's login info?
			IfMsgBox, No
				{
				Goto, getUserInfo4
				}
		}
		Loop{
			InputBox, user3 , PR2 is cool, Enter username 3:
			if(ErrorLevel||(user3="")){
				IniRead, user3, EPICsimDetails.ini,general, user3
					if(user3!=""){
						break
					}
				MsgBox, You must enter a username	
			}
			else{
				break
			}
		}
		Loop{
			InputBox, pass3 , PR2 is cool, Enter password 3:
			if(ErrorLevel||(pass3="")){
				IniRead, pass3, EPICsimDetails.ini,general, pass3
					if(pass3!=""){
						break
					}
				MsgBox, You must enter a password
			}
			else{
				break
			}
		}
	IniWrite, % user3, EPICsimDetails.ini,general, user3
	IniWrite, % pass3, EPICsimDetails.ini,general, pass3

	getUserInfo4:
	if(pass4!="ERROR"){
		MsgBox, 4, PR2 is cool, Would you like to reenter the fourth player's login info?
			IfMsgBox, No
				{
				Goto, getDelay
				}
		}
		Loop{
			InputBox, user4 , PR2 is cool, Enter username 4:
			if(ErrorLevel||(user4="")){
				IniRead, user4, EPICsimDetails.ini,general, user4
					if(user4!=""){
						break
					}
				MsgBox, You must enter a username	
			}
			else{
				break
			}
		}
		Loop{
			InputBox, pass4 , PR2 is cool, Enter password 4:
			if(ErrorLevel||(pass4="")){
				IniRead, pass4, EPICsimDetails.ini,general, pass4
					if(pass4!=""){
						break
					}
				MsgBox, You must enter a password
			}
			else{
				break
			}
		}
	IniWrite, % user4, EPICsimDetails.ini,general, user4
	IniWrite, % pass4, EPICsimDetails.ini,general, pass4
	
	getDelay:
	if(delay!="ERROR"){
		MsgBox, 4, PR2 is cool, Would you like to change the script delay?
			IfMsgBox, No
				{
				Goto, endSetup
				}
		}
		Loop {
			InputBox, delay, PR2 is cool, How much delay would you like to add to the script`, dependant on your computer specs`?(try 0`, then scale up)`n`n(This is how you will troubleshoot most issues)
			if(ErrorLevel||(delay="")){
				IniRead, delay, EPICsimDetails.ini,general, delay
					if(delay!=""){
						break
					}
			}
			if delay is digit
				{
				if(delay<1){
					delay:=1
				}
				break 
			}
				 
			MsgBox,0 , PR2 is cool, Please enter a valid levelID
		}
		iniWrite, % delay, EPICsimDetails.ini,general, delay
	;getMacroVersion:
	
	endSetup:
		SysGet, pr2Monitor, monitorWorkArea , %whichMonitor% ; stores monitor boundaries as variables
		desktopWidth:=(pr2MonitorRight-pr2MonitorLeft)
		desktopHeight:=(pr2MonitorBottom-pr2MonitorTop)
		IniRead, filePath, EPICsimDetails.ini,general, filepath
        Loop {
			if(FileExist(filePath)){
				break
			}
			if (FileExist("EPICsimDetails.ini")){
				MsgBox, , Goober`.`., Your PR2 file path is not valid
			}
			FileSelectFile, filePath , 3, Platform Racing 2.exe, Select your PR2 launcher (what you run the game with), PR2 launcher (*.exe)
			iniWrite, % filePath, EPICsimDetails.ini,general, filepath
	    }
	Loop, 4{ ; creates 4 objects containing 1 username and 1 password each and places them in 'accounts' array
		temp:=% "user" . A_Index
		user:=%temp%
		temp:=% "pass" . A_Index
		pass:=%temp%
		obj:={username: user , password: pass}
		accounts[A_Index]:= obj
	}
	legal:=True
	MsgBox, 0, PR2 is cool, Windows+F12`: begin the sim`nWindows+F11: reload the script`nWindows+F10: pause the script`nWindows+F9: end the script`nWindows+F8: hide instances (but continue simming)`nWindows+h: show all hotkeys`n`nHappy simming and stay epic B-)
return

    ;Add GUI which shows the accessible hotkeys
    ;Gui, Add, Button, x10 y10 w100 h30 gShowHotkeys, Hotkeys
    ;Gui, Show, w120 h50, Hotkeys GUI

}

; performs the same action on every instance to reduce the time loss from waiting for a server response; starts server API requests as early as possible
FindTheseTexts(Text, repeat:=1, playing:=False, eep:=0, timeout:=-1, errorMessage:="", x1:=0, y1:=0, x2:=0, y2:=0, customPixelOffset:=0, automaticMinCheck:=True, offset:=False,waitPrev:=False){ 
	Loop, 4{
		if(offset=True){
			FindThisText(Text, IDs[A_Index], repeat,-1, True, timeout, eep, errorMessage,90,,,,,x1, y1, x2, y2,,,,,automaticMinCheck)
		}
		else{
		FindThisText(Text, IDs[A_Index], repeat, playing?A_Index:0, True, timeout, eep, errorMessage,,,,,,x1, y1, x2, y2,,,,,automaticMinCheck)
		}
		if(reboot){
			return
		}
		if(waitPrev){
			if(A_Index!=1){
				FindThisPixel(IDs[A_Index],0xEADC9F,640,525,640,525,4,,,3,,p A_Index wait p A_Index-1 to queue,,,40*(A_Index-1))
			}
		}
	}
}

; locates text through image processing (!!!) and clicks the daaang thaang
FindThisText(Text, hwnd, repeat:=1, index:=0, unbind:=False, timeout:=-1, eep:=0, errorMessage:="", offsetAmm:=40,xTol:=.75, yTol:=.75, wait:="wait",canTimeout:=True, x1:=0, y1:=0, x2:=0, y2:=0, click:=True, howMany:=1,offsetTheX:=0, customPixelOffset:=-1, automaticMinCheck:=True){ ; .3 tolerance                        
	WinGet, minMax, MinMax, % "ahk_id " . hwnd
	if((!(minMax+1))&&minMax!=""){ ; no minimizy.,. 
		WinGet, currID, ID, A ; get ID of current window focus
		DllCall("user32\ShowWindow", "Ptr",hwnd,"Int",4)
		WinActivate, % "ahk_id " currID
	}
	if(customPixelOffset=-1){
		customPixelOffset:=pixelOffset
	}
/*
	WinGetPos,,, currW, currH, % "ahk_id " . hwnd ; prevent resized windows (sorry)
	if((currW!=dims[1])||(currH!=dims[2])){
		WinGetTitle, tit, % "ahk_id " . hwnd
		instance:=SubStr(tit, 25, 1)
		WinMoveEx(locationx+((Mod(instance+1, 2))*startingWidth), locationy+(startingHeight*(instance-2>0 ? 1 : 0)), startingWidth, startingHeight, hwnd) ; move instance to adjusted coordinates (exclude border)
	}
*/
	;WinGetPos,currX,currY,,, % "ahk_id " . hwnd ; prevent resized windows (sorry)
	VarSetCapacity(rect, 16, 0)
	DllCall("user32\GetClientRect", Ptr, hwnd, Ptr, &rect)
	DllCall("user32\ClientToScreen", Ptr, hwnd, Ptr, &rect)
	clW := NumGet(&rect, 8, "Int") ;*(96/A_ScreenDPI)
	clH := NumGet(&rect, 12, "Int") ;*(96/A_ScreenDPI)
	grayX:=((clW/clH)>1.375?clW-(clH*1.375):0)
	grayY:=((clW/clH)>1.375?0:clH-(clW/1.375))
	realclW:=clW-grayX
	realclH:=clH-grayY
	zoomX:=realclW/1375
	zoomY:=realclH/1000
	x1:=x1*zoomX
	y1:=y1*zoomY
	x2:=x2*zoomX
	y2:=y2*zoomY
    offsetAmm:=zoomX*offsetAmm
	customPixelOffset:=zoomX*customPixelOffset
	x1-=(customPixelOffset*(1+zoomX))
	x1+=grayX/2
	y1-=customPixelOffset*(1+zoomY)
	y1+=grayY/2
	x2+=(customPixelOffset*(1+zoomX))+grayX/2
	y2+=(customPixelOffset*(1+zoomY))+grayY/2
	offsetTheX:=zoomX*offsetTheX
	x1:=Round(x1) ;*(96/A_ScreenDPI)
	y1:=Round(y1) ;*(96/A_ScreenDPI)
	x2:=Round(x2) ;*(96/A_ScreenDPI)
	y2:=Round(y2) ;*(96/A_ScreenDPI)
	FindText().ClientToScreen(sx1,sy1,x1,y1,hwnd)
	FindText().ClientToScreen(sx2,sy2,x2,y2,hwnd)
    if(!bound){
	    FindText().BindWindow(hwnd, 2)
        bound:=True
    }
	login:=FindText(wait,timeout,sx1,sy1,sx2,sy2,xTol,yTol,Text,,howMany,,,,,zoomX,zoomY)
    if((!login)&&(canTimeout)){
		reboot(errorMessage,hwnd)
		return
    }
	if(click){
		if(wait="wait0"){
			FindText().ScreenToWindow(wx1,wy1,sx1,sy1,hwnd)
			FindText().ScreenToWindow(wx2,wy2,sx2,sy2,hwnd)
			centX:=((wx1+((wx2-wx1)//2))+offsetTheX) ;*(96/A_ScreenDPI)
			centY:=((wy1+((wy2-wy1)//2))-((index)*offsetAmm)) ;*(96/A_ScreenDPI)
			Sleep, eep
			currTime:=A_TickCount
			KeyWait, LButton
			ControlClick, % "x" . centX . " y" . centY, % "ahk_id " . hwnd,,,, NA
			timeLost+=(A_TickCount-currTime)
		}
		else{
			centX:=login[1][1]+login[1][3]//2
			centY:=(login[1][2]+login[1][4]//2)-((index)*offsetAmm)
			FindText().ScreenToWindow(clickX, clickY, centX, centY, hwnd)
			Loop, %repeat%{
				Sleep, eep + 10
				KeyWait, LButton
				ControlClick, % "x" . clickX . " y" . clickY, % "ahk_id " . hwnd,,,, NA
				Sleep, eep + 10
    		}
		}
	}
    if(unbind){
        FindText().BindWindow(0)
        bound:=False
    }
    if(!canTimeout){
	
        return login
    }
	return
}


; checks if there are any loaded saved accounts, and determines how many
checkForSaved(){
	Sleep, 300
	if(FindThisPixel(0x00CCFF,IDs[1],910,600,960,650,15,,,,False," check if no saved accounts in savedcheck")){
		return
	}
    ;if(FindThisText("|<>*133$90.tz0Ty0Qz3y03y07vzUTz0Tzbz0Dz07z7UQ7UTXzD0S3U7w1k01kS1w3UM1k7s1k01kQ1k3Us1k0s1k01kQ0k3Uk1k0s1k1zkQ0k3Uk0k0s1kDzkQ0k3Vzzk0s1kTVkQ0k3Vzzk0s1kw1kQ0k3Vk000s1ks1kQ0k3Uk000s1ks1kQ0k3Us000s1ks1kQ0k3Us000s1ks3kQ0k3Uw0E7s1kwDkQ0k3UT3k7s1kTzkQ0k3UDzk7s1kDtkQ0k3U3z07U",IDs[1],,,,.25,delay,"check if no saved accounts",,,,,False,505,328,595,345,False)){ 
    FindThisText("|<>*200$18.zzzzzzzzzDzsDzsDzs1zU1zU0Q00Q00Q0U", IDs[1],,,,5, delay, "known user dropdown in savedCheck",,,,,,850,442,868,453)
    if(reboot){
		return
	}
	Sleep, delay + 15
	savedAccounts:=4
	  ;while(!FindThisText(IDs[1], "|<>*140$46.s0Q00003U1k0000C0700000s0Q00003U1k0000C070y07ks0QDy1znU1kkQC3i0770kk6s0QQ070TU1ks0M0y073y1zzs0Q3y7zzU1k1wM060600tk0M0MQ1b01k3VkCC1nUQ3VkwC7zU7z1zk7s0Dk1y8",,,,.25,delay,"find bottom of saved accounts",,,,,False,582,689,628,709,False)){
	  while(FindThisPixel(0xABAFB0,IDs[1],870,680,870,680,25,,,0,False," checking number of saved accounts",,False)){   
		savedAccounts++
        ControlSend,, {PgDn}, % "ahk_id " . IDs[1]
		Sleep, delay + 15
	}
	return
}



FindThisPixel(pixel,hwnd,x1,y1,x2,y2,var,unbind:=False, click:=false,customPixelOffset:=-1,canWait:=True, errorMessage:="",waitTime:=7500, automaticMinCheck:=True,offset:=0){
	WinGet, minMax, MinMax, % "ahk_id " . hwnd 
	if((!(minMax+1))&&minMax!=""){ ; no minimizy.,. 
		WinGet, currID, ID, A ; get ID of current window focus
		DllCall("user32\ShowWindow", "Ptr",hwnd,"Int",4)
		WinActivate, % "ahk_id " currID
	}
	if(customPixelOffset=-1){
		customPixelOffset:=pixelOffset
	}
    VarSetCapacity(rect, 16, 0)
	DllCall("user32\GetClientRect", Ptr, hwnd, Ptr, &rect)
	DllCall("user32\ClientToScreen", Ptr, hwnd, Ptr, &rect)
	clW := NumGet(&rect, 8, "Int") ;*(96/A_ScreenDPI)
	clH := NumGet(&rect, 12, "Int") ;*(96/A_ScreenDPI)
	grayX:=((clW/clH)>1.375?clW-(clH*1.375):0)
	grayY:=((clW/clH)>1.375?0:clH-(clW/1.375))
	realclW:=clW-grayX
	realclH:=clH-grayY
	zoomX:=realclW/1375
	zoomY:=realclH/1000
	x1:=x1*zoomX
	y1:=y1*zoomY
	x2:=x2*zoomX
	y2:=y2*zoomY
	customPixelOffset:=zoomX*customPixelOffset
	x1-=(customPixelOffset*(1+zoomX))
	x1+=grayX/2
	y1-=customPixelOffset*(1+zoomY)
	y1+=grayY/2
	x2+=(customPixelOffset*(1+zoomX))+(grayX/2)
	y2+=(customPixelOffset*(1+zoomY))+(grayY/2)
	x1:=Round(x1) ;*(96/A_ScreenDPI)
	y1:=Round(y1)-offset ;*(96/A_ScreenDPI)
	x2:=Round(x2) ;*(96/A_ScreenDPI)
	y2:=Round(y2)-offset ;*(96/A_ScreenDPI)
	;WinGetPos, testX, testY, testWidth, testHeight, % "ahk_id " hwnd
	;MsgBox, %testX% %testY% %testWidth% %testHeight%
	if(!bound){
	    FindText().BindWindow(hwnd, 2)
        bound:=True
    }
	FindText().ClientToScreen(sx1,sy1,x1,y1,hwnd)
	FindText().ClientToScreen(sx2,sy2,x2,y2,hwnd)
    currTime:=A_TickCount
	pixelFound:=FindText().PixelSearch(tempx,tempy,sx1,sy1,sx2,sy2,pixel,var)
    if((canWait)){
		while(!(pixelFound:=FindText().PixelSearch(tempx,tempy,sx1,sy1,sx2,sy2,pixel,var))){
			if((A_TickCount-currTime)>waitTime){
				reboot(errorMessage,hwnd)
				return
        	}
		}
    }
	if(click){
		FindText().ScreenToWindow(wx1,wy1,sx1,sy1,hwnd)
		FindText().ScreenToWindow(wx2,wy2,sx2,sy2,hwnd)
		centX:=(wx1+((wx2-wx1)//2)) ;*(96/A_ScreenDPI)
		centY:=(wy1+((wy2-wy1)//2)) ;*(96/A_ScreenDPI)
		KeyWait, LButton
		ControlClick, % "x" . centX . " y" . centY, % "ahk_id " . hwnd,,,, NA
		Sleep, 50 + delay
		KeyWait, LButton
		ControlClick, % "x" . centX . " y" . centY, % "ahk_id " . hwnd,,,, NA
		Sleep, delay + 15
	}
    if(unbind){
        FindText().BindWindow(0)
        bound:=False
    }
	if(!click){
	
		return pixelFound
	}

    return
}

; functions winGetPosEx and WinMoveEx from user 'plankoe' on reddit, adapted slightly

; sets vals for the exact position/size of window when its borders are ignored
WinGetPosEx(byref X:="", byref Y:="", byref W:="", byref H:="", hwnd:="") {
    static DWMWA_EXTENDED_FRAME_BOUNDS := 9
    if (hwnd = "")
        hwnd := WinExist() ; last found window
    if hwnd is not integer
        hwnd := WinExist(hwnd)
    RECTsize := VarSetCapacity(RECT, 16, 0)
    DllCall("dwmapi\DwmGetWindowAttribute"
            , "ptr" , hwnd
            , "uint", DWMWA_EXTENDED_FRAME_BOUNDS
            , "ptr" , &RECT
            , "uint", RECTsize
            , "uint")
    X := NumGet(RECT, 0, "int")
    Y := NumGet(RECT, 4, "int")
    W := NumGet(RECT, 8, "int") - X
    H := NumGet(RECT, 12, "int") - Y
}


; Move window and fix offset from invisible border using WinGetPosEx
WinMoveEx(X:="", Y:="", W:="", H:="", hwnd:="") {
    if hwnd is not integer
        hwnd := WinExist(hwnd)
    if (hwnd = "")
        hwnd := WinExist()
    ; compare pos and get offset
    WinGetPosEx(fX, fY, fW, fH, hwnd)
    WinGetPos wX, wY, wW, wH, % "ahk_id " hwnd
    xDiff := fX - wX
    hDiff := wH - fH
    nX := nY := nW := nH := ""
    pixel := 1
    ; new X, Y, W, H with offset corrected
    (X!="") && nX := X - xDiff - pixel
    (Y!="") && nY := Y - pixel
    (W!="") && nW := W + (xDiff + pixel) * 2
    (H!="") && nH := H + hDiff + (pixel * 2)
    WinMove % "ahk_id" hwnd,, nX, nY, nW, nH
	if(!windowSizeGet){
		return [nW, nH]
	}
	
}



ButtonClose:
	Gui, Destroy
	return

;DllCall( "SetWindowPos", UInt,hwnd,Int,1,Int,startingclX,Int,startingclY,Int,startingWidth,Int,startingHeight,UInt,0x14 )
	
reboot(error, hwnd){
	WinSet, Transparent, 255, % "ahk_id " . hwnd
	WinSet, Transparent, off, % "ahk_id " . hwnd
	FileAppend, %error%, errorLog.txt
	Gui, +ToolWindow +AlwaysOnTop -Caption +Border +LastFound
	Gui, Add, Text, y40 w300 Center, %  "Something went wrong! Error type: " . error . "`n`nThis error message will be logged in the same directory as the script.`n`nThe sim will now reboot..."
	Gui, Add, Button, x270 y0 w60 h30 Default, Close
	Gui, Show, NoActivate
	guiID:=WinExist()
	currTime:=A_TickCount
	while(((A_TickCount-currTime)<5000)&&WinExist("%" "Ahk_id " guiID)){
	}
	if(WinExist("%" "Ahk_id " guiID)){
		Gui, Destroy
	}
	FindText().BindWindow(0)
	bound:=False
	reboot:=True
	resetConsec++
	resetTotal++
	timeLost:=0
	return
}
