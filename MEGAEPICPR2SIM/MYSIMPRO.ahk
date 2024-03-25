﻿; NEED TO ADD
;-CALIBRATION
;-FINDTEXT(), WITH BIND
;-BETTER SETUP/GUI

; features I hope to add
;-GUI for INI options/setup
;-TREAT PR2 AS A MENU, CONTROLSEND TAB OPTIONS, INCREASE RELIABILITY? (DLL, UIA, POSTMESSAGE, SENDMESSAGE)
;-figure out syntax for winTitle, ahk_pid to pull values from an array without needing temp val (impossible with arrays?)
;-each isntacne has its own width/height, dont call updateDims if it hasnt changed, then 'set standard' for future reboots aka apply to starting variables
;-combine text and blind modes in disconnect func if possible
;-extra mode to allow instances to be hidden/minimized during sim idle
;use if getKeyState to fix overlapping key issues?
;-multi-monitor/multi-display start
;-remove checkDisconnects dependency on the clipboard and copying
;-add delay variables in opening setup
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
SendMode Input
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, 3 ; forces perfect title match


; initiate globals, avoids extra paramaters
global accounts:=[{}]
global IDs:=[]
;global redoSetup:=False
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
setup()
SetControlDelay, 1 + (delay//10) ;delay after each controlClick 
SetKeyDelay, 1 + (delay//10), 0 ; delay after text input/key press
SetWinDelay, 1 + (delay//10) ; delay after win function (needs testing with other setups)
return




;Hotkeys!


#F9::
    MsgBox, See you soon! Go use those shiny new ranks!
	Loop, 4{
		WinClose, % "ahk_id " . IDs[A_Index]
	}
    ExitApp
#F10::
    Pause, Toggle
    return
#F11::
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
		if(resetConsec=3){
			MsgBox, 0, Donezo.., Something is SERIOUSLY messed up.. are the servers down?`n`nThe script will now close
			Loop, 4{
				WinClose, % "ahk_id " . IDs[A_Index]
			}
			ExitApp
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
	Loop{
		if(checkHappyHour()){
			loginSome(True) 
		}
        FindTheseTexts(star,, True, delay, 5, "Level queue")
		if(reboot){
			return
		}
        FindTheseTexts("|<>*152$19.wU0FE08fqAJ9/mQZ1GCUd6ELX001001W",,, delay, 5, "level play")
		if(reboot){
			return
		}
        shout()
		Sleep, 118000 ; Sleep till 1:58 (big exp)
		FindThisText("|<>*121$18.S0+n02V9DV9+V9+Z9+r9+Tj/U", IDs[1],,, True,5, delay, "quit 1") ;quit1
		if(reboot){
			return
		}
		ControlSend,, {Space down}, % "ahk_id " . IDs[2] ;slash2
		Sleep, 75 + (delay//5)
		ControlSend,, {Space up}, % "ahk_id " . IDs[2]
		Sleep, 2650 ;wait for dude 2
		KeyWait, LButton
		FindThisText("|<>*121$18.S0+n02V9DV9+V9+Z9+r9+Tj/U", IDs[2],,, True,5, delay, "quit 2") ;quit 2
		if(reboot){
			return
		}
		ControlSend,, {Space down}, % "ahk_id " . IDs[3] ; slash 3
		Sleep, 75 + (delay//5)
		ControlSend,, {Space up}, % "ahk_id " . IDs[3] 
		Sleep, 2750 ; wait for dude 3
		KeyWait, LButton
		FindThisText("|<>*121$18.S0+n02V9DV9+V9+Z9+r9+Tj/U", IDs[3],,, True,5, delay, "quit 3") ;quit 3
		if(reboot){
			return
		}
		ControlSend,, {Space down}, % "ahk_id " . IDs[4] ;slash 4
		Sleep, 75 + (delay//5)
		ControlSend,, {Space up}, % "ahk_id " . IDs[4]
		Sleep, 2850 ;wait for dude 4
		KeyWait, LButton
		FindThisText("|<>*121$18.S0+n02V9DV9+V9+Z9+r9+Tj/U", IDs[4],,, True,5, delay, "quit 4") ;quit 4
		if(reboot){
			return
		}
        FindTheseTexts("|<>*141$29.U0UU1011023nnqA4YYYc99ddEGHHCUYYYNxltsk0001000068",,, delay, 5, "return to lobby")
		if(reboot){
			return
		}
        totalRuns++
		resecConsec:=0
		;repeat
	} 
	return
}

; experiemental sim on Delicious Experience's sim level. Gives 'player 4' the outfit reward, and finishes ~7 seconds faster than U's sims, if the server is not lagging
; requires 46 jump, high speed and high accel set on loadout 9.
macroExperimental(){
	Loop{
		if(checkHappyHour()){
			loginSome(True) 
		}
		FindTheseTexts(star,, True, delay + 10, 5, "Level queue")
		if(reboot){
			return
		}
		FindTheseTexts("|<>*152$19.wU0FE08fqAJ9/mQZ1GCUd6ELX001001W",,, delay + 10, 5, "level play") ; , 130, 200, 200, 290)
		if(reboot){
			return
		}
		shout()
		Sleep, 118500 ; Sleep till 2 minutes (big exp)
		FindThisText("|<>*121$18.S0+n02V9DV9+V9+Z9+r9+Tj/U", IDs[1],,, True,5, delay + 50, "quit 1") ;quit 1
		if(reboot){
			return
		}
		ControlSend,, {Space down}, % "ahk_id " . IDs[2] ;
		Sleep, 50 + (delay//5)								  ; slash 2
		ControlSend,, {Space up}, % "ahk_id " . IDs[2]   ;
		;FindThisText("|<>*111$23.01000DU01zk03zk0Dzs0Tzs0zzs1zzs3zzs7zzkDzzUTzw0zzU1zs07z00zs07z00Ts00y001", IDs[2],,, True,5, delay, "hat wait instance 2") ; wait for hat
		Sleep, 300
		FindThisText("|<>*143$29.TzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzbzzzyTzzzxzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk", IDs[2],,,,5,, "hat wait instance 2",,,, "wait0",,,,,, false, 0) ; wait for hat
		if(reboot){
			return
		}
		ControlSend,, {Up down}{Right down}, % "ahk_id " . IDs[2] ; start move 2
		FindThisText("|<>*116$40.03s000k0kk00TXs1U0T6S060D0Bk88D01q00X00Tk1X00Dn06007sC0001w0s000z03U00TU0C00Dk00s03w003U1y000C0z0000sDk0003Us0000C300000sA000030k0000A3U0000kC000030s0000A7U0000kS000033k0000AC00000nk00003S00000Ds00000y000003k000006000000U", IDs[2],,,,5,, "gun wait 1 instance 2",,,,,,,,,,false) ; wait for gun
		Sleep, delay + 100
		if(reboot){
			return
		}
		ControlSend,, {Left Down}{Space down}, % "ahk_id " . IDs[2] ; 
		Sleep, 50 + (delay//5)													 ; gun back 2
		ControlSend,, {Left Up}{Space up}, % "ahk_id " . IDs[2] 	 ;
		FindThisText("|<>*102$10.7Uz7yzzzzzzxzby7U000000007Vzbyzzzzzzxzby7U000000007Vzbyzzzzzzxzby7W", IDs[2],,,,5,, "gun wait 2 instance 2",,,,,,,,,,false) ; wait for gun reload
		Sleep, delay + 100
		if(reboot){
			return
		}
		ControlSend,, {Left Down}{Space down}, % "ahk_id " . IDs[2] ;
		Sleep, 50 + (delay//5)													 ; gun back 2
		ControlSend,, {Left Up}{Space up}, % "ahk_id " . IDs[2] 	 ;
		Sleep, 375
		ControlSend,, {Up up}{Right up}, % "ahk_id " . IDs[2] ; stop move 2
		FindThisText("|<>*121$18.S0+n02V9DV9+V9+Z9+r9+Tj/U", IDs[2],,, True,5, delay + 50, "quit 2") ;quit 2
		if(reboot){
			return
		}
		ControlSend,, {Space down}, % "ahk_id " . IDs[3] ;
		Sleep, 50 + (delay//5)										  ; slash 3
		ControlSend,, {Space up}, % "ahk_id " . IDs[3]   ;
		;FindThisText("|<>*111$23.01000DU01zk03zk0Dzs0Tzs0zzs1zzs3zzs7zzkDzzUTzw0zzU1zs07z00zs07z00Ts00y001", IDs[3],,, True,5, delay, "hat wait instance 3") ; wait for hat
		Sleep, 300
		FindThisText("|<>*143$29.TzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzbzzzyTzzzxzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk", IDs[3],,,,5,, "hat wait instance 3",,,, "wait0",,,,,, false, 0) ; wait for hat
		if(reboot){
			return
		}
		ControlSend,, {Up down}{Right down}, % "ahk_id " . IDs[3] ; move 3
		FindThisText("|<>*116$40.03s000k0kk00TXs1U0T6S060D0Bk88D01q00X00Tk1X00Dn06007sC0001w0s000z03U00TU0C00Dk00s03w003U1y000C0z0000sDk0003Us0000C300000sA000030k0000A3U0000kC000030s0000A7U0000kS000033k0000AC00000nk00003S00000Ds00000y000003k000006000000U", IDs[3],,,,5,, "gun wait 1 instance 3",,,,,,,,,, false) ; wait for gun
		Sleep, delay + 100
		if(reboot){
			return
		}
		ControlSend,, {Left Down}{Space down}, % "ahk_id " . IDs[3] ; 
		Sleep, 50 + (delay//5)													 ; gun back 3
		ControlSend,, {Left Up}{Space up}, % "ahk_id " . IDs[3] 	 ;
		FindThisText("|<>*102$10.7Uz7yzzzzzzxzby7U000000007Vzbyzzzzzzxzby7U000000007Vzbyzzzzzzxzby7W", IDs[3],,,,5,, "gun wait 2 instance 3",,,,,,,,,,false) ; wait for gun reload
		Sleep, delay + 100
		if(reboot){
			return
		}
		ControlSend,, {Left Down}{Space down}, % "ahk_id " . IDs[3] ;
		Sleep, 50 + (delay//5)													 ; gun back 3
		ControlSend,, {Left Up}{Space up}, % "ahk_id " . IDs[3] 	 ;
		Sleep, 400
		ControlSend,, {Up up}{Right up}, % "ahk_id " . IDs[3] ; stop moving 3
		FindThisText("|<>*121$18.S0+n02V9DV9+V9+Z9+r9+Tj/U", IDs[3],,, True,5, delay + 50, "quit 3") ;quit 3
		if(reboot){
			return
		}
		ControlSend,, {Space down}, % "ahk_id " . IDs[4] ;
		Sleep, 50 + (delay//5)										  ; slash 4
		ControlSend,, {Space up}, % "ahk_id " . IDs[4]   ;
		;FindThisText("|<>*111$23.01000DU01zk03zk0Dzs0Tzs0zzs1zzs3zzs7zzkDzzUTzw0zzU1zs07z00zs07z00Ts00y001", IDs[4],,, True,5, delay, "hat wait instance 4") ; wait for hat
		Sleep, 300
		FindThisText("|<>*143$29.TzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzbzzzyTzzzxzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk", IDs[4],,,,5,, "hat wait instance 4",,,, "wait0",,,,,, false, 0) ; wait for hat
		if(reboot){
			return
		}
		ControlSend,, {Up Down}{Right down}, % "ahk_id " . IDs[4] ; move 4
		FindThisText("|<>*116$40.03s000k0kk00TXs1U0T6S060D0Bk88D01q00X00Tk1X00Dn06007sC0001w0s000z03U00TU0C00Dk00s03w003U1y000C0z0000sDk0003Us0000C300000sA000030k0000A3U0000kC000030s0000A7U0000kS000033k0000AC00000nk00003S00000Ds00000y000003k000006000000U", IDs[4],,,,5,, "gun wait 1 instance 4",,,,,,,,,,false) ; wait for gun
		Sleep, delay + 100
		if(reboot){
			return
		}
		ControlSend,, {Left Down}{Space down}, % "ahk_id " . IDs[4] ; 
		Sleep, 50 + (delay//5)													 ; gun back 4 (3rd layer)
		ControlSend,, {Left Up}{Space up}, % "ahk_id " . IDs[4] 	 ;
		while((!(FindText(X:="wait", Y:=.1,0,0,0,0,0,0,"|<>*141$29.U0UU1011023nnqA4YYYc99ddEGHHCUYYYNxltsk0001000068")))&&(simType=1)){
			FindThisText("|<>*102$10.7Uz7yzzzzzzxzby7U000000007Vzbyzzzzzzxzby7U000000007Vzbyzzzzzzxzby7W", IDs[4],,,,.1,, "gun wait reload instance 4",,,,,False,,,,,False) ; wait for gun reload
			Sleep, delay + 50
			ControlSend,, {Left Down}{Space down}, % "ahk_id " . IDs[4] ;
			Sleep, 50 + (delay//5)													 ; gun back 4 (3rd layer)
			ControlSend,, {Left Up}{Space up}, % "ahk_id " . IDs[4] 	 ;
			Sleep, delay + 25
		}
		if(simType=2){
			Sleep, 400
			FindThisText("|<>*121$18.S0+n02V9DV9+V9+Z9+r9+Tj/U", IDs[4],,, True,5, delay + 50, "quit 4") ;quit 4
		}
		ControlSend,, {Up up}{Right up}, % "ahk_id " . IDs[4] ; stop moving 4
		FindText().BindWindow(0)
		bound:=False
		FindTheseTexts("|<>*141$29.U0UU1011023nnqA4YYYc99ddEGHHCUYYYNxltsk0001000068",,, delay, 5, "return to lobby") ; return to lobby
		if(reboot){
			return
		}
		totalRuns++
		resecConsec:=0
	}
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
			startingWidth:=wW-(borderThickness*2)
            startingHeight:=wH-(borderThickness)
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
    FindTheseTexts("|<>*39$16.164nNbRiRqtrPbRaRq7zvzzjU", 2,, delay, 5, "main double click after load") ;past main menu then mute
	if(reboot){
		return
	}
	Sleep, 50 + delay
	FindTheseTexts("|<>*146$34.00010000061008EA203UUE80u31UDy8421UEUE861m1UUM78621zwUE87zm11UTz8A630SUUE80S631U0sEM600010k0004600000E000012",,, delay, 5, "mute instance")
	if(reboot){
		return
	}
}

; logs in all accounts in array 'instances' on currentServer
loginSome(logoutFirst:=False){
	Loop, 4{
        loopID:=IDs[A_Index]
		if(logoutFirst){ ; if changing servers mid sim
			FindThisText("|<>*149$32.U0000c0000+3nvmLUYaYYcNdtd+6OSOGUYaYYjjDjDA00E0000w008", loopID,,,,5, delay + 250, "logout button")  ; logout button
			if(reboot){
				return
			}
		}
		FindThisText("|<>*164$19.U00E0083Vg3ty35X12lUVMkNYTrXs00400y00SU", loopID,,,,5, delay + 250, "login main menu")  ; login button
		if(reboot){
			return
		}
        if(!savedAccountsGet){
            checkForSaved() ; checks for any saved accounts
            FindThisText("|<>*117$7.zjXUW", loopID,,,,5, delay, "menu bar undo checkForSaved dropdown") ; click back on menu
			if(reboot){
				return
			}
            savedAccountsGet:=True
        }
		if(savedAccounts){
			FindThisText("|<>*117$7.zjXUW", loopID,,,,5, delay, "known users dropdown post saved check") ; known users list
			if(reboot){
				return
			}
			ControlSend,, {PgDn}, % "ahk_id " . loopID
            if(savedAccounts>5){
				Sleep, delay
			    ControlSend,, % "{PgDn " . savedAccounts-5 . "}", % "ahk_id " . loopID ; reveal and select 'use other account', extra pgdn inputs if lots of saved accounts
            }
			KeyWait, Shift
			ControlSend,, {Enter}, % "ahk_id " . loopID
			Sleep, delay + 250
		}
        if(currentServer!="Derron"){
            FindThisText("|<>*117$7.zjXUW", loopID,,,,5, delay, "server list dropdown")  ;server list
			if(reboot){
				return
			}
			Loop, 4{
				if(serverList[A_Index]=currentServer){ ; locates index of servername and presses down accordingly
					Loop, % (A_Index-1){
						ControlSend,, {down}, % "ahk_id " . loopID ; pick server
						Sleep, delay
					}
					KeyWait, Control
					ControlSend,, {Enter}, % "ahk_id " . loopID
					break
				}
			}
        }
        FindThisText("|<>*241$110.zzzzzzzzzzzzzzzzzzs000000000000000006000000000000000001U00000000000000000M000000000000000006000000000000000001U00000000000000000M000000000000000006000000000000000001U00000000000000000M000000000000000006000000000000000001U00000000000000000M000000000000000006000000000000000001U00000000000000000M000000000000000006000000000000000001U00000000000000000M000000000000000006000000000000000001zzzzzzzzzzzzzzzzzzs", loopID,,,,5, 250 + delay, "user text field")  ; user field
		if(reboot){
			return
		}
		KeyWait, Shift
		ControlSend,, % "{text}" . accounts[A_Index].username, % "ahk_id " . loopID ; type username
		Sleep, delay + 250
		FindThisText("|<>*241$110.zzzzzzzzzzzzzzzzzzs000000000000000006000000000000000001U00000000000000000M000000000000000006000000000000000001U00000000000000000M000000000000000006000000000000000001U00000000000000000M000000000000000006000000000000000001U00000000000000000M000000000000000006000000000000000001U00000000000000000M000000000000000006000000000000000001U00000000000000000M000000000000000006000000000000000001zzzzzzzzzzzzzzzzzzs", loopID,,,,5, 250 + delay, "pass text field")	;move to pass field
		if(reboot){
			return
		}
		KeyWait, Shift
		ControlSend,, % "{text}" . accounts[A_Index].password, % "ahk_id " . loopID ; type password
		Sleep, delay
        FindThisText("|<>*145$27.U0044000UUwQ5w4YUdUYY5A4YUdUYY5Dr3Ud0040007U0U", loopID,,, True,5, delay, "login to game") ; login
		if(reboot){
			return
		}
		if(A_Index=2){
			Sleep, 5000 + (delay*10) ; too fast boiii
		}
		
	}
}

; brings specified instance(s) from the page past login to the sim
levelPrep(){
    Loop, 4{
        loopID:=IDs[A_Index]
        FindThisText(Text:="|<>*230$13.1k7z7zrzzzzzzzzzzzzzzzzyzy7w1w8", loopID,,,,5, delay + 100, "hat menu") ; click (?) for hats
        if(reboot){
			return
		}
		FindThisText(Text:="|<>*172$52.0000k00000007k0000003zk000000zzk00000Dzzk00000zzzk00007zzzk0000zzzzk0003zzzzU000Tzzzz0001zzzzy0007zzzzw000zzzzzs003zzzzzk00DzzzzzU00zzzzzz003zzzzzy00Dzzzzzw00zzzzzzk03zzzzzzU0Dzzzzzy00zzzzzzs03zzzzzzk0Dzzzzzy00Tzzzzz001zzzzzk007zzzzw000Tzzzy0001zzzzU0007zzzs0000zzzw00007zzz00001zzzk0000Dzzs00007zzy00001zzzU0000Tzzs00003zzy00000DzzU00000zzs000003zw0000007z0000000Dk0000002", loopID,,,,5, delay + 100, "click exp hat") ; exp hat
		if(reboot){
			return
		}
		FindThisText(Text:="|<>*152$25.w00UE0008D9/rYYZ+4GGb299HUYYdSSSLU10200U12", loopID,,,,5, delay + 400, "equip exp hat") ; click equip
		if(reboot){
			return
		}
		FindThisText(Text:="|<>*153$7.zMksssM4634", loopID,,-1,,5, delay + 300, "click hat color", 14) ; hat color
		if(reboot){
			return
		}
		FindThisText(Text:="|<>*202$56.zzzzzzzzzk000000004000000001000000000E000000004000000001000000000E000000004000000001000000000E000000004000000001000000000E000000004000000001000000000E000000004000000001000000000E000000004000000001000000000M", loopID,2,,,5, delay, "click color Hex Text box") ; color hex text
		if(reboot){
			return
		}
		ControlSend,, {text}#000000, % "ahk_id " . loopID ; black color
		Sleep, delay
		FindThisText("|<>*153$14.S8wmG4cVC8Gm4Yn8bWC", loopID,,,,5, delay, "confirm hat color") ; OK button for hat color
		if(reboot){
			return
		}
		FindThisText(Text:="|<>*153$7.zMksssM4634", loopID,,-2,,5, delay + 300, "click hat color", 14) ; hat color
		if(reboot){
			return
		}
		FindThisText(Text:="|<>*202$56.zzzzzzzzzk000000004000000001000000000E000000004000000001000000000E000000004000000001000000000E000000004000000001000000000E000000004000000001000000000E000000004000000001000000000E000000004000000001000000000M", loopID,2,,,5, delay, "click color Hex Text box") ; color hex text
		if(reboot){
			return
		}
		ControlSend,, {text}#000000, % "ahk_id " . loopID ; black color
		Sleep, delay + 25
		FindThisText("|<>*153$14.S8wmG4cVC8Gm4Yn8bWC", loopID,,,,5, delay + 10, "confirm hat color") ; OK button for hat color
		if(reboot){
			return
		}
		FindThisText("|<>*116$18.k00k00000nwTnwvnBnnBnnAnnAznAT00300z00QU", loopID,2,-2,,5, delay + 10, "ing locator for stats", 34) ; change stats
		if(reboot){
			return
		}
		ControlSend,, {text}0, % "ahk_id " . loopID ; 0 accel
		FindThisText("|<>*116$18.k00k00000nwTnwvnBnnBnnAnnAznAT00300z00QU", loopID,2,-3,,5, delay + 10, "ing locator for stats", 34) ; change stats
		if(reboot){
			return
		}
		ControlSend,, {text}46, % "ahk_id " . loopID ; 46 jump
		FindThisText("|<>*116$18.k00k00000nwTnwvnBnnBnnAnnAznAT00300z00QU", loopID,2,-1,,5, delay + 10, "ing locator for stats", 34) ; change stats
		if(reboot){
			return
		}
		ControlSend,, {text}100, % "ahk_id " . loopID ; 100 speed
		FindThisText("|<>*116$18.k00k00000nwTnwvnBnnBnnAnnAznAT00300z00QU", loopID,2,-2,,5, delay + 10, "ing locator for stats", 34) ; change stats
		if(reboot){
			return
		}
		ControlSend,, {text}100, % "ahk_id " . loopID ; remainder accel
		FindThisText("|<>*186$25.000E000800047ltvwAlZa2FUVT8kEkYM8Mm6IDt1u6", loopID,,,,5, delay, "search tab") ; search tab
		if(reboot){
			return
		}
		FindThisText("|<>*141$22.W0028008bXbWGGG9lx8VY4anGFlst8", loopID,,,,5, delay, "search by dropdown") ;search by dropdown
		if(reboot){
			return
		}
		FindThisText("|<>*152$8.j++WcuCWcfm", loopID,,,,5, delay, "level ID type") ; level ID
		if(reboot){
			return
		}
		FindThisText("|<>*220$142.zzzzzzzzzzzzzzzzzzzzzzzy00000000000000000000000M00000000000000000000001U0000000000000000000000600000000000000000000000M00000000000000000000001U0000000000000000000000600000000000000000000000M00000000000000000000001U0000000000000000000000600000000000000000000000M00000000000000000000001U0000000000000000000000600000000000000000000000M00000000000000000000001U0000000000000000000000600000000000000000000000M00000000000000000000001U0000000000000000000000600000000000000000000000M00000000000000000000001zzzzzzzzzzzzzzzzzzzzzzzy", loopID,,,,5, delay, "search text box") ;click text box
		if(reboot){
			return
		}
		ControlSend,,% "{text}" . levelID, % "ahk_id " . loopID ; enter sim ID
		Sleep, delay
		FindThisText("|<>*136$78.0001k00040000000280004000000020ttnbU0000003V994oU0000000Nwt44U000U000B1944U001U0029994IU001U003stt3YU001U000000000001U000000000001U000000000001U000000000001U000000000001E000000000003DzzzzzzzzzzzyU", loopID,,, True,5, delay, "search button") ; search button
		if(reboot){
			return
		}
	} 
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
    Loop, 2 {
		FindThisText("|<>*134$105.zzzzzzzzzzzzzzzzzw00000000000000001U0000000000000000A00000000000000001U0000000000000000A00000000000000001U0000000000000000A00000000000000001U0000000000000000A00000000000000001U0000000000000000A00000000000000001U0000000000000000A00000000000000001U0000000000000000A00000000000000001U0000000000000000A00000000000000001U0000000000000000DzzzzzzzzzzzzzzzzzU", IDs[A_Index],,, True,5, delay)
	    if(reboot){
			return
		}
		if(A_Index=1){
			Sleep, delay
			ControlSend,, % "{text}We have broken " . resetTotal . " times! Epic!", % "ahk_id " . IDs[A_Index]
		}
		else{
			Sleep, delay
			ControlSend,, % "{text}We've simmed " . totalRuns .  " times over " . ((A_TickCount-currentTick)//3600000) . " hours and " . Mod(((A_TickCount-currentTick)//60000), 60) . " minutes. Wowzers!", % "ahk_id " . IDs[A_Index]
		}
		Sleep, delay
		KeyWait, Control
		ControlSend,, {Enter}, % "ahk_id " . IDs[A_Index]
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
        details:={whichmonitor:whichMonitor, startingheight:startingHeight, startingwidth:startingWidth, levelid:levelID, simtype:simType, pr2location:pr2Location, user1:user1, pass1:pass1, user2:user2, pass2:pass2, user3:user3, pass3:pass3, user4:user4, pass4:pass4, delay:delay}   
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
				Goto, getUserInfo1
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
	MsgBox, 0, PR2 is cool, Windows+F12`: begin the sim`nWindows+F11: reload the script`nWindows+F10: pause the script`nWindows+F9: end the script`nWindows+h: show all hotkeys`n`nHappy simming and stay epic B-)
    

    ;Add GUI which shows the accessible hotkeys
    ;Gui, Add, Button, x10 y10 w100 h30 gShowHotkeys, Hotkeys
    ;Gui, Show, w120 h50, Hotkeys GUI

}

; performs the same action on every instance to reduce the time loss from waiting for a server response; starts server API requests as early as possible
FindTheseTexts(Text, repeat:=1, playing:=False, eep:=0, timeout:=-1, errorMessage:="", x1:=0, y1:=0, x2:=0, y2:=0){ 
	Loop, 4{
		FindThisText(Text, IDs[A_Index], repeat, playing?A_Index:0, True, timeout, eep, errorMessage,,,,,,x1, y1, x2, y2)
		if(reboot){
			return
		}
	}
}

; locates text through image processing (!!!) and clicks the daaang thaang
FindThisText(Text, hwnd, repeat:=1, index:=0, unbind:=False, timeout:=-1, eep:=0, errorMessage:="", offsetAmm:=16,xTol:=0, yTol:=0, wait:="wait",canTimeout:=True, x1:=0, y1:=0, x2:=0, y2:=0, click:=True, howMany:=1){
	WinGet, minMax, MinMax, % "ahk_id " . hwnd                                  ; prevent minimized windows (sorry)
	if(!(minMax+1)){
		WinRestore, % "ahk_id " . hwnd ; minimizing is illegal right now!!... sorry
		WinMaximize, % "ahk_id " . hwnd ; fix weird offset issue?
		WinRestore, % "ahk_id " . hwnd  ;
		WinSet, Bottom,, % "ahk_id " . hwnd ; hide behind instances
	}
	WinGetPos,,, currW, currH, % "ahk_id " . hwnd ; prevent resized windows (sorry)
	if((currW!=dims[1])||(currH!=dims[2])){
		WinGetTitle, tit, % "ahk_id " . hwnd
		instance:=SubStr(tit, 25, 1)
		WinMoveEx(locationx+((Mod(instance+1, 2))*startingWidth), locationy+(startingHeight*(instance-2>0 ? 1 : 0)), startingWidth, startingHeight, hwnd) ; move instance to adjusted coordinates (exclude border)
	}
	WinGetPos,currX,currY,,, % "ahk_id " . hwnd ; prevent resized windows (sorry)
	/*
	if(x1!=0){
		x1+=currX
	}
	if(y1!=0){
		y1+=currY
	}
	if(x2!=0){
		x2+=currX
	}
	if(y2!=0){
		y2+=currY
	}
	*/
    if(!bound){
	    FindText().BindWindow(hwnd, 1)
        bound:=True
    }
	login:=FindText(wait,timeout,x1,y1,x2,y2,xTol,yTol,Text,,howMany)
    if((!login)&&(canTimeout)){
		FileAppend,% errorMessage . ", ", errorLog.txt
		MsgBox, 0, like ZOINKS, % "Something went wrong! Error type: " . errorMessage . "`n`nThe sim will now reboot...", 5
		MsgBox, 0, like ZOINKS, Rebooting sim in 3..., 1
		MsgBox, 0, like ZOINKS, Rebooting sim 2..., 1
		MsgBox, 0, like ZOINKS, Rebooting sim 1 ..., 1
		FindText().BindWindow(0)
		bound:=False
		reboot:=True
		resetConsec++
		resetTotal++
		return
    }
	if(click){
		centX:=login[1][1]+login[1][3]//2
		centY:=(login[1][2]+login[1][4]//2)-((index)*offsetAmm)
		FindText().ScreenToWindow(clickX, clickY, centX, centY, hwnd)
		Loop, %repeat%{
			KeyWait, LButton
			ControlClick, % "x" . clickX . " y" . clickY, % "ahk_id " . hwnd,,,, NA
			Sleep, eep
    	}
	}
    if(unbind){
        FindText().BindWindow(0)
        bound:=False
    }
}


; checks if there are any loaded saved accounts, and determines how many
checkForSaved(){
    if(FindText("wait", .25, 0,0,0,0,0,0,"|<>*153$35.yTDj7X42NWF68Ql4X4HdW9y8YH4G0F8a8a9WTAF7n")){
        return
    }
    FindThisText("|<>*117$7.zjXUW", IDs[1],,,,5, delay, "known user dropdown in savedCheck")
    if(reboot){
		return
	}
	savedAccounts:=4
    while(!FindText("wait", .25, 0,0,0,0,0,0,"|<>*159$18.W00W00WSCWGGWQTW6EanGQSCU")){
        savedAccounts++
        ControlSend,, {PgDn}, % "ahk_id " . IDs[1]
		Sleep, delay
    }
	Sleep, delay
}



; funcctions winGetPosEx and WinMoveEx from user 'plankoe' on reddit, adapted slightly

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


