; NEED TO ADD
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
;-getOffset return, offset varies if window size varies(issue at high/lowresolutions)





; Important Notes:

;It is OK to move the instances around however you want but minimizing them will force an instance reboot if commands are sent while it is minimized (specifically controlClick commands)
; Making the instance TOO small will likely prevent certain clicks from aligning correctly (specifically queueing and playing the sim, I need to fix that function)
;TLDR: computer normal use-OK      moving instance(duringidle)-OK     stacking instances-OK     minimizing instance-NOT OK(instance will reboot and fix, will add functionality later)

;-May require you to run PR2/Autohotkey with administrator privelages! right click exe, compatability, run as admin. autohotkey's executable is not so obvious to locate

;-set key delay below might be a significant      factor towards whether the script is successful or not.... needs testing

;-Moving the instance while commands are being sent es no bueno





;end of instructions/warnings... All the pr2 experience you can dream of is now yours at the click of a button (and maybe a time machine)

;START THE SCRIPT WITH windows + F12. RELOAD THE SCRIPT WITH windows + F11





global localDelayMillis:=15 ; Add delay after every command sent to the game that's limited by your computer's speed. Play around with it. If things do not function correctly, this may be why (minimum of 1)
global serverDelayMillis:= 500 ; Add delay after every command sent to the game that's limited by your internet/distance from the server. (Illinois or something?) if things do not function correctly, this is most likely why

#Warn ; debugging
/*


if (!A_IsAdmin) {
    Run % "*RunAs " A_ScriptFullPath
    ExitApp
}
if (!FileExist(A_Temp "\ahk-install.exe")) {								; CALL THIS IF THEY DID NOT CLICK UI BUTTON
    UrlDownloadToFile https://www.autohotkey.com/download/ahk-install.exe
        , % A_Temp "\ahk-install.exe"
}
cmd := "timeout /t 1"
    . " & taskkill /F /IM AutoHotkey*.exe"
    . " & ahk-install.exe /S /uiAccess=1" (A_Is64bitOS ? " /U64" : "")
    . " & del ahk-install.exe"
Run % A_ComSpec " /C """ cmd """", % A_Temp
*/
/*


#SingleInstance Force ; of ~script~
if (!A_IsCompiled && !InStr(A_AhkPath, "_UIA")) {
	newPath := RegExReplace(A_AhkPath, "(U\d+)?\.exe", "U" (A_Is64bitOS ? 64 : 32) "_UIA.exe") ; restartss the script if it is not running with UI access
	Run % StrReplace(DllCall("GetCommandLine", "Str"), A_AhkPath, newPath)
    ExitApp
}
*/

#InstallMouseHook
#InstallKeybdHook
#MenuMaskKey vkE8 ; prevents windows menu from activating randomly
#HotkeyModifierTimeout 100
#KeyHistory, 500
;#include Acc.ahk
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, 3 ; forces perfect title match
SetControlDelay, localDelayMillis ;delay after each controlClick 
SetKeyDelay, 5, 0 ; delay after text input/key press
SetWinDelay, 1 ; delay after win function (needs testing with other setups)
;DetectHiddenWindows, On           ;will implement
; initiate globals, avoids extra paramaters
global accounts:=[{}]
global IDs:=[]
global redoSetup:=False
global filePath
global levelID
global savedAccounts
global whichMonitor
global repeatLoadoutWarning
global pr2Location
global startingWidth
global startingHeight
global titleBarHeight
global borderThickness
global windowSizeGet:=False
global instanceWidth
global instanceHeight
global offsetY
global offsetX
global locationx
global locationy
global clickRatios:={queueXRatio: .4646, queueYRatio: .4075, playOffsetRatio: .04, playXRatio: .3, playYRatio: .425, quitXRatio: .8273, quitYRatio: .95, lobbyXRatio: .6, lobbyYRatio: .825, muteXRatio: .9636, muteYRatio: .95, logoutXRatio: .7091, logoutYRatio: .95, loginMainXRatio: .5091, loginMainYRatio: .575, knownUsersXRatio: .5091, knownUsersYRatio: .45,serverListXRatio: .5091, serverListYRatio: .625, loginTextBoxXRatio: .5273, userFieldYRatio: .3375, searchTabXRatio: .9327, searchTabYRatio: .0325, searchByXRatio: .7, searchByYRatio: .1, levelTextFieldXRatio: .5812, levelTextFieldYRatio: .25} ; coord locations relative to pr2 active game window
global tempName
global pr2Monitor
global pr2MonitorLeft
global pr2MonitorRight
global pr2MonitorTop
global pr2MonitorBottom
global desktopWidth
global desktopHeight
global currentHour:=A_Hour	; reads system time
global serverInfoURL:="https://pr2hub.com/files/server_status_2.txt" 
global serverList:=["Derron", "Carina", "Grayan","Fitz"] ; stand-in associative array string:a_index
global currentServer:="Derron"
global instances:=[1, 2, 3, 4] ; called during most functions, changes when only specific instances are rebooted
global instancesRev:=[] 
global legal:=False
global iterations
setup()
return



