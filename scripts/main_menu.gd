extends Control

const MAP_IDS = ["testmap", null, null]

func changeToBuiltin(mapName: String):
	var map = MapLoader.loadBuiltinMap(mapName)
	if map == null:
		$HBoxContainer/VBoxContainer/Container/Button4.text = "Failed :("
		return
	get_tree().change_scene_to_packed(map)

func _ready() -> void:
	Settoing.activeInstance = Settoing.loadFromFile()
	if Settoing.activeInstance == null: Settoing.activeInstance = Settoing.new()

	%rotsensitivity.value = Settoing.activeInstance.rotMod * 100

	$HBoxContainer/PanelContainer.hide()
	$HBoxContainer/PanelContainer2.hide()
	get_window().title = "Dodecahedron Football Demo " + str(Settoing.GAME_DEMO_NUM) + " [v" + Settoing.GAME_VER + "]"
	%versionlabel.text = "Dodecahedron Football - Version " + Settoing.GAME_VER + " - Demo " + str(Settoing.GAME_DEMO_NUM)
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

func _on_rotationsensitivity_value_changed(value: float) -> void:
	Settoing.activeInstance.rotMod = value / 100
	%rotsensitivitylabel.text = str(value)

func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	print("OPENING url " + str(meta))
	OS.shell_open(str(meta))

func _on_savesettingsbtn_pressed() -> void:
	Settoing.saveToFile(Settoing.activeInstance)

func _on_button_3_pressed() -> void:
	get_tree().quit()
