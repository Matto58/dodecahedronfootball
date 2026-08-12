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

static func popup(parent: Node, title: String, text: String, onClose: Callable = func(): pass) -> AcceptDialog:
	var p = AcceptDialog.new()
	p.title = title
	p.dialog_text = text
	p.close_requested.connect(onClose)
	p.confirmed.connect(onClose)
	parent.add_child(p)
	return p

static func ask(parent: Node, title: String, text: String, yesStr: String, noStr: String, onYes: Callable, onNo: Callable) -> ConfirmationDialog:
	var p = ConfirmationDialog.new()
	p.title = title
	p.dialog_text = text
	p.ok_button_text = yesStr
	p.cancel_button_text = noStr
	p.close_requested.connect(onNo)
	p.confirmed.connect(onYes)
	p.canceled.connect(onNo)
	parent.add_child(p)
	return p