;Hotkeys!



;F5::
	;UIA := UIA_Interface() ; Initialize UIA interface



;#F10:: ;# means windows key, so windows key + F10. Loads clipboard contents if they were lost by a script crashing during the clipboard copy paste juggling
;	FileRead, Clipboard, *c copyBackup.clip ; if clipboard contents are needed, hit this hotkey before starting the macro again. This loads your clipboard contents back
;	return
#F11::Reload ; reloads the script. Just close your pr2 instances if you want to start again, then hit F12
#F12::  ;basically does everything for you once you hit f12..


/*


	ComObjError(False)
	oAcc := Acc_ObjectFromPoint(vChildId)
	vAccRoleNum := oAcc.accRole(vChildId)
	vAccRoleNumHex := Format("0x{:X}", vAccRoleNum)
	vAccStateNum := oAcc.accState(vChildId)
	vAccStateNumHex := Format("0x{:X}", vAccStateNum)
	oRect := Acc_Location(oAcc, vChildId)
	oAcc := Acc_Get("Focused")
	tempName:="Adobe Flash Player 32"
	ControlSend,, {tab}, %tempName% ; enter in-level text menu
	MsgBox, % Acc_Get(accObject, "State")
	ComObjError(True)
	return
*/

	
/*
	run C:\Users\Troy\Desktop\Pr2\Platform Racing 2.exe
	WinWaitActive, ahk_exe Platform Racing 2.exe
	ID:= WinExist("ahk_pid" pid) ; define hex value of the instance's process ID to pass into winMoveEx(only likes hex?)
	DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", -3&=0xFFFFFFFF, "Ptr", -VarSetCapacity(IID,16)+NumPut(0x46000000000000C0,NumPut(0x0000000000020400,IID,"Int64"),"Int64"), "Ptr*", pacc)=0
	acc:=ComObjEnwrap(9,pacc,1)
	*/

;DllCall("LoadLibrary","Str","oleacc","Ptr")

	if(!legal){
		return
	}
	bootInstances() ;load all instances
	checkHappyHour() ; checks for happy hour
	loginSome() ;logs all 4 accounts in
	levelPrep(True) ; finds sim level
	Loop{
		macro() ; begins macro
	}
	return

