extends Control

@onready var buttonclick = $menu_sounds/buttonclick

var is_ready: bool = true

func _on_options_pressed(): 
	get_tree().change_scene_to_file("res://Other/options_menu.tscn")
	

func _on_exit_game_pressed():
	get_tree().quit()
	
func _on_start_game_pressed():
	get_tree().change_scene_to_file("res://Other/Magula.tscn")
	
