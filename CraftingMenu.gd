extends Control



func _ready():
	MainScene.glasses = 1
	MainScene.strings = 1
	MainScene.wires = 1
	
	
	
	
func _on_returnpause_pressed():
	visible = false


func _on_opencrafting_pressed():
	visible = true


func _on_craftbow_pressed():
	if MainScene.glasses >= 1 and MainScene.strings >= 1 and MainScene.wires >= 1 and !$"../../Player".bow_owned:
		MainScene.glasses -= 1
		MainScene.strings -= 1
		MainScene.wires -= 1
		$"../../Player".bow_owned = true
		


func _on_craftknife_pressed():
	if MainScene.glasses >= 1 and MainScene.strings >= 1 and MainScene.leathers >= 1 and !$"../../Player".knife_owned:
		MainScene.glasses -= 1
		MainScene.strings -= 1
		MainScene.leathers -= 1
		$"../../Player".knife_owned = true


func _on_craftboots_pressed():
	if MainScene.leathers >= 1 and MainScene.strings >= 1 and MainScene.wires >= 1 and !$"../../Player".boots_owned:
		MainScene.leathers -= 1
		MainScene.strings -= 1
		MainScene.wires -= 1
		$"../../Player".boots_owned = true
		$"../../Player".boots_equipped = true