; Contains everything to upkeep the sim after initial setup
macro(){
	Loop{
		if(checkHappyHour()){
			loginSome(True) 
		}
		clickSome("queueXRatio", "queueYRatio", "playOffsetRatio", 250) ; join queue
		clickSome("playXRatio", "playYRatio", "playOffsetRatio", 10) ; play
		Sleep, 2500
		if(checkDisconnects()){
			break
		}
		Sleep, 114250 ; Sleep till 1:58 (big exp)
		tempName:="Best Game Ever Instance 1"
		KeyWait, LButton
		ControlClick, % "x" . getXPos(clickRatios["quitXRatio"]) . " y" . getYPos(clickRatios["quitYRatio"]), %tempName%,,,, NA ;quit1
		tempName:="Best Game Ever Instance 2"
		ControlSend,, {Space down}, %tempName% ;slash2
		Sleep, 50
		ControlSend,, {Space up}, %tempName% 
		Sleep, 2650 ;wait for dude 2
		KeyWait, LButton
		ControlClick, % "x" . getXPos(clickRatios["quitXRatio"]) . " y" . getYPos(clickRatios["quitYRatio"]), %tempName%,,,, NA ;quit 2
		tempName:="Best Game Ever Instance 3"
		ControlSend,, {Space down}, %tempName% ; slash 3
		Sleep, 50
		ControlSend,, {Space up}, %tempName% 
		Sleep, 2750 ; wait for dude 3
		KeyWait, LButton
		ControlClick, % "x" . getXPos(clickRatios["quitXRatio"]) . " y" . getYPos(clickRatios["quitYRatio"]), %tempName%,,,, NA ;quit 3
		tempName:="Best Game Ever Instance 4"
		ControlSend,, {Space down}, %tempName% ;slash 4
		Sleep, 50
		ControlSend,, {Space up}, %tempName%
		Sleep, 2850 ;wait for dude 4
		KeyWait, LButton
		ControlClick, % "x" . getXPos(clickRatios["quitXRatio"]) . " y" . getYPos(clickRatios["quitYRatio"]), %tempName%,,,, NA ;quit 4
		Sleep, 50
		clickSome("lobbyXRatio", "lobbyYRatio", 10) ;return to lobby
		Sleep, serverDelayMillis
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
		clickSome("queueXRatio", "queueYRatio", "playOffsetRatio", 250) ; join queue
		clickSome("playXRatio", "playYRatio", "playOffsetRatio", 10) ; play
		Sleep, 2500
		if(checkDisconnects()){
			break
		}
		Sleep, 114000 ; Sleep till 2 minutes (big exp)
		tempName:="Best Game Ever Instance 1"
		ControlClick, % "x" . getXPos(clickRatios["quitXRatio"]) . " y" . getYPos(clickRatios["quitYRatio"]), %tempName%,,,, NA ;quit1
		Sleep, 100
		tempName:="Best Game Ever Instance 2"
		ControlSend,, {Space down}, %tempName% ;
		Sleep, 50									  ; slash 2
		ControlSend,, {Space up}, %tempName%   ;
		Sleep, 200
		ControlSend,, {Up down}{Right down}, %tempName% ; start move 2
		Sleep, 400
		ControlSend,, {Left Down}{Space down}, %tempName% ; 
		Sleep, 50												 ; gun back 2
		ControlSend,, {Left Up}{Space up}, %tempName% 	 ;
		Sleep, 150
		ControlSend,, {Left Down}{Space down}, %tempName% ;
		Sleep, 50												 ; gun back 2
		ControlSend,, {Left Up}{Space up}, %tempName% 	 ;
		Sleep, 400
		ControlSend,, {Up up}{Right up}, %tempName% ; stop move 2
		ControlClick, % "x" . getXPos(clickRatios["quitXRatio"]) . " y" . getYPos(clickRatios["quitYRatio"]), %tempName%,,,, NA ;quit2
		Sleep, 100
		tempName:="Best Game Ever Instance 3"
		ControlSend,, {Space down}, %tempName% ;
		Sleep, 50									  ; slash 3
		ControlSend,, {Space up}, %tempName%   ;
		Sleep, 200
		ControlSend,, {Up down}{Right down}, %tempName% ; move 3
		Sleep, 400
		ControlSend,, {Left Down}{Space down}, %tempName% ; 
		Sleep, 50												 ; gun back 3
		ControlSend,, {Left Up}{Space up}, %tempName% 	 ;
		Sleep, 150
		ControlSend,, {Left Down}{Space down}, %tempName% ;
		Sleep, 50												 ; gun back 3
		ControlSend,, {Left Up}{Space up}, %tempName% 	 ;
		Sleep, 300
		ControlSend,, {Up up}{Right up}, %tempName% ; stop moving 3
		ControlClick, % "x" . getXPos(clickRatios["quitXRatio"]) . " y" . getYPos(clickRatios["quitYRatio"]), %tempName%,,,, NA ;quit3
		Sleep, 100
		tempName:="Best Game Ever Instance 4"
		ControlSend,, {Space down}, %tempName% ;
		Sleep, 50									  ; slash 4
		ControlSend,, {Space up}, %tempName%   ;
		Sleep, 200
		ControlSend,, {Up Down}{Right down}, %tempName% ; move 4
		Sleep, 400
		ControlSend,, {Left Down}{Space down}, %tempName% ; 
		Sleep, 50												 ; gun back 4 (3rd layer)
		ControlSend,, {Left Up}{Space up}, %tempName% 	 ;
		Sleep, 200
		ControlSend,, {Left Down}{Space down}, %tempName% ;
		Sleep, 50												 ; gun back 4 (1st layer)
		ControlSend,, {Left Up}{Space up}, %tempName% 	 ;
		Sleep, 200
		ControlSend,, {Left Down}{Space down}, %tempName% ;
		Sleep, 50												 ; gun back 4 (1st layer)
		ControlSend,, {Left Up}{Space up}, %tempName% 	 ;
		Sleep, 200
		ControlSend,, {Left Down}{Space down}, %tempName% ;
		Sleep, 50												 ; gun back 4 (2nd layer)
		ControlSend,, {Left Up}{Space up}, %tempName% 	 ;
		Sleep, 400
		ControlSend,, {Left Down}{Space down}, %tempName% ;
		Sleep, 50												 ; gun back 4 (2nd layer)
		ControlSend,, {Left Up}{Space up}, %tempName% 	 ;
		Sleep, 200
		ControlSend,, {Left Down}{Space down}, %tempName% ;
		Sleep, 50												 ; gun back 4 (3rd layer)
		ControlSend,, {Left Up}{Space up}, %tempName% 	 ;
		Sleep, 700
		ControlSend,, {Up up}{Right up}, %tempName% ; stop moving 4
		clickSome("lobbyXRatio", "lobbyYRatio") ;return to lobby
		Sleep, serverDelayMillis
	}
	return
}


; brings user from empty desktop, to 4 intentionally placed, sized and named instances
bootInstances(close:=false){
	if(close){ ; closes specific instances
		Loop, % instances.Length(){
			WinClose, % "Best Game Ever Instance " . instances[A_Index]
			Sleep, 1000
		}
	}
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
	WinGet, currID, ID, A ; get ID of current window focus
	Loop, % instances.Length(){ 
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
			clW := NumGet(&rect, 8, "Int")
			clH := NumGet(&rect, 12, "Int")
			borderThickness:=clX-wX
			titleBarHeight:=clY-wY
			windowSizeGet:=True
		}
		IDs[A_Index]:=ID
		Process, Priority, %pid%, H
		tempName:="Best Game Ever Instance " . instances[A_Index] 
		WinSetTitle,Adobe Flash Player 32,, %tempName% ;change window name for clarity later
		WinMoveEx(locationx+((Mod(instances[A_Index]+1, 2))*startingWidth), locationy+(startingHeight*(instances[A_Index]-2>0 ? 1 : 0)), startingWidth, startingHeight, ID) ; move instance to adjusted coordinates (exclude border)
		WinSet, Bottom,, %tempName%
	}
	WinActivate, ahk_id %currID% ; restore window focus before pr2 instances were created
	Sleep, serverDelayMillis*20
	clickSome("muteXRatio", "muteYRatio")
	clickSome("muteXRatio", "muteYRatio") ;past main menu then mute
	return
}


