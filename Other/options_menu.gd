extends Control

@onready var buttonclick = $Node/audio

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Other/menu.tscn")
	
