extends Node

@export var animation_tree: AnimationTree
@export var player: CharacterBody3D

var on_floor_blend: float = 1
var on_floor_blend_target : float = 1

var tween : Tween
	
func _on_player_set_movement_state(_movement_state: MovementState):
	if tween:
		tween.kill()
		
	tween = create_tween()
	tween.tween_property(animation_tree, "parameters/movement_blend/blend_position", _movement_state.id, 0.25)
	tween.parallel().tween_property(animation_tree, "parameters/movement_anim_speed/scale", _movement_state.animation_speed, 0.7)


func _on_player_pressed_jump(_jump_state: JumpState):
	#animation_tree["parameters/" + jump_state.animation_name + "/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	animation_tree["parameters/TimeSeek/seek_request"] = 0.6
	animation_tree["parameters/Transition/transition_request"] = "state_1"
	await get_tree().create_timer(0.45).timeout
	animation_tree["parameters/Transition/transition_request"] = "state_0"