; logs in all accounts in array 'instances' on currentServer
loginSome(logoutFirst:=False){
	Loop, % instances.Length(){
		tempName:="Best Game Ever Instance " . instances[A_Index]
		if(logoutFirst){ ; if changing servers mid sim
			Sleep, 300
			ControlClick, % "x" . getXPos(clickRatios["logoutXRatio"]) . " y" . getYPos(clickRatios["logoutYRatio"]), %tempName%,,,, NA  ; logout button
		}
		Sleep, serverDelayMillis
		ControlClick, % "x" . getXPos(clickRatios["loginMainXRatio"]) . " y" . getYPos(clickRatios["loginMainYRatio"]), %tempName%,,,, NA  ; login button
		Sleep, 250
		if(savedAccounts!=0){
			ControlClick, % "x" . getXPos(clickRatios["knownUsersXRatio"]) . " y" . getYPos(clickRatios["knownUsersYRatio"]), %tempName%,,,, NA ; known users list
			Sleep, 250
			ControlSend,, % "{PgDn " . (savedAccounts>5 ? savedAccounts-4 : 1) . "}", %tempName% ; reveal and select 'use other account', extra pgdn inputs if lots of saved accounts
			Sleep, 250 ; bug testing login issues
			KeyWait, Control
			ControlSend,, {Enter}, %tempName% ; use other account
		}
		Sleep, 250
		ControlClick, % "x" . getXPos(clickRatios["serverListXRatio"]) . " y" . getYPos(clickRatios["serverListYRatio"]), %tempName%,,,, NA  ;server list
		Loop, % serverList.Length(){
			if(serverList[A_Index]=currentServer){ ; locates index of servername and presses down accordingly
				Sleep, 250
				ControlSend,, % "{down " . A_Index-1 . "}", %tempName% ; pick server
				Sleep, 100
				KeyWait, Control
				ControlSend,, {Enter}, %tempName%
				break
			}
		}
		Sleep, 250
		ControlClick, % "x" . getXPos(clickRatios["loginTextBoxXRatio"]) . " y" . getYPos(clickRatios["userFieldYRatio"]), %tempName%,,,, NA  ; user field
		Sleep, 250
		KeyWait, Shift
		ControlSend,, % "{text}" . accounts[instances[A_Index]].username, %tempName% ; type username
		Sleep, 250
		ControlSend,, {Tab}, %tempName%	;move to pass field
		Sleep, 100
		KeyWait, Shift
		ControlSend,, % "{text}" . accounts[instances[A_Index]].password, %tempName% ; type password
		Sleep, 250
		KeyWait, Control
		ControlSend,, {Enter}, %tempName% ; login
		Sleep, 2000 ; too fast boiii
	}
	Sleep, 10000
	return
}

; brings specified instance(s) from the page past login to the sim
levelPrep(loadOut:=false){
	clickSome("searchTabXRatio", "searchTabYRatio") ; search tab
		Loop, % instances.Length(){
			tempName:="Best Game Ever Instance " . instances[A_Index]
			if(loadOut){
				ControlSend,, 9, %tempName%				 ;
				Sleep, 250	
				KeyWait, Shift									 ; changes the character to loadout 9, one with an EXP hat
				ControlSend,, {Shift Down}{Tab 3}{Shift up}{Space}, %tempName% ;
			}
			Sleep, 500
			ControlClick, % "x" . getXPos(clickRatios["searchByXRatio"]) . " y" . getYPos(clickRatios["searchByYRatio"]), %tempName%,,,, NA ;search by dropdown
			Sleep, 100
			ControlSend,, {PgDn}, %tempName% ; move to bottom of list aka 'level id'
			Sleep, 100
			KeyWait, Control
			ControlSend,, {Enter}, %tempName% ; select			
			Sleep, 250	
			ControlClick, % "x" . getXPos(clickRatios["levelTextFieldXRatio"]) . " y" . getYPos(clickRatios["levelTextFieldYRatio"]), %tempName%,,,, NA ;click text box
			Sleep, 100
			ControlSend,,% "{text}" . levelID, %tempName% ; enter sim ID
			Sleep, 250
			KeyWait, Control
			ControlSend,, {Enter}, %tempName% ;search
			Sleep, 100
		} 
		Sleep, 2000
	return
}

; performs the same action on every instance to reduce the time loss from waiting for a server response; starts server API requests as early as possible
clickSome(xRatio, yRatio, offsetRatio:="", sleep:=0){ 
	Loop, % instances.Length(){
		tempName:= "Best Game Ever Instance " . instances[A_Index]
		playOffset:= (offsetRatio="") ? 0 : getOffset(clickRatios[offsetRatio]) ; only calls getOffset if offset exists
		ControlClick, % "x" . getXPos(clickRatios[xRatio]) .  " y" . getYPos(clickRatios[YRatio]) + (playOffset*(A_Index-1)), %tempName%,,,, NA ; click! (maybe with offset!)
		Sleep, sleep
	}
	return
}

