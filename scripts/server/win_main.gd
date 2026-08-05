extends Control

var map: Map

func _exit_tree() -> void:
	if $Console.net == null: return
	$Console.net.shutDown()

func _ready() -> void:
	get_window().title = "Dodecahedron Football Server [v" + DHMain.GAME_VER + "]"
	$Console/VBoxContainer/conprompt.editable = false
	$FileDialog.show()

func _on_file_dialog_file_selected(path: String) -> void:
	print("loading map " + path)
	var mapScn: PackedScene = load(path)
	map = mapScn.instantiate()
	print("loaded. initializing")
	add_child(map)
	$Console.net = map.net
	print("initialized. ready for players")
	$Console/VBoxContainer/conprompt.editable = true

func _on_file_dialog_canceled() -> void:
	get_tree().quit(1)
