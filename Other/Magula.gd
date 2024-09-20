extends Node3D

@onready var hit_rect = $UI/ColorRect

func _ready():
	pass

func _process(delta):
	pass

func _on_player_3d_player_hit():
	hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false
