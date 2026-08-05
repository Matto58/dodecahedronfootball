extends Control

func _ready() -> void:
	if ResourceLoader.exists("res://scripts/client/main_menu.gd"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/server_main.tscn")
