extends Node3D

const speed = 20

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.basis * Vector3(0,0,speed) * delta
	if ray.is_colliding():
		if !ray.get_collider().has_method("enemy"):
			if ray.get_collider().name == "Wall":
				queue_free()
			if ray.get_collider().has_method("player"):
				mesh.visible = false
				await get_tree().create_timer(1).timeout
				queue_free()


func enemy_arrow():
	pass

func _on_timer_timeout():
	queue_free()