; gets x click coord
getXPos(ratio){ 
	updateDims()
	return Round(instanceWidth*ratio)+offsetX
}

; getx y click coord
getYPos(ratio){ 
	updateDims()
	return Round(instanceHeight*ratio)+offsetY 
}
	
; gets offset (only for queue/play atm)(needs to be fixed, works in most normal window sizes)
getOffset(ratio){ 
	updateDims()
	return Round(instanceHeight*ratio)
	;return Round((instanceHeight+((offsetY-50)*2))*ratio)
}

; changes instanceHeight and instanceWidth to be accurate to the actual coordinates of pr2 gameplay, and creates offsetX and offsetY values to increment coords by (title bar/gray space)
updateDims(){ 
	rect := VarSetCapacity(RECT, 16, 0)
	hwnd := WinExist(tempName)
	DllCall("user32\GetClientRect", Ptr, hwnd, Ptr, &rect)
	DllCall("user32\ClientToScreen", Ptr, hWnd, Ptr, &rect)
	clW := NumGet(&rect, 8, "Int")
	clH := NumGet(&rect, 12, "Int")
	grayX:=((clW/clH)>1.375?Round(clW-(clH*1.375)):0)
	grayY:=((clW/clH)>1.375?0:Round(clH-(clW/1.375)))
	offsetX:=borderThickness+Round(grayX/2)
	offsetY:=titleBarHeight+Round(grayY/2)
	instanceWidth := clW-Round(grayX)
	instanceHeight := clH-Round(grayY)
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
	return
}

; checks if any instance has softlocked (is not in the sim instance when they should be) !!(does not work if server delay causes character to enter a level other than the sim, e.x a campaign level)
checkDisconnects(){
	reboot:=[]
	;FileAppend, %ClipboardAll%, copyBackup.clip ; creates text file containing clipboard data as a failsafe for the rare case where the script crashes while juggling clipboard data
	Loop, 4{ ; for all instances
		tempName:= "Best Game Ever Instance " . A_Index
		ControlSend,, {tab}, %tempName% ; enter in-level text menu
		ControlSend,, % "{text}" . A_Index, %tempName%  ; type the instance number
		KeyWait, Control
		clipSaved:= ClipboardAll ; save current clipboard to temp val to restore after checks are complete
		Clipboard:="" ; clear clipboard
		KeyWait, Control
		ControlSend,, {ctrl down}ac{ctrl up}, %tempName% 
		KeyWait, Control
		ControlSend,, {BS}, %tempName% ; highlight, copy and delete the typed instance number
		ControlSend,, {text}We love PR2! Woohoo!, %tempName% ; It's true (:
		KeyWait, Control
		ControlSend,, {Enter}, %tempName% 
		startTick:=A_TickCount
		found:=False
		search:=A_Index
		while((A_TickCount-startTick)<500){ ; for 500 ms
			if(Clipboard=search){ ; if the instance was copied
				Clipboard:=clipSaved
				found:=True
				instancesRev.push(search)
				Sleep, 500-(A_TickCount-startTick) ; wait the remainder of the 2500ms for consistency
				break
			}
			else if(Clipboard!=""){
				clipSaved:=ClipboardAll
				Clipboard:=""
			}
		}	
		if(!found){
			reboot.push(search) ; it's so joever
		}
		KeyWait, Control
	}
	if(reboot.Length()!=0){
		instances:=reboot 
		bootInstances(true) ; close instances and reboot
		loginSome() ;logs some accounts in
		levelPrep() ; finds sim level
		instances:=instancesRev
		clickSome("quitXRatio", "quitYRatio",, 10) ;quit level 
		clickSome("lobbyXRatio", "lobbyYRatio",, 10) ;return to lobby
		Sleep, serverDelayMillis
		instances:=[1, 2, 3, 4]  ; reinstate instances array
		instancesRev:=[]
		return True
	}
	instancesRev:=[]
	return False
}
	
