extends Node3D #explained my problem

const SPEED = 35.0

@onready var mesh = $MeshInstance3D as MeshInstance3D
@onready var ray = $RayCast3D as RayCast3D
@onready var particles = $GPUParticles3D as GPUParticles3D

func _ready():
	pass
	
func _process(delta):
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
	if ray.is_colliding():
		mesh.visible = false
		particles.emitting = true
		ray.enabled = false
		if ray.get_collider().is_in_group("enemy"):
			ray.get_collider().hit()
		await get_tree().create_timer(1.0).timeout
		selfDestruct()

func _on_timer_timeout():
	selfDestruct()

func selfDestruct():
	queue_free()
