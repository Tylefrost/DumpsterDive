extends Node3D
@onready var mesh = $weapon_knife

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_player_knife_equip():
	mesh.visible = true


func _on_player_knife_unequip():
	mesh.visible = false
