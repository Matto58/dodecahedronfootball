extends Control

class_name DHMain

# GAME INFO CONSTS
const GAME_VER = "0.3.4"
const GAME_DEMO_NUM = 3

func _ready() -> void:
	if ResourceLoader.exists("res://scripts/client/main_menu.gd"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/server_main.tscn")
