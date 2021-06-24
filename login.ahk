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
	global numButtons := 0 ; Starting with 1 for existing button(s)
	Gui, main:New
	load()
	numButtons ++
	Gui, main:Add, Button, x70 w60 h25 gadd, New...
	guiHeight := numButtons * 42.5
	Gui, main:Show, w200 h%guiHeight%
}

load() {
	global ; enables global mode for declaration of dynamic variable for GUI
	If InStr(FileExist(A_ScriptDir . "\out"), "D")
	{
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
			numButtons ++
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
	If !InStr(FileExist(A_ScriptDir . "\out"), "D")
		FileCreateDir, %A_ScriptDir%\out
	file := FileOpen(A_ScriptDir . "\out\" . username . ".txt", "w")
	file.write(Crypt.Encrypt.String("AES", "CBC", credential, hash))
	file.close()
	main()
}

login(x, y) {
	saved := clipboard
	WinActivate, Riot Client
	MouseClick, left, 250, 250
	Send, ^a
	Send, {Delete}
	clipboard := x
	Send, ^v
	Sleep, 100
	Send, %A_Tab%
	clipboard := y
	Send, ^v
	Sleep, 100
	Send, {Enter}
	clipboard := saved
}

openClient(x, y) {
	if WinExist("Riot Client") {
		login(x, y)
		ExitApp
	} 
	else {
		Run %riotClientPath% --launch-product=valorant --launch-patchline=live
		while (!WinExist("Riot Client")) {
		}
		login(x, y)
		ExitApp
	}
}