setup(){
	MsgBox, 0, PR2 is cool, Welcome to the EPIC PR2 player count optimizer!!! (it's a sim)
	MsgBox, 0, PR2 is cool, If anything is not working as intended or you need help, contact @yaboitroi on discord (epicmidget)
	if (FileExist("EPICsimDetails.ini")){
		MsgBox, 4, PR2 is cool, Would you like to reanswer any startup prompts?
			IfMsgBox, no
				{
				IniRead, whichMonitor, EPICsimDetails.ini,general, whichmonitor
				Goto, endSetup
				}
			IfMsgBox, Yes
				redoSetup:=True
	}
	MsgBox,0 , PR2 is cool, Welcome to the EPIC sim setup
	if(redoSetup){
	MsgBox, 4, PR2 is cool, Would you like to reenter your PR2 file path?
		IfMsgBox, No
			{
			Goto, getLevelID
			}
	}
	Loop {
		InputBox, filePath , PR2 is cool, Enter the FULL file path for your PR2 executable (including the .exe) for example`, C:\Users\EpicMidget\Desktop\Pr2\Platform Racing 2.exe. Enter help for help
		while(filePath="help"){
			MsgBox, 0, PR2 is cool, To find the file path, open file explorer and locate your pr2 executable (what you click to open pr2). Click the section at the top of file explorer that lists the folders you've entered/your current location, and it will convert to a file path. add your pr2 file name (case sensitive) and .exe at the end.
			InputBox, filePath , PR2 is cool, Enter the FULL file path for your PR2 executable (including the .exe) for example`, C:\Users\EpicMidget\Desktop\Pr2\Platform Racing 2.exe. Enter help for help
		}
		if(ErrorLevel||(filePath="")){
			IniRead, filePath, EPICsimDetails.ini,general, filepath
		}
		MsgBox,0 , PR2 is cool, Your file path will now be tested for validity
		try{
			Run, %filePath%,,, pid
			WinWait, ahk_pid %pid%,, 3
			WinClose, ahk_pid %pid%
			if(ErrorLevel=0){
				break
			}
		}
	MsgBox,0 , PR2 is cool, Your file path isn't correct. Please try again
		
	}
	iniWrite, % filePath, EPICsimDetails.ini,general, filepath

	getLevelID:
	if(redoSetup){
	MsgBox, 4, PR2 is cool, Would you like to reenter your level ID?
		IfMsgBox, No
			{
			Goto, getMonitor
			}
	}
	Loop {
		InputBox, levelID, PR2 is cool, Log in to PR2 and search user 'U'. pick any one of their levels and paste the level ID here. Try to pick one that isn't near the top of the search. If you're unsure of how to find the level ID`, type help. (blockeditor could also be used to create your own)
		while(levelID="help"){
			MsgBox, 0, PR2 is cool, To find the levelID, click the question mark below the level, then hit the green arrow. The level ID should be after the 'level=' part.
			InputBox, levelID, PR2 is cool, Log in to PR2 and search user 'U'. pick any one of their levels and paste the level ID here. Try to pick one that isn't near the top of the search. If you're unsure of how to find the level ID, type help
		}
		if(ErrorLevel||(levelID="")){
			IniRead, levelID, EPICsimDetails.ini,general, levelid
				if(levelID!=""){
					break
				}
		}
		if levelID is digit
			if(levelID!=""){
				break  
			}
		MsgBox,0 , PR2 is cool, Please enter a valid levelID
	}
	iniWrite, % levelID, EPICsimDetails.ini,general, levelid

	getMonitor:
	IniRead, whichMonitor, EPICsimDetails.ini,general, whichmonitor
	if(redoSetup){
		MsgBox, 4, PR2 is cool, Would you like to reenter which monitor the instances will intially load on?
			IfMsgBox, No
				{
				Goto, getPr2Location
				}
		}
	SysGet, monitorCount, monitorCount
	Loop {
		InputBox, whichMonitor , PR2 is cool, Pick which monitor to load pr2 on. your main monitor (1)`, or others (2+) (seen in windows display settings)
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
	if(redoSetup){
		MsgBox, 4, PR2 is cool, Would you like to reenter your initial instance loading location?
			IfMsgBox, No
				{
				Goto, getSavedAccounts
				}
		}
	Loop {
		InputBox, pr2Location , PR2 is cool, Enter a value to determine where you would like your pr2 instances to be initially displayed`: top left corner`(1`)`, top right corner`(2`)`, bottom left corner`(3`)`, bottom right corner`(4`)`, or center`(5`)
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

	getSavedAccounts:
	if(redoSetup){
		MsgBox, 4, PR2 is cool, Would you like to reenter your number of saved accounts?
			IfMsgBox, No
				{
				Goto, getStartingWidth
				}
		}
	Loop {
		InputBox, savedAccounts , PR2 is cool, Enter how many accounts you have saved credentials for in PR2 `(seen after clicking login on the main `menu`)
		if(ErrorLevel||(savedAccounts="")){
			IniRead, savedAccounts, EPICsimDetails.ini,general, savedaccounts
				if(savedAccounts!=""){
					break
				}
		}
		else if savedAccounts is digit
			if(savedAccounts!=""){
				break  
		}
		MsgBox, 0, PR2 is cool, Please enter an appropriate integer
	}
	IniWrite, % savedAccounts, EPICsimDetails.ini,general, savedaccounts

	getStartingWidth:
	if(redoSetup){
		MsgBox, 4, PR2 is cool, Would you like to reenter the starting pr2 window width?
			IfMsgBox, No
				{
				Goto, getStartingHeight
				}
	}
	Loop {
		InputBox, startingWidth , PR2 is cool, Enter the width `(in pixels`) that you would like your instances to be booted. Values lower than 150 are not recommended`, and values greater than half of your monitors width will be set to half.
		if(ErrorLevel||(startingWidth="")){
			IniRead, startingWidth, EPICsimDetails.ini,general, startingwidth
				if(startingWidth!=""){
					break
				}
		}
		else if startingWidth is digit
			{
			if(startingWidth!=""){
				if(startingWidth>Round(desktopWidth/2)){
					startingWidth:=Round(desktopWidth/2)
				}
				if(startingWidth<1){
					startingWidth:=1
				}
				break
			}
		}
		MsgBox,0 , PR2 is cool, Please enter an integer
	}
	IniWrite, % startingWidth, EPICsimDetails.ini,general, startingwidth

	getStartingHeight:
	if(redoSetup){
		MsgBox, 4, PR2 is cool, Would you like to reenter the starting pr2 window height?
			IfMsgBox, No
				{
				Goto, getUserInfo1
				}
		}
	Loop {
		InputBox, startingHeight , PR2 is cool, Enter the height `(in pixels`) that you would like your instances to be booted. Values lower than 150 are not recommended`, and values greater than half of your monitors height will be set to half.
		if(ErrorLevel||(startingHeight="")){
			IniRead, startingHeight, EPICsimDetails.ini,general, startingheight
				if(startingHeight!=""){
					break
				}
			MsgBox, You must enter a value
		}
		else if startingHeight is digit
			{
				if(startingHeight>Round(desktopHeight/2)){
					startingHeight:=Round(desktopHeight/2)
				}
				if(startingHeight<1){
					startingHeight:=1
				}
				break
			}
			MsgBox,0 , PR2 is cool, Please enter an integer
	}
	IniWrite, % startingHeight, EPICsimDetails.ini,general, startingheight

	getUserInfo1:
	if(redoSetup){
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
		InputBox, pass1 , PR2 is cool, Enter password 1:
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
	if(redoSetup){
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
	if(redoSetup){
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
	if(redoSetup){
		MsgBox, 4, PR2 is cool, Would you like to reenter the fourth player's login info?
			IfMsgBox, No
				{
				Goto, endSetup
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

	endSetup:
		IniRead, filePath, EPICsimDetails.ini,general, filepath
		IniRead, levelID, EPICsimDetails.ini,general, levelid
		IniRead, pr2Location, EPICsimDetails.ini,general, pr2location
		IniRead, savedAccounts, EPICsimDetails.ini,general, savedaccounts
		IniRead, startingWidth, EPICsimDetails.ini,general, startingwidth
		IniRead, startingHeight, EPICsimDetails.ini,general, startingheight
		IniRead, user1, EPICsimDetails.ini,general, user1
		IniRead, pass1, EPICsimDetails.ini,general, pass1
		IniRead, user2, EPICsimDetails.ini,general, user2
		IniRead, pass2, EPICsimDetails.ini,general, pass2
		IniRead, user3, EPICsimDetails.ini,general, user3
		IniRead, pass3, EPICsimDetails.ini,general, pass3
		IniRead, user4, EPICsimDetails.ini,general, user4
		IniRead, pass4, EPICsimDetails.ini,general, pass4
	SysGet, pr2Monitor, monitorWorkArea , %whichMonitor% ; stores monitor boundaries as variables
	IniRead, repeatLoadoutWarning, EPICsimDetails.ini, general, repeatloadoutwarning
	if(repeatLoadoutWarning="ERROR"){
		MsgBox,0 , PR2 is cool, Before beginning the script, make sure your 9th loadout slots on each character have an exp hat equipped. Your loadouts can be seen in the top right of your account tab`, as a little save icon.
		Loop{
			MsgBox, 4, PR2 is cool, Did you save the loadouts?
				IfMsgBox, Yes
					Break
			MsgBox, 0, this is not a drill, GO SAVE YOUR LOADOUTS!! DO YOU WANT EXP OR NOT?!? Why am I yelling?
		}
		MsgBox, 4, PR2 is cool, Did you really save them? Really really?... Hit yes and you won't see this again. Do NOT forget if you happen to switch accounts in the future
			IfMsgBox, Yes
				IniWrite, guccigang, EPICsimDetails.ini, general, repeatloadoutwarning
			IfMsgBox, No
				MsgBox, 0, like zoinks, The pr2 exp gods have been notified. You have been warned
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
	MsgBox, 0, PR2 is cool, Press the windows key + F12 to begin the sim and F11 to reload the script. Happy simming and stay epic B-)

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
    WinGetPos wX, wY, wW, wH, % "ahk_id" hwnd
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
}

/*
retired code

;reads txt file with login info
getLoginInfo(){
	FileRead, userData, %simAccountInfo% 
	parsedUserData:= StrSplit(userData, A_Space) ;separate login info by spaces
	Loop, % parsedUserData.Length(){
		parsedUserData[A_Index]:= StrReplace(parsedUserData[A_Index], "_", A_Space)
	}
	iterations:=Round((parsedUserData.Length())/2)
	Loop, %iterations%{ ; creates 5 objects containing 1 username and 1 password each and places them in 'accounts' array
		obj:={username:  parsedUserData[(A_Index*2)-1], password:  parsedUserData[A_Index*2]}
		accounts[A_Index]:= obj
	}
	return
}



retired code

controlClicker(xRatio, yRatio){
	WinGet, minMax, MinMax, %tempName%
	if(!(minMax+1)){
		;WinMaximize, %tempName%
		PostMessage, 0x0112, 0xF120,,, %tempName%
	}
	ControlClick, % "x" . getXPos(clickRatios[xRatio]) . " y" . getYPos(clickRatios[yRatio]), %tempName%,,,, NA ;quit1
	if(simMode){
		WinMinimize, %tempName%
	}
	return
}



retired code

;checks if local clock has passed a flat hour for hh check
checkTime(){
	if(currentHour!=A_Hour){
		currentHour:=A_Hour
		return true
	}
	return
}



retired code

updateDims(){ 
	WinGet, minMax, MinMax, %tempName%
		if(!(minMax+1)){
			WinRestore, %tempName% ; minimizing is illegal right now!!... sorry
			WinMaximize, %tempName% ; fix weird offset issue?
			WinRestore, %tempName%  ;
			WinSet, Bottom,, %tempName% ; hide behind instances
		}
	WinGetPos,,, instanceWidth, instanceHeight, %tempName% ; get full process size
	if(((instanceHeight-titleBarHeight)/instanceWidth)>.7226){ ;if pr2 has gray area on top
		offsetY:=titleBarHeight+Round(((instanceHeight-titleBarHeight)-(InstanceWidth*.7226))/2)  ; title bar + grayabove pixel length
		offsetX:=0               ;no gray
		instanceHeight:=Round(instanceWidth*.7226)
	}
	else{ ; else, pr2 has gray area on the sides (or no gray area)
		offsetX:= Round((instanceWidth-((instanceHeight-titleBarHeight)/.7226))/2) ; gray above pixel length
		offsetY:=titleBarHeight ; title bar pixel length
		instanceHeight-=titleBarHeight 
		instanceWidth:=Round((instanceHeight)/.7226)
	}
	return
}



retired instructions

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;-----------------------------------------------------------------------------------------------------------------------

;	Before running the script, be sure to follow all instructions below and enter all of the necessary information

;-----------------------------------------------------------------------------------------------------------------------
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


;!!!! MAKE SURE OUTFIT LOADOUT 9 HAS EXP HAT EQUIPPED

;Create a text document and include all 4 SIM accounts login info on a single line in the format:
;user1 pass1 user2 pass2 user3 pass3 user4 pass4 --- if SPACE in name, use "_" (underscore)
;and insert file path below in fileRead. Your credentials will be read locally to the script and parsed for use later
;you can copy this directly from clicking the file pathing bar at the top of file explorer, just add the text file at the end
;for example, "C:\Users\%your username%\Desktop\%folder name%2\PR2 User Credentials.txt"
global simAccountInfo:="C:\Users\EpicMidget\Desktop\Pr2\sim macro\PR2 User Credentials.txt" ;this exists so that you don't accidentally share your login credentials with anyone (through sharing code)

global filePath:="C:\Users\EpicMidget\Desktop\Pr2\Platform Racing 2.exe" ;Same thing as above, but this is your platform racing 2 executable location

;global macroMode:= 1 ; determine which macro you would like to run. If you're internet is inconsistent, stay with the first version (1). The second version is faster, gives more EXP and will give you the ITEM rewards on player 4!
global levelID:= ; 6514855 uses user 'U' on PR2's sim levels. just pick any of them, or create a copy using blockeditor (see line below) and play on that. To find the ID, click the question mark below the level, the arrow at the bottom left (share) and locate the ID within the share link
					    ;https://github.com/Pr2FreeRunner/BlockEditor/releases/tag/Release
global localDelayMillis:=3 ; Add delay after every command sent to the game that's limited by your computer's speed. Play around with it. If things do not function correctly, this may be why (minimum of 1)
global serverDelayMillis:= 800 ; Add delay after every command sent to the game that's limited by your internet/distance from the server. (Illinois or something?) if things do not function correctly, this is most likely why
global pr2Location:=3 ; Enter a value to determine where you would like your pr2 isntances to be initially displayed: top left corner(1), top right corner(2), bottom left corner(3), bottom right corner(4), or center(5), relative to your chosen monitor in whichMonitor below
;global pr2WindowStatus:=1 ; chose whether you want pr2 to be visible(1), minimized(2) or hidden(3). visible windows are allowed variable size (will implement)
;global simMode:=1 ; , chose whether your pr2 instances sit behind your active windows, on your desktop(0), or stay minimized until inputs are sent where they will flash on your screen momentarily then minimize again(1)
global savedAccounts:=6 ; type the amount of account details you have saved in the 'user' drop down after you hit login on the main menu. If you have never clicked 'remember me' while logging in, set this value to 0.
global startingWidth:=7654567 ; The starting width for one pr2 instance, type '0' for four corners. Windows too small will not work (yet)
global startingHeight:=7564234 ;  the starting height for one pr2 instance, type '0' for four corners Windows too small will not work (yet)
global whichMonitor:=1 ; determines which monitor the pr2 instances will appear on. See system settings for order, if multiple (default 1)

*/


