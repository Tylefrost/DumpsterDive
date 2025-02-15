extends CharacterBody3D

var speed = 50
var player_chase = false
var player = null
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# combat
var player_inattack_range = false
var player_attack_cooldown = true
var health = 100

# ranged combat
var arrow_in_range = false

# drop items
@onready var string = preload("res://GameModules/Items/string.tscn")
@onready var leather = preload("res://GameModules/Items/leather.tscn")
@onready var glass = preload("res://GameModules/Items/glass.tscn")
@onready var wire = preload("res://GameModules/Items/wire.tscn")
@onready var bag = preload("res://GameModules/Items/bag.tscn")

# animations
@onready var anim = $MeshRoot/AnimationTree
var check = true

func _physics_process(delta):
	
	player_attack()
	dead()
	
	if player_chase:
		if not is_on_floor():
			velocity.y -= gravity * delta
		anim["parameters/Transition/transition_request"] = "state_1"
		position.x += (player.position.x - position.x) / speed
		position.z += (player.position.z - position.z) / speed
		move_and_collide(Vector3(0,0,0))
		move_and_slide()
		look_at(player.position, Vector3(0,1,0))
		rotation.x = 0
		rotation.z = 0
	
		if MainScene.wallet_attack and check == true:
			check = false
			anim["parameters/Transition_2/transition_request"] = "state_1"
			await get_tree().create_timer(0.017).timeout
			check = true
		
func _on_detection_area_body_entered(body):
	player = body
	player_chase = true
	
func _on_detection_area_body_exited(_body):
	player = null
	player_chase = false

func _on_enemy_hitbox_body_entered(body):
	if body.has_method("player"):
		player_inattack_range = true
	if body.has_method("arrow"):
		anim["parameters/Transition_3/transition_request"] = "state_1"
		health -= 10
		print("slime health ", health)
		
func _on_enemy_hitbox_body_exited(body):
	if body.has_method("player"):
		player_inattack_range = false
	
		
func player_attack():
	if player_inattack_range and MainScene.player_current_attack == true:
		if player_attack_cooldown:
			anim["parameters/Transition_3/transition_request"] = "state_1"
			health -= 10
			$TakeDamageCooldown.start()
			player_attack_cooldown = false
			print("slime health ", health)
			
func enemy():
	pass

func dead():
	if health <= 0:
		drop_items()
		self.queue_free()

func _on_take_damage_cooldown_timeout():
	player_attack_cooldown = true

func drop_items():
	var random = RandomNumberGenerator.new()
	random.randomize()
	var item = random.randi_range(0, 5)
	if item == 1:
		var string_instance = string.instantiate()
		string_instance.position = global_position
		get_parent().add_child(string_instance)
	if item == 2:
		var leather_instance = leather.instantiate()
		leather_instance.position = global_position
		get_parent().add_child(leather_instance)
	if item == 3:
		var glass_instance = glass.instantiate()
		glass_instance.position = global_position
		get_parent().add_child(glass_instance)
	if item == 4:
		var wire_instance = wire.instantiate()
		wire_instance.position = global_position
		get_parent().add_child(wire_instance)

func wallet():
	pass
