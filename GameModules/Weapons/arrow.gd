extends Node3D

const speed = 40

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.basis * Vector3(0,0,speed) * delta
	if ray.is_colliding():
		mesh.visible = false
		queue_free()

func arrow():
	pass

func _on_timer_timeout():
	queue_free()
