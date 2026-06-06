extends Control

const MAP_IDS = ["testmap", null, null]

func changeToBuiltin(mapName: String):
	var map = MapLoader.loadBuiltinMap(mapName)
	if map == null:
		$HBoxContainer/VBoxContainer/Container/Button4.text = "Failed :("
		return
	get_tree().change_scene_to_packed(map)

func _ready() -> void:
	$HBoxContainer/PanelContainer.hide()
	$HBoxContainer/PanelContainer2.hide()
	get_window().title = "Dodecahedron Football Demo " + str(Settoing.GAME_DEMO_NUM) + " [v" + Settoing.GAME_VER + "]"
	%democounter.text = "demo " + str(Settoing.GAME_DEMO_NUM)

func _on_button_4_pressed() -> void:
	$HBoxContainer/PanelContainer.show()
	$HBoxContainer/PanelContainer2.hide()

func _on_button_2_pressed() -> void:
	$HBoxContainer/PanelContainer.hide()
	$HBoxContainer/PanelContainer2.show()

func _on_playmapsandbox_pressed() -> void:
	_on_maplist_item_activated(%maplist.get_selected_items()[0])

func _on_maplist_item_selected(index: int) -> void:
	%playmapsandbox.disabled = MAP_IDS[index] == null

func _on_maplist_item_activated(index: int) -> void:
	changeToBuiltin(MAP_IDS[index])

func _on_button_3_pressed() -> void:
	get_tree().quit()
