#SingleInstance, force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#include lib\class_cng.ahk

global riotClientPath := "C:\Riot Games\Riot Client\RiotClientServices.exe"
global key := "If whenever the army attacks it is like a whetstone thrown against an egg, it is due to the vacuous and substantial."
global hash := Crypt.Hash.String("SHA1", key)

main()
return

main() {
	setup()
	global buttonRows := 0
	Gui, main:New
	load()
	buttonRows ++
	Gui, main:Add, Button, x35 y+15 w60 h25 gadd, Add/Edit
	Gui, main:Add, Button, x105 y+-25 w60 h25 gpath, Set Path
	Gui, Font, s8 bold, MS Sans Serif
	Gui, main:Add, Text, x20, Press Esc to reset application
	guiHeight := buttonRows * 42.5 + 25
	Gui, main:Show, w200 h%guiHeight%
}

path() {
	FileCreateDir, %A_ScriptDir%\pre
	MsgBox, 48, ,
	(
Navigate to the location the Riot Client is installed.`n
The file is named RiotClientServices.exe`n
Default installation path: C:\Riot Games\Riot Client\RiotClientServices.exe
	)
	IfMsgBox, OK
		FileSelectFile, riotClientPath
		file := FileOpen(A_ScriptDir . "\pre\setup.txt", "w")
		file.write(riotClientPath)
		file.close()
}

setup() {
	global
	if FileExist(A_ScriptDir . "\pre\setup.txt") {
		FileRead, riotClientPath, %A_ScriptDir%\pre\setup.txt
		IfNotExist, %riotClientPath%
		{
			MsgBox, 16, , Invalid path set in setup file
			path()
		}
	}
	else {
		path()
	}
}

load() {
	global ; enables global mode for declaration of dynamic variable for GUI
	if InStr(FileExist(A_ScriptDir . "\out"), "D") {
		Loop, Files, %A_ScriptDir%\out\*.txt
		{
			local credential := ""
			FileRead, credential, %A_LoopFileFullPath%
			credential := Crypt.Decrypt.String("AES", "CBC", credential, hash)
			credential := StrSplit(credential, "`n")
			local username := credential[1]
			local password := credential[2]
			local label := credential[3]
			local fn := Func("openClient").Bind(username, password)
			Gui, main:Add, Button, x50 w100 h35 v%username%, %label%
			GuiControl +g, %username%, % fn
			buttonRows ++
		}
	}
}

add() {
	global guiWidth := 200
	Gui, add:New
	Gui, add:Add, Text, Center x0 w%guiWidth%, Enter Username
	Gui, add:Add, Edit, vusername x25 w150
	Gui, add:Add, Text, Center x0 w%guiWidth%, Enter Password
	Gui, add:Add, Edit, vpassword +password x25 w150
	Gui, add:Add, Text, Center x0 w%guiWidth%, Enter Label
	Gui, add:Add, Edit, vlabel x25 w150
	Gui, add:Add, Button, w50 h22.5 x75 gsubmit, Add
	Gui, add:Show, w%guiWidth%
}

submit() {
	global ; enables global mode for declaration of variables for GUI
	Gui, add:Submit
	credential := username . "`n" . password . "`n" . label
	if !InStr(FileExist(A_ScriptDir . "\out"), "D")
		FileCreateDir, %A_ScriptDir%\out
	file := FileOpen(A_ScriptDir . "\out\" . username . ".txt", "w")
	file.write(Crypt.Encrypt.String("AES", "CBC", credential, hash))
	file.close()
	main()
}

login(user, pass, x, y) {
	saved := clipboard
	readyCounter := 0
	while (readyCounter < 2) {
		MouseMove, %x%, %y%
		if (A_Cursor = "IBeam") {
			readyCounter += 1
		}
		Sleep, 100
	}
	MouseClick, left, %x%, %y%
	Sleep, 100
	Send, ^a
	Sleep, 100
	Send, {Delete}
	Sleep, 100
	clipboard := user
	Sleep, 100
	Send, ^v
	Sleep, 100
	Send, %A_Tab%
	Sleep, 100
	clipboard := pass
	Sleep, 100
	Send, ^v
	Sleep, 100
	Send, {Enter}
	clipboard := saved
	Sleep, 500
}

openClient(user, pass) {
	main()
	HitList:="VALORANT.exe|VALORANT-Win64-Shipping.exe|RiotClientServices.exe"
	Loop, Parse, HitList, |
	{
		Loop
		{
			Process, Exist, %A_LoopField%
			if ErrorLevel
				Process, Close, %A_LoopField%
			else
				break
			Sleep, 3000
		}
	}
	Run %riotClientPath% --launch-product=valorant --launch-patchline=live
	SetTitleMatchMode, 2
	WinActivate, ahk_exe Riot Client.exe
	WinWaitActive, ahk_exe Riot Client.exe
	x = 300
	y = 396
	login(user, pass, x, y)
}

Esc::ExitApp