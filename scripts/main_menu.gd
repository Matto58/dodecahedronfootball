extends Control

const MAP_IDS = ["testmap", null]

func changeToBuiltin(mapName: String):
	var map = MapLoader.loadBuiltinMap(mapName)
	if map == null:
		$HBoxContainer/VBoxContainer/Container/Button4.text = "Failed :("
		return
	get_tree().change_scene_to_packed(map)

func updateTrackDisplay(track):
	%nowplaying.text = "♫ Now playing: %s - %s" % [track.artist, track.title]

func _ready() -> void:
	$HBoxContainer/PanelContainer.hide()
	$HBoxContainer/PanelContainer2.hide()
	get_window().title = "Dodecahedron Football Demo " + str(Settoing.GAME_DEMO_NUM) + " [v" + Settoing.GAME_VER + "]"
	%democounter.text = "demo " + str(Settoing.GAME_DEMO_NUM)
	$HBoxContainer/VBoxContainer/Container/Button4.grab_focus()

	$MusicManager.onNewTrackSelected.connect(updateTrackDisplay)
	if Settoing.activeInstance.mainMenuTrack != 0:
		$MusicManager.selectTrackFromIndex(Settoing.activeInstance.mainMenuTrack-1)
	else:
		$MusicManager.selectRandomTrack()
	$MusicManager.audioPlayer.volume_linear = Settoing.activeInstance.masterVolume
	$HBoxContainer/PanelContainer2/settoing.musicMgr = $MusicManager
	updateTrackDisplay($MusicManager.currentlyPlaying)

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
