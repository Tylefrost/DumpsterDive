extends CharacterBody3D

signal set_movement_state(_movement_state: MovementState)
signal set_movement_direction(_movement_state: Vector3)
signal pressed_jump(jump_state : JumpState)

# state manager
@export var max_jump: int = 1
@export var movement_states: Dictionary
@export var jump_states: Dictionary

# movement
var jump_counter: int = 0
var movement_direction: Vector3
var sprint_cooldown
var jump_cooldown = true

# light detection
@onready var sub_viewport := $SubViewport
@onready var light_detection := $SubViewport/LightDetection
@onready var texture_rect := $TextureRect
@onready var light_level := $LightLevel
var damage_cooldown = true

@onready var anim = $MeshRoot/AnimationTree

# combat for enemy
var enemies_inattack_range = 0
var enemy_attack_cooldown = true
var boss
var wallet
var horse

# health 
var health = 130
var regen_wait = false

# combat for player
var player_alive = true
var attack = false
var player_attack_cooldown = true

# better combat
var knife_owned = false
var knife_equipped = false
signal knife_unequip()
signal knife_equip()

# long range combat
var bow_owned = false
var bow_equipped = false
var bow_cooldown = true
var arrow = load("res://GameModules/Weapons/arrow.tscn")
@onready var bow = $MeshRoot/raccoon/Raccoon/Skeleton3D/BoneAttachment3D2/Bow/RayCast3D
signal bow_equip()
signal bow_unequip()

#healthbar
@onready var health_bar = $HealthBar

#bowcooldownbar
@onready var bowCooldownBar = $BowCooldownBar

func _input(event):
	# movement directions
	if event.is_action("movement"):
		movement_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
		movement_direction.z = Input.get_action_strength("back") - Input.get_action_strength("forward")
		
		# activating movement states
		if is_movement_ongoing():
			if Input.is_action_pressed("sprint"):
				set_movement_state.emit(movement_states["sprint"])
			else:
				set_movement_state.emit(movement_states["walk"])
		else:
			set_movement_state.emit(movement_states["stand"])
			
func _ready():
	set_movement_state.emit(movement_states["stand"])
	
	# Make SubViewport render lighting only
	sub_viewport.debug_draw = 2
	
	health_bar.value = health
	health_bar.max_value = 130
	bowCooldownBar.value = 0
	
	
func _physics_process(_delta):
	
	enemy_attack()
	player_attack()
	
	if health <= 0:
		player_alive = false # add death scene
		health = 0
		print("player dead")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	# if there is movement continue updating movement direction
	if is_movement_ongoing():
		set_movement_direction.emit(movement_direction)
	
	# Jumping
	if is_on_floor():
		jump_counter = 0
		
	if jump_counter < 1:
		if Input.is_action_just_pressed("jump"):
			pressed_jump.emit(jump_states["ground_jump"])
			jump_counter += 1
	
	if Input.is_action_just_pressed("attack") and bow_equipped and bow_cooldown:
		anim["parameters/TimeSeek_2/seek_request"] = 0.6
		anim["parameters/Transition_3/transition_request"] = "state_1"
		bow_cooldown = false
		await get_tree().create_timer(0.27).timeout
		var arrow_instance = arrow.instantiate()
		arrow_instance.position = bow.global_position
		arrow_instance.transform.basis = bow.global_transform.basis
		get_parent().add_child(arrow_instance)
		
		#$BowCooldown.start()
		bow_cooldown = true
	
	if knife_owned:
		emit_signal("knife_equip")
	
	if bow_owned:
		if Input.is_action_just_pressed("equip_bow"):
			if bow_equipped:
				bow_equipped = false
				emit_signal("bow_unequip")
				if knife_owned: 
					knife_equipped = true
					emit_signal("knife_equip")
			else:
				bow_equipped = true
				emit_signal("bow_equip")
				if knife_owned:
					knife_equipped = false
					emit_signal("knife_unequip")
	health_bar.value = health
	
func _process(_delta):
	
	# Light detection
	light_detection.global_position = global_position # Make light detection follow the player
	var texture = sub_viewport.get_texture() # Get the ViewportTexture from the SubViewport
	texture_rect.texture = texture # Display this texture on the TextureRect
	var color = get_average_color(texture) # Get the average color of the ViewportTexture
	light_level.value = color.get_luminance() # Use the average color's brighness as the light level value
	light_level.tint_progress.a = color.get_luminance() # Also tint the progress texture with the above
	
	if light_level.tint_progress.a >= 0.5 and damage_cooldown:
		damage_cooldown = false
		await get_tree().create_timer(1).timeout
		health -= 1
		damage_taken()
		print(health)
		damage_cooldown = true
				
	bowCooldownBar.value = $BowCooldown.time_left
	
# is there movement
func is_movement_ongoing() -> bool:
	return abs(movement_direction.x) > 0 or abs(movement_direction.z) > 0

# light detection
func get_average_color(texture: ViewportTexture) -> Color:
	var image = texture.get_image() # Get the Image of the input texture
	image.resize(1, 1, Image.INTERPOLATE_LANCZOS) # Resize the image to one pixel
	return image.get_pixel(0, 0) # Read the color of that pixel
	

func _on_player_hitbox_body_entered(body):
	if body.has_method("enemy"):
		enemies_inattack_range += 1
	if body.has_method("boss"):
		boss = true
	if body.has_method("horse"):
		horse = true
	if body.has_method("wallet"):
		wallet = true
	if body.has_method("enemy_arrow"):
		health -= 10
		damage_taken()
		print(health)

func _on_player_hitbox_body_exited(body):
	if body.has_method("enemy"):
		enemies_inattack_range -= 1
	if body.has_method("boss"):
		MainScene.boss_attack = false
	if body.has_method("horse"):
		horse = false
	if body.has_method("wallet"):
		wallet = false
func player():
	pass

func enemy_attack():
	if enemies_inattack_range > 0 and enemy_attack_cooldown:
		enemy_attack_cooldown = false
		if boss:
			MainScene.boss_attack = true
		if horse:
			MainScene.horse_attack = true
		if wallet:
			MainScene.wallet_attack = true
		$EnemyAttackCooldown.start()
		await get_tree().create_timer(1.25).timeout
		if enemies_inattack_range > 0:
			health -= 10 * enemies_inattack_range
			damage_taken()
			print(health)
			
func player_attack():
	if Input.is_action_just_pressed("attack") and player_attack_cooldown and !bow_equipped:
		player_attack_cooldown = false
		enemy_attack_cooldown = false
		MainScene.player_current_attack = true
		attack = true
		anim["parameters/Transition_2/transition_request"] = "state_1"
		
		await get_tree().create_timer(1).timeout
		player_attack_cooldown = true
		
func _on_attack_cooldown_timeout():
	$AttackCooldown.stop()
	MainScene.player_current_attack = false
	attack = false


func _on_enemy_attack_cooldown_timeout():
	enemy_attack_cooldown = true

func _on_bow_cooldown_timeout():
	$BowCooldown.stop()
	bow_cooldown = true

func damage_taken():
	regen_wait = true
	$WaitRegen.start()
	
func _on_wait_regen_timeout():
	regen_wait = false
	regen_health()
	
func regen_health():
	if health < 130 and regen_wait == false:
		health += 10
		if health > 130:
			health = 130
		print(health)
		await get_tree().create_timer(2).timeout
		regen_health()